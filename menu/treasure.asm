
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: treasure.asm                                                         |
; |                                                                            |
; | description: treasure menu                                                 |
; |                                                                            |
; | created: 4/8/2022                                                          |
; +----------------------------------------------------------------------------+

; [ treasure menu ]

TreasureMenu:
@d792:  phb
        phd
        jsr     SaveDlgGfx_far
        jsr     InitMenu
        stz     $1a83
        ldx     $41         ; zero
        txa
        stx     $1bb3
        stx     $1bb5
        sta     $1bb7
        lda     #$08
        sta     $45
        ldx     $41         ; zero
        txy
@d7b0:  lda     $1804,x
        beq     @d7d1
        cmp     #$54
        bcc     @d7c7
        cmp     #$60
        bcs     @d7c7
        sta     $ff28,y
        lda     #$0a
        sta     $ff29,y
        bra     @d7d9
@d7c7:  sta     $ff28,y
        lda     #$01
        sta     $ff29,y
        bra     @d7d9
@d7d1:  lda     #0
        sta     $ff28,y
        sta     $ff29,y
@d7d9:  iny2
        inx
        dec     $45
        bne     @d7b0
        jsr     _01d7f2
        jsr     FadeOut
        stz     $1bc6
        jsr     RestoreDlgGfx_far
        lda     #0
        xba
        pld
        plb
        rts

; ------------------------------------------------------------------------------

; [  ]

_01d7f2:
@d7f2:  ldx     #$ffe0
        stx     $93
        ldx     #$ff88
        stx     $9f
        jsr     SelectBG2
        jsr     _01db40
        jsr     SelectBG1
        ldx     #$ed00      ; items $00-$ed valid (all but key items)
        stx     $1b1d
        inc     $1bc6
        jsr     DrawTreasureList
        jsr     SelectBG4
        ldy     #.loword(TreasureItemsWindow)
        jsr     DrawWindow
        jsr     SelectBG3
        jsr     DrawInventoryList
        jsr     TfrAllBGTiles
        jsr     UpdateScrollRegs_far
        stz     $60
        jsr     FadeIn
@d82b:  jsr     _01d83a
        lda     $60
        beq     @d838
        jsr     CheckKeyItems
        bcs     @d82b
        rts
@d838:  bra     _01d89a

; ------------------------------------------------------------------------------

; [  ]

_01d83a:
@d83a:  jsr     SelectBG2
        ldy     #.loword(TreasureTakeAllPosText)
        jsr     DrawPosText
        jsr     _01d887
        jsr     TfrSpritesVblank
        jsr     TfrBG2Tiles
        jsr     UpdateCtrlMenu
; left or right button
        lda     $01
        and     #JOY_LEFT|JOY_RIGHT
        beq     @d85b
        lda     $60
        eor     #$ff
        sta     $60
; B button
@d85b:  lda     $01
        and     #JOY_B
        beq     @d86c
        lda     $60
        cmp     #$ff
        bne     @d868
        rts
@d868:  lda     #$ff
        sta     $60
; A button
@d86c:  lda     $00
        and     #JOY_A
        beq     @d873
        rts
; down button
@d873:  lda     $01
        and     #JOY_DOWN
        beq     @d884
        stz     $60
        jsr     _01d887
        inc     $1a83
        jmp     _01d93e
@d884:  jmp     _01d83a

; ------------------------------------------------------------------------------

; [  ]

_01d887:
@d887:  lda     $60
        bne     @d88f
.if LANG_EN
        lda     #$58
.else
        lda     #$48
.endif
        bra     @d891
@d88f:  lda     #$b8
@d891:  sta     $45
        lda     #$0e
        sta     $46
        jmp     DrawCursor1

; ------------------------------------------------------------------------------

; [  ]

_01d89a:
@d89a:  ldy     $41         ; zero
        lda     #$08
        sta     $48
@d8a0:  lda     $ff28,y
        beq     @d8d1
        lda     #$30
        sta     $45
        ldx     $41         ; zero
