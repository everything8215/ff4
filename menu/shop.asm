
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: shop.asm                                                             |
; |                                                                            |
; | description: shop menu                                                     |
; |                                                                            |
; | created: 4/8/2022                                                          |
; +----------------------------------------------------------------------------+

.pushseg

.segment "shop_prop"

; 13/a300
        .include .sprintf("data/shop_prop_%s.asm", LANG_SUFFIX)

.popseg

; ------------------------------------------------------------------------------

; [ shop menu ]

ShopMenu:
@c2bf:  phb
        phd
        ldx     #$0100
        phx
        pld
        lda     #$7e
        pha
        plb
        jsr     SaveDlgGfx_far
        jsr     InitMenu
        ldx     #$ed00                  ; items $00-$ed valid (all but key items)
        stx     $1b1d
        lda     #$20                    ; sprite layer priority: 2
        sta     $c1
        stz     $1b79
        stz     $1b7a
        jsr     UpdateScrollRegs_far
        lda     #$20
        sta     $3f
        stz     $1b94
        jsr     ClearAllBGTiles
        jsr     ResetSprites
        jsr     TfrAllBGTiles
        jsr     TfrSprites
        jsr     _01cb03
        lda     #$0a
        sta     $1b7c
        jsr     _01c35f
        jsr     FadeOut
        jsr     RestoreDlgGfx_far
        tdc
        xba
        pld
        plb
        rts

; ------------------------------------------------------------------------------

; [  ]

_01c30c:
@c30c:  jsr     SelectBG4
        ldx     #$48c0
        stx     $1a71
        jsr     TfrCharPal
        jsr     InitPartySprites
        ldy     #.loword(ShopGilWindow)
        jsr     DrawWindow
        jsr     _01c3ec
        ldy     #.loword(ShopChoiceWindow)
        jsr     DrawWindow
        ldy     #.loword(ShopTypeWindow)
        jsr     DrawWindow
        ldy     #.loword(ShopMsgWindow)
        jsr     DrawWindow
        lda     #0
        xba
        lda     $1a01
.if LANG_EN
        asl3
.else
        asl2
        adc     $1a01
.endif
        longa
        clc
        adc     #.loword(ShopTypeTextTbl)
        tay
        shorta
.if LANG_EN
        ldx     #$0044
.else
        ldx     #$0046
.endif
        jsr     DrawMenuText
        ldy     #.loword(ShopWelcomePosText)
        jmp     DrawPosText

; ------------------------------------------------------------------------------

; [  ]

_01c356:
@c356:  jsr     _01c30c
        ldy     #.loword(ShopCharWindow)
        jmp     DrawWindow

; ------------------------------------------------------------------------------

; [  ]

_01c35f:
@c35f:  jsr     LoadCharGfx
        jsr     _01c356
        jsr     TfrBG4TilesVblank
        jsr     FadeIn
        bra     @c37c
@c36d:  jsr     ClearAllBGTiles
        jsr     _01c356
        jsr     TfrBG3TilesVblank
        jsr     TfrBG1TilesVblank
        jsr     TfrBG4TilesVblank
@c37c:  lda     $1b79
        asl3
        sta     $45
        asl2
        adc     $45
.if LANG_EN
        adc     #$08
.else
        adc     #$10
.endif
        sta     $45
        lda     #$30
        sta     $46
        jsr     DrawCursor1
        jsr     UpdatePartySpritesShop
        jsr     TfrSpritesVblank
        jsr     TfrBG4Tiles
        jsr     TfrPal
        jsr     UpdateCtrlMenu
; right button
        lda     $01
        and     #JOY_RIGHT
        beq     @c3b5
        lda     $1b79
        inc
        cmp     #$03
        bne     @c3b2
        lda     #$00
@c3b2:  sta     $1b79
; left button
@c3b5:  lda     $01
        and     #JOY_LEFT
        beq     @c3c6
        lda     $1b79
        dec
        bpl     @c3c3
        lda     #$02
