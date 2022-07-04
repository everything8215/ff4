
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: magic.asm                                                            |
; |                                                                            |
; | description: magic menu routines                                           |
; |                                                                            |
; | created: 4/7/2022                                                          |
; +----------------------------------------------------------------------------+

.import MagicName

; ------------------------------------------------------------------------------

; pointers to window data for each character
CharMagicWindowPtrs:
@aec9:  .addr   Char1MagicWindow
        .addr   Char2MagicWindow
        .addr   Char3MagicWindow
        .addr   Char4MagicWindow
        .addr   Char5MagicWindow

; ------------------------------------------------------------------------------

; [ magic menu ]

; subroutine starts at 01/aee5

_aed3:  jsr     SelectBG2
        ldy     #.loword(CantUseMagicWindow)
        jsr     DrawWindowText
        jsr     TfrBG2TilesVblank
        jsr     WaitKeypress
        jmp     TfrClearBG2Tiles

; subroutine starts here
ShowMagicMenu:
@aee5:  stz     $1b27
        jsr     SelectChar
        lda     $e8
        bpl     @aef0
        rts
@aef0:  lda     $e8
        jsr     GetCharID
        bne     @aef8
        rts
@aef8:  phx
        jsl     LoadMagicCursorPos
        plx
        lda     a:$0003,x
        sta     $1a86
        and     #$c4
        bne     _aed3
        lda     a:$0001,x
        and     #$0f
        sta     $45
        asl
        adc     $45
        jsr     Tax16
        lda     f:SpellListTbl,x
        and     f:SpellListTbl+1,x
        and     f:SpellListTbl+2,x
        cmp     #$ff
        beq     _aed3                   ; branch if character can't use magic
        phx
        jsr     ResetSprites
        lda     $e8
        jsr     DrawPosPortrait
        jsr     TfrSpritesVblank
        jsr     ClearBG3Tiles
        jsr     DrawAllCharBlocks
        jsr     TfrBG3TilesVblank
        lda     #$20
        sta     $3f
        jsr     SelectBG4
        ldy     #.loword(MainOptionsWindow)
        jsr     DrawWindow
        ldy     #.loword(MagicLabelPosText) ; this doesn't get drawn
        ldy     #.loword(MainOptionsWindow)
        ldx     #.loword(MagicTypeWindow)
        jsr     TransformWindow
        ldx     #.loword(UpdatePortraitPos)
        stx     $d0
        ldx     #.loword(TfrSprites)    ; transfer sprite data to ppu
        stx     $cd
        lda     $e8
        jsr     CalcPortraitPos
        longa
        tya
        shorta
        sta     $ba
        xba
        sta     $bc
        stz     $b9
        stz     $bb
        lda     #$28
        sta     $c2
        sta     $d2
        lda     #$c8
        sta     $b3
        sta     $bd
        lda     #$81
        sta     $b4
        sta     $be
        lda     $e7
        sta     $b7
        sta     $c0
        lda     #$68
        sta     $b0
        lda     #$04
        sta     $ae
        lda     #$34
        sta     $ad
        lda     $e8
        sta     $d3
        plx
        lda     f:SpellListTbl,x
        sta     $1b7e
        bmi     @afa7
        ldy     #.loword(WhiteMagicStr)
        bra     @afaa
@afa7:  ldy     #.loword(BlankMagicStr1)
@afaa:  jsr     DrawPosText
        lda     f:SpellListTbl+1,x
        sta     $1b7f
        bmi     @afbb
        ldy     #.loword(BlackMagicStr)
        bra     @afbe
@afbb:  ldy     #.loword(BlankMagicStr2)
@afbe:  jsr     DrawPosText
        lda     f:SpellListTbl+2,x
        sta     $1b80
        bmi     @afcf
        ldy     #.loword(SummonMagicStr)
        bra     @afd2
@afcf:  ldy     #.loword(BlankMagicStr3)
@afd2:  jsr     DrawPosText
        lda     $e8
        jsr     GetCharID
        cmp     #$12
        bne     @afe4
        ldy     #.loword(NinjutsuMagicStr)
        jsr     DrawPosText
@afe4:  jsr     SelectBG1
        ldy     #.loword(MagicListWindow)
        jsr     DrawWindow
@afed:  lda     $1b81
        jsr     Tax16
        lda     $1b7e,x
        bpl     @b007
        lda     $1b81
        inc
        cmp     #$03
        bne     @b002
        lda     #$00
@b002:  sta     $1b81
        bra     @afed
