
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: equip.asm                                                            |
; |                                                                            |
; | description: equipment change menu                                         |
; |                                                                            |
; | created: 4/8/2022                                                          |
; +----------------------------------------------------------------------------+

.import UpdateEquip_ext
.import EquipProp

; ------------------------------------------------------------------------------

; [ equip menu ]

EquipMenu:
@bbf5:  inc     $1b1f
        stz     $1b27
        jsr     SelectChar
        lda     $e8
        bpl     @bc06       ; branch if not cancelled
        stz     $1b1f
        rts
@bc06:  stz     $1bad
        jsr     ResetSprites
        jsr     ResetBGScroll
        lda     #$30        ; sprite layer priority: 3
        sta     $c1
        sta     $3f
        lda     $e8
        sta     $d3
        jsr     DrawPosPortrait
        jsr     TfrSpritesVblank
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
        lda     #$79
        sta     f:hBG4SC
        lda     #$82
        sta     $ae
        lda     #$28
        sta     $c2
        sta     $d2
        lda     $e7
        sta     $b7
        sta     $c0
        ldx     #.loword(UpdatePortraitPos)
        stx     $d0
        ldx     #.loword(TfrSprites)
        stx     $cd
        jsr     SelectClearBG3
        jsr     DrawSelCharBlock
        jsr     TfrBG3TilesVblank
        lda     $e7
        asl
        sta     $43
        ldx     $43
        longa
        lda     f:CharEquipWindowTbl,x
        tax
        shorta
        ldy     #.loword(MainCharWindow)
        phx
        phy
        jsr     TransformWindow
        jsr     SelectEquipSlot
        lda     $e8
        jsl     UpdateEquip_ext
        jsr     HideCursor2
        jsr     ClearBG4Tiles
        jsr     TfrBG4TilesVblank
        longa
        ldx     #$f600
        ldy     #$c600
        lda     #$07ff
        mvn     #$7e,#$7e
        shorta
        lda     #$79
        sta     f:hBG4SC
        jsr     SelectBG3
        jsr     ClearBG2Tiles
        jsr     ClearBG1Tiles
        ldx     #$ffb0
        stx     $96
        ldx     $41         ; zero
        stx     $99
        jsr     TfrBG4TilesVblank
        jsr     UpdateScrollRegs_far
        ldx     #$0800
        stx     $de
        jsr     TfrBG2TilesVblank
        jsr     TfrBG1Tiles
        ldx     #$1000
        stx     $de
        lda     #$02
        sta     $ae
        lda     $e7
        ora     #$80
        sta     $b7
        sta     $c0
        lda     #$28
        sta     $c2
        sta     $d2
        ldx     #.loword(UpdatePortraitPos)
        stx     $d0
        ldx     #.loword(TfrSprites)
        stx     $cd
        jsr     HideCursor1
        plx
        ply
        jsr     TransformWindow
        lda     #$7a
        sta     f:hBG4SC
        jsr     DrawMainMenu
        jsr     TfrBG3TilesVblank
        stz     $1b1f
        rts

; ------------------------------------------------------------------------------

; [ select equipment slot ]

SelectEquipSlot:

.if LANG_EN
        @SLOT_TEXT_X = 7
.else
        @SLOT_TEXT_X = 8
.endif

@bcf7:  jsr     SelectClearBG2
        lda     $1bad
        bne     @bd0f
        longa
        ldx     #$a600      ; copy bg2 tilemap to buffer
        ldy     #$f600
        lda     #$07ff
        mvn     #$7e,#$7e
        shorta
@bd0f:  ldy     #.loword(EquipWindow)
        jsr     DrawWindowText
        lda     $e8
        jsr     GetCharPtr
        stx     $60
        lda     $e8
        jsl     UpdateEquip_ext
        ldy     #$001d
        lda     ($60),y
        ldy     #bg_pos @SLOT_TEXT_X,2
        jsr     DrawNum4
        ldy     #$002a
        lda     ($60),y
        ldy     #bg_pos @SLOT_TEXT_X,4
        jsr     DrawNum4
        ldy     #$0024
        lda     ($60),y
        ldy     #bg_pos @SLOT_TEXT_X,6
        jsr     DrawNum4
        lda     #$31
        sta     $a600+bg_pos @SLOT_TEXT_X,2
        lda     #$3b
        sta     $a600+bg_pos @SLOT_TEXT_X,4
        lda     #$41
        sta     $a600+bg_pos @SLOT_TEXT_X,6
        lda     ($60)
        ldy     #$01c6
        jsr     DrawCharName
        lda     ($60)
        and     #$c0
        lsr3
        sta     $45
        stz     $46
        longa
        lda     #.loword(HandednessText)
        clc
        adc     $45
        tay
        shorta
        ldx     #$0248
        jsr     DrawMenuText
        stz     $db
        ldy     #$0030
        ldx     #$0164
        jsr     DrawEquipItemName
        iny
        ldx     #$01e4
        jsr     DrawEquipItemName
        iny
        ldx     #$0264
        jsr     DrawEquipItemName
        ldy     #$0033
        ldx     #$0064
        jsr     DrawEquipItemName
        iny
        lda     ($60),y
        cmp     #$02
        bcc     @bda7
        phy
        ldy     #$00b6
        jsr     DrawNum2
        ply
