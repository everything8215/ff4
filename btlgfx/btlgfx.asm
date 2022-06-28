
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: btlgfx.asm                                                           |
; |                                                                            |
; | description: battle graphics routines                                      |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

.p816

.include "const.inc"
.include "hardware.inc"
.include "macros.inc"
.include "btlgfx_data.asm"

.import ExecSound_ext, UpdateCtrlBattle_ext

.export ExecBtlGfx_ext

; ------------------------------------------------------------------------------

; bank 02
.segment "btlgfx_code"
.a8
.i16

; *** unused ***
@8000:  nop3

ExecBtlGfx_ext:
@8003:  jmp     ExecBtlGfx_far

; ------------------------------------------------------------------------------

WaitFrame_far:
@8006:  jsr     WaitFrame
        rtl

ExecBtlGfx_far:
@800a:  jsr     ExecBtlGfx
        rtl

; ------------------------------------------------------------------------------

ExecBtlGfx:
@800e:  asl
        tax
        lda     f:BtlGfxTbl,x
        sta     $02
        lda     f:BtlGfxTbl+1,x
        sta     $03
        jmp     ($0002)

; ------------------------------------------------------------------------------

BtlGfxTbl:
@801f:  .addr   OpenMenu
        .addr   CloseMenu
        .addr   WaitFrameMain
        .addr   InitBtlGfx
        .addr   ToggleCharRows
        .addr   BtlGfx_05
        .addr   UpdateInventoryItemText
        .addr   UpdateMagicListName
        .addr   UpdateArrowQty
        .addr   UpdateCmdList
        .addr   UpdateCharNames
        .addr   DrawMonsterNames
        .addr   DrawHPText
        .addr   DrawMPText
        .addr   DrawMagicList
        .addr   WaitFrameAnim
        .addr   MonsterDeath
        .addr   ShowDmgNumerals
        .addr   WinAnim
        .addr   RunAnim
        .addr   UpdateMonsterRows_near
        .addr   WaitMenu

; ------------------------------------------------------------------------------

WaitMenuBattleEnd:
.if EASY_VERSION
        jsr     UpdateEquipmentBuf
.endif

; ------------------------------------------------------------------------------

; [ battle graphics $15: wait for menu ]

WaitMenu:
@804b:  clr_a
        sta     f:$000140               ; disable multi-controller update
        lda     $f44b
        bne     @8058
        inc     $f44b
@8058:  jsr     WaitVblank
        jsr     ImmediateMenuUpdate
        lda     $1821
        bne     @8058
        rts

; ------------------------------------------------------------------------------

; [ battle graphics $14: update monster rows ]

UpdateMonsterRows_near:
@8064:  jsl     UpdateMonsterRows
        rts

; ------------------------------------------------------------------------------

; [ battle graphics $13: party runs away ]

RunAnim:
@8069:  jsr     WaitMenuBattleEnd
        lda     $f425
        beq     @8075
        inc     $f396
        rts
@8075:  stz     $f485
        lda     #$21
        jsr     PlaySfx
        clr_ax
@807f:  lda     $29c5,x
        cmp     #$ff
        beq     @8099
        txa
        asl2
        tay
        stz     $f099,x
        lda     $f015,y
        and     #$c0
        bne     @8099
        lda     #$03                    ; dead characters get h-flip
        sta     $f099,x
@8099:  lda     #1
        sta     $f2bc,x                 ; can't target characters while running
        sta     $f0af,x
        inx
        cpx     #5
        bne     @807f
        inc     $f396
@80aa:  jsr     WaitFrame
        lda     $efcf
        ora     $efdf
        ora     $efef
        ora     $efff
        ora     $f00f
        bne     @80aa
        clr_ax
@80c0:  stz     $efd1,x
        stz     $efd3,x
        txa
        clc
        adc     #$10
        tax
        cpx     #$0050
        bne     @80c0

; start of frame loop
@80d0:  jsr     WaitFrame
        clr_ax
        stz     $02
        stz     $04
@80d9:  lda     $04
        tay
        lda     $29c5,y
        cmp     #$ff
        beq     @810e
        lda     $04
        asl2
        tay
        lda     $f015,y
        and     #$c0
        bne     @810e                   ; branch if dead or stone
        lda     $efc4,x
        beq     @810e
        lda     $efce,x
        ora     #$01
        sta     $efce,x
        jsr     UpdateCharRun_near
        lda     $efc5,x
        cmp     #$f0
        bcc     @8110
        clr_a
        sta     $efc4,x
        inc     $02
        bra     @8110
@810e:  inc     $02
@8110:  inc     $04
        txa
        clc
        adc     #$10
        tax
        cpx     #$0050
        bne     @80d9
        lda     $02                     ; loop until all characters are offscreen
        cmp     #5
        bne     @80d0
        rts

; ------------------------------------------------------------------------------

; [ update character sprite running offscreen (near) ]

UpdateCharRun_near:
@8123:  jsl     UpdateCharRun
        rts

; ------------------------------------------------------------------------------

; [ update character sprite running back onscreen (near) ]

UpdateCharAppear_near:
@8128:  jsl     UpdateCharAppear
        rts

; ------------------------------------------------------------------------------

; [ battle graphics $12: victory animation ]

WinAnim:
@812d:  inc     $f472
        jsr     WaitMenuBattleEnd
        clr_axy
@8136:  tya
        tax
        jsr     GetObjPtr
        lda     $2003,x
        and     #$c0
        bne     @814c                   ; skip if dead or stone
        lda     #$08
        sta     $f099,y
        lda     #1
        sta     $f46d,y
@814c:  iny
        cpy     #5
        bne     @8136
        lda     #$0f
        sta     $f43b
        rts

; ------------------------------------------------------------------------------

; [ battle graphics $06: draw inventory item text ]

UpdateInventoryItemText:
@8158:  ldx     $00
        stx     $1816
        jmp     DrawInventoryItemText

; ------------------------------------------------------------------------------

; [ battle graphics $07:  ]

; unused ???, draw spell name ???

UpdateMagicListName:
@8160:  ldx     $00
        stx     $1816
        jmp     DrawMagicListName

; ------------------------------------------------------------------------------

; [ battle graphics $08: update arrow quantity ]

; $00: character id
; $01: arrow hand (0: left, 1: right)

UpdateArrowQty:
@8168:  ldx     $00
        stx     $1816
        jmp     DrawEquipItemText

; ------------------------------------------------------------------------------

; [ battle graphics $09: draw battle command list ]

UpdateCmdList:
@8170:  lda     $00         ; character id
        sta     $1816
        jmp     DrawCmdList

; ------------------------------------------------------------------------------

; [ battle graphics $04: toggle character rows ]

ToggleCharRows:
@8178:  lda     $f014
        eor     #1
        sta     $f014
        rts

; ------------------------------------------------------------------------------

; [ battle graphics $03: init battle graphics ]

InitBtlGfx:
@8181:  jsr     InitHWRegs
        jsr     InitRAM
        jsr     InitMenuWindows
        jsl     InitScrollHDMA
        jsr     InitGfx
        jsr     InitCharGfx
        jsr     UpdateAnimPos
        jsr     InitTargetCursorPos
        jsr     InitPal
        lda     $6cc0
        beq     @81b0
        lda     $ed4e
        and     #$40
        bne     @81b0                   ; branch if monsters are flying
        lda     #1
        jsr     SwapMonsterScreen
        bra     @81b5

; back attack or flying monsters
@81b0:  lda     #$ff
        jsr     UpdateMonsterEntry
@81b5:  jsr     OpenNameWindow
        lda     #$f2
        sta     $6cc2
        lda     #$1f
        sta     f:hTM
        sta     f:hTMW
@81c7:  lda     f:hRDNMI
        bpl     @81c7
        lda     #$8d
        sta     f:hVTIMEL
        clr_a
        sta     f:hVTIMEH
        sta     f:hHTIMEL
        sta     f:hHTIMEH
        jsl     InitHDMA
        lda     #$a1
        sta     f:hNMITIMEN             ; enable nmi and irq
        cli
        jsr     WaitVblank
        stz     $f13d
        clr_ax
        stx     $1813
        lda     #$16                    ; monster entry takes 24 frames
        sta     $f28e
        lda     #$20
        sta     $f133
        lda     #$10
        sta     $f134

; start of frame loop
@8205:  jsr     WaitVblank
        lda     $f13d
        sta     $6cc1
        cmp     #$0f
        beq     @8215
        inc     $f13d
@8215:  lda     $f133
        beq     @822d
        lda     $f133
        dec
        sta     $f133
        asl3
        and     #$f0
        ora     #$02
        sta     $6cc2
        bra     @8230
@822d:  stz     $6cc2
@8230:  jsr     ImmediateMenuUpdate
        lda     $f28e
        beq     @8251
        lda     $f28e
        dec
        sta     $f28e
        pha
        tax
        lda     f:AnimSineTbl,x   ; sine table
        asl2
        jsr     UpdateMonsterEntry
        pla
        bne     @8251
        clr_a
        jsr     SwapMonsterScreen
@8251:  lda     $181e                   ; wait for menu to open
        ora     $1820
        ora     $f28e                   ; wait for monster entry
        ora     $f133                   ; wait for screen mosaic
        bne     @8205
        inc     $f44a                   ; enable player input
        rts

; ------------------------------------------------------------------------------

; [ update monster entry ]

UpdateMonsterEntry:
@8263:  ldx     #0
        pha
        lda     $ed4e
        and     #$40
        bne     @8287                   ; branch if monsters are flying
        lda     $6cc0
        beq     @8279

; back attack - enter from right
        pla
        eor     #$ff
        inc
        bra     @827a

; normal attack - enter from left
@8279:  pla
@827a:  sta     $7612,x                 ; bg1 h-scroll
        inx4
        cpx     #$0260
        bne     @827a
        rts

; flying monsters - enter from above
@8287:  pla
@8288:  sta     $7614,x                 ; bg1 v-scroll
        inx4
        cpx     #$0260
        bne     @8288
        rts

; ------------------------------------------------------------------------------

; [ battle graphics $02: wait one frame ]

; called from battle main

WaitFrameMain:
@8295:  jsr     WaitVblank
        jsr     ImmediateMenuUpdate
        jsr     PeriodicMenuUpdate
        jsr     UpdateObjPos
        jsr     RedrawMainMenu
        jsl     CheckAutoCloseMenu
        bcc     @82ad
        jsr     CloseMenu
@82ad:  jmp     UpdateObjBuf

; ------------------------------------------------------------------------------

; [ battle graphics $0f: wait one frame ]

; called from battle graphics (redirected from WaitFrame)

WaitFrameAnim:
@82b0:  jsr     WaitVblank
        jsr     ImmediateMenuUpdate
        jsr     PeriodicTextUpdate
;fallthrough

; ------------------------------------------------------------------------------

; [ update character/monster positions ]

; also checks for an empty inventory slot

UpdateObjPos:
@82b9:  jsr     UpdateCharAnimPos
        jsr     UpdateFlyingHDMA
        jsr     UpdateMonsterPos
        clr_axy
@82c5:  lda     $321b,x     ; find an empty item slot
        beq     @82d9
        inx4
        iny
        cpx     #$00c0
        bne     @82c5
        lda     #$ff        ; inventory is full
        bra     @82da
        rts
@82d9:  tya
@82da:  sta     $38f4
        sta     $181d
        rts

; ------------------------------------------------------------------------------

; [ update flying monster v-scroll ]

UpdateFlyingHDMA:
@82e1:  lda     $ed4e
        and     #$40
        beq     @8301       ; return if monsters are not flying
@82e8:  lda     $f353
        beq     @82e8       ; wait for irq
        lda     $1813
        pha
        lsr2
        and     #$0f
        tax
        lda     f:FlyingOffsetTbl,x
        jsr     SetFlyingHDMA
        pla
        sta     $ed4f
@8301:  rts

; ------------------------------------------------------------------------------

; [ set monster hdma v-scroll value ]

SetFlyingHDMA:
@8302:  ldx     #0
@8305:  sta     $7614,x
        sta     $76a0,x
        sta     $772c,x
        sta     $77b8,x
        inx4
        cpx     #$008c
        bne     @8305
        rts

; ------------------------------------------------------------------------------

; [ transfer shadow graphics to vram ]

TfrShadowGfx:
@831b:  lda     $ed4e
        and     #$40
        beq     @8344       ; branch if monsters are not flying
        lda     $ed4f
        lsr2
        and     #$0f
        tax
        lda     f:FlyingShadowTbl,x
        longa
        clc
        adc     #$d9e6
        tax
        lda     #$0040
        sta     $0e
        shorta
        lda     #$7e
        ldy     #$4510
        jsr     TfrVRAM4
@8344:  rts

; ------------------------------------------------------------------------------

; [ battle nmi ]

BattleNMI:
@8345:  php
        longai
        pha
        phx
        phy
        phb
        phd
        ldx     #$0000
        phx
        pld
        shorta0
        lda     f:hRDNMI
        lda     #$7e
        pha
        plb
        lda     $1812
        beq     @8365
        jmp     @83c6
@8365:  stz     $f47e
        inc     $1812
        stz     $f353                   ; clear irq flag
        jsl     TfrSprites
        jsl     TfrPal
        jsr     TfrShadowGfx
        jsr     TfrAnimGfx
        jsr     TfrMenuTilesUpdate
        lda     $6cc1
        sta     f:hINIDISP              ; set screen brightness
        lda     $6cc2
        sta     f:hMOSAIC
        jsl     UpdateColorMath
        jsr     UpdateMenuHDMA
        jsl     UpdateCtrl
        jsl     CheckPause
        bcs     @83a4                   ; branch if paused
        inc     $f47e
        jsr     UpdateCursor
@83a4:  jsr     DrawMenuCursors
        jsr     DrawTargetCursors
        jsr     DrawListArrows
        jsr     UpdateTargetCursors
        jsr     UpdateCharSprites
        jsr     DrawWeaponHit
        jsr     DrawWeaponSprite
        jsr     UpdateAnimSprites
        jsr     UpdateTargetPal
        jsr     DrawDmgNumerals
        jsl     UpdateSummon
@83c6:  lda     $7ef47e
        beq     @83d5
        lda     $38d9
        bne     @83d5
        jsl     IncGameTime
@83d5:  longai
        inc     $1813       ; increment frame counter
        pld
        plb
        ply
        plx
        pla
        plp
        rti

.a8

; ------------------------------------------------------------------------------

; [ clear vram ]

; +X: start address (vram)
; +Y: size (in bytes)

ClearVRAM:
@83e1:  phb
        clr_a
        pha
        plb
        stx     hVMADDL
        ldx     #.loword(@Zero)
        stx     $4352
        lda     #$09
        sta     $4350
        lda     #$18
        sta     $4351
        lda     #^@Zero
        sta     $4354
        sty     $4355
        lda     #$20
        sta     hMDMAEN
        plb
        rts

@Zero:
@8407:  .word   0

; ------------------------------------------------------------------------------

; [ transfer summon graphics to vram ]

;  A: source bank
; +X: source address

TfrSummonGfx:
@8409:  pha
        phx
        phy
        stx     $f371
        sta     $f373
        stz     $f370
        stz     $f374
@8418:  lda     $efa8                   ; wait for animation graphics transfer
        ora     $efb1
        beq     @8426
        jsr     WaitFrame
        jmp     @8418

; start of frame loop
@8426:  ldx     $f371
        stx     $00
        lda     $f373
        sta     $02
        stz     $04
        stz     $07

; start of tile loop
@8434:  lda     $f370
        tay
        lda     [$00],y
        bmi     @846f

; not a blank tile
        sta     $06                     ; tile vram offset
        lda     $04
        asl2
        tay
        lda     $f374
        longa
        asl5
        clc
        adc     #$dbe6                  ; copy from graphics buffer
        sta     $f360,y
        lda     $06
        asl4
        sta     $f362,y
        shorta0
        lda     $04
        tax
        inc     $f35c,x
        inc     $f370
        inc     $f374
        jmp     @8499

; check for terminator
@846f:  cmp     #$ff
        beq     @84a7                   ; branch if terminator

; blank tile
        and     #$7f
        sta     $06                     ; tile vram offset
        lda     $04
        asl2
        tay
        longa
        lda     #$f376                  ; blank tile buffer
        sta     $f360,y
        lda     $06
        asl4
        sta     $f362,y
        shorta0
        lda     $04
        tax
        inc     $f35c,x
        inc     $f370
@8499:  inc     $04
        lda     $04
        cmp     #4                      ; transfer 4 tiles per frame
        bne     @8434
        jsr     WaitFrame
        jmp     @8426
@84a7:  jsr     WaitFrame
        ply
        plx
        pla
        rts

; ------------------------------------------------------------------------------

; [ execute transfer to vram (far) ]

ExecTfr_far:
@84ae:  jsr     ExecTfr
        rtl

; ------------------------------------------------------------------------------

; [ execute transfer to vram ]

;    A: source bank
;   +X: source address
;   +Y: destination address (vram)
; +$00: size

ExecTfr:
@84b2:  pha
        phx
        phy
        ldx     $00
        phx
