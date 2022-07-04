
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: fat_choco.asm                                                        |
; |                                                                            |
; | description: fat chocobo menu                                              |
; |                                                                            |
; | created: 4/8/2022                                                          |
; +----------------------------------------------------------------------------+

; [ fat chocobo menu (from field) ]

FatChocoMenu:
@cc95:  php
        phb
        phd
        ldx     #$0100
        phx
        pld
        lda     #$7e
        pha
        plb
        jsr     SaveDlgGfx_far
        stz     $1a88
        jsr     FatChocoMain
        tdc
        xba
        jsr     RestoreDlgGfx_far
        pld
        plb
        plp
        rts

; ------------------------------------------------------------------------------

; [ fat chocobo menu (whistle) ]

FatChocoWhistle:
@ccb3:  lda     $1e05       ; save current song id
        pha
        stz     $1b19
        lda     #$01
        sta     $1a88
        ldx     $93
        stx     $1ba5
        lda     #$85        ; fade out music (slow)
        sta     $1e00
        jsl     ExecSound_ext
        jsr     FadeOut
        lda     #$4c
        jsr     PlaySfx
        lda     #$f0
@ccd7:  jsr     WaitVblank
        dec
        bne     @ccd7
        lda     #$30
        jsr     PlaySong2
        jsr     FatChocoMain
        pla
        jsr     PlaySong2
        lda     #$00
        xba
        ldx     $1a65
        txs
        rts

; ------------------------------------------------------------------------------

; [ play song ]

PlaySong2:
@ccf1:  sta     $1e01
        lda     #$01
        sta     $1e00
        jsl     ExecSound_ext
        rts

; ------------------------------------------------------------------------------

; [ fat chocobo menu ]

FatChocoMain:
@ccfe:  jsr     InitMenu
        jsr     LoadCharGfx
        lda     #$01
        sta     $1a73
        longa
        lda     f:$000204     ; save irq jump code
        pha
        lda     f:$000206
        pha
        shorta
        sei
        lda     #<FatChocoIRQ        ; irq: 01/ce2c
        sta     f:$000205
        lda     #>FatChocoIRQ
        sta     f:$000206
        lda     #^FatChocoIRQ
        sta     f:$000207
        lda     #$21
        sta     f:hNMITIMEN     ; enable irq
        lda     f:hTIMEUP
        cli
        inc     $1b49
        jsr     ClearAllBGTiles
        jsr     ResetSprites
        jsr     TfrAllBGTiles
        jsr     InitFatChocoboMenu
        jsr     LoadFatChocoGfx
        jsr     TfrSprites
        jsr     TfrPal
        jsr     FadeIn
        jsr     ChooseFatChocoCommand
        stz     $1b49
        jsr     FadeOut
        sei
        longa
        pla
        sta     f:$000206
        pla
        sta     f:$000204
        shorta
        rts

; ------------------------------------------------------------------------------

; [ init fat chocobo menu ]

InitFatChocoboMenu:
@cd69:  ldx     #$48c0
        stx     $1a71
        jsr     TfrCharPal
        jsr     InitPartySprites
        stz     $e0
        jsr     SelectBG3
        ldy     #.loword(FatChocoMsgWindow)
        jsr     DrawWindow
        ldy     #.loword(FatChocoChoiceWindow)
        jmp     DrawWindowText

; ------------------------------------------------------------------------------

; [ choose a fat chocobo command (give or take) ]

ChooseFatChocoCommand:
@cd86:  jsr     DrawFatChocoSprite
@cd89:  jsr     SelectBG3
        lda     $1a88
        beq     @cd9b
        lda     $1a02
        bne     @cd9b
        ldy     #.loword(FatChocoMsg2PosText)   ; used whistle
        bra     @cd9e
@cd9b:  ldy     #.loword(FatChocoMsg1PosText)   ; used gysahl greens
@cd9e:  jsr     DrawPosText
        stz     $1a88
        jsr     TfrBG3TilesVblank
        lda     #$17
        sta     f:hTM
        cli
@cdae:  lda     $1baf
        beq     @cdb8
        ldx     #$4040
        bra     @cdbb