@bda7:  iny
        ldx     #$00e4
        jsr     DrawEquipItemName
        iny
        lda     ($60),y
        cmp     #$02
        bcc     @bdbb
        ldy     #$0136
        jsr     DrawNum2
@bdbb:  lda     $1bad
        bne     @bdf7
        jsr     SelectBG1
        ldy     #.loword(EquipWindow)
        jsr     DrawWindow
        jsr     TfrBG1TilesVblank
        jsr     TfrBG2TilesVblank
        inc     $1bad
        longa
        ldx     #$c600      ; copy bg4 tilemap to buffer
        ldy     #$f600
        lda     #$07ff
        mvn     #$7e,#$7e
        shorta
        jsr     ClearBG4Tiles
        jsr     TfrBG4TilesVblank
        lda     #$7a
        sta     f:hBG4SC
        stz     $96
        stz     $97
        jsr     SelectBG2
        bra     @bdfa
@bdf7:  jsr     TfrBG2TilesVblank
; start of frame loop
@bdfa:  lda     #$00
        xba
        lda     $1b37
        asl
        adc     $1b37
        longa
        adc     #$1b28      ; get pointer to inventory cursor position
        sta     $51
        inc
        sta     $54
        inc
        sta     $57
        shorta
        lda     $1b37
        asl4
        adc     #$10
        sta     $46
.if LANG_EN
        lda     #$58
.else
        lda     #$60
.endif
        sta     $45
        jsr     DrawCursor1
        jsr     TfrBG2TilesVblank
        jsr     TfrSprites
        jsr     UpdateCtrlMenu
; up button
        lda     $01
        and     #JOY_UP
        beq     @be3f
        lda     $1b37
        dec
        bpl     @be3c
        lda     #$04
@be3c:  sta     $1b37
; down button
@be3f:  lda     $01
        and     #JOY_DOWN
        beq     @be52
        lda     $1b37
        inc
        cmp     #$05
        bne     @be4f
        lda     #$00
@be4f:  sta     $1b37
@be52:  lda     $00
        and     #JOY_A
        beq     @be7f
; A button
        lda     $1b37
        asl
        jsr     Tax16
        lda     f:EquipSlotRangeTbl,x   ; set max and min valid item id
        sta     $1b1d
        lda     f:EquipSlotRangeTbl+1,x
        sta     $1b1e
        jsr     SelectEquipItem
        jsr     HideCursor2
        jsr     ClearBG4Tiles
        jsr     TfrBG4TilesVblank
        jsr     TfrSprites
        jmp     SelectEquipSlot
; B button
@be7f:  lda     $01
        and     #JOY_B
        beq     @be86
        rts
@be86:  jmp     @bdfa

; ------------------------------------------------------------------------------

; [ select item from inventory ]

SelectEquipItem:
@be89:  lda     #$00
        xba
        lda     ($57)       ; scroll position
        longa
        asl4
        clc
        adc     #$ff98
        sta     $99
        shorta
        jsr     SelectBG4
        lda     $e8
        jsr     GetCharPtr
        stx     $e5
        jsr     DrawInventoryList
        jsr     TfrBG4TilesVblank
        jsr     UpdateScrollRegs_far
        lda     $e8
        jsr     GetCharPtr
        stx     $60
; start of frame loop
@beb6:  lda     ($51)       ; cursor y position
        asl4
        adc     #$76
        sta     $46
        lda     ($54)       ; cursor x position
        beq     @bec6
        lda     #$68
@bec6:  adc     #$08
        sta     $45
        jsr     DrawCursor2
        jsr     TfrSpritesVblank
        jsr     UpdateCtrlMenu