@d8ab:  lda     $ff28,y
        cmp     $1440,x
        bne     @d8cb
        lda     $ff29,y
        clc
        adc     $1441,x
        cmp     #$64
        bcs     @d8cb
        sta     $1441,x
        lda     #0
        sta     $ff28,y
        sta     $ff29,y
        bra     @d8d1
@d8cb:  inx2
        dec     $45
        bne     @d8ab
@d8d1:  iny2
        dec     $48
        bne     @d8a0
        lda     #$08
        sta     $45
        ldy     $41         ; zero
@d8dd:  lda     $ff28,y
        beq     @d8fc
        lda     #0
        phy
        jsr     FindItem
        ply
        cmp     #0
        bne     @d8fc
        longa
        lda     $ff28,y
        sta     $1440,x
        lda     $41         ; zero
        sta     $ff28,y
        shorta
@d8fc:  iny2
        dec     $45
        bne     @d8dd
        ldy     #8
        ldx     $41         ; zero
        txa
@d908:  clc
        adc     $ff29,x
        inx2
        dey
        bne     @d908
        jsr     _01d929
        cmp     #0
        bne     _01d93e
        inc     $60
        jsr     _01d887
        jsr     TfrSpritesVblank
        jsr     SelectBG2
        jsr     TfrBG2TilesVblank
        jmp     WaitKeypress

; ------------------------------------------------------------------------------

; [  ]

_01d929:
@d929:  pha
        jsr     SelectClearBG1
        jsr     DrawTreasureList
        jsr     SelectBG3
        jsr     DrawInventoryList
        jsr     TfrBG1TilesVblank
        jsr     TfrBG3TilesVblank
        pla
        rts

; ------------------------------------------------------------------------------

; [  ]

_01d93e:
@d93e:  lda     $1a83
        stz     $1a83
        bne     @d956
@d946:  jsr     _01d83a
        lda     $60
        beq     @d953
        jsr     CheckKeyItems
        bcs     @d946
        rts
@d953:  jmp     _01d89a
@d956:  jsr     _01d95b
        bra     @d946

; ------------------------------------------------------------------------------

; [  ]

_01d95b:
@d95b:  jsr     SelectBG2
        ldy     #.loword(TreasureExchangePosText)
        jsr     DrawPosText
        jsr     TfrBG2TilesVblank
; start of frame loop
@d967:  lda     $1bb3
        asl4
        adc     #$30
        sta     $5b
        lda     $1bb4
        beq     @d97b
        lda     #$70
        bra     @d97d
@d97b:  lda     #0
@d97d:  sta     $5a
        ldx     $5a
        ldy     #$0304
        tdc
        jsr     DrawCursor
        jsr     TfrSpritesVblank
        jsr     UpdateCtrlMenu
; B button
        lda     $01
        and     #JOY_B
        beq     @d99c
        stz     $60
        ldy     #$0304
        jmp     HideCursor
; A button
@d99c:  lda     $00
        and     #JOY_A
        beq     @d9a5
        jsr     _01d9ea
; right button
@d9a5:  lda     $01
        and     #JOY_RIGHT
        beq     @d9b6
        lda     $1bb4
        inc
        and     #$01
        sta     $1bb4
        beq     @d9dc
; left button
@d9b6:  lda     $01
        and     #JOY_LEFT
        beq     @d9c7
        lda     $1bb4
        inc
        and     #$01
        sta     $1bb4
        bne     @d9cd
; up button
@d9c7:  lda     $01
        and     #JOY_UP
        beq     @d9d6
@d9cd:  lda     $1bb3
        dec
        bmi     @d9d6
        sta     $1bb3
; down button
@d9d6:  lda     $01
        and     #JOY_DOWN
        beq     @d9e7
@d9dc:  lda     $1bb3
        inc
        cmp     #$04
        beq     @d9e7
        sta     $1bb3
@d9e7:  jmp     @d967

; ------------------------------------------------------------------------------

; [  ]

_01d9ea:
@d9ea:  lda     $1bb5
        asl4
        adc     #$86
        sta     $46
        lda     $1bb6
        beq     @d9fe
        lda     #$70
        bra     @da00
