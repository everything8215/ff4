
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: load.asm                                                             |
; |                                                                            |
; | description: load game from sram slot                                      |
; |                                                                            |
; | created: 3/14/2022                                                         |
; +----------------------------------------------------------------------------+

.import InitCharProp_ext

; ------------------------------------------------------------------------------

; [ game load menu ]

GameLoadMenu:
@9592:  phb
        phd
        jsr     SaveDlgGfx_far
        lda     #$7e
        pha
        plb
        stz     $1b9a
        ldx     #$1be4
        cpx     $1a5f
        beq     @95b2
        stx     $1a5f
        stz     $1a3c
        jsr     _019924
        jsr     InitCtrl_far
@95b2:  jsr     _019982
        jsr     ValidateSRAM
        bcs     @95c0
        jsr     GameLoadMenu_main
        jsr     SelectTopChar
@95c0:  jsr     RestoreDlgGfx_far
        tdc
        xba
        lda     f:$0017fb
        pld
        plb
        rts

; ------------------------------------------------------------------------------

; [ select top character ]

SelectTopChar:
@95cc:  stz     $48
@95ce:  lda     $48
        jsr     GetSelCharPtr
        lda     a:$0000,x
        and     #$3f
        bne     @95e2                   ; find first valid character slot
        inc     $48
        lda     $48
        cmp     #5
        bne     @95ce
@95e2:  lda     $48
        sta     $e7
        sta     $1b3e
        sta     $1b8a
        ldx     #$ffd8
        stx     $1ba5
        lda     $16a9
        sta     $1c
        rts

; ------------------------------------------------------------------------------

; [ game load menu main ]

GameLoadMenu_main:
@95f8:  lda     #$15        ; song $15 (the prelude)
        sta     $1e01
        lda     #$01        ; play song
        sta     $1e00
        jsl     ExecSound_ext
        jsr     InitMenu
        lda     #$30        ; sprite layer priority: 3
        sta     $c1
        jsr     _019982
        stz     $1b47
@9613:  jsr     ClearAllBGTiles
        jsr     ResetSprites
        jsr     TfrSprites
        lda     $1a3c
        jsr     _01977f
        jsr     LoadCharGfx
        jsr     _0198c9
        jsr     _0196de
        jsr     SelectBG2
        ldy     #.loword(NewGamePosText)
        jsr     DrawPosText
        jsr     TfrAllBGTiles
        jsr     _0199b8
        jsr     SelectSaveSlot
        lda     $1a3c       ; selected save slot
        bne     @9645
; new game
        jmp     InitSaveSlot
@9645:  jsr     ConfirmSaveSlot
        bcc     @9653
; yes
        jsr     LoadBtnMap
        jsr     SetStereoMono
        jmp     FadeOut
; no
@9653:  jsr     FadeOut
        jmp     @9613

; ------------------------------------------------------------------------------

; [ get player input (select save slot) ]

SelectSaveSlot:
@9659:  lda     $1a3c       ; validate selected save slot
        cmp     #$05
        bcc     @9663
        stz     $1a3c
@9663:  jsr     TfrSpritesVblank
        jsr     TfrPal
        lda     #$1f
        sta     f:hTM     ; show sprites
        inc     $16a7
        jsr     UpdateCtrlMenu
; A button
        lda     $00
        and     #JOY_A
        beq     @967d       ; branch if a button is not pressed
        sec
        rts
; up button
@967d:  lda     $01
        and     #JOY_UP
        beq     @96a8
        lda     #$0f
        sta     f:hTM     ; hide sprites
@9689:  lda     $1b47
        beq     @9696
        lda     $1a3c
        dec
        beq     @969c
        bra     @969e
@9696:  lda     $1a3c
        dec
        bpl     @969e
@969c:  lda     #$04
@969e:  sta     $1a3c
        jsr     _019943
        bcc     @9689
        bra     @96c7
; down button
@96a8:  lda     $01
        and     #JOY_DOWN
        beq     @96d3
        lda     #$0f
        sta     f:hTM     ; hide sprites
@96b4:  lda     $1a3c
        inc
        cmp     #$05
        bne     @96bf
        lda     $1b47
@96bf:  sta     $1a3c
        jsr     _019943
        bcc     @96b4
@96c7:  lda     $1a3c
        jsr     _01977f
        jsr     LoadCharGfx
        jsr     _0198c9
; B button
@96d3:  lda     $01
        and     #JOY_B
        beq     @96db
        clc
        rts
@96db:  jmp     @9659

; ------------------------------------------------------------------------------

; [  ]