@b007:  inc     $1b87
        jsr     _01b255
        stz     $1b87
        ldx     #$ff18
        stx     $93
        jsr     UpdateScrollRegs_far
        lda     #$05
        sta     $ab
        lda     #$9a
        sta     $aa
        jsr     TfrBG1TilesVblank
        jsr     SelectBG3
        jsr     DrawSelCharBlock
        lda     $e7
        asl
        jsr     Tax16
        longa
        lda     f:CharMagicWindowPtrs,x
        tax
        shorta
        ldy     #.loword(MainCharWindow)
        jsr     TransformWindow
        jsr     _01b0bb
        lda     #$30
        sta     $3f
        jsr     ResetSprites
        jsr     SelectBG4
        ldy     #$020a                  ; (16,10)
        lda     #$0d                    ; 13 tiles wide
        sec                             ; set tiles to $ff
        jsr     ClearText_far
        jsr     TfrBG4TilesVblank
        jsr     TfrSprites
        lda     #$28
        sta     $c2
        lda     #$01
        sta     $b4
        lda     $e7
        ora     #$80
        sta     $b7
        sta     $c0
        lda     #$68
        sta     $b0
        lda     #$84
        sta     $ae
        lda     #$34
        sta     $ad
        lda     #$06
        sta     $ab
        jsr     SelectBG3
        lda     $e7
        asl
        jsr     Tax16
        longa
        lda     f:CharMagicWindowPtrs,x
        tay
        shorta
        ldx     #.loword(MainCharWindow)
        jsr     TransformWindow
        jsr     ClearBG1Tiles
        jsr     ResetBGScroll
        jsr     TfrBG1TilesVblank
        jsr     UpdateScrollRegs_far
        jsr     SelectBG4
        ldy     #.loword(MagicTypeWindow)
        ldx     #.loword(MainOptionsWindow)
        jsr     TransformWindow
        jsr     DrawMainMenu
        jsr     TfrBG3TilesVblank
        jsr     SelectBG4
        jsr     OpenWindow
        jsl     SaveMagicCursorPos
        rts

; ------------------------------------------------------------------------------

; [  ]

_01b0bb:
@b0bb:  lda     $1b87
        bne     @b0d4
        stz     $1b93
        lda     $1b81
        asl4
        adc     #$10
        sta     $46
        lda     #$08
        sta     $45
        bra     @b0d7
@b0d4:  jsr     _01b36d
@b0d7:  jsr     DrawCursor1
        jsr     SelectBG4
        jsr     _01b3ec
        jsr     _01b426
        sta     $1b93
        ldy     #$021a
        jsr     DrawNum2
        ldx     #$020a
        ldy     #.loword(MPNeededPosText)+2
        jsr     CopyText
        lda     #$c3
.if LANG_EN
        sta     $c818
.else
        sta     $c816
.endif
        jsr     TfrSpritesVblank
        jsr     TfrBG4Tiles
        jsr     UpdateCtrlMenu
        lda     $1b87
        bne     @b164
; up button
        lda     $01
        and     #JOY_UP
        beq     @b12c
        lda     $1b81
        sta     $43
@b113:  lda     $43
        dec
        bpl     @b11a
        lda     #$02
@b11a:  jsr     Tax16
        lda     $1b7e,x
        bmi     @b113
        pha
        lda     $43
        sta     $1b81
        pla
        jsr     _01b24c
; down button
@b12c:  lda     $01
        and     #JOY_DOWN
        beq     @b151
        lda     $1b81
        sta     $43
@b137:  lda     $43
        inc
        cmp     #$03
        bne     @b13f
        tdc
@b13f:  jsr     Tax16
        lda     $1b7e,x
        bmi     @b137
        pha
        lda     $43
        sta     $1b81
        pla
        jsr     _01b24c
; A button
@b151:  lda     $00
        and     #JOY_A
        beq     @b15a
        inc     $1b87
; B button
@b15a:  lda     $01
        and     #JOY_B
        beq     @b161
        rts
@b161:  jmp     _01b0bb
; up button
@b164:  lda     $01
        and     #JOY_UP
        beq     @b175
        lda     $1b83
        dec
        bpl     @b172
        lda     #$07
@b172:  sta     $1b83
; down button
@b175:  lda     $01
        and     #JOY_DOWN
        beq     @b187
        lda     $1b83
        inc
        cmp     #$08
        bne     @b184
        tdc
@b184:  sta     $1b83
; left button
@b187:  lda     $01
        and     #JOY_LEFT
        beq     @b198
        lda     $1b84
        dec
        bpl     @b195
        lda     #$02
@b195:  sta     $1b84
; right button
@b198:  lda     $01
        and     #JOY_RIGHT
        beq     @b1aa
        lda     $1b84
        inc
        cmp     #$03
        bne     @b1a7
        tdc
