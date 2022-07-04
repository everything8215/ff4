
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: item.asm                                                             |
; |                                                                            |
; | description: item menu routines                                            |
; |                                                                            |
; | created: 4/4/2022                                                          |
; +----------------------------------------------------------------------------+

.pushseg

.segment "item_desc"

; item description id for consumable items ($ce-$f8)
; 0f/ae00
        .include .sprintf("data/item_desc_id_%s.asm", LANG_SUFFIX)

; 0f/ae2b
        .include .sprintf("text/item_desc_%s.asm", LANG_SUFFIX)

.popseg

; ------------------------------------------------------------------------------

; [ item menu ]

ItemMenu:
@9f27:  stz     $1b1f
        jsr     SavePal1
        jsr     ResetBGScroll
        jsr     ClearBG2Tiles
        jsr     SelectBG4
        lda     #$1c
        sta     $c2
        lda     #$06
        sta     $ae
        jsr     ResetSprites
        jsr     TfrSpritesVblank
        lda     #$1b
        sta     f:hTM
        ldy     #.loword(MainOptionsWindow)
        ldx     #.loword(ItemLabelWindowRight)
        jsr     TransformWindow
        jsr     SelectBG2
        ldy     #.loword(ItemLabelWindowLeft)
        jsr     DrawWindowText
        lda     #$03
        jsr     ClearBGPal
        jsr     TfrBG2TilesVblank
        jsr     TfrPal
        ldx     $1ba5
        stx     $93
        jsr     UpdateScrollRegs_far
        inc     $1bc9
        ldx     #$ce|($ea<<8)           ; items $ce-$ea valid (consumables)
        stx     $1b1d
        jsr     SelectClearBG1
        jsr     DrawInventoryList
        jsr     UpdateScrollRegs_far
        jsr     OpenWindow
        jsr     SelectItem
        jsr     ResetSprites
        jsr     TfrSpritesVblank
        ldx     $93
        stx     $1ba5
        jsr     SelectClearBG1
        jsr     CloseWindow
        jsr     ClearBG2Tiles
        jsr     RestorePal1
        jsr     TfrBG2TilesVblank
        jsr     TfrPal
        jsr     SelectBG4
        lda     #$1c
        sta     $c2
        lda     #$86
        sta     $ae
        ldx     #.loword(MainOptionsWindow)
        ldy     #.loword(ItemLabelWindowRight)
        jsr     TransformWindow
        jsr     DrawMainMenu
        jsr     DrawAllPortraits
        jsr     TfrSpritesVblank
        lda     #$1f
        sta     f:hTM
        stz     $1bc9
        jmp     OpenWindow

; ------------------------------------------------------------------------------

; [ select item from inventory ]

SelectItem:
@9fcd:  jsr     DrawItemDesc
        ldx     #$6800
        stx     $1d
        ldx     #$a600
        stx     $1f
        lda     #$7e
        sta     $21
        ldx     #$0140
        stx     $22
        jsr     WaitVblank
        jsr     TfrVRAM
        jsr     TfrSprites
        jsr     TfrBG1Tiles
        jsr     UpdateCtrlMenu
; left button
@9ff2:  lda     $01
        and     #JOY_LEFT
        beq     @a003
        lda     $1b22                   ; toggle x position
        inc
        and     #$01
        sta     $1b22
        bne     @a01a                   ; move up
; right button
@a003:  lda     $01
        and     #JOY_RIGHT
        beq     @a014
        lda     $1b22                   ; toggle x position
        inc
        and     #$01
        sta     $1b22
        beq     @a06c                   ; move down
; up button
@a014:  lda     $01
        and     #JOY_UP
        beq     @a066
@a01a:  lda     $1b23
        bne     @a062                   ; branch if not at y = 0
        lda     $1b1a                   ; decrement scroll position
        beq     @a066
        dec
        sta     $1b1a
        longa
        ldy     #8                      ; scroll 2 pixels per frame, 8 frames
@a02d:  lda     $93
        sec
        sbc     #2
        sta     $93
        shorta
        lda     $1b19
        beq     @a042
        inc     $0311                   ; move cursor sprite
        inc     $0311
@a042:  phy
        jsr     DrawItemDesc
        jsr     TfrSpritesVblank
        jsr     TfrBG2Tiles
        jsr     UpdateScrollRegs_far
        ply
        longa
        dey
        bne     @a02d
        shorta
        jsr     DrawItemCursors
        jsr     UpdateCtrlAfterScroll
        bcs     @a066
        jmp     @9ff2
