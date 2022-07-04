
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: menu.asm                                                             |
; |                                                                            |
; | description: menu program                                                  |
; |                                                                            |
; | created: 3/15/2022                                                         |
; +----------------------------------------------------------------------------+

.p816

.include "const.inc"
.include "hardware.inc"
.include "macros.inc"

.include .sprintf("text/menu_text_%s.inc", LANG_SUFFIX)
.include "menu_data.asm"

.import Battle_ext
.import ExecSound_ext

.import ItemName

.import MiscBattleGfx
.import MapSpritePal
.import BattleCharGfx, BattleCharPal

; function exports
.export MainMenu_ext, NamingwayMenu_ext, ShopMenu_ext, GameLoadMenu_ext
.export InitCtrl_ext, FatChocoMenu_ext, NamingwayMenu_ext2
.export UpdateCtrlField_ext, TreasureMenu_ext, FatChocoMenu_ext2
.export UpdateCtrlBattle_ext

.export menu_dp

; ------------------------------------------------------------------------------

.export WindowGfx, WindowPal

; 0a/f000
.segment "window_gfx"
        .include .sprintf("gfx/window_gfx_%s.asm", LANG_SUFFIX)

; 0d/86d0
.segment "menu_pal"
        .include "gfx/portrait_pal.asm"

; 0d/87d0
        .include "gfx/window_pal.asm"

; 1d/d3c0
.segment "portrait_gfx"
        .include "gfx/portrait_gfx.asm"

; ------------------------------------------------------------------------------

.segment "menu_dp"

menu_dp:

; ------------------------------------------------------------------------------

.segment "menu_code"

; ------------------------------------------------------------------------------

MainMenu_ext:
@8000:  jsr     MainMenu
        rtl

NamingwayMenu_ext:
@8004:  jsr     NamingwayMenu
        rtl

ShopMenu_ext:
@8008:  jsr     ShopMenu
        rtl

GameLoadMenu_ext:
@800c:  jsr     GameLoadMenu
        rtl

UpdateCtrlField_ext:
@8010:  jsr     UpdateCtrlField
        rtl

FatChocoMenu_ext:
@8014:  jsr     FatChocoMenu
        rtl

NamingwayMenu_ext2:
@8018:  jsr     NamingwayMenu
        rtl

InitCtrl_ext:
@801c:  jsr     InitCtrl_far
        rtl

TreasureMenu_ext:
@8020:  jsr     TreasureMenu
        rtl

FatChocoMenu_ext2:
@8024:  jsr     FatChocoMenu
        rtl

UpdateCtrlBattle_ext:
@8028:  jsr     UpdateCtrlBattle
        rtl

; ------------------------------------------------------------------------------

; [ main menu ]

.a8
.i16

MainMenu:
@802c:  phb
        phd
        tdc
.if BUGFIX_MISC_MENU
        sta     f:hNMITIMEN
.else
        sta     f:$004100     ; *** bug, should be $4200 ***
.endif
        lda     #$7e
        pha
        plb
        jsr     InitMainMenu
        lda     #$80
        sta     f:hINIDISP     ; screen off
        tdc
        xba
        pld
        plb
        rts

; ------------------------------------------------------------------------------

; [ init main menu ]

InitMainMenu:
@8045:  jsr     SaveDlgGfx_far
        jsr     InitMenu
        tsx
        dex2
        stx     $1a65       ; save stack pointer
        jsr     MainMenuMain
        jsr     FadeOut
        jmp     RestoreDlgGfx_far

; ------------------------------------------------------------------------------

; [ battle ]

; *** unused ***
Battle:
@805a:  jml     Battle_ext

; ------------------------------------------------------------------------------

; [ update controller (field) ]

UpdateCtrlField:
@805e:  pha
        lda     #0
        sta     f:$000140                     ; disable multi-controller update
        jsl     UpdateCtrl_ext
        lda     #0
        xba
        pla
        rts

; ------------------------------------------------------------------------------

; [ update controller (battle) ]

UpdateCtrlBattle:
@806e:  pha
        jsl     UpdateCtrl_ext
        lda     #0
        xba
        pla
        rts

; ------------------------------------------------------------------------------

; [ transfer data to vram ]

;  +$011d: destination address (vram)
; ++$011f: source address
;  +$0122: size

TfrVRAM:
@8078:  phb
        tdc
        pha
        plb
        lda     #$80
        sta     hVMAINC
        tdc
        sta     hHDMAEN     ; disable hdma
        ldy     $011d
        sty     hVMADDL     ; destination address (vram)
        lda     #$01
        sta     $4300
        lda     #<hVMDATAL
        sta     $4301
        longa
        lda     $011f       ; source address
        sta     $4302
        lda     $0121
        sta     $4304
        shorta
        lda     $0123
        sta     $4306
        lda     #$01
        sta     hMDMAEN
        plb
        rts

; ------------------------------------------------------------------------------

; [ transfer palettes to ppu ]

TfrPal:
@80b2:  phd
        ldx     #$4300
        phx
        pld
        tdc
        sta     f:hCGADD
        sta     $00
        lda     #<hCGDATA
        sta     $01
        ldx     #$a000
        stx     $02
        lda     #$7e
        sta     $04
        ldx     #$0200
        stx     $05
        lda     #$01
        sta     f:hMDMAEN
        pld
        rts

; ------------------------------------------------------------------------------

; [ draw window ]

; +y: window data pointer (bank 01)

DrawWindow:
@80d9:  phy
        phb
        phk
        plb
        longa
        lda     a:$0000,y     ; tilemap buffer
        sta     $2b
        lda     a:$0002,y     ; window size
        sta     $2d
        shorta
        lda     $34         ; tile flags
        sta     $2f
        plb
        jsr     DrawWindowTiles
        ply
        rts

; ------------------------------------------------------------------------------

; [ draw window tilemap to buffer ]

DrawWindowTiles:
@80f5:  longa
        lda     $29
        clc
        adc     $2b
        tay
        lda     $2d
        sta     $31
        shorta
        lda     #$f7
        jsr     @811c
        pha
        lda     $33
        beq     @810f
        pla
        rts
@810f:  pla
@8110:  jsr     @8152
        dec     $32
        bne     @8110
        lda     #$fc
        jmp     @811c
@811c:  phy
        sta     $30
        lda     $30
        sta     a:$0000,y
        iny
        lda     $2f
        sta     a:$0000,y
        iny
        lda     $2d
        sta     $31
        inc     $30
@8131:  lda     $30
        sta     a:$0000,y
        iny
        lda     $2f
        sta     a:$0000,y
        iny
        dec     $31
        bne     @8131
        inc     $30
        lda     $30
        sta     a:$0000,y
        iny
        lda     $2f
        sta     a:$0000,y
        ply
        jmp     NextRowY
@8152:  phy
        sta     $30
        lda     #$fa
        sta     a:$0000,y
        iny
        lda     $2f
        sta     a:$0000,y
        iny
        lda     $2d
        sta     $31
        inc     $30
@8167:  lda     #$ff
        sta     a:$0000,y
        iny
        lda     $2f
        sta     a:$0000,y
        iny
        dec     $31
        bne     @8167
        lda     #$fb
        sta     a:$0000,y
        iny
        lda     $2f
        sta     a:$0000,y
        ply
        jmp     NextRowY

; ------------------------------------------------------------------------------

; [ wait for vblank (far) ]

WaitVblank_far:
@8186:  jsr     WaitVblank
        rtl

; ------------------------------------------------------------------------------

; [ wait for vblank ]

WaitVblank:
@818a:  pha
        inc     $16a3       ; increment game time
        lda     $16a3
        cmp     #$3c
        bcc     @81a5
        stz     $16a3
        inc     $16a4
        bne     @81a5
        inc     $16a5
        bne     @81a5
        inc     $16a6
@81a5:  lda     f:hRDNMI     ; wait for vblank
        and     #$80
        bne     @81a5
@81ad:  lda     f:hRDNMI
        and     #$80
        beq     @81ad
        lda     $88
        sta     f:hINIDISP     ; set screen brightness
        pla
        rts

; ------------------------------------------------------------------------------

; [ convert hex to decimal (2 digits) ]

HexToDec2:
@81bd:  stz     $45
@81bf:  sec
        sbc     #$0a
        bcc     @81c8
        inc     $45
        bra     @81bf
@81c8:  adc     #$8a
        xba
        lda     $45
        bne     @81d2
        lda     #$ff
        rts
@81d2:  clc
        adc     #$80
        rts

; ------------------------------------------------------------------------------

; [ convert hex to decimal (4 digits) ]

; +a: value to convert
; $5a-$5e: decimal text

HexToDec4:
@81d6:  phx
        phy
        longa
        ldx     #$007f
        stx     $5a
@81df:  inc     $5a
        sec
        sbc     #$03e8
        bpl     @81df
        clc
        adc     #$03e8
        phd
        ldx     #$4200
        phx
        pld
        sta     $04
        shorta
        lda     #$64
        sta     $06
        jsr     WaitMult
        lda     $14
        clc
        adc     #$80
        sta     f:$00015b
        lda     $16
        sta     $04
        tdc
        sta     $05
        lda     #$0a
        sta     $06
        jsr     WaitMult
        lda     $14
        clc
        adc     #$80
        sta     f:$00015d
        lda     $16
        pld
        clc
        adc     #$80
        sta     $5e
        lda     $5a
        cmp     #$80
        bne     @8242
        lda     #$ff
        sta     $5a
        lda     $5b
        cmp     #$80
        bne     @8242
        lda     #$ff
        sta     $5b
        lda     $5d
        cmp     #$80
        bne     @8242
        lda     #$ff
        sta     $5d
@8242:  ply
        plx
        rts

; ------------------------------------------------------------------------------

; [ wait for hardware multiply ]

WaitMult:
@8245:  nop6
        rts

; ------------------------------------------------------------------------------

; [ transfer sprite data to ppu ]

TfrSpritesVblank:
@824c:  jsr     WaitVblank
TfrSprites:
@824f:  phx
        phd
        ldx     #$4300
        phx
        pld
        tdc
        sta     f:hOAMADDL
        sta     f:hOAMADDH
        sta     $00
        lda     #$04
        sta     $01
        ldx     #$0300
        stx     $02
        lda     #$00
        sta     $04
        ldx     #$0220
        stx     $05
        lda     #$01
        sta     f:hMDMAEN
        pld
        plx
        rts

; ------------------------------------------------------------------------------

; [ draw cursor sprite ]

; $3f: --oo---- sprite priority
; $45: x position
; $46: y position

; cursor 2
DrawCursor2:
@827c:  ldy     #$0310
        bra     DrawCursorBtnMap

; cursor 1
DrawCursor1:
@8281:  ldy     #$0300                  ; +y: pointer to sprite data

DrawCursorBtnMap:
@8284:  ldx     $45

DrawCursor:
@8286:  lda     #$0a
        phb
        pha
        lda     #$7e
        pha
        plb
        pla
        sta     a:$0002,y
        longa
        txa
        shorta
        sta     a:$0000,y
        xba
        sta     a:$0001,y
        lda     $3f
        sta     a:$0003,y
        plb
        rts

; ------------------------------------------------------------------------------

; [ update controller after scrolling the inventory ]

