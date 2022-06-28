
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: math.asm                                                             |
; |                                                                            |
; | description: battle menu routines                                          |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

; [ clear message window tilemap ]

ClearMsgTiles:
@92ca:  clr_ax
@92cc:  sta     $dae6,x
        inx
        cpx     #$0100
        bne     @92cc
        rts

; ------------------------------------------------------------------------------

; [ draw message window (full) ]

DrawFullMsgWindow:
@92d6:  jsr     ClearMsgTiles
        ldx     #$dae6
        stx     $ef5a
        ldx     #$0003                  ; (3,0)
        stx     $ef56
        ldx     #$041a                  ; 26x4
        stx     $ef58
        jsr     DrawMsgWindow
        lda     #$20
        sta     $ef55
        lda     #$20
        sta     $ef54
        ldx     #$db2e
        stx     $ef52
        jsr     DrawText
        jmp     OpenMsgWindow

; ------------------------------------------------------------------------------

; [ draw message window (left) ]

; used for back attack

DrawLeftMsgWindow:
@9304:  jsr     ClearMsgTiles
        ldx     #$dae6
        stx     $ef5a
        ldx     #$0002                  ; (2,0)
        stx     $ef56
        ldx     #$040a                  ; 10x4
        stx     $ef58
        jsr     DrawMsgWindow
        lda     #$20
        sta     $ef55
        lda     #$20
        sta     $ef54
        ldx     #$db2c
        stx     $ef52
        jsr     DrawText
        jmp     OpenMsgWindow

; ------------------------------------------------------------------------------

; [ draw message window (center) ]

; unused

DrawCenterMsgWindow:
@9332:  jsr     ClearMsgTiles
        ldx     #$dae6
        stx     $ef5a
        ldx     #$000b                  ; (11,0)
        stx     $ef56
        ldx     #$040a                  ; 10x4
        stx     $ef58
        jsr     DrawMsgWindow
        lda     #$20
        sta     $ef55
        lda     #$20
        sta     $ef54
        ldx     #$db3e
        stx     $ef52
        jsr     DrawText
        jmp     OpenMsgWindow

; ------------------------------------------------------------------------------

; [ draw message window (right) ]

DrawRightMsgWindow:
@9360:  jsr     ClearMsgTiles
        ldx     #$dae6
        stx     $ef5a
        ldx     #$0014                  ; (20,0)
        stx     $ef56
        ldx     #$040a                  ; 10x4
        stx     $ef58
        jsr     DrawMsgWindow
        lda     #$20
        sta     $ef55
        lda     #$20
        sta     $ef54
        ldx     #$db50
        stx     $ef52
        jsr     DrawText
        jmp     OpenMsgWindow

; ------------------------------------------------------------------------------

; [ open message window ]

OpenMsgWindow:
@938e:  ldx     #$dae6                  ; message window tilemap buffer
        stx     $ef9e
        ldx     #$78e0                  ; message window tilemap (vram)
        stx     $efa0
        lda     #$04
        sta     $ef9d
        stz     $ef9c
        lda     #$01
        sta     $ef9b
        rts

; ------------------------------------------------------------------------------

; [ close message window ]

CloseMsgWindow:
@93a8:  jsr     ClearMsgTiles
        ldx     #$dba6
        stx     $ef9e
        ldx     #$7940
        stx     $efa0
        lda     #$04
        sta     $ef9d
        lda     #$01
        sta     $ef9c
        sta     $ef9b
        rts

; ------------------------------------------------------------------------------

; [ transfer message window tilemap to vram ]

TfrMsgWindowTiles:
@93c5:  lda     $ef9b
        beq     @9419
        ldx     #$0040
        stx     $0e
        ldx     $ef9e
        ldy     $efa0
        lda     #$7e
        jsr     TfrVRAM4
        dec     $ef9d
        beq     @9416
        lda     $ef9c
        bne     @93fc
        longa
        lda     $ef9e
        clc
        adc     #$0040
        sta     $ef9e
        lda     $efa0
        clc
        adc     #$0020
        sta     $efa0
        bra     @9412
@93fc:  longa
        lda     $ef9e
        sec
        sbc     #$0040
        sta     $ef9e
        lda     $efa0
        sec
        sbc     #$0020
        sta     $efa0
@9412:  shorta0
        rts
@9416:  stz     $ef9b
@9419:  rts

; ------------------------------------------------------------------------------

; [ transfer mp cost tilemap to vram ]

TfrMPText:
@941a:  lda     $1838
        beq     @9432                   ; branch if update is disabled
        ldx     #$0006                  ; 3 tiles
        stx     $0e
        lda     #$00
        ldx     #$1839
        ldy     #$5f39
        jsr     TfrVRAM4
        stz     $1838                   ; disable update
@9432:  rts

; ------------------------------------------------------------------------------

; [ transfer menu tilemap to vram (update) ]

TfrMenuTilesUpdate:
@9433:  lda     $1824
        beq     @9461                   ; branch if no transfer needed
        lda     $1825                   ; number of transfers
        tax
        lda     f:TfrMenuTilesPtrs,x
        tax
        longa
        lda     $1824,x                 ; source address
        pha
        lda     $1826,x                 ; destination address (vram)
        tay
        lda     $1828,x                 ; transfer size
        sta     $0e
        shorta0
        plx
        lda     #$7e
        jsr     TfrVRAM4
        dec     $1825
        bne     @9461
        stz     $1824                   ; disable menu tilemap vram
@9461:  jsr     TfrMPText
        jmp     TfrMsgWindowTiles

; ------------------------------------------------------------------------------

; pointers to menu tilemap vram transfer data
TfrMenuTilesPtrs:
@9467:  .byte   $00,$02,$08,$0e

; ------------------------------------------------------------------------------

; [ do menu text update ]

UpdateMenuText:
@946b:  jsr     UpdateMenuText2
        stz     $1821
        rts

; ------------------------------------------------------------------------------

; [ do menu text update ]

UpdateMenuText2:
@9472:  lda     $1821
        asl
        tax
        lda     f:UpdateMenuTextTbl,x
        sta     $00
        lda     f:UpdateMenuTextTbl+1,x
        sta     $01
        jmp     ($0000)

; ------------------------------------------------------------------------------

; menu text update jump table
UpdateMenuTextTbl:
@9486:  .addr   UpdateMenuText_00
        .addr   UpdateCharNames
        .addr   UpdateMenuText_02
        .addr   UpdateMenuText_03
        .addr   DrawHPText
        .addr   DrawMonsterNames
        .addr   DrawMPText
        .addr   UpdateMenuText_07
        .addr   UpdateMenuText_08
        .addr   UpdateMenuText_09

; ------------------------------------------------------------------------------

UpdateMenuText_00:
@949a:  rts

; ------------------------------------------------------------------------------

; [ get max equipment quantity ]

; set carry if arrows (never used)

GetMaxQty:
@949b:  lda     $321b,y                 ; item id
        cmp     #$61
        bcc     @94a4
        bra     @94ae
@94a4:  cmp     #$54
        bcc     @94ae
        lda     #20                     ; 20 arrows
@ZeroQty:
        sta     $04
        sec
        rts
@94ae:  lda     #1                      ; 1 for other weapons
        sta     $04
        clc
        rts

; ------------------------------------------------------------------------------

; [ equip item ]

; The Japanese easy version includes an attempt to fix for the item duplication
; bug. Instead of catching the bug when it occurs (in the item/equip menu),
; they try to prevent empty slots in the equipment buffer from being copied back
; to character data after battle, but it doesn't actually work.

UpdateMenuText_09:
@94b4:  jsr     EquipItem

UpdateEquipmentBuf:
@94b7:  clr_axy
        longa
@94bc:  lda     $32db,x                 ; equipped item id
        sta     $2033,y                 ; copy to character properties
.if EASY_VERSION
        and     #$00ff                  ; branch if slot is empty
.else
        and     #$ff00
.endif
        bne     @94ca                   ; branch if quantity is nonzero
        sta     $2033,y
@94ca:  lda     $32df,x
        sta     $2035,y
.if EASY_VERSION
        and     #$00ff
.else
        and     #$ff00
.endif
        bne     @94d8
        sta     $2035,y
@94d8:  txa
        clc
        adc     #$0008
        tax
        tya
        clc
        adc     #$0080
        tay
        cpy     #$0280
        bne     @94bc
        shorta0
        rts

; ------------------------------------------------------------------------------

; [ equip item from inventory (or unequip item) ]

EquipItem:
@94ed:  lda     $181a
        asl2
        sta     $00
        lda     $1819
        asl3
        clc
        adc     $00
        tax
        lda     $181b
        asl2
        tay
        lda     $181c
        beq     @9540
        cmp     #$01
        beq     @9543
        cmp     #$02
        beq     @9583
        cmp     #$03
        beq     @9546
        cmp     #$04
        beq     @951a
        rts

; 4: overfull inventory slot -> empty equipment slot
@951a:  jsr     GetMaxQty
        lda     $321c,y
        sec
        sbc     $04
        sta     $321c,y
        lda     $321a,y
        sta     $32da,x
        lda     $321b,y
        sta     $32db,x
        lda     $04
        sta     $32dc,x
        lda     $321d,y
        sta     $32dd,x
        jmp     @9616
@9540:  jmp     @95fe
@9543:  jmp     @95e0

; 3: equip more of same type of arrows
@9546:  lda     $321c,y
        sta     $01
        lda     #20
        sec
        sbc     $32dc,x
        sta     $00
        cmp     $01
        bcc     @956f

; transfer entire arrow stack to equip slot
        lda     $01
        clc
        adc     $32dc,x
        sta     $32dc,x
        lda     #$80
        sta     $321a,y
        clr_a
        sta     $321b,y
        sta     $321c,y
        jmp     @9616

; transfer part of arrow stack to equip slot
@956f:  lda     $32dc,x
        clc
        adc     $00
        sta     $32dc,x
        lda     $01
        sec
        sbc     $00
        sta     $321c,y
        jmp     @9616

; 2: swap equipment with inventory item
@9583:  lda     $32da,x                 ; save equipped item
        sta     $00
        lda     $32db,x
        sta     $01
        lda     $32dc,x
        sta     $02
        lda     $32dd,x
        sta     $03
        jsr     GetMaxQty
        lda     $321c,y
        sec
        sbc     $04
        sta     $321c,y
        lda     $321a,y
        sta     $32da,x
        lda     $321b,y
        sta     $32db,x
        lda     $04
        sta     $32dc,x
        lda     $321d,y
        sta     $32dd,x
        lda     $181d
        asl2
        tay
        lda     $00
        sta     $321a,y
        lda     $01
        sta     $321b,y
        lda     $02
        sta     $321c,y
        lda     $03
        sta     $321d,y
        lda     $181d
        sta     $1817
        jsr     DrawInventoryItemText
        jmp     @9616