@c3c3:  sta     $1b79
; A button
@c3c6:  lda     $00
        and     #JOY_A
        beq     @c3e2
        lda     $1b79
        cmp     #$02
        bne     @c3d4
        rts
@c3d4:  pha
        pla
        ldx     #.loword(ShopJumpTbl)
        jsr     ExecJumpTbl
        jsr     HideCursor2
        jmp     @c36d
; B button
@c3e2:  lda     $01
        and     #JOY_B
        beq     @c3e9
        rts
@c3e9:  jmp     @c37c

; ------------------------------------------------------------------------------

; [  ]

_01c3ec:
@c3ec:  ldy     #.loword(GilPosText)
        jsr     DrawPosText

_01c3f2:
@c3f2:  jsr     SelectBG4
        ldy     #$01a6
        lda     $16a2
        ldx     $16a0
        jmp     DrawNum7

; ------------------------------------------------------------------------------

; buy/sell jump table
ShopJumpTbl:
@c401:  .addr   BuyMenu
        .addr   SellMenu

; ------------------------------------------------------------------------------

; [ buy menu ]

BuyMenu:
@c405:  lda     $34
        sta     $db
        lda     #0                      ; check if inventory is full
        jsr     FindItem
        cmp     #0
        beq     _c42a

ShopInventoryFull:
@c412:  jsr     UpdatePartySpritesShop
        jsr     HideCursor1
        jsr     TfrSpritesVblank
        jsr     SelectBG1
        ldy     #.loword(ShopInventoryFullPosText)
        jsr     DrawWindowText
        jsr     OpenWindow
        jmp     WaitKeypress

_c42a:  jsr     ResetSprites
        jsr     SelectBG4
        ldy     #.loword(ShopChoiceWindow)
        jsr     DrawWindow
        jsr     _01c3ec
        ldy     #.loword(ShopMsgWindow)
        jsr     DrawWindow
        ldy     #.loword(ShopWhichPosText)
        jsr     DrawPosText
        ldy     #.loword(ShopListWindow)
        jsr     DrawWindow
        jsr     LoadShopList
        tya
        sta     $1b7d
        jsr     TfrSpritesVblank
        jsr     OpenWindow
        stz     $1bcb
; start of frame loop
@c45b:  jsr     DrawQtyCursor
        jsr     UpdatePartySpritesShop
        lda     $1b7c
        ldy     #$019a
        jsr     DrawNum2
        jsr     TfrSpritesVblank
        jsr     TfrBG4Tiles
        jsr     UpdateCtrlMenu
        jsr     UpdateShopQty
        lda     $1bcb
        beq     @c481
        stz     $1bcb
        jsr     UpdateShopList
; A button
@c481:  lda     $00
        and     #JOY_A
        beq     @c490
        ldy     #$0310
        jsr     SelectItemBuy
        jmp     HideCursor2
; B button
@c490:  lda     $01
        and     #JOY_B
        beq     @c497
        rts
@c497:  jmp     @c45b

; ------------------------------------------------------------------------------

; [ update shop list ]

UpdateShopList:
@c49a:  jsr     LoadShopList
        jmp     TfrBG4TilesVblank

; ------------------------------------------------------------------------------

; [ load shop list ]

LoadShopList:
@c4a0:  ldx     $41         ; zero
        stx     $1a78
        stx     $1a7a
        stx     $1a7c
        stx     $1a7e
        jsr     SelectBG4
        ldx     #$1b55
        stx     $51
        lda     #$00
        xba
        lda     $1a00
        asl3
        longa
        adc     #.loword(ShopProp)
        sta     $5a
        shorta
        lda     #^ShopProp
        sta     $5c
        ldy     $41         ; zero
; start of item loop
@c4ce:  sty     $1a80
        lda     [$5a],y
        cmp     #$ff
        bne     @c4d8
        rts
@c4d8:  sta     $5d
        sta     ($51)
        jsr     IncShopPtr
        phy
        jsr     Tax16
        lda     f:ItemPrice,x   ; item prices
        bpl     @c533