; called after scrolling the inventory up or down
; set carry if player pressed left/right while scrolling
; otherwise, update the controller

UpdateCtrlAfterScroll:
@82a5:  lda     $01
        and     #JOY_LEFT|JOY_RIGHT
        bne     @82b4
        jsr     UpdateCtrlMenu
        lda     $03
        sta     $01
        clc
        rts
@82b4:  sec
        rts

; ------------------------------------------------------------------------------

; [ update controller ]

UpdateCtrl_far:
@82b6:  jsl     UpdateCtrl_ext
        rts

; ------------------------------------------------------------------------------

; [ init controller ]

InitCtrl_far:
@82bb:  jsl     InitCtrl_ext2
        rts

; ------------------------------------------------------------------------------

; [ update controller (w/ sound effect) ]

UpdateCtrlMenu:
@82c0:  jsr     UpdateCtrl_far
        lda     $00
        ora     $01
        beq     @82cc
        jsr     CursorSfx
@82cc:  rts

; ------------------------------------------------------------------------------

; [ draw text ]

; +x: destination offset
; +y: source address (bank 01)

DrawMenuText:
@82cd:  phb
        phd
        phx
        phx
        ldx     #$0100
        phx
        pld
        plx
        phk
        plb
        longa
        txa
        clc
        adc     $29
        tax
        shorta
        bra     DrawTextString

; ------------------------------------------------------------------------------

; [ draw text (any bank) ]

; +x: destination offset
; +y: source address
;  a: source bank

DrawText:
@82e4:  phb
        phd
        phx
        phx
        ldx     #$0100
        phx
        pld
        plx
        pha
        plb
        longa
        txa
        clc
        adc     $29
        tax
        shorta
        bra     DrawTextString

; ------------------------------------------------------------------------------

; [ draw window and text ]

DrawWindowText:
@82fb:  jsr     DrawWindow
        jsr     Iny_4
; fallthrough

; ------------------------------------------------------------------------------

; [ draw positioned text ]

; +y: source address

DrawPosText:
@8301:  phb
        phd
        phx
        ldx     #$0100
        phx
        pld
        phk
        plb
_830b:  longa
        lda     a:$0000,y
        clc
        adc     $29
        tax
        shorta
        iny2
; fallthrough

; ------------------------------------------------------------------------------

; [ draw null-terminated string ]

DrawTextString:
@8318:  lda     a:$0000,y
        beq     @8332       ; branch if terminator
        iny
        cmp     #$01
        beq     _830b       ; branch if newline
        jsr     GetDakuten
        sta     $7e0000,x   ; dakuten
        xba
        sta     $7e0040,x   ; kana
        inx2
        bra     @8318
@8332:  plx
        pld
        plb
        rts

; ------------------------------------------------------------------------------

; [ wait for keypress ]

WaitKeypress:
@8336:  pha
        phx
        phy
        phb
@833a:  jsr     WaitVblank
        jsr     UpdateCtrlMenu
        lda     $00
        ora     $01
        beq     @833a
        plb
        ply
        plx
        pla
        rts

; ------------------------------------------------------------------------------

; [ do jump table ]

;  a: index
; +x: jump table address

ExecJumpTbl:
@834b:  sta     $1d
        stz     $1e
        phk
        pla
        sta     $011f
        longa
        lda     $1d
        stx     $1d
        asl
        adc     $1d
        sta     $1d
        lda     [$1d]
        sta     $0120
        shorta
        jmp     ($0120)

; ------------------------------------------------------------------------------

; [ draw 2-digit number ]

DrawNum2:
@8369:  jsr     HexToDec2
        longa
        pha
        tya
        clc
        adc     $29
        tay
        pla
        shorta
        sta     a:$0000,y
        xba
        sta     a:$0002,y
        rts

; ------------------------------------------------------------------------------

; [ draw 4-digit number ]

DrawNum4:
@837f:  xba
        lda     #0
        xba

_018383:
@8383:  php
        phx
        shorta
        phy
        jsr     HexToDec4
        longa
        pla
        clc
        adc     $29
        tay
        shorta
        lda     $5a
        sta     a:$0000,y
        lda     $5b
        sta     a:$0002,y
        lda     $5d
        sta     a:$0004,y
        lda     $5e
        sta     a:$0006,y
        plx
        plp
        rts

; ------------------------------------------------------------------------------

; [ draw character name ]

DrawCharName:
@83ab:  and     #$3f
        bne     @83b0
        rts
@83b0:  dec
        jsr     Tax16
        lda     f:CharNameTbl,x   ; name for each character
        asl
        sta     $45
        asl
        adc     $45
        jsr     Tax16
        longa
        tya
        clc
        adc     $29
        tay
        shorta
        lda     #$06
        sta     $45
@83ce:  lda     $1500,x     ; character names
        inx
        jsr     GetDakuten
        sta     a:$0000,y     ; dakuten
        xba
        sta     a:$0040,y     ; kana
        iny2
        dec     $45
        bne     @83ce
        rts

; ------------------------------------------------------------------------------

; [ open window ]

OpenWindow:
@83e3:  lda     #$19
        sta     $45
        ldx     $35
        stx     $1d         ; destination address (vram)
        ldx     $29
        stx     $1f         ; source address
        lda     #$7e
        sta     $21
        ldx     #$0080      ; size
        stx     $22
@83f8:  jsr     WaitVblank
        jsr     TfrVRAM
        longa
        lda     $1d
        clc
        adc     #$0040
        sta     $1d
        lda     $1f
        clc
        adc     #$0080
        sta     $1f
        shorta
        dec     $45
        bne     @83f8
        rts

; ------------------------------------------------------------------------------

; [ close window ]

CloseWindow:
@8417:  lda     #$19
        sta     $45
        longa
        lda     $35
        clc
        adc     #$0600
        sta     $1d         ; destination address (vram)
        lda     $29
        clc
        adc     #$0c00
        sta     $1f         ; source address
        shorta
        lda     #$7e
        sta     $21
        ldx     #$0080
        stx     $22         ; size
; start of frame loop
@8438:  jsr     WaitVblank
        jsr     TfrVRAM
        longa
        lda     $1d
        sec
        sbc     #$0040      ; next row (move up)
        sta     $1d
        lda     $1f
        sec
        sbc     #$0080
        sta     $1f
        shorta
        dec     $45
        bne     @8438
        rts

; ------------------------------------------------------------------------------

; name for each character (see 16/fb3f for battle)
CharNameTbl:
@8457:  .byte   $00,$01,$02,$03,$04,$05,$06,$07,$08,$03,$00,$03,$06,$09,$01,$05
        .byte   $02,$0a,$0b,$01,$0c,$0d

; ------------------------------------------------------------------------------

; [ select bg3 ]

; select and clear
SelectClearBG3:
@846d:  jsr     ClearBG3Tiles
; select only
SelectBG3:
@8470:  pha
        phx
        ldx     #$d600      ; bg3 screen buffer
        stx     $29
        ldx     #$7000      ; bg3 tilemap (vram)
        stx     $35
        lda     #$03
        sta     $c3
        stz     $34         ; low priority
        plx
        pla
        rts

; ------------------------------------------------------------------------------

; [ select bg4 ]

; select and clear
SelectClearBG4:
@8485:  jsr     ClearBG4Tiles
; select only
SelectBG4:
@8488:  pha
        phx
        ldx     #$c600      ; bg4 screen buffer
        stx     $29
        ldx     #$7800      ; bg4 tilemap (vram)
        stx     $35
        lda     #$02
        sta     $c3
        lda     #$20
        sta     $34         ; high priority
        plx
        pla
        rts

; ------------------------------------------------------------------------------

; [ select bg1 ]

; select and clear
SelectClearBG1:
@849f:  jsr     ClearBG1Tiles
; select only
SelectBG1:
@84a2:  pha
        phx
        ldx     #$b600      ; bg1 screen buffer
        stx     $29
        ldx     #$6000      ; bg1 tilemap (vram)
        stx     $35
        lda     #$01
        sta     $c3
        stz     $34         ; low priority
        plx
        pla
        rts

; ------------------------------------------------------------------------------

; [ select bg2 ]

; select and clear
SelectClearBG2:
@84b7:  jsr     ClearBG2Tiles
; select only
SelectBG2:
@84ba:  pha
        phx
        ldx     #$a600      ; bg2 screen buffer
        stx     $29
        ldx     #$6800      ; bg2 tilemap (vram)
        stx     $35
        tdc
        sta     $c3
        lda     #$20
        sta     $34         ; high priority
        plx
        pla
        rts

; ------------------------------------------------------------------------------

; [ transform window ]

; +y: pointer to current window data (bank 01)
; +x: pointer to new window data (bank 01)

; $63 window left position (current)
; $64 window top position (current)
; $65 window right position (current)
; $66 window bottom position (current)
; $67 window left position (target)
; $68 window top position (target)
; $69 window right position (target)
; $6a window bottom position (target)

TransformWindow:
@84d0:  phb
        phk
        plb
        lda     a:$0000,y
        and     #$3f
        lsr
        sta     $63
        lda     a:$0002,y
        clc
        adc     $63
        inc
        sta     $65
        longa
        lda     a:$0000,y
        lsr6
        shorta
        sta     $64
        lda     a:$0003,y
        clc
        adc     $64
        inc
        sta     $66
        lda     a:$0000,x
        and     #$3f
        lsr
        sta     $67
        lda     a:$0002,x
        clc
        adc     $67
        inc
        sta     $69
        longa
        lda     a:$0000,x
        lsr6
        shorta
        sta     $68
        lda     a:$0003,x
        clc
        adc     $68
        inc
        sta     $6a
        plb
; start of frame loop
@8526:  lda     $64
        cmp     $68
        beq     @852f
        jsr     ChangeWindowTop
@852f:  lda     $66
        cmp     $6a
        beq     @8538
        jsr     ChangeWindowBtm
@8538:  lda     $63
        cmp     $67
        beq     @8541
        jsr     ChangeWindowLeft
@8541:  lda     $65
        cmp     $69
        beq     @854a
        jsr     ChangeWindowRight
@854a:  lda     $c2
        beq     @855e       ; branch if done scrolling
        dec     $c2
        ldy     #$0008      ; loop over 4 bgs, h-scroll and v-scroll
        ldx     $41         ; zero
@8555:  jsr     UpdateBGScroll
        inx3
        dey
        bne     @8555
@855e:  jsr     $01cf       ; draw sprites
        jsr     WaitVblank
        lda     $c3         ; menu window bg index
        ldx     #.loword(TfrBGTilesTbl)
        jsr     ExecJumpTbl
        jsr     $01cc       ; clear sprite data
        jsr     UpdateScrollRegs_far
        ldx     $63
        cpx     $67
        bne     @8526       ; branch if left/top position doesn't match
        ldx     $65
        cpx     $69
        bne     @8526       ; branch if right/bottom position doesn't match
        lda     $01c2
        bne     @8526       ; branch if not done scrolling
        ldx     #.loword(@858c)
        stx     $01cd
        stx     $01d0
@858c:  rts

; ------------------------------------------------------------------------------

; [ update bg scroll position ]

UpdateBGScroll:
@858d:  lda     $a2,x
        bpl     @85a8       ; branch if positive scroll rate
        longa
        lda     $a1,x
        and     #$7fff
        sta     $1d
        lda     $89,x
        sec
        sbc     $1d
        sta     $89,x
        shorta
        bcs     @85a7
        dec     $8b,x