; 1: equipment slot -> inventory slot with same item
@95e0:  lda     $321c,y
        clc
        adc     $32dc,x
        cmp     #100
        bcc     @95ed
        lda     #99
@95ed:  sta     $321c,y
        lda     #$80
        sta     $32da,x
        stz     $32db,x
        stz     $32dc,x
        jmp     @9616

; 0: swap equipment slot and inventory slot
@95fe:  lda     #4
        sta     $00
@9602:  lda     $32da,x                 ; swap 4 bytes
        pha
        lda     $321a,y
        sta     $32da,x
        pla
        sta     $321a,y
        inx
        iny
        dec     $00
        bne     @9602
@9616:  lda     $1819
        sta     $1816
        ldx     $181a
        stx     $1817
        lda     $1817
        jsr     DrawEquipItemText
        lda     $1818
        sta     $1817
        jmp     DrawInventoryItemText

; ------------------------------------------------------------------------------

; [ swap inventory slots ]

UpdateMenuText_08:
@9631:  lda     $181a
        asl2
        tax
        lda     $181b
        asl2
        tay
        lda     #$04
        sta     $00
@9641:  lda     $321a,x                 ; swap inventory slots
        pha
        lda     $321a,y
        sta     $321a,x
        pla
        sta     $321a,y
        inx
        iny
        dec     $00
        bne     @9641
        lda     $1819
        sta     $1816
        ldx     $181a
        stx     $1817
        jsr     DrawInventoryItemText
        lda     $1818
        sta     $1817
        jmp     DrawInventoryItemText

; ------------------------------------------------------------------------------

; [ do forced menu vram update ]

ImmediateMenuUpdate:
@966d:  lda     $1824
        bne     @9681                   ; branch if transfer is pending
        jsr     UpdateMenuText
        jsr     TfrMenuTilesImmediate
        lda     $181f
        sta     $181e
        stz     $181f
@9681:  rts

; ------------------------------------------------------------------------------

; [ transfer menu tilemap to vram ]

TfrMenuTilesImmediate:
@9682:  lda     $181e
        asl
        tax
        lda     f:ImmediateMenuUpdateTbl,x
        sta     $00
        lda     f:ImmediateMenuUpdateTbl+1,x
        sta     $01
        jmp     ($0000)

; ------------------------------------------------------------------------------

; immediate menu update jump table
ImmediateMenuUpdateTbl:
@9696:  .addr   NoMenuUpdate
        .addr   NoMenuUpdate
        .addr   DrawMainMenu
        .addr   UpdateCmdWindow
        .addr   TfrWhiteMagicList
        .addr   TfrBlackMagicList
        .addr   TfrSummonMagicList
        .addr   TfrInventoryList
        .addr   TfrMPWindow
        .addr   TfrEquipWindow
        .addr   UnusedMenuUpdate
        .addr   UnusedMenuUpdate
        .addr   UpdateStatusTiles

; periodic menu vram update jump table
PeriodicMenuUpdateTbl:
@96b0:  .addr   DrawMainMenu
        .addr   UpdateCmdWindow
        .addr   TfrMPWindow
        .addr   TfrEquipWindow
        .addr   UpdateMagicList
        .addr   UpdateStatusTiles
        .addr   DrawMainMenu
        .addr   UpdateCharNames

; periodic menu text update jump table
PeriodicTextUpdateTbl:
@96c0:  .addr   UpdateCharNames
        .addr   TfrMainMenu
        .addr   TfrCmdWindow
        .addr   TfrStatusTiles

; ------------------------------------------------------------------------------

; [ redraw main menu (called every frame) ]

RedrawMainMenu:
@96c8:  jsr     DrawStatusText
        jsr     DrawCmdWindow
        jsr     DrawObjNames
        jmp     DrawCharHP

; ------------------------------------------------------------------------------

; [ transfer inventory/spell list tilemap to vram ]

UpdateMagicList:
@96d4:  lda     $4a
        and     #$7c
        beq     @96f8
        cmp     #$40
        bne     @96e1
        jmp     TfrSummonMagicList
@96e1:  cmp     #$20
        bne     @96e8
        jmp     TfrBlackMagicList
@96e8:  cmp     #$10
        bne     @96ef
        jmp     TfrWhiteMagicList
@96ef:  lda     $4a
        and     #$04
        beq     @96f8
        jmp     TfrInventoryList
@96f8:  rts

; ------------------------------------------------------------------------------

; unused
@96f9:  rts

; ------------------------------------------------------------------------------

; [ do periodic menu vram update ]

PeriodicMenuUpdate:
@96fa:  lda     $1824
        bne     @9718                   ; branch if transfer is pending
        inc     $1845                   ; increment periodic menu update counter
        lda     $1845
        and     #$07
        asl
        tax
        lda     f:PeriodicMenuUpdateTbl,x
        sta     $00
        lda     f:PeriodicMenuUpdateTbl+1,x
        sta     $01
        jmp     ($0000)
@9718:  rts

; ------------------------------------------------------------------------------

; [ do periodic menu text update ]

PeriodicTextUpdate:
@9719:  lda     $1824
        bne     @9737                   ; branch if transfer is pending
        inc     $f44d
        lda     $f44d
        and     #$03
        asl
        tax
        lda     f:PeriodicTextUpdateTbl,x
        sta     $00
        lda     f:PeriodicTextUpdateTbl+1,x
        sta     $01
        jmp     ($0000)
@9737:  rts

; ------------------------------------------------------------------------------

; [ load menu tilemap vram transfer data ]

; Y is either 2, 8, or 14

LoadMenuTfrData:
@9738:  phy
        sta     $26
        lda     #$06
        sta     $28
        jsr     Mult8
        ldx     $2a
        ply
        lda     #$06
        sta     $00
@9749:  lda     f:MenuUpdateVRAMTfrTbl,x
        sta     $1824,y
        iny
        inx
        dec     $00
        bne     @9749
        rts

; ------------------------------------------------------------------------------

; [ no immediate menu update ]

NoMenuUpdate:
@9757:  rts

; ------------------------------------------------------------------------------

; pointers to character mp text buffers
CharMPTextBufPtrs:
@9758:  .byte   $00,$1c,$38,$54,$70

; しょうひ　ＭＰ (mp consumption)
MPNeededText:
@975d:  .byte   $de,$df,$e0,$e1,$ff,$e2,$e3

; ------------------------------------------------------------------------------

; [ update mp cost tilemap ]

TfrMPWindow:
@9764:  lda     $1822                   ; selected character
        tax
        lda     f:CharMPTextBufPtrs,x
        tax
        clr_ay
@976f:  lda     $ba92,x                 ; copy from text buffer to tilemap
        sta     $d3d4,y
        lda     $baa0,x
        sta     $d414,y
        iny
        inx
        cpy     #$000e
        bne     @976f
        clr_axy
@9785:  lda     f:MPNeededText,x        ; しょうひ　ＭＰ
        sta     $d494,y
        iny2
        inx
        cpx     #7
        bne     @9785
        lda     #$06                    ; mp cost window
        ldy     #$0002
        jsr     LoadMenuTfrData
        lda     #$01
        sta     $1825                   ; 1 transfer
        sta     $1824                   ; enable menu tilemap vram transfer
        rts

; ------------------------------------------------------------------------------

UnusedMenuUpdate:
@97a5:  rts

; ------------------------------------------------------------------------------

; [ update equipped items tilemap ]

TfrEquipWindow:
@97a6:  ldx     #$d1ec
        stx     $00
        ldx     #$d208
        stx     $02
        lda     $1822
        asl
        tax
        longa
        lda     f:EquipTextBufPtrs,x
        pha
        lda     f:RLHandTextBufPtrs,x
        tax
        shorta0
        clr_ay
@97c6:  lda     a:$0000,x
        sta     ($00),y
        lda     a:$0014,x
        sta     ($02),y
        inx
        iny
        cpy     #$000a
        bne     @97c6
        ldy     #$0040
@97da:  lda     a:$0000,x
        sta     ($00),y
        lda     a:$0014,x
        sta     ($02),y
        inx
        iny
        cpy     #$004a
        bne     @97da
        plx
        ldy     #$0080
@97ef:  lda     a:$0000,x
        sta     ($00),y
        lda     a:$0030,x
        sta     ($02),y
        inx
        iny
        cpy     #$0098
        bne     @97ef
        ldy     #$00c0
@9803:  lda     a:$0000,x
        sta     ($00),y
        lda     a:$0030,x
        sta     ($02),y
        inx
        iny
        cpy     #$00d8
        bne     @9803
        lda     #$07                    ; equipped items window
        ldy     #$0002
        jsr     LoadMenuTfrData
        lda     #$01
        sta     $1825                   ; 1 transfer
        sta     $1824                   ; enable menu tilemap vram transfer
        rts

; ------------------------------------------------------------------------------

MagicListTextBufPtrs:
@9825:  .word   $0000,$06c0,$0d80,$1440,$1b00

; ------------------------------------------------------------------------------

; [ update spell list tilemap in vram ]

TfrSummonMagicList:
@982f:  ldx     #$0480                  ; summon
        bra     _983c

TfrBlackMagicList:
@9834:  ldx     #$0240                  ; black magic/ninjutsu
        bra     _983c

TfrWhiteMagicList:
@9839:  ldx     #$0000                  ; white magic
_983c:  phx
        lda     $1822
        sta     $00
        jsr     DrawMagicList
        plx
        stx     $06
        ldx     #$c536
        stx     $00
        ldx     #$0010
@9850:  clr_ay
        dec
@9853:  sta     ($00),y
        iny2
        cpy     #$002a
        bne     @9853
        longa
        lda     $00
        clc
        adc     #$0040
        sta     $00
        shorta0
        dex
        bne     @9850
        ldx     #$c52a
        stx     $00
        ldx     #$c538
        stx     $02
        ldx     #$c546
        stx     $04
        lda     $1822
        asl
        tax
        longa
        lda     f:MagicListTextBufPtrs,x
        clc
        adc     $06
        tax
        shorta0
        lda     #$08
        sta     $06
@9891:  clr_ay
@9893:  lda     $97a6,x
        sta     ($00),y
        lda     $97be,x
        sta     ($02),y
        lda     $97d6,x
        sta     ($04),y
        iny
        inx
        cpy     #$000c
        bne     @9893
        ldy     #$0040
@98ac:  lda     $97a6,x
        sta     ($00),y
        lda     $97be,x
        sta     ($02),y
        lda     $97d6,x
        sta     ($04),y
        iny
        inx
        cpy     #$004c
        bne     @98ac
        longa
        txa
        clc
        adc     #$0030
        tax
        lda     $00
        clc
        adc     #$0080
        sta     $00
        lda     $02
        clc
        adc     #$0080
        sta     $02
        lda     $04
        clc
        adc     #$0080
        sta     $04
        shorta0
        dec     $06
        bne     @9891
        lda     #$02                    ; spell list
        ldy     #$0002
        jsr     LoadMenuTfrData
        lda     #$01
        sta     $1825                   ; 1 transfer
        sta     $1824                   ; enable menu tilemap vram transfer
        rts