@b1a7:  sta     $1b84
; A button
@b1aa:  lda     $00
        and     #JOY_A
        beq     @b1da
        lda     $1b88
        bne     @b1d2
        inc     $1b88
        ldx     $1b83
        stx     $1b85
        jsr     _01b36d
        longa
        lda     $45
        clc
        adc     #$0404
        sta     $45
        shorta
        jsr     DrawCursor2
        bra     @b1e9
@b1d2:  stz     $1b88
        jsr     _01b387
        bra     @b1e9
; B button
@b1da:  lda     $01
        and     #JOY_B
        beq     @b1e9
        stz     $1b87
        stz     $1b88
        jsr     HideMagicCursors
; X button
@b1e9:  lda     $00
        and     #JOY_X
        beq     @b20e
        lda     $1b81
        sta     $43
@b1f4:  lda     $43
        inc
        cmp     #$03
        bne     @b1fc
        tdc
@b1fc:  jsr     Tax16
        lda     $1b7e,x
        bmi     @b1f4
        pha
        lda     $43
        sta     $1b81
        pla
        jsr     _01b24c
@b20e:  jmp     _01b0bb

; ------------------------------------------------------------------------------

_01b211:
@b211:  .byte   $10,$58,$a0

; magic type names
.if LANG_EN

WhiteMagicStr:
@b1ec:  .byte   $f0,$00,$58,$63,$64,$6f,$60,$00
BlackMagicStr:
@b1f4:  .byte   $70,$01,$43,$67,$5c,$5e,$66,$00
SummonMagicStr:
@b1fc:  .byte   $f0,$01,$44,$5c,$67,$67,$00
NinjutsuMagicStr:
@b203:  .byte   $70,$01,$4f,$64,$69,$65,$5c,$00

.else

WhiteMagicStr:
@b214:  .byte   $f0,$00,$95,$b4,$a8,$a7,$8c,$00
BlackMagicStr:
@b21c:  .byte   $70,$01,$91,$b4,$a8,$a7,$8c,$00
SummonMagicStr:
@b224:  .byte   $f0,$01,$95,$7f,$8c,$8f,$b6,$00
NinjutsuMagicStr:
@b22c:  .byte   $70,$01,$9f,$b6,$16,$7e,$9b,$00

.endif

; blank lines to clear magic type names
BlankMagicStr1:
@b234:  .byte   $f0,$00,$ff,$ff,$ff,$ff,$ff,$00
BlankMagicStr2:
@b23c:  .byte   $70,$01,$ff,$ff,$ff,$ff,$ff,$00
BlankMagicStr3:
@b244:  .byte   $f0,$01,$ff,$ff,$ff,$ff,$ff,$00

; ------------------------------------------------------------------------------

; [  ]

_01b24c:
@b24c:  jsr     SelectBG1
        jsr     _01b255
        jmp     TfrBG1TilesVblank

; ------------------------------------------------------------------------------

; [  ]

_01b255:
@b255:  sta     $43
        jsr     SelectBG1
        longa
        lda     $43
        asl3
        sta     $48
        asl
        adc     $48
        adc     #$1560
        sta     $60
@b26b:  shorta
        stz     $5e
        stz     $5b
        lda     #$08
        sta     $5a
        ldy     $41         ; zero
@b277:  lda     #$03
        sta     $5d
@b27b:  longa
        lda     $5d
        dec
        asl
        tax
        lda     #$0008
        sec
        sbc     $5a
        xba
        and     #$ff00
        lsr
        clc
        adc     f:_1efebd,x
        tax
        shorta
        lda     ($60),y
        jsr     DrawMagicName
        iny
        dec     $5d
        bne     @b27b
        dec     $5a
        bne     @b277
        shorta
        rts

; ------------------------------------------------------------------------------

; [ draw spell name ]

DrawMagicName:
@b2a6:  pha
        phx
        cmp     #$0e
        bcc     @b2cf
        cmp     #$1c
        bcs     @b2cf
        sta     $1a87
        phy
        jsr     _01b43c
        ply
        sta     $1bc4
        stz     $1bc5
        lda     $e8
        jsr     GetCharPtr
        longa
        lda     a:$000b,x
        cmp     $1bc4
        shorta
        bcs     @b2da
@b2cf:  lda     $1bc8
        bne     @b2da
@b2d4:  lda     $34
        ora     #$04
        bra     @b303
@b2da:  lda     $1a87
        cmp     #$12
        beq     @b301
        lda     $1a86
        and     #$28
        beq     @b301
        and     #$20
        beq     @b2f3
        lda     $1a87
        cmp     #$19
        beq     @b301