@a062:  dec
        sta     $1b23                   ; decrement y position
; down button
@a066:  lda     $01
        and     #JOY_DOWN
        beq     @a0bc
@a06c:  lda     $1b23
        cmp     #$09
        bcc     @a0b8
        lda     $1b1a
        cmp     #$0e
        beq     @a0bc
        inc
        sta     $1b1a
        longa
        ldy     #8
@a083:  lda     $93
        clc
        adc     #2
        sta     $93
        shorta
        lda     $1b19
        beq     @a098
        dec     $0311
        dec     $0311
@a098:  phy
        jsr     DrawItemDesc
        jsr     TfrSpritesVblank
        jsr     TfrBG2Tiles
        jsr     UpdateScrollRegs_far
        ply
        longa
        dey
        bne     @a083
        shorta
        jsr     DrawItemCursors
        jsr     UpdateCtrlAfterScroll
        bcs     @a0bc
        jmp     @9ff2
@a0b8:  inc
        sta     $1b23
; A button
@a0bc:  lda     $00
        and     #JOY_A
        beq     @a0e3
        lda     $1b19
        bne     @a0cc                       ; branch if second item
        jsr     SelectItem1
        bra     @a0ff
@a0cc:  jsr     SelectItem2
        jsr     SelectBG1
        jsr     DrawInventoryList
        stz     $1b19
        jsr     HideItemCursor2
        jsr     TfrBG1TilesVblank
        jsr     TfrSprites
        bra     @a0ff
; B button
@a0e3:  lda     $01
        and     #JOY_B
        beq     @a0ff
        lda     $1b19
        beq     @a0f6
        stz     $1b19
        jsr     HideItemCursor2
        bra     @a0ff
@a0f6:  jsr     HideItemCursor2
        jsr     LoadPortraits
        stz     $86
        rts
@a0ff:  jsr     DrawItemCursors
        jmp     @9fcd

; ------------------------------------------------------------------------------

; [ draw item cursors ]

DrawItemCursors:
@a105:  phy
        lda     #$20
        sta     $3f
        lda     $1b23                       ; cursor 1 y position
        asl4
        adc     #$36
        xba
        lda     $1b22                       ; cursor 1 x position
        beq     @a11b
        lda     #$6c
@a11b:  clc
        adc     #$04
        tax
        ldy     #$0300
        jsr     DrawCursor
        lda     $1b19
        beq     @a15a
        lda     $1b25
        sec
        sbc     $1b1a
        cmp     #$fc
        bcs     @a13d
        cmp     #$00
        bmi     @a157
        cmp     #$0b
        bcs     @a157
@a13d:  asl4
        adc     #$36
        xba
        lda     $1b24
        beq     @a14b
        lda     #$70
@a14b:  clc
        adc     #$08
        tax
        ldy     #$0310
        jsr     DrawCursor
        bra     @a15a
@a157:  jsr     HideCursor2
@a15a:  ply
        rts

; ------------------------------------------------------------------------------

; [ draw inventory or fat chocobo item list ]

DrawTreasureList:
@a15c:  ldx     #$ff28
        stx     $5a
        lda     #8                      ; 8 items
        sta     $e1
        bra     _a181

DrawFatChocoList:
@a167:  ldx     #$1340
        stx     $5a
        lda     #$7e                    ; 126 items
        sta     $e1
        bra     _a181

DrawInventoryList:
@a172:  ldy     #.loword(InventoryWindow)
        jsr     DrawWindow
        ldx     #$1440
        stx     $5a
        lda     #$30                    ; 48 items
        sta     $e1
_a181:  stz     $5d
        stz     $5e
@a185:  lda     ($5a)
        beq     @a1cd
        cmp     #$ff                    ; trash can
        bne     @a192
        jsr     DrawTrash
        bra     @a1cd
@a192:  ldy     #$0001
        lda     ($5a),y                 ; quantity
        beq     @a1cd
        sta     $5c
        lda     #0
        xba
        lda     ($5a)
        cmp     #$ed                    ; key items
        beq     @a1a8
        cmp     #$fe
        bne     @a1b3
@a1a8:  lda     $1bc9
        beq     @a1b3
        lda     $34
        sta     $db
        bra     @a1b8
@a1b3:  lda     ($5a)
        jsr     CheckCanUseItem
@a1b8:  longa
        lda     $5d
        lsr
        asl7
        adc     #4
        tay
        shorta
        jsr     DrawItemSlot