; right button
@bed3:  lda     $01
        and     #JOY_RIGHT
        beq     @bee2
        lda     ($54)
        inc
        and     #$01
        sta     ($54)
        beq     @bf22
; left button
@bee2:  lda     $01
        and     #JOY_LEFT
        beq     @bef1
        lda     ($54)
        inc
        and     #$01
        sta     ($54)
        bne     @bef7
; up button
@bef1:  lda     $01
        and     #JOY_UP
        beq     @bf1c
@bef7:  lda     ($51)
        dec
        bpl     @bf1a
        lda     ($57)
        dec
        bmi     @bf1c
        sta     ($57)
        lda     #$08
@bf05:  longa
        dec     $99
        dec     $99
        shorta
        jsr     UpdateScrollRegsVblank
        dec
        bne     @bf05
        jsr     UpdateCtrlAfterScroll
        bcc     @bed3
        bra     @bf1c
@bf1a:  sta     ($51)
; down button
@bf1c:  lda     $01
        and     #JOY_DOWN
        beq     @bf4b
@bf22:  lda     ($51)
        inc
        cmp     #$06
        bne     @bf49
        lda     ($57)
        inc
        cmp     #$13
        beq     @bf4b
        sta     ($57)
        lda     #$08
@bf34:  longa
        inc     $99
        inc     $99
        shorta
        jsr     UpdateScrollRegsVblank
        dec
        bne     @bf34
        jsr     UpdateCtrlAfterScroll
        bcc     @bed3
        bra     @bf4b
@bf49:  sta     ($51)
; A button
@bf4b:  lda     $00
        and     #JOY_A
        beq     @bf9c
        ldx     $60
        stx     $5d
        lda     ($51)
        clc
        adc     ($57)
        asl
        adc     ($54)
        asl
        jsr     Tax16
        lda     $1440,x
        stx     $4b
        beq     @bf71       ; branch if inventory slot empty (remove item)
        ldx     $5d
        stx     $e5
        jsr     CheckItemEquip
        bcc     @bf74
@bf71:  jmp     EquipItem
@bf74:  jsr     ErrorSfx
        lda     $eb
        beq     @bf9c
        jsr     HideCursor2
        jsr     SelectBG1
        ldy     #.loword(EquipTwoHandWindow)
        jsr     DrawWindowText
        jsr     TfrBG1TilesVblank
        jsr     TfrSprites
        jsr     WaitKeypress
        jsr     ClearBG1Tiles
        ldy     #.loword(EquipWindow)
        jsr     DrawWindow
        jsr     TfrBG1TilesVblank
; B button
@bf9c:  lda     $01
        and     #JOY_B
        beq     @bfa3
        rts
@bfa3:  jmp     @beb6

; ------------------------------------------------------------------------------

; [ check if item can be equipped ]

CheckItemEquip:
@bfa6:  stz     $01eb
        cmp     #$b0
        bcs     @bfb2       ; branch if not a weapon or armor
        jsr     CheckItemSlot
        bcs     @bfb4
@bfb2:  clc
        rts
@bfb4:  jsr     CheckClassEquip
        bcs     @bfba
        rts
@bfba:  lda     $1b37
        cmp     #$02
        bcc     @bfc2
        rts
@bfc2:  lda     ($e5)
        and     #$c0
        cmp     #$c0        ; branch if ambidextrous
        beq     @bfda
        clc
        rol3
        jsr     Tax16
        lda     f:MainHandSlotTbl,x
        cmp     $1b37
        bne     @bfe3       ; branch if not main hand
@bfda:  lda     $1b39
        ldx     #$5f00      ; allow all weapons and shields
        jmp     CheckItemID
@bfe3:  lda     $1b39
        ldx     #$5f4d      ; allow bows and arrows
        jsr     CheckItemID
        bcs     @bff4
        ldx     #$6c61      ; allow shields
        jmp     CheckItemID
@bff4:  sec
        rts

; main hand slot for each handedness
MainHandSlotTbl:
@bff6:  .byte   2,1,0,2

; ------------------------------------------------------------------------------

; [ check if item id is in range ]

CheckArmorID:
@bffa:  ldx     #$9b81      ; allow armor
        bra     _c007

CheckAccessoryID:
@bfff:  ldx     #$af9c      ; allow accessory
        bra     _c007

CheckHelmetID:
@c004:  ldx     #$806d      ; allow helmet
_c007:  lda     $1b39

CheckItemID:
@c00a:  stx     $45
        cmp     $45
        bcc     _c018
        cmp     $46
        beq     _c016
        bcs     _c018