; ------------------------------------------------------------------------------

; [ transfer inventory tilemap to vram ]

TfrInventoryList:
@98fa:  jsr     UpdateEnabledItems
        ldx     #$c52a                  ; pointer to inventory tilemap buffer
        stx     $00
        ldx     #$c546
        stx     $02
        clr_ax
        lda     #$18                    ; 24 rows
        sta     $06
; start of row loop
@990d:  clr_ay
        dec
        sta     ($00),y
        sta     ($02),y
        ldy     #$0040
        sta     ($00),y
        sta     ($02),y
        ldy     #$0002
@991e:  lda     $8ea6,x                 ; inventory text buffer
        sta     ($00),y
        lda     $8ed6,x
        sta     ($02),y
        iny
        inx
        cpy     #$001a
        bne     @991e
        ldy     #$0042
@9932:  lda     $8ea6,x                 ; inventory text buffer
        sta     ($00),y
        lda     $8ed6,x
        sta     ($02),y
        iny
        inx
        cpy     #$005a
        bne     @9932
        longa
        txa
        clc
        adc     #$0030
        tax
        lda     $00
        clc
        adc     #$0080
        sta     $00
        lda     $02
        clc
        adc     #$0080
        sta     $02
        shorta0
        dec     $06
        bne     @990d
        lda     #$03                    ; inventory 1
        ldy     #$0002
        jsr     LoadMenuTfrData
        lda     #$04                    ; inventory 2
        ldy     #$0008
        jsr     LoadMenuTfrData
        lda     #$05                    ; inventory 3
        ldy     #$000e
        jsr     LoadMenuTfrData
        lda     #$03
        sta     $1825                   ; 3 transfers
        sta     $1824                   ; enable menu tilemap vram transfer
        rts

; ------------------------------------------------------------------------------

; [ update battle command window ]

UpdateCmdWindow:
@9983:  jsr     DrawCmdWindow
        jmp     TfrCmdWindow

; ------------------------------------------------------------------------------

; [ draw battle command window ]

DrawCmdWindow:
@9989:  ldx     #$0340
@998c:  lda     $be65,x                 ; copy main menu window tilemap
        sta     $c1a5,x
        dex
        bne     @998c
        lda     #$02
        jsr     LoadMenuWindowData
        jsr     DrawWindow3
        lda     #$03
        ldx     #$64
        jmp     DrawCmdListText

; ------------------------------------------------------------------------------

; [ transfer battle command window tilemap to vram ]

TfrCmdWindow:
@99a5:  lda     #$01                    ; battle command window
        ldy     #$0002
        jsr     LoadMenuTfrData
        lda     #$01
        sta     $1825                   ; 1 transfer
        sta     $1824                   ; enable menu tilemap vram transfer
        rts

; ------------------------------------------------------------------------------

; [ transfer status tilemap to vram ]

UpdateStatusTiles:
@99b6:  jsr     DrawStatusText

TfrStatusTiles:
@99b9:  ldy     #$0002
        lda     #$08                    ; status
        jsr     LoadMenuTfrData
        lda     #$01
        sta     $1825                   ; 1 transfer
        sta     $1824                   ; enable menu tilemap vram transfer
        rts

; ------------------------------------------------------------------------------

; [ draw main menu ]

DrawMainMenu:
@99ca:  jsr     DrawObjNames
        jsr     DrawCharHP
        jmp     TfrMainMenu

; ------------------------------------------------------------------------------

; [ draw monster and character names ]

DrawObjNames:
@99d3:  clr_a                           ; monster names
        jsr     DrawMainMenuText
        lda     #$01                    ; character names
        jmp     DrawMainMenuText

; ------------------------------------------------------------------------------

; [ draw character hp ]

DrawCharHP:
@99dc:  lda     #$02                    ; character hp
        jmp     DrawMainMenuText

; ------------------------------------------------------------------------------

; [ transfer main menu tilemap to vram ]

TfrMainMenu:
@99e1:  clr_a                           ; main menu
        ldy     #$0002
        jsr     LoadMenuTfrData
        lda     #$01
        sta     $1825                   ; 1 transfer
        sta     $1824                   ; enable menu tilemap vram transfer
        rts

; ------------------------------------------------------------------------------

; [ draw main menu text ]

; A: main menu text to update
;      0: monster names
;      1: character names
;      2: character hp
;      3: battle commands

DrawCmdListText:
@99f1:  pha
        lda     $1822                   ; selected character slot
        sta     $26
        stx     $28
        jsr     Mult8
        ldx     $2a
        stx     $ef62                   ; text buffer offset
        pla
        jmp     _9a0b

DrawMainMenuText:
@9a05:  ldx     #0
        stx     $ef62
_9a0b:  sta     $26
        lda     #6
        sta     $28
        jsr     Mult8
        ldx     $2a
        clr_ay
@9a18:  lda     f:MenuTextUpdateTbl,x   ; main menu text update data
        sta     $ef5c,y
        iny
        inx
        cpy     #6
        bne     @9a18
        longa
        lda     $ef5e
        clc
        adc     $ef62                   ; add text buffer offset
        sta     $ef5e
        shorta0
        lda     $ef5c
        tax
        stx     $02
        ldx     $ef60
        stx     $00
        ldx     $ef5e
@9a43:  clr_ay
@9a45:  lda     a:$0000,x
        sta     ($00),y
        inx
        iny
        cpy     $02
        bne     @9a45
        longa
        lda     $00
        clc
        adc     #$0040
        sta     $00
        shorta0
        dec     $ef5d
        bne     @9a43
        rts

; ------------------------------------------------------------------------------

; [ init menu text and tilemaps ]

InitMenuWindows:
@9a63:  jsr     UpdateCharNames
        jsr     InitInventoryTextBuf
        jsr     InitMagicListTextBuf
        jsr     DrawHPText
        jsr     DrawMonsterNames
        jsr     DrawMPText
        jsr     DrawAllCmdLists
        jsr     InitEquipTextBuf
        jsr     DrawAllMenuWindows
        jsr     DrawDefendRow
        jsr     DrawStatusText
        jsl     DrawPauseText
        jmp     TfrMenuTilesInit

; ------------------------------------------------------------------------------

; [ draw defend and row text ]

DrawDefendRow:
@9a8b:  ldx     #$d5e8
        stx     $00
.if LANG_EN
        ldx     #$d618
.else
        ldx     #$d61c
.endif
        stx     $02
        clr_axy
@9a98:  lda     f:DefendText,x
        sta     ($00),y
        lda     f:RowText,x
        sta     ($02),y
        inx
        iny2
        cpx     #DefendRowTextLength*2
        beq     @9ab6
        cpx     #DefendRowTextLength
        bne     @9a98
        ldy     #$0040
        bra     @9a98
@9ab6:  rts

; ------------------------------------------------------------------------------

.if LANG_EN

DefendRowTextLength = 6

DefendText:
@9ab7:  .byte   $ff,$ff,$ff,$ff,$ff,$ff
        .byte   $e4,$e5,$e6,$e6,$e7,$ff

RowText:
@9ac3:  .byte   $ff,$ff,$ff,$ff,$ff,$ff
        .byte   $e8,$e9,$e5,$ea,$eb,$ec

.else

DefendRowTextLength = 4

; "ぼうぎょ" (defend)
DefendText:
@9ab7:  .byte   $e8,$ff,$e8,$ff
        .byte   $e9,$ea,$eb,$ec

; "チェンジ" (change row)
RowText:
@9abf:  .byte  $ff,$ff,$ff,$e8
        .byte  $e4,$e5,$e6,$e7

.endif

; ------------------------------------------------------------------------------

; [ transfer menu tilemap to vram (init) ]

TfrMenuTilesInit:
@9ac7:  clr_ax
@9ac9:  longa
        lda     f:MenuInitVRAMTfrTbl,x
        sta     $02
        lda     f:MenuInitVRAMTfrTbl+2,x
        tay
        lda     f:MenuInitVRAMTfrTbl+4,x
        sta     $00
        txa
        clc
        adc     #$0006
        tax
        shorta0
        lda     #$7e
        phx
        ldx     $02
        jsr     TfrVRAM5
        plx
        cpx     #$0036
        bne     @9ac9
        rts

; ------------------------------------------------------------------------------

; [ draw all menu windows ]

DrawAllMenuWindows:
@9af4:  ldx     #$1840
        clr_a
@9af8:  sta     $be65,x
        dex
        bne     @9af8
        clr_ax
        longa
@9b02:  lda     #$0200
        sta     $d366,x
        lda     #$2000
        sta     $d6a6,x
        clr_a
        sta     $dbe6,x
        inx2
        cpx     #$0340
        bne     @9b02
        shorta0
@9b1c:  jsr     LoadMenuWindowData
        pha
        jsr     DrawWindow3
        pla
        inc
        cmp     #$07
        bne     @9b1c
        lda     #$07
        jsr     LoadMenuWindowData
        jsr     DrawWindow2
        lda     #$08
        jsr     LoadMenuWindowData
        jsr     DrawWindow2
        lda     #$09
        jsr     LoadMenuWindowData
        jsr     DrawWindow2
        lda     #$0a
        jsr     LoadMenuWindowData
        jsr     DrawWindow3
        lda     #$0b
        jsr     LoadMenuWindowData
        jsr     DrawWindow3
        lda     #$0c
        jsr     LoadMenuWindowData
        jmp     DrawWindow

; ------------------------------------------------------------------------------

; [ load menu window data ]

; A: menu window id

LoadMenuWindowData:
@9b59:  pha
        sta     $26
        lda     #$06
        sta     $28
        jsr     Mult8
        ldx     $2a
        clr_ay
@9b67:  lda     f:MenuWindowTbl,x
        sta     $ef56,y
        iny
        inx
        cpy     #6
        bne     @9b67
        pla
        rts

; ------------------------------------------------------------------------------

; [ get window border tiles ]

GetBorderTiles:
@9b77:  ldx     $04
        lda     f:BorderTilesTbl,x
        sta     $06
        lda     f:BorderTilesTbl+1,x
        sta     $07
        lda     f:BorderTilesTbl+2,x
        sta     $08
        inx3
        stx     $04
        rts

; ------------------------------------------------------------------------------

; window border tiles
BorderTilesTbl:
@9b91:  .byte   $10,$11,$12
        .byte   $0b,$ff,$0c
        .byte   $0d,$0e,$0f

        .byte   $f7,$f8,$f9
        .byte   $fa,$ff,$fb
        .byte   $fc,$fd,$fe

        .byte   $16,$17,$18
        .byte   $fa,$ff,$fb
        .byte   $fc,$fd,$fe

; ------------------------------------------------------------------------------

; [ draw window ]