@a1cd:  longa
        inc     $5a                     ; increment item list pointer
        inc     $5a
        shorta
        inc     $5d                     ; next item
        lda     $5d
        cmp     $e1
        bne     @a185
        rts

; ------------------------------------------------------------------------------

; [ draw item slot ]

DrawItemSlot:
@a1de:  lda     $1bcc
        bne     @a1ed
        longa
        tya
        clc
        adc     #$0040
        tay
        shorta
@a1ed:  lda     $5d
        and     #$01
        bne     @a223
        lda     ($5a)
        jsr     DrawItemName
        longa
        tya
        clc
        adc     #$0052
        tay
        shorta
        lda     ($5a)
        cmp     #$fe
        beq     @a222
        lda     #$c8
        sta     ($29),y
        iny
        lda     $db
        sta     ($29),y
        iny
        phy
        lda     $5c
        jsr     DrawNum2
        ply
        iny
        lda     $db
        sta     ($29),y
        iny2
        sta     ($29),y
@a222:  rts
@a223:  longa
        tya
        clc
        adc     #$001c
        tay
        shorta
        lda     ($5a)
        jsr     DrawItemName
        longa
        tya
        clc
        adc     #$0052
        tay
        shorta
        lda     ($5a)
        cmp     #$fe
        beq     @a25c
        lda     #$c8
        sta     ($29),y
        iny
        lda     $db
        sta     ($29),y
        iny
        lda     $5c
        phy
        jsr     DrawNum2
        ply
        iny
        lda     $db
        sta     ($29),y
        iny
        iny
        sta     ($29),y
@a25c:  rts

; ------------------------------------------------------------------------------

; [ check if item can be used ]

CheckCanUseItem:
@a25d:  pha
        pha
        lda     $1b1f
        beq     @a26c                   ; branch if inventory (not equip menu)
        pla
        jsr     CheckItemEquip
        bcc     @a29e
        bra     @a298
@a26c:  pla
        cmp     #$e2
        beq     @a275
        cmp     #$e3
        bne     @a284
; tent/cottage
@a275:  pha
        lda     $1bc9
        beq     @a283
        pla
        lda     $1a02
        beq     @a2aa       ; branch if tent is disabled
        bra     @a298
@a283:  pla
@a284:  cmp     #$19        ; legend sword
        beq     @a29e
        cmp     #$c8        ; crystal
        beq     @a29e
        cmp     $1b1d
        bcc     @a29e       ; branch if not valid
        cmp     $1b1e
        beq     @a298
        bcs     @a29e
; can use
@a298:  lda     $34
        sta     $db
        pla
        rts
@a29e:  cmp     #$19        ; legend sword
        beq     @a2b2
        cmp     #$c8        ; crystal
        beq     @a2b2
        cmp     #$ec
        bcs     @a2b2       ; branch if an event item
; can't use
@a2aa:  lda     #$04
        ora     $34
        sta     $db
        pla
        rts
@a2b2:  cmp     #$fe
        beq     @a2aa
        lda     $1bc6
        beq     @a2aa
        lda     #$08
        ora     $34
        sta     $db
        pla
        rts

; ------------------------------------------------------------------------------

; [ select 1st item ]

SelectItem1:
@a2c3:  lda     $1b1a
        clc
        adc     $1b23
        sta     $1b25
        lda     $1b22
        sta     $1b24
        lda     #1
        sta     $1b19
        rts

; ------------------------------------------------------------------------------

; [ hide 2nd item cursor ]

HideItemCursor2:
@a2d9:  stz     $1b19

HideCursor2:
@a2dc:  ldy     #$0310

HideCursor:
@a2df:  ldx     #$0004                  ; hide 4 sprites
@a2e2:  lda     #$ff
        sta     a:$0000,y
        iny
        lda     #$f0
        sta     a:$0000,y
        iny
        dex
        bne     @a2e2
        rts

HideCursor1:
@a2f2:  ldy     #$0300
        bra     HideCursor

; ------------------------------------------------------------------------------

; [ select 2nd item (use or swap items) ]

; subroutine starts at c1/a309

_a2f7:  jsr     SelectBG2
        ldy     #.loword(ItemDescWindow)
        jsr     DrawWindow
        ldy     #.loword(NothingHerePosText)
        jsr     DrawPosText
        jmp     _a375