_c016:  sec
        rts
_c018:  clc
        rts

; ------------------------------------------------------------------------------

; [ check if item can go in equipment slot ]

CheckItemSlot:
@c01a:  sta     $1b39
        beq     _c016
        lda     $1b37
        jsr     Tax16
        lda     f:EquipSlotPtrTbl,x
        sta     $1b3a
        cmp     #$30
        beq     CheckHelmetID
        cmp     #$31
        beq     CheckArmorID
        cmp     #$32
        beq     CheckAccessoryID
        lda     $1b39
        lda     $1b37
        beq     @c044
        lda     #$33        ; right hand
        bra     @c046
@c044:  lda     #$35        ; left hand
@c046:  sta     $43
        ldy     $43
        lda     ($e5),y
        sta     $1b38
        bne     @c053
        sec
        rts
@c053:  ldx     #$4c44      ; allow harp, rune axe, wrench
        jsr     CheckItemID
        bcc     @c05f
@c05b:  inc     $eb
        clc
        rts
@c05f:  lda     $1b39
        ldx     #$4c44
        jsr     CheckItemID
        bcs     @c05b
        lda     $1b39
        ldx     #$4300
        jsr     CheckItemID
        bcc     @c092
        lda     ($e5)
        and     #$c0
        cmp     #$c0
        beq     @c086
@c07d:  lda     $1b38
        ldx     #$6c61
        jmp     CheckItemID
@c086:  lda     $1b38
        ldx     #$4300
        jsr     CheckItemID
        bcc     @c07d
        rts
@c092:  ldx     #$6c61
        jsr     CheckItemID
        bcc     @c0a3
        lda     $1b38
        ldx     #$4300
        jmp     CheckItemID
@c0a3:  ldx     #$534d
        jsr     CheckItemID
        bcc     @c0b4
        lda     $1b38
        ldx     #$5f54
        jmp     CheckItemID
@c0b4:  ldx     #$5f54
        jsr     CheckItemID
        bcc     @c0c5
        lda     $1b38
        ldx     #$534d
        jmp     CheckItemID
@c0c5:  clc
        rts

; ------------------------------------------------------------------------------

; valid item ranges for each equipment slot (5 * 2 bytes)
EquipSlotRangeTbl:
@c0c7:  .byte   $01,$6c,$01,$6c,$6d,$80,$81,$9b,$9c,$af

; character properties pointer for each equipment slot (5 * 1 byte)
EquipSlotPtrTbl:
@c0d1:  .byte   $33,$35,$30,$31,$32

; ------------------------------------------------------------------------------

; [ equip/remove item ]

EquipItem:
@c0d6:  lda     $1b37       ; equipped item slot
        jsr     Tax16
        lda     f:EquipSlotPtrTbl,x
        ldx     $4b
        sta     $43
        ldy     $43
        lda     $1b37
        cmp     #$02
        bcc     @c157       ; branch if a weapon slot
; armor slot
        lda     ($60),y
        bne     @c104       ; branch if slot is not empty
        lda     $1440,x
        bne     @c0f7
        rts
@c0f7:  sta     ($60),y
        dec     $1441,x
        bne     @c103
        lda     #$00
        sta     $1440,x
@c103:  rts
@c104:  lda     $1440,x
        bne     @c116
        lda     ($60),y
        sta     $1440,x
        inc     $1441,x
        lda     #$00
        sta     ($60),y
        rts
@c116:  cmp     ($60),y
        beq     @c103
        lda     $1441,x
        cmp     #$01
        bne     @c12e
        lda     ($60),y
        pha
        lda     $1440,x
        sta     ($60),y
        pla
        sta     $1440,x
        rts
@c12e:  lda     ($60),y
        phx
        jsr     FindItem
        beq     @c13c       ; branch if found
        tdc                 ; find an empty slot
        jsr     FindItem
        bne     @c153       ; branch if no empty slots
@c13c:  lda     ($60),y
        sta     $1440,x
        inc     $1441,x
        plx
        lda     $1440,x
        sta     ($60),y
        dec     $1441,x
        bne     @c152
        stz     $1440,x
@c152:  rts
@c153:  plx
@c154:  jmp     ErrorSfx
; weapon slot
@c157:  lda     ($60),y
        bne     @c188
        lda     $1440,x
        bne     @c161
        rts
@c161:  sta     ($60),y
        jsr     CheckItemArrows
        bcc     @c177
        iny
        lda     $1441,x
        sta     ($60),y