DrawWindow:
@9bac:  ldx     #$0009
        stx     $04
        lda     #$20
        bra     _9bcb

DrawMsgWindow:
@9bb5:  ldx     #$0012
        stx     $04
        lda     #$20
        bra     _9bcb

DrawWindow2:
@9bbe:  ldx     #$0009
        stx     $04
        lda     #$02
        bra     _9bcb

DrawWindow3:
@9bc7:  clr_ax
        stx     $04
_9bcb:  sta     $02
        lda     $ef57       ; y-offset
        sta     $26
        lda     #$40
        sta     $28
        jsr     Mult8
        lda     $ef56       ; x-offset
        longa
        pha
        asl
        clc
        adc     $2a
        adc     $ef5a       ; destination address
        sta     $00
        pla
        shorta
        jsr     GetBorderTiles
        ldx     $00
        lda     $ef58       ; width
        tay
        lda     $06
        sta     a:$0000,x
        lda     $02
        sta     a:$0001,x
        inx2
        dey2
@9c02:  lda     $07
        sta     a:$0000,x
        lda     $02
        sta     a:$0001,x
        inx2
        dey
        bne     @9c02
        lda     $08
        sta     a:$0000,x
        lda     $02
        sta     a:$0001,x
        dec     $ef59       ; height
        dec     $ef59
        jsr     GetBorderTiles
@9c24:  longa
        lda     $00
        clc
        adc     #$0040
        sta     $00
        shorta0
        ldx     $00
        lda     $ef58
        tay
        lda     $06
        sta     a:$0000,x
        lda     $02
        sta     a:$0001,x
        inx2
        dey2
@9c45:  lda     $07
        sta     a:$0000,x
        lda     $02
        sta     a:$0001,x
        inx2
        dey
        bne     @9c45
        lda     $08
        sta     a:$0000,x
        lda     $02
        sta     a:$0001,x
        dec     $ef59
        bne     @9c24
        jsr     GetBorderTiles
        longa
        lda     $00
        clc
        adc     #$0040
        sta     $00
        shorta0
        ldx     $00
        lda     $ef58
        tay
        lda     $06
        sta     a:$0000,x
        lda     $02
        sta     a:$0001,x
        inx2
        dey2
@9c87:  lda     $07
        sta     a:$0000,x
        lda     $02
        sta     a:$0001,x
        inx2
        dey
        bne     @9c87
        lda     $08
        sta     a:$0000,x
        lda     $02
        sta     a:$0001,x
        rts

; ------------------------------------------------------------------------------

; [ draw all battle command lists ]

DrawAllCmdLists:
@9ca1:  stz     $1816
@9ca4:  stz     $1817
@9ca7:  jsr     DrawCmdName
        inc     $1817
        lda     $1817
        cmp     #$05
        bne     @9ca7
        inc     $1816
        lda     $1816
        cmp     #5
        bne     @9ca4
        rts

; ------------------------------------------------------------------------------

; [ draw battle command list ]

DrawCmdList:
@9cbf:  stz     $1817
@9cc2:  jsr     DrawCmdName
        inc     $1817
        lda     $1817
        cmp     #5
        bne     @9cc2
        rts

; ------------------------------------------------------------------------------

; [ draw battle command name ]

UpdateMenuText_07:
DrawCmdName:
@9cd0:  ldx     #$74fd      ; text buffer
        stx     $ef50
        lda     #$05
        sta     $ef54
        lda     $1817       ; battle command slot
        sta     $26
        lda     #$14
        sta     $28
        jsr     Mult8
        lda     $1817
        asl2
        tax
        stx     $00
        lda     $1816       ; character id
        asl
        tax
        longa
        lda     f:CmdTextBufPtrs,x
        clc
        adc     $2a         ; add command slot * 20
        sta     $ef52
        lda     f:CmdDataPtrs,x   ; pointers to battle command data
        clc
        adc     $00
        tax
        shorta0
        phx
        lda     a:$0001,x     ; $3303
        sta     $26
        lda     a:$0000,x     ; $3302
        pha
        lda     #$05
        sta     $28
        jsr     Mult8
        ldx     $2a
        lda     #$00        ; white text
        sta     $00
        pla
        and     #$80
        beq     @9d2b
        lda     #$04        ; gray text
        sta     $00
@9d2b:  clr_ay
        lda     #$0e        ; change tile flags
        sta     $74fd,y
        iny
        lda     $00         ; text color
        sta     $74fd,y
        iny
@9d39:  lda     f:BattleCmdName,x
        sta     $74fd,y
        iny
        inx
        cpy     #$0007
        bne     @9d39
        clr_a
        sta     $74fd,y
        plx
        lda     a:$0001,x
        cmp     #$ff
        bne     @9d5f
        ldy     #$0002
@9d56:  sta     $74fd,y
        iny
        cpy     #$0007
        bne     @9d56
@9d5f:  clr_a
        sta     $ef55
        jsr     DrawText
        rts

; ------------------------------------------------------------------------------

; ??? pointers for left and right hand

EquipHandPtrs:
@9d67:  .byte   $00,$30

; ------------------------------------------------------------------------------

; [ init equipped item text buffer ]

InitEquipTextBuf:
@9d69:  stz     $1816
@9d6c:  stz     $1817
@9d6f:  jsr     DrawEquipItemText
        inc     $1817
        lda     $1817
        cmp     #$02
        bne     @9d6f
        jsr     DrawEquipHandText
        inc     $1816
        lda     $1816
        cmp     #$05
        bne     @9d6c
        rts

; ------------------------------------------------------------------------------

; [ draw right/left hand text ]

DrawEquipHandText:
@9d8a:  lda     $1816
        tax
        jsr     GetObjPtr
        lda     $2000,x     ; left/right handed
        and     #$c0
        lsr6
        sta     $26
        lda     #$14
        sta     $28
        jsr     Mult8
        lda     $1816
        asl
        tax
        longa
        lda     f:RLHandTextBufPtrs,x
        tay
        shorta0
        ldx     $2a
        lda     #$14
        sta     $00
@9dba:  lda     f:RLHandText,x
        sta     a:$0000,y
        clr_a
        sta     a:$0001,y
        inx
        iny2
        dec     $00
        bne     @9dba
        rts

; ------------------------------------------------------------------------------

; [ draw equipped item text ]

DrawEquipItemText:
@9dcd:  ldx     #$74fd
        stx     $ef50
        lda     #$0c
        sta     $ef54
        lda     $1817
        tax
        lda     f:EquipHandPtrs,x
        tax
        stx     $02
        lda     $1817
        asl2
        tax
        stx     $00
        lda     $1816
        asl
        tax
        longa
        lda     f:EquipTextBufPtrs,x
        clc
        adc     $02
        sta     $ef52
        lda     f:EquipDataPtrs,x
        clc
        adc     $00
        tax
        shorta0
        lda     #$00
        sta     $00
        lda     #$00
        sta     $01
        lda     a:$0001,x
        sta     $26
        sta     $02
        lda     a:$0002,x
        pha
        lda     #$09
        sta     $28
        jsr     Mult8
        lda     a:$0000,x
        and     #$80
        beq     @9e2e
        lda     #$04
        sta     $00
        sta     $01
@9e2e:  ldx     $2a
        clr_ay
        lda     #$0e
        sta     $74fd,y
        iny
        lda     $01
        sta     $74fd,y
        iny
        lda     #$03
        sta     $74fd,y
        iny
        lda     f:ItemName,x   ; item symbol
        sta     $74fd,y
        iny
        lda     #$0e
        sta     $74fd,y
        iny
        lda     $00
        sta     $74fd,y
        iny
        lda     #$08
        sta     $00
@9e5c:  lda     f:ItemName+1,x   ; item name
        sta     $74fd,y
        iny
        inx
        dec     $00
        bne     @9e5c
        lda     $02
        bne     @9e78
        pla
        lda     #$05
        sta     $74fd,y
        iny
        lda     #$03
        bra     @9e90
@9e78:  lda     #$c8
        sta     $74fd,y
        iny
        pla
        tax
        jsr     HexToDec
        jsr     NormalizeNum
        lda     $180e
        sta     $74fd,y
        iny
        lda     $180f
@9e90:  sta     $74fd,y
        iny
        clr_a
        sta     $74fd,y
        jsr     DrawText
        rts

; ------------------------------------------------------------------------------

; [ init inventory text buffer ]

InitInventoryTextBuf:
@9e9c:  stz     $1817
@9e9f:  jsr     DrawInventoryItemText
        inc     $1817
        lda     $1817
        cmp     #$30
        bne     @9e9f
        rts

; ------------------------------------------------------------------------------

; [ battle graphics $0e: draw spell list ]

DrawMagicList:
@9ead:  lda     $00         ; character slot
        asl
        tax
        longa
        lda     f:MagicListPtrs,x   ; pointers to spell lists
        sta     $00
        lda     f:MagicListTextPtrs,x   ; pointers to spell list text buffers
        sta     $02
        clc
        adc     #$000c
        sta     $04
        shorta0
        lda     #$48
        sta     $07
; start of spell loop
@9ecc:  ldy     #$0001
        lda     ($00)
        bmi     @9edb
        lda     #$00        ; palette 0, white text
        sta     $06
        lda     #$00
        bra     @9ee3
@9edb:  lda     #$04        ; palette 1, gray text
        sta     $06
        bra     @9ee3
@9ee1:  lda     $06
@9ee3:  sta     ($02),y
        sta     ($04),y
        iny2
        cpy     #$000d
        bne     @9ee1
        longa
        lda     $02
        clc
        adc     #$0018
        sta     $02
        clc
        adc     #$000c
        sta     $04
        lda     $00
        clc
        adc     #$0004
        sta     $00
        shorta0
        dec     $07
        bne     @9ecc
        rts

; ------------------------------------------------------------------------------

; [ update enabled item text color in inventory text buffer ]

UpdateEnabledItems:
@9f0e:  lda     $1822
        sta     $1816
        stz     $1817
        jsr     DrawEquipItemText       ; right hand
        inc     $1817
        jsr     DrawEquipItemText       ; left hand
        lda     $ef9a
        beq     @9f28
        jmp     @9f65

; using item
@9f28:  clr_ayx
@9f2b:  lda     #12                     ; change font color for 12 tiles
        sta     $02
        lda     $321a,x
        bmi     @9f3c
        lda     #$00
        sta     $00
        lda     #$00
        bra     @9f44
@9f3c:  lda     #$04
        sta     $00
        bra     @9f44
@9f42:  lda     $00
@9f44:  sta     $8ea7,y
        sta     $8ebf,y
        iny2
        dec     $02
        bne     @9f42
        longa
        tya
        clc
        adc     #$0018
        tay
        shorta0
        inx4
        cpx     #$00c0
        bne     @9f2b
        rts