; 1000x price multiplier
        and     #$7f
        sta     f:hWRMPYA
        lda     #$fa        ; multiply by 250
        sta     f:hWRMPYB
        longa
        tya
        asl
        tax
        lda     f:_01c59e,x
        tay
        shorta
        lda     f:hRDMPYL
        sta     $45
        lda     f:hRDMPYH
        sta     $46
        lda     #$00
        sta     $47         ; multiply by 4
        rol     $45
        rol     $46
        rol     $47
        rol     $45
        rol     $46
        rol     $47
        ldx     $45
        longa
        txa
        sta     ($51)
        inc     $51
        inc     $51
        shorta
        lda     $47
        sta     ($51)
        jsr     IncShopPtr
        bra     @c55b
; 10x price multiplier
@c533:  sta     f:hWRMPYA
        lda     #$0a        ; multiply by 10
        sta     f:hWRMPYB
        longa
        tya
        asl
        tax
        lda     f:_01c59e,x
        tay
        lda     f:hRDMPYL
        tax
        sta     ($51)
        inc     $51
        inc     $51
        shorta
        lda     #0
        sta     ($51)
        jsr     IncShopPtr
@c55b:  jsr     _01caaa
        longa
        tya
        sec
        sbc     #$0030
        tax
        shorta
        ldy     #.loword(GilPosText)+2
        jsr     DrawMenuText
        ply
        lda     $5d
        phy
        longa
        tya
        asl
        tax
        lda     f:_01c58e,x
        tay
        shorta
        lda     $5d
        jsr     DrawItemName
        ply
        iny
        cpy     #8
        beq     @c58d
        jmp     @c4ce
@c58d:  rts

; ------------------------------------------------------------------------------

_01c58e:
@c58e:  .word   $0246,$02c6,$0346,$03c6,$0446,$04c6,$0546,$05c6

_01c59e:
@c59e:  .word   $0296,$0316,$0396,$0416,$0496,$0516,$0596,$0616

; ------------------------------------------------------------------------------

; [ increment shop list pointer ]

IncShopPtr:
@c5ae:  longa
        inc     $51
        shorta
        rts

; ------------------------------------------------------------------------------

; [ select item to buy ]

; start of frame loop
SelectItemBuy:
@c5b5:  lda     $1b7b       ; cursor position
        asl4
        adc     #$50
        sta     $46
        lda     #$10
        sta     $45
        jsr     DrawCursor1
        jsr     _01c772
        jsr     UpdatePartySpritesShop
        jsr     TfrSpritesVblank
        jsr     UpdateCtrlMenu
; B button
        lda     $01
        and     #JOY_B
        beq     @c5da
        rts
; A button
@c5da:  lda     $00
        and     #JOY_A
        beq     @c5ef
        jsr     BuyItem
        jsr     ClearBG1Tiles
        jsr     TfrBG1TilesVblank
        jsr     _01c3f2
        jsr     TfrBG4TilesVblank
; up button
@c5ef:  lda     $01
        and     #JOY_UP
        beq     @c60a
@c5f5:  lda     $1b7b
        dec
        bpl     @c5ff
        lda     $1b7d
        dec
@c5ff:  sta     $1b7b
        jsr     Tax16
        lda     $1a78,x
        bne     @c5f5
; down button
@c60a:  lda     $01
        and     #JOY_DOWN
        beq     @c626
@c610:  lda     $1b7b
        inc
        cmp     $1b7d
        bcc     @c61b
        lda     #$00
@c61b:  sta     $1b7b
        jsr     Tax16
        lda     $1a78,x
        bne     @c610
; left or right button
@c626:  lda     $01
        and     #JOY_LEFT|JOY_RIGHT
        beq     @c63f
        lda     $1b7a
        eor     #$ff
        and     #$01
        sta     $1b7a
        jsr     DrawQtyCursor
        jsr     UpdateShopList
        jsr     TfrSprites
