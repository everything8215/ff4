
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: config.asm                                                           |
; |                                                                            |
; | description: config menu                                                   |
; |                                                                            |
; | created: 4/8/2022                                                          |
; +----------------------------------------------------------------------------+

; [ config menu ]

ConfigMenu:
@d142:  lda     #$30
        sta     $3f
        jsr     ResetBGScroll
        ldx     #$fffc
        stx     $8d
        stx     $8a
        jsr     UpdateScrollRegs_far
        jsr     FadeOut
        lda     #$13
        sta     f:hTM
        ldx     #$4040                  ; destination (vram)
        stx     $1d
        ldx     #.loword(WindowColorCursorGfx)
        stx     $1f
        lda     #^WindowColorCursorGfx
        sta     $0121
        ldx     #$0020                  ; size
        stx     $0122
        jsr     TfrVRAM
        jsr     ResetSprites
        jsr     TfrSprites
        jsr     InitCtrl_far
        jsr     ConfigMenuSelect
        jsr     FadeOut
        lda     #$1f
        sta     f:hTM
        jsr     ClearBG2Tiles
        jsr     ClearBG1Tiles
        jsr     TfrBG2Tiles
        jsr     ResetSprites
        jsr     DrawAllPortraits
        jsr     TfrSprites
        jsr     TfrBG1Tiles
        jmp     FadeIn

; ------------------------------------------------------------------------------

; [ config menu (select option) ]

ConfigMenuSelect:
@d1a1:  jsr     SelectBG1
        ldy     #.loword(ConfigMainWindow)
        jsr     DrawWindowText
        ldy     #.loword(ConfigLabelWindow)
        jsr     DrawWindow
        ldy     #.loword(ConfigLabelPosText)
        jsr     DrawPosText
        lda     #$53
        sta     $bb1e
        lda     #$48
        sta     $bb9e
        lda     #$43
        sta     $bc1e
.if SIMPLE_CONFIG
        ldx     #bg_pos 15,12
.else
        ldx     #bg_pos 15,10
.endif
        ldy     #.loword(BattleNumText)
        jsr     CopyText
        ldx     #bg_pos 15,8
        ldy     #.loword(BattleNumText)
        jsr     CopyText
        jsr     GraySpeedNumeral
        ldy     #$bb22                  ; bg1 (17,20)
        jsr     DrawColorTicks
        ldy     #$bba2
        jsr     DrawColorTicks
        ldy     #$bc22
        jsr     DrawColorTicks
        jsr     TfrBG1Tiles
        ldx     $16aa
        jsr     CalcColorComponents
        jsr     FadeIn
; start of frame loop
@d1f8:
.if !SIMPLE_CONFIG
        lda     $16b8       ; controller setting
        jsr     GetConfigXPos
        sta     $0304
        lda     #$80
        sta     $0305
        lda     $16be       ; battle mode
        jsr     GetConfigXPos
        sta     $45
        lda     #$30
        sta     $46
        jsr     DrawCursor1
.endif
        jsr     GraySpeedNumeral
        lda     $16ac
        asl2
        jsr     Tax16
        lda     #$00
        sta     $b81f,x
        lda     $16ad
        asl2
        jsr     Tax16
        lda     #$00
.if SIMPLE_CONFIG
        sta     $b91f,x
        lda     $1ba7
        pha
        jsr     Tax16
        lda     f:ConfigCursorYTbl,x
        sta     $46
        pla
        cmp     #$03
.else
        sta     $b89f,x
        lda     $1ba7
        pha
        asl4
        adc     #$30
        sta     $46
        pla
        cmp     #$07
.endif
        bcc     @d247
        lda     #$68
        bra     @d249