; using throw
@9f65:  clr_axy
@9f68:  lda     #12                     ; change font color for 12 tiles
        sta     $02
        lda     $321a,x
        and     #$04
        beq     @9f7b
        lda     #$00
        sta     $00
        lda     #$00
        bra     @9f83
@9f7b:  lda     #$04
        sta     $00
        bra     @9f83
@9f81:  lda     $00
@9f83:  sta     $8ea7,y
        sta     $8ebf,y
        iny2
        dec     $02
        bne     @9f81
        longa
        tya
        clc
        adc     #$0018
        tay
        shorta0
        inx4
        cpx     #$00c0
        bne     @9f68
        rts

; ------------------------------------------------------------------------------

; [ draw inventory item text ]

UpdateMenuText_02:
DrawInventoryItemText:
@9fa4:  ldx     #$74fd      ; init pointer to text buffer
        stx     $ef50
        lda     $1817       ; inventory slot
        sta     $26
        lda     #$30        ; 48 bytes per item slot (24 tiles)
        sta     $28
        jsr     Mult8
        longa
        lda     $2a
        clc
        adc     #$8ea6      ; inventory text buffer
        sta     $ef52
        shorta0
        lda     #$0c        ; 2 lines, 12 characters per line
        sta     $ef54
        lda     $1817
        asl2
        tax
        lda     $321b,x     ; item id
        sta     $02
        sta     $26
        lda     $321c,x     ; item quantity
        pha
        lda     #$00        ; use white palette
        sta     $00
        lda     #$00
        sta     $01
        lda     $321a,x
        and     #$80
        beq     @9fef       ; branch if not disabled
        lda     #$04        ; use gray palette
        sta     $00
        sta     $01
@9fef:  lda     #$09
        sta     $28
        jsr     Mult8
        ldx     $2a
        clr_ay
        lda     #$0e
        sta     $74fd,y
        iny
        lda     $01
        sta     $74fd,y
        iny
        lda     #$03
        sta     $74fd,y
        iny
        lda     f:ItemName,x   ; item symbol
        sta     $74fd,y
        iny
        lda     #$0e
        sta     $74fd,y
        iny
        lda     $00
        sta     $74fd,y
        iny
        lda     #$08
        sta     $00
@a024:  lda     f:ItemName+1,x   ; item name
        sta     $74fd,y
        iny
        inx
        dec     $00
        bne     @a024
        lda     $02
        bne     @a040
        pla
        lda     #$05
        sta     $74fd,y
        iny
        lda     #$03
        bra     @a064
@a040:  lda     #$c8        ; colon ":"
        sta     $74fd,y
        iny
        pla
        tax
        jsr     HexToDec
        jsr     NormalizeNum
        lda     #$03
        sta     $74fd,y
        iny
        lda     $180e
        sta     $74fd,y
        iny
        lda     #$03
        sta     $74fd,y
        iny
        lda     $180f
@a064:  sta     $74fd,y
        iny
        clr_a
        sta     $74fd,y
        jsr     DrawText
        rts

; ------------------------------------------------------------------------------

; [ init spell list text buffer ]

InitMagicListTextBuf:
@a070:  stz     $1816
@a073:  stz     $1817
@a076:  jsr     DrawMagicListName
        inc     $1817
        lda     $1817
        cmp     #$48
        bne     @a076
        inc     $1816
        lda     $1816
        cmp     #5
        bne     @a073
        rts

; ------------------------------------------------------------------------------

; [ draw spell name (spell list) ]

UpdateMenuText_03:
DrawMagicListName:
@a08e:  ldx     #$74fd
        stx     $ef50
        lda     #$06
        sta     $ef54
        lda     $1817
        sta     $26
        lda     #$18
        sta     $28
        jsr     Mult8
        lda     $1816
        asl
        tax
        lda     $1817
        longa
        asl2
        sta     $00
        lda     f:MagicListTextPtrs,x   ; pointers to spell list text buffers
        clc
        adc     $2a
        sta     $ef52
        lda     f:MagicListPtrs,x
        clc
        adc     $00
        tax
        shorta0
        lda     a:$0001,x
        sta     $26
        lda     #$00
        sta     $00
        lda     #$00
        sta     $01
        lda     a:$0000,x
        and     #$80
        beq     @a0e2
        lda     #$04
        sta     $00
        sta     $01
@a0e2:  lda     #6
        sta     $28
        jsr     Mult8
        ldx     $2a
        clr_ay
        lda     #$0e
        sta     $74fd,y
        iny
        lda     $01
        sta     $74fd,y
        iny
        lda     #$03
        sta     $74fd,y
        iny
        lda     f:MagicName,x
        sta     $74fd,y
        iny
        lda     #$0e
        sta     $74fd,y
        iny
        lda     $00
        sta     $74fd,y
        iny
        lda     #5
        sta     $00
@a117:  lda     f:MagicName+1,x
        sta     $74fd,y
        iny
        inx
        dec     $00
        bne     @a117
        clr_a
        sta     $74fd,y
        jsr     DrawText
        rts

; ------------------------------------------------------------------------------

; [ battle graphics $0c: draw hp text ]

DrawHPText:
@a12c:  lda     #$02
        jsr     GetTextBufData
        clr_ayx
        stz     $04
        stz     $06

; start of character loop
@a138:  phx
        lda     $04
        longa
        asl
        tax
        lda     f:CharPropPtrs,x        ; pointers to character data
        sta     $00
        shorta0
        plx
        jsr     CheckShowCharName
        bcs     @a165
        lda     ($00)
        beq     @a165                   ; branch if no character
        lda     #$06
        sta     $02
@a156:  lda     f:MenuText_0002,x       ; character current/max hp text
        sta     $74fd,y
        iny
        inx
        dec     $02
        bne     @a156
        bra     @a172
@a165:  longa
        txa
        clc
        adc     #$0006
        tax
        shorta0
        inc     $06
@a172:  inc     $04
        lda     $04
        cmp     #5
        bne     @a138
        lda     $06
        beq     @a194                   ; branch if there are no empty slots
@a17e:  lda     #$05
        sta     $74fd,y                 ; fill empty slots
        iny
        lda     #$09
        sta     $74fd,y
        iny
        lda     #$01
        sta     $74fd,y
        iny
        dec     $06
        bne     @a17e
@a194:  clr_a                           ; null-terminator
        sta     $74fc,y
        jsr     DrawText
        clr_ax
@a19d:  longa
        lda     f:CharPropPtrs,x
        sta     $00
        shorta0
        lda     ($00)
        bne     @a1b0                   ; find first non-empty character slot
        inx2
        bra     @a19d
@a1b0:  lda     f:CharHPTextBufPtrs,x   ; this value is unused
        lda     #$77                    ; little "hp" text
        sta     $b9e2,x
        inc
        sta     $b9e4,x
        rts

; ------------------------------------------------------------------------------

; pointers to character hp text buffers (unused)
CharHPTextBufPtrs:
@a1be:  .word   $0024,$006c,$0000,$0090,$0048

; character display order
CharOrderTbl:
@a1c8:  .byte   1,3,0,4,2

; pointers to character data
CharPropPtrs:
@a1cd:  .word   $2080,$2180,$2000,$2200,$2100

; ------------------------------------------------------------------------------

; [ battle graphics $0d: draw current/max mp ]

DrawMPText:
@a1d7:  lda     #$03        ; character current/max mp
        jsr     DrawMenuText
        clr_ax
@a1de:  lda     f:CharMPTextBufPtrs,x
        tay
        lda     #$db        ; little "mp" text
        sta     $ba94,y
        inc
        sta     $ba96,y
        inx
        cpx     #5
        bne     @a1de
        rts

; ------------------------------------------------------------------------------

; character display order
CharOrderTbl2:
@a1f3:  .byte   1,3,0,4,2

; ------------------------------------------------------------------------------

; [ check if character name/hp hidden ]

CheckShowCharName:
@a1f8:  phx
        lda     $04
        tax
        lda     f:CharOrderTbl2,x
        tax
        lda     $f2c1,x
        beq     @a209
        plx
        sec
        rts
@a209:  plx
        clc
        rts

; ------------------------------------------------------------------------------

; [ battle graphics $0a: draw character names ]

UpdateCharNames:
@a20c:  lda     #$01
        jsr     GetTextBufData
        clr_ayx
        stz     $04
        stz     $06
@a218:  phx
        lda     $04
        longa
        asl
        tax
        lda     f:CharPropPtrs,x
        sta     $00
        shorta0
        plx
        jsr     CheckShowCharName
        bcs     @a26a
        lda     ($00)
        beq     @a26a
        lda     #$0e
        sta     $74fd,y
        iny
        lda     $d7
        beq     @a251
        phx
        lda     $04
        tax
        lda     f:CharOrderTbl,x   ; character display order
        cmp     $1822
        beq     @a24c
        plx
        bra     @a251
@a24c:  plx
        lda     #$08
        bra     @a253
@a251:  lda     #$00
@a253:  sta     $74fd,y
        iny
        lda     #$03
        sta     $02
@a25b:  lda     f:MenuText_0001,x   ; character names text
        sta     $74fd,y
        iny
        inx
        dec     $02
        bne     @a25b
        bra     @a277
@a26a:  longa
        txa
        clc
        adc     #$0003
        tax
        shorta0
        inc     $06
@a277:  inc     $04
        lda     $04
        cmp     #5
        bne     @a218
        lda     $06
        beq     @a299
@a283:  lda     #$05
        sta     $74fd,y
        iny
        lda     #$06
        sta     $74fd,y
        iny
        lda     #$01
        sta     $74fd,y
        iny
        dec     $06
        bne     @a283
@a299:  clr_a
        sta     $74fc,y
        jsr     DrawText
        rts

; ------------------------------------------------------------------------------

; [ draw status text ]

; this window is shown when choosing a target for a beneficial spell or item

DrawStatusText:
@a2a1:  ldx     #$be82                  ; copy character name/hp tilemap
        stx     $00
        ldx     #$d6aa
        stx     $02
        longa
        lda     #13                     ; copy 13 rows
        sta     $06
@a2b2:  lda     #16                     ; and 16 columns
        sta     $04
        ldy     #0
@a2ba:  lda     ($00),y
        sta     ($02),y
        iny2
        dec     $04
        bne     @a2ba
        lda     $00
        clc
        adc     #$0040
        sta     $00
        lda     $02
        clc
        adc     #$0040
        sta     $02
        dec     $06
        bne     @a2b2
        shorta0
        jmp     _a2e2

; ------------------------------------------------------------------------------

; status effects shown in target select window
ShowStatusNameTbl:
@a2de:  .byte   $ff,$ff,$41,$30

; ------------------------------------------------------------------------------

; continuation from above
_a2e2:  ldx     #$d710      ; status tilemap buffer
        stx     $ef52
        clr_ax
; start of character loop
@a2ea:  phx
        lda     f:CharOrderTbl,x   ; character display order
        tay
        lda     $29c5,y
        cmp     #$ff
        bne     @a2fa
        jmp     @a37c