SelectItem2:
@a309:  lda     $1b23
        clc
        adc     $1b1a
        cmp     $1b25
        bne     _a38e                   ; branch if items don't match
        lda     $1b22
        cmp     $1b24
        bne     _a38e                   ; branch if items don't match
        lda     $1b25
        asl
        adc     $1b24
        asl
        sta     $45
        stz     $46
        ldx     $45
        lda     $1441,x
        beq     _a2f7                   ; branch if inventory slot is empty
        lda     $1440,x
        cmp     #$fe
        bne     @a33a
        jmp     SortInventory
@a33a:  jsr     CheckCanUseItem
        lda     $60
        and     #$08
        bne     @a366
        lda     $1440,x
        sta     $1b3b
        stx     $1b3c
; whistle
        cmp     #$ed
        bne     @a35b
        dec     $1441,x
        bne     @a358
        stz     $1440,x
@a358:  jmp     FatChocoWhistle
@a35b:  cmp     #$ce
        bcc     @a366
        cmp     #$eb
        bcs     @a366
        jmp     UseItem
; not consumable
@a366:  jsr     SelectBG2
        ldy     #.loword(ItemDescWindow)
        jsr     DrawWindow
        ldy     #.loword(CantUseHerePosText)
        jsr     DrawPosText
; reset item selection
_a375:  jsr     TfrBG2TilesVblank
        jsr     WaitKeypress
        jsr     HideItemCursor2
        jsr     SelectBG2
        ldy     #.loword(ItemLabelWindowRight)
        jsr     DrawWindow
        ldy     #.loword(ItemLabelPosText)
        jsr     DrawPosText
        rts
; swap items
_a38e:  jsr     HideItemCursor2
        lda     $1b23
        clc
        adc     $1b1a
        asl
        adc     $1b22
        asl
        sta     $45
        stz     $46
        ldy     $45
        lda     $1b25
        asl
        adc     $1b24
        asl
        sta     $45
        ldx     $45
        lda     $1440,y
        cmp     #$ff
        bne     @a3da
        lda     $1440,x
        beq     @a3da
        cmp     #$ed
        beq     @a3d0
        cmp     #$19
        beq     @a3cb
        cmp     #$c8
        beq     @a3cb
        cmp     #$ec
        bcc     @a3d0
@a3cb:  jsr     ErrorSfx
        bra     @a3fe
@a3d0:  lda     #0
        sta     $1440,x
        sta     $1441,x
        bra     @a3fe
@a3da:  lda     $1440,x
        cmp     $1440,y
        beq     @a40b
@a3e2:  lda     $1440,x
        pha
        lda     $1441,x
        pha
        lda     $1440,y
        sta     $1440,x
        lda     $1441,y
        sta     $1441,x
        pla
        sta     $1441,y
        pla
        sta     $1440,y
@a3fe:  jsr     SelectBG1
        jsr     DrawInventoryList
        jsr     HideItemCursor2
        jsr     SelectBG2
        rts
@a40b:  lda     $1441,y
        clc
        adc     $1441,x
        cmp     #100
        bcs     @a3e2
        sta     $1441,y
        lda     #0
        sta     $1440,x
        sta     $1441,x
        bra     @a3fe

; ------------------------------------------------------------------------------

; [ draw character select window ]

DrawItemCharSelect:
@a423:  lda     #$30
        sta     $3f
        jsr     SavePal2
        jsr     WaitVblank
        jsr     TfrPal
        jsr     SelectBG2
        ldy     #.loword(ItemDescWindow)
        jsr     DrawWindow
        ldy     #.loword(ItemWhomPosText)
        jsr     DrawPosText
        lda     $1b22
        beq     @a44b
        lda     #5                      ; char blocks on left side
        ldy     #.loword(ItemCharSelectWindowLeft)
        bra     @a450
@a44b:  lda     #0                      ; char blocks on right side
        ldy     #.loword(ItemCharSelectWindowRight)
@a450:  sta     $1bc1
        jsr     DrawWindow
        stz     $1bc3
@a459:  lda     $1bc3
        jsr     GetCharPtr
        txy
        lda     $1bc1
        asl
        jsr     Tax16
        longa
        lda     f:ItemCharBlockTbl,x
        tax
        shorta
        jsr     DrawItemCharBlock
        inc     $1bc1
        inc     $1bc3
        lda     $1bc3
        cmp     #$05
        bne     @a459
        rts

; ------------------------------------------------------------------------------

; [ get character target for item ]