@84b8:  lda     $efa8
        ora     $efb1
        beq     @84c5
        jsr     WaitFrame
        bra     @84b8
@84c5:  plx
        stx     $00
        ply
        plx
        pla
        sta     $efaf
        stx     $efa9
        sty     $efab
        ldx     #$0080
        stx     $efad
        longa
        lda     $00
        asl
        and     #$ff00
        sta     $00
        shorta0
        lda     $01
        sta     $efb0                   ; number of blocks
@84ec:  inc     $efa8
        jsr     WaitFrame
        dec     $efb0
        beq     @8512
        longa
        lda     $efa9
        clc
        adc     #$0080                  ; transfer 128 bytes per frame
        sta     $efa9
        lda     $efab
        clc
        adc     #$0040
        sta     $efab
        shorta0
        bra     @84ec
@8512:  rts

; ------------------------------------------------------------------------------

; [ wait one frame ]

WaitFrame:
@8513:  phy
        phx
        lda     #$0f        ; battle graphics $0f: wait one frame
        jsl     ExecBtlGfx_ext
        plx
        ply
        rts

; ------------------------------------------------------------------------------

; [ wait for vblank ]

WaitVblank:
@851e:  inc     $1811
@8521:  lda     $1811
        bne     @8521
        rts

; ------------------------------------------------------------------------------

; [ divide (far) ]

Div16_far:
@8527:  jsr     Div16
        rtl

; ------------------------------------------------------------------------------

; [ divide ]

Div16:
@852b:  phx
        longa
        pha
        stz     $2a
        stz     $2c
        lda     $26
        beq     @8557
        lda     $28
        beq     @8557
        ldx     #$0010
@853e:  rol     $26
        rol     $2c
        sec
        lda     $2c
        sbc     $28
        sta     $2c
        bcs     @8552
        lda     $2c
        adc     $28
        sta     $2c
        clc
@8552:  rol     $2a
        dex
        bne     @853e
@8557:  pla
        shorta
        plx
        rts

; ------------------------------------------------------------------------------

; [ multiply (8-bit, far) ]

Mult8_far:
@855c:  jsr     Mult8
        rtl

; ------------------------------------------------------------------------------

; [ multiply (8-bit) ]

; +$2a = $26 * $28

Mult8:
@8560:  phx
        ldx     #8
        stz     $2a
        stz     $2b
@8568:  ror     $28
        bcc     @8573
        lda     $26
        clc
        adc     $2b
        sta     $2b
@8573:  ror     $2b
        ror     $2a
        dex
        bne     @8568
        plx
        rts

; ------------------------------------------------------------------------------

; [ multiply (16-bit) ]

; +++$2c = +$26 * +$28

Mult16:
@857c:  phx
        longa
        pha
        clr_a
        sta     $2e
        sta     $2a
        sta     $2c
        ldx     #$0010
@858a:  lsr     $26
        bcc     @859b
        clc
        lda     $2a
        adc     $28
        sta     $2a
        lda     $2c
        adc     $2e
        sta     $2c
@859b:  asl     $28
        rol     $2e
        dex
        bne     @858a
        pla
        shorta
        plx
        rts

; ------------------------------------------------------------------------------

; [ multiply (16-bit) ]

; +++$22 = +$1c * +$1e
; unused

Mult16_2:
@85a7:  phx
        longa
        pha
        clr_a
        sta     $24
        sta     $20
        sta     $22
        ldx     #$0010
@85b5:  lsr     $1c
        bcc     @85c6
        clc
        lda     $20
        adc     $1e
        sta     $20
        lda     $22
        adc     $24
        sta     $22
@85c6:  asl     $1e
        rol     $24
        dex
        bne     @85b5
        pla
        shorta
        plx
        rts

; ------------------------------------------------------------------------------

; [ hardware multiply ]

MultHW:
@85d2:  phx
        lda     $1c
        sta     f:hWRMPYA
        lda     $1e
        sta     f:hWRMPYB
        phb
        clr_a
        pha
        plb
        ldx     hRDMPYL
        stx     $20
        plb
        plx
        rts

; ------------------------------------------------------------------------------

; [ hardware divide ]

DivHW:
@85eb:  phx
        phb
        clr_a
        pha
        plb
        stz     $1f
        ldx     $1c
        stx     hWRDIVL
        lda     $1e
        sta     hWRDIVB
        ldx     #4
@85ff:  dex
        bne     @85ff
        ldx     hRDDIVL
        stx     $20
        ldx     hRDMPYL
        stx     $22
        plb
        plx
        rts

; ------------------------------------------------------------------------------

; [ transfer 3bpp graphics to vram ]

Tfr3bppGfx:
@860f:  phb
        pha
        plb
        sty     hVMADDL
        stx     $02
        ldy     #0
@861a:  longa
        pha
        ldx     #8
@8620:  lda     ($02),y
        sta     hVMDATAL
        iny2
        dex
        bne     @8620
        ldx     #8
        pla
        shorta
@8630:  lda     ($02),y
        sta     hVMDATAL
        stz     hVMDATAH
        iny
        dex
        bne     @8630
        dec     $00
        bne     @861a
        plb
        rts

; ------------------------------------------------------------------------------

; [ transfer 3bpp graphics to vram ]

; *** unused ***

Tfr3bppGfx2:
@8642:  phb
        pha
        plb
        sty     hVMADDL
        stx     $10
        ldy     #0
@864d:  longa
        pha
        ldx     #8
@8653:  lda     ($10),y
        sta     hVMDATAL
        iny2
        dex
        bne     @8653
        ldx     #8
        pla
        shorta
@8663:  lda     ($10),y
        sta     hVMDATAL
        stz     hVMDATAH
        iny
        dex
        bne     @8663
        dec     $0e
        bne     @864d
        plb
        rts

; ------------------------------------------------------------------------------

; [ transfer 4bpp graphics to vram (channel 5) ]

; mostly used to transfer 4bpp graphics, but also transfers tiles sometimes

TfrVRAM5:
@8675:  phb
        pha
        clr_a
        pha
        plb
        pla
        sty     hVMADDL
        stx     $4352
        sta     $4354
        lda     #$01
        sta     $4350
        lda     #<hVMDATAL
        sta     $4351
        ldx     $00
        stx     $4355
        lda     #$20
        sta     hMDMAEN
        plb
        rts

; ------------------------------------------------------------------------------

; [ transfer tile data to vram (channel 4) ]

; mostly used to transfer tilemap data

TfrVRAM4:
@869a:  phb
        pha
        clr_a
        pha
        plb
        pla
        sty     hVMADDL
        stx     $4342
        sta     $4344
        lda     #$01
        sta     $4340
        lda     #<hVMDATAL
        sta     $4341
        ldx     $0e
        stx     $4345
        lda     #$10
        sta     hMDMAEN
        plb
        rts

; ------------------------------------------------------------------------------

; [ convert hex to decimal (5 digit number) ]

HexToDec:
@86bf:  stx     $26
        ldx     #10000
        stx     $28
        jsr     Div16
        lda     $2a
        clc
        adc     #$80
        sta     $180c
        ldx     $2c
        stx     $26
        ldx     #1000
        stx     $28
        jsr     Div16
        lda     $2a
        clc
        adc     #$80
        sta     $180d
        ldx     $2c
        stx     $26
        ldx     #100
        stx     $28
        jsr     Div16
        lda     $2a
        clc
        adc     #$80
        sta     $180e
        ldx     $2c
        stx     $26
        ldx     #10
        stx     $28
        jsr     Div16
        lda     $2a
        clc
        adc     #$80
        sta     $180f
        lda     $2c
        clc
        adc     #$80
        sta     $1810
        rts

; ------------------------------------------------------------------------------

; [ normalize number text (5 digit number) ]

NormalizeNum:
@8716:  ldx     #0
@8719:  lda     $180d,x                 ; shift out the top digit
        sta     $180c,x
        inx
        cpx     #5
        bne     @8719
        ldx     #0
@8728:  lda     $180c,x
        cmp     #$80
        bne     @873a                   ; return if digit is not zero
        lda     #$ff
        sta     $180c,x                 ; hide digit
        inx
        cpx     #3                      ; don't hide ones digit
        bne     @8728
@873a:  rts

; ------------------------------------------------------------------------------

; [ normalize battle variable text (7 digit number) ]

NormalizeVar:
@873b:  ldx     #0
@873e:  lda     $f4ad,x
        cmp     #$80
        bne     @8750
        lda     #$ff
        sta     $f4ad,x
        inx
        cpx     #7
        bne     @873e
@8750:  rts

; ------------------------------------------------------------------------------

; character cursor data
CharCursorTbl:
@8751:  .byte   $bc,$ff,$ab,$ff,$c9,$ff,$98,$ff,$8a,$ff

; ------------------------------------------------------------------------------

; [ init target cursor positions ]

InitTargetCursorPos:
@875b:  ldx     #0
@875e:  lda     f:CharCursorTbl,x
        sta     $29df,x
        inx
        cpx     #5*2
        bne     @875e
        jsr     InitMonsterCursorY

; init monster cursor horizontal order
        ldx     #0
        ldy     #0
        stz     $02
@8776:  lda     $29a5,x                 ; monster x position
        lsr4
        sta     $74fd,y
        lda     $29a5,x
        and     #$0f
        sta     $74fe,y
        iny2
        lda     $02
        sta     $f333,x
        sta     $f33b,x
        inc     $02
        inx
        cpx     #8
        bne     @8776
        jsr     SortMonsterCursorX
        ldx     #0
        ldy     #7
@87a3:  lda     $f33b,y
        sta     $f333,x
        dey
        inx
        cpx     #8
        bne     @87a3
        rts

; ------------------------------------------------------------------------------

; [ sort monsters horizontally ]

SortMonsterCursorX:
@87b1:  lda     #$20                    ; repeat 32 times
        sta     $02
@87b5:  ldx     #0
        ldy     #0
@87bb:  lda     $74fd,x                 ; check x first
        cmp     $74ff,x
        bne     @87d1
        lda     $74fe,x
        cmp     $7500,x
        bcc     @87d6
        jsr     SwapMonsterCursorX
        jmp     @87d6
@87d1:  bcc     @87d6
        jsr     SwapMonsterCursorX
@87d6:  inx2
        iny
        cpx     #7*2
        bne     @87bb
        dec     $02
        bne     @87b5
        rts

; ------------------------------------------------------------------------------

; [ init vertical monster order ]

InitMonsterCursorY:
@87e3:  ldx     #0
        ldy     #0
        stz     $02
@87eb:  lda     $29a5,x                 ; copy monster xy positions to buffer
        lsr4
        sta     $74fd,y
        lda     $29a5,x
        and     #$0f
        sta     $74fe,y
        iny2
        lda     $02
        sta     $f343,x
        sta     $f34b,x
        inc     $02
        inx
        cpx     #8
        bne     @87eb
        jsr     SortMonsterCursorY
        ldx     #0
        ldy     #7
@8818:  lda     $f343,y
        sta     $f34b,x
        dey
        inx
        cpx     #8
        bne     @8818
        rts

; ------------------------------------------------------------------------------

; [ sort monsters vertically ]

SortMonsterCursorY:
@8826:  lda     #$20                    ; repeat 32 times
        sta     $02
@882a:  ldx     #0
        ldy     #0
@8830:  lda     $74fe,x                 ; check y position
        cmp     $7500,x
        bne     @8846
        lda     $74fd,x
        cmp     $74ff,x
        bcc     @884b
        jsr     SwapMonsterCursorY
        jmp     @884b
@8846:  bcc     @884b
        jsr     SwapMonsterCursorY
@884b:  inx2
        iny
        cpx     #7*2
        bne     @8830
        dec     $02
        bne     @882a
        rts

; ------------------------------------------------------------------------------

; [ swap monster cursor order ]

SwapMonsterCursorX:
@8858:  lda     $f33b,y
        sta     $00
        lda     $f33c,y
        sta     $f33b,y
        lda     $00
        sta     $f33c,y
        jmp     _887b

SwapMonsterCursorY:
@886b:  lda     $f343,y                 ; swap monster slots
        sta     $00
        lda     $f344,y
        sta     $f343,y
        lda     $00
        sta     $f344,y
_887b:  lda     $74ff,x                 ; swap xy positions
        sta     $00
        lda     $74fd,x
        sta     $74ff,x
        lda     $00
        sta     $74fd,x
        lda     $7500,x
        sta     $00
        lda     $74fe,x
        sta     $7500,x
        lda     $00
        sta     $74fe,x
        rts

; ------------------------------------------------------------------------------

; [ update monster sizes ]

UpdateMonsterSizes:
@889c:  ldy     #0
@889f:  lda     $29bd,y                 ; monster type
        asl
        tax
        lda     $6cc3,x                 ; monster width
        sta     $00
        lda     $6cc4,x                 ; monster height
        sta     $01
        tya
        asl
        tax
        stx     $02
        lda     $00
        sta     $f2a1,x
        lda     $01
        sta     $f2a2,x
        sty     $26
        lda     #$80
        sta     $28
        jsr     Mult8
        ldx     $2a
        lda     $2285,x
        and     #$20
        beq     @88d4                   ; branch if not an egg
        ldx     $02
        jmp     @88ec
@88d4:  lda     $2283,x
        ldx     $02
        and     #$38
        beq     @88f4                   ; branch if not toad, mini, or pig
        and     #$30
        beq     @88ec
        lda     #$02                    ; toad, mini, and pig are 2x2
        sta     $f2a1,x
        sta     $f2a2,x
        jmp     @88f4
@88ec:  lda     #$04                    ; egg is 4x4
        sta     $f2a1,x
        sta     $f2a2,x
@88f4:  iny
        cpy     #8
        bne     @889f
        rts

; ------------------------------------------------------------------------------

; [ update character/monster positions for animations ]

UpdateAnimPos:
@88fb:  jsl     UpdateMonsterAnimPos
        jsr     UpdateCharAnimPos
        jmp     UpdateMonsterSizes

; ------------------------------------------------------------------------------

; [ update character positions for animation ]

UpdateCharAnimPos:
@8905:  ldx     #0
@8908:  lda     $6cf3,x                 ; update character x positions
        sta     $f053,x
        sta     $f039,x
        clc
        adc     #$18
        sta     $f06d,x
        lda     $6cf4,x                 ; update character y positions
        sta     $f054,x
        sta     $f03a,x
        clc
        adc     #$18
        sta     $f06e,x
        inx2
        cpx     #5*2
        bne     @8908
        rts

; ------------------------------------------------------------------------------

; [ update object buffers from main battle module ]

UpdateObjBuf:
@892e:  lda     #5
        sta     $00
        clr_a
        sta     $02
        ldx     #0
        ldy     #0
@893b:  longa
        lda     $2003,x                 ; update character status buffers
        sta     $f015,y
        lda     $2005,x
        sta     $f017,y
        txa
        clc
        adc     #$0080
        tax
        tya
        clc
        adc     #4
        tay
        shorta0
        phy
        lda     $02
        tay
        lda     $1f80,x
        dec
        cmp     #$ff
        beq     @8966
        lda     $02
@8966:  sta     $29c5,y                 ; update character id buffer
        ply
        inc     $02
        dec     $00
        bne     @893b
        ldx     #0
@8973:  lda     $29b5,x                 ; update monster type buffer
        sta     $f123,x
        inx
        cpx     #8
        bne     @8973
        rts

; ------------------------------------------------------------------------------

; [ clear sprite data ]

ResetSprites:
@8980:  ldx     #0
        lda     #$f0
@8985:  sta     $0300,x
        inx
        cpx     #$0220
        bne     @8985
        rts

; ------------------------------------------------------------------------------

; [ init battle graphics ram ]

InitRAM:
@898f:  jsl     ResetRAM
        jsl     TfrPal
        jsr     ResetSprites
        jsr     ClearTileBuf
        ldy     #$5800
        jsr     TfrTileBuf
        ldy     #$5c00
        jsr     TfrTileBuf
        ldy     #$6000
        jsr     TfrTileBuf
        ldy     #$6400
        jsr     TfrTileBuf
        ldy     #$6800
        jsr     TfrTileBuf
        ldy     #$6c00
        jsr     TfrTileBuf
        jsr     UpdateObjBuf
        jsr     InitCharSprites
        lda     #1
        sta     f:$000140     ; enable multi-controller update
        jmp     _02f91e

; ------------------------------------------------------------------------------

; [ init hardware registers ]

InitHWRegs:
@89d0:  clr_a
        pha
        plb
        sta     hNMITIMEN               ; disable nmi and irq
        sta     hSETINI
        sta     hCGSWSEL
        lda     #^BattleNMI
        sta     $0203
        ldx     #.loword(BattleNMI)
        stx     $0201
        lda     #$5c                    ; jml
        sta     $0200
        sta     $0204
        lda     #^BattleIRQ
        sta     $0207
        ldx     #.loword(BattleIRQ)
        stx     $0205
        ldx     #$7000
        ldy     #$2000
        jsr     ClearVRAM
        ldx     #$4000
        ldy     #$0020
        jsr     ClearVRAM
        ldx     #$1ff0
        ldy     #$0020
        jsr     ClearVRAM
        lda     #$33
        sta     hW12SEL
        sta     hWOBJSEL
        lda     #$08
        sta     hWH0
        lda     #$f8
        sta     hWH1
        clr_a
        sta     hTMW
        sta     hTSW
        lda     #$7e
        pha
        plb
        longa
        lda     $1800                   ; battle id
        sta     $26
        lda     #8
        sta     $28
        shorta0
        jsr     Mult16
        ldx     $2a
        lda     f:BattleProp+6,x
        sta     $ed4e
        stz     $ef87                   ; disable color flash
        rts