@a2fa:  tya
        asl2
        tay
        clr_ax
@a300:  lda     $f015,y
        and     f:ShowStatusNameTbl,x
        sta     $00,x
        iny
        inx
        cpx     #4
        bne     @a300
        clr_ax
@a312:  asl     $03
        rol     $02
        rol     $01
        rol     $00
        bcs     @a327
        inx
        cpx     #$0020
        bne     @a312
        ldy     #0
        bra     @a349
@a327:  txa
        asl
        tax
        lda     f:StatusNamePtrs,x   ; pointers to status names
        sta     $00
        lda     f:StatusNamePtrs+1,x
        sta     $01
        lda     #^StatusNamePtrs
        sta     $02
        clr_ay
@a33c:  lda     [$00],y     ; copy status name to text buffer
        beq     @a349
        sta     $74fd,y
        iny
        cpy     #8
        bne     @a33c
@a349:  cpy     #8
        beq     @a356
        lda     #$ff
        sta     $74fd,y
        iny
        bra     @a349
@a356:  clr_a
        sta     $74fd,y
        ldx     #$74fd
        stx     $ef50
        lda     #$20
        sta     $ef54
        lda     #$20
        sta     $ef55
        jsr     DrawText
        longa
        lda     $ef52       ; next character
        clc
        adc     #$0080
        sta     $ef52
        shorta0
@a37c:  plx
        inx
        cpx     #5
        beq     @a386
        jmp     @a2ea
@a386:  longa
        clr_ax
@a38a:  lda     $d6a6,x     ; tile tile priority
        ora     #$2000
        sta     $d6a6,x
        inx2
        cpx     #$0340
        bne     @a38a
        shorta0
        rts

; ------------------------------------------------------------------------------

; [ battle graphics $0b: draw monster names ]

UpdateMenuText_05:
DrawMonsterNames:
@a39e:  clr_a
        jsr     GetTextBufData
        ldx     #$29b1
        stx     $00
        ldx     #$29ca
        stx     $08
        clr_axy
        lda     #$04
        sta     $04
        stz     $06
@a3b5:  lda     ($00)
        cmp     #$ff
        beq     @a3d2       ; branch if monster type is unused
        lda     ($08)
        beq     @a3d2       ; branch if no monsters left
        lda     #$06
        sta     $02
@a3c3:  lda     f:MenuText_0000,x   ; text for monster name and count
        sta     $74fd,y
        iny
        inx
        dec     $02
        bne     @a3c3
        bra     @a3df
@a3d2:  longa
        txa
        clc
        adc     #$0006
        tax
        shorta0
        inc     $06
@a3df:  phx
        ldx     $00
        inx
        stx     $00
        ldx     $08
        inx
        stx     $08
        plx
        dec     $04
        bne     @a3b5
        lda     $06
        beq     @a409
@a3f3:  lda     #$05
        sta     $74fd,y
        iny
        lda     #$0a
        sta     $74fd,y
        iny
        lda     #$01
        sta     $74fd,y
        iny
        dec     $06
        bne     @a3f3
@a409:  clr_a
        sta     $74fc,y
        jsr     DrawText
        rts

; ------------------------------------------------------------------------------

; [ get battle menu text buffer data ]

GetTextBufData:
@a411:  pha
        sta     $26
        lda     #$06
        sta     $28
        jsr     Mult8
        ldx     $2a
        clr_ay
@a41f:  lda     f:MenuTextBufTbl,x
        sta     $ef50,y
        iny
        inx
        cpy     #6
        bne     @a41f
        pla
        rts

; ------------------------------------------------------------------------------

; [ draw battle menu text ]

DrawMenuText:
@a42f:  jsr     GetTextBufData
        asl
        tax
        lda     f:MenuTextPtrs,x
        sta     $00
        lda     f:MenuTextPtrs+1,x
        sta     $01
        lda     #$16
        sta     $02
        clr_ay
@a446:  lda     [$00],y     ; copy text to buffer
        sta     $74fd,y
        iny
        cpy     #$0020
        bne     @a446
        jsr     DrawText
        rts

; ------------------------------------------------------------------------------

; [ draw text ]

DrawText:
@a455:  lda     $ef55
        sta     $36
        asl     $ef54
        ldx     $ef50
        stx     $30
        ldx     $ef52
        stx     $32
        lda     $32
        clc
        adc     $ef54
        sta     $34
        lda     $33
        adc     #$00
        sta     $35
        ldy     #0
@a478:  lda     ($30)
        beq     @a490       ; branch if terminator
        cmp     #$0f
        bcc     @a488
        jsr     DrawLetter
        jsr     IncTextPtr
        bra     @a478
; escape codes $01-$0e
@a488:  jsr     ExecTextCmd
        jsr     IncTextPtr
        bra     @a478
@a490:  rts

; ------------------------------------------------------------------------------

; [ increment text pointer ]

IncTextPtr:
@a491:  ldx     $30
        inx
        stx     $30
        rts

; ------------------------------------------------------------------------------

; [ draw text character ]

DrawLetter:
.if !LANG_EN
@a497:  cmp     #$42
        bcc     DrawLetterWithDakuten
.endif

DrawLetterNoDakuten:
@a49b:  phx
        sta     ($34),y
        lda     #$ff
        sta     ($32),y
        iny
        lda     $36         ; tile flags
        sta     ($32),y
        sta     ($34),y
        iny
        plx
        rts

DrawLetterWithDakuten:
@a4ac:  phx
        sec
        sbc     #$0f
        asl
        tax
        lda     f:DakutenTbl,x   ; dakuten
        sta     ($32),y
        lda     f:DakutenTbl+1,x   ; kana
        sta     ($34),y
        iny
        lda     $36         ; tile flags
        sta     ($32),y
        sta     ($34),y
        iny
        plx
        rts

; ------------------------------------------------------------------------------

; text escape code jump table
TextCmdTbl:
@a4c8:  .addr   TextCmd_00
        .addr   TextCmd_01
        .addr   TextCmd_02
        .addr   TextCmd_03
        .addr   TextCmd_04
        .addr   TextCmd_05
        .addr   TextCmd_06
        .addr   TextCmd_07
        .addr   TextCmd_08
        .addr   TextCmd_09
        .addr   TextCmd_0a
        .addr   TextCmd_0b
        .addr   TextCmd_0c
        .addr   TextCmd_0d
        .addr   TextCmd_0e

; ------------------------------------------------------------------------------

; [ escape code $06: variable ]

TextCmd_06:
@a4e6:  jsr     IncTextPtr
        lda     ($30)
        bmi     @a4ee
        rts
@a4ee:  and     #$7f
        bne     @a4f8
        ldx     #$0000
        jmp     TextVar_00
@a4f8:  cmp     #$01
        bne     @a502
        ldx     #$0003
        jmp     TextVar_01
@a502:  cmp     #$02
        bne     @a509
        jmp     TextVar_02
@a509:  cmp     #$03
        bne     @a510
        jmp     TextVar_03
@a510:  cmp     #$04
        bne     TextVar_05
        jmp     TextVar_04

; ------------------------------------------------------------------------------

; [ variable type 5: status name ]

TextVar_05:
@a517:  lda     $359a
        asl
        tax
        lda     f:StatusNamePtrs,x
        sta     $00
        lda     f:StatusNamePtrs+1,x
        sta     $01
        lda     #^StatusNamePtrs
        sta     $02
@a52c:  lda     [$00]
        beq     @a53a
        jsr     DrawLetter
        ldx     $00
        inx
        stx     $00
        bra     @a52c
@a53a:  rts

; ------------------------------------------------------------------------------

; [ variable type 4: magic name ]

TextVar_04:
@a53b:  lda     $359a
        cmp     #$48
        bcc     @a565
        sec
        sbc     #$48
        sta     $26
        lda     #$08
        sta     $28
        jsr     Mult8
        ldx     $2a
        lda     #$08
        sta     $00
@a554:  lda     f:AttackName,x
        cmp     #$ff
        beq     @a564
        jsr     DrawLetter
        inx
        dec     $00
        bne     @a554
@a564:  rts
@a565:  sta     $26
        lda     #$06
        sta     $28
        jsr     Mult8
.if !LANG_EN
        ldy     #0
.endif
        ldx     $2a
        lda     f:MagicName,x
        jsr     DrawLetterNoDakuten
        lda     #$05
        sta     $00
@a57e:  lda     f:MagicName+1,x
        cmp     #$ff
        beq     @a58e
        jsr     DrawLetter
        inx
        dec     $00
        bne     @a57e
@a58e:  rts

; ------------------------------------------------------------------------------

; [ variable type 3: item name ]

TextVar_03:
@a58f:  lda     $359a
        sta     $26
        lda     #$09
        sta     $28
        jsr     Mult8
.if !LANG_EN
        ldy     #0
.endif
        ldx     $2a
        inx
        lda     #$08
        sta     $00
@a5a5:  lda     f:ItemName,x
        cmp     #$ff
        beq     @a5b5
        jsr     DrawLetter
        inx
        dec     $00
        bne     @a5a5
@a5b5:  rts

; ------------------------------------------------------------------------------

; [ variable type 2: character name ]

TextVar_02:
@a5b6:  lda     $359a
        longa
        asl7
        tax
        shorta0
        lda     $2000,x
        dec
        and     #$3f
        tax
        lda     f:CharNameTbl,x   ; name for each character

DrawCharName:
@a5d1:  sta     $26
        lda     #$06
        sta     $28
        jsr     Mult8
        lda     #$06
        sta     $00
        ldx     $2a
        inx5
@a5e5:  lda     $1500,x
        cmp     #$ff
        bne     @a5f5
        dex
        dec     $00
        lda     $00
        cmp     #$01
        bne     @a5e5
@a5f5:  ldx     $2a
@a5f7:  lda     $1500,x
        jsr     DrawLetter
        inx
        dec     $00
        bne     @a5f7
        rts

; ------------------------------------------------------------------------------

; [ variable type 0/1: battle variable ]

TextVar_00:
TextVar_01:
@a603:  lda     $359a,x
        sta     $00
        lda     $359b,x
        sta     $01
        lda     $359c,x
        sta     $02
        jsl     HexToDecVar
        jsr     NormalizeVar
@a619:  lda     $f4ad,x
        jsr     DrawLetterNoDakuten
        inx
        cpx     #8
        bne     @a619
        rts

; ------------------------------------------------------------------------------

; [ text escape code ]

ExecTextCmd:
@a626:  asl
        tax
        lda     f:TextCmdTbl,x
        sta     $00
        lda     f:TextCmdTbl+1,x
        sta     $01
        jmp     ($0000)

; ------------------------------------------------------------------------------

; [ escape code $01: newline ]

TextCmd_01:
@a637:  lda     $ef54
        longa
        pha
        asl
        clc
        adc     $32
        sta     $32
        pla
        clc
        adc     $32
        sta     $34
        clr_ay
        shorta
        rts