@d247:  lda     #$18
@d249:  sta     $45
        jsr     DrawCursor2
        lda     $1ba8                   ; red color component cursor
        asl
        adc     #$86
        sta     $0320
        lda     #$a0
        sta     $0321
        lda     $1ba9                   ; green color component cursor
        asl
        adc     #$86
        sta     $0324
        lda     #$b0
        sta     $0325
        lda     $1baa                   ; blue color component cursor
        asl
        adc     #$86
        sta     $0328
        lda     #$c0
        sta     $0329
        jsr     CalcWindowColor
        ldx     $45
        stx     $16aa
        jsr     UpdateWindowColor_far
        lda     #$04
        sta     $0322
        sta     $0326
        sta     $032a
        lda     #$30
        sta     $0323
        sta     $0327
        sta     $032b
        lda     $16b6
        jsr     GetConfigXPos
        sta     $030c
.if SIMPLE_CONFIG
        lda     #$78
        sta     $030d
.else
        lda     #$60
        sta     $030d
        lda     $16a9
        jsr     GetConfigXPos
        sta     $0308
        lda     #$70
        sta     $0309
        lda     $16b7
        jsr     GetConfigXPos
        sta     $0314
        lda     #$90
        sta     $0315
.endif
        ldx     #$300a
        stx     $0306
        stx     $030a
        stx     $030e
        stx     $0316
        stx     $031a
        jsr     TfrSpritesVblank
        jsr     TfrBG1Tiles
        jsr     TfrPal
        jsr     UpdateCtrlMenu
; B button
        lda     $01
        and     #JOY_B
        beq     @d2e8
        rts
@d2e8:
.if !SIMPLE_CONFIG
; A button
        lda     $00
        and     #JOY_A
        beq     @d30c
        lda     $1ba7
        cmp     #$04
        bne     @d2fd
        lda     $16a9
        beq     @d31d
        jsr     BtnMapMenu
@d2fd:  cmp     #$05
        bne     @d30c
        lda     $16b8
        beq     @d30c
        jsr     MultiCtrlMenu
        jsr     ResetSprites
.endif
; up button
@d30c:  lda     $01
        and     #JOY_UP
        beq     @d31d
        lda     $1ba7
        dec
.if SIMPLE_CONFIG
        bpl     @d293
        lda     #5
@d293:  sta     $1ba7
.else
        bpl     @d31a
        lda     #9
@d31a:  sta     $1ba7
.endif
; down button
@d31d:  lda     $01
        and     #JOY_DOWN
        beq     @d32f
        lda     $1ba7
        inc
.if SIMPLE_CONFIG
        cmp     #6
.else
        cmp     #10
.endif
        bne     @d32c
        tdc
@d32c:  sta     $1ba7

@d32f:
.if SIMPLE_CONFIG

        lda     $01
        and     #$02
        beq     @d2ea
        lda     $1ba7
        bne     @d2be
        lda     $16ac
        dec
        bmi     @d2ea
        sta     $16ac
        bra     @d2ea
@d2be:  dec
        bne     @d2cc
        lda     $16ad
        dec
        bmi     @d2ea
        sta     $16ad
        bra     @d2ea
@d2cc:  dec
        bne     @d2d4
        jsr     ToggleStereoMono
        bra     @d2ea
@d2d4:  dec
        asl
        jsr     Tax16
        longa
        lda     f:ColorComponentPtrs,x
        sta     $45
        shorta
        lda     ($45)
        dec
        bmi     @d2ea
        sta     ($45)
@d2ea:  lda     $01
        and     #$01
        beq     @d332
        lda     $1ba7
        bne     @d302
        lda     $16ac
        inc
        cmp     #$06
        beq     @d332
        sta     $16ac
        bra     @d332
@d302:  dec
        bne     @d312
        lda     $16ad
        inc
        cmp     #$06
        beq     @d332
        sta     $16ad
        bra     @d332
@d312:  dec
        bne     @d31a
        jsr     ToggleStereoMono
        bra     @d332
@d31a:  dec
        asl
        jsr     Tax16
        longa
        lda     f:ColorComponentPtrs,x
        sta     $45
        shorta
        lda     ($45)
        inc
        cmp     #$20
        beq     @d332
        sta     ($45)
@d332:  jmp     @d1f8

.else

; left button
        lda     $01
        and     #$02
        beq     @d396
; 0: change battle mode
        lda     $1ba7
        bne     @d33f
        jsr     ToggleActiveWait
        bra     @d396