@cdb8:  ldx     #$4010
@cdbb:  ldy     #$0310
        jsr     DrawCursor
        jsr     _01d12e
        ldx     #$3188
        jsr     UpdatePartySpritesNamingway
        jsr     TfrSpritesVblank
        jsr     UpdateCtrlMenu
; left or right button
        lda     $01
        and     #JOY_LEFT|JOY_RIGHT
        beq     @cddf
        lda     $1baf
        inc
        and     #$01
        sta     $1baf
; B button
@cddf:  lda     $01
        and     #JOY_B
        beq     @cde6
        rts
; A button
@cde6:  lda     $00
        and     #JOY_A
        beq     @ce25
        stz     $1bb2
        stz     $1bb0
        stz     $1bb1
        ldx     #$1340
        jsr     SortItems
        ldx     #$ed00      ; items $00-$ed valid (all but key items)
        stx     $1b1d
        ldx     #.loword(FatChocoJumpTbl)
        lda     $1baf
        jsr     ExecJumpTbl
        jsr     ClearBG4Tiles
        jsr     ClearBG3Tiles
        jsr     InitFatChocoboMenu
        jsr     HideCursor1
        jsr     HideCursor2
        jsr     TfrBG4TilesVblank
        jsr     TfrBG3TilesVblank
        jsr     TfrSprites
        jmp     @cd89
@ce25:  jmp     @cdae

; ------------------------------------------------------------------------------

; fat chocobo jump table
FatChocoJumpTbl:
@ce28:  .addr   FatChocoGive
        .addr   FatChocoTake

; ------------------------------------------------------------------------------

; [ fat chocobo irq ]

FatChocoIRQ:
@ce2c:  php
        longa
        pha
        shorta
        phb
        lda     #$00
        pha
        plb
        lda     $4211
        lda     #$0f
@ce3c:  dec
        bne     @ce3c
        lda     $01e0
        beq     @ce58
        lda     #$58        ; scanline 88
        sta     $4209
        lda     #$00
        sta     $420a
        stz     $01e0
        lda     #$17        ; disable bg4
        sta     $212c
        bra     @ce7b
@ce58:  lda     #$1f        ; enable bg4
        sta     $212c
        inc     $01e0
        lda     #$cb        ; scanline 203
        sta     $4209
        lda     #$00
        sta     $420a
        lda     $019a
        xba
        lda     $0199
        sta     $2114       ; bg4 v-scroll
        sta     $2114
        xba
        sta     $2114
@ce7b:  plb
        longa
        pla
        plp
        rti
.a8

; ------------------------------------------------------------------------------

; [ choose item to give to fat chocobo ]

FatChocoGive:
@ce81:  jsr     SelectBG3
        ldy     #.loword(FatChocoMsg3PosText)  ; what will you give me?
        jsr     DrawPosText
        jsr     TfrBG3TilesVblank
        jsr     SelectClearBG4
        jsr     DrawInventoryList
        lda     #$11
        sta     $e2
        ldx     #$ffb0
        stx     $99

; common code for give and take
FatChocoSelectItem:
@ce9c:  jsr     SelectBG3
        ldy     #.loword(FatChocoListWindow)
        jsr     DrawWindow
        jsr     TfrBG4TilesVblank
        jsr     TfrBG3TilesVblank
; start of frame loop
@ceab:  jsr     UpdateCtrlMenu
        jsr     FatChocoDrawCursor
        jsr     _01d0ea
        ldx     #$3188
        jsr     UpdatePartySpritesNamingway
        jsr     TfrSpritesVblank
        jsr     TfrBG4Tiles
; B button
@cec0:  lda     $01
        and     #JOY_B
        beq     @cece
        ldx     #$1340
        jsr     SortItems
        clc
        rts
; A button
@cece:  lda     $00
        and     #JOY_A
        beq     @cee2
        lda     $e2
        cmp     #$11
        beq     @cedf
        jsr     FatChocoTakeItem
        bra     @cee2