@85a7:  rts
@85a8:  longa
        lda     $89,x
        clc
        adc     $a1,x
        sta     $89,x
        shorta
        bcc     @85b7
        inc     $8b,x
@85b7:  rts

; ------------------------------------------------------------------------------

; jump table to transfer screen buffer to vram
TfrBGTilesTbl:
@85b8:  .addr   TfrBG2Tiles
        .addr   TfrBG1Tiles
        .addr   TfrBG4Tiles
        .addr   TfrBG3Tiles

; ------------------------------------------------------------------------------

; [ change top of window ]

ChangeWindowTop:
@85c0:  bcc     @85ca
        jsr     DrawWindowRowMidTop
        dec     $64
        jmp     DrawWindowRowTop
@85ca:  jsr     HideWindowRowTop
        inc     $64
        jmp     DrawWindowRowTop

; ------------------------------------------------------------------------------

; [ change bottom of window ]

ChangeWindowBtm:
@85d2:  bcc     @85dc
        jsr     HideWindowRowBtm
        dec     $66
        jmp     DrawWindowRowBtm
@85dc:  jsr     DrawWindowRowMidBtm
        inc     $66
        jmp     DrawWindowRowBtm

; ------------------------------------------------------------------------------

; [ change left side of window ]

ChangeWindowLeft:
@85e4:  bcc     @85ee
        jsr     DrawWindowColMidLeft
        dec     $63
        jmp     DrawWindowColLeft
@85ee:  jsr     HideWindowColLeft
        inc     $63
        jmp     DrawWindowColLeft

; ------------------------------------------------------------------------------

; [ change right side of window ]

ChangeWindowRight:
@85f6:  bcc     @8600
        jsr     HideWindowColRight
        dec     $65
        jmp     DrawWindowColRight
@8600:  jsr     DrawWindowColMidRight
        inc     $65
        jmp     DrawWindowColRight

; ------------------------------------------------------------------------------

; [ get pointer to window tilemap buffer ]

; top left corner
GetWindowPtrTopLeft:
@8608:  lda     $63
        asl
        sta     $43
        lda     $64
        bra     _8621

; bottom left corner
GetWindowPtrBtmLeft:
@8611:  lda     $63
        asl
        sta     $43
        lda     $66
        bra     _8621

; top right corner
GetWindowPtrTopRight:
@861a:  lda     $65
        asl
        sta     $43
        lda     $64
_8621:  xba
        lda     #0
        longa
        lsr2
        clc
        adc     $43
        clc
        adc     $29                     ; add tilemap offset
        tax
        shorta
        rts

; ------------------------------------------------------------------------------

; [ draw window row (middle) ]

DrawWindowRowMidBtm:
@8632:  jsr     GetWindowPtrBtmLeft
        bra     _863a

DrawWindowRowMidTop:
@8637:  jsr     GetWindowPtrTopLeft
_863a:  lda     $65
        sec
        sbc     $63
        dec
        sta     $1d
        lda     #$fa                    ; left side border
        sta     a:$0000,x
        inx2
        lda     #$ff                    ; blank window
@864b:  sta     a:$0000,x
        inx2
        dec     $1d
        bne     @864b
        lda     #$fb                    ; right side border
        sta     a:$0000,x
        rts

; ------------------------------------------------------------------------------

; [ hide window row ]

HideWindowRowBtm:
@865a:  jsr     GetWindowPtrBtmLeft
        bra     _8662
HideWindowRowTop:
@865f:  jsr     GetWindowPtrTopLeft
_8662:  lda     $65
        sec
        sbc     $63
        inc
        sta     $1d
        tdc                             ; hide tile (black)
@866b:  sta     a:$0000,x
        inx2
        dec     $1d
        bne     @866b
        rts

; ------------------------------------------------------------------------------

; [ draw window row (top) ]

DrawWindowRowTop:
@8675:  jsr     GetWindowPtrTopLeft
        lda     $65
        sec
        sbc     $63
        dec
        sta     $1d
        lda     #$f7                    ; top left
        sta     a:$0000,x
        inx2
        lda     #$f8                    ; top middle
@8689:  sta     a:$0000,x
        inx2
        dec     $1d
        bne     @8689
        lda     #$f9                    ; top right
        sta     a:$0000,x
        rts

; ------------------------------------------------------------------------------

; [ draw window row (bottom) ]

DrawWindowRowBtm:
@8698:  jsr     GetWindowPtrBtmLeft
        lda     $65
        sec
        sbc     $63
        dec
        sta     $1d
        lda     #$fc                    ; bottom left border
        sta     a:$0000,x
        inx2
        lda     #$fd                    ; bottom border
@86ac:  sta     a:$0000,x
        inx2
        dec     $1d
        bne     @86ac
        lda     #$fe                    ; bottom right border
        sta     a:$0000,x
        rts

; ------------------------------------------------------------------------------

; [ draw window column ]

; middle column (left side)
DrawWindowColMidLeft:
@86bb:  lda     #$f8                    ; top
        sta     $1e
        lda     #$ff                    ; empty window
        sta     $1f
        lda     #$fd                    ; bottom
        sta     $20
        bra     _86f8
; left column
DrawWindowColLeft:
@86c9:  lda     #$f7                    ; top left
        sta     $1e
        lda     #$fa                    ; left
        sta     $1f
        lda     #$fc                    ; bottom left
        sta     $20
        bra     _86f8
; right column
DrawWindowColRight:
@86d7:  lda     #$f9
        sta     $1e
        lda     #$fb
        sta     $1f
        lda     #$fe
        sta     $20
        bra     _86f3
; middle column (right side)
DrawWindowColMidRight:
@86e5:  lda     #$f8
        sta     $1e
        lda     #$ff
        sta     $1f
        lda     #$fd
        sta     $20
        bra     _86f3
_86f3:  jsr     GetWindowPtrTopRight
        bra     _86fb
_86f8:  jsr     GetWindowPtrTopLeft
_86fb:  lda     $66
        sec
        sbc     $64
        dec
        sta     $1d
        lda     $1e
        sta     a:$0000,x               ; top tile
        jsr     NextRowX
@870b:  lda     $1f
        sta     a:$0000,x               ; middle tiles
        jsr     NextRowX
        dec     $1d
        bne     @870b
        lda     $20
        sta     a:$0000,x               ; bottom tile
        rts

; ------------------------------------------------------------------------------

; [ hide window column ]

HideWindowColRight:
@871d:  jsr     GetWindowPtrTopRight
        bra     _8725
HideWindowColLeft:
@8722:  jsr     GetWindowPtrTopLeft
_8725:  lda     $66
        sec
        sbc     $64
        inc
        sta     $1d
@872d:  lda     #$00
        sta     a:$0000,x
        jsr     NextRowX
        dec     $1d
        bne     @872d
        rts

; ------------------------------------------------------------------------------

; [ save dialogue window graphics ]

SaveDlgGfx_far:
@873a:  jsl     SaveDlgGfx_ext
        rts

; ------------------------------------------------------------------------------

; [ restore dialogue window graphics ]

RestoreDlgGfx_far:
@873f:  phb
        jsl     RestoreDlgGfx_ext
        jsr     TfrVRAM
        plb
        rts

; ------------------------------------------------------------------------------

; [ update window color ]

UpdateWindowColor_far:
@8749:  jsl     UpdateWindowColor_ext
        rts

; ------------------------------------------------------------------------------

; [ cursor sound effect ]

CursorSfx:
@874e:  lda     #$11        ; system sound effect $11
; fallthrough

; ------------------------------------------------------------------------------

; [ play system sound effect ]

PlaySysSfx:
@8750:  sta     $1e00
        jsl     ExecSound_ext
        rts

; ------------------------------------------------------------------------------

; [ error sound effect ]

ErrorSfx:
@8758:  lda     #$12        ; system sound effect $12
        bra     PlaySysSfx

; ------------------------------------------------------------------------------

; [ play game sound effect (far) ]

PlaySfx_far:
@875c:  jsr     PlaySfx
        rtl

; ------------------------------------------------------------------------------

; [ cure sound effect ]

CureSfx:
@8760:  lda     #$58
; fallthrough

; ------------------------------------------------------------------------------

; [ play game sound effect ]

PlaySfx:
@8762:  sta     $1e01
        lda     #$02
        sta     $1e00
        lda     #$80
        sta     $1e02
        lda     #$ff
        sta     $1e03
        jsl     ExecSound_ext
        rts

; ------------------------------------------------------------------------------

; [ clear text (far) ]

ClearText_far:
@8779:  jsl     ClearText_ext
        rts

; ------------------------------------------------------------------------------

; [ next row (x) ]

NextRowX:
@877e:  longa
        pha
        txa
        clc
        adc     #$0040                  ; skip 32 tiles (1 row of tilemap)
        tax
        pla
        shorta
        rts

; ------------------------------------------------------------------------------

; [ next row (y) ]

NextRowY:
@878b:  longa
        pha
        tya
        clc
        adc     #$0040
        tay
        pla
        shorta
        rts

; ------------------------------------------------------------------------------

; [ copy text to screen buffer ]

;  +y: source address (bank 01)
;  +x: destination address (bank 7e)
; $29: destination offset

CopyText:
@8798:  phb
        phk
        plb
        longa
        txa
        clc
        adc     $29
        tax
        shorta
@87a4:  lda     a:$0000,y
        beq     @87b2
        sta     $7e0000,x
        inx2
        iny
        bra     @87a4
@87b2:  plb
        rts

; ------------------------------------------------------------------------------

; [ tax ]

Tax16:
@87b4:  sta     $43
        ldx     $43
        rts

; ------------------------------------------------------------------------------

; [ iny ]

Iny_8:
@87b9:  iny4
Iny_4:
@87bd:  iny4
        rts

; ------------------------------------------------------------------------------

; [ draw game time and gil ]

DrawTimeGil:
@87c2:  jsr     SelectBG3
        ldy     #.loword(TimePosText)+2
        ldx     #bg_pos 23,20
        jsr     CopyText
        ldy     #.loword(GilPosText)+2
        ldx     #bg_pos 27,25
        jsr     DrawMenuText
        jsr     DrawTime
        ldy     #bg_pos 21,24
        lda     $16a2                   ; current gil
        ldx     $16a0
        jmp     DrawNum7

; ------------------------------------------------------------------------------

; [ fade in main menu ]

FadeInMainMenu:
@87e6:  jsr     ResetScrollRegs
        jsr     UpdateScrollRegs_far
        jsr     LoadPortraits
        jsr     InitDrawMainMenu
        jsr     TfrAllBGTiles
        jsr     TfrSprites
        jmp     FadeIn

; ------------------------------------------------------------------------------

; [ main menu ]

MainMenuMain:
@87fb:  lda     #$7e
        pha
        plb
        jsr     ClearCursorMem
        jsr     FadeInMainMenu
        stz     $1a03
        lda     $16b7
        bne     @8813
        stz     $1a76
        stz     $1a77
; start of frame loop
@8813:  lda     $1a76
        asl4
        adc     #$10
        sta     $46
        lda     #$b0
        sta     $45
        jsr     DrawCursor1
        jsr     DrawTimeGil
        jsr     TfrSpritesVblank
        jsr     TfrBG3Tiles
        jsr     TfrPal
        jsr     UpdateCtrlMenu