_0196de:
@96de:  jsr     UpdateWindowColor_far
        longa
        lda     f:$7006aa
        sta     $a042
        sta     $a04a
        lda     f:$700eaa
        sta     $a002
        sta     $a00a
        lda     f:$7016aa
        sta     $a0c2
        sta     $a0ca
        lda     f:$701eaa
        sta     $a082
        sta     $a08a
        shorta
        tdc
        jsr     DrawSaveSlot
        jsr     DrawSaveSlot
        jsr     DrawSaveSlot
        jsr     DrawSaveSlot
        ldx     #$4000
        stx     $a022
        lda     $34
        pha
        jsr     SelectBG2
        lda     #$30
        sta     $34
        ldy     #.loword(NewGameWindow)
        jsr     DrawWindow
        pla
        sta     $34
        jmp     TfrPal

; ------------------------------------------------------------------------------

; [  ]

_019736:
@9736:  phy
        sta     $73
        stx     $74
        phb
        lda     #$7e
        pha
        plb
        jsr     Div60
        jsr     Div60
        ldx     $73
        lda     $1d
        jsr     HexToDec2
        cmp     #$ff
        bne     @9753
        lda     #$80
@9753:  sta     a:$000a,y
        xba
        sta     a:$000c,y
        longa
        lda     $73
        shorta
        jsr     HexToDec4
        lda     $5a
        sta     a:$0000,y
        lda     $5b
        sta     a:$0002,y
        lda     $5d
        sta     a:$0004,y
        lda     $5e
        sta     a:$0006,y
        lda     #$c8
        sta     a:$0008,y
        plb
        ply
        rts

; ------------------------------------------------------------------------------

; [  ]

_01977f:
@977f:  dec
        bmi     _01979b
        asl3
        sta     $46
        stz     $45
        phb
        longa
        ldx     $45
        ldy     #$1000
        lda     #$07ff
        mvn     #$70,#$00
        shorta
        plb
        rts

_01979b:
@979b:  phb
        longa
        ldx     #.loword(CharName)
        ldy     #$1500
        lda     #$0053
        mvn     #^CharName,#$00
        shorta
        plb
        phb
        phd
        tdc
        pha
        plb
        xba
        ldx     #$0600
        phx
        pld
        jsl     InitCharProp_ext
        pld
        plb
        ldx     $41                     ; zero
        stx     $1007
        stx     $1009
        stz     $1040
        stz     $1080
        stz     $10c0
        stz     $1100
        rts

; ------------------------------------------------------------------------------

; [ confirm selected save slot ]

ConfirmSaveSlot:
@97d3:  jsr     FadeOut
        jsr     ResetScrollRegs
        jsr     ClearAllBGTiles
        jsr     TfrAllBGTiles
        jsr     ResetSprites
        jsr     SelectBG3
        jsr     LoadPortraits
        ldx     #$1be4
        cpx     $17fe       ; check sram fixed value
        bne     @97f5
        jsr     DrawCharsMainMenu
        bra     @9807
@97f5:  jsr     SelectBG3
        ldy     #.loword(MainCharWindow)
        jsr     DrawWindow
        ldx     #$0394
        ldy     #.loword(LoadEmptyPosText)+2
        jsr     DrawMenuText
@9807:  jsr     TfrSprites
        jsr     SelectBG4
        ldy     #.loword(LoadTimeWindow)
        jsr     DrawWindow
        ldy     #.loword(LoadMsgWindow)
        jsr     DrawWindow
        lda     $1b47
        beq     @9826
        ldy     #.loword(SaveConfirmPosText)
        jsr     DrawPosText
        bra     @982c
@9826:  ldy     #.loword(LoadConfirmPosText)
        jsr     DrawPosText
@982c:  ldy     #.loword(LoadYesNoPosText)
        jsr     DrawPosText
        lda     $16a4
        ldx     $16a5
        ldy     #$cb2e
        jsr     _019736
        ldy     #.loword(TimePosText)
        jsr     DrawPosText
        jsr     SelectBG1
        ldy     #.loword(LoadGilWindow)
        jsr     DrawWindow
        ldy     #.loword(GilPosText)+2
        ldx     #$0678
        jsr     DrawMenuText
        ldy     #$062c
        lda     $16a2
        ldx     $16a0
        jsr     DrawNum7
        jsr     TfrAllBGTiles
        jsr     UpdateWindowColor_far
        jsr     TfrPal
        jsr     FadeIn
        stz     $1b46
@9871:  lda     $1b46
        beq     @987a
        lda     #$40
        bra     @987c
@987a:  lda     #$30
@987c:  sta     $46
        lda     #$b8
        sta     $45
        jsr     DrawCursor1
        jsr     TfrSpritesVblank
        jsr     UpdateCtrlMenu