; ------------------------------------------------------------------------------

; [ escape code $00: string terminator (unused) ]

TextCmd_00:
@a64e:  rts

; ------------------------------------------------------------------------------

; [ escape code $04: character name (by character id) ]

TextCmd_04:
@a64f:  jsr     IncTextPtr
        lda     ($30)
        jmp     DrawCharName

; ------------------------------------------------------------------------------

; [ escape code $02: character name (by slot) ]

TextCmd_02:
@a657:  jsr     IncTextPtr
        lda     ($30)

DrawCharSlotName:
@a65c:  pha
        tax
        lda     $29c5,x
        cmp     #$ff
        bne     @a672
        ldx     #$0006
@a668:  lda     #$ff
        jsr     DrawLetter
        dex
        bne     @a668
        pla
        rts
@a672:  pla
        longa
        asl7
        tax
        shorta0
        lda     $2000,x
        dec
        and     #$3f
        tax
        lda     f:CharNameTbl,x   ; name for each character
        sta     $26
        lda     #$06
        sta     $00
        sta     $28
        jsr     Mult8
        ldx     $2a
@a698:  lda     $1500,x
        jsr     DrawLetter
        inx
        dec     $00
        bne     @a698
        rts

; ------------------------------------------------------------------------------

; [ escape code $03: borders and symbols ]

TextCmd_03:
@a6a4:  jsr     IncTextPtr
        lda     ($30)
        jmp     DrawLetterNoDakuten

; ------------------------------------------------------------------------------

; [ escape code $05: tab ]

TextCmd_05:
@a6ac:  jsr     IncTextPtr
        lda     ($30)
        sta     $00
@a6b3:  lda     #$ff
        jsr     DrawLetter
        dec     $00
        bne     @a6b3
        rts

; ------------------------------------------------------------------------------

; [ escape code $07: character 1 variable ]

TextCmd_07:
@a6bd:  ldx     #$0000
        clr_a
        bra     DrawCharVar

; ------------------------------------------------------------------------------

; [ escape code $08: character 2 variable ]

TextCmd_08:
@a6c3:  ldx     #$0080
        lda     #1
        bra     DrawCharVar

; ------------------------------------------------------------------------------

; [ escape code $09: character 3 variable ]

TextCmd_09:
@a6ca:  ldx     #$0100
        lda     #2
        bra     DrawCharVar

; ------------------------------------------------------------------------------

; [ escape code $0a: character 4 variable ]

TextCmd_0a:
@a6d1:  ldx     #$0180
        lda     #3
        bra     DrawCharVar

; ------------------------------------------------------------------------------

; [ escape code $0b: character 5 variable ]

TextCmd_0b:
@a6d8:  ldx     #$0200
        lda     #4
; fallthrough

; ------------------------------------------------------------------------------

; [ draw character variable ]

DrawCharVar:
@a6dd:  stx     $0a
        pha
        jsr     IncTextPtr
        lda     ($30)
        bne     @a6eb
; 0: character name
        pla
        jmp     DrawCharSlotName
@a6eb:  tax
        pla
        sta     $03
        txa
        ldx     $0a
; 1: current hp
        cmp     #$01
        bne     @a6fd
        stz     $02
        lda     #$07
        jmp     DrawHPNum
; 2: max hp
@a6fd:  cmp     #$02
        bne     @a708
        stz     $02
        lda     #$09
        jmp     DrawHPNum
; 3: current mp
@a708:  cmp     #$03
        bne     @a715
        lda     #1
        sta     $02
        lda     #$0b
        jmp     DrawMPNum
; 4: max mp
@a715:  cmp     #$04
        bne     @a722
        lda     #1
        sta     $02
        lda     #$0d
        jmp     DrawMPNum
; 5: invalid (infinite loop)
@a722:  jmp     @a722

; ------------------------------------------------------------------------------

; [ clear hex to decimal conversion buffer ]

; unused

ClearHexToDecBuf:
@a725:  lda     #$ff
        sta     $180c
        sta     $180d
        sta     $180e
        sta     $180f
        rts

; ------------------------------------------------------------------------------

; [ draw mp value ]

; $02: number of digits to skip (0 for hp, 1 for mp)

DrawMPNum:
@a734:  ldx     $0a
        jsr     GetStatNumText
        lda     $02
        tax
@a73c:  lda     $180c,x
        cmp     #$ff
        beq     @a746
        clc
        adc     #$6d                    ; $6d is "0" on bg2
@a746:  jsr     DrawLetterNoDakuten
        inx
        cpx     #4
        bne     @a73c
        rts

; ------------------------------------------------------------------------------

; [ draw hp value ]

DrawHPNum:
@a750:  ldx     $0a
        jsr     GetStatNumText
        lda     $02
        tax
@a758:  lda     $180c,x
        jsr     DrawLetterNoDakuten
        inx
        cpx     #4
        bne     @a758
        rts

; ------------------------------------------------------------------------------

; [ convert hp or mp value to text ]

GetStatNumText:
@a765:  longa
        stx     $00
        clc
        adc     $00
        tax
        lda     $2000,x     ; get hp/mp value
        tax
        shorta0
        jsr     HexToDec
        jmp     NormalizeNum

; ------------------------------------------------------------------------------

; [ escape code $0e: change tile flags ]

TextCmd_0e:
@a77a:  jsr     IncTextPtr
        lda     ($30)
        sta     $36
        rts

; ------------------------------------------------------------------------------

; [ escape code $0d: monster count ]

TextCmd_0d:
@a782:  jsr     IncTextPtr
        lda     ($30)
        tax
        lda     $29ca,x
        beq     @a7a9
        lda     $29b1,x
        cmp     #$ff
        beq     @a7a6
        lda     $29ca,x
        tax
        cmp     #$01
        bne     @a7a0
        lda     #$ff        ; blank if only 1 monster
        bra     @a7a6
@a7a0:  jsr     HexToDec
        lda     $1810
@a7a6:  jmp     DrawLetterNoDakuten
@a7a9:  dec
        jmp     DrawLetterNoDakuten

; ------------------------------------------------------------------------------

; [ escape code $0c: monster name ]

TextCmd_0c:
@a7ad:  jsr     IncTextPtr
        lda     ($30)
        tax
        lda     $29ca,x
        beq     @a7bf
        lda     $29b1,x
        cmp     #$ff
        bne     @a7cb
@a7bf:  ldx     #8
@a7c2:  lda     #$ff
        jsr     DrawLetterNoDakuten
        dex
        bne     @a7c2
        rts
@a7cb:  pha
        lda     $38d0,x
        beq     @a7d6
        pla
        lda     #$df
        bra     @a7d7
@a7d6:  pla
@a7d7:  longa
        asl3
        tax
        shorta0
        lda     #8
        sta     $00
@a7e4:  lda     f:MonsterName,x
        jsr     DrawLetter
        inx
        dec     $00
        bne     @a7e4
        rts

; ------------------------------------------------------------------------------

; [ set hdma data for scrolling menu list ]

UpdateListScrollHDMA:
@a7f1:  longa
        txa
        ldx     #0
@a7f7:  sta     $7f74,x
        dey
        bne     @a804
        clc
        adc     #4
        ldy     #12
@a804:  inx4
        cpx     #$00f0
        bne     @a7f7
        shorta0
        rts

; ------------------------------------------------------------------------------

; [ update hdma data for menu ]

UpdateMenuHDMA:
@a811:  lda     $1820
        longa
        asl
        tax
        lda     f:MenuHDMATbl,x
        sta     $0e
        shorta0
        jmp     ($000e)

; ------------------------------------------------------------------------------

; hdma update jump table
MenuHDMATbl:
@a824:  .addr   MenuHDMA_00
        .addr   MenuHDMA_01
        .addr   MenuHDMA_02
        .addr   MenuHDMA_03

; ------------------------------------------------------------------------------

; [ hdma update 0: none ]

MenuHDMA_00:
@a82c:  rts

; ------------------------------------------------------------------------------

; [ hide cursor 2 if it scrolls offscreen ]

CheckListCursorVisible:
@a82d:  lda     $ef73
        bne     @a842
        stz     $ef6a
        cpx     #$0094
        bcc     @a83f
        cpx     #$00d1
        bcc     @a842
@a83f:  inc     $ef6a
@a842:  rts

; ------------------------------------------------------------------------------

; [ hdma update 2: scroll menu down ]

MenuHDMA_02:
@a843:  jsr     @a846
@a846:  ldx     $ef65
        inx
        stx     $ef65
        ldy     $ef67
        dey
        sty     $ef67
        bne     @a866
        ldy     #$000c
        sty     $ef67
        ldx     $ef65
        inx4
        stx     $ef65
@a866:  jsr     UpdateListScrollHDMA
        dec     $ef64
        bne     @a872
        stz     $1820
        rts
@a872:  ldx     $ef71
        dex
        stx     $ef71
        jmp     CheckListCursorVisible

; ------------------------------------------------------------------------------

; [ hdma update 3: scroll menu up ]

MenuHDMA_03:
@a87c:  jsr     @a87f
@a87f:  ldx     $ef65
        dex
        stx     $ef65
        ldy     $ef67
        iny
        sty     $ef67
        cpy     #$000d
        bne     @a8a2
        ldy     #$0001
        sty     $ef67
        ldx     $ef65
        dex4
        stx     $ef65
@a8a2:  jsr     UpdateListScrollHDMA
        dec     $ef64
        bne     @a8ae
        stz     $1820
        rts
@a8ae:  ldx     $ef71
        inx
        stx     $ef71
        jmp     CheckListCursorVisible

; ------------------------------------------------------------------------------

; [ scroll menu list down ]

ScrollListDown:
@a8b8:  ldx     $ef71
        dex
        stx     $ef71
        lda     #$0c
        sta     $ef64
        lda     #$02
        sta     $1820
        rts

; ------------------------------------------------------------------------------

; [ scroll menu list up ]

ScrollListUp:
@a8ca:  ldx     $ef71
        inx
        stx     $ef71
        lda     #$0c
        sta     $ef64
        lda     #$03
        sta     $1820
        rts

; ------------------------------------------------------------------------------

; [ hdma update 1: open/close menu ]

MenuHDMA_01:
@a8dc:  lda     $181e
        ora     $181f
        bne     @a8ec       ; return if there is a pending vram transfer
        lda     $1844
        beq     @a8ed
        jmp     @a92d
@a8ec:  rts

; open menu
@a8ed:  longa
        lda     $183f
        sta     $0e
        lda     $1841
        sta     $10
        ldy     #$0000
@a8fc:  lda     ($0e),y     ; swap 32 bytes (8 scanlines)
        sta     $12
        lda     ($10),y
        sta     ($0e),y
        lda     $12
        sta     ($10),y
        iny2
        cpy     #$0020
        bne     @a8fc
        lda     $0e
        clc
        adc     #$0020
        sta     $183f
        lda     $10
        clc
        adc     #$0020
        sta     $1841
        shorta0
        dec     $1843
        bne     @a92c
        stz     $1820       ; menu is completely open