; up button
        lda     $01
        and     #JOY_UP
        beq     @8845
        lda     $1a76
        dec
        bpl     @8842
        lda     #$07
@8842:  sta     $1a76
; down button
@8845:  lda     $01
        and     #JOY_DOWN
        beq     @8857
        lda     $1a76
        inc
        cmp     #$08
        bcc     @8854
        tdc
@8854:  sta     $1a76
; A button
@8857:  lda     $00
        and     #JOY_A
        beq     @887d
        jsr     HideCursor1
        jsr     TfrSpritesVblank
        lda     $1a76
        cmp     $1a77
        beq     @886e
        jsr     ClearCursorMem
@886e:  sta     $1a77
        ldx     #.loword(MainMenuTbl)
        jsr     ExecJumpTbl
        jsr     ClearCursorMem
        jmp     @8813
; B button
@887d:  lda     $01
        and     #JOY_B
        beq     @8884
        rts
@8884:  jmp     @8813

; ------------------------------------------------------------------------------

; main menu jump table
MainMenuTbl:
@8887:  .addr   ItemMenu
        .addr   ShowMagicMenu
        .addr   EquipMenu
        .addr   ShowStatusMenu
        .addr   ChangeOrder
        .addr   ChangeRow
        .addr   ConfigMenu
        .addr   ShowSaveMenu

; ------------------------------------------------------------------------------

; [ draw character blocks and portraits ]

DrawCharsMainMenu:
@8897:  jsr     DrawAllCharBlocks
        jmp     DrawAllPortraits

; ------------------------------------------------------------------------------

; [ draw all character blocks ]

DrawAllCharBlocks:
@889d:  jsr     SelectBG3
        ldy     #.loword(MainCharWindow)
        jsr     DrawWindow
        jsr     DrawCharBlock1
        jsr     DrawCharBlock2
        jsr     DrawCharBlock3
        jsr     DrawCharBlock4
        jmp     DrawCharBlock5

; ------------------------------------------------------------------------------

; jump table for drawing character blocks
DrawCharBlockTbl:
@88b5:  .addr   DrawCharBlock1
        .addr   DrawCharBlock2
        .addr   DrawCharBlock3
        .addr   DrawCharBlock4
        .addr   DrawCharBlock5

; ------------------------------------------------------------------------------

; [ draw selected character block ]

DrawSelCharBlock:
@88bf:  jsr     SelectBG3
        ldy     #.loword(MainCharWindow)
        jsr     DrawWindow
; fallthrough

_0188c8:
@88c8:  lda     $e8
        ldx     #.loword(DrawCharBlockTbl)
        jmp     ExecJumpTbl

; character slot 1
DrawCharBlock1:
@88d0:  ldx     #$02ce
        ldy     #$1000
        jmp     DrawCharBlock

; character slot 2
DrawCharBlock2:
@88d9:  ldx     #$004e
        ldy     #$1040
        jmp     DrawCharBlock

; character slot 3
DrawCharBlock3:
@88e2:  ldx     #$054e
        ldy     #$1080
        jmp     DrawCharBlock

; character slot 4
DrawCharBlock4:
@88eb:  ldx     #$018e
        ldy     #$10c0
        jmp     DrawCharBlock

; character slot 5
DrawCharBlock5:
@88f4:  ldx     #$040e
        ldy     #$1100
        jmp     DrawCharBlock

; ------------------------------------------------------------------------------

; [ draw portraits ]

DrawAllPortraits:
@88fd:  lda     #0        ; sprite layer priority: 0
        sta     $c1
        tdc
        jsr     DrawPosPortrait
        lda     #1
        jsr     DrawPosPortrait
        lda     #2
        jsr     DrawPosPortrait
        lda     #3
        jsr     DrawPosPortrait
        lda     #4
        jmp     DrawPosPortrait

; ------------------------------------------------------------------------------

; [ draw main menu ]

DrawMainMenu:
@8919:  jsr     DrawCharsMainMenu
        jsr     SelectBG3
        ldy     #.loword(MainTimeWindow)
        jsr     DrawWindow
        ldy     #.loword(MainGilWindow)
        jsr     DrawWindow
        jsr     SelectBG4
        ldy     #.loword(MainOptionsWindow)
        jsr     DrawWindowText
        lda     $1a02
        bne     @8947       ; branch if tent/save is enabled
        lda     #$24        ; gray palette
        sta     $ca31       ; bg4 (16,24)
        sta     $ca33
        sta     $ca35
.if LANG_EN
        sta     $ca37       ; this is for the "e"
.else
        sta     $c9f5       ; this is for the dakuten
.endif
@8947:  rts

; ------------------------------------------------------------------------------

; [ calculate portrait position ]

CalcPortraitPos:
@8948:  sta     $60
        stz     $61
        longa
        lda     $60
        asl6
        adc     #$1000
        tay
        shorta
        lda     $60
        asl4
        sta     $48
        lda     a:$0000,y
        and     #$3f
        bne     @896c
        rts
@896c:  ora     $48
        sta     $48
        lda     $16a8       ; row setting
        beq     @897a
; 2 front, 3 back
        ldx     #10
        bra     @897c
; 3 front, 2 back
@897a:  ldx     $41         ; zero
@897c:  stx     $45
        lda     $60
        asl
        sta     $43
        longa
        lda     $43
        adc     $45
        tax
        lda     f:PortraitPosTbl,x   ; portrait positions
        tay
        shorta
        rts

; ------------------------------------------------------------------------------

; [ draw portrait (main menu) ]

; a: character slot

DrawPosPortrait:
@8992:  jsr     CalcPortraitPos
        lda     $60
        jmp     DrawPortrait

; ------------------------------------------------------------------------------

; [ draw character block ]

; +y: pointer to character properties
; +x: tilemap offset

; subroutine starts at 01/899b

_899a:  rts
; subroutine starts here
DrawCharBlock:
@899b:  lda     a:$0000,y
        and     #$3f
        beq     _899a
        sty     $48
        stx     $4b
        jsr     SetCharBlockColor
        txy
        jsr     DrawCharName
        ldy     $4b
        ldx     $48
        jsr     DrawStatusIcons
        longa
        lda     $4b
        clc
        adc     #$0084
        sta     $4b
        adc     $29
        tax
        shorta
        lda     #$4d        ; "L"
        sta     a:$0000,x
.if LANG_EN
        lda     #$67        ; "l"
        sta     a:$0008,x
        lda     #$60        ; "e"
        sta     a:$0002,x
        sta     a:$0006,x
        lda     #$71        ; "v"
.else
        sta     a:$0008,x
        lda     #$46        ; "E"
        sta     a:$0002,x
        sta     a:$0006,x
        lda     #$57        ; "V"
.endif
        sta     a:$0004,x
        lda     #$49        ; "H"
        sta     a:$0040,x
        lda     #$51        ; "P"
        sta     a:$0042,x
        sta     a:$0082,x
        lda     #$4e        ; "M"
        sta     a:$0080,x
        lda     #$c7        ; "/"
        sta     a:$004e,x
        sta     a:$008e,x
        ldy     #$0002
        lda     ($48),y
        jsr     HexToDec2
        sta     a:$0014,x
        xba
        sta     a:$0016,x
        longa
        lda     #$0046
        ldy     #$0007      ; current hp
        jsr     DrawHPMP
        lda     #$0050
        ldy     #$0009      ; max hp
        jsr     DrawHPMP
        lda     #$0086
        ldy     #$000b      ; current mp
        jsr     DrawHPMP
        lda     #$0090
        ldy     #$000d      ; max mp
        jsr     DrawHPMP
        shorta
        rts

; ------------------------------------------------------------------------------

; [ draw hp/mp text ]

DrawHPMP:
@8a2a:  longa
        phx
        stx     $45
        clc
        adc     $45
        tax
        lda     ($48),y
        jsr     HexToDec4
        shorta
        lda     $5a
        sta     a:$0000,x
        lda     $5b
        sta     a:$0002,x
        lda     $5d
        sta     a:$0004,x
        lda     $5e
        sta     a:$0006,x
        longa
        plx
        rts
.a8

; ------------------------------------------------------------------------------

; [ select character (main menu) ]

SelectChar:
@8a52:  lda     $e7
        jsr     Tax16
        jsr     GetSlotCharID
        bne     @8a69
        lda     $e7         ; find the first valid character
        inc
        cmp     #5
        bne     @8a65
        lda     #0
@8a65:  sta     $e7
        bra     @8a52
; start of frame loop
@8a69:  lda     $e7
        asl3
        sta     $45         ; y position = slot * 40 + 16
        asl2
        adc     $45
        adc     #$10
        sta     $46
        lda     #$02        ; x position = 2
        sta     $45
        jsr     DrawCursor1
        jsr     TfrSpritesVblank
        jsr     UpdateCtrlMenu
; up button
        lda     $01
        and     #JOY_UP
        beq     @8aaa
@8a8b:  lda     $e7
        dec
        bpl     @8a92
        lda     #4
@8a92:  sta     $e7
        jsr     Tax16
        lda     f:CharOrderTbl,x   ; character battle order
        jsr     GetCharPtr
        lda     $1bb8
        bne     @8aaa
        lda     a:$0000,x
        and     #$1f
        beq     @8a8b
; down button
@8aaa:  lda     $01
        and     #JOY_DOWN
        beq     @8ad0
@8ab0:  lda     $e7
        inc
        cmp     #5
        bne     @8ab8
        tdc
@8ab8:  sta     $e7
        jsr     Tax16
        lda     f:CharOrderTbl,x      ; character battle order
        jsr     GetCharPtr
        lda     $1bb8
        bne     @8ad0
        lda     a:$0000,x
        and     #$1f
        beq     @8ab0
; left or right button
@8ad0:  lda     $1b27
        beq     @8ae0
        lda     $01
        and     #JOY_LEFT|JOY_RIGHT
        beq     @8ae0
        lda     #$7f                    ; change row setting
        sta     $e8
        rts
; A button
@8ae0:  lda     $00
        and     #JOY_A
        beq     @8af2
        lda     $e7
        jsr     Tax16
        lda     f:CharOrderTbl,x      ; character battle order
        sta     $e8
        rts
; B button
@8af2:  lda     $01
        and     #JOY_B
        beq     @8afd
        lda     #$ff
        sta     $e8
        rts
@8afd:  jmp     @8a69

; ------------------------------------------------------------------------------

; [ draw character title or status icons ]

DrawStatusIcons:
@8b00:  sty     $4b
        stx     $48
        lda     a:$0003,x
        bit     #$80
        bne     @8b26       ; branch if dead
        asl
        sta     $45
        lda     a:$0004,x
        rol3
        and     #$01
        ora     $45
        beq     @8b30
        pha
        jsr     MoveToClassNamePos
        jsr     NextRowY
        pla
        dey2
        bra     @8b43
@8b26:  jsr     MoveToClassNamePos
        tyx
        ldy     #.loword(CantFightText)
        jmp     DrawMenuText
@8b30:  lda     $1bc2
        beq     @8b36
        rts
@8b36:  ldy     $48
        lda     a:$0001,y
        pha
        jsr     MoveToClassNamePos
        pla
        jmp     DrawClassName