; 1: change battle speed
@d33f:  dec
        bne     @d34d
        lda     $16ac
        dec
        bmi     @d396
        sta     $16ac
        bra     @d396
; 2: change battle message speed
@d34d:  dec
        bne     @d35b
        lda     $16ad
        dec
        bmi     @d396
        sta     $16ad
        bra     @d396
; 3: toggle stereo/mono
@d35b:  dec
        bne     @d363
        jsr     ToggleStereoMono
        bra     @d396
; 4: toggle default/custom button mapping
@d363:  dec
        bne     @d36b
        jsr     ToggleCustomBtnMap
        bra     @d396
; 5: toggle single/multi-controller
@d36b:  dec
        bne     @d373
        jsr     ToggleMultiCtrl
        bra     @d396
; 7-9: change window color
@d373:  dec
        beq     @d38e
        dec
        asl
        jsr     Tax16
        longa
        lda     f:ColorComponentPtrs,x
        sta     $45
        shorta
        lda     ($45)
        dec                 ; decrement color component
        bmi     @d396
        sta     ($45)
        bra     @d396
; 6: toggle cursor reset/memory
@d38e:  lda     $16b7
        eor     #$01
        sta     $16b7
; right button
@d396:  lda     $01
        and     #$01
        beq     @d403
; 0: change battle mode
        lda     $1ba7
        bne     @d3a6
        jsr     ToggleActiveWait
        bra     @d403
; 1: change battle speed
@d3a6:  dec
        bne     @d3b6
        lda     $16ac
        inc
        cmp     #$06
        beq     @d403
        sta     $16ac
        bra     @d403
; 2: change battle message speed
@d3b6:  dec
        bne     @d3c6
        lda     $16ad
        inc
        cmp     #$06
        beq     @d403
        sta     $16ad
        bra     @d403
; 3: toggle stereo/mono
@d3c6:  dec
        bne     @d3ce
        jsr     ToggleStereoMono
        bra     @d403
; 4: toggle default/custom button mapping
@d3ce:  dec
        bne     @d3d6
        jsr     ToggleCustomBtnMap
        bra     @d403
; 5: toggle single/multi-controller
@d3d6:  dec
        bne     @d3de
        jsr     ToggleMultiCtrl
        bra     @d403
; 7-9: change window color
@d3de:  dec
        beq     @d3fb
        dec
        asl
        jsr     Tax16
        longa
        lda     f:ColorComponentPtrs,x
        sta     $45
        shorta
        lda     ($45)
        inc                 ; increment color component
        cmp     #$20
        beq     @d403
        sta     ($45)
        bra     @d403
; 6: toggle cursor reset/memory
@d3fb:  lda     $16b7
        eor     #$01
        sta     $16b7
@d403:  jmp     @d1f8

.endif

; ------------------------------------------------------------------------------

; [ draw color slider tick marks ]

DrawColorTicks:
@d406:  ldx     $41         ; zero
@d408:  lda     f:ColorTicksTbl,x
        sta     a:$0000,y
        iny2
        inx
        cpx     #9
        bne     @d408
        rts

; ------------------------------------------------------------------------------

; color slider tick marks
ColorTicksTbl:
@d418:  .byte   1,2,2,2,1,2,2,2,3

; pointers to window color components

ColorComponentPtrs:
@d421:  .word   $1ba8,$1ba9,$1baa

; ------------------------------------------------------------------------------

; [ get window color from components ]

CalcWindowColor:
@d427:  lda     $1ba9
        sta     $43
        longa
        lda     $43
        asl5
        sta     $45
        shorta
        lda     $1ba8
        ora     $45
        sta     $45
        lda     $1baa
        asl2
        ora     $46
        sta     $46
        rts

; ------------------------------------------------------------------------------

; [ get components from window color ]

CalcColorComponents:
@d44a:  stx     $45
        lda     $45
        and     #$1f
        sta     $1ba8       ; red
        longa
        lda     $16aa
        lsr5
        shorta
        and     #$1f
        sta     $1ba9       ; green
        lda     $46
        lsr2
        sta     $1baa       ; blue
        rts