@a92c:  rts

; close menu
@a92d:  longa
        lda     $183f
        sta     $0e
        lda     $1841
        sta     $10
        ldy     #$0000
@a93c:  lda     ($0e),y     ; swap 32 bytes (8 scanlines)
        pha
        lda     ($10),y
        sta     ($0e),y
        pla
        sta     ($10),y
        iny2
        cpy     #$0020
        bne     @a93c
        lda     $0e
        sec
        sbc     #$0020
        sta     $183f
        lda     $10
        sec
        sbc     #$0020
        sta     $1841
        shorta0
        dec     $1843
        bne     @a96a
        stz     $1820
@a96a:  rts

; ------------------------------------------------------------------------------

; [ open/close menu window ]

; A: window id

OpenCloseWindow:
@a96b:  sta     $1c
        lda     #6
        sta     $1e
        jsr     MultHW
        ldx     $20
        ldy     #0
@a979:  lda     f:MenuHDMAProp,x
        sta     $183f,y
        inx
        iny
        cpy     #6
        bne     @a979
        lda     #$01
        sta     $1820
        rts

; ------------------------------------------------------------------------------

; [ open mp cost window ]

OpenMPWindow:
@a98d:  ldx     #0
        stx     $5f
        stx     $ef85
        stz     $63
        lda     #$80
        tsb     $4a
        lda     #$08
        jsr     OpenCloseWindow
        lda     #$08                    ; mp cost
        sta     $181e
        rts

; ------------------------------------------------------------------------------

; [ close mp cost window ]

CloseMPWindow:
@a9a6:  lda     #$80
        trb     $4a
        lda     #$09
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ open defend window (position 1) ]

OpenDefendWindow1:
@a9af:  lda     #$01
        tsb     $4b
        lda     #$0a
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ close defend window (position 1) ]

CloseDefendWindow1:
@a9b8:  lda     #$01
        trb     $4b
        lda     #$0b
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ open defend window (position 2) ]

OpenDefendWindow2:
@a9c1:  lda     #$02
        tsb     $4b
        lda     #$0c
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ close defend window (position 2) ]

CloseDefendWindow2:
@a9ca:  lda     #$02
        trb     $4b
        lda     #$0d
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ open defend window (position 3) ]

OpenDefendWindow3:
@a9d3:  lda     #$04
        tsb     $4b
        lda     #$0e
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ close defend window (position 3) ]

CloseDefendWindow3:
@a9dc:  lda     #$04
        trb     $4b
        lda     #$0f
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ open defend window (position 4) ]

OpenDefendWindow4:
@a9e5:  lda     #$08
        tsb     $4b
        lda     #$10
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ close defend window (position 4) ]

CloseDefendWindow4:
@a9ee:  lda     #$08
        trb     $4b
        lda     #$11
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ open defend window (position 5) ]

OpenDefendWindow5:
@a9f7:  lda     #$10
        tsb     $4b
        lda     #$12
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ close defend window (position 5) ]

CloseDefendWindow5:
@aa00:  lda     #$10
        trb     $4b
        lda     #$13
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ open row window (position 1) ]

OpenRowWindow1:
@aa09:  lda     #$01
        tsb     $4c
        lda     #$14
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ close row window (position 1) ]

CloseRowWindow1:
@aa12:  lda     #$01
        trb     $4c
        lda     #$15
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ open row window (position 2) ]

OpenRowWindow2:
@aa1b:  lda     #$02
        tsb     $4c
        lda     #$16
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ close row window (position 2) ]

CloseRowWindow2:
@aa24:  lda     #$02
        trb     $4c
        lda     #$17
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ open row window (position 3) ]

OpenRowWindow3:
@aa2d:  lda     #$04
        tsb     $4c
        lda     #$18
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ close row window (position 3) ]

CloseRowWindow3:
@aa36:  lda     #$04
        trb     $4c
        lda     #$19
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ open row window (position 4) ]

OpenRowWindow4:
@aa3f:  lda     #$08
        tsb     $4c
        lda     #$1a
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ close row window (position 4) ]

CloseRowWindow4:
@aa48:  lda     #$08
        trb     $4c
        lda     #$1b
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ open row window (position 5) ]

OpenRowWindow5:
@aa51:  lda     #$10
        tsb     $4c
        lda     #$1c
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ close row window (position 5) ]

CloseRowWindow5:
@aa5a:  lda     #$10
        trb     $4c
        lda     #$1d
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ open char/monster name window ]

OpenNameWindow:
@aa63:  lda     #$01
        tsb     $4a
        clr_a
        jsr     OpenCloseWindow
        lda     #$02        ; main menu
        sta     $181e
        rts

; ------------------------------------------------------------------------------

; [ close char/monster name window ]

; unused

CloseNameWindow:
@aa71:  lda     #$01
        trb     $4a
        lda     #$01
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ open command list window ]

OpenCmdWindow:
@aa7a:  ldx     #0
        stx     $5f
        lda     #$02
        tsb     $4a
        lda     #$02
        jsr     OpenCloseWindow
        lda     #$03                    ; battle command list
        sta     $181e
        lda     $38bd
        bne     @aaa9
        lda     $1822
        tax
        lda     f:$0016b9,x             ; controller for this character
        beq     @aaa0
        lda     #$19
        bra     @aaa2
@aaa0:  lda     #$18
@aaa2:  sta     $1e00
        jsl     ExecSound_ext
@aaa9:  lda     #$01
        sta     $1823
        rts

; ------------------------------------------------------------------------------

; [ close command list window ]

CloseCmdWindow:
@aaaf:  lda     #$02
        trb     $4a
        lda     #$03
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ reset menu list scroll hmda data ]

ResetListScrollHDMA:
@aab8:  ldx     #$0173
        stx     $ef65
        ldy     #$000c
        sty     $ef67
        longa
        txa
        ldx     #0
@aaca:  sta     $81f4,x
        dey
        bne     @aad7
        clc
        adc     #4
        ldy     #12
@aad7:  inx4
        cpx     #$00f0
        bne     @aaca
        shorta0
        rts

; ------------------------------------------------------------------------------

; [ open inventory window ]

OpenInventoryWindow:
@aae4:  stz     $ef75
        jsr     ResetListScrollHDMA
        ldx     #0
        stx     $5f
        stx     $ef85
        stz     $63
        lda     #$04
        tsb     $4a
        lda     #$04
        jsr     OpenCloseWindow
        lda     #$07                    ; inventory
        sta     $181e
        jmp     PauseBattleWait

; ------------------------------------------------------------------------------

; [ pause battle (delay mode) ]

PauseBattleDelay:
@ab05:  lda     $16be
        cmp     #$02
        bne     @ab11
        lda     #$09        ; wait 9 frames, then pause battle
        sta     $f4ac
@ab11:  rts

; ------------------------------------------------------------------------------

; [ unpause battle (delay mode) ]

UnpauseBattleDelay:
@ab12:  lda     $16be
        cmp     #$02
        bne     @ab1f
        stz     $f4ac
        stz     $38da
@ab1f:  rts

; ------------------------------------------------------------------------------

; [ pause battle (wait mode) ]

PauseBattleWait:
@ab20:  lda     $16be
        bne     @ab28
        inc     $38da
@ab28:  rts

; ------------------------------------------------------------------------------

; [ unpause battle (wait mode) ]

UnpauseBattleWait:
@ab29:  lda     $16be
        bne     @ab31
        stz     $38da
@ab31:  rts

; ------------------------------------------------------------------------------

; [  ]

CloseInventoryWindow:
@ab32:  lda     #$04
        trb     $4a
        jsr     UnpauseBattleWait
        lda     #$05
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ open equipment window ]

OpenEquipWindow:
@ab3e:  lda     #$08
        tsb     $4a
        lda     #$06
        jsr     OpenCloseWindow
        lda     #$09        ; equipped items
        sta     $181e
        rts

; ------------------------------------------------------------------------------

; [ close equipment window ]

CloseEquipWindow:
@ab4d:  stz     $ef74
        lda     #$08
        trb     $4a
        lda     #$07
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ open white magic spell list ]

OpenWhiteMagicWindow:
@ab59:  jsr     ResetListScrollHDMA
        lda     #$10
        tsb     $4a
        lda     #$04
        jsr     OpenCloseWindow
        lda     #$04        ; white magic spell list
        sta     $181e
        jmp     PauseBattleWait

; ------------------------------------------------------------------------------

; [ close white magic spell list ]

CloseWhiteMagicWindow:
@ab6d:  lda     #$10
        trb     $4a
        jsr     UnpauseBattleWait
        lda     #$05
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ open black magic spell list ]

OpenBlackMagicWindow:
@ab79:  jsr     ResetListScrollHDMA
        lda     #$20
        tsb     $4a
        lda     #$04
        jsr     OpenCloseWindow
        lda     #$05        ; black magic/ninjutsu spell list
        sta     $181e
        jsr     PauseBattleWait
        rts

; ------------------------------------------------------------------------------

; [ close black magic spell list ]

CloseBlackMagicWindow:
@ab8e:  lda     #$20
        trb     $4a
        jsr     UnpauseBattleWait
        lda     #$05
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ open summon spell list ]

OpenSummonMagicWindow:
@ab9a:  jsr     ResetListScrollHDMA
        lda     #$40
        tsb     $4a
        lda     #$04
        jsr     OpenCloseWindow
        lda     #$06        ; summon spell list
        sta     $181e
        jmp     PauseBattleWait

; ------------------------------------------------------------------------------

; [ close summon spell list ]

CloseSummonMagicWindow:
@abae:  lda     #$40
        trb     $4a
        jsr     UnpauseBattleWait
        lda     #$05
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ open status window ]

OpenStatusWindow:
@abba:  lda     #$80
        tsb     $4d
        lda     #$1e
        jsr     OpenCloseWindow
        lda     #$0c        ; status window
        sta     $181e
        rts

; ------------------------------------------------------------------------------

; [ close status window ]

CloseStatusWindow:
@abc9:  lda     #$80
        trb     $4d
        lda     #$1f
        jmp     OpenCloseWindow

; ------------------------------------------------------------------------------

; [ battle graphics $01: close menu ]

CloseMenu:
@abd2:  lda     #$01
        sta     $f0ae
        lda     #$02
        sta     $f0b4
        rts

; ------------------------------------------------------------------------------

; [ battle graphics $00: open menu ]

OpenMenu:
@abdd:  lda     #$01
        sta     $d7
        jsr     UpdateCharNames
        stz     $f0ae
        lda     $1822
        tax
        stz     $f099,x
        lda     #$01
        sta     $f0b4
        rts

; ------------------------------------------------------------------------------