@d9fe:  lda     #0
@da00:  sta     $45
        jsr     DrawCursor1
        jsr     TfrSpritesVblank
        jsr     UpdateCtrlMenu
; B button
@da0b:  lda     $01
        and     #JOY_B
        beq     @da14
        jmp     HideCursor1
; A button
@da14:  lda     $00
        and     #JOY_A
        beq     @da20
        jsr     HideCursor1
        jmp     _01daac
; right button
@da20:  lda     $01
        and     #JOY_RIGHT
        beq     @da31
        lda     $1bb6
        inc
        and     #$01
        sta     $1bb6
        beq     @da79
; left button
@da31:  lda     $01
        and     #JOY_LEFT
        beq     @da42
        lda     $1bb6
        inc
        and     #$01
        sta     $1bb6
        bne     @da48
; up button
@da42:  lda     $01
        and     #JOY_UP
        beq     @da73
@da48:  lda     $1bb5
        dec
        bpl     @da70
        lda     $1bb7
        dec
        bmi     @da73
        sta     $1bb7
        lda     #$08
@da59:  longa
        dec     $9f
        dec     $9f
        shorta
        jsr     UpdateScrollRegsVblank
        dec
        bne     @da59
        jsr     UpdateCtrlMenu
        ldx     $02
        stx     $00
        bra     @da0b
@da70:  sta     $1bb5
; down button
@da73:  lda     $01
        and     #JOY_DOWN
        beq     @daa9
@da79:  lda     $1bb5
        inc
        cmp     #$05
        bne     @daa6
        lda     $1bb7
        inc
        cmp     #$14
        beq     @daa9
        sta     $1bb7
        lda     #$08
@da8e:  longa
        inc     $9f
        inc     $9f
        shorta
        jsr     UpdateScrollRegsVblank
        dec
        bne     @da8e
        jsr     UpdateCtrlMenu
        ldx     $02
        stx     $00
        jmp     @da0b
@daa6:  sta     $1bb5
@daa9:  jmp     _01d9ea

; ------------------------------------------------------------------------------

; [  ]

_01daac:
@daac:  lda     $1bb3
        asl
        adc     $1bb4
        asl
        jsr     Tax16
        lda     $1bb5
        clc
        adc     $1bb7
        asl
        adc     $1bb6
        asl
        sta     $43
        ldy     $43
        lda     $1440,y
        cmp     #$19
        beq     @db03
        cmp     #$c8
        beq     @db03
        cmp     #$ee
        bcs     @db03
        lda     $1440,y
        cmp     $ff28,x
        bne     @daf1
        lda     $ff29,x
        clc
        adc     $1441,y
        cmp     #$64
        bcs     @db03
        sta     $1441,y
        stz     $ff29,x
        bra     @db03
@daf1:  longa
        lda     $1440,y
        pha
        lda     $ff28,x
        sta     $1440,y
        pla
        sta     $ff28,x
        shorta
@db03:  jmp     _01d929
        longa
        lda     $41         ; zero
        sta     $ff28,x
        shorta
        bra     @db03

; ------------------------------------------------------------------------------

; [ check for key items ]

CheckKeyItems:
@db11:  ldx     $41                     ; zero
@db13:  lda     $ff28,x
        cmp     #$19                    ; legend sword
        beq     @db2b
        cmp     #$c8                    ; crystal
        beq     @db2b
        cmp     #$ee                    ; key items
        bcs     @db2b
        inx2
        cpx     #$0010
        bne     @db13
        clc
        rts
@db2b:  jsr     SelectBG2
        ldy     #.loword(TreasureWarningWindow)
        jsr     DrawWindowText
        jsr     TfrBG2TilesVblank
        jsr     ErrorSfx
        jsr     WaitKeypress
        jsr     ClearBG2Tiles
; fallthrough

; ------------------------------------------------------------------------------

; [  ]

_01db40:
@db40:  ldy     #.loword(TreasureChoiceWindow)
        jsr     DrawWindow
        ldy     #.loword(TreasureLabelWindow)
        jsr     DrawWindowText
        jsr     TfrBG2TilesVblank
        sec
        rts

; ------------------------------------------------------------------------------