; X button
@c63f:  lda     $00
        and     #JOY_X
        beq     @c662
        lda     $1b7a
        beq     @c662
        lda     $1b7c
        clc
        adc     #10        ; increase by 10
        cmp     #100
        bcc     @c656
        lda     #10
@c656:  sta     $1b7c
        ldy     #$019a
        jsr     DrawNum2
        jsr     UpdateShopList
@c662:  jmp     SelectItemBuy

; ------------------------------------------------------------------------------

; [ buy item ]

BuyItem:
@c665:  lda     $1b7a
        beq     @c66e
        lda     $1b7c
        dec
@c66e:  inc
        sta     $45
        sta     $1b75
        lda     $1b7b
        asl
        asl
        jsr     Tax16
        lda     $1b56,x
        sta     $37
        lda     $1b57,x
        sta     $38
        lda     $1b58,x
        sta     $39
        stz     $3a
        stz     $3b
        stz     $3c
        stz     $3d
        stz     $3e
@c695:  longa
        lda     $37
        clc
        adc     $3b
        sta     $3b
        lda     $39
        adc     $3d
        sta     $3d
        shorta
        dec     $45
        bne     @c695
        ldx     $16a0
        stx     $37
        lda     $16a2
        sta     $39
        stz     $3a
        longa
        lda     $37
        sec
        sbc     $3b
        sta     $37
        lda     $39
        sbc     $3d
        sta     $39
        shorta
        lda     $3a
        bpl     @c71e
        ldx     #$50c0
        stx     $1a71
        jsr     InitPartySprites
        lda     #$09
        sta     $fe01
        sta     $fe05
        sta     $fe09
        sta     $fe0d
        sta     $fe11
        sta     $fe15
        sta     $fe19
        sta     $fe1d
        sta     $fe21
        sta     $fe25
        stz     $1a73
        jsr     UpdatePartySpritesShop
        jsr     TfrSpritesVblank
        jsr     SelectBG1
        ldy     #.loword(ShopNotEnoughGilPosText)
        jsr     DrawWindowText
        jsr     OpenWindow
        jsr     ErrorSfx
        jsr     WaitKeypress
        ldx     #$48c0
        stx     $1a71
        jsr     InitPartySprites
        jsr     ClearBG1Tiles
        jmp     TfrBG1TilesVblank
@c71e:  lda     #$00
        jsr     FindItem
        cmp     #$00
        beq     @c72a
        jmp     ShopInventoryFull
@c72a:  phx
        lda     $37
        sta     $16a0
        ldx     $38
        stx     $16a1
        plx
        lda     $1b7b
        asl
        asl
        sta     $43
        ldy     $43
        lda     $1b55,y
        sta     $1440,x
        lda     $1b75
        sta     $1441,x
        jsr     SelectBG1
        ldy     #.loword(ThankYouWindow)
        jsr     DrawWindowText
        jsr     UpdatePartySpritesShop
        jsr     TfrSpritesVblank
        lda     #$2b        ; cash register sound effect
        jsr     PlaySfx
        jsr     TfrBG1TilesVblank
        jsr     WaitKeypress
@c765:  jsr     TfrSpritesVblank
        jsr     UpdateCtrlMenu
        lda     $02
        ora     $03
        bne     @c765       ; wait for keypress
        rts

; ------------------------------------------------------------------------------

; [  ]

_01c772:
@c772:  stz     $fe15
        stz     $fe19
        stz     $fe1d
        stz     $fe21
        stz     $fe25
        lda     $1b7b
        asl
        asl
        jsr     Tax16
        lda     $1b55,x
        bne     @c78f
@c78e:  rts
@c78f:  cmp     #$ce
        bcs     @c78e
        sta     $1b39
        lda     #$00
@c798:  jsr     _01c7a1
        inc
        cmp     #$05
        bne     @c798
        rts

; ------------------------------------------------------------------------------

; [  ]

_01c7a1:
@c7a1:  pha
        sta     $57
        jsr     GetCharID
        beq     @c7bc
        stx     $e5
        jsr     CheckClassEquip
        bcc     @c7bc
        lda     $57
        asl
        asl
        jsr     Tax16
        lda     #$08
        sta     $fe15,x