@b2f3:  lda     $1a86
        and     #$08
        beq     @b2d4
        lda     $1a87
        cmp     #$1a
        bne     @b2d4
@b301:  lda     $34
@b303:  sta     $db
        plx
        pla
        pha
        longa
        txa
        clc
        adc     $29
        tax
        shorta
        pla
        phb
        phx
        phy
        xba
        lda     #$00
        xba
        longa
        asl
        sta     $45
        asl
        adc     $45
        adc     #.loword(MagicName)
        tay
        shorta
        lda     #^MagicName
        pha
        plb
        lda     a:$0000,y
        iny
        sta     $7e0040,x
        lda     #$ff
        sta     $7e0000,x
        inx
        lda     $db
        sta     $7e0000,x
        sta     $7e0040,x
        inx
        lda     #5
        sta     $45
@b349:  lda     a:$0000,y
        jsr     GetDakuten
        sta     $7e0000,x   ; dakuten
        xba
        sta     $7e0040,x   ; kana
        inx
        lda     $db
        sta     $7e0000,x
        sta     $7e0040,x
        inx
        iny
        dec     $45
        bne     @b349
        ply
        plx
        plb
        rts

; ------------------------------------------------------------------------------

; [  ]

_01b36d:
@b36d:  lda     $1b83                   ; x position
        asl4
        adc     #$56
        sta     $46
        lda     $1b84                   ; y position
        shorti
        tax
        lda     f:_01b211,x
        longi
        sta     $45
        rts

; ------------------------------------------------------------------------------

; [  ]

_01b387:
@b387:  ldx     $1b83
        cpx     $1b85
        bne     @b392
        jmp     UseMagic
@b392:  stz     $1b88
        jsr     HideCursor2
        lda     $1b83
        asl
        adc     $1b83
        adc     $1b84
        jsr     _01b3d2
        tay
        lda     $1b85
        asl
        adc     $1b85
        adc     $1b86
        jsr     _01b3d2
        tax
        lda     $1560,x
        pha
        lda     $1560,y
        sta     $1560,x
        pla
        sta     $1560,y
        jsr     _01b3c8
        jmp     _01b24c

; ------------------------------------------------------------------------------

; [  ]

_01b3c8:
@b3c8:  lda     $1b81
        jsr     Tax16
        lda     $1b7e,x
        rts

; ------------------------------------------------------------------------------

; [  ]

_01b3d2:
@b3d2:  sta     $1d
        stz     $1e
        jsr     _01b3c8
        xba
        lda     #$00
        xba
        longa
        asl3
        sta     $45
        asl
        adc     $45
        adc     $1d
        shorta
        rts

; ------------------------------------------------------------------------------

; [  ]

_01b3ec:
@b3ec:  lda     #$24
        ldx     #$0130
        jsr     @b418
        ldx     #$01b0
        jsr     @b418
        ldx     #$0230
        jsr     @b418
        lda     $1b81
        bne     @b40a
        ldx     #$0130
        bra     @b416
@b40a:  cmp     #$01
        bne     @b413
        ldx     #$01b0
        bra     @b416
@b413:  ldx     #$0230
@b416:  lda     #$20
@b418:  pha
        ldy     #$0005
@b41c:  sta     $c601,x
        inx2
        dey
        bne     @b41c
        pla
        rts

; ------------------------------------------------------------------------------

; [  ]

_01b426:
@b426:  lda     $1b87
        beq     _b454
        lda     $1b83
        asl
        adc     $1b83
        adc     $1b84
        jsr     _01b3d2
        tay
        lda     $1560,y
; fallthrough

; ------------------------------------------------------------------------------

; [  ]

_01b43c:
@b43c:  xba
        lda     #0
        xba
        longa
        asl
        sta     $45
        asl
        adc     $45
        tax
        shorta
        lda     $0f97a5,x
        and     #$7f
        sta     $1b93
_b454:  lda     $1b93
        rts

; ------------------------------------------------------------------------------

; [ draw spell target select windows ]

DrawSpellTargetWindows:
@b458:  lda     #$0f
        sta     f:hTM
        jsr     LoadPortraits

_01b461:
@b461:  lda     #$20        ; sprite layer priority: 2
        sta     $c1
        jsr     SelectBG1
        jsr     HideMagicCursors
        stz     $1b88
        lda     $1b83
        asl
        adc     $1b83
        adc     $1b84
        jsr     _01b3d2
        tay
        lda     $1560,y                 ; spell list
        sta     $1b89
        sec
        sbc     #$0e
        jsr     Tax16
        lda     f:MagicMultiTarget,x   ; multi-target flag
        sta     $1b90
        ldy     #.loword(MagicTargetWindow)
        jsr     DrawWindow
        ldy     #.loword(MagicWhomWindow)
        jsr     DrawWindow
        ldy     #.loword(MagicNameWindow)
        jsr     DrawWindow
        jsr     SelectBG1
        lda     $1b89
        ldx     #$0044
        jsr     DrawMagicName
        ldy     #.loword(MPNeededPosText)
        jsr     DrawPosText
        ldy     #.loword(MagicWhomPosText)
        jsr     DrawPosText
        jsr     _01b426
        sta     $1b93