; up or down button
        lda     $01
        and     #JOY_UP|JOY_DOWN
        beq     @989a
        lda     $1b46
        inc
        and     #$01
        sta     $1b46
; A button
@989a:  lda     $00
        and     #JOY_A
        beq     @98a8
        sec
        lda     $1b46
        beq     @98a7
        clc
@98a7:  rts
; B button
@98a8:  lda     $01
        and     #JOY_B
        beq     @98b0
        clc
        rts
@98b0:  jmp     @9871

; ------------------------------------------------------------------------------

; [ transfer character sprite palettes to ppu ]

TfrCharPal:
@98b3:  longa
        ldx     #$fe28      ; character palette buffer
        ldy     #$a160
        lda     #$009f
        mvn     #$7e,#$7e
        shorta
        jsr     WaitVblank
        jmp     TfrPal

; ------------------------------------------------------------------------------

; [  ]

_0198c9:
@98c9:  lda     #$30                    ; sprite layer priority: 3
        sta     $c1
        jsr     TfrCharPal
        jsr     ResetSprites
        tdc
        sta     $1d
        tdc
        sta     $1e
        lda     $1a3c                   ; selected save slot
        asl
        jsr     Tax16
        longa
        lda     f:CharSpritePosTbl,x
        sta     $1f
        shorta
        lda     #5
        sta     $5a
@98ee:  jsr     DrawCharSprite
        longa
        lda     #$0018
        clc
        adc     $1f
        sta     $1f
        shorta
        inc     $1d
        dec     $5a
        bne     @98ee
        rts

; ------------------------------------------------------------------------------

; character sprite positions (load/save/namingway menu)
CharSpritePosTbl:
@9904:
.if LANG_EN
        .byte   $6c,$04,$78,$28,$78,$58,$78,$88,$78,$b8
.else
        .byte   $4e,$04,$78,$28,$78,$58,$78,$88,$78,$b8
.endif

; ------------------------------------------------------------------------------

; [ init save slot ]

InitSaveSlot:
@990e:  jsr     FadeOut
        jsr     InitSRAM
        jsr     SetStereoMono
InitSRAMSlotNoFade:
@9917:  longa
        lda     #$1be4      ; init sram fixed value
        sta     $17fe
        shorta
        stz     $17fb
_019924:
@9924:  longa
        lda     #$0100
        sta     $1a37
        sta     $16ae
        lda     #$0002
        sta     $16b0
        sta     $1a39
        shorta
        lda     #$00
        sta     $1a3b
        sta     $16b2
        rts

; ------------------------------------------------------------------------------

; [  ]

_019943:
@9943:  lda     $1b47
        bne     @994d
        lda     $1a3c
        bne     @994f
@994d:  sec
        rts
@994f:  dec
_019950:
@9950:  sta     $51
        asl3
        sta     $46
        stz     $45
        ldx     $45
        longa
        lda     f:$7007fe,x   ; check sram fixed value
        tay
        shorta
        cpy     #$1be4
        beq     @996d
@9969:  shorta
        clc
        rts
@996d:  lda     $51
        inc
        jsr     CalcChecksum
        longa
        txa
        ldx     $45
        cmp     f:$7007fc,x   ; compare with saved checksum
        bne     @9969
        shorta
        sec
        rts

; ------------------------------------------------------------------------------

; [  ]

_019982:
@9982:  jsr     _01979b
        stz     $48
        stz     $49
@9989:  lda     $48
        jsr     _019950
        bcs     @99ae
        longa
        phb
        lda     $48
        xba
        asl3
        tay
        phy
        ldx     #$1000
        lda     #$07ff
        mvn     #$7e,#$70
        plx
        lda     #$2000
        sta     $06aa,x
        plb
        shorta
@99ae:  lda     $48
        inc
        sta     $48
        cmp     #$04
        bne     @9989
        rts

; ------------------------------------------------------------------------------

; [  ]

_0199b8:
@99b8:  lda     $1b9a
        beq     @99c6
        jsr     _019a1e
        jsr     UpdateScrollRegs_far
        jmp     FadeIn
@99c6:  inc     $1b9a
        tdc
        sta     $88
        ldx     #$ffe8
        stx     $93
        stx     $99
        stx     $9f
        lda     #$03
        sta     $4e
        ldy     #$0030
@99dc:  jsr     UpdateScrollRegsVblank
        longa
        dec     $93
        dec     $99
        dec     $99
        dec     $9f
        dec     $9f
        dec     $9f
        shorta
        dec     $4e
        bne     @99f9
        lda     #$03
        sta     $4e
        inc     $88