@cedf:  jsr     FatChocoGiveItem
; right button
@cee2:  lda     $01
        and     #JOY_RIGHT
        beq     @cef5
        lda     $1bb1
        beq     @cef2
        stz     $1bb1
        bra     @cf46
@cef2:  inc     $1bb1
; left button
@cef5:  lda     $01
        and     #JOY_LEFT
        beq     @cf08
        lda     $1bb1
        bne     @cf05
        inc     $1bb1
        bra     @cf0e
@cf05:  stz     $1bb1
; up button
@cf08:  lda     $01
        and     #JOY_UP
        beq     @cf40
@cf0e:  lda     $1bb0
        bne     @cf3d
        lda     $1bb2
        beq     @cf40
        dec     $1bb2
        lda     #$08
@cf1d:  longa
        dec     $99
        dec     $99
        shorta
        pha
        jsr     FatChocoDrawCursor
        jsr     TfrSpritesVblank
        jsr     TfrBG4Tiles
        pla
        dec
        bne     @cf1d
        jsr     UpdateCtrlMenu
        ldx     $02
        stx     $00
        jmp     @cec0
@cf3d:  dec     $1bb0
; down button
@cf40:  lda     $01
        and     #JOY_DOWN
        beq     @cf7c
@cf46:  lda     $1bb0
        cmp     #$06
        bne     @cf79
        lda     $1bb2
        cmp     $e2
        beq     @cf7c
        inc     $1bb2
        lda     #$08
@cf59:  longa
        inc     $99
        inc     $99
        shorta
        pha
        jsr     FatChocoDrawCursor
        jsr     TfrSpritesVblank
        jsr     TfrBG4Tiles
        pla
        dec
        bne     @cf59
        jsr     UpdateCtrlMenu
        ldx     $02
        stx     $00
        jmp     @cec0
@cf79:  inc     $1bb0
@cf7c:  jmp     @ceab

; ------------------------------------------------------------------------------

; [ draw fat chocobo list cursor ]

FatChocoDrawCursor:
@cf7f:  lda     $1bb0
        asl4
        clc
        adc     #$5f
        sta     $5b
        lda     $1bb1
        beq     @cf94
        lda     #$78
        bra     @cf96
@cf94:  lda     #$08
@cf96:  sta     $5a
        ldx     $5a
        ldy     #$0300
        tdc
        jsr     DrawCursor
        jsl     ScrollFatChocoList
        rts

; ------------------------------------------------------------------------------

; [ calculate item offset from cursor position ]

FatChocoCalcOffset:
@cfa6:  lda     $1bb2
        clc
        adc     $1bb0
        asl
        adc     $1bb1
        asl
        sta     $43
        ldx     $43
        rts

; ------------------------------------------------------------------------------

; [ give an item to fat chocobo ]

FatChocoGiveItem:
@cfb7:  jsr     FatChocoCalcOffset
        lda     $1440,x
        beq     @cfcb
        cmp     #$19
        beq     @cfcb
        cmp     #$c8
        beq     @cfcb
        cmp     #$ee
        bcc     @cfcd
@cfcb:  bra     _cffa
@cfcd:  lda     #$7e
        sta     $45
        ldy     $41         ; zero
@cfd3:  lda     $1340,y
        beq     _cffb
        cmp     $1440,x
        bne     @cfe8
        lda     $1341,y
        clc
        adc     $1441,x
        cmp     #$64
        bcc     _cffb
@cfe8:  iny2
        dec     $45
        bne     @cfd3
        jsr     SelectBG3
        ldy     #.loword(FatChocoMsg5PosText)  ; i can't eat any more
        jsr     DrawPosText
        jsr     TfrBG3TilesVblank
_cffa:  rts
_cffb:  lda     $1440,x
        sta     $1340,y
        lda     $1441,x
        clc
        adc     $1341,y
        sta     $1341,y
        stz     $1440,x
        stz     $1441,x
        jsr     SelectClearBG4
        jsr     DrawInventoryList
        jmp     TfrBG4TilesVblank

; ------------------------------------------------------------------------------

; [  ]

FatChocoTakeItem:
@d01a:  jsr     FatChocoCalcOffset
        lda     $1340,x
        beq     _cffa
        lda     #$30
        sta     $45
        ldy     $41         ; zero