GetItemTarget:
@a481:  jsr     DrawItemCharSelect
        jsr     OpenWindow
        lda     #$30
        sta     $3f
        jsr     SelectItemTarget
        lda     #$20
        sta     $3f
        jsr     HideItemCursor2
        jsr     RestorePal2
        jsr     TfrBG2TilesVblank
        jmp     TfrPal

; ------------------------------------------------------------------------------

; [ draw character block (use item) ]

; starts at 01/a49f

_a49e:  rts

DrawItemCharBlock:
@a49f:  lda     a:$0000,y
        and     #$3f
        beq     _a49e                   ; return if character slot empty
        sty     $48
        stx     $4b
        phy
        txy
        phx
        jsr     DrawCharName
        plx
        ply
        pha
        lda     a:$0003,y               ; use gray palette if dead
        rol4
        and     #$04
        ora     $34
        sta     $45
        lda     #$0e
        jsr     SetTextColor
        jsr     SetTextColor
        jsr     SetTextColor
        jsr     SetTextColor
        pla
        longa
        lda     $4b
        clc
        adc     $29
        sta     $4e
        clc
        adc     #$0040
        sta     $51
        shorta
        ldx     $48
        ldy     $4b
        phx
        phy
        jsr     DrawStatusIcons
        ply
        plx
        stx     $48
        sty     $4b
        longa
        lda     $51
        clc
        adc     #$0042
        tay
        shorta
        lda     #$49                ; "H"
        sta     a:$0000,y
        lda     #$51                ; "P"
        sta     a:$0002,y
        sta     a:$0042,y
        lda     #$4e                ; "M"
        sta     a:$0040,y
        lda     #$c7                ; "/"
        sta     a:$000e,y
        sta     a:$004e,y
        longa
        ldx     $51
        inx
        inx
        lda     #$0046
        ldy     #$0007
        jsr     DrawHPMP
        lda     #$0050
        ldy     #$0009
        jsr     DrawHPMP
        lda     #$0086
        ldy     #$000b
        jsr     DrawHPMP
        lda     #$0090
        ldy     #$000d
        jsr     DrawHPMP
        shorta
        rts

; ------------------------------------------------------------------------------

; [ select character (use item) ]

SelectItemTarget:
@a541:  jsr     GetSelCharID
        bne     @a555
        lda     $1b3e
        inc
        cmp     #5
        bne     @a550
        lda     #0
@a550:  sta     $1b3e
        bra     @a541
@a555:  lda     $1b22
        bne     @a55e
        lda     #$70
        bra     @a560
@a55e:  lda     #$08
@a560:  sta     $5d
; start of frame loop
@a562:  jsr     TfrSpritesVblank
        jsr     UpdateCtrlMenu
; up button
        lda     $01
        and     #JOY_UP
        beq     @a57e
@a56e:  lda     $1b3e
        dec
        bpl     @a576
        lda     #4
@a576:  sta     $1b3e
        jsr     GetSelCharID
        beq     @a56e
; down button
@a57e:  lda     $01
        and     #JOY_DOWN
        beq     @a596
@a584:  lda     $1b3e
        inc
        cmp     #5
        bcc     @a58e
        lda     #0
@a58e:  sta     $1b3e
        jsr     GetSelCharID
        beq     @a584
; A button
@a596:  lda     $00
        and     #JOY_A
        beq     @a5a9
        lda     $1b3e
        jsr     Tax16
        lda     f:CharOrderTbl,x      ; character battle order
        sta     $e8
        rts
; B button
@a5a9:  lda     $01
        and     #JOY_B
        beq     @a5b4
        lda     #$ff
        sta     $e8
        rts
@a5b4:  lda     $1b3e
        asl5
        adc     #$40
        sta     $5e
        lda     #$00
        ldx     $5d
        ldy     #$0300
        jsr     DrawCursor
        jmp     @a562

; ------------------------------------------------------------------------------

; [ calculate potion/ether effect ]

CalcPotionEffect:
@a5cd:  ldy     #$0003
        lda     ($60),y
        and     #$c0
        beq     _a611       ; branch if not dead or stone
        ldy     #.loword(ItemDoesntWorkPosText)
; fallthrough

; ------------------------------------------------------------------------------

; [ show item message ]

ShowItemMessage:
@a5d9:  inc     $1a82
        phy
        jsr     SelectBG2
        ldy     #.loword(ItemMsgWindow)
        jsr     DrawWindow
        ply
        jsr     DrawPosText
        jsr     TfrBG2TilesVblank