@99f9:  jsr     UpdateCtrlMenu
        lda     $00
        and     #JOY_A
        bne     @9a08
        lda     $01
        and     #JOY_UP|JOY_DOWN
        beq     @9a16
@9a08:  jsr     _019a1e
        lda     #$03
        sta     $4e
        lda     #$0f
        sta     $88
        ldy     #$0002
@9a16:  dey
        bne     @99dc
        lda     #$0f
        sta     $88
        rts

; ------------------------------------------------------------------------------

; [  ]

_019a1e:
@9a1e:  lda     #$b8
        sta     $93
        lda     #$88
        sta     $99
        lda     #$58
        sta     $9f
        lda     #$ff
        sta     $94
        sta     $9a
        sta     $a0
        rts

; ------------------------------------------------------------------------------

; [ draw save slot ]

DrawSaveSlot:
@9a33:  pha
        sta     $4b
        asl
        sta     $48
        stz     $49
        ldx     #.loword(SelectBGTbl)
        lda     $4b
        jsr     ExecJumpTbl
        lda     $4b
        bne     @9a4c
        ldy     #$a6c0
        sty     $29
@9a4c:  ldy     #.loword(SaveSlotWindow)
        jsr     DrawWindow
        ldy     #.loword(SavePosText)+2
        ldx     #bg_pos 1,2
        jsr     DrawMenuText
        lda     $4b
        clc
        adc     #$81                    ; add to "1"
        ldy     $29
.if LANG_EN
        sta     a:$00ca,y               ; draw slot index
.else
        sta     a:$00c8,y
.endif
        phb
        lda     #$70
        pha
        plb
        lda     $4b
        jsr     _019950
        bcc     @9ac5
        longa
        lda     $48
        asl2
        xba
        tax
        phx
        phx
@9a7b:  lda     a:$0000,x
        and     #$003f
        cmp     #$0001
        beq     @9a93
        cmp     #$000b             ; find cecil (locks up if no cecil)
        beq     @9a93
        txa
        clc
        adc     #$0040
        tax
        bra     @9a7b
@9a93:  lda     a:$0007,x
        ldy     #$014a
        jsr     _019acf
        lda     a:$0009,x
        ldy     #$0154
        jsr     _019acf
        plx
        lda     $29
        clc
        adc     #$00cc
        tay
        plx
        lda     $06a5,x
        pha
        shorta
        lda     $06a4,x
        plx
        jsr     _019736
        plb
        ldy     $29
        lda     #$c7
        sta     $0152,y
        bra     @9acc
@9ac5:  ldy     #.loword(LoadEmptyPosText)
        jsr     DrawPosText
        plb
@9acc:  pla
        inc
        rts

; ------------------------------------------------------------------------------

; [  ]

_019acf:
@9acf:  phb
        sta     $45
        shorta
        lda     #$7e
        pha
        plb
        longa
        lda     $45
        jsr     _018383
        plb
        rts

; ------------------------------------------------------------------------------

SelectBGTbl:
@9ae1:  .addr   SelectBG2
        .addr   SelectBG1
        .addr   SelectBG4
        .addr   SelectBG3

; ------------------------------------------------------------------------------

; [ validate sram ]

ValidateSRAM:
@9ae9:  longa
        lda     #$1be4      ; check sram fixed value for all slots
        cmp     f:$7007fe
        beq     @9b13
        cmp     f:$700ffe
        beq     @9b13
        cmp     f:$7017fe
        beq     @9b13
        cmp     f:$701ffe
        beq     @9b13
        shorta
        jsr     InitSRAM
        jsr     InitSRAMSlotNoFade
        jsr     SelectTopChar
        sec
        rts
@9b13:  shorta
        clc
        rts

; ------------------------------------------------------------------------------

; [ init sram ]

InitSRAM:
@9b17:  ldx     #$1040
@9b1a:  lda     #0
        sta     a:$0000,x
        inx
        cpx     #$1800
        bne     @9b1a
        ldx     #$3000
        stx     $16aa
        jsr     UpdateWindowColor_far
        longa
        lda     #$0053
        ldx     #.loword(CharName)
        ldy     #$1500
        mvn     #^CharName,#$7e
        lda     #$0005
        ldx     #$1500
        ldy     #$1b0a
        mvn     #$7e,#$7e
        shorta
        lda     #$00
        sta     $16ae
        inc
        sta     $16af
        sta     $16b1
        inc
        sta     $16ad
        sta     $16ac
        sta     $16b0
        rts

; ------------------------------------------------------------------------------