; ------------------------------------------------------------------------------

; [ battle irq ]

BattleIRQ:
@8a51:  php
        longa
        pha
        shorta
        lda     f:hTIMEUP
        lda     #$01
        sta     $7ef353     ; set irq flag
        longa
        pla
        plp
        rti

.a8

; ------------------------------------------------------------------------------

.include "ppu.asm"
.include "menu.asm"
.include "cursor.asm"

; ------------------------------------------------------------------------------

; [ do special animation ]

DoSpecialAnim_near:
@bc9d:  jsl     DoSpecialAnim_far
        rts

; ------------------------------------------------------------------------------

; [ draw attack name window ]

DrawAttackNameWindow:
@bca2:  lda     $6cc0
        beq     @bcaa
        jmp     DrawLeftMsgWindow
@bcaa:  jmp     DrawRightMsgWindow

; ------------------------------------------------------------------------------

; [ transfer monster tiles to vram ]

TfrRightMonsterTiles:
@bcad:  ldy     #$6000                  ; right screen
        bra     _bcb5

TfrLeftMonsterTiles:
@bcb2:  ldy     #$6400                  ; left screen
_bcb5:  ldx     #$0480
        stx     $00
        lda     #$7e
        ldx     #$6cfd
        jmp     ExecTfr

; ------------------------------------------------------------------------------

; [ swap visible monster screen ]

; A: 0 or 1 for left or right screen

SwapMonsterScreen:
@bcc2:  ldx     #0
@bcc5:  sta     $7613,x     ; set bg1 h-scroll hdma data
        inx4
        cpx     #$0230
        bne     @bcc5
        rts

; ------------------------------------------------------------------------------

; [ set monster animation palette to black and white ]

; used for flashing active monster

LoadMonsterFlashPal:
@bcd2:  clr_ay
@bcd4:  clr_a
        sta     $ee30,y
        inx
        iny
        cpy     #$0020
        bne     @bcd4
        ldx     #$7fff
        stx     $ee32
        rts

; ------------------------------------------------------------------------------

; [ flash active monster ]

FlashMonster:
@bce6:  stz     $4e
        lda     #1
        jsr     SwapMonsterScreen
@bced:  jsr     WaitFrame
        lda     $4e
        and     #$04                    ; swap every 4 frames
        lsr2
        eor     #1
        jsr     SwapMonsterScreen
        inc     $4e
        lda     $4e
        cmp     #$10                    ; 16 frames total
        bne     @bced
        clr_a
        jmp     SwapMonsterScreen

; ------------------------------------------------------------------------------

; [  ]

_02bd07:
@bd07:  longa
        lda     $00
        and     #$001f
        cmp     #$001f
        beq     @bd1b
        lda     $00
        clc
        adc     #$0001
        sta     $00
@bd1b:  lda     $00
        and     #$03e0
        cmp     #$03e0
        beq     @bd2d
        lda     $00
        clc
        adc     #$0020
        sta     $00
@bd2d:  lda     $00
        and     #$7c00
        cmp     #$7c00
        beq     @bd3f
        lda     $00
        clc
        adc     #$0400
        sta     $00
@bd3f:  shorta0
        rts

; ------------------------------------------------------------------------------

; [ decrement color components ]

; +$00: color
;    A: decrement amount

DecColor:
@bd43:  sta     $26
        stz     $27
        longa
        lda     $26
        asl5
        sta     $28
        asl5
        sta     $2a

; red
        lda     $00
        and     #$001f
        beq     @bd74
        cmp     $26
        bcc     @bd6d
        lda     $00
        sec
        sbc     $26
        sta     $00
        bra     @bd74

; set red component to zero
@bd6d:  lda     $00
        and     #$7fe0
        sta     $00

; green
@bd74:  lda     $00
        and     #$03e0
        beq     @bd8f
        cmp     $28
        bcc     @bd88
        lda     $00
        sec
        sbc     $28
        sta     $00
        bra     @bd8f

; set green component to zero
@bd88:  lda     $00
        and     #$3e1f
        sta     $00

; blue
@bd8f:  lda     $00
        and     #$7c00
        beq     @bdaa
        cmp     $2a
        bcc     @bda3
        lda     $00
        sec
        sbc     $2a
        sta     $00
        bra     @bdaa

; set blue component to zero
@bda3:  lda     $00
        and     #$03ff
        sta     $00
@bdaa:  shorta0
        rts

; ------------------------------------------------------------------------------

; [ step forward to attack ]

StepForwardToAttack:
@bdae:  lda     $34c2
        bmi     @bdd2                   ; return if monster attacker
        lda     $3529
        bne     @bdd2
        lda     $48
        tax
        lda     #1
        sta     $f0af,x
        stz     $f099,x
        jsr     GetAttackerCharSpritePtr
@bdc6:  phx
        jsr     WaitFrame
        plx
        lda     $efc5,x                 ; move to x = 192
        cmp     #$c0
        bne     @bdc6
@bdd2:  rts

; ------------------------------------------------------------------------------

; [  ]

_02bdd3:
@bdd3:  clr_axy
@bdd6:  longa
        lda     $f2d4,y
        sta     $f2f4,y
        lda     $f2d6,y
        sta     $f2f6,y
        lda     $2283,x                 ; monster status
        sta     $f2d4,y
        lda     $2285,x
        sta     $f2d6,y
        txa
        clc
        adc     #$0080
        tax
        shorta0
        iny4
        cpx     #$0400
        bne     @bdd6
        clr_ax
@be04:  lda     $f2d4,x
        and     #$f8
        asl
        sta     $00
        lda     $f2d6,x
        asl2
        and     #$80
        ora     $00
        sta     $00
        lda     $f2f4,x
        and     #$f8
        asl
        sta     $01
        lda     $f2f6,x
        asl2
        and     #$80
        ora     $01
        sta     $01
        cmp     $00
        beq     @be4c
        lda     $00
        eor     $01
        sta     $03
        lda     $00
        and     $01
        sta     $02
        clr_ay
@be3c:  asl     $03
        bcs     @be4a
        asl     $02
        bcs     @be4c
        iny
        cpy     #4
        bne     @be3c
@be4a:  bra     _02be56
@be4c:  inx4
        cpx     #$0020
        bne     @be04
        rts

; ------------------------------------------------------------------------------

; [ boss flash transition ]

_02be56:
@be56:  phx
        lda     #$07
        sta     $f314
@be5c:  lda     $f314
        sta     $f315
@be62:  jsr     WaitFrame
        clr_a
        jsr     SwapMonsterScreen
        dec     $f315
        bne     @be62
        lda     #$08
        sec
        sbc     $f314
        sta     $f315
@be77:  jsr     WaitFrame
        lda     #1
        jsr     SwapMonsterScreen
        dec     $f315
        bne     @be77
        dec     $f314
        bne     @be5c
        plx
        rts

; ------------------------------------------------------------------------------

; [ restore graphics after magic animation ]

AfterMagicAnim:
@be8b:  jsr     ResetAnimSpritesLarge
        lda     $f35a
        beq     @beaa
        lda     #$ff
        sta     $f320
        jsr     LightenBattleBG
        jsr     WaitFrame
        jsr     _02c736
        stz     $f35a
        stz     $f320
        jsr     CharSpritesSummonAnim
@beaa:  rts

; ------------------------------------------------------------------------------

; [ execute graphics script (far) ]

ExecGfxScript_far:
@beab:  jsr     ExecGfxScript
        rtl

; ------------------------------------------------------------------------------

; [ battle graphics $05: graphics script ]

BtlGfx_05:
@beaf:  jsr     RedrawMainMenu
        jsr     ExecGfxScript
        lda     $f474
        beq     @bec1       ; branch if not mist dragon vs. golbez
        jsl     ShowMistVsGolbez
        stz     $f474
@bec1:  rts

; ------------------------------------------------------------------------------

; [ init buffer pointers ]

InitBufPtrs:
@bec2:  ldx     #$33c2      ; graphics script buffer
        stx     $3f
        ldx     #$3522      ; reflected targets
        stx     $43
        ldx     #$34d4      ; damage buffer
        stx     $41
        ldx     #$34ca      ; battle messages
        stx     $45
        rts

; ------------------------------------------------------------------------------

; [ battle graphics $11: display damage numerals ]

ShowDmgNumerals:
@bed7:  jsr     InitBufPtrs
        jmp     ShowMsg_04

; ------------------------------------------------------------------------------

; [ restore monster tilemap after animation ??? ]

_02bedd:
@bedd:  jsr     TfrLeftMonsterTiles
        lda     #1
        jsr     SwapMonsterScreen
        jsr     _02bdd3
        jsr     TfrRightMonsterTiles
        clr_a
        jsr     SwapMonsterScreen
        rtl

; ------------------------------------------------------------------------------

; [ execute graphics script ]

ExecGfxScript:
@bef0:  lda     $f425
        beq     @bef6
        rts
@bef6:  stz     $f35a
        jsr     WaitFrame
        jsr     InitBufPtrs
        lda     $34c3       ; attacker id
        sta     $48
        clr_ax
@bf06:  lda     f:BitOrTbl,x
        cmp     $34c5       ; find first target
        beq     @bf17
        inx
        cpx     #8
        bne     @bf06
        clr_ax              ; zero if no targets found
@bf17:  txa
        sta     $49         ; target id
        lda     $34c2
        bpl     @bf4f       ; branch if character attacker
        lda     $ed4e
        and     #$10
        bne     @bf4f       ; branch if enemy character
        lda     $34c2
        and     #$40
        bne     @bf4f       ; branch if monster flash is disabled
        jsr     _02e8dd
        jsr     UpdateBG1Tiles
        jsr     _02e8e2
        lda     $48         ; attacker
        sta     $f109
        lda     #$07
        sta     $f10a
        jsr     _028a89
        jsr     ModifyBG1Tiles_near
        jsr     LoadMonsterFlashPal
        jsr     TfrLeftMonsterTiles
        jsr     FlashMonster
@bf4f:  lda     ($3f)
        cmp     #$a9
        bcc     @bf7f
        cmp     #$c0
        bcc     @bf6f
        cmp     #$e8
        bcc     @bf77
        cmp     #$ff
        beq     @bf87
        cmp     #$f0
        bcc     @bf6a

; $f0-$fe: other commands
        jsr     DoGfxScriptCmd
        bra     @bf82

; $e8-$ef: unused
@bf6a:  jsr     UnusedGfxScriptCmd2
        bra     @bf82

; $a9-$bf: special animation
@bf6f:  jsr     DoSpecialAnim_near
        jsr     GetNextGfxScriptByte
        bra     @bf4f

; $c0-$e7: command animation
@bf77:  jsr     DoCmdAnim
        jsr     ResetAnimSpritesLarge
        bra     @bf82

; $00-$a8: magic animation
@bf7f:  jsr     DoMagicAnim
@bf82:  jsr     GetNextGfxScriptByte
        bra     @bf4f

; $ff: end of script
@bf87:  clr_ax
@bf89:  stz     $f0af,x                 ; make character step back
        inx
        cpx     #5
        bne     @bf89
        jsr     MonsterDeath
        jsr     LoadMonsterTiles
        jsl     _02bedd
        clr_ax
        stx     $0a
@bfa0:  phx
        txa
        tay
        jsr     GetObjPtr
        lda     $2003,x
        and     #$08
        beq     @bfb8
        lda     $f235,y
        cmp     #$0e
        beq     @bfe1
        lda     #$0e
        bra     @bfc4
@bfb8:  lda     $f235,y
        cmp     #$0e
        bne     @bfe1
        lda     $2001,x
        and     #$1f
@bfc4:  sta     $f235,y
        pha
        tya
        asl2
        tay
        lda     $f015,y
        and     #$c7
        sta     $00
        lda     $2003,x
        and     #$38
        ora     $00
        sta     $f015,y
        pla
        jsr     ReloadCharGfx
@bfe1:  longa
        lda     $0a
        clc
        adc     #$0400
        sta     $0a
        shorta0
        plx
        inx
        cpx     #5
        bne     @bfa0
        jsr     WaitMsgWindow
        jmp     CloseMsgWindow

; ------------------------------------------------------------------------------

; [ reload character graphics ]

; A: character graphics id

ReloadCharGfx:
@bffb:  phx
        cmp     #$0f
        bcc     @c006
        jsr     GetExtraCharGfxPtr
        jmp     @c011
@c006:  tax
        stx     $26
        ldx     #$0800
        stx     $28
        jsr     Mult16
@c011:  longa
        lda     $2a
        clc
        adc     #.loword(BattleCharGfx)
        tax
        lda     #$0800
        sta     $00
        shorta0
        ldy     $0a
        lda     #^BattleCharGfx
        jsr     ExecTfr
        plx
        rts

; ------------------------------------------------------------------------------

; [ get next graphics script byte ]

GetNextGfxScriptByte:
@c02b:  ldx     $3f
        inx
        stx     $3f
        lda     ($3f)
        rts

; ------------------------------------------------------------------------------

.include "cmd_anim.asm"

; ------------------------------------------------------------------------------

; [ wait ]

; +X: number of frames to wait

WaitX:
@c8a0:  jsr     WaitFrame
        dex
        bne     @c8a0
        rts

; ------------------------------------------------------------------------------

; [ do graphics script command $f0-$fe ]

DoGfxScriptCmd:
@c8a7:  sec
        sbc     #$f0
        asl
        tax
        lda     f:GfxScriptCmdTbl,x
        sta     $00
        lda     f:GfxScriptCmdTbl+1,x
        sta     $01
        jmp     ($0000)

; ------------------------------------------------------------------------------

; graphics script command $f0-$fe jump table
GfxScriptCmdTbl:
@c8bb:  .addr   GfxScriptCmd_f0
        .addr   GfxScriptCmd_f1
        .addr   GfxScriptCmd_f2
        .addr   GfxScriptCmd_f3
        .addr   UnusedGfxScriptCmd2
        .addr   UnusedGfxScriptCmd2
        .addr   UnusedGfxScriptCmd2
        .addr   GfxScriptCmd_f7
        .addr   GfxScriptCmd_f8
        .addr   UnusedGfxScriptCmd2
        .addr   UnusedGfxScriptCmd1
        .addr   UnusedGfxScriptCmd1
        .addr   UnusedGfxScriptCmd1
        .addr   UnusedGfxScriptCmd1
        .addr   UnusedGfxScriptCmd1
        .addr   UnusedGfxScriptCmd1

; ------------------------------------------------------------------------------

; [ graphics script command $f7: darken/lighten battle bg ]

GfxScriptCmd_f7:
@c8db:  jsr     GetNextGfxScriptByte
        and     #$80
        beq     @c8e5
        jmp     LightenBattleBG
@c8e5:  jsr     DarkenBattleBG
        rts

; ------------------------------------------------------------------------------

; [ unused graphics script commands ]

UnusedGfxScriptCmd2:
@c8e9:  jsr     GetNextGfxScriptByte

UnusedGfxScriptCmd1:
@c8ec:  rts

; ------------------------------------------------------------------------------

; [ graphics script command $f1: battle dialogue (slowest message speed) ]

GfxScriptCmd_f1:
@c8ed:  lda     #$01
        sta     $f49c
        bra     _c8f7

; ------------------------------------------------------------------------------

; [ graphics script command $f2: battle dialogue (config message speed) ]

GfxScriptCmd_f2:
@c8f4:  stz     $f49c
_c8f7:  jsr     GetNextGfxScriptByte
        jsr     WaitMsgWindow
        jsr     CloseMsgWindow
        jsr     WaitMsgWindow
        lda     ($3f)
        longa
        asl
        tax
        lda     f:BattleDlgPtrs,x       ; pointers to battle dialogue
        sta     $00
        lda     f:BattleDlgPtrs+1,x
        sta     $01
        lda     #^BattleDlgPtrs         ; *** don't need 16-bit here ***
        sta     $02
        shorta0
        tay
@c91e:  lda     [$00],y
        sta     $74fd,y
        iny
        cpy     #$0080
        bne     @c91e
        ldx     #$74fd
        stx     $ef50
        jsr     DrawFullMsgWindow
        jsr     WaitMsgAuto
        jsr     CloseMsgWindow
        jmp     WaitMsgWindow

; ------------------------------------------------------------------------------

; [ wait for battle message ]

; A: battle message id

WaitMsg:
@c93b:  pha
        ldx     #16
        jsr     WaitX
        pla
        tax
        lda     f:WaitMsgKeypressTbl,x   ; battle messages that wait for keypress
        bne     WaitMsgKeypress