; ------------------------------------------------------------------------------

; [ set stereo/mono ]

SetStereoMono:
@d46c:  lda     #$90
        sta     $1e00
        lda     $16b6
        and     #$01
        sta     $1e01
        jsl     ExecSound_ext
        rts

; ------------------------------------------------------------------------------

.if !SIMPLE_CONFIG

; [ button mapping menu ]

BtnMapMenu:
@d47e:  jsr     SelectBG2
        ldy     #.loword(BtnMapWindow)
        jsr     DrawWindow
        ldy     #.loword(ConfigLabelWindow)
        jsr     DrawWindow
        ldy     #.loword(BtnMapPosText)
        jsr     DrawPosText
        ldx     #$0394
        ldy     #.loword(BtnList1Text)
        jsr     DrawMenuText
        ldx     #$0414
        ldy     #.loword(BtnList1Text)
        jsr     DrawMenuText
        ldy     #.loword(BtnList2Text)
        ldx     #$0294
        jsr     DrawMenuText
        ldy     #.loword(BtnList2Text)
        ldx     #$0314
        jsr     DrawMenuText
        ldy     #.loword(BtnList2Text)
        ldx     #$0214
        jsr     DrawMenuText
        jsr     ResetSprites
        jsr     TfrSpritesVblank
        jsr     OpenWindow
        jsr     SelectBtnMap
        jsr     ClearBG2Tiles
        jsr     ResetSprites
        jsr     TfrSpritesVblank
        jsr     CloseWindow
        jmp     SelectBG1

; ------------------------------------------------------------------------------

; [ get player input (button mapping menu) ]

SelectBtnMap:
@d4db:  lda     $1bb9
        asl4
        adc     #$4b
        sta     $46
        lda     #$0a
        sta     $45
        ldy     #$0314
        jsr     DrawCursorBtnMap
        lda     $16ae
        jsr     GetBtnMapXPos
        lda     #$4a
        sta     $46
        jsr     DrawCursor1
        lda     $16af
        jsr     GetBtnMapXPos
        lda     #$5a
        sta     $46
        jsr     DrawCursor2
        lda     $16b0
        jsr     GetBtnMapXPos
        lda     #$6a
        sta     $46
        ldy     #$030c
        jsr     DrawCursorBtnMap
        lda     $16b1
        jsr     Tax16
        lda     f:BtnMapYTbl,x
        sta     $45
        lda     #$7a
        sta     $46
        ldy     #$0308
        jsr     DrawCursorBtnMap
        lda     $16b2
        jsr     Tax16
        lda     f:BtnMapYTbl,x
        sta     $45
        lda     #$8a
        sta     $46
        ldy     #$0318
        jsr     DrawCursorBtnMap
        jsr     TfrSpritesVblank
        jsr     UpdateCtrlMenu

; B button
        lda     $01
        and     #JOY_B
        beq     @d557
        lda     #$05
        sta     $1bb9

; up button
@d557:  lda     $01
        and     #JOY_UP
        beq     @d568
        lda     $1bb9
        dec
        bpl     @d565
        lda     #$05
@d565:  sta     $1bb9

; down button
@d568:  lda     $01
        and     #JOY_DOWN
        beq     @d57b
        lda     $1bb9
        inc
        cmp     #$06
        bne     @d578
        lda     #$00
@d578:  sta     $1bb9

; right button
@d57b:  lda     $01
        and     #JOY_RIGHT
        beq     @d59a
        lda     $1bb9
        cmp     #$05
        beq     @d5b8
        jsr     Tax16
        lda     $16ae,x
        inc
        cmp     f:BtnMapMaxValue,x
        bne     @d597
        lda     #0
@d597:  sta     $16ae,x

; left button
@d59a:  lda     $01
        and     #JOY_LEFT
        beq     @d5b8
        lda     $1bb9
        cmp     #$05
        beq     @d5b8
        jsr     Tax16
        lda     $16ae,x
        dec
        bpl     @d5b5
        lda     f:BtnMapMaxValue,x
        dec