@c7bc:  pla
        rts

; ------------------------------------------------------------------------------

; [ sell menu ]

SellMenu:
@c7be:  jsr     _01cb03
        ldx     #$ffb8
        stx     $9f
        jsr     ClearBG4Tiles
        jsr     _01c30c
        jsr     ResetSprites
        jsr     TfrBG4TilesVblank
        jsr     TfrSprites
        jsr     SelectBG1
        ldy     #.loword(ShopChoiceWindow)
        jsr     DrawWindow
        ldy     #.loword(SellMsgPosText)
        jsr     DrawPosText
        ldy     #.loword(ShopQtyPosText)
        jsr     DrawPosText
        jsr     SelectBG3
        jsr     UpdateScrollRegs_far
        jsr     DrawInventoryList
        jsr     TfrBG3TilesVblank
        jsr     SelectBG1
        jsr     TfrSpritesVblank
        jsr     TfrBG1Tiles
        jsr     OpenWindow
; start of frame loop
@c802:  lda     #$20
        sta     $3f
        lda     $1b7a
        beq     @c810
        ldx     #$3058
        bra     @c813
@c810:  ldx     #$3040
@c813:  ldy     #$0300
        lda     #$00
        jsr     DrawCursor
        lda     $1b7c
        ldy     #$019a
        jsr     DrawNum2
        jsr     TfrSpritesVblank
        jsr     TfrBG1Tiles
        jsr     UpdateCtrlMenu
        jsr     UpdateShopQty
; A button
        lda     $00
        and     #JOY_A
        beq     @c83f
        ldy     #$0310
        jsr     CopyCursorSprite
        jmp     SelectItemSell
; B button
@c83f:  lda     $01
        and     #JOY_B
        beq     @c846
        rts
@c846:  jmp     @c802

; ------------------------------------------------------------------------------

; [ select item to sell ]

SelectItemSell:
@c849:  lda     #$20
        sta     $3f
        lda     $1b94
        asl4
        adc     #$58
        sta     $46
        lda     $1b95
        beq     @c861
        lda     #$78
        bra     @c863
@c861:  lda     #$08
@c863:  sta     $45
        jsr     DrawCursor1
        jsr     TfrSpritesVblank
        jsr     UpdateCtrlMenu
; B button
@c86e:  lda     $01
        and     #JOY_B
        beq     @c876
        clc
        rts
; A button
@c876:  lda     $00
        and     #JOY_A
        beq     @c8a3
        jsr     ConfirmSell
        bcc     @c896
        jsr     ResetSprites
        jsr     SelectClearBG3
        jsr     DrawInventoryList
        jsr     TfrBG3TilesVblank
        jsr     _01c3f2
        jsr     TfrBG4TilesVblank
        jsr     TfrClearBG2Tiles
@c896:  lda     #$20
        sta     $3f
        jsr     SelectBG4
        ldy     #$031c
        jsr     HideCursor
; right button
@c8a3:  lda     $01
        and     #JOY_RIGHT
        beq     @c8b4
        lda     $1b95
        inc
        and     #$01
        sta     $1b95
        beq     @c900
; left button
@c8b4:  lda     $01
        and     #JOY_LEFT
        beq     @c8c5
        lda     $1b95
        inc
        and     #$01
        sta     $1b95
        bne     @c8cb
; up button
@c8c5:  lda     $01
        and     #JOY_UP
        beq     @c8fa
@c8cb:  lda     $1b94
        dec
        bmi     @c8d6
        sta     $1b94
        bra     @c8fa
@c8d6:  lda     $1b96
        dec
        bmi     @c8fa
        sta     $1b96
        lda     #$08
        sta     $45
@c8e3:  longa
        dec     $9f
        dec     $9f
        shorta
        jsr     UpdateScrollRegsVblank
        dec     $45
        bne     @c8e3
        jsr     UpdateCtrlAfterScroll
        bcs     @c8fa
        jmp     @c86e