; close automatically (battle dialogue jumps in here)
WaitMsgAuto:
@c94a:  lda     $f49c
        beq     @c953
        lda     #$05        ; use slowest message speed (5)
        bra     @c956
@c953:  lda     $16ad       ; battle message speed
@c956:  asl
        tax
        longa
        lda     f:MsgDurTbl,x   ; battle message durations
        tax
        shorta0
        jmp     WaitX

; wait for keypress
WaitMsgKeypress:
@c965:  inc     $f43a
@c968:  jsr     WaitVblank
        jsr     UpdateFlyingHDMA
        lda     $f43a
        bne     @c968
        rts

; ------------------------------------------------------------------------------

; [ wait for message window ]

WaitMsgWindow:
@c974:  lda     $ef9b
        beq     @c97e
        jsr     WaitFrame
        bra     @c974
@c97e:  rts

; ------------------------------------------------------------------------------

; [ graphics script command $f8: show message ]

; 0: attacker name (unused)
; 1: target name (unused)
; 2: attack name
; 3: battle message
; 4: damage numerals

GfxScriptCmd_f8:
@c97f:  jsr     WaitMsgWindow
        ldx     #$74fd
        stx     $ef50
        jsr     GetNextGfxScriptByte
        asl
        tax
        lda     f:ShowMsgTbl,x
        sta     $00
        lda     f:ShowMsgTbl+1,x
        sta     $01
        jmp     ($0000)

; text display jump table
ShowMsgTbl:
@c99c:  .addr   ShowMsg_00
        .addr   ShowMsg_01
        .addr   ShowMsg_02
        .addr   ShowMsg_03
        .addr   ShowMsg_04

; ------------------------------------------------------------------------------

; [ message type 4: damage numerals ]

ShowMsg_04:
@c9a6:  clr_ax
@c9a8:  lda     $34d4,x     ; copy character damage values to buffer
        sta     $dbf6,x
        inx
        cpx     #10
        bne     @c9a8
        clr_ax
@c9b6:  lda     $34de,x     ; copy monster damage values to buffer
        sta     $dbe6,x
        inx
        cpx     #$0010
        bne     @c9b6
        stz     $00
        clr_ax
@c9c6:  lda     $dbe6,x     ; put monsters before characters
        sta     $34d4,x
        ora     $00
        sta     $00
        inx
        cpx     #$001a
        bne     @c9c6
        lda     $00
        bne     @c9db       ; return if all damage values are zero
        rts
@c9db:  clr_ax
        dec
@c9de:  sta     $dbe6,x     ; set buffer to $ff
        inx
        cpx     #$0046
        bne     @c9de
        clr_ax
@c9e9:  clr_a
        sta     $f0fa,x     ; disable character/monster damage numerals
        lda     #$31        ; use white text (palette 0)
        sta     $f0ed,x
        inx
        cpx     #13
        bne     @c9e9
        clr_axy
        stx     $02
@c9fd:  longa
        lda     ($41),y     ; damage value
        sta     $00
        and     #$3fff
        tax
        shorta0
        jsr     HexToDec
        jsr     NormalizeNum
        phy
        iny
        lda     ($41),y
        and     #$40
        beq     @ca2a       ; branch if not miss
.if LANG_EN
        lda     #$6c
        sta     $180c
        inc
        sta     $180d
        inc
        sta     $180e
        inc
        sta     $180f
.else
        lda     #$ff
        sta     $180c
        sta     $180f
        lda     #$6c        ; set "miss" tiles
        sta     $180d
        lda     #$6d
        sta     $180e
.endif
@ca2a:  clr_ax
        ldy     $02
@ca2e:  lda     $180c,x     ; number digit
        cmp     #$ff
        beq     @ca38       ; branch if no digit
        sec
        sbc     #$10
@ca38:  sta     $dbe7,y     ; copy 4 digits to buffer
        iny
        inx
        cpx     #4
        bne     @ca2e
        ply
        longa
        lda     $02         ; increment buffer pointer
        clc
        adc     #$0005
        sta     $02
        lda     ($41),y
        bne     @ca5c       ; branch if damage is nonzero
        tya
        lsr
        tax
        shorta0
        inc     $f0fa,x     ; enable character/monster damage numerals
        bra     @ca5f
@ca5c:  shorta0
@ca5f:  iny
        lda     ($41),y
        and     #$40
        beq     @ca6f       ; branch if not miss
        tya
        dec
        lsr
        tax
        lda     #$ff
        sta     $f0fa,x
@ca6f:  lda     ($41),y
        bpl     @ca7c       ; branch if hp damage
        tya
        dec
        lsr
        tax
        lda     #$3d        ; use green text (palette 6)
        sta     $f0ed,x
@ca7c:  iny
        cpy     #$001a
        beq     @ca85
        jmp     @c9fd
@ca85:  clr_axy
@ca88:  lda     $f05d,x     ; monster x positions
        sta     $f0d3,y
        inx
        lda     $f05d,x
        sta     $f0e0,y
        inx
        iny
        cpy     #8
        bne     @ca88
        clr_axy
@ca9f:  lda     $efc5,x
        clc
        adc     $efc7,x
        sta     $f0db,y     ; x position
        lda     $efc6,x
        clc
        adc     $efc8,x
        adc     #$18
        sta     $f0e8,y     ; y position
        txa
        clc
        adc     #$10
        tax
        iny
        cpy     #5
        bne     @ca9f
        stz     $f108       ; clear frame counter
        longa
        lda     a:$0041
        clc
        adc     #$001a      ; increment damage buffer pointer
        sta     a:$0041
        shorta0
        inc     $f107       ; enable damage numeral animation
@cad5:  jsr     WaitFrame
        lda     $f107
        bne     @cad5
        rts

; ------------------------------------------------------------------------------

; [ message type 0: attacker name (unused) ]

ShowMsg_00:
@cade:  lda     $34c2
        bmi     @caea       ; branch if monster attacker
        lda     #$02        ; character name
        sta     $74fd
        bra     @caef
@caea:  lda     #$0c        ; monster name
        sta     $74fd
@caef:  lda     $48         ; target id
        sta     $74fe
        stz     $74ff
        jmp     DrawLeftMsgWindow

; ------------------------------------------------------------------------------

; [ message type 1: target name (unused) ]

ShowMsg_01:
@cafa:  lda     $34c4
        and     #$40
        beq     @cb12                   ; branch if not multi-target
        clr_ax
@cb03:  lda     f:TargetAllText,x       ; ぜんぶ (all)
        sta     $74fd,x
        inx
        cpx     #4
        bne     @cb03
        bra     @cb2f
@cb12:  lda     $34c4
        bmi     @cb1e       ; branch if monster target
        lda     #$02        ; character name
        sta     $74fd
        bra     @cb23
@cb1e:  lda     #$0c        ; monster name
        sta     $74fd
@cb23:  lda     $49         ; target id
        tax
        lda     $29bd,x     ; monster type
        sta     $74fe
        stz     $74ff
@cb2f:  jmp     DrawCenterMsgWindow

; ------------------------------------------------------------------------------

; [ message type 2: attack name ]

ShowMsg_02:
@cb32:  lda     $34c7
        and     #$70
        cmp     #$40
        beq     @cb6c       ; branch if magic used
        cmp     #$20
        beq     @cb69       ; branch if item used
        cmp     #$10
        beq     @cb44       ; branch if command used
        rts

; command name
@cb44:  lda     $34c8
        sta     $26
        lda     #5
        sta     $28
        jsr     Mult8
        clr_ay
        ldx     $2a
@cb54:  lda     f:BattleCmdName,x
        sta     $74fd,y
        inx
        iny
        cpy     #5
        bne     @cb54
        clr_a
        sta     $74fd,y
        jmp     DrawAttackNameWindow
@cb69:  jmp     @cb6f                   ; item name
@cb6c:  jmp     @cb98                   ; attack name

; item name
@cb6f:  lda     $34c8
        bne     @cb75
        rts
@cb75:  sta     $26
        lda     #9
        sta     $28
        jsr     Mult8
        clr_ay
        ldx     $2a
        inx                             ; skip item symbol
@cb83:  lda     f:ItemName,x
        sta     $74fd,y
        iny
        inx
        cpy     #8
        bne     @cb83
        clr_a
        sta     $74fd,y
        jmp     DrawAttackNameWindow

; attack name
@cb98:  lda     $34c8
        bne     @cb9e                   ; branch if attack name is shown
        rts
@cb9e:  cmp     #$48
        bcc     @cbc7                   ; branch if character magic

; monster attack name
        sec
        sbc     #$48
        sta     $26
        lda     #8
        sta     $28
        jsr     Mult8
        ldx     $2a
        clr_ay
@cbb2:  lda     f:AttackName,x         ; attack names
        sta     $74fd,y
        iny
        inx
        cpy     #8
        bne     @cbb2
        clr_a
        sta     $74fd,y
        jmp     DrawAttackNameWindow

; spell name
@cbc7:  lda     $34c8
        sta     $26
        lda     #6
        sta     $28
        jsr     Mult8
        clr_ay
        ldx     $2a
        lda     #$03
        sta     $74fd,y
        iny                             ; skip magic symbol
@cbdd:  lda     f:MagicName,x
        sta     $74fd,y
        iny
        inx
        cpy     #7
        bne     @cbdd
        clr_a
        sta     $74fd,y
        jmp     DrawAttackNameWindow

; ------------------------------------------------------------------------------

; [ message type 3: battle message ]

ShowMsg_03:
@cbf2:  jsr     WaitMsgWindow
        jsr     CloseMsgWindow
        jsr     WaitMsgWindow
        lda     ($45)
        cmp     #$ff
        bne     @cc02
        rts
@cc02:  pha
        longa
        asl
        tax
        lda     f:BattleMsgPtrs,x   ; pointers to battle messages
        sta     $00
        shorta0
        lda     #^BattleMsgPtrs
        sta     $02
        ldx     $45
        inx
        stx     $45
        clr_ayx
@cc1c:  lda     [$00],y     ; copy to text buffer
        sta     $74fd,y
        iny
        inx
        cpx     #$0080
        bne     @cc1c
        jsr     DrawFullMsgWindow
        pla
        jsr     WaitMsg
        jmp     @cbf2

; ------------------------------------------------------------------------------

; [ graphics script command $f3: play song ]

GfxScriptCmd_f3:
@cc32:  jsr     GetNextGfxScriptByte
        sta     $38be
        inc     $38bd
        rts

; ------------------------------------------------------------------------------

; [  ]

_02cc3c:
@cc3c:  jsr     TfrLeftMonsterTiles
        stz     $4e
@cc41:  jsr     WaitFrame
        lda     $4e
        and     #1
        jsr     SwapMonsterScreen
        inc     a:$004e
        lda     a:$004e
        cmp     #$60
        bne     @cc41
        jsr     TfrRightMonsterTiles
        lda     #1
        jsr     SwapMonsterScreen
        rtl

; ------------------------------------------------------------------------------

; [  ]

_02cc5e:
@cc5e:  pha
        lda     #1
        sta     $f482
        pla
        jsr     ChangeBossFrame
        rtl

; ------------------------------------------------------------------------------

; [  ]

_02cc69:
@cc69:  ldx     #0
@cc6c:  jsr     WaitFrame
        phx
        txa
        jsr     SetFlyingHDMA
        plx
        txa
        clc
        adc     #$10
        tax
        cpx     #$0090
        bne     @cc6c
        jsl     _02bedd
        ldx     #$0090
@cc86:  jsr     WaitFrame
        phx
        txa
        jsr     SetFlyingHDMA
        plx
        txa
        sec
        sbc     #$10
        tax
        cmp     #$f0
        bne     @cc86
        rts

; ------------------------------------------------------------------------------

; [  ]

BossTransition_far:
@cc99:  pha
        jsr     TfrLeftMonsterTiles
        pla
        jsr     BossTransition
        rtl

; ------------------------------------------------------------------------------

; [ graphics script command $f0: change boss frame ]

; ssgggggg
;   s: monster slot
;   g: boss frame id

GfxScriptCmd_f0:
@cca2:  stz     $f482
        jsr     GetNextGfxScriptByte

ChangeBossFrame:
@cca8:  pha
        lsr6
        tay
        pla
        and     #$3f
        sta     $f2b4,y                 ; boss frame id
        jsr     DrawBoss
        jsr     ModifyBG1Tiles_near
        lda     $f482
        beq     @ccc4
        jmp     TfrRightMonsterTiles
@ccc4:  jsr     TfrLeftMonsterTiles
        lda     $efa6                   ; transition type

BossTransition:
@ccca:  and     #$0f
        beq     @cce5
        cmp     #$01
        beq     @cd11
        cmp     #$02
        beq     @cd06
        cmp     #$03
        beq     @ccf1
        cmp     #$04
        beq     @cce1
        jmp     _02cc69

; 4: flash/shake
@cce1:  jsl     ShakeMonster

; 0: no transition
@cce5:  lda     #1
        jsr     SwapMonsterScreen
        jsr     TfrRightMonsterTiles
        clr_a
        jmp     SwapMonsterScreen

; 3: materialize (same as monster death)
@ccf1:  lda     #$30
        sta     $4e
@ccf5:  jsr     WaitFrame
        stz     $38e6
        jsl     UpdateMonsterDeathAnim
        dec     $4e
        bne     @ccf5
        jmp     @cce5

; 2: flash
@cd06:  lda     #$59
        jsr     PlaySfx
        jsr     _02be56
        jmp     @cce5

; 1: pixelate
@cd11:  stz     $4e
@cd13:  ldx     #8
        jsr     WaitX
        jsr     @cd34
        inc     $4e
        lda     $4e
        cmp     #$07
        bne     @cd13
        jsr     TfrRightMonsterTiles
@cd27:  ldx     #8
        jsr     WaitX
        jsr     @cd34
        dec     $4e
        bne     @cd27
@cd34:  lda     $4e
        asl4
        and     #$f0
        ora     #$01
        sta     $6cc2                   ; set screen mosaic register
        rts

; ------------------------------------------------------------------------------

.include "weapon.asm"
.include "sprite.asm"
.include "math.asm"
.include "monster_death.asm"
.include "magic.asm"

; ------------------------------------------------------------------------------

; bank 03
.segment "btlgfx_code2"

; ------------------------------------------------------------------------------

; powers of 10
Pow10:
@f280:  .word   .loword(10000000),  ^10000000
        .word   .loword(1000000),   ^1000000
        .word   .loword(100000),    ^100000
        .word   .loword(10000),     ^10000
        .word   .loword(1000),      ^1000
        .word   .loword(100),       ^100
        .word   .loword(10),        ^10

; ------------------------------------------------------------------------------

; [ convert battle variable from hex to decimal (6 digits) ]

HexToDecVar:
@f29c:  clr_ax
@f29e:  stz     $f4ad,x
        inx
        cpx     #8
        bne     @f29e
        ldx     #0
@f2aa:  phx
        txa
        asl2
        tax
        lda     f:Pow10,x   ; powers of 10
        sta     $04
        lda     f:Pow10+1,x
        sta     $05
        lda     f:Pow10+2,x
        sta     $06
        jsr     DivVar
        plx
        lda     $08
        clc
        adc     #$80
        sta     $f4ad,x
        inx
        cpx     #7
        bne     @f2aa
        lda     $00
        clc
        adc     #$80
        sta     $f4b4
        rtl

; ------------------------------------------------------------------------------

; [ divide (battle variable hex to decimal conversion) ]

DivVar:
@f2dc:  stz     $08
@f2de:  lda     $00
        sec
        sbc     $04
        sta     $00
        lda     $01
        sbc     $05
        sta     $01
        lda     $02
        sbc     $06
        sta     $02
        inc     $08
        bcs     @f2de
        dec     $08
        lda     $00
        clc
        adc     $04
        sta     $00
        lda     $01
        adc     $05
        sta     $01
        lda     $02
        adc     $06
        sta     $02
        rts

; ------------------------------------------------------------------------------

; [ validate character equipment ]

; validates equipped items against a character's handedness
; doesn't check class equipment restrictions

ValidateEquip:
@f30b:  phx
        lda     $2894
        bne     @f315
        lda     #$80
        bra     @f340
@f315:  cmp     #$44
        bcs     @f31d
        lda     #$01
        bra     @f340
@f31d:  cmp     #$4d
        bcs     @f325
        lda     #$02
        bra     @f340
@f325:  cmp     #$54
        bcs     @f32d
        lda     #$04
        bra     @f340
@f32d:  cmp     #$61
        bcs     @f335
        lda     #$08
        bra     @f340
@f335:  cmp     #$6d
        bcs     @f33d
        lda     #$10
        bra     @f340
@f33d:  jmp     @f404
@f340:  sta     $0f
        lda     $2895
        bne     @f34b
        lda     #$80
        bra     @f376
@f34b:  cmp     #$44
        bcs     @f353
        lda     #$01
        bra     @f376
@f353:  cmp     #$4d
        bcs     @f35b
        lda     #$02
        bra     @f376