@8b43:  sta     $45
        lda     #$21
        sta     $46
        longa
        tya
        clc
        adc     $29
        tay
        shorta
        ldx     #$0008
@8b55:  lda     $45
        bit     #$80
        beq     @8b6b
        lda     $46
        sta     a:$0000,y
        lda     f:StatusIconPalTbl-1,x
        ora     $34
        sta     a:$0001,y
        bra     @8b70
@8b6b:  lda     #$ff
        sta     a:$0000,y
@8b70:  phy
        longa
        tya
        sec
        sbc     #$0040
        tay
        shorta
        lda     #$ff
        sta     a:$0000,y
        ply
        iny2
        inc     $46
        asl     $45
        dex
        bne     @8b55
        rts

; ------------------------------------------------------------------------------

; status icon tile flags
StatusIconPalTbl:
@8b8b:  .byte   $00,$08,$0c,$0c,$0c,$0c,$08,$00

; ------------------------------------------------------------------------------

; [ draw game time ]

DrawTime:
@8b93:  lda     $16a4       ; game time
        sta     $73
        ldx     $16a5
        stx     $74
        jsr     Div60
        jsr     Div60
        ldx     $73
        cpx     #$03e7
        bcc     @8bb6       ; branch if less than 1000 hours
        ldy     #$d602      ; bg3 screen buffer
        jsr     @8bb8
        lda     $5b
        sta     $056c,y
        rts
@8bb6:  ldy     $29
@8bb8:  lda     $1d
        jsr     HexToDec2
        cmp     #$ff
        bne     @8bc3
        lda     #$80
@8bc3:  sta     $0576,y     ; minutes
        xba
        sta     $0578,y
        longa
        lda     $73
        shorta
        jsr     HexToDec4
        lda     $5b
        sta     $056e,y     ; hours
        lda     $5d
        sta     $0570,y
        lda     $5e
        sta     $0572,y
        lda     #$c8        ; colon
        sta     $0574,y
        rts

; ------------------------------------------------------------------------------

; [ divide by 60 ]

Div60:
@8be8:  stz     $1d
        ldx     #$0018
        rol     $73
        rol     $74
        rol     $75
@8bf3:  rol     $1d
        lda     $1d
        cmp     #$3c
        bcc     @8bff
        sbc     #$3c
        sta     $1d
@8bff:  rol     $73
        rol     $74
        rol     $75
        dex
        bne     @8bf3
        rts

; ------------------------------------------------------------------------------

; [ init and draw main menu ]

; called when fading in from field or returning from save menu

InitDrawMainMenu:
@8c09:  jsr     ClearAllBGTiles
        jsr     ResetSprites
        jsr     TfrSprites
        jmp     DrawMainMenu

; ------------------------------------------------------------------------------

; [ move to class name text position (7 tiles over) ]

MoveToClassNamePos:
@8c15:  longa
        lda     $4b
        clc
        adc     #$000e
        tay
        shorta
        rts

; ------------------------------------------------------------------------------

; [ set character block text color ]

SetCharBlockColor:
@8c21:  pha
        phx
        phy
        lda     a:$0003,y               ; use gray palette if dead
        and     #$80
        clc
        rol4
        sta     $45
        lda     #$07
        jsr     SetTextColor          ; dakuten row
        jsr     SetTextColor          ; name/title row
        lda     #$0e
        jsr     SetTextColor          ; level row
        jsr     SetTextColor          ; hp row
        jsr     SetTextColor          ; mp row
        ply
        plx
        pla
        rts

; ------------------------------------------------------------------------------

; [ set text color ]

; $45: tile flags
;   A: number of tiles

SetTextColor:
@8c47:  pha
        sta     $37
        phx
        longa
        txa
        clc
        adc     $29
        tax
        shorta
        lda     $45
@8c56:  sta     a:$0001,x
        inx2
        dec     $37
        bne     @8c56
        plx
        jsr     NextRowX
        pla
        rts

; ------------------------------------------------------------------------------

; [ clear cursor position data ]

ClearCursorMem:
@8c65:  pha
        lda     $16b7
        bne     @8c7b       ; branch if memory cursor
        ldx     #$00eb
        ldy     $41         ; zero
        tdc
@8c71:  sta     $1b00,y     ; clear $1b00-$1beb
        iny
        dex
        bne     @8c71
        jsr     SelectTopChar
@8c7b:  pla
        rts

; ------------------------------------------------------------------------------

; [ init menu ]

InitMenu:
@8c7d:  sei
        lda     #0
        sta     f:$000144     ; clear high byte of 8-bit scratchpad
        pha
        plb
        lda     #$80       ; screen off
        sta     hINIDISP
        lda     #$01       ; disable nmi and irq
        sta     hNMITIMEN
        ldx     #$2100
        phx
        pld
        jsl     InitHWRegs
        jsr     ResetBGScroll
        ldx     #$4000
        stx     $16
        phb
        lda     #^MiscBattleGfx
        pha
        plb
        lda     #$20
        ldy     #.loword(MiscBattleGfx)
        jsr     Tfr3bppGfx
        plb
        ldx     #$0100
        phx
        pld
        lda     #$7e
        pha
        plb
        stz     $41         ; zero (constant)
        stz     $42
        ldx     #$1000
        stx     $de
        jsr     UpdateScrollRegs_far
        ldx     #$2000      ; destination address (vram)
        stx     $1d
        ldx     #.loword(WindowGfx)
        stx     $1f
        lda     #^WindowGfx
        sta     $21
        ldx     #$1000      ; size: $1000
        stx     $22
        jsr     TfrVRAM
        jsr     ResetSprites
        jsr     ClearAllBGTiles
        jsr     TfrAllBGTiles
        jsl     LoadMenuPal
        longa
        jsr     UpdateWindowColor_far
        ldx     #.loword(MapSpritePal)+12*16
        ldy     #$a100
        lda     #15
        mvn     #^MapSpritePal,#$7e
        shorta
        jsr     TfrPal
        jsr     TfrSprites
        jsr     TfrAllBGTiles
        stz     $84
        stz     $85
        stz     $88
        lda     #$30
        sta     $3f
        lda     #$4c      ; jmp
        sta     $01cc
        sta     $01cf
        ldx     #.loword(@8d2c)
        stx     $01cd
        stx     $01d0
        jsr     InitCtrl_far
        lda     #$63
        sta     $e3
        lda     #$80
        sta     $88
        stz     $1bc9
@8d2c:  rts

; ------------------------------------------------------------------------------

; [ clear screen buffer ]

ClearAllBGTiles:
@8d2d:  jsr     ClearBG3Tiles
        jsr     ClearBG1Tiles
        jsr     ClearBG4Tiles
; fallthrough

ClearBG2Tiles:
@8d36:  ldx     #$a600      ; bg2 screen buffer
        bra     _8d4a

ClearBG1Tiles:
@8d3b:  ldx     #$b600      ; bg1 screen buffer
        bra     _8d62

ClearBG4Tiles:
@8d40:  ldx     #$c600      ; bg4 screen buffer
        bra     _8d4a

ClearBG3Tiles:
@8d45:  ldx     #$d600      ; bg3 screen buffer
        bra     _8d62

; high priority (bg2 and bg4)
_8d4a:  stx     $73
        longa
        lda     #$2000
_8d51:  ldy     $41         ; zero
        ldx     #$0800
@8d56:  sta     ($73),y
        iny2
        dex
        bne     @8d56
        shorta
        stz     $44
        rts

; low priority (bg1 and bg3)
_8d62:  stx     $73
        longa
        lda     $41         ; zero
        bra     _8d51

; ------------------------------------------------------------------------------

; [ reset sprite data ]

ResetSprites:
@8d6a:  longa
        ldy     #128      ; 128 sprites
        ldx     #0
@8d72:  lda     #$f0ff
        sta     f:$000300,x
        lda     #$3000
        sta     f:$000302,x
        inx4
        dey
        bne     @8d72
        ldy     #16      ; clear 32 bytes of upper sprite data
        lda     #0
@8d8d:  sta     f:$000300,x
        inx2
        dey
        bne     @8d8d
        lda     #$aaaa      ; sprites 0-15 are 32x32 (cursors)
        sta     f:$000500
        shorta
        rts

; ------------------------------------------------------------------------------

; [ load character graphics ]

LoadCharGfx:
@8da0:  stz     $e4         ; character slot
@8da2:  lda     $e4
        jsr     GetCharPtr
        asl
        sta     $43
        ldy     $43
        lda     a:$0000,x     ; character id
        and     #$3f
        sta     $5a
        sta     $1a67,y
        lda     $e4
        sta     $5b
        sta     $1a68,y
        lda     a:$0001,x     ; character graphics
        sta     $5c
        jsr     LoadCharGfxSlot
        inc     $e4         ; next character slot
        lda     $e4
        cmp     #5
        bne     @8da2
        rts

; ------------------------------------------------------------------------------

; [ load character slot graphics ]

LoadCharGfxSlot:
@8dce:  lda     $5a
        bne     @8dd3       ; branch if no character
        rts
@8dd3:  lda     #0
        xba
        lda     $5c
        asl3
        xba
        longa
        clc
        adc     #.loword(BattleCharGfx)
        sta     $1f
        lda     #$0600      ; size: $0600 bytes
        sta     $22
        shorta
        lda     #^BattleCharGfx
        sta     $21
        lda     $5b
        asl
        jsr     Tax16
        longa
        lda     f:CharGfxVRAMTbl,x   ; ppu address for character graphics
        sta     $1d
        shorta
        jsr     WaitVblank
        jsr     TfrVRAM
        tdc
        xba
        lda     $5c
        and     #$0f
        longa
        asl5
        tax
        shorta
        lda     $5b
        asl5
        sta     $43
        ldy     $43
        lda     #$20
        sta     $45
@8e24:  lda     f:BattleCharPal,x   ; load character palette to buffer
        sta     $fe28,y
        inx
        iny
        dec     $45
        bne     @8e24
        rts

; ------------------------------------------------------------------------------

; [ get dakuten ]

GetDakuten:
@8e32:  phx
        cmp     #$42
        bcs     @8e4c       ; branch if no dakuten
        sec
        sbc     #$0f
        asl
        xba
        lda     #$00
        xba
        tax
        lda     f:DakutenTbl+1,x   ; dakuten
        xba
        lda     f:DakutenTbl,x   ; kana
        xba
        plx
        rts
@8e4c:  xba
        lda     #$ff
        plx
        rts

; ------------------------------------------------------------------------------

; [ hide portrait ??? ]

; unused, maybe portraits were on a background layer at sound point?

_018e51:
@8e51:  ldx     #4
        longa
@8e56:  lda     #$0100
        sta     a:$0000,y
        sta     a:$0002,y
        sta     a:$0004,y
        sta     a:$0006,y
        jsr     NextRowY
        dex
        bne     @8e56
        shorta
        rts

; ------------------------------------------------------------------------------

; [ draw portrait ]

DrawPortrait:
@8e6e:  pha
        phy
        sta     $1d
        sty     $1e
        jsr     GetCharID
        bne     @8ea1
; no portrait
        tdc
        xba
        lda     $1d
        longa
        asl6
        tay
        ldx     #$0020