@d5b5:  sta     $16ae,x

; A button
@d5b8:  lda     $00
        and     #JOY_A
        beq     @d5c8
        lda     $1bb9
        cmp     #$05
        bne     @d5c8
        jsr     ValidateBtnMap
@d5c8:  lda     $01
        and     #$c0
        bne     @d5d7
        lda     $00
        and     #$c0
        bne     @d5d7
@d5d4:  jmp     SelectBtnMap
@d5d7:  jsr     ValidateBtnMap
        bra     @d5d4

; ------------------------------------------------------------------------------

; [ validate button mapping ]

ValidateBtnMap:
@d5dc:  lda     $16ae
        cmp     $16af
        beq     LoadBtnMapError
        cmp     $16b0
        beq     LoadBtnMapError
        lda     $16af
        cmp     $16b0
        beq     LoadBtnMapError
        plx

; [ load button map ]

LoadBtnMap:
@d5f2:  ldx     $16ae
        stx     $1a37
        ldx     $16b0
        stx     $1a39
        lda     $16b2
        sta     $1a3b
        jmp     InitCtrl_far

LoadBtnMapError:
@d607:  jmp     ErrorSfx

.endif

; ------------------------------------------------------------------------------

; [ get button mapping cursor x position ]

GetBtnMapXPos:
@d60a:  jsr     Tax16
        lda     f:BtnMapXTbl,x
        sta     $45
        rts

; ------------------------------------------------------------------------------

; button mapping cursor x positions
BtnMapXTbl:
@d614:  .byte   $44,$5c,$74,$8c,$a4

; button mapping cursor y positions
BtnMapYTbl:
@d619:  .byte   $44,$6c,$94,$bc

; ------------------------------------------------------------------------------

; [ get toggle cursor x position ]

GetConfigXPos:
@d61d:  and     #$01
        beq     @d625
        lda     #$a0
        bra     @d627
@d625:  lda     #$68
@d627:  rts

; ------------------------------------------------------------------------------

; [ toggle stereo/mono ]

ToggleStereoMono:
@d628:  lda     $16b6
        eor     #$01
        sta     $16b6
        jmp     SetStereoMono

; ------------------------------------------------------------------------------

; [ toggle single/multi-controller ]

ToggleMultiCtrl:
@d633:  lda     $16b8
        eor     #$01
        sta     $16b8
        rts

; ------------------------------------------------------------------------------

; [ toggle active/wait mode ]

.if !SIMPLE_CONFIG

ToggleActiveWait:
@d63c:  lda     $16be
        eor     #$01
        sta     $16be
        rts

.endif

; ------------------------------------------------------------------------------

; [ toggle default/custom button mapping ]

ToggleCustomBtnMap:
@d645:  lda     $16a9
        eor     #$01
        sta     $16a9
        sta     $1a64
        rts

; ------------------------------------------------------------------------------

; max selected value for each button mapping (confirm, cancel, menu, L, start)
BtnMapMaxValue:
@d651:  .byte   5,5,5,4,4

; ------------------------------------------------------------------------------

.if !SIMPLE_CONFIG

; [ multi-controller menu ]

MultiCtrlMenu:
@d656:  jsr     SelectBG2
        ldy     #.loword(ConfigLabelWindow)
        jsr     DrawWindow
        ldy     #.loword(MultiCtrlWindow)
        jsr     DrawWindowText
        stz     $48
        stz     $49
        ldy     #$0212
@d66c:  ldx     $48
        lda     f:CharOrderTbl,x   ; character battle order
        phy
        jsr     GetCharPtr
        lda     a:$0000,x
        jsr     DrawCharName
        ply
        phy
        jsr     Iny_8
        jsr     Iny_4
        tyx
        ldy     #.loword(MultiCtrlPtxt)+2
        jsr     DrawMenuText
        ply
        jsr     NextRowY
        jsr     NextRowY
        inc     $48
        lda     $48
        cmp     #5
        bne     @d66c
        lda     $1bc7
        sta     $45