@c16e:  lda     #$00
        sta     $1440,x
        sta     $1441,x
        rts
@c177:  iny
        lda     ($60),y
        inc
        sta     ($60),y
        dec     $1441,x
        bne     @c187
        lda     #$00
        sta     $1440,x
@c187:  rts
@c188:  lda     $1440,x
        bne     @c1a0
        lda     ($60),y
        sta     $1440,x
        iny
        lda     ($60),y
        sta     $1441,x
        lda     #$00
        sta     ($60),y
        dey
        sta     ($60),y
        rts
@c1a0:  cmp     ($60),y
        bne     @c1c3
        jsr     CheckItemArrows
        bcc     @c187
        lda     $1441,x
        iny
        clc
        adc     ($60),y
        cmp     #$64
        bcs     @c1b8
        sta     ($60),y
        bra     @c16e
@c1b8:  sec
        sbc     #$63
        sta     $1441,x
        lda     #$63
        sta     ($60),y
        rts
@c1c3:  lda     $1440,x
        jsr     CheckItemArrows
        bcc     @c1cd
        bra     @c1d4
@c1cd:  lda     $1441,x
        cmp     #$01
        bne     @c1dc
@c1d4:  jsr     SwapInventoryByte
        iny
        inx
        jmp     SwapInventoryByte
@c1dc:  iny
        lda     #$63
        sec
        sbc     ($60),y
        sta     $e3
        dey
        lda     ($60),y
        jsr     FindItem
        beq     @c1f6
        lda     #$00
        jsr     FindItem
        beq     @c1f6
        jmp     @c154
@c1f6:  lda     ($60),y
        sta     $1440,x
        iny
        lda     ($60),y
        clc
        adc     $1441,x
        sta     $1441,x
        ldx     $4b
        lda     $1440,x
        jsr     CheckItemArrows
        bcs     @c224
        lda     #$01
        sta     ($60),y
        dey
        lda     $1440,x
        sta     ($60),y
        dec     $1441,x
        bne     @c223
        lda     #$00
        sta     $1440,x
@c223:  rts
@c224:  lda     $1441,x
        sta     ($60),y
        dey
        lda     $1440,x
        sta     ($60),y
        lda     #$00
        sta     $1440,x
        sta     $1441,x
        rts

; ------------------------------------------------------------------------------

; [ find item in inventory ]

;   a: item id (can be zero to find an empty slot)
; $e3: max stack size

FindItem:
@c238:  phy
        ldy     #$0030
        ldx     $41         ; zero
@c23e:  cmp     $1440,x
        beq     @c24c
@c243:  inx2
        dey
        bne     @c23e
        ply
        lda     #$01        ; return 1 if not found
        rts
@c24c:  pha
        lda     $1441,x
        cmp     $e3
        bcc     @c257
        pla
        bra     @c243
@c257:  pla
        ply
        lda     #$00
        rts

; ------------------------------------------------------------------------------

; [ check if item is an arrow ]

CheckItemArrows:
@c25c:  cmp     #$54
        bcc     @c266
        cmp     #$60
        bcs     @c266
        sec                 ; set carry if item is an arrow
        rts
@c266:  clc                 ; clear carry if item is not an arrow
        rts

; ------------------------------------------------------------------------------

; [ swap equipment with inventory ]

; swaps one byte, either item id or quantity

SwapInventoryByte:
@c268:  lda     ($60),y
        pha
        lda     $1440,x
        sta     ($60),y
        pla
        sta     $1440,x
        rts

; ------------------------------------------------------------------------------

; [ check item equipability ]

CheckClassEquip:
@c275:  lda     #0
        xba
        lda     $1b39
        cmp     #$b0
        bcs     @c2b9       ; branch if not a weapon or armor
        longa
        asl3
        tax
        shorta
        lda     f:EquipProp+6,x         ; item properties, byte 6
        and     #$1f
        asl
        jsr     Tax16
        longa
        lda     f:ItemClasses,x   ; item equipability
        sta     $45
        shorta
        ldy     #$0001
        lda     ($e5),y     ; character job
        and     #$0f
        inc
        sta     $48
        stz     $49
        longa
        lda     #$0001      ; set bit for job
@c2ac:  dec     $48
        beq     @c2b3
        asl
        bra     @c2ac
@c2b3:  and     $45
        bne     @c2bb
        shorta
@c2b9:  clc
        rts
@c2bb:  shorta
        sec
        rts

; ------------------------------------------------------------------------------