; down button
@c8fa:  lda     $01
        and     #JOY_DOWN
        beq     @c933
@c900:  lda     $1b94
        inc
        cmp     #$08
        beq     @c90d
        sta     $1b94
        bra     @c933
@c90d:  lda     $1b96
        inc
        cmp     #$11
        beq     @c933
        sta     $1b96
        lda     #8                      ; scroll down for 8 frames
        sta     $45
@c91c:  longa
        inc     $9f
        inc     $9f
        shorta
        jsr     UpdateScrollRegsVblank
        dec     $45
        bne     @c91c
        jsr     UpdateCtrlAfterScroll
        bcs     @c933
        jmp     @c86e
@c933:  jmp     SelectItemSell

; ------------------------------------------------------------------------------

; [ confirm sell item ]

ConfirmSell:
@c936:  lda     #$30
        sta     $3f
        lda     $1b94
        clc
        adc     $1b96
        asl2
        adc     $1b95
        adc     $1b95
        jsr     Tax16
        stx     $1b98
        lda     $1440,x
        cmp     #$19
        beq     @c96e
        cmp     #$c8
        beq     @c96e
        cmp     #$ee
        bcs     @c96e
        phx
        jsr     SelectClearBG2
        ldy     #.loword(SellWindow)
        jsr     DrawWindowText
        plx
        lda     $1440,x
        bne     @c970
@c96e:  clc
        rts
@c970:  sta     $5d
        sta     $43
        lda     $1441,x
        sta     $5e
        ldx     $43
        lda     f:ItemPrice,x
        bmi     @c991
        sta     $43
        longa
        lda     $43
        asl2
        adc     $43
        sta     $5a
        shorta
        bra     @c9a8
@c991:  asl
        sta     f:hWRMPYA
        lda     #$fa
        sta     f:hWRMPYB
        phx
        plx
        longa
        lda     f:hRDMPYL
        sta     $5a
        shorta
@c9a8:  lda     $5d
        cmp     #$d4
        bcs     @c9b8
        cmp     #$d1
        bcc     @c9b8
        lda     #$01
        sta     $5a
        stz     $5b
@c9b8:  lda     $1b7a
        beq     @c9c1
        lda     $1b7c
        dec
@c9c1:  inc
        cmp     $5e
        bcc     @c9c8
        lda     $5e
@c9c8:  sta     $60
        sta     $1b97
        stz     $61
        stz     $37
        stz     $38
        stz     $39
        stz     $3a
.if LANG_EN
        ldy     #$039c
.else
        ldy     #$0396
.endif
        jsr     DrawNum2
        longa
        lda     #0
@c9e2:  clc
        adc     $5a
        bcc     @c9e9
        inc     $39
@c9e9:  dec     $60
        bne     @c9e2
        sta     $37
        lda     $39
        ldx     $37
.if LANG_EN
        ldy     #$0494
.else
        ldy     #$0414
.endif
        shorta
        jsr     DrawNum7
        stz     $db
        lda     $5d
        ldy     #$02d4
        jsr     DrawItemName
        lda     $1b95
        bne     @ca10
        ldy     #$031c
        jsr     CopyCursorSprite
@ca10:  stz     $48
        jsr     OpenWindow
        lda     #$30
        sta     $3f
.if LANG_EN
@ca19:  lda     #$a0
.else
@ca19:  lda     #$b0
.endif
        sta     $46
        lda     $48
        bne     @ca25
        lda     #$50
        bra     @ca27
.if LANG_EN
@ca25:  lda     #$78
.else
@ca25:  lda     #$70
.endif
@ca27:  sta     $45
        jsr     DrawCursor1
        jsr     TfrSpritesVblank
        jsr     UpdateCtrlMenu
; B button
        lda     $01
        and     #JOY_B
        beq     @ca3d
        jsr     TfrClearBG2Tiles
        clc
        rts
; A button
@ca3d:  lda     $00
        and     #JOY_A
        beq     @ca8c
        lda     $48
        beq     @ca4c
        jsr     TfrClearBG2Tiles
        clc
        rts