@f35b:  cmp     #$54
        bcs     @f363
        lda     #$04
        bra     @f376
@f363:  cmp     #$61
        bcs     @f36b
        lda     #$08
        bra     @f376
@f36b:  cmp     #$6d
        bcs     @f373
        lda     #$10
        bra     @f376
@f373:  jmp     @f404
@f376:  sta     $0e
        lda     $1822
        longa
        asl7
        tax
        shorta0
        lda     $2000,x
        sta     $10
        and     #$c0
        cmp     #$c0
        beq     @f3c1
        lda     $10
        bmi     @f3ac
        longa
        lda     $0e
        cmp     #$8001
        beq     @f40b
        cmp     #$1001
        beq     @f40b
        cmp     #$1080
        beq     @f40b
        bra     @f3d4
@f3ac:  longa
        lda     $0e
        cmp     #$0180
        beq     @f40b
        cmp     #$0110
        beq     @f40b
        cmp     #$8010
        beq     @f40b
        bra     @f3d4
@f3c1:  longa
        lda     $0e
        cmp     #$0101
        beq     @f40b
        cmp     #$0180
        beq     @f40b
        cmp     #$8001
        beq     @f40b
@f3d4:  cmp     #$8080
        beq     @f40b
        cmp     #$0804
        beq     @f40b
        cmp     #$0408
        beq     @f40b
        cmp     #$0280
        beq     @f40b
        cmp     #$8002
        beq     @f40b
        cmp     #$0480
        beq     @f40b
        cmp     #$0880
        beq     @f40b
        cmp     #$8008
        beq     @f40b
        cmp     #$8004
        beq     @f40b
        shorta0
@f404:  lda     #1
        sta     $2893
        plx
        rtl
@f40b:  shorta0
        lda     #1
        sta     $352b
        stz     $2893
        plx
        rtl

; ------------------------------------------------------------------------------

; [  ]

_03f418:
@f418:  lda     #$5e
        jsl     PlaySfx_far
        clr_ax
        stx     $f406
        stx     $f408
        stx     $f173
        ldx     #$0010
        jsr     WaitX_near
        clr_axy
        stx     $f4a2
        longa
@f437:  lda     f:_03f479,x
        asl
        and     #$0100
        sta     $dbe6,y
        inx
        iny2
        cpy     #$0040
        bne     @f437
        shorta0
@f44d:  jsl     WaitFrame_far
        inc     $f173
        lda     $f173
        and     #$07
        tax
        lda     f:AnimShakeTbl,x
        tay
        sty     $f406
        jsr     _03f49a
        lda     $f173
        and     #$03
        bne     @f44d
        ldx     $f4a2
        inx
        stx     $f4a2
        cpx     #$0080
        bne     @f44d
        rtl

; ------------------------------------------------------------------------------

_03f479:
@f479:  .byte   $80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$00,$80
        .byte   $00,$00,$80,$00,$00,$00,$80,$00,$00,$00,$00,$80,$00,$00,$00,$00
        .byte   $00

; ------------------------------------------------------------------------------

; [  ]

_03f49a:
@f49a:  phx
        longa
        lda     $f4a2
        sta     $02
        lda     #$0100
        sta     $00
        clr_ayx
@f4aa:  lda     $00
        sta     $7612,y
        dec     $02
        bpl     @f4ca
        lda     $f406
        sta     $00
        cpx     #$0040
        beq     @f4ca
        lda     $dbe6,x
        sta     $04
        lda     $00
        eor     $04
        sta     $00
        inx2
@f4ca:  iny4
        cpy     #$0230
        bne     @f4aa
        shorta0
        plx
        rts

; ------------------------------------------------------------------------------

; [ draw animation frame tile ]

_03f4d8:
@f4d8:  pha
        and     #$1f
        cmp     #$1f
        bne     @f4e3

; blank tile
        pla
        jmp     @f51e

; visible tile
@f4e3:  tax
        lda     f:_16fccb,x
        sta     $ebe8,y
        lda     $12
        sta     $ebe6,y
        lda     $13
        sta     $ebe7,y
        pla
        asl
        and     #$c0
        ora     #$0f
        ora     $1a
        sta     $ebe9,y
        lda     $f261
        beq     @f51a
        lda     $ebe9,y
        eor     #$40
        sta     $ebe9,y
        lda     $10
        dec
        asl4
        clc
        adc     $14
        sta     $ebe6,y
@f51a:  iny4
@f51e:  lda     $12
        clc
        adc     #$10
        sta     $12
        dec     $10
        bne     @f53f
        lda     $14
        sta     $12
        lda     $13
        clc
        adc     #$10
        sta     $13
        lda     $f24d
        sta     $10
        dec     $11
        bne     @f53f
        clc
        rtl
@f53f:  sec
        rtl

; ------------------------------------------------------------------------------

; [ load monster death palette ]

LoadMonsterDeathPal:
@f541:  stz     $4e
        clr_axy
@f546:  lda     f:AnimPal+5*16,x
        sta     $ee30,y
        inx
        iny
        cpy     #$0020
        bne     @f546
        rtl

; ------------------------------------------------------------------------------

; [  ]

_03f555:
@f555:  clr_ax
@f557:  lda     $29b5,x     ; copy monster types
        sta     $f12b,x
        lda     $f123,x
        sta     $29b5,x
        inx
        cpx     #8
        bne     @f557
        rtl

; ------------------------------------------------------------------------------

; [  ]

_03f56a:
@f56a:  clr_ax
@f56c:  lda     $29b5,x
        sta     $f123,x
        lda     $f12b,x
        sta     $29b5,x
        inx
        cpx     #8
        bne     @f56c
        rtl

; ------------------------------------------------------------------------------

_03f57f:
@f57f:  .byte   $0e,$1b,$2e,$57

; ------------------------------------------------------------------------------

; [  ]

_03f583:
@f583:  lda     $13
        and     #$03
        tax
        lda     f:_03f57f,x
        jsl     PlaySfx_far
        rts

; ------------------------------------------------------------------------------

; [  ]

_03f591:
@f591:  lda     #$42
        sta     $38be
        inc     $38bd
        jsr     _03f583
        jsr     _03f609
        ldx     #$0040
        jsr     WaitX_near
        jsr     _03f583
        jsl     FlashScreenYellow
        ldx     #$0020
        jsr     WaitX_near
        jsr     _03f609
        ldx     #$0000
        stx     $f406
        stx     $f408
        sta     $f133
@f5c1:  jsl     WaitFrame_far
        lda     $f133
        and     #$07
        tax
        lda     f:AnimShakeTbl,x
        tay
        sty     $f406
        lda     $f133
        and     #$0f
        bne     @f5e1
        ldy     $f408
        dey
        sty     $f408
@f5e1:  lda     $f133
        cmp     #$8c
        beq     @f5f0
        cmp     #$10
        beq     @f5f0
        cmp     #$20
        bne     @f5f3
@f5f0:  jsr     _03f609
@f5f3:  inc     $f133
        jsl     SetMonsterScroll
        ldy     $f408
        cpy     #$ff60
        bne     @f5c1
        lda     #$20
        jsl     PlaySfx_far
        rtl

; ------------------------------------------------------------------------------

; [  ]

_03f609:
@f609:  jsr     _03f583
        jsl     FlashScreenWhite
        lda     #$03
        sta     $ef87
        jsl     WaitFrame_far
        jsl     FlashScreenYellow
        lda     #$03
        sta     $ef87
        jsl     WaitFrame_far
        jsl     FlashScreenRed
        lda     #$03
        sta     $ef87
        rts

; ------------------------------------------------------------------------------

; [ update character sprite running back onscreen ]

; used for appear command

UpdateCharAppear:
@f630:  phx
        jsr     GetCharRunSpeed
        lda     $efc5,x
        sec
        sbc     $00
        sta     $efc5,x
        plx
        rtl

; ------------------------------------------------------------------------------

; [ update character sprite running offscreen ]

; used for running away and hide command

UpdateCharRun:
@f63f:  phx
        jsr     GetCharRunSpeed
        lda     $efc5,x
        clc
        adc     $00
        sta     $efc5,x
        plx
        rtl

; ------------------------------------------------------------------------------

; [ get character running movement speed ]

GetCharRunSpeed:
@f64e:  txa
        stz     $efc8,x
        lsr2
        tay
        lda     $f015,y
        and     #$30
        beq     @f673                   ; branch if not mini or toad
        and     #$20
        beq     @f66f
        lda     $efd1,x
        and     #$07
        phx
        tax
        lda     f:ToadHopTbl,x
        plx
        sta     $efc8,x
@f66f:  lda     #1
        bra     @f675
@f673:  lda     #2
@f675:  sta     $00
        rts

; ------------------------------------------------------------------------------

; animation palette swap speeds
PalSwapSpeedTbl:
@f678:  .byte   $7f,$3f,$1f,$0f,$07,$03,$01,$00

; ------------------------------------------------------------------------------

; [ update monster positions for animations ]

UpdateMonsterAnimPos:
@f680:  ldy     #0
        ldx     #0
@f686:  lda     $29bd,x
        cmp     #$ff
        bne     @f6a1
        sta     $f043,y
        sta     $f044,y
        sta     $f05d,y
        sta     $f05e,y
        sta     $f029,y
        sta     $f02a,y
        bra     @f6e9
@f6a1:  phx
        pha
        lda     $29a5,x                 ; x position
        and     #$f0
        lsr
        clc
        adc     #$10
        sta     $02
        lda     $29a5,x                 ; y position
        and     #$0f
        asl3
        sta     $03
        pla
        asl
        tax
        lda     $6cc3,x                 ; width
        asl2
        clc
        adc     $02
        sta     $f043,y                 ; center x
        sta     $f05d,y                 ; damage numeral position
        sta     $f029,y
        lda     $03
        sta     $f02a,y                 ; top y
        lda     $6cc4,x                 ; height
        asl2
        clc
        adc     $03
        sta     $f044,y                 ; center y
        lda     $6cc4,x
        asl3
        clc
        adc     $03
        sta     $f05e,y                 ; bottom y
        plx
@f6e9:  iny2
        inx
        cpx     #8
        beq     @f6f4
        jmp     @f686
@f6f4:  rtl

; ------------------------------------------------------------------------------

; [ update character palette id ]

UpdateCharPalID:
@f6f5:  tax
        phx
        longa
        asl7
        tax
        shorta0
        lda     $2001,x
        and     #$1f
        cmp     #$0f
        bne     @f70e
        dec
@f70e:  plx
        sta     $f0a3,x
        rtl

; ------------------------------------------------------------------------------

; monster death sound effects
MonsterDeathSfxTbl:
@f713:  .byte   $10,$59,$59,$59,$21,$10

; ------------------------------------------------------------------------------

; [ clear character pose if player lost control ]

CheckCharPose:
@f719:  clr_ayx
@f71c:  lda     $f015,x                 ; dead or stone
        and     #$c0
        bne     @f736
        lda     $f016,x                 ; paralyze, sleep, charm, berserk
        and     #$3c
        bne     @f736
@f72a:  txa
        clc
        adc     #$04
        tax
        iny
        cpx     #$0014
        bne     @f71c
        rts
@f736:  lda     #$00                    ; clear character pose
        sta     $f099,y
        sta     $f09e,y
        jmp     @f72a

; ------------------------------------------------------------------------------

; [ check if menu needs to close automatically ]

; clear carry if player lost control of selected character or all
; monsters were defeated

CheckAutoCloseMenu:
@f741:  jsr     CheckCharPose
        lda     $1822                   ; selected character
        asl2
        tax
        lda     $f015,x
        and     #$c0
        bne     @f76c                   ; branch if character is dead or stone
        lda     $f016,x
        and     #$3c
        bne     @f76c                   ; paralyze, sleep, charm, berserk
        ldx     #0
@f75b:  lda     $29b5,x
        cmp     #$ff
        bne     @f76a                   ; branch if any monsters are alive
        inx
        cpx     #8
        bne     @f75b
        bra     @f76c
@f76a:  clc
        rtl
@f76c:  sec
        rtl

; ------------------------------------------------------------------------------

; [ load battle bg palette ]

LoadBattleBGPal:
@f76e:  lda     $1802       ; battle bg id
        and     #$1f
        sta     $00
        tax
        lda     $1802
        and     #$20
        beq     @f783       ; branch if not using alternate palette
        lda     f:AltBattleBGPalTbl,x
        bne     @f786
@f783:  clc
        adc     $00
@f786:  ldx     #1
        sta     $2a
        longa
        asl     $2a
        asl     $2a
        asl     $2a
        asl     $2a
        asl     $2a
        txa
        asl5
        tay
        shorta0
        ldx     $2a
        lda     #$10
        sta     $00
@f7a7:  lda     f:BattleBGPal,x
        sta     $ed50,y
        lda     f:BattleBGPal+16,x
        sta     $ed70,y
        inx
        iny
        dec     $00
        bne     @f7a7
        rtl

; ------------------------------------------------------------------------------

; alternate battle bg palette id
AltBattleBGPalTbl:
@f7bc:  .byte   22,0,0,0,17,0,0,18,20,0,0,19,21,0,0,0,0

; ------------------------------------------------------------------------------

; [ increment game time ]

IncGameTime:
@f7cd:  inc     $16a3       ; increment game time
        lda     $16a3
        cmp     #$3c
        bcc     @f7e7
        stz     $16a3
        inc     $16a4
        bne     @f7e7
        inc     $16a5
        bne     @f7e7
        inc     $16a6
@f7e7:  rtl

; ------------------------------------------------------------------------------

; [  ]

_03f7e8:
@f7e8:  lda     $0e
        beq     @f7f6
        dec     $0e
        lda     #$31
        sta     $10
        lda     #$ff
        clc
        rtl
@f7f6:  lda     [$1c]
        cmp     #$fe
        beq     @f80e
        cmp     #$ff
        beq     @f818
        ldx     $1c
        inx
        stx     $1c
        pha
        lda     $f330
        sta     $10
        pla
        sec
        rtl
@f80e:  ldx     $1c
        inx
        stx     $1c
        lda     [$1c]
        dec
        sta     $0e
@f818:  lda     #$31
        sta     $10
        lda     #$ff
        ldx     $1c
        inx
        stx     $1c
        clc
        rtl

; ------------------------------------------------------------------------------

; [  ]

_03f825:
@f825:  lda     #$40
        jsr     SetColorMath
        lda     #$1f
        sta     $f433
        sta     $f435
        sta     $f434
        lda     #$e0
        sta     $ef88
        lda     #$10
        sta     $f49b
        lda     #$05
        sta     $ef87
        rtl

; ------------------------------------------------------------------------------

; [  ]

_03f845:
@f845:  lda     #$24
        jsl     PlaySfx_far
        jsl     FlashScreenRed
        jsr     Wait8
        jsl     FlashScreenYellow
        jsr     Wait8
        jsl     FlashScreenWhite
        jsr     Wait8
        stz     $ef87
        rtl

; ------------------------------------------------------------------------------

; [ wait 8 frames ]

Wait8:
@f864:  ldx     #8                      ; repeat 8 times

WaitX_near:
@f867:  jsl     WaitFrame_far
        dex
        bne     @f867
        rts

; ------------------------------------------------------------------------------

; [ big bang ]

BigBang:
@f86f:  jsr     FinalBGScrollBack
        ldx     #$80b0
        stx     $f289       ; sprite $b0 is highest priority
        inc     $f28b
        clr_a
        jsl     DoMagicAnim_far
        jsl     ResetAnimSpritesLarge_far
        clr_ax
        stx     $f289       ; disable sprite priority order shifting
        inc     $f28b
        ldx     #4          ; repeat 4 times
@f88f:  phx
        jsl     FlashScreenGreen
        jsr     Wait8
        jsl     FlashScreenRed
        jsr     Wait8
        jsl     FlashScreenYellow
        jsr     Wait8
        jsl     FlashScreenBlue
        jsr     Wait8
        jsl     FlashScreenWhite
        jsr     Wait8
        plx
        dex
        bne     @f88f
        stz     $ef87
        jsr     FinalBGScrollForward
        rtl

; ------------------------------------------------------------------------------

; [ make final battle bg scroll backward ]

FinalBGScrollBack:
@f8be:  jsl     WaitFrame_far
        stz     $00
        ldx     #0
@f8c7:  lda     $f488,x
        cmp     f:FinalBGScrollBackTbl,x
        beq     @f8d5
        dec     $f488,x     ; decrement to backward scroll rate
        inc     $00
@f8d5:  inx
        cpx     #$0012
        bne     @f8c7
        lda     $00
        bne     @f8be
        rts

; ------------------------------------------------------------------------------

; [ make final battle bg scroll forward ]

FinalBGScrollForward:
@f8e0:  jsl     WaitFrame_far
        stz     $00
        ldx     #0
@f8e9:  lda     $f488,x
        cmp     f:FinalBGScrollForwardTbl,x
        beq     @f8f7
        inc     $f488,x     ; increment to forward scroll rate
        inc     $00
@f8f7:  inx
        cpx     #$0012
        bne     @f8e9
        lda     $00
        bne     @f8e0
        rts