@d69f:  lda     $45
        jsr     GetSlotCharID
        bne     @d6b2
        inc     $45
        lda     $45
        cmp     #5
        bne     @d69f
        stz     $45
        bra     @d69f
@d6b2:  lda     $45
        sta     $1bc7
        jsr     ResetSprites
        jsr     TfrSpritesVblank
        jsr     OpenWindow
; start of frame loop
@d6c0:  lda     $1bc7
        asl4
        adc     #$4a
        sta     $46
        lda     #$38
        sta     $45
        jsr     DrawCursor1
        stz     $45
        stz     $46
@d6d6:  lda     $45
        asl
        jsr     Tax16
        longa
        lda     f:MultiCtrlTilePtrs,x   ; tilemap offset
        tay
        shorta
        lda     $45
        jsr     GetMultiCtrlChar
        lsr
        clc
        adc     #$81                    ; "1" or "2"
        sta     $a600,y
        inc     $45
        lda     $45
        cmp     #$05
        bne     @d6d6
        jsr     TfrBG2TilesVblank
        jsr     TfrSprites
        jsr     UpdateCtrlMenu
; B button
        lda     $01
        and     #JOY_B
        beq     @d70b
        jmp     TfrClearBG2Tiles
; up button
@d70b:  lda     $01
        and     #JOY_UP
        beq     @d721
@d711:  lda     $1bc7
        dec
        bpl     @d719
        lda     #4
@d719:  sta     $1bc7
        jsr     GetMultiCtrlCharID
        beq     @d711
; down button
@d721:  lda     $01
        and     #JOY_DOWN
        beq     @d739
@d727:  lda     $1bc7
        inc
        cmp     #5
        bne     @d731
        lda     #0
@d731:  sta     $1bc7
        jsr     GetMultiCtrlCharID
        beq     @d727
; left or right button
@d739:  lda     $01
        and     #JOY_LEFT|JOY_RIGHT
        beq     @d74b
        jsr     GetMultiCtrlSelChar
        dec2
        bpl     @d748
        lda     #$02
@d748:  sta     $16b9,x
@d74b:  jmp     @d6c0

.endif

; ------------------------------------------------------------------------------

; [ get controller for character ]

GetMultiCtrlSelChar:
@d74e:  lda     $1bc7                   ; a: character slot

GetMultiCtrlChar:
@d751:  jsr     Tax16
        lda     f:CharOrderTbl,x        ; character battle order
        jsr     Tax16
        lda     $16b9,x
        rts

; ------------------------------------------------------------------------------

; [ get character id ]

GetMultiCtrlCharID:
@d75f:  jsr     Tax16
        lda     f:CharOrderTbl,x        ; character battle order
        jsr     GetCharPtr
        lda     a:$0000,x
        and     #$3f
        rts

; ------------------------------------------------------------------------------

; tilemap offsets for character controller numeral
MultiCtrlTilePtrs:
@d76f:  .word   $026e,$02ee,$036e,$03ee,$046e

; ------------------------------------------------------------------------------

; [ change battle speed numerals to gray ]

GraySpeedNumeral:
@d779:  ldy     #$b81f                  ; bg1 (15,8)
        jsr     @d782
.if SIMPLE_CONFIG
        ldy     #$b91f                  ; bg1 (15,12)
.else
        ldy     #$b89f                  ; bg1 (15,10)
.endif
@d782:  lda     #$04
        ldx     #$0006
@d787:  sta     a:$0000,y
        iny4
        dex
        bne     @d787
        rts

; ------------------------------------------------------------------------------

; [ load button map ]

.if SIMPLE_CONFIG

LoadBtnMap:
@d434:  ldx     $16ae
        stx     $1a37
        ldx     $16b0
        stx     $1a39
        lda     $16b2
        sta     $1a3b
        jmp     InitCtrl_far

; ------------------------------------------------------------------------------

ConfigCursorYTbl:
@d449:  .byte   $30,$50,$78,$a0,$b0,$c0

.endif

; ------------------------------------------------------------------------------