.if LANG_EN
        ldy     #$01ca
.else
        ldy     #$01c8
.endif
        jsr     DrawNum2
        ldx     #$02e0
        ldy     #$1000
        jsr     DrawCharBlock
        ldx     #$0060
        ldy     #$1040
        jsr     DrawCharBlock
        ldx     #$0560
        ldy     #$1080
        jsr     DrawCharBlock
        ldx     #$01a0
        ldy     #$10c0
        jsr     DrawCharBlock
        ldx     #$0420
        ldy     #$1100
        jsr     DrawCharBlock
        lda     $16a8
        and     #$01
        asl
        sta     $45
        asl2
        adc     $45
        jsr     Tax16
        lda     #$00
        jsr     DrawPortraitMagic
        jsr     DrawPortraitMagic
        jsr     DrawPortraitMagic
        jsr     DrawPortraitMagic
        jsr     DrawPortraitMagic
        lda     #$1f
        sta     f:hTM
        rts

; ------------------------------------------------------------------------------

; [ cast spell ]

; subroutine starts at 01/b53d

; spell unuseable
MagicError:
@b519:  jsr     HideMagicCursors
        jmp     ErrorSfx

HideMagicCursors:
@b51f:  jsr     HideCursor2
        jmp     HideCursor1

; warp
WarpEffect:
@b525:  stz     $1b87
        stz     $1b88
        jmp     MagicEffect_1b

; exit, sight
SightEffect:
@b52e:  stz     $1b87
        stz     $1b88
        sec
        sbc     #$16
        ldx     #.loword(MagicEffectTbl)+16
        jmp     ExecJumpTbl

; subroutine starts here
UseMagic:
@b53d:  stz     $1b87
        jsr     SelectBG1
        stz     $1b88
        lda     $1b83
        asl
        adc     $1b83
        adc     $1b84
        jsr     _01b3d2
        tay
        lda     $1560,y
        cmp     #$0e
        bcc     MagicError
        cmp     #$1c
        bcs     MagicError
        sta     $1b89
        cmp     #$12
        beq     @b588
        jsr     GetCharStatus
        and     #$28
        beq     @b588
        bit     #$20
        beq     @b578
        lda     $1b89
        cmp     #$19
        beq     @b588
@b578:  jsr     GetCharStatus
        bit     #$08
        beq     @b586
        lda     $1b89
        cmp     #$1a
        beq     @b588
@b586:  bra     MagicError
@b588:  jsr     _01ba05
        bpl     @b596
        jsr     _01b97e
        jsr     ErrorSfx
        jmp     @b618
@b596:  lda     $1560,y
        cmp     #$16
        beq     SightEffect
        cmp     #$17
        beq     SightEffect
        cmp     #$1b
        beq     WarpEffect
        jsr     HideCursor2
        jsr     HideCursor1
        jsr     _01b97e
        jsr     ResetSprites
        jsr     TfrSpritesVblank
        jsr     _01b461
        jsr     OpenWindow
        jsr     TfrSpritesVblank
        stz     $1b8b
        stz     $1b8c
        stz     $1b8d
        stz     $1b8e
        stz     $1b8f
        stz     $1bbb
@b5cf:  lda     $1b8a
        jsr     GetSlotCharID
        bne     @b5e6
        lda     $1b8a
        inc
        cmp     #$05
        bne     @b5e1
        lda     #$00
@b5e1:  sta     $1b8a
        bra     @b5cf
@b5e6:  lda     $1bbb
        beq     @b5f0
        jsr     HideCursor1
        bra     @b606
@b5f0:  lda     $1b8a
        asl2
        adc     $1b8a
        asl3
        adc     #$20
        sta     $46
        lda     #$40
        sta     $45
        jsr     DrawCursor1
@b606:  ldy     #$0310
        jsr     _01b6c7
        jsr     TfrSpritesVblank
        jsr     UpdateCtrlMenu
; B button
        lda     $01
        and     #JOY_B
        beq     @b63d