@8e89:  lda     #$f0ff
        sta     $0340,y
        lda     #$3000
        sta     $0342,y
        iny4
        dex
        bne     @8e89
        shorta
        ply
        pla
        rts
; draw portrait
@8ea1:  lda     #0
        xba
        lda     $1d
        longa
        asl6
        tay
        shorta
        lda     $1d
        asl4
        adc     #$20
        sta     $20
        lda     $1d
        clc
        adc     #$03
        asl
        ora     $01c1       ; layer priority
        sta     $21
        longa
; 1st row
        ldx     #4
@8ecb:  lda     $1e
        sta     $0340,y
        clc
        adc     #8
        sta     $1e
        lda     $20
        sta     $0342,y
        inc
        sta     $20
        iny4
        dex
        bne     @8ecb
        lda     $1e
        clc
        adc     #$07e0      ; next row
        sta     $1e
; 2nd row
        ldx     #4
@8ef0:  lda     $1e
        sta     $0340,y
        clc
        adc     #8
        sta     $1e
        lda     $20
        sta     $0342,y
        inc
        sta     $20
        iny4
        dex
        bne     @8ef0
        lda     $1e
        clc
        adc     #$07e0      ; next row
        sta     $1e
; 3rd row
        ldx     #4
@8f15:  lda     $1e
        sta     $0340,y
        clc
        adc     #8
        sta     $1e
        lda     $20
        sta     $0342,y
        inc
        sta     $20
        iny4
        dex
        bne     @8f15
        lda     $1e
        clc
        adc     #$07e0      ; next row
        sta     $1e
; 4th row
        ldx     #4
@8f3a:  lda     $1e
        sta     $0340,y
        clc
        adc     #8
        sta     $1e
        lda     $20
        sta     $0342,y
        inc
        sta     $20
        iny4
        dex
        bne     @8f3a
        shorta
        ply
        pla
        rts

; ------------------------------------------------------------------------------

; [ convert hex to decimal (7 digits) ]

HexToDec7:
@8f59:  stx     $73
        sta     $75
        lda     #$ff
        ldx     $41         ; zero
@8f61:  sta     $0163,x
        inx
        cpx     #7
        bne     @8f61
        ldy     $41         ; zero
@8f6c:  jsr     Div10
        lda     $1d
        ora     #$80
        sta     $0163,y     ; store digit
        iny
        lda     $73
        ora     $74
        ora     $75
        beq     @8f84
        cpy     #7
        bne     @8f6c
@8f84:  rts

; ------------------------------------------------------------------------------

; [ divide by 10 ]

Div10:
@8f85:  stz     $1d
        ldx     #$0018
        rol     $73
        rol     $74
        rol     $75
@8f90:  rol     $1d
        lda     $1d
        cmp     #10
        bcc     @8f9c
        sbc     #10
        sta     $1d
@8f9c:  rol     $73
        rol     $74
        rol     $75
        dex
        bne     @8f90
        rts

; ------------------------------------------------------------------------------

; [ draw number text (7 digits) ]

DrawNum7:
@8fa6:  phy
        phy
        jsr     HexToDec7
        longa
        pla
        clc
        adc     #14
        tay
        shorta
        ldx     $41         ; zero
@8fb7:  lda     $0163,x
        sta     ($29),y     ; copy to tilemap
        dey2
        inx
        cpx     #7
        bne     @8fb7
        ply
        rts

; ------------------------------------------------------------------------------

; [ draw class name (character title) ]

DrawClassName:
@8fc6:  and     #$0f
        pha
        longa
        tya
        clc
        adc     $29
        tay
        shorta
        pla
.if LANG_EN
        sta     $46
        asl
        sta     $45
        asl
        adc     $45
        adc     $46
        sta     $45
        stz     $46
        ldx     $45
        lda     #7
.else
        asl
        sta     $45
        asl
        adc     $45
        sta     $45
        stz     $46
        ldx     $45
        lda     #6
.endif
        sta     $45
@8fe3:  lda     f:ClassName,x
        jsr     GetDakuten
        sta     a:$0000,y     ; dakuten
        xba
        sta     a:$0040,y     ; kana
        iny
        lda     $34
        sta     a:$0000,y
        sta     a:$0040,y
        iny
        inx
        dec     $45
        bne     @8fe3
        rts

; ------------------------------------------------------------------------------

; [ get pointer to character properties ]

GetCharPtr:
@9001:  pha
        and     #$0f
        asl
        jsr     Tax16
        longa
        lda     f:CharPtrTbl,x
        tax
        shorta
        pla
        rts

; ------------------------------------------------------------------------------

; [ draw item name ]

DrawEquipItemName:
@9013:  phy
        phx
        lda     ($60),y

_9017:  sta     $43
        longa
        lda     $29
        clc
        adc     #$0040
        sta     $1d
        lda     $43
        asl3
        adc     $43
        tax
        shorta
        ply
        lda     f:ItemName,x
        sta     ($1d),y
        iny
        lda     $db
        ora     $34
        sta     ($29),y
        sta     ($1d),y
        iny
        inx
        lda     #$08
        sta     $45
@9043:  lda     f:ItemName,x
        jsr     GetDakuten
        sta     ($29),y     ; dakuten
        xba
        sta     ($1d),y     ; kana
        inx
        iny
        lda     $db
        ora     $34
        sta     ($29),y
        sta     ($1d),y
        iny
        dec     $45
        bne     @9043
        ply
        rts

DrawItemName:
@9060:  phy
        phy
        bra     _9017

; ------------------------------------------------------------------------------

; [ draw character battle sprite ]

DrawCharSprite:
@9064:  phx
        lda     $1d
        jsr     GetCharPtr
        stx     $22
        lda     ($22)
        and     #$3f
        bne     _908c
        bra     _9075

; for order change animation
DrawCharSpriteOrder:
@9074:  phx
_9075:  tdc
        xba
        lda     $1d
        longa
        asl6
        adc     #$0340
        tay
        shorta
        jsr     HideExtraCharSprites
        plx
        rts
_908c:  ldy     $41         ; zero
@908e:  cmp     $1a67,y
        beq     @9097
        iny2
        bra     @908e
@9097:  lda     $1a68,y
        pha
        sta     $45
        asl
        adc     $45
        asl4
        adc     #$80
        sta     $48
        lda     #$00
        adc     #$00
        sta     $49
        pla
        inc3
        asl
        ora     $c1         ; sprite layer priority
        adc     $49
        sta     $49
        lda     $1e
        cmp     #$09
        bne     @90c4
        ldx     #$0006
        bra     @90c6
@90c4:  ldx     $41         ; zero
@90c6:  tdc
        xba
        lda     $1d
        longa
        asl6
        adc     #$0340
        tay
        shorta
        lda     #$06
        sta     $45
@90dc:  lda     $1f
        clc
        adc     f:CharSpriteXTbl,x
        sta     a:$0000,y
        lda     $20
        clc
        adc     f:CharSpriteYTbl,x
        sta     a:$0001,y
        stx     $e9
        lda     $1e
        asl
        sta     $43
        asl
        adc     $43
        adc     $e9
        jsr     Tax16
        lda     #$00
        xba
        lda     f:CharSpriteTileTbl,x
        ldx     $e9
        longa
        clc
        adc     $48
        sta     a:$0002,y
        shorta
        iny4
        inx
        dec     $45
        bne     @90dc
        jsr     HideExtraCharSprites
        plx
        rts

; ------------------------------------------------------------------------------

; [ hide extra character sprites ]

; portraits use 16 sprites, but characters only use 6
; this subroutine hides the last 10 when character sprites are drawn

HideExtraCharSprites:
@9120:  ldx     #10
        longa
@9125:  lda     #$f0ff
        sta     a:$0000,y
        lda     #$3000
        sta     a:$0002,y
        iny4
        dex
        bne     @9125
        shorta
        rts

; ------------------------------------------------------------------------------

; character spritesheet (11 * 6 bytes)
CharSpriteTileTbl:
@913b:  .byte   $00,$01,$02,$03,$04,$05
        .byte   $06,$07,$08,$09,$0a,$0b
        .byte   $00,$01,$02,$03,$0c,$0d
        .byte   $0e,$0f,$10,$11,$12,$13
        .byte   $00,$01,$14,$03,$15,$0d
        .byte   $00,$01,$16,$17,$18,$19
        .byte   $00,$1a,$02,$1b,$1c,$1d
        .byte   $1e,$1f,$20,$21,$22,$23
        .byte   $24,$25,$26,$27,$28,$29
        .byte   $2a,$2b,$2c,$2d,$2e,$2f
        .byte   $2a,$2b,$2c,$2d,$2e,$2f

; sprite x positions
CharSpriteXTbl:
@917d:  .byte   $00,$08,$00,$08,$00,$08
        .byte   $00,$08,$10,$00,$08,$10

; sprite y positions
CharSpriteYTbl:
@9189:  .byte   $00,$00,$08,$08,$10,$10
        .byte   $00,$00,$00,$08,$08,$08

; ------------------------------------------------------------------------------

; [  ]

; unused

_019195:
@9195:  ldx     $41         ; zero
        longa
        lda     #5
        sta     $45
        ldy     $41         ; zero
@91a0:  lda     f:_0191c4,x
        clc
        adc     $1a71
        sta     $fe02,y
        sta     $fe16,y
        tya
        lsr2
        sta     $fe00,y
        sta     $fe14,y
        iny4
        inx2
        dec     $45
        bne     @91a0
        shorta
        rts

; ------------------------------------------------------------------------------

_0191c4:
@91c4:  .word   $0000,$1800,$3000,$4800,$6000

; ------------------------------------------------------------------------------

; [ init party sprites (shop and fat chocobo menu) ]

InitPartySprites:
@91ce:  lda     $16a8                   ; row setting
        beq     @91d5
        lda     #$0a
@91d5:  jsr     Tax16
        longa
        lda     #5
        sta     $45
        ldy     $41                     ; zero
@91e1:  lda     f:PartyCharPos,x
        clc
        adc     $1a71
        sta     $fe02,y
        sta     $fe16,y
        tya
        lsr2
        sta     $fe00,y
        sta     $fe14,y
        iny4
        inx2
        dec     $45
        bne     @91e1
        shorta
        lda     #$0a
        sta     $1a73
        rts

; ------------------------------------------------------------------------------

; party character positions
PartyCharPos:
@920a:  .byte   $00,$1c                 ; 3 front, 2 back
        .byte   $00,$00
        .byte   $00,$38
        .byte   $18,$0c
        .byte   $18,$2c

        .byte   $18,$1c                 ; 3 back, 2 front
        .byte   $18,$00
        .byte   $18,$38
        .byte   $00,$0c
        .byte   $00,$2c

; ------------------------------------------------------------------------------

; [ update party sprites (shop menu) ]

UpdatePartySpritesShop:
@921e:  lda     $1a73
        beq     @9227
        dec     $1a73
        rts
@9227:  lda     #$0a
        sta     $1a73
        lda     #$ff
        eor     $1a75
        sta     $1a75
        beq     @923b
        ldy     #$fe00
        bra     @923e
@923b:  ldy     #$fe14
@923e:  ldx     #$0005
@9241:  longa
        lda     a:$0000,y
        sta     $1d
        lda     a:$0002,y
        sta     $1f
        shorta
        phx
        phy
        jsr     DrawCharSprite
        ply
        plx
        iny4
        dex
        bne     @9241
        rts