_a5ed:  ldx     $1b3c
        lda     $1b3b
        sta     $1440,x
        inc     $1441,x
        plx
        lda     $e8
        cmp     #$03
        bne     @a60b
        lda     $1b22
        bne     @a60b
        jsr     HideCursor1
        jsr     TfrSpritesVblank
@a60b:  jsr     ErrorSfx
        jmp     WaitKeypress

; ------------------------------------------------------------------------------

; [ calculate potion/ether effect (cont'd) ]

_a611:  tdc
        xba
        lda     $1b3b
        sec
        sbc     #$b0
        longa
        asl
        sta     $45         ; multiply by 6
        asl
        adc     $45
        tax
        shorta
        tdc
        xba
        lda     $0f9681,x   ; item properties, byte 1 (power)
        longa
        asl4
        sta     $1a84
        asl
        adc     $1a84       ; power * 48
        sta     $45
        shorta
        jmp     CureSfx

; ------------------------------------------------------------------------------

; [ item effect $ce/$cf/$d0: potion/cure ]

ItemEffect_ce:
ItemEffect_cf:
ItemEffect_d0:
@a63e:  jsr     CalcPotionEffect
        ldy     #$0007
_a644:  longa
        lda     ($60),y     ; add to current hp
        clc
        adc     $45
        iny
        iny
        cmp     ($60),y
        bcc     @a653
        lda     ($60),y     ; set hp to max
@a653:  dey
        dey
        sta     ($60),y
        shorta
        rts

; ------------------------------------------------------------------------------

; [ item effect $d1/$d2: ether ]

ItemEffect_d1:
ItemEffect_d2:
@a65a:  jsr     CalcPotionEffect
        ldy     #$000b      ; current mp
        bra     _a644

; ------------------------------------------------------------------------------

; [ item effect $d3: elixir ]

ItemEffect_d3:
@a662:  jsr     CalcPotionEffect
        longa
        ldy     #$0009
        lda     ($60),y     ; set hp to max
        dey
        dey
        sta     ($60),y
        ldy     #$000d
        lda     ($60),y     ; set mp to max
        dey
        dey
        sta     ($60),y
        shorta
        rts

; ------------------------------------------------------------------------------

; item effect jump table ($ce-$ea)
ItemEffect_tbl:
@a67c:  .addr   ItemEffect_ce
        .addr   ItemEffect_cf
        .addr   ItemEffect_d0
        .addr   ItemEffect_d1
        .addr   ItemEffect_d2
        .addr   ItemEffect_d3
        .addr   ItemEffect_d4
        .addr   ItemEffect_d5
        .addr   ItemEffect_d6
        .addr   ItemEffect_d7
        .addr   ItemEffect_d8
        .addr   ItemEffect_d9
        .addr   ItemEffect_da
        .addr   ItemEffect_db
        .addr   ItemEffect_dc
        .addr   ItemEffect_dd
        .addr   ItemEffect_de
        .addr   ItemEffect_df
        .addr   ItemEffect_e0
        .addr   ItemEffect_e1
        .addr   ItemEffect_e2
        .addr   ItemEffect_e3
        .addr   ItemEffect_e4
        .addr   ItemEffect_e5
        .addr   ItemEffect_e6
        .addr   ItemEffect_e7
        .addr   ItemEffect_e8
        .addr   ItemEffect_e9
        .addr   ItemEffect_ea

; ------------------------------------------------------------------------------

; [ item effect $d4: phoenix tail ]

ItemEffect_d4:
@a6b6:  ldy     #$0003
        lda     ($60),y
        and     #$80
        bne     @a6c5       ; branch if dead
        ldy     #.loword(ItemUnnecessaryPosText)
        jsr     ShowItemMessage
@a6c5:  ldy     #$0016
        lda     ($60),y     ; mod. vitality * 5
        sta     $43
        longa
        lda     $43
        asl2
        adc     $43
        ldy     #$0007
        cmp     ($60),y
        bcc     @a6dd
        sta     ($60),y     ; set hp
@a6dd:  shorta
        ldy     #$0003
        lda     ($60),y     ; clear dead status
        and     #$7f
        sta     ($60),y
        jmp     CureSfx

; ------------------------------------------------------------------------------

; [ item effect $dd: panacea ]

ItemEffect_dd:
@a6eb:  ldy     #$0003
        lda     ($60),y
        bpl     @a6f8       ; branch if not dead
        ldy     #.loword(ItemDoesntWorkPosText)
        jsr     ShowItemMessage
@a6f8:  lda     #$00
        sta     ($60),y
        iny
        lda     ($60),y
        and     #$7f
        sta     ($60),y
        jmp     CureSfx

; ------------------------------------------------------------------------------

; [ use consumable item ($ce-$ea) ]

UseItem:
@a706:  cmp     #$de        ; alarm
        beq     @a71a
        cmp     #$e2
        bcs     @a71a
        jsr     GetItemTarget
        lda     $e8
        bmi     @a74a
        jsr     GetCharPtr
        stx     $60
@a71a:  ldx     $1b3c
        dec     $1441,x     ; decrement quantity
        bne     @a725
        stz     $1440,x
@a725:  lda     $1b3b
        sec
        sbc     #$ce
        ldx     #.loword(ItemEffect_tbl)
        jsr     ExecJumpTbl
        lda     $1b3b
        cmp     #$de
        beq     @a74a
        cmp     #$e2
        bcs     @a74a
        lda     $1a82
        bne     @a74a
        jsr     DrawItemCharSelect
        jsr     TfrBG2TilesVblank
        jsr     WaitKeypress
@a74a:  stz     $1a82
        jsr     SelectClearBG2
        ldy     #.loword(ItemLabelWindowLeft)
        jsr     DrawWindowText
        jmp     TfrBG2TilesVblank

; ------------------------------------------------------------------------------

; [ item effect $df: golden apple ]

ItemEffect_df:
@a759:  longa
        ldy     #$0009
        lda     ($60),y
        clc
        adc     #100         ; add 100 to max hp
_a764:  cmp     #9999
        bcc     @a76c
        lda     #9999       ; max 9999
@a76c:  sta     ($60),y
        shorta
        jmp     CureSfx

; ------------------------------------------------------------------------------

; [ item effect $e0: silver apple ]

ItemEffect_e0:
@a773:  longa
        ldy     #$0009
        lda     ($60),y
        clc
        adc     #50      ; add 50 to max hp
        bra     _a764

; ------------------------------------------------------------------------------

; [ item effect $e1: soma drop ]

ItemEffect_e1:
@a780:  longa
        ldy     #$000d
        lda     ($60),y
        clc
        adc     #10        ; add 10 to max mp
        cmp     #999
        bcc     @a793
        lda     #999       ; max 999
@a793:  sta     ($60),y
        shorta
        jmp     CureSfx

; ------------------------------------------------------------------------------

; [ item effect $d5-$dc: status restoring items ]

ItemEffect_d5:
ItemEffect_d6:
ItemEffect_d7:
ItemEffect_d8:
ItemEffect_d9:
ItemEffect_da:
ItemEffect_db:
ItemEffect_dc:
@a79a:  lda     $1b3b
        sec
        sbc     #$d5
        asl
        sta     $43
        ldx     $43
        ldy     #$0003
        longa
        lda     ($60),y
        sta     $45
        and     f:ItemStatusMaskTbl,x   ; status mask for items $d5-$dd
        sta     ($60),y
        cmp     $45
        beq     @a7bd
        shorta
        jmp     CureSfx
@a7bd:  shorta
        ldy     #.loword(ItemUnnecessaryPosText)
        jsr     ShowItemMessage
; fallthrough

; ------------------------------------------------------------------------------

; [ draw item description ]

DrawItemDesc:
@a7c5:  jsr     SelectBG2
        lda     $1b23
        clc
        adc     $1b1a
        asl
        adc     $1b22
        asl
        jsr     Tax16
        lda     $1440,x
        pha
        ldy     #.loword(ItemDescWindow)
        jsr     DrawWindow
        pla
        cmp     #$ce
        bcc     @a811
        cmp     #$e7
        bcs     @a811
        sec
        sbc     #$ce
        jsr     Tax16
        lda     f:ItemDescID,x
        sta     $45
        ldx     #.loword(ItemDesc)-1
@a7f9:  beq     @a807
        inx
        lda     f:.bankbyte(ItemDesc)<<16,x
        bne     @a7f9
        dec     $45
        bne     @a7f9
        inx
@a807:  txy
        lda     #$0f
        ldx     #$0054
        jsr     DrawText
        rts
@a811:  jsr     ClearBG2Tiles
        ldy     #.loword(ItemLabelWindowLeft)
        jmp     DrawWindowText

; ------------------------------------------------------------------------------

; [ draw trash can ]

DrawTrash:
@a81a:  longa
        lda     $5d
        lsr
        asl7
        sta     $45
        lda     $5d
        and     #$0001
        beq     @a832
        lda     #$0020
@a832:  adc     $45
        clc
        adc     $29
        adc     #$004a
        tay
        shorta
        lda     #$04
        sta     a:$0000,y
        inc
        sta     a:$0002,y
        inc
        sta     a:$0040,y
        inc
        sta     a:$0042,y
        rts

; ------------------------------------------------------------------------------

; [ item effect: can't use item ]

ItemUnusable:
@a84f:  stz     $1a03
        jmp     _a5ed

; ------------------------------------------------------------------------------

; [ item effect $e2/$e3: tent/cottage ]

ItemEffect_e2:
ItemEffect_e3:
@a855:  lda     $1a02
        bne     _a878
        jmp     _a5ed

; ------------------------------------------------------------------------------

; [ item effect $e4: naughty book ]

ItemEffect_e4:
@a85d:  lda     $1a04
        and     #$80
        beq     ItemUnusable
        lda     #$07
        bra     _a87e

; ------------------------------------------------------------------------------

; [ item effect $e5: emergency exit ]

ItemEffect_e5:
@a868:  lda     $1a04
        and     #$20
        beq     ItemUnusable
        bra     _a878

; ------------------------------------------------------------------------------

; [ item effect $e6: dwarven bread ]

ItemEffect_e6:
@a871:  lda     $1a04
        and     #$40
        beq     ItemUnusable
_a878:  lda     $1b3b
        sec
        sbc     #$e1
_a87e:  sta     $1a03
        stz     $1b19
        ldx     $93
        stx     $1ba5
        ldx     $1a65
        txs
        rts

; ------------------------------------------------------------------------------

; [ item effect $de: alarm ]

ItemEffect_de:
@a88e:  lda     #$3c
        jsr     PlaySfx
        lda     #$06
        bra     _a87e

; ------------------------------------------------------------------------------

; [ item effect $e7-$ea: summon items ]

ItemEffect_e7:
ItemEffect_e8:
ItemEffect_e9:
ItemEffect_ea:
@a897:  stz     $45
@a899:  lda     $45
        jsr     GetCharID
        cmp     #$03
        beq     @a8b3       ; branch if rydia (girl)
        cmp     #$11
        beq     @a8b3       ; branch if rydia (adult)
        inc     $45         ; check next character slot
        lda     $45
        cmp     #$05
        bne     @a899
@a8ae:  longi
        jmp     _a5ed
@a8b3:  sta     $ed
        lda     $1b3b
        sec
        sbc     #$b6        ; get spell id from summon item id
        sta     $45
        shorti
        ldy     $41         ; zero
@a8c1:  lda     $15c0,y
        cmp     $45
        beq     @a8ae       ; branch if spell is already known
        iny
        cpy     #$18
        bne     @a8c1
        ldy     $41         ; zero
@a8cf:  lda     $15c0,y
        beq     @a8d9       ; find an empty slot in the spell list
        iny
        cpy     #$18
        bne     @a8cf
@a8d9:  lda     $45
        sta     $15c0,y
        pha
        longi
        jsr     SelectBG2
        ldy     #.loword(SummonMsgWindow)
        jsr     DrawWindowText
        ldy     #bg_pos 13,10
        lda     $ed
        jsr     DrawCharName
        inc     $1bc8
        pla
.if LANG_EN
        ldx     #bg_pos 13,14
.else
        ldx     #bg_pos 13,12
.endif
        jsr     DrawMagicName
        stz     $1bc8
        jsr     OpenWindow
        jsl     PlayFanfare
        jsr     ClearBG2Tiles
        jsr     TfrBG2TilesVblank
        longi
        rts

; ------------------------------------------------------------------------------

; [ get selected character id ]

GetSelCharID:
@a90f:  lda     $1b3e                       ; selected character
; fallthrough

; ------------------------------------------------------------------------------

; [ get character id (battle order) ]

GetSlotCharID:
@a912:  jsr     Tax16
        lda     f:CharOrderTbl,x   ; character battle order
; fallthrough

; ------------------------------------------------------------------------------

; [ get character id ]

GetCharID:
@a919:  jsr     GetCharPtr
        lda     a:$0000,x
        and     #$3f
        rts

; ------------------------------------------------------------------------------

; [ sort inventory ]

SortInventory:
@a922:  lda     #$63
        sta     $e3
        ldx     #$1440
        jsr     SortItems
        jmp     CureSfx

; ------------------------------------------------------------------------------