; ------------------------------------------------------------------------------

; [ update final battle bg hdma data ]

UpdateFinalBGScroll:
@f902:  phx
        phy
        lda     $f4a9
        bne     @f947
        lda     $1802
        cmp     #$10
        bne     @f947       ; branch if not final battle bg
        clr_ax
@f912:  lda     f:FinalBGScrollHDMAStripTbl,x
        tay
        sty     $0e
        stz     $11
        lda     $f488,x     ; scroll rate for this strip
        sta     $10
        bpl     @f924       ; convert to 16-bit
        dec     $11
@f924:  longa
        txa
        asl5
        tay
        lda     $7992,y     ; add to bg2 hdma h-scroll value
        clc
        adc     $10
@f933:  sta     $7992,y
        iny4
        dec     $0e
        bne     @f933
        shorta0
        inx
        cpx     #$0012
        bne     @f912
@f947:  ply
        plx
        rtl

; ------------------------------------------------------------------------------

; final battle bg hdma data (3 * 18 bytes)

; forward scroll rate (1x)
FinalBGScrollForwardTbl:
@f94a:  .byte   5,4,3,2,1,0,1,2,3,4,5,6,7,8,9,10,11,12

; backward scroll rate (3x)
FinalBGScrollBackTbl:
@f95c:  .lobytes -15,-12,-9,-6,-3,0,-3,-6,-9,-12,-15,-18,-21,-24,-27,-30,-33,-36

; hdma strip sizes (pixels)
FinalBGScrollHDMAStripTbl:
@f96e:  .byte   8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,4

; ------------------------------------------------------------------------------

; [ shake monster ]

ShakeMonster:
@f980:  stz     $4e
        clr_ax
        stx     $f406
        stx     $f408
@f98a:  jsl     WaitFrame_far
        jsl     SetMonsterScroll
        lda     $4e
        and     #$07
        asl
        tax
        longa
        lda     f:ShakeMonsterTbl,x
        sta     $f406
        shorta0
        inc     $4e
        lda     $4e
        cmp     #$40
        bne     @f98a
        clr_ax
        stx     $f406
        jsl     SetMonsterScroll
        rtl

; ------------------------------------------------------------------------------

; [ random (0..255) for megaflare animation ]

RandMegaflare:
@f9b6:  phx
        inc     $97
        lda     $97
        tax
        lda     $1900,x     ; rng table
        plx
        rts

; ------------------------------------------------------------------------------

; [ megaflare animation ]

MegaflareAnim:
@f9c1:  lda     #$20
        sta     $f111
        clr_ax
@f9c8:  jsr     InitMegaflareSpritePos
        cpx     #$0010
        bne     @f9c8
        clr_ax
        dec
@f9d3:  sta     $f3a8,x
        inx
        cpx     #8
        bne     @f9d3
        stz     $f3a8
        jsl     FlashScreenRed
        lda     #$02
        sta     $ef87
@f9e8:  ldx     #$0004
@f9eb:  jsl     WaitFrame_far
        dex
        bne     @f9eb
        inc     $f42b
        jsr     DrawMegaflareSprites
        stz     $f42b
        ldx     #$0016
@f9fe:  lda     $f398,x
        sta     $f399,x
        dex
        cpx     #$000f
        bne     @f9fe
        lda     $f3a8
        inc
        and     #$07
        sta     $f3a8
        clr_ax
@fa15:  lda     $f3a8,x
        bne     @fa22
        phx
        txa
        asl
        tax
        jsr     InitMegaflareSpritePos
        plx
@fa22:  inx
        cpx     #8
        bne     @fa15
        dec     $f111
        bne     @f9e8
        stz     $ef87
        rtl

; ------------------------------------------------------------------------------

; [ init megaflare sprite position ]

InitMegaflareSpritePos:
@fa31:  jsr     RandMegaflare
        and     #$7f
        clc
        sta     $f398,x
        inx
        jsr     RandMegaflare
        and     #$3f
        clc
        adc     #$20
        sta     $f398,x
        inx
        rts

; ------------------------------------------------------------------------------

; [ draw megaflare sprites ]

DrawMegaflareSprites:
@fa48:  clr_axy
@fa4b:  lda     $f3a8,x
        cmp     #$ff
        beq     @fabb
        asl
        phx
        tax
        lda     f:MegaflareSpritePtrs,x
        sta     $00
        lda     f:MegaflareSpritePtrs+1,x
        sta     $01
        lda     #$13
        sta     $02
        plx
        phx
        txa
        asl
        tax
        lda     $f398,x
        sta     $04
        lda     $f399,x
        sta     $05
@fa74:  lda     [$00]
        cmp     #$ff
        beq     @faba
        clc
        adc     $04
        pha
        lda     $6cc0
        beq     @fa87
        pla
        eor     #$ff
        pha
@fa87:  pla
        sta     $0340,y
        jsr     IncMegaflareSpriteOffset
        lda     [$00]
        clc
        adc     $05
        sta     $0341,y
        jsr     IncMegaflareSpriteOffset
        lda     [$00]
        sta     $0342,y
        jsr     IncMegaflareSpriteOffset
        lda     [$00]
        pha
        lda     $6cc0
        beq     @faad
        pla
        eor     #$40
        pha
@faad:  pla
        sta     $0343,y
        iny4
        jsr     IncMegaflareSpriteOffset
        bra     @fa74
@faba:  plx
@fabb:  inx
        cpx     #8
        bne     @fa4b
        rts

; ------------------------------------------------------------------------------

; [ increment megaflare sprite data offset ]

IncMegaflareSpriteOffset:
@fac2:  ldx     $00
        inx
        stx     $00
        rts

; ------------------------------------------------------------------------------

; [ update monster death animation ]

; it appears that at some point there were 4 different monster death
; animations, but in the release version there is only one

UpdateMonsterDeathAnim:
@fac8:  lda     $38e6
        bne     @fad1
        jsr     UpdateMonsterDeathHDMA
        rtl
@fad1:  cmp     #$01
        bne     @fad9
        jsr     UpdateMonsterDeathHDMA
        rtl
@fad9:  cmp     #$02
        bne     @fae1
        jsr     UpdateMonsterDeathHDMA
        rtl
@fae1:  jsr     UpdateMonsterDeathHDMA
        rtl

; ------------------------------------------------------------------------------

; [ update monster death hdma data ]

; uses hdma to swap in and out monster scanlines. this is used for the
; standard monster death animation and can also be used for transitioning
; a boss graphics frame

UpdateMonsterDeathHDMA:
@fae5:  clr_ay
        lda     $4e
        asl
        tax
@faeb:  lda     f:MonsterDeathHDMATbl,x
        sta     $01
        lda     f:MonsterDeathHDMATbl+1,x
        sta     $00
        inx2
        longa
        asl     $00
        rol     $02
        shorta0
        lda     $02
        and     #$01
        eor     #$01
        sta     $7613,y
        sta     $7693,y
        sta     $7713,y
        sta     $7793,y
        sta     $7813,y
        sta     $7893,y
        iny4
        cpy     #$0040
        bne     @faeb
        ldy     #$0040
        lda     $4e
        asl
        tax
@fb2a:  lda     f:MonsterDeathHDMATbl,x
        sta     $01
        lda     f:MonsterDeathHDMATbl+1,x
        sta     $00
        inx2
        longa
        asl     $00
        rol     $02
        shorta0
        lda     $02
        and     #$01
        eor     #$01
        sta     $764f,y
        sta     $76cf,y
        sta     $774f,y
        sta     $77cf,y
        sta     $784f,y
        dey4
        bne     @fb2a
        rts

; ------------------------------------------------------------------------------

; [ open/close pause window ]

OpenClosePauseWindow:
@fb5d:  clr_ax
@fb5f:  lda     $8c32,x
        pha
        lda     $7e12,x
        sta     $8c32,x
        pla
        sta     $7e12,x
        inx
        cpx     #$0080
        bne     @fb5f
        rts

; ------------------------------------------------------------------------------

; [ update sound for pause/unpause ]

; pause
PauseSfx:
@fb74:  lda     #$8a        ; quarter volume
        sta     $1e00
        jsl     ExecSound_ext
        bra     _fb88

; unpause
UnpauseSfx:
@fb7f:  lda     #$88        ; full volume
        sta     $1e00
        jsl     ExecSound_ext
_fb88:  lda     #$02
        sta     $1e00
        lda     #$5a        ; play sound effect $5a
        sta     $1e01
        lda     #$80
        sta     $1e02
        jsl     ExecSound_ext
        rts

; ------------------------------------------------------------------------------

; [ check pause ]

; return carry set if paused (disables player input)

CheckPause:
@fb9c:  lda     f:hSTDCNTRL1H
        ora     f:hSTDCNTRL2H
        and     #$10                    ; start button (controller 1 or 2)
        ora     $38
        sta     $38                     ; set controller 1 buttons pressed
        lda     $f44b
        cmp     #$ff
        beq     @fbed
        lda     $f44a
        beq     @fbed
        lda     $f448
        beq     @fbef
        cmp     #$01
        beq     @fbdb
        inc     $f449
        lda     $f449
        cmp     #$0f
        bne     @fc3c
        stz     $f448
        stz     $38d9
@fbcf:  lda     $f44b
        cmp     #$fe
        bne     @fc3c
        inc     $f44b
        bra     @fc3c
@fbdb:  dec     $f449
        lda     $f449
        cmp     #$04
        bne     @fc3c
        stz     $f448
        inc     $38d9
        bra     @fbcf
@fbed:  bra     @fc3a
@fbef:  lda     $38d9
        bne     @fc18                   ; branch if paused

; not paused
        lda     $f44b
        beq     @fc00
        lda     #$fe
        sta     $f44b
        bra     @fc0c
@fc00:  lda     $38
        and     #$10
        beq     @fc3a                   ; branch if start button is not pressed
        jsr     PauseSfx
        jsr     OpenClosePauseWindow
@fc0c:  lda     #$01
        sta     $f448
        lda     #$0f
        sta     $f449
        bra     @fc3c

; paused
@fc18:  lda     $f44b
        beq     @fc24
        lda     #$fe
        sta     $f44b
        bra     @fc2a
@fc24:  lda     $38
        and     #$10
        beq     @fc3c                   ; branch if start button is not pressed
@fc2a:  jsr     UnpauseSfx
        jsr     OpenClosePauseWindow
        lda     #$02
        sta     $f448
        lda     #$04
        sta     $f449
@fc3a:  clc
        rtl
@fc3c:  sec
        rtl

; ------------------------------------------------------------------------------

; [ update color math ]

UpdateColorMath:
@fc3e:  lda     $ef87                   ; color flash type
        bne     @fc46
        jmp     @fd24
@fc46:  lda     $f49b
        beq     @fc50
        lda     $f49b
        bra     @fc52
@fc50:  lda     #$03
@fc52:  jsr     SetColorMath
        lda     #$e0
        sta     f:hCOLDATA
        lda     $ef87
        cmp     #$01
        beq     @fcd4
        cmp     #$02
        beq     @fca1
        cmp     #$03
        beq     @fcd4
        cmp     #$04
        beq     @fc8e
        cmp     #$05
        beq     @fc76
        cmp     #$06
        beq     @fca1

; 5: decrease
@fc76:  lda     $f435
        beq     @fc86
        dec     $f435
        dec     $f434
        dec     $f433
        bra     @fcdb
@fc86:  stz     $f49b
        stz     $ef87
        bra     @fcdb

; 4: increase
@fc8e:  lda     $f435
        cmp     $f436
        beq     @fc9f
        inc     $f435
        inc     $f434
        inc     $f433
@fc9f:  bra     @fcdb

; 2: gradual, 6: ???
@fca1:  lda     $ef8a
        bne     @fcbf
        lda     $f435
        cmp     #$1f
        beq     @fcb8
        inc     $f435
        inc     $f434
        inc     $f433
        bra     @fcdb
@fcb8:  lda     #$01
        sta     $ef8a
        bra     @fcdb
@fcbf:  lda     $f435
        beq     @fccf
        dec     $f435
        dec     $f434
        dec     $f433
        bra     @fcdb
@fccf:  stz     $ef8a
        bra     @fcdb

; 1: every other frame, 3: once
@fcd4:  lda     $ef89
        and     #$02
        bne     @fd20
@fcdb:  lda     $ef88
        and     #$80
        beq     @fceb
        lda     $f433
        ora     #$80
        sta     f:hCOLDATA
@fceb:  lda     $ef88
        and     #$40
        beq     @fcfb
        lda     $f434
        ora     #$40
        sta     f:hCOLDATA
@fcfb:  lda     $ef88
        and     #$20
        beq     @fd0b
        lda     $f435
        ora     #$20
        sta     f:hCOLDATA
@fd0b:  lda     $ef87
        cmp     #$03
        bne     @fd20
        inc     $ef89
        lda     $ef89
        and     #$02
        bne     @fd1f
        stz     $ef87
@fd1f:  rtl
@fd20:  inc     $ef89
        rtl
@fd24:  lda     $ed4e
        and     #$80
        beq     @fd3b       ; branch if monsters are not transparent
        lda     #$02
        sta     f:hCGSWSEL
        sta     f:hTS
        lda     #$41
        jsr     SetColorMath
        rtl
@fd3b:  clr_a
        sta     f:hCGSWSEL
        sta     f:hTS
        jsr     SetColorMath
        rtl

; ------------------------------------------------------------------------------

; [ set color math register ]

SetColorMath:
@fd48:  sta     f:hCGADSUB              ; set register directly
        sta     $f43d                   ; set value in hdma table
        sta     $f43f
        rts

; ------------------------------------------------------------------------------

; [ init summon sprite data ]

; A: summon attack id

InitSummonSprite:
@fd53:  stz     $f326
        stz     $f327
        stz     $f329
        stz     $f32b
        stz     $f32c
        stz     $f32d
        pha
        sec
        sbc     #$4d
        sta     $f325

; asura
        cmp     #$0d
        bcc     @fd85
        cmp     #$10
        beq     @fd85
        pha
        inc     $f327
        lda     $1813
        tay
        lda     $1900,y                 ; rng table
        and     #$03
        sta     $f326
        pla

; sylph
@fd85:  cmp     #$0a
        bne     @fda3
        pha
        stz     $f133
        lda     #$40
        sta     $f173
        lda     #$08
        sta     $f1b3
        sta     $f1f3
        lda     #$02
        sta     $f32d
        inc     $f32c
        pla

@fda3:  asl2
        tax
        clr_ay
@fda8:  lda     f:SummonSpritePosTbl,x
        sta     $f321,y
        inx
        iny
        cpy     #4
        bne     @fda8
        pla
        lda     #$38
        sta     $f330
        clr_ay
@fdbe:  clr_a
        sta     $ee90,y                 ; clear summon color palette
        inx
        iny
        cpy     #$0020
        bne     @fdbe
        ldx     #$7fff                  ; set 1st color to white
        stx     $ee92
        rtl

; ------------------------------------------------------------------------------

; [ update controller ]

UpdateCtrl:
@fdd0:  lda     $f44a
        beq     @fe02
        phd
        ldx     #$0037
        phx
        pld
        jsl     UpdateCtrlBattle_ext
        pld
        lda     f:hSTDCNTRL1L
        ora     f:hSTDCNTRL2L
        and     #$30
        cmp     #$30
        bne     @fdf4       ; branch if not holding r and l buttons
        lda     $37
        and     #$7f        ; ignore a button
        sta     $37
@fdf4:  lda     $f43a
        beq     @fe02       ; branch if not waiting for battle message keypress
        lda     $37
        ora     $38
        beq     @fe02       ; branch if no keypress
        stz     $f43a
@fe02:  rtl

; ------------------------------------------------------------------------------

; [ transfer sprite data to ppu ]

TfrSprites:
@fe03:  lda     $f42b
        bne     @fe45
        phb
        clr_a
        pha
        plb
        ldx     #0
        stx     hOAMADDL
        ldx     #$0400
        stx     $4340
        ldx     #$0300
        stx     $4342
        clr_a
        sta     $4344
        sta     $4347
        ldx     #$0220
        stx     $4345
        lda     #$10
        sta     hMDMAEN
        lda     $7ef28a
        bpl     @fe44       ; branch if no priority order shifting
        lda     $7ef28a     ; set highest priority sprite
        sta     hOAMADDH
        lda     $7ef289
        sta     hOAMADDL
@fe44:  plb
@fe45:  rtl

; ------------------------------------------------------------------------------

; [ init hdma tables ]

InitHDMA:
@fe46:  lda     #$64
        sta     $f43c
        lda     #$28
        sta     $f43e
        lda     #$01
        sta     $f440
        stz     $f441
        stz     $f442
        phb
        clr_a
        pha
        plb
        lda     #$43
        sta     $4300
        sta     $4310
        sta     $4320
        lda     #$0d        ; bg1 scroll
        sta     $4301
        lda     #$0f        ; bg2 scroll
        sta     $4311
        lda     #$11        ; bg3 scroll
        sta     $4321
        ldx     #$75fd
        stx     $4302
        ldx     #$7604
        stx     $4312
        ldx     #$760b
        stx     $4322
        lda     #$7e
        sta     $4304
        sta     $4314
        sta     $4324
        sta     $4307
        sta     $4317
        sta     $4327
        lda     #$00
        sta     $4370
        lda     #$31        ; color math
        sta     $4371
        ldx     #$f43c
        stx     $4372
        lda     #$7e
        sta     $4377
        sta     $4374
        lda     #$87        ; enable hdma
        sta     hHDMAEN
        plb
        rtl