@b618:  jsr     SelectClearBG1
        ldy     #.loword(MagicListWindow)
        jsr     DrawWindow
        jsr     _01b3c8
        jsr     _01b24c
        jsr     _01b98f
        lda     #$00        ; sprite layer priority: 0
        sta     $c1
        jsr     HideCursor2
        jsr     HideCursor1
        jsr     SelectBG1
        jsr     TfrSpritesVblank
        jmp     TfrBG1Tiles
; A button
@b63d:  lda     $00
        and     #JOY_A
        beq     @b653
        lda     $1b8a
        jsr     Tax16
        lda     #$ff
        sta     $1b8b,x
        jsr     _01b717
        bra     @b618
; up button
@b653:  lda     $01
        and     #JOY_UP
        beq     @b669
@b659:  lda     $1b8a
        dec
        bpl     @b661
        lda     #$04
@b661:  sta     $1b8a
        jsr     GetSlotCharID
        beq     @b659
; down button
@b669:  lda     $01
        and     #JOY_DOWN
        beq     @b681
@b66f:  lda     $1b8a
        inc
        cmp     #$05
        bne     @b679
        lda     #$00
@b679:  sta     $1b8a
        jsr     GetSlotCharID
        beq     @b66f
; left or right button
@b681:  lda     $01
        and     #JOY_LEFT|JOY_RIGHT
        beq     @b6ae
        lda     $1b90
        beq     @b6ae
        ldy     #$0004
@b68f:  tya
        jsr     GetSelCharPtr
        lda     a:$0000,x
        and     #$3f
        beq     @b6a3
        tyx
        lda     $1b8b,x
        eor     #$ff
        sta     $1b8b,x
@b6a3:  dey
        bpl     @b68f
        lda     #$ff
        eor     $1bbb
        sta     $1bbb
@b6ae:  jmp     @b5e6

; ------------------------------------------------------------------------------

; [ draw portrait (spell target select) ]

DrawPortraitMagic:
@b6b1:  pha
        phx
        pha
        longa
        lda     f:MagicPortraitPosTbl,x   ; portrait positions for spell target select
        tay
        shorta
        pla
        jsr     DrawPortrait
        plx
        pla
        inc
        inx2
        rts

; ------------------------------------------------------------------------------

; [  ]

_01b6c7:
@b6c7:  lda     $1b9b
        pha
        phy
        jsr     Tax16
        lda     $1b8b,x
        bne     @b6ea
        lda     #$08
        sta     $45
@b6d8:  lda     #$ff
        sta     a:$0000,y
        iny
        lda     #$f0
        sta     a:$0000,y
        iny
        dec     $45
        bne     @b6d8
        bra     @b701
@b6ea:  lda     $43
        asl2
        adc     $43
        asl3
        adc     #$24
        sta     $46
        lda     #$44
        sta     $45
        ldx     $45
        tdc
        jsr     DrawCursor
@b701:  ply
        longa
        tya
        clc
        adc     #$0010
        tay
        shorta
        pla
        inc
        cmp     #$05
        bcc     @b713
        tdc
@b713:  sta     $1b9b
        rts

; ------------------------------------------------------------------------------

; [  ]

_01b717:
@b717:  jsr     _01ba05
        longa
        sta     a:$000b,x
        shorta
        lda     $1b89
        sec
        sbc     #$0e
        pha
        jsl     PlayMagicSfx
        pla
        ldx     #.loword(MagicEffectTbl)
        jsr     ExecJumpTbl
        jsr     GetCharStatus
        sta     $1a86
        jsr     SelectClearBG1
        ldy     #.loword(MagicListWindow)
        jsr     DrawWindow
        jsr     _01b3c8
        jsr     _01b255
        jsr     DrawSpellTargetWindows
        jsr     HideCursor1
        jsr     TfrBG1TilesVblank
        jsr     TfrSprites
        jsr     WaitKeypress
        jsr     SelectBG3
        jsr     _0188c8
        jmp     TfrBG3TilesVblank

; ------------------------------------------------------------------------------

; magic effect jump table (starts at $0e)
MagicEffectTbl:
@b760:  .addr   MagicEffect_0e
        .addr   MagicEffect_0f
        .addr   MagicEffect_10
        .addr   MagicEffect_11
        .addr   MagicEffect_12
        .addr   MagicEffect_13
        .addr   MagicEffect_14
        .addr   MagicEffect_15
        .addr   MagicEffect_16
        .addr   MagicEffect_17
        .addr   MagicEffect_18
        .addr   MagicEffect_19
        .addr   MagicEffect_1a
        .addr   MagicEffect_1b

; ------------------------------------------------------------------------------

; [ magic effect $0e: cure 1 ]

MagicEffect_0e:
@b77c:  lda     $0f97f5
        sta     $1b91
        bra     CureEffect