; ------------------------------------------------------------------------------

; [ load portraits ]

LoadPortraits:
@925e:  tdc
@925f:  jsr     WaitVblank
        jsr     TfrPortraitGfx
        jsr     LoadPortraitPal
        inc
        cmp     #5
        bne     @925f
        jsr     WaitVblank
        jmp     TfrPal

; ------------------------------------------------------------------------------

; [ transfer portrait graphics to vram ]

TfrPortraitGfx:
@9273:  pha
        sta     $45
        stz     $46
        jsr     GetCharID
        bne     @927f
        pla
        rts
@927f:  pha
        lda     a:$0001,x
        and     #$0f
        sta     $1bc0
        stz     $1bbf
        lda     a:$0003,x
        and     #$38
        beq     @92c2
        lsr2
        jsr     Tax16
        longa
        lda     f:StatusPortraitPtrs,x
        tay
        shorta
        lda     $45
        asl
        sta     $43
        ldx     $43
        lda     #$80
        sta     f:hVMAINC
        longa
        lda     f:PortraitVRAMTbl,x   ; portrait graphics locations (vram)
        sta     f:hVMADDL
        shorta
        pla
        phd
        ldx     #$2100
        phx
        pld
        bra     @92ed
@92c2:  pla
        phd
        ldx     #$2100
        phx
        pld
        dec
        asl
        sta     $0143
        lda     #$80
        sta     $15
        longa
        lda     $1bbf
        lsr
        clc
        adc     $1bbf
        adc     #.loword(PortraitGfx)
        tay
        lda     $0145
        asl
        tax
        lda     f:PortraitVRAMTbl,x   ; portrait graphics locations (vram)
        sta     $16
        shorta
@92ed:  phb
        lda     #^PortraitGfx
        pha
        plb
        lda     #$10
        jsr     Tfr3bppGfx
        plb
        pld
        pla
        rts

; ------------------------------------------------------------------------------

; [ transfer 3bpp graphics to vram ]

Tfr3bppGfx:
@92fb:  sta     $0145
@92fe:  ldx     #$0008
@9301:  lda     a:$0000,y
        sta     $18
        lda     a:$0001,y
        sta     $19
        iny2
        dex
        bne     @9301
        ldx     #$0008
@9313:  lda     a:$0000,y
        sta     $18
        stz     $19
        iny
        dex
        bne     @9313
        dec     $0145
        bne     @92fe
        rts

; ------------------------------------------------------------------------------

; portrait graphics locations (vram)
PortraitVRAMTbl:
@9324:  .word   $4200,$4300,$4400,$4500,$4600

; ------------------------------------------------------------------------------

; [ load portrait palette ]

LoadPortraitPal:
@932e:  pha
        sta     $45
        stz     $46
        jsr     GetCharID
        bne     @933a
        pla
        rts
@933a:  lda     a:$0001,x
        and     #$0f
        sta     $43
        longa
        lda     $43
        asl4
        adc     #.loword(PortraitPal)
        tax
        lda     $45
        asl5
        adc     #$a160
        tay
        lda     #15
        mvn     #^PortraitPal,#$7e
        shorta
        pla
        rts

; ------------------------------------------------------------------------------

; [ update character sprites (namingway/fat chocobo menu) ]

UpdatePartySpritesNamingway:
@9362:  dec     $1a73
        bne     @9374
        lda     #$0a
        sta     $1a73
        lda     $1a75
        eor     #$ff
        sta     $1a75
@9374:  longa
        txa
        sta     $63
        clc
        adc     #$0018
        sta     $65
        adc     #$0018
        sta     $67
        adc     #$0018
        sta     $69
        adc     #$0018
        sta     $6b
        shorta
        tdc
        sta     $1d
        lda     $1b4b
        sta     $1e
        lda     $1a75
        bne     @93a2
        lda     $1b4c
        sta     $1e
@93a2:  ldx     $63
        stx     $1f
        jsr     DrawCharSprite
        lda     #$01
        sta     $1d
        lda     $1b4d
        sta     $1e
        lda     $1a75
        bne     @93bc
        lda     $1b4e
        sta     $1e
@93bc:  ldx     $65
        stx     $1f
        jsr     DrawCharSprite
        lda     #$02
        sta     $1d
        lda     $1b4f
        sta     $1e
        lda     $1a75
        bne     @93d6
        lda     $1b50
        sta     $1e
@93d6:  ldx     $67
        stx     $1f
        jsr     DrawCharSprite
        lda     #$03
        sta     $1d
        lda     $1b51
        sta     $1e
        lda     $1a75
        bne     @93f0
        lda     $1b52
        sta     $1e
@93f0:  ldx     $69
        stx     $1f
        jsr     DrawCharSprite
        lda     #$04
        sta     $1d
        lda     $1b53
        sta     $1e
        lda     $1a75
        bne     @940a
        lda     $1b54
        sta     $1e
@940a:  ldx     $6b
        stx     $1f
        jmp     DrawCharSprite

; ------------------------------------------------------------------------------

; [ transfer screen buffer to vram (all) ]

TfrAllBGTiles:
@9411:  jsr     TfrBG2Tiles
        jsr     TfrBG1Tiles
        jsr     TfrBG4Tiles
        jmp     TfrBG3Tiles

; ------------------------------------------------------------------------------

; [ transfer screen buffer to vram ]

; clear bg2 screen buffer in vram
TfrClearBG2Tiles:
@941d:  jsr     ClearBG2Tiles

; transfer bg2 screen buffer to vram
TfrBG2TilesVblank:
@9420:  jsr     WaitVblank

TfrBG2Tiles:
@9423:  phx
        phy
        ldx     #$6800
        ldy     #$a600
        bra     _9452

; transfer bg1 screen buffer to vram
TfrBG1TilesVblank:
@942d:  jsr     WaitVblank

TfrBG1Tiles:
@9430:  phx
        phy
        ldx     #$6000
        ldy     #$b600
        bra     _9452

; transfer bg4 screen buffer to vram
TfrBG4TilesVblank:
@943a:  jsr     WaitVblank

TfrBG4Tiles:
@943d:  phx
        phy
        ldx     #$7800
        ldy     #$c600
        bra     _9452

; transfer bg3 screen buffer to vram
TfrBG3TilesVblank:
@9447:  jsr     WaitVblank

TfrBG3Tiles:
@944a:  phx
        phy
        ldx     #$7000
        ldy     #$d600
_9452:  stx     $1d
        sty     $1f
        lda     #$7e
        sta     $21
        ldx     $de
        stx     $22
        jsr     TfrVRAM
        ply
        plx
        rts

; ------------------------------------------------------------------------------

; [ fade in ]

FadeIn:
@9464:  jsr     WaitVblank
        lda     $88
        and     #$7f
        sta     f:hINIDISP     ; set screen brightness
        pha
        jsr     UpdateCtrl_far
        pla
        inc
        sta     $88
        cmp     #$10
        bcc     @9464
        dec     $88
        rts

; ------------------------------------------------------------------------------

; [ fade out ]

FadeOut:
@947e:  jsr     WaitVblank
        lda     $88
        bmi     @949b       ; branch if screen is off
        sta     f:hINIDISP     ; set screen brightness
        pha
        jsr     UpdateCtrl_far
        pla
        dec                 ; decrement screen brightness
        sta     $88
        bpl     @947e
        lda     #$80
        sta     f:hINIDISP     ; screen off
        sta     $88
@949b:  rts

; ------------------------------------------------------------------------------

; [  ]

ResetScrollRegs:
@949c:  jsr     ResetBGScroll
        bra     UpdateScrollRegs_far

UpdateScrollRegsVblank:
@94a1:  jsr     WaitVblank
; fallthrough

UpdateScrollRegs_far:
@94a4:  jsl     UpdateScrollRegs_ext
        rts

; ------------------------------------------------------------------------------

; [ reset bg scroll positions ]

ResetBGScroll:
@94a9:  phx
        phd
        ldx     #$0100
        phx
        pld
        longa
        lda     #$0000
        ldy     #$001c
        ldx     $41         ; zero
@94ba:  sta     $89,x
        inx2
        dey
        bne     @94ba
        shorta
        pld
        plx
        rts

; ------------------------------------------------------------------------------

; [ save color palettes (slot 1) ]

SavePal1:
@94c6:  longa
        lda     #$00ff
        ldx     #$a000
        ldy     #$a200
        mvn     #$7e,#$7e
        shorta
        rts

; ------------------------------------------------------------------------------

; [ save color palettes (slot 2) ]

SavePal2:
@94d7:  longa
        lda     #$00ff
        ldx     #$a000
        ldy     #$a400
        mvn     #$7e,#$7e
        shorta
        rts

; ------------------------------------------------------------------------------

; [ restore color palettes (slot 1) ]

RestorePal1:
@94e8:  longa
        lda     #$00ff
        ldx     #$a200
        ldy     #$a000
        mvn     #$7e,#$7e
        shorta
        rts

; ------------------------------------------------------------------------------

; [ restore color palettes (slot 2) ]

RestorePal2:
@94f9:  longa
        lda     #$00ff
        ldx     #$a400
        ldy     #$a000
        mvn     #$7e,#$7e
        shorta
        rts

; ------------------------------------------------------------------------------

; bg palette offsets
BGPalOffsetTbl:
@950a:  .byte   $40,$00,$c0,$80

; ------------------------------------------------------------------------------

; [ get bg palette offset ]

GetBGPalOffset:
@950e:  dec
        jsr     Tax16
        lda     f:BGPalOffsetTbl,x
        sta     $43
        ldx     $43
        rts

; ------------------------------------------------------------------------------

; [ clear bg palette ]

ClearBGPal:
@951b:  pha
        jsr     GetBGPalOffset
        lda     #$20
        sta     $1d
        tdc
@9524:  sta     $a000,x
        inx
        dec     $1d
        bne     @9524
        pla
        rts

; ------------------------------------------------------------------------------

; [ update portrait position ]

; called at vblank to move the portrait during menu transform

UpdatePortraitPos:
@952e:  lda     $d2
        bne     @9533
        rts
@9533:  lda     $be
        bpl     @954a
        and     #$7f
        sta     $59
        clc
        lda     $bd
        adc     $b9
        sta     $b9
        lda     $ba
        adc     $59
        sta     $ba
        bra     @9557
@954a:  lda     $b9
        sec
        sbc     $bd
        sta     $b9
        lda     $ba
        sbc     $be
        sta     $ba
@9557:  lda     $c0
        bpl     @956e
        and     #$7f
        sta     $59
        clc
        lda     $bf
        adc     $bb
        sta     $bb
        lda     $bc
        adc     $59
        sta     $bc
        bra     @957b
@956e:  lda     $bb
        sec
        sbc     $bf
        sta     $bb
        lda     $bc
        sbc     $c0
        sta     $bc
@957b:  lda     $bc
        xba
        lda     $ba
        tay
        lda     $d3
        jsr     DrawPortrait
        dec     $d2
        rts

; ------------------------------------------------------------------------------

; [ get character status byte 1 ]

GetCharStatus:
@9589:  lda     $e8
        jsr     GetCharPtr
        lda     a:$0003,x
        rts