; ------------------------------------------------------------------------------

; [ transfer color palettes to ppu ]

TfrPal:
@febe:  phb
        clr_a
        pha
        plb
        sta     hCGADD
        ldx     #$2202
        stx     $4340
        ldx     #$ed50
        stx     $4342
        lda     #$7e
        sta     $4344
        ldx     #$0200
        stx     $4345
        lda     #$10
        sta     hMDMAEN
        plb
        rtl

; ------------------------------------------------------------------------------

; bank 01
.segment "btlgfx_code3"

; ------------------------------------------------------------------------------

; [ pre-magic animation (white and summon) ]

; A: pre-attack animation id
;      0: black magic
;      1: white magic
;      2: summon magic

PreMagicAnim2:
@e300:  cmp     #$01
        beq     @e309
        cmp     #$02
        beq     @e31f
        rtl

; white magic
@e309:  lda     #$07
        sta     $f11b
        lda     #$05
        sta     $f11c
        lda     #$14
        sta     $f118
        stz     $f116
        lda     #$ae
        bra     @e335

; summon magic
@e31f:  lda     #$03
        sta     $f11b
        lda     #$08
        sta     $f11c
        lda     #$08
        sta     $f116
        lda     #$ff
        sta     $f118
        lda     #$9e
@e335:  jsl     EnableAnimPalEffect_far
        jsr     ResetAnimSpritesLarge_near
        jsl     InitPolarAngle_far
        clr_ax
@e342:  pha
        jsr     IncPolarAngle_near
        pla
        clc
        adc     #$20
        inx
        cpx     #8
        bne     @e342
        clr_a
        jsl     SetPolarRadius_far
        lda     a:$0048
        asl
        tax
        lda     $f053,x
        clc
        adc     #$10
        sta     $f111
        lda     $f054,x
        sec
        sbc     #$08
        sta     $f112
        stz     $f115
        stz     $f114
        stz     $f117

; start of frame loop
@e375:  jsr     WaitFrame_near
        jsr     UpdatePreMagicSprites
        jsl     UpdatePalSwap_far
        lda     $f117
        cmp     $f118
        beq     @e391
        lda     $f117
        jsl     SetPolarRadius_far
        inc     $f117
@e391:  lda     $f116
        bne     @e3a3
        clr_ax
@e398:  lda     #$04
        jsr     IncPolarAngle_near
        inx
        cpx     #8
        bne     @e398
@e3a3:  inc     $f114
        lda     $f114
        and     $f11b
        bne     @e3b1
        inc     $f115
@e3b1:  lda     $f115
        cmp     $f11c
        bne     @e375
        jsr     ResetAnimSpritesLarge_near
        rtl

; ------------------------------------------------------------------------------

; [ update white/summon pre-magic animation sprites ]

UpdatePreMagicSprites:
@e3bd:  clr_axy
@e3c0:  jsr     CalcPolarX_near
        clc
        adc     $f111
        sta     $00
        jsr     CalcPolarY_near
        clc
        adc     $f112
        sta     $02
        phx
        lda     $f115
        clc
        adc     $f116
        tax
        lda     f:PreMagicAnimFlagsTbl,x
        sta     $04
        lda     f:PreMagicAnimTilesTbl,x
        plx
        jsr     DrawPreMagicSprite
        inx
        cpx     #8
        bne     @e3c0
        rts

; ------------------------------------------------------------------------------

; [ draw sprites for white/summon pre-magic animation ]

;   A: tile id
; $00: x position
; $02: y position
; $04: sprite flags

DrawPreMagicSprite:
@e3f0:  sta     $0342,y
        lda     $02
        sta     $0341,y
        lda     $6cc0
        bne     @e406
        lda     $00
        sta     $0340,y
        lda     $04
        bra     @e414
@e406:  lda     $00
        eor     #$ff
        sec
        sbc     #$10
        sta     $0340,y
        lda     $04
        eor     #$40
@e414:  sta     $0343,y
        iny4
        rts

; ------------------------------------------------------------------------------

; [ reset 16x16 animation sprites (near) ]

ResetAnimSpritesLarge_near:
@e41c:  jsl     ResetAnimSpritesLarge_far
        rts

; ------------------------------------------------------------------------------

; [ dark wave animation ]

DarkWaveAnim:
@e421:  lda     $34c4
        sta     $f485
        lda     #$65
        jsl     PlaySfx_far
        jsl     FlashScreenBlue
        lda     #$02
        sta     $ef87
        jsr     ResetAnimSpritesLarge_near
        clr_a
        sta     $f133
        lda     #$80
        sta     $f134
        lda     #$28
        sta     $f1b3
        sta     $f1b4
        lda     a:$0048
        asl
        tax
        lda     #$48
        sta     $f114
        lda     $34c2
        bmi     @e470
        stz     $f484
        lda     $f053,x
        sta     $f111
        lda     $f054,x
        sec
        sbc     #$08
        sta     $f112
        stz     $f113
        bra     @e489
@e470:  lda     #$40
        sta     $f484
        lda     $f043,x
        sta     $f111
        lda     $f044,x
        sec
        sbc     #$0c
        sta     $f112
        lda     #$f8
        sta     $f113
@e489:  lda     #$08
        sta     $f115
        jsl     CalcTrajectory_far

; start of frame loop
@e492:  jsr     WaitFrame_near
        jsr     CopyDarkWaveSprites
        jsl     UpdateTrajectory_far
        bcs     @e4c7
        lda     $f118
        sta     $00
        lda     $f119
        sta     $02
        clr_ay
        phy
        lda     #$84
        jsr     DrawDarkWaveSprites
        ldy     #$000c
        plx
        lda     #$84
        jsr     UpdateDarkWaveSprites
        ldy     #$0018
        ldx     #$0001
        lda     #$84
        jsr     UpdateDarkWaveSprites
        jmp     @e492
@e4c7:  jsl     DisableAnimPalEffect_far
        stz     $ef87
        rtl

; ------------------------------------------------------------------------------

; [  ]

UpdateDarkWaveSprites:
@e4cf:  pha
        phy
        lda     #$10
        jsr     IncPolarAngle_near
        jsr     CalcPolarY_near
        clc
        adc     $f119
        sta     $02
        ply
        pla
        jmp     DrawDarkWaveSprites

; ------------------------------------------------------------------------------

; [ copy sprites for dark wave attack ]

CopyDarkWaveSprites:
@e4e4:  ldy     #$001c
        longa
@e4e9:  lda     $0340,y
        sta     $0344,y
        lda     $0342,y
        clc
        adc     #$0002
        sta     $0346,y
        dey4
        cpy     #$fffc
        bne     @e4e9
        shorta0
        rts

; ------------------------------------------------------------------------------

; [ draw sprites for dark wave, mist dragon, and holy animations ]

; draw pre-holy animation sprites
DrawPreHolySprites:
@e506:  stz     $f484
        lda     #$82

; draw dark wave and mist dragon sprites
DrawDarkWaveSprites:
@e50b:  sta     $0342,y
        lda     $02
        sta     $0341,y
        lda     $6cc0
        bne     @e521
        lda     $00
        sta     $0340,y
        lda     #$3f
        bra     @e52a
@e521:  lda     $00
        eor     #$ff
        sta     $0340,y
        lda     #$7f
@e52a:  eor     $f484
        sta     $0343,y
        iny4
        rts

; ------------------------------------------------------------------------------

; [ copy pre-holy animation sprites ]

CopyPreHolySprites:
@e535:  jsr     CopyBasePreHolySprites
        jmp     CopyFlippedPreHolySprites

; ------------------------------------------------------------------------------

; [ copy pre-holy animation sprites (not flipped) ]

CopyBasePreHolySprites:
@e53b:  ldy     #$0040
        longa
@e540:  lda     $0340,y
        sta     $0344,y
        lda     $0342,y
        sta     $0346,y
        dey4
        cpy     #$fffc
        bne     @e540
        shorta0
        rts

; ------------------------------------------------------------------------------

; [ copy pre-holy animation sprites (flipped) ]

CopyFlippedPreHolySprites:
@e559:  clr_ay
        longa
@e55d:  lda     $0340,y
        eor     #$00ff
        sta     $0380,y
        lda     $0342,y
        sta     $0382,y
        iny4
        cpy     #$0040
        bne     @e55d
        shorta0
        rts

; ------------------------------------------------------------------------------

; [ pre-holy animation (white) ]

PreHolyAnim:
@e579:  jsr     ResetAnimSpritesLarge_near
        jsl     InitPolarAngle_far
        lda     #$10
        sta     $f1b3
        sta     $f1f3
        clr_a
        sta     $f398
        lda     #$30
        sta     $f399
        jsr     PlayMagicSfx_near
        jsr     _01ee8f

; start of 1st frame loop (balls move to center)
@e597:  jsr     WaitFrame_near
        jsr     CopyPreHolySprites
        clr_ax
        jsr     CalcPolarY_near
        clc
        adc     $f399
        sta     $02
        lda     $f398
        sta     $00
        clr_ax
        lda     #$20
        jsr     IncPolarAngle_near
        ldy     #0
        clr_a
        jsr     DrawPreHolySprites
        dec     $f399
        dec     $f399
        lda     $f398
        sec
        sbc     #$08
        sta     $f398
        cmp     #$80
        bne     @e597
        lda     #$c0
        sta     $f133
        clc
        adc     #$40
        sta     $f173
        lda     #$20
        sta     $f1b3
        sta     $f1f3
        lda     #$80
        sta     $f398
        lda     #$08
        sta     $f399

; start of 2nd frame loop (balls converge)
@e5eb:  jsr     WaitFrame_near
        jsr     CopyPreHolySprites
        clr_ax
        jsr     CalcPolarX_near
        clc
        adc     $f398
        sta     $00
        jsr     CalcPolarY_near
        clc
        adc     $f399
        sta     $02
        clr_ay
        jsr     DrawPreHolySprites
        clr_ax
        lda     #$20
        jsr     IncPolarAngle_near
        lda     $f1b3
        cmp     #$08
        bcc     @e621
        clr_ax
        dec
        jsr     IncPolarRadius_near
        jmp     @e5eb
@e621:  clr_ax
        lda     $f463
        sta     $04
@e628:  asl     $04
        bcc     @e647
        lda     $f462
        bmi     @e63b
        lda     $f053,x
        sta     $00
        lda     $f054,x
        bra     @e643
@e63b:  lda     $f043,x
        sta     $00
        lda     $f044,x
@e643:  sta     $01
        bra     @e64e
@e647:  inx2
        cpx     #$0010
        bne     @e628
@e64e:  lda     #$08
        sta     $f112
        lda     $00
        cmp     #$80
        bcc     @e65d
        lda     #$58
        bra     @e65f
@e65d:  lda     #$a8
@e65f:  sta     $f111
        ldx     $00
        stx     $f113
        lda     #$10
        sta     $f115
        jsl     CalcTrajectory_far

; start of 3rd frame loop (balls move to target)
@e670:  jsr     WaitFrame_near
        jsr     CopyBasePreHolySprites
        jsl     UpdateTrajectory_far
        bcs     @e698
        stz     $01
        stz     $03
        lda     $f118
        sec
        sbc     #$08
        sta     $00
        lda     $f119
        sec
        sbc     #$08
        sta     $02
        clr_ay
        jsr     DrawPreHolySprites
        jmp     @e670
@e698:  stz     $ef87
        rtl

; ------------------------------------------------------------------------------

; [ hit character animation (for magic attacks) ]

MagicHitCharAnim:
@e69c:  lda     $38e2
        beq     @e6f7
        lda     $f466
        bmi     @e6f7
        jsr     ResetAnimSpritesLarge_near
        stz     $4e
        clr_ay
@e6ad:  lda     $f099,y                 ; save pose
        sta     $f09e,y
        iny
        cpy     #5
        bne     @e6ad

; start of frame loop
@e6b9:  jsr     WaitFrame_near
        lda     $f467                   ; targetted characters
        sta     $00
        clr_ay
@e6c3:  asl     $00
        bcc     @e6db
        lda     #$07                    ; hit pose
        sta     $f099,y
        tya
        asl4
        tax
        lda     $4e
        and     #$04
        eor     #$04
        sta     $efc7,x
@e6db:  iny
        cpy     #5
        bne     @e6c3
        inc     $4e
        lda     $4e
        cmp     #$10                    ; 16 frames
        bne     @e6b9
        clr_ay
@e6eb:  lda     $f09e,y                 ; restore previous pose
        sta     $f099,y
        iny
        cpy     #5
        bne     @e6eb
@e6f7:  rtl

; ------------------------------------------------------------------------------

; [ draw sprites for firaga animation ]

DrawFiragaSprites:
@e6f8:  phx
        lda     $6cc0
        beq     @e715
        lda     $01
        clc
        adc     #$0f
        bpl     @e70c
        clc
        adc     $00
        bcc     @e725
        bra     @e711
@e70c:  clc
        adc     $00
        bcs     @e725
@e711:  eor     #$ff
        bra     @e72f
@e715:  lda     $01
        bpl     @e720
        clc
        adc     $00
        bcc     @e725
        bra     @e72f
@e720:  clc
        adc     $00
        bcc     @e72f
@e725:  lda     #$f0
        sta     $0340,y
        sta     $0341,y
        bra     @e75e
@e72f:  sta     $0340,y
        lda     $02
        clc
        adc     $03
        sta     $0341,y
        lda     $04
        and     #$60
        lsr4
        tax
        lda     f:FiragaAnimTilesTbl,x
        sta     $0342,y
        lda     f:FiragaAnimTilesTbl+1,x
        eor     $05
        pha
        lda     $6cc0
        beq     @e75a
        pla
        eor     #$40
        pha
@e75a:  pla
        sta     $0343,y
@e75e:  iny4
        plx
        rts

; ------------------------------------------------------------------------------

; [ update sprites for firaga animation ]

UpdateFiragaSprites:
@e764:  lda     $00
        pha
        lda     $00
        sec
        sbc     #$10
        sta     $00
        jsr     CalcPolarX_near
        sta     $01
        jsr     CalcPolarY_near
        sta     $03
        lda     $f173,x
        sta     $04
        stz     $05
        jsr     DrawFiragaSprites
        lda     $00
        clc
        adc     #$20
        sta     $00
        lda     $01
        eor     #$ff
        sta     $01
        lda     #$40
        sta     $05
        jsr     DrawFiragaSprites
        pla
        sta     $00
        rts

; ------------------------------------------------------------------------------

; [ fire 3 animation (firaga) ]

FiragaAnim:
@e79a:  sta     $f13d
        jsr     ResetAnimSpritesLarge_near
        jsl     InitPolarAngle_far
        clr_ax
@e7a6:  lda     f:FiragaYRadiusTbl,x
        sta     $f1b3,x
        lda     f:FiragaXRadiusTbl,x
        sta     $f1f3,x
        lda     #$fc
        jsr     IncPolarAngle_near
        inx
        cpx     #4
        bne     @e7a6

; start of frame loop
@e7bf:  jsr     WaitFrame_near
        clr_ayx
        lda     $f13d
        sta     $0a
@e7ca:  asl     $0a
        bcc     @e7fb
        lda     $f13e
        bmi     @e7e0
        lda     $f053,x
        clc
        adc     #$10
        sta     $00
        lda     $f054,x
        bra     @e7eb
@e7e0:  lda     $f043,x
        sec
        sbc     #$0c
        sta     $00
        lda     $f044,x
@e7eb:  sta     $02
        phx
        ldx     #0
@e7f1:  jsr     UpdateFiragaSprites
        inx
        cpx     #4
        bne     @e7f1
        plx
@e7fb:  inx2
        cpx     #$0010
        bne     @e7ca
        clr_ax
@e804:  lda     f:FiragaAngleRateTbl,x
        jsr     IncPolarAngle_near
        inx
        cpx     #4
        bne     @e804
        lda     $f133
        cmp     #$80
        bcs     @e7bf
        rtl

; ------------------------------------------------------------------------------

FiragaAngleRateTbl:
@e819:  .lobytes -4,-3,-4,-3

; ------------------------------------------------------------------------------

; [ random (0..255) ]

Rand3:
@e81d:  inc     $97
        lda     $97
        tay
        lda     $1900,y     ; rng table
        rts

; ------------------------------------------------------------------------------

; [  ]

_01e826:
@e826:  phx
        clr_ax
@e829:  lsr     $04
        bcc     @e854
        jsr     Rand3
        and     #$07
        clc
        adc     f:_16fff6,x
        sta     $00
        jsr     Rand3
        and     #$1f
        adc     f:_16fff6+1,x
        sta     $01
        lda     $00
        sec
        sbc     #$08
        sta     $f459,x
        lda     $01
        sec
        sbc     #$08
        sta     $f45a,x