; ------------------------------------------------------------------------------

; [ magic effect $0f: cure 2 ]

MagicEffect_0f:
@b785:  lda     $0f97fb
        sta     $1b91
        bra     CureEffect

; ------------------------------------------------------------------------------

; [ magic effect $10: cure 3 ]

MagicEffect_10:
@b78e:  lda     $0f9801
        sta     $1b91
        bra     CureEffect

; ------------------------------------------------------------------------------

; [ magic effect $11: cure 4 ]

MagicEffect_11:
@b797:  lda     $1bbb
        beq     @b7a5
        lda     $0f9807
        sta     $1b91
        bra     CureEffect
@b7a5:  lda     #0
@b7a7:  jsr     _01b7b0
        inc
        cmp     #5
        bne     @b7a7
        rts

; ------------------------------------------------------------------------------

; [  ]

_01b7b0:
@b7b0:  pha
        jsr     Tax16
        lda     $1b8b,x
        beq     @b7cd
        lda     $43
        jsr     GetSelCharPtr
        lda     a:$0003,x
        bmi     @b7cd
        longa
        lda     a:$0009,x
        sta     a:$0007,x
        shorta
@b7cd:  pla
        rts

; ------------------------------------------------------------------------------

; [ do cure magic effect ]

CureEffect:
@b7cf:  lda     #0
        xba
        lda     $1b91
        longa
        asl2
        sta     $1b91
        shorta
        lda     $e8
        jsr     GetCharPtr
        lda     a:$0018,x
        lsr3
        inc
        sta     $54
        stz     $55
        lda     #0
        xba
        lda     a:$0018,x
        lsr
        longa
        clc
        adc     $1b91
        sta     $57
@b7fd:  clc
        adc     $57
        dec     $54
        bne     @b7fd
        sta     $57
        shorta
        shorti
        ldx     $41         ; zero
        txy
@b80d:  lda     $1b8b,x
        beq     @b813
        iny
@b813:  inx
        cpx     #$05
        bne     @b80d
        longi
        lda     $1bbb
        beq     @b827
        longa
        lda     $57
        lsr2
        bra     @b82b
@b827:  longa
        lda     $57
@b82b:  sta     $45
        shorta
        lda     #$00
@b831:  jsr     _01b83a
        inc
        cmp     #$05
        bne     @b831
        rts

; ------------------------------------------------------------------------------

; [  ]

_01b83a:
@b83a:  pha
        sta     $1bbc
        jsr     Tax16
        lda     $1b8b,x
        beq     @b871
        ldx     $43
        lda     f:CharOrderTbl,x   ; character battle order
        jsr     GetCharPtr
        lda     a:$0003,x
        and     #$c0
        bne     @b871
        lda     $1bbc
        jsr     GetSelCharPtr
        longa
        lda     a:$0007,x
        clc
        adc     $45
        cmp     a:$0009,x
        bcc     @b86c
        lda     a:$0009,x
@b86c:  sta     a:$0007,x
        shorta
@b871:  pla
        rts

; ------------------------------------------------------------------------------

; [ magic effect $12: esuna/heal ]

MagicEffect_12:
@b873:  lda     #$00
@b875:  jsr     _01b87e
        inc
        cmp     #$05
        bne     @b875
        rts

; ------------------------------------------------------------------------------

; [  ]

_01b87e:
@b87e:  pha
        jsr     Tax16
        lda     $1b8b,x
        beq     @b897
        jsr     _01b9a0
        longa
        lda     a:$0003,x
        and     #$7c80
        sta     a:$0003,x
        shorta
@b897:  pla
        rts

; ------------------------------------------------------------------------------

; [ magic effect $13: life ]

MagicEffect_13:
@b899:  lda     #$00
        sta     $1bbd
@b89e:  jsr     _01b8a8
        inc
        cmp     #$05
        bne     @b89e
        bra     _b8ea

; ------------------------------------------------------------------------------

; [  ]

_01b8a8:
@b8a8:  pha
        jsr     Tax16
        lda     $1b8b,x
        beq     @b8db
        jsr     _01b9a0
        lda     a:$0003,x
        bpl     @b8db
        and     #$7f
        sta     a:$0003,x
        lda     a:$0016,x
        sta     $43
        longa
        lda     $43
        asl2
        adc     $43
        cmp     a:$0009,x
        bcc     @b8d3
        lda     a:$0009,x
@b8d3:  sta     a:$0007,x
        shorta
        inc     $1bbd
@b8db:  pla
        rts

; ------------------------------------------------------------------------------

; [ magic effect $14: life 2 ]

MagicEffect_14:
@b8dd:  lda     #$00
        sta     $1bbd