@ca4c:  longa
        lda     $16a0
        clc
        adc     $37
        sta     $16a0
        shorta
        lda     $16a2
        adc     $39
        sta     $16a2
        cmp     #$98
        bcc     @ca75
        ldx     #$967f
        cpx     $16a0
        bcs     @ca75
        stx     $16a0
        lda     #$98
        sta     $16a2
@ca75:  ldx     $1b98
        lda     $1441,x
        sec
        sbc     $1b97
        sta     $1441,x
        bne     @ca87
        sta     $1440,x
@ca87:  jsr     TfrClearBG2Tiles
        sec
        rts
; left or right button
@ca8c:  lda     $01
        and     #JOY_LEFT|JOY_RIGHT
        beq     @ca99
        lda     $48
        inc
        and     #$01
        sta     $48
@ca99:  jmp     @ca19

; ------------------------------------------------------------------------------

; [ copy cursor sprite data ]

CopyCursorSprite:
@ca9c:  longa
        lda     #$000f
        ldx     #$0300
        mvn     #$7e,#$7e
        shorta
        rts

; ------------------------------------------------------------------------------

; [  ]

_01caaa:
@caaa:  pha
        lda     $1b7a
        bne     @cab4
        pla
        jmp     DrawNum7
@cab4:  pla
        stz     $76
        sta     $75
        stz     $7a
        sta     $79
        stx     $73
        stx     $77
        lda     $1b7c
        dec
        sta     $63
        stz     $64
        longa
@cacb:  lda     $73
        clc
        adc     $77
        sta     $73
        lda     $75
        adc     $79
        sta     $75
        dec     $63
        bne     @cacb
        shorta
        lda     $75
        cmp     #^10000000
        bcs     @cae9
        ldx     $73
        jmp     DrawNum7
@cae9:  ldx     $75
        cpx     #.loword(10000000)
        bcs     @caf3
        jmp     DrawNum7
@caf3:  tyx
        ldy     #.loword(ExpendText)
        jsr     CopyText
        ldx     $1a80
        lda     #1
        sta     $1a78,x
        rts

; ------------------------------------------------------------------------------

; [  ]

_01cb03:
@cb03:  stz     $1b7b
        stz     $1b94
        stz     $1b96
        rts

; ------------------------------------------------------------------------------

; [ draw item quantity cursor ]

DrawQtyCursor:
@cb0d:  lda     $1b7a
        beq     @cb17
        ldx     #$3058
        bra     @cb1a
@cb17:  ldx     #$3040
@cb1a:  stx     $45
        jmp     DrawCursor2

; ------------------------------------------------------------------------------

; [ update shop item quantity ]

; X button
UpdateShopQty:
@cb1f:  lda     $00
        and     #$40
        beq     @cb3c
        lda     $1b7a
        beq     @cb3c
        lda     $1b7c
        clc
        adc     #$0a
        cmp     #$64
        bcc     @cb36
        lda     #$0a
@cb36:  sta     $1b7c
        inc     $1bcb
; up button
@cb3c:  lda     $01
        and     #JOY_UP
        beq     @cb57
        lda     $1b7a
        beq     @cb57
        lda     $1b7c
        inc
        cmp     #$64
        bcc     @cb51
        lda     #$02
@cb51:  sta     $1b7c
        inc     $1bcb
; down button
@cb57:  lda     $01
        and     #JOY_DOWN
        beq     @cb72
        lda     $1b7a
        beq     @cb72
        lda     $1b7c
        dec
        cmp     #$02
        bcs     @cb6c
        lda     #$63
@cb6c:  sta     $1b7c
        inc     $1bcb
; left or right button
@cb72:  lda     $01
        and     #JOY_LEFT|JOY_RIGHT
        beq     @cb85
        lda     $1b7a
        eor     #$ff
        and     #$01
        sta     $1b7a
        inc     $1bcb
@cb85:  rts

; ------------------------------------------------------------------------------