@e854:  inx2
        cpx     #8
        bne     @e829
        plx
        rtl

; ------------------------------------------------------------------------------

; [  ]

_01e85d:
@e85d:  lda     $f458
        tax
        phx
        lda     f:_13f900,x
        sta     $04
        jsl     _01e826
        plx
        phx
        lda     f:_16fb00,x
        tax
        clr_ay
@e875:  lda     f:_16fb09,x
        sta     $f3b0,y
        inx
        iny
        cpy     #$0012
        bne     @e875
        plx
        lda     f:_16faa6,x
        tax
        clr_ay
@e88b:  lda     f:_16faaf,x
        asl
        phx
        tax
        lda     $f3b0,y
        clc
        adc     $f459,x
        sta     $f3b0,y
        lda     $f3b1,y
        clc
        adc     $f45a,x
        sta     $f3b1,y
        plx
        inx
        iny2
        cpy     #$0012
        bne     @e88b
        inc     $f458
        lda     $f458
        cmp     #$09
        bne     @e8bc
        stz     $f458
@e8bc:  rtl

; ------------------------------------------------------------------------------

; [ load battle bg tilemap ]

LoadBattleBGTiles:
@e8bd:  lda     $1802                   ; battle bg id
        and     #$1f
        pha
        asl2
        tax
        lda     f:BattleBGProp+3,x      ; tile offset
        sta     $06
        lda     f:BattleBGProp+2,x      ; bottom tilemap
        jsr     LoadBattleBGBtmTiles
        clr_ay
        lda     f:BattleBGProp,x        ; top tilemap
        phx
        jsr     GetBattleBGTopTilesPtr
        jsr     LoadBattleBGTopTiles
        plx
        lda     f:BattleBGProp+1,x      ; middle tilemap
        beq     @e8ed
        jsr     GetBattleBGTopTilesPtr
        jsr     LoadBattleBGTopTiles
@e8ed:  pla
        cmp     #$10
        bne     @e904                   ; branch if not final boss
        ldx     #0
@e8f5:  lda     $707e,x                 ; toggle horizontal flip
        ora     #$20
        sta     $707e,x
        inx2
        cpx     #$0440
        bne     @e8f5
@e904:  rtl

; ------------------------------------------------------------------------------

; [ get pointer to upper battle bg tilemap ]

GetBattleBGTopTilesPtr:
@e905:  sta     $27         ; multiply by 256
        stz     $26
        ldx     $26
        rts

; ------------------------------------------------------------------------------

; [ load lower battle bg tilemap ]

LoadBattleBGBtmTiles:
@e90c:  phx
        longa
        asl6
        clc
        adc     #$f880
        sta     $00
        shorta0
        lda     #$16
        sta     $02
        clr_axy
@e925:  lda     [$00],y
        sta     $04
        and     #$80
        sta     $05
        lda     $04
        and     #$3f
        inc
        clc
        adc     $06
        sta     $6efd,x
        inx
        lda     $04
        and     #$40
        lsr4
        clc
        adc     #$04
        ora     #$02
        ora     $05
        sta     $6efd,x
        inx
        iny
        tya
        and     #$3f
        tay
        cpx     #$0280      ; load 320 tiles (10 rows)
        bne     @e925
        plx
        rts

; ------------------------------------------------------------------------------

; [ load upper battle bg tilemap ]

LoadBattleBGTopTiles:
@e958:  lda     #$00        ; load 256 tiles (8 rows)
        sta     $04
@e95c:  lda     f:BattleBGTopTiles,x
        sta     $02
        and     #$80
        sta     $03         ; vertical flip
        lda     $02
        and     #$3f        ; tile index
        inc
        sta     $6cfd,y     ; vram buffer
        iny
        lda     $02
        and     #$40        ; palette (1 or 2)
        lsr4
        clc
        adc     #$04
        ora     #$02
        ora     $03
        sta     $6cfd,y
        iny
        inx
        dec     $04
        bne     @e95c
        rts

; ------------------------------------------------------------------------------

; [ update monster rows ]

UpdateMonsterRows:
@e988:  clr_ax
        lda     #$80
@e98c:  sta     $35eb,x
        inx
        cpx     #8
        bne     @e98c
        clr_ax
@e997:  lda     $f333,x
        tay
        lda     $f123,y
        cmp     #$ff
        bne     @e9a8
        inx
        cpx     #8
        bne     @e997
@e9a8:  lda     $f333,x
        jsr     GetMonsterLeftPos
        lda     $00
        sta     $02
        clr_ax
@e9b4:  lda     $f123,x
        cmp     #$ff
        beq     @e9c8
        txa
        jsr     GetMonsterLeftPos
        dec
        cmp     $02
        bcc     @e9c8
        clr_a
        sta     $35eb,x
@e9c8:  inx
        cpx     #8
        bne     @e9b4
        rtl

; ------------------------------------------------------------------------------

; [ play default magic sound effect (near) ]

PlayMagicSfx_near:
@e9cf:  jsl     PlayMagicSfx_far
        rts

; ------------------------------------------------------------------------------

; [ h-flip tilemap ]

FlipTiles:
@e9d4:  ldx     #$6cfd
        stx     $00
        ldx     #$0012      ; 18 rows
        stx     $02
        jmp     _ea37

; ------------------------------------------------------------------------------

; [ modify monster tilemap (back attack and demon wall) ]

ModifyBG1Tiles:
@e9e1:  ldx     #$6cfd                  ; tilemap buffer
        stx     $00
        ldx     #18                     ; 18 rows
        stx     $02
        lda     $f411
        beq     _ea37                   ; branch if no demon wall offset
        asl
        sta     $06
        clc
        adc     $00
        sta     $04
        lda     $01
        adc     #0
        sta     $05
        lda     #$40
        sec
        sbc     $06
        tay
        sty     $06
@ea06:  longa
        clr_ay
@ea0a:  lda     ($04),y
        sta     ($00),y
        iny2
        cpy     $06
        bne     @ea0a
        lda     #$2200                  ; blank tile ???
@ea17:  sta     ($00),y
        iny2
        cpy     #$0040
        bne     @ea17
        lda     $04
        clc
        adc     #$0040
        sta     $04
        lda     $00
        clc
        adc     #$0040
        sta     $00
        shorta0
        dec     $02
        bne     @ea06

; h-flip
_ea37:  lda     $6cc0
        beq     @ea68                   ; return if not back attack
        longa
@ea3e:  clr_ay
@ea40:  lda     ($00),y                 ; push a full row onto the stack
        pha
        iny2
        cpy     #$0040
        bne     @ea40
        clr_ay
@ea4c:  pla
        eor     #$4000                  ; reverse order and toggle h-flip
        sta     ($00),y
        iny2
        cpy     #$0040
        bne     @ea4c
        lda     $00
        clc
        adc     #$0040
        sta     $00
        dec     $02
        bne     @ea3e
        shorta0
@ea68:  rtl

; ------------------------------------------------------------------------------

; [ get monster's left side position ]

GetMonsterLeftPos:
@ea69:  tay
        lda     $29a5,y                 ; x position
        lsr4
        sta     $00
        tya
        asl
        tay
        lda     $f2a1,y                 ; visible width
        clc
        adc     $00
        rts

; ------------------------------------------------------------------------------

; [ divide (used for doom numerals) ]

DivDoomNum:
@ea7d:  phx
        longa
        pha
        stz     $20
        stz     $22
        lda     $1c
        beq     @eaa9
        lda     $1e
        beq     @eaa9
        ldx     #$0010
@ea90:  rol     $1c
        rol     $22
        sec
        lda     $22
        sbc     $1e
        sta     $22
        bcs     @eaa4
        lda     $22
        adc     $1e
        sta     $22
        clc
@eaa4:  rol     $20
        dex
        bne     @ea90
@eaa9:  pla
        shorta
        plx
        rts

; ------------------------------------------------------------------------------

; [ update doom numerals ]

UpdateDoomNum:
@eaae:  phx
        lda     $47
        tax
        lda     f:CharTimerPtrs,x
        tax
        lda     $2a16,x                 ; doom timer
        tax
        stx     $1c
        ldx     #10                     ; divide by 10
        stx     $1e
        jsr     DivDoomNum
        lda     $22
        clc
        adc     #$70                    ; tile id for "0"
        sta     $f07a
        lda     $20
        clc
        adc     #$70
        sta     $f079
        plx
        lda     #$04
        sta     $efd0,x
        lda     #$09
        sta     $f078
        rtl

; ------------------------------------------------------------------------------

; [ reset ram ]

ResetRAM:
@eae1:  lda     $3581
        sta     $6cc0
        clr_a
        ldx     #$ed50
@eaeb:  sta     a:$0000,x               ; clear $ed50-$f4bb
        inx
        cpx     #$f4bc
        bne     @eaeb
        ldx     #$180c
@eaf7:  sta     a:$0000,x
        inx
        cpx     #$1847
        bne     @eaf7
        clr_ax
        stz     $d7
        stz     $47
        stx     $48
        stx     $4a
        stx     $4c
        stz     $4e
        stx     $5f
        stx     $61
        stz     $63
        stz     $64
        stx     $37
        stx     $39
        sta     $6cc1
        sta     $6cc2
        inc     $f07b                   ; enable status sprites
        inc     $f07f
        inc     $f083
        inc     $f087
        inc     $f08b
@eb2f:  sta     a:$004f,x
        inx4
        cpx     #$0010
        bne     @eb2f
        ldx     $1800
        cpx     #$00f4
        bne     @eb47
        lda     #$02
        bra     @eb4e
@eb47:  cpx     #$01af
        bne     @eb51
        lda     #$12
@eb4e:  sta     $f411
@eb51:  inc     $f28b
        clr_ax
@eb56:  lda     #$ff
        sta     $f2b4,x
        lda     #$80
        sta     $ef6b,x                 ; clear menu cursor positions
        sta     $ef7a,x                 ; clear target cursor positions
        inx
        cpx     #8
        bne     @eb56
        lda     #$02
        sta     $183a
        sta     $183c
        sta     $183e
        ldx     #$0101
        stx     $ef69
        stx     $ef83                   ; hide up and down list arrows
        stx     $ef76
        stx     $ef78
        inc     $ef73
        clr_ax
        longa
        lda     #.loword(AnimGfx)
@eb8d:  sta     $7ff000,x
        clc
        adc     #$0018
        inx2
        cpx     #$0600
        bne     @eb8d
        lda     #0
        shorta
        clr_ax
@eba3:  lda     f:FinalBGScrollForwardTbl,x
        sta     $f488,x
        inx
        cpx     #$0012
        bne     @eba3
        jsl     UpdateColorMath
        lda     #$18                    ; set button repeat rates
        sta     $01dd
        lda     #$03
        sta     $01dc
        rtl

; ------------------------------------------------------------------------------

; [ draw pause window text ]

DrawPauseText:
@ebbf:  clr_axy
@ebc2:  lda     f:PauseText,x
        sta     $dc42,y
        inx
        iny2
        cpx     #5
        bne     @ebc2
        rtl

; ------------------------------------------------------------------------------

; [ init bg scroll hdma ]

InitScrollHDMA:
@ebd2:  clr_ax
@ebd4:  lda     f:ScrollHDMATbl,x       ; load bg scroll hdma tables
        sta     $75fd,x
        inx
        cpx     #$0015
        bne     @ebd4
        clr_ax
@ebe3:  sta     $7612,x                 ; clear hdma data
        inx
        cpx     #$1620
        bne     @ebe3
        clr_ax
        lda     #$fe
@ebf0:  sta     $7d14,x                 ; bg3 v-scroll
        dec
        inx4
        cpx     #$0380
        bne     @ebf0
        ldx     #$0230
@ec00:  lda     $7d14,x
        dec
        sta     $7994,x                 ; bg2 v-scroll
        inx4
        cpx     #$0280
        bne     @ec00
        longa
        clr_ax
        lda     #$0173
        ldy     #$0008
@ec1a:  sta     $8094,x
        pha
        clc
        adc     #$0068
        sta     $8314,x
        clc
        adc     #$00f0
        sta     $8af4,x
        pla
        dey
        bne     @ec37
        clc
        adc     #$0004
        ldy     #$000c
@ec37:  cpx     #$0110
        bne     @ec40
        clc
        adc     #$0004
@ec40:  inx4
        cpx     #$0130
        bne     @ec1a
        clr_ax
        lda     #$016f
        ldy     #$0008
@ec51:  inc     $81d3,x
        sta     $81d4,x
        dey
        bne     @ec61
        clc
        adc     #$0004
        ldy     #$000c
@ec61:  cpx     #$0110
        bne     @ec6a
        clc
        adc     #$0134
@ec6a:  inx4
        cpx     #$0130
        bne     @ec51
        clr_ax
        lda     #$006b
        ldy     #$0008
@ec7b:  sta     $8454,x
        dey
        bne     @ec88
        clc
        adc     #$0004
        ldy     #$000c
@ec88:  cpx     #$0088
        bne     @ec91
        clc
        adc     #$0004
@ec91:  inx4
        cpx     #$00a0
        bne     @ec7b
        clr_ax
@ec9c:  lda     $8072,x
        sta     $81c2,x
        sta     $8442,x
        inx2
        cpx     #$0010
        bne     @ec9c
        clr_ax
@ecae:  lda     #$0101
        sta     $84f2,x
        inx4
        cpx     #$0100
        bne     @ecae
        clr_ax
        lda     #$0053
        ldy     #$0008
@ecc5:  sta     $85f4,x
        sta     $8874,x
        pha
        sec
        sbc     #$000c
        sta     $8674,x
        sta     $88f4,x
        sec
        sbc     #$000c
        sta     $86f4,x
        sta     $8974,x
        sec
        sbc     #$000c
        sta     $8774,x
        sta     $89f4,x
        sec
        sbc     #$000c
        sta     $87f4,x
        sta     $8a74,x
        pla
        dey
        bne     @ecfc
        clc
        adc     #$0004
@ecfc:  pha
        lda     #$00ac
        sta     $8872,x
        sta     $88f2,x
        sta     $8972,x
        sta     $89f2,x
        sta     $8a72,x
.if LANG_EN
        lda     #$01ac                  ; scroll position for row change window
.else
        lda     #$01bc
.endif
        sta     $85f2,x
        sta     $8672,x
        sta     $86f2,x
        sta     $8772,x
        sta     $87f2,x
        pla
        inx4
        cpx     #$0070
        bne     @ecc5
        ldx     #$001c
        ldy     #$0004
        lda     #$0134
@ed34:  sta     $7d14,x
        dey
        bne     @ed3e
        clc
        adc     #$0004
@ed3e:  inx4
        cpx     #$0080
        bne     @ed34
        clr_ax
@ed49:  lda     #$0100
        sta     $8c32,x
        lda     #$0160
        sta     $8c34,x
        inx4
        cpx     #$0080
        bne     @ed49
        shorta0
        rtl

; ------------------------------------------------------------------------------

; [ set monster v-scroll position (for jumping) ]

SetMonsterScrollJump:
@ed62:  phx
        longa
        lda     $f408
        clc
        adc     $2a
        sta     $02
        jmp     _ed78

; ------------------------------------------------------------------------------

; [ set monster scroll hdma data ]

SetMonsterScroll:
@ed70:  phx
        longa
        lda     $f408
        sta     $02
_ed78:  lda     $f406
        sta     $00
        clr_ax
@ed7f:  lda     $00                     ; h-scroll
        sta     $7612,x
        sta     $769e,x
        sta     $772a,x
        sta     $77b6,x
        lda     $02                     ; v-scroll
        sta     $7614,x
        sta     $76a0,x
        sta     $772c,x
        sta     $77b8,x
        inx4
        cpx     #$008c
        bne     @ed7f
        shorta0
        plx
        rtl

; ------------------------------------------------------------------------------

; [ set bg and monster color for teleport spell animation ]

TeleportSetColor:
@eda9:  phy
        sty     $00
        longa
        asl4
        sta     $2a
        txa
        asl5
        clc
        adc     $00
        tay
        lda     $2a
        clc
        adc     $00
        tax
        shorta0
        lda     f:AnimPal,x
        sta     $ed50,y
        sta     $ed60,y
        ply
        rts

; ------------------------------------------------------------------------------

; [ modify palette for teleport animation ]

TeleportPalAnim:
@edd3:  clr_ay
@edd5:  phy
        jsr     WaitFrame_near
        ply
        ldx     #$0001
        lda     #$26
        jsr     TeleportSetColor
        ldx     #$0002
        lda     #$26
        jsr     TeleportSetColor
        ldx     #$0003
        lda     #$27
        jsr     TeleportSetColor
        ldx     #$0004
        lda     #$27
        jsr     TeleportSetColor
        ldx     #$0006
        lda     #$27
        jsr     TeleportSetColor
        iny
        cpy     #$0010
        bne     @edd5
        rtl

; ------------------------------------------------------------------------------

.include "special_anim.asm"
.include "summon.asm"

; ------------------------------------------------------------------------------