@b8e2:  jsr     _01b907
        inc
        cmp     #$05
        bne     @b8e2
_b8ea:  lda     $1bbd
        bne     @b906
        lda     $e8
        jsr     GetCharPtr
        lda     $1b93
        sta     $43
        longa
        lda     a:$000b,x
        clc
        adc     $43
        sta     a:$000b,x
        shorta
@b906:  rts

; ------------------------------------------------------------------------------

; [  ]

_01b907:
@b907:  pha
        jsr     Tax16
        lda     $1b8b,x
        beq     @b932
        jsr     _01b9a0
        lda     a:$0003,x
        bpl     @b932
        lda     #$00
        sta     a:$0003,x
        lda     a:$0004,x
        and     #$7f
        sta     a:$0004,x
        longa
        lda     a:$0009,x
        sta     a:$0007,x
        shorta
        inc     $1bbd
@b932:  pla
        rts

; ------------------------------------------------------------------------------

; [ magic effect $15: mini ]

MagicEffect_15:
@b934:  lda     #$10
        ldy     #$0003
        bra     magic_status_effect

; ------------------------------------------------------------------------------

; [ magic effect $19: toad ]

MagicEffect_19:
@b93b:  lda     #$20
        ldy     #$0003
        bra     magic_status_effect

; ------------------------------------------------------------------------------

; [ magic effect $1a: pig ]

MagicEffect_1a:
@b942:  lda     #$08
        ldy     #$0003
        bra     magic_status_effect

magic_status_effect:
@b949:  sta     $48
        eor     #$ff
        sta     $49
        sty     $4b
        lda     #0
@b953:  jsr     _01b95c
        inc
        cmp     #5
        bne     @b953
        rts

; ------------------------------------------------------------------------------

; [  ]

_01b95c:
@b95c:  pha
        jsr     Tax16
        lda     $1b8b,x
        beq     @b97c
        jsr     _01b9a0
        stx     $4e
        stz     $50
        lda     ($4e),y
        pha
        and     $49
        sta     ($4e),y
        pla
        eor     #$ff
        and     $48
        ora     ($4e),y
        sta     ($4e),y
@b97c:  pla
        rts

; ------------------------------------------------------------------------------

; [  ]

_01b97e:
@b97e:  longa
        lda     #$0257
        ldx     #$0300
        ldy     #$a200
        mvn     #$7e,#$7e
        shorta
        rts

; ------------------------------------------------------------------------------

; [  ]

_01b98f:
@b98f:  longa
        lda     #$0257
        ldx     #$a200
        ldy     #$0300
        mvn     #$7e,#$7e
        shorta
        rts

; ------------------------------------------------------------------------------

; [ get pointer to selected character properties ]

GetSelCharPtr:
@b9a0:  sta     $43

_01b9a0:
@b9a2:  ldx     $43
        lda     f:CharOrderTbl,x   ; character battle order
        jmp     GetCharPtr

; ------------------------------------------------------------------------------

; [ magic effect $1b: warp ]

_b9ab:  jsr     HideMagicCursors
        jmp     ErrorSfx

MagicEffect_1b:
@b9b1:  lda     $1a04
        and     #$10
        beq     _b9ab
        lda     #$03
        bra     _b9d0

; ------------------------------------------------------------------------------

; [ magic effect $16: exit ]

MagicEffect_16:
@b9bc:  lda     $1a04
        and     #$20
        beq     _b9ab
        lda     #$04
        bra     _b9d0

; ------------------------------------------------------------------------------

; [ magic effect $17: sight ]

MagicEffect_17:
@b9c7:  lda     $1a04
        and     #$40
        beq     _b9ab
        lda     #$05
_b9d0:  sta     $1a03
        jsr     _01ba05
        longa
        sta     a:$000b,x
        shorta
        jsl     SaveMagicCursorPos
        ldx     $1a65
        txs
        rts

; ------------------------------------------------------------------------------

; [ magic effect $18: float ]

MagicEffect_18:
@b9e6:  lda     #$00
@b9e8:  pha
        jsr     Tax16
        lda     $1b8b,x
        beq     @b9fe
        pla
        pha
        jsr     GetSelCharPtr
        lda     a:$0004,x
        ora     #$40
        sta     a:$0004,x
@b9fe:  pla
        inc
        cmp     #$05
        bne     @b9e8
        rts

; ------------------------------------------------------------------------------

; [  ]

_01ba05:
@ba05:  lda     $e8
        jsr     GetCharPtr
        lda     $1b93
        sta     $43
        longa
        lda     a:$000b,x
        sec
        sbc     $43
        shorta
        rts

; ------------------------------------------------------------------------------