@d028:  lda     $1440,y
        beq     @d03f
        iny2
        dec     $45
        bne     @d028
        jsr     SelectBG3
        ldy     #.loword(FatChocoMsg6PosText)  ; organize your bag!
        jsr     DrawPosText
        jmp     TfrBG3TilesVblank
@d03f:  longa
        lda     $1340,x
        sta     $1440,y
        stz     $1340,x
        shorta
        jsr     _01d052
        jmp     TfrBG4TilesVblank

; ------------------------------------------------------------------------------

; [ draw inventory list (fat chocobo) ]

DrawFatChocoInventory:
_01d052:
@d052:  jsr     ClearBG1Tiles
        jsr     SelectClearBG2
        jsr     DrawFatChocoList
        jsl     CopyFatChocoList
        rts

; ------------------------------------------------------------------------------

; [ choose item to take from fat chocobo ]

FatChocoTake:
@d060:  ldx     #$ffa8
        stx     $99
        inc     $1bcc
        jsr     SelectBG3
        ldy     #.loword(FatChocoMsg4PosText)  ; what will you take?
        jsr     DrawPosText
        jsr     TfrBG3TilesVblank
        lda     #$38
        sta     $e2
        jsr     _01d052
        jsr     FatChocoSelectItem
        stz     $1bcc
        rts

; ------------------------------------------------------------------------------

; [ load fat chocobo graphics ]

LoadFatChocoGfx:
@d082:  longa
        lda     #$000f
        ldx     #.loword(MapSpritePal)+17*16
        ldy     #$a120
        mvn     #^MapSpritePal,#$7e
        shorta
        ldy     #$f200      ; 1b/f200 (fat chocobo graphics)

; namingway jumps in here
_01d095:
@d095:  phb
        phd
        lda     #$1b
        pha
        plb
        ldx     #$2100
        phx
        pld
        lda     #$80
        sta     $15
        ldx     #$4600
        stx     $16
        lda     #$10
        sta     $0145
@d0ae:  ldx     #$0008
@d0b1:  lda     a:$0000,y
        sta     $18
        lda     a:$0001,y
        sta     $19
        iny2
        dex
        bne     @d0b1
        ldx     #$0008
@d0c3:  lda     a:$0000,y
        sta     $18
        stz     $19
        iny
        dex
        bne     @d0c3
        dec     $0145
        bne     @d0ae
        jsr     DrawFatChocoSprite
        pld
        plb
        rts

; ------------------------------------------------------------------------------

; [ draw fat chocobo sprite ]

DrawFatChocoSprite:
@d0d9:  longa
        lda     #$003f
        ldx     #.loword(FatChocoSpriteTbl)
        ldy     #$0480
        mvn     #^FatChocoSpriteTbl,#$7e
        shorta
        rts

; ------------------------------------------------------------------------------

; [  ]

_01d0ea:
@d0ea:  jsr     _01d12e
        jsr     FatChocoCalcOffset
        lda     $1baf
        beq     @d0fa
        lda     $1340,x
        bra     @d0fd
@d0fa:  lda     $1440,x
@d0fd:  bne     @d100
@d0ff:  rts
@d100:  cmp     #$ce
        bcs     @d0ff
        sta     $1b39
        tdc
@d108:  jsr     _01d111
        inc
        cmp     #$05
        bne     @d108
        rts

; ------------------------------------------------------------------------------

; [  ]

_01d111:
@d111:  pha
        sta     $57
        jsr     GetCharID
        beq     @d12c
        stx     $e5
        jsr     CheckClassEquip
        bcc     @d12c
        lda     $57
        asl
        sta     $43
        ldx     $43
        lda     #$08
        sta     $1b4b,x
@d12c:  pla
        rts

; ------------------------------------------------------------------------------

; [  ]

_01d12e:
@d12e:  longa
        stz     $1b4b
        stz     $1b4d
        stz     $1b4f
        stz     $1b51
        stz     $1b53
        shorta
        rts

; ------------------------------------------------------------------------------