; ------------------------------------------------------------------------------

.include "load.asm"
.include "name.asm"
.include "item.asm"
.include "status.asm"
.include "order.asm"
.include "sort.asm"
.include "magic.asm"
.include "namingway.asm"
.include "equip.asm"
.include "shop.asm"
.include "save.asm"
.include "fat_choco.asm"
.include "config.asm"
.include "treasure.asm"

; ------------------------------------------------------------------------------

.segment "menu_code2"

; ------------------------------------------------------------------------------

; [ play fanfare ]

; called when rydia learns a spell from a summon item

PlayFanfare:
@c600:  lda     $1e05       ; current song
        pha
        lda     #$29        ; song $29 (fanfare)
        jsr     PlaySong
        ldx     #330      ; 330 frames (5.5 seconds)
@c60c:  jsl     WaitVblank_far
        dex
        bne     @c60c
        pla
        jsr     PlaySong
        rtl

; ------------------------------------------------------------------------------

; [ play song ]

PlaySong:
@c618:  sta     $1e01
        lda     #$01
        sta     $1e00
        jsl     ExecSound_ext
        rts

; ------------------------------------------------------------------------------

; pointers to character properties
CharPtrTbl:
@c625:  .word   $1000,$1040,$1080,$10c0,$1100

; ------------------------------------------------------------------------------

.include "system.asm"

; ------------------------------------------------------------------------------

.segment "menu_code4"

; ------------------------------------------------------------------------------

; [ copy fat chocobo item list to tile buffer ]

CopyFatChocoList:
@fc28:  lda     $e2
        cmp     #$11
        beq     @fc40                   ; return if showing inventory (take)
        lda     #10                     ; copy 10 items
        sta     $45
        lda     $1bb2                   ; scroll position
        dec
@fc36:  pha
        jsr     CopyFatChocoListItem
        pla
        inc
        dec     $45
        bne     @fc36
@fc40:  rtl

; ------------------------------------------------------------------------------

; [ scroll fat chocobo list by 1 line ]

ScrollFatChocoList:
@fc41:  lda     $e2
        cmp     #$11
        beq     @fc57                   ; return if showing inventory (give)
        lda     $1bb2
        dec
        jsr     CopyFatChocoListItem
        lda     $1bb2
        clc
        adc     #$08
        jsr     CopyFatChocoListItem
@fc57:  rtl

; ------------------------------------------------------------------------------

; [ copy 1 item of fat chocobo list to tile buffer ]

CopyFatChocoListItem:
@fc58:  sta     $43
        longa
        lda     $43
        xba
        lsr
        pha
        clc
        and     #$1fff
        clc
        adc     #$a600
        tax
        pla
        clc
        and     #$0fff
        clc
        adc     #$c600
        tay
        lda     #$007f
        mvn     #$7e,#$7e
        shorta
        rts

; ------------------------------------------------------------------------------

FatChocoSpriteTbl:
@fc7d:  .byte   $08,$08,$60,$02
        .byte   $10,$08,$61,$02
        .byte   $18,$08,$64,$02
        .byte   $20,$08,$65,$02
        .byte   $08,$10,$62,$02
        .byte   $10,$10,$63,$02
        .byte   $18,$10,$66,$02
        .byte   $20,$10,$67,$02
        .byte   $08,$18,$68,$02
        .byte   $10,$18,$69,$02
        .byte   $18,$18,$6c,$02
        .byte   $20,$18,$6d,$02
        .byte   $08,$20,$6a,$02
        .byte   $10,$20,$6b,$02
        .byte   $18,$20,$6e,$02
        .byte   $20,$20,$6f,$02

; ------------------------------------------------------------------------------

; pointers to pig, mini, and toad portrait graphics
StatusPortraitPtrs:
@fcbd:  .addr   PortraitGfx+14*$0180
        .addr   PortraitGfx+14*$0180
        .addr   PortraitGfx+15*$0180
        .addr   PortraitGfx+15*$0180
        .addr   PortraitGfx+16*$0180
        .addr   PortraitGfx+16*$0180
        .addr   PortraitGfx+16*$0180
        .addr   PortraitGfx+16*$0180

; ------------------------------------------------------------------------------

; [ init hardware registers ]

; direct page set to $2100 before call

InitHWRegs:
@fccd:  lda     #$02
        sta     <hOBJSEL
        lda     #$00
        sta     <hOAMADDL
        sta     <hOAMADDH
        sta     <hBGMODE
        sta     <hMOSAIC
        lda     #$62
        sta     <hBG1SC
        lda     #$6a
        sta     <hBG2SC
        lda     #$72
        sta     <hBG3SC
        lda     #$7a
        sta     <hBG4SC
        lda     #$22
        sta     <hBG12NBA
        lda     #$22
        sta     <hBG34NBA
        lda     #$00
        sta     hMDMAEN
        sta     hHDMAEN
        lda     #$80
        sta     <hVMAINC
        tdc
        sta     <hVMADDL
        sta     <hVMADDH
        lda     #$1f
        sta     <hTM
        tdc
        sta     <hTS
        sta     <hTMW
        sta     <hTSW
        sta     <hCGSWSEL
        sta     <hCGADSUB
        sta     <hSETINI
        lda     #$e0
        sta     <hCOLDATA
        rtl

; ------------------------------------------------------------------------------

; [  ]

LoadMenuPal:
@fd1a:  longa
        ldx     #.loword(WindowPal)
        ldy     #$a000
        lda     #$001f
        mvn     #^WindowPal,#$7e
        ldx     #.loword(WindowPal)
        ldy     #$a040
        lda     #$001f
        mvn     #^WindowPal,#$7e
        ldx     #.loword(WindowPal)
        ldy     #$a080
        lda     #$001f
        mvn     #^WindowPal,#$7e
        ldx     #.loword(WindowPal)
        ldy     #$a0c0
        lda     #$001f
        mvn     #^WindowPal,#$7e
        ldx     #.loword(WindowPal)
        ldy     #$a060
        lda     #$0007
        mvn     #^WindowPal,#$7e
        shorta
        rtl

; ------------------------------------------------------------------------------

; [ play sound effect for magic spell ]

PlayMagicSfx:
@fd5b:  jsr     Tax16_2
        lda     f:MagicSfxTbl,x
        jml     PlaySfx_far

; ------------------------------------------------------------------------------

MagicSfxTbl:
@fd66:  .byte   $58,$58,$58,$58,$66,$27,$27,$58,$58,$3d,$1f,$58,$58

; vram address for character graphics
CharGfxVRAMTbl:
@fd73:  .word   $4800,$4b00,$4e00,$5100,$5400

; tile buffer addresses for character blocks (item menu)
; right side and left side
ItemCharBlockTbl:
@fd7d:  .word   $039e,$019e,$059e,$029e,$049e
        .word   $0384,$0184,$0584,$0284,$0484

; ------------------------------------------------------------------------------

; [ get pointer to magic menu cursor positions ]

GetMagicCursorPtr:
@fd91:  lda     $e8         ; character id

_1efd93:
@fd93:  asl
        sta     $45         ; multiply by 6
        asl
        adc     $45
        jmp     Tax16_2

; ------------------------------------------------------------------------------

; [ load magic menu cursor positions ]

LoadMagicCursorPos:
@fd9c:  jsr     GetMagicCursorPtr
        longa
        lda     $1bcd,x
        sta     $1b81
        lda     $1bcf,x
        sta     $1b83
        lda     $1bd1,x
        sta     $1b85
        shorta
        rtl

; ------------------------------------------------------------------------------

; [ save magic menu cursor positions ]

SaveMagicCursorPos:
@fdb6:  jsr     GetMagicCursorPtr
        longa
        lda     $1b81
        sta     $1bcd,x
        lda     $1b83
        sta     $1bcf,x
        lda     $1b85
        sta     $1bd1,x
        shorta
        rtl

; ------------------------------------------------------------------------------

; [  ]

_1efdd0:
@fdd0:  lda     $d9
        jsr     _1efd93
        txy
        lda     $da
        jsr     _1efd93
        longa
        lda     $1bcd,x
        pha
        lda     $1bcf,x
        pha
        lda     $1bd1,x
        pha
        lda     $1bcd,y
        sta     $1bcd,x
        lda     $1bcf,y
        sta     $1bcf,x
        lda     $1bd1,y
        sta     $1bd1,x
        pla
        sta     $1bd1,y
        pla
        sta     $1bcf,y
        pla
        sta     $1bcd,y
        shorta
        rtl

; ------------------------------------------------------------------------------

; portrait positions (10 * 2 bytes)
PortraitPosTbl:
@fe0a:  .byte   $10,$60
        .byte   $10,$10
        .byte   $10,$b0
        .byte   $18,$38
        .byte   $18,$88

@fe14:  .byte   $18,$60
        .byte   $18,$10
        .byte   $18,$b0
        .byte   $10,$38
        .byte   $10,$88

; ------------------------------------------------------------------------------

; dakuten table (menu)
; 2 bytes each, kana then dakuten

DakutenTbl:
@fe1e:  .byte                                                           $cc,$c0
        .byte   $8f,$c0,$90,$c0,$91,$c0,$92,$c0,$93,$c0,$94,$c0,$95,$c0,$96,$c0
        .byte   $97,$c0,$98,$c0,$99,$c0,$9a,$c0,$9b,$c0,$9c,$c0,$9d,$c0,$a3,$c0
        .byte   $a4,$c0,$a5,$c0,$a6,$c0,$a7,$c0,$a3,$c1,$a4,$c1,$a5,$c1,$a6,$c1
        .byte   $a7,$c1,$cf,$c0,$d0,$c0,$d1,$c0,$d2,$c0,$d3,$c0,$d4,$c0,$d5,$c0
        .byte   $d6,$c0,$d7,$c0,$d8,$c0,$d9,$c0,$da,$c0,$db,$c0,$dc,$c0,$dd,$c0
        .byte   $e3,$c0,$e4,$c0,$e5,$c0,$e6,$c0,$e7,$c0,$e3,$c1,$e4,$c1,$e5,$c1
        .byte   $e6,$c1,$e7,$c1

; ------------------------------------------------------------------------------

; [ tax ]

Tax16_2:
@fe84:  sta     $43
        ldx     $43
        rts

; ------------------------------------------------------------------------------

; sprite graphics for window color cursor (1 tile, 4bpp)
WindowColorCursorGfx:
@fe89:  .byte   $20,$00,$70,$20,$88,$30,$88,$30,$88,$30,$88,$30,$70,$00,$20,$00
@fe99:  .byte   $00,$00,$00,$00,$50,$00,$50,$00,$50,$00,$50,$00,$20,$00,$00,$00

; portrait positions for spell target select
MagicPortraitPosTbl:
@fea9:  .byte   $58,$68,$58,$18,$58,$b8,$60,$40,$60,$90  ; 3 front/2 back
@feb3:  .byte   $60,$68,$60,$18,$60,$b8,$58,$40,$58,$90  ; 2 front/3 back

_1efebd:
@febd:  .byte   $6c,$02,$5a,$02,$48,$02

; status mask for items $d5-$dd
ItemStatusMaskTbl:
@fec3:  .word   $ffbf,$ffdf,$ffef,$fff7,$fffb,$fffd,$fffe,$7fff

; ------------------------------------------------------------------------------
