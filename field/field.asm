
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                            FINAL FANTASY IV                                |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: field.asm                                                            |
; |                                                                            |
; | description: field program                                                 |
; |                                                                            |
; | created: 3/14/2022                                                         |
; +----------------------------------------------------------------------------+

.p816

.include "const.inc"
.include "hardware.inc"
.include "macros.inc"

.include "field_data.asm"
.include "header.asm"

; data imports
.import WindowGfx, WindowPal, SpellListInit

; function imports
.import MainMenu_ext, GameLoadMenu_ext, TreasureMenu_ext
.import InitCtrl_ext, UpdateCtrlField_ext
.import Battle_ext, UpdateEquip_ext
.import InitSound_ext, ExecSound_ext

; function exports
.export InitCharProp_ext

.export stack, JmpNMI, JmpIRQ
.export sprite_ram, sprite_ram_hi

; ------------------------------------------------------------------------------

.segment "stack"

stack:
JmpNMI:        .res 4
JmpIRQ:        .res 4

; ------------------------------------------------------------------------------

.segment "sprite_ram"

sprite_ram:                             .res $0200
sprite_ram_hi:                          .res $20

; ------------------------------------------------------------------------------

.segment "field_dp"

field_dp:

; ------------------------------------------------------------------------------

.segment "unused"
.a8
.i16

.if SKIP_INTRO
DebugInit:
        lda     #$fa            ; give key to tower of babil
        sta     $1440
        lda     #1
        sta     $1441
        phk
        per     @1-1
        pea     .loword($ffbe)
        jml     InitNewGame
@1:     phk
        per     @2-1
        pea     .loword($ffbe)
        jml     InitCharProp
@2:     jsl     InitSpellLists
        lda     #0
        sta     $1700       ; overworld
        sta     $171b       ; hovercraft world
        sta     $171f       ; enterprise world
        sta     $1722       ; falcon world
        sta     $1726       ; big whale world
        lda     #1
        sta     $1718       ; show hovercraft
        sta     $171c       ; show enterprise
        sta     $1720       ; show falcon
        sta     $1724       ; show big whale
        lda     #101
        sta     $1706
        sta     $1719
        sta     $171d
        sta     $1721
        inc
        sta     $1725
        lda     #158
        sta     $1707
        sta     $1726
        inc
        sta     $171a
        inc
        sta     $171e
        inc
        sta     $1722
        ldx     #50000          ; give gil
        stx     $16a0
        lda     #$36            ; give hook
        phk
        per     @3-1
        pea     .loword($ffbe)
        jml     SetEventSwitch
@3:     lda     #$30            ; open tunnel to underground
        phk
        per     @4-1
        pea     .loword($ffbe)
        jml     SetEventSwitch
@4:     rtl
.endif

; ------------------------------------------------------------------------------

.segment "field_code_ext"

InitCharProp_ext:
@ffbc:  jsr     InitCharProp
        rtl

; ------------------------------------------------------------------------------

.segment "field_code"
.a8
.i16

; ------------------------------------------------------------------------------

; [ reset ]

Reset:
@8000:  sei
        clc
        xce
        longi
        shorta
        stz     hMEMSEL
        stz     hMDMAEN
        stz     hHDMAEN
        lda     #$8f
        sta     hINIDISP
        lda     #0
        sta     hNMITIMEN
        lda     #0
        xba
        lda     #0
        pha
        plb
        ldx     #field_dp
        phx
        pld
        ldx     #stack+$ff
        txs
        jsr     InitInterrupts
        jsl     InitHWRegs
        jsl     ClearRAM
        jsl     InitSound_ext
        jsl     InitCtrl_ext
        jsr     ShowTitle

SoftReset:
@8040:  jsl     GameLoadMenu_ext
        lda     $17ef                   ; seed battle probability rng
        clc
        adc     $0fff
        sta     $17ef
        asl
        sta     $17ee                   ; seed battle index rng
        lda     $17fb
        cmp     #0
        bne     @808b                   ; branch if loading a saved game
.if SKIP_INTRO
        jsl     DebugInit
        bra     @808b
.else
; new game
        jsr     InitNewGame
        jsr     InitCharProp
        jsl     InitSpellLists
        jsl     InitHWRegs
        jsr     UpdatePlayerSpeed
        jsr     InitZoomHDMA
        lda     #1                      ; enable event
        sta     $b1
        lda     #1                      ; waiting for vblank
        sta     $7d
        lda     #$0f                    ; set screen brightness
        sta     $80
        lda     #$81
        sta     hNMITIMEN
        cli
        stz     $ab                     ; clear player movement direction
        lda     #$10                    ; intro
        jsr     ExecEvent
        stz     $b1                     ; no event
.endif
        jmp     MainLoop

; restore saved game
@808b:  jsr     InitZoomHDMA

AfterBattle:
@808e:  jsl     InitHWRegs
        jsr     UpdatePlayerSpeed
        lda     #1
        sta     $7d                     ; waiting for vblank
        stz     $df                     ; clear dialogue window height
        stz     $b1                     ; no event
        jmp     LoadMap

; ------------------------------------------------------------------------------

; [ field main ]

FieldMain:
@80a0:  stz     $79                     ; clear frame counters
        stz     $7a
        stz     $7b
        lda     #$81                    ; enable nmi
        sta     hNMITIMEN
        jsr     WaitFrame
        cli

MainLoop:
@80af:  jsr     WaitVblankLong
        stz     $e0
        jsl     ResetButtons
        jsr     CheckMenu
        lda     $e0
        beq     @80c2
        jmp     @80af
@80c2:  lda     $1700
        cmp     #3
        bne     @80cc
        jmp     @8138
; world map
@80cc:  lda     #7
        sta     hBGMODE
        jsr     CheckTriggerWorld
        lda     $e0
        beq     @80db
        jmp     @80af
@80db:  lda     $cd
        beq     @80e2
        jmp     LoadMap
@80e2:
.if NO_RAND_BATTLES
        nop3
.else
        jsr     CheckBattle
.endif
        lda     $85
        beq     @80ef
        jsr     BattleWorld
        jmp     AfterBattle
@80ef:  lda     $e0
        beq     @80f6
        jmp     @80af
@80f6:  jsr     CheckPlayerMoveWorld
        lda     $e0
        beq     @8103
        stz     $06ab
        jmp     @80af
@8103:  jsr     MovePlayer
        jsr     ResetSprites
        jsr     DrawWorldSprites
        jsr     UpdateWaterLavaAnim
        jsl     UpdateTopChar
        lda     $ce
        bne     @811a       ; branch if overworld/underground switch
        jmp     @80af
@811a:  stz     $ce
        lda     $1700
        bne     @8127
        jsr     GoDownTunnel
        jmp     FieldMain
@8127:  cmp     #1
        bne     @8131
        jsr     GoUpTunnel
        jmp     FieldMain
@8131:  cmp     #2
        bne     @8135
@8135:  jmp     @80af
; sub-map
@8138:  jsr     CheckTriggerSub
        lda     $cd
        beq     @8142
        jmp     LoadMap
@8142:
.if NO_RAND_BATTLES
        nop3
.else
        jsr     CheckBattle
.endif
        lda     $85
        beq     @814f                   ; branch if no battle
        jsr     BattleSub
        jmp     AfterBattle
@814f:  jsr     CheckTreasureNPC
        lda     $85
        beq     @815c                   ; branch if no battle
        jsr     BattleSub
        jmp     AfterBattle
@815c:  lda     $e0
        beq     @8163
        jmp     @80af
@8163:  jsr     CheckPlayerMoveSub
        jsr     CheckMoveNPCs
        jsr     MovePlayer
        jsr     MoveNPCs
        jsr     ResetSprites
        jsl     DrawPlayerSub
        jsr     DrawNPCs
        jsl     UpdateTopChar
        jsr     UpdateCaveWaterGfx
        lda     $d1
        beq     @81f1
        ldx     $172c
        dex3
        stx     $172c
        lda     $172e,x
        cmp     #$fb
        bcc     @8197
        jsr     FadeOutSongFast
@8197:  jsr     WipeOut
        stz     $d6
        lda     $172e,x
        sec
        sbc     #$fb
        bcc     @81c4
        sta     $1700
        lda     $172f,x
        sta     $1706
        lda     #$02                    ; face down
        sta     $1705
        lda     $1730,x
        sta     $1707
        ldx     #0
        stx     $172c
        jsr     FadeOutSongFast
        jmp     LoadMap
@81c4:  lda     #$03
        sta     $1700
        lda     $172e,x
        sta     $1702
        lda     $172f,x
        and     #$3f
        sta     $1706
        lda     $172f,x
        lsr6
        clc
        adc     #$02
        and     #$03
        sta     $1705                   ; set facing direction
        lda     $1730,x
        sta     $1707
        jmp     LoadMap
@81f1:  jmp     @80af

; ------------------------------------------------------------------------------

; [ check menu ]

CheckMenu:
@81f4:  lda     $d5
        bne     @81f9       ; return if player control is disabled
        rts
@81f9:  lda     $50         ; return if x button was already processed
        beq     @8200
        jmp     @828f
@8200:  lda     $02         ; return if x button is not pressed
        and     #JOY_X
        bne     @8209
        jmp     @828f
@8209:  lda     #$01
        sta     $50
        lda     $1700
        cmp     #$03
        bne     @821e
        lda     $0fdb
        and     #$30
        ora     #$80
        jmp     @822a
@821e:  lda     $1704
        bne     @8228
        lda     #$40
        jmp     @822a
@8228:  lda     #$00
@822a:  sta     $1a04
        jsr     FadeOutMenu
        jsl     MainMenu_ext
        lda     $1700
        cmp     #$03
        bne     @8241
        ldx     $16aa
        stx     $0cdd
@8241:  jsr     FadeInMenu
        lda     $1a03
        beq     @828f       ; return if no menu event
        lda     #$01
        sta     $b1
        stz     $ab
        lda     $1a03       ; menu event
        cmp     #$03
        bcs     @825f       ; branch if not tent or cabin
        lda     $1a03
        clc
        adc     #$76
        jmp     @8287
@825f:  cmp     #$03
        bne     @8268
        lda     #$87
        jmp     @8287
@8268:  cmp     #$04
        bne     @8271
        lda     #$86
        jmp     @8287
@8271:  cmp     #$05
        bne     @827a
        lda     #$fb
        jmp     @8287
@827a:  cmp     #$06
        bne     @8285
        lda     #$01
        sta     $c0
        jmp     @828a
@8285:  lda     #$db
@8287:  jsr     ExecEvent
@828a:  stz     $b1
        jsr     PlayMapSong
@828f:  rts

; ------------------------------------------------------------------------------

; [ init new game ]

InitNewGame:
@8290:  stz     $1700
        stz     $1701
        stz     $1703
        stz     $170f
        stz     $1712
        stz     $1718
        stz     $171c
        stz     $1720
        stz     $1724
        stz     $1728
        stz     $172b
        stz     $171b
        stz     $171f
        stz     $1723
        stz     $1727
        ldx     #0
        stx     $172c
        ldx     #0
@82c6:  lda     f:InitNPCSwitch,x       ; initial npc switches
        sta     $12e0,x
        inx
        cpx     #$0040
        bne     @82c6
        ldx     #0
@82d6:  lda     f:InitEventSwitch,x     ; initial event switches
        sta     $1280,x
        inx
        cpx     #$0020
        bne     @82d6
        ldx     #0
@82e6:  stz     $12a0,x
        inx
        cpx     #$0020
        bne     @82e6
        lda     #$fe
        sta     $149c
        lda     #$ff
        sta     $149e
        lda     #1
        sta     $149d
        sta     $149f
        rts

; ------------------------------------------------------------------------------

; [ update player movement speed ]

UpdatePlayerSpeed:
@8302:  lda     $1704       ; vehicle id
        tax
        lda     PlayerSpeedTbl,x     ; movement speed
        sta     $ac
        rts

; movement speed for each vehicle
PlayerSpeedTbl:
@830c:  .byte   0,1,2,1,3,3,3

; ------------------------------------------------------------------------------

; [ load map ]

LoadMap:
@8313:  lda     $1700
        bne     @8321

; 0: overworld
        jsr     LoadOverworld
        jsr     WipeIn
        jmp     FieldMain

; 1: underground
@8321:  cmp     #1
        bne     @832e
        jsr     LoadUnderground
        jsr     WipeIn
        jmp     FieldMain

; 2: moon
@832e:  cmp     #2
        bne     @833b
        jsr     LoadMoon
        jsr     WipeIn
        jmp     FieldMain

; sub-map
@833b:  lda     $85
        beq     @8345
        jsr     ReloadSubMap
        jmp     @8348
@8345:  jsr     LoadSubMap
@8348:  jsr     WipeIn
        jmp     FieldMain

; ------------------------------------------------------------------------------

; [ init map ram ]

InitMapRAM:
@834e:  lda     #$80
        sta     hINIDISP
        stz     hHDMAEN
        stz     hNMITIMEN       ; disable nmi and irq
        sei
        jsr     ResetSprites
        stz     $7a         ; animation frame counter
        stz     $94
        stz     $eb
        stz     $e9
        stz     $eb
        stz     $ec
        stz     $ed
        stz     $ea         ; show map name
        stz     $e7
        stz     $e8
        stz     $d4
        stz     $ab
        stz     $cf
        stz     $da
        stz     $c9
        stz     $c4
        stz     $c1
        lda     #1
        sta     $54
        sta     $55
        sta     $50
        sta     $51
        sta     $52
        sta     $53
        sta     $56
        sta     $57
        stz     $66
        stz     $67
        stz     $68
        stz     $69
        lda     #$10
        sta     $ad         ; mode 7 zoom level
        ldx     #0
        stx     $06fb       ; mode 7 rotation angle
        rts

; ------------------------------------------------------------------------------

.pushseg
.segment "map_prop"

; 15/9c80
        .byte   $00,$00,$00,$0d
        .include .sprintf("data/map_prop_%s.asm", LANG_SUFFIX)
        .byte   $00,$7f,$00,$00,$00,$00,$00,$00,$7f

.popseg

; ------------------------------------------------------------------------------

; [ load sub-map ]

LoadSubMap:
@83a4:  jsr     InitMapRAM
        jsr     RemoveFloat
        stz     $ac
        lda     $1702
        sta     $18
        stz     $19
        lda     $1701
        beq     @83ba
        inc     $19
@83ba:  asl     $18
        rol     $19
        asl     $18
        rol     $19
        ldx     $18
        stx     $1a
        asl     $18
        rol     $19
        lda     $18
        clc
        adc     $1a
        sta     $18
        lda     $19
        adc     $1b
        sta     $19
        lda     $18
        clc
        adc     $1702
        sta     $18
        lda     $1701
        beq     @83e6
        lda     #$01
@83e6:  adc     $19
        sta     $19
        ldx     $18
        ldy     #0
@83ef:  lda     f:MapProp,x
        sta     $0fdb,y
        inx
        iny
        cpy     #$000d
        bne     @83ef
        lda     f:MapProp+12,x          ; next map's treasure offset
        sec
        sbc     $0fe7                   ; subtract treasure offset
        sta     $0711                   ; number of treasures
        lda     $0fdc
        sta     $06f9
        lda     $0fdd
        sta     $19
        stz     $18
        ldx     $18
        ldy     #0
@841a:  lda     f:MapTileProp,x
        sta     $0edb,y
        inx
        iny
        cpy     #$0100
        bne     @841a
        lda     $0fdd
        asl2
        sta     $19
        stz     $18
        ldx     $18
        lda     #$7f
        pha
        plb
        ldy     #0
@843a:  lda     f:MapTileset,x
        sta     $4800,y
        inx
        iny
        cpy     #$0400
        bne     @843a
        lda     #$00
        pha
        plb
        jsr     InitBG1Tilemap
        jsr     InitNPCs
; fallthrough

; ------------------------------------------------------------------------------

; [ reload sub-map ]

ReloadSubMap:
@8452:  jsr     InitMapRAM
        lda     #$17
        sta     $212c
        lda     #$09
        sta     $2105
        jsl     LoadWindowPal
        ldx     #$2000
        stx     $47
        ldx     #$1000
        stx     $45
        lda     #.bankbyte(WindowGfx)
        sta     $3c
        ldx     #.loword(WindowGfx)
        stx     $3d
        jsl     TfrVRAM
        ldx     #$2800
        stx     $47
        ldx     #$1000
        stx     $45
        stz     $76
        jsl     ClearVRAM
        jsl     LoadBGGfx
        lda     $0fdf
        and     #$7f
        jsr     ClearBGTilemap
        jsl     LoadMapPal
        jsl     InvertPal
        lda     $85
        bne     @84a9                   ; branch if returning from a battle
        lda     $b1
        bne     @84a9                   ; branch if an event is running
        jsr     LoadMapTitle
@84a9:  stz     $d1
        stz     $85                     ; disable battle
        lda     $b1
        bne     @84b4
        jsr     PlayMapSong
@84b4:  lda     $81
        bne     @84d9
        lda     #$11
        sta     $212d
        lda     $0fe4
        lsr
        bcc     @84d0
        lda     #$02
        sta     $2130
        lda     #$43
        sta     $2131
        jmp     @84ea
@84d0:  stz     $2130
        stz     $2131
        jmp     @84ea
@84d9:  stz     $212d
        lda     #$83
        sta     $2131
        lda     $83
        and     #$e0
        ora     $81
        sta     $2132
@84ea:  jsr     InitBG2Tilemap
        jsr     InitBG1Tilemap
        jsl     LoadBGAnimGfx
        jsr     LoadCaveWaterGfx
        jsl     TfrBGAnimGfx
        jsr     LoadPlayerGfxSub
        jsr     UpdateBG2Scroll
        rts

; ------------------------------------------------------------------------------

; [ load overworld ]

LoadOverworld:
@8502:  jsr     InitMapRAM
        jsr     InitWorld
        stz     $1701
        stz     $06fa
        jsr     LoadWaterGfx
        lda     #.bankbyte(WorldPal_0000)
        ldx     #.loword(WorldPal_0000)
        jsr     LoadWorldPal
        lda     #.bankbyte(WorldTileset_0000)
        ldy     #.loword(WorldTileset_0000)
        jsr     LoadWorldTileset
        ldx     #0
@8524:  lda     f:WorldTileProp_0000,x
        sta     $0edb,x
        inx
        cpx     #$0100
        bne     @8524
        jsr     LoadPlayerGfxWorld
        jsr     _00f971
        jsl     UpdateZoomHDMA
        rts

; ------------------------------------------------------------------------------

; [ load underground ]

LoadUnderground:
@853c:  jsr     InitMapRAM
        jsr     InitWorld
        lda     #1
        sta     $1701
        stz     $06fa
        jsr     LoadLavaGfx
        lda     #.bankbyte(WorldPal_0001)
        ldx     #.loword(WorldPal_0001)
        jsr     LoadWorldPal
        lda     #.bankbyte(WorldTileset_0001)
        ldy     #.loword(WorldTileset_0001)
        jsr     LoadWorldTileset
        ldx     #0
@8560:  lda     f:WorldTileProp_0001,x
        sta     $0edb,x
        inx
        cpx     #$0100
        bne     @8560
        jsr     LoadPlayerGfxWorld
        jsr     _00f971
        rts

; ------------------------------------------------------------------------------

; [ load moon ]

LoadMoon:
@8574:  jsr     InitMapRAM
        jsr     InitWorld
        lda     #2
        sta     $1701
        lda     #$02
        sta     $06fa
        lda     #.bankbyte(WorldPal_0002)
        ldx     #.loword(WorldPal_0002)
        jsr     LoadWorldPal
        lda     #.bankbyte(WorldTileset_0002)
        ldy     #.loword(WorldTileset_0002)
        jsr     LoadWorldTileset
        ldx     #0
@8597:  lda     f:WorldTileProp_0002,x
        sta     $0edb,x
        inx
        cpx     #$0100
        bne     @8597
        jsr     LoadPlayerGfxWorld
        jsr     _00f971
        rts

; ------------------------------------------------------------------------------

; [ init world map ]

InitWorld:
@85ab:  jsr     RemoveFloat
        stz     $d1
        lda     $85
        bne     @85b9                   ; branch if returning from a battle
        lda     #$02
        sta     $1705                   ; face down
@85b9:  stz     $85                     ; disable battle
        lda     #7
        sta     hBGMODE
        lda     #$11                    ; enable sprites and bg1
        sta     $212c
        stz     $2130                   ; disable color math
        stz     $2131
        lda     $b1
        bne     @85d2
        jsr     PlayMapSong
@85d2:  jsl     TfrWorldGfx
        jsl     InvertPal
        rts

; ------------------------------------------------------------------------------

; [ remove float ]

RemoveFloat:
@85db:  ldx     #0
@85de:  lda     $1004,x                 ; clear float status
        and     #$bf
        sta     $1004,x
        jsr     NextChar
        cpx     #$0140
        bne     @85de
        rts

; ------------------------------------------------------------------------------

; [ screen off ]

ScreenOff:
@85ef:  lda     #$80
        sta     hINIDISP
        lda     #0
        sta     hNMITIMEN
        rts

; ------------------------------------------------------------------------------

.include .sprintf("title_%s.asm", LANG_SUFFIX)

; ------------------------------------------------------------------------------

; [ next sprite ]

NextSprite:
@88e2:  inx4
        iny4
        rts

; ------------------------------------------------------------------------------

; [ battle (world map) ]

BattleWorld:
@88eb:  lda     #$3f
        jsr     PlaySfx
        lda     #$01
        sta     $212c                   ; main screen only (hide sprites)
        stz     $79
@88f7:  jsr     WaitVblankShort
        stz     hHDMAEN
        lda     $79
        tax
        lda     f:BattleZoomTbl,x       ; world map battle effect zoom values
        sta     $ad
        jsr     CalcMode7Rot
        jsr     UpdateMode7Regs
        inc     $79
        lda     $79
        cmp     #$28
        bne     @88f7
        jsr     ExecBattle
        rts

; ------------------------------------------------------------------------------

; [ battle (sub-map) ]

BattleSub:
@8918:  lda     #$3f
        jsr     PlaySfx
        lda     #$03
        sta     hTM                     ; bg1 and bg2 only (hide sprites)
        stz     $79
@8924:  jsr     WaitVblankShort
        lda     $79
        lsr
        tax
        lda     BattleMosaicTbl,x
        sta     hMOSAIC
        inc     $79
        lda     $79
        cmp     #$2a
        bne     @8924
        lda     $c6
        bne     @8940
        jsr     UpdateBattleParams
@8940:  jsr     ExecBattle
        rts

; screen pixelation data for battle blur -> $2106
BattleMosaicTbl:
@8944:  .byte   $03,$23,$43,$63,$43,$23,$03,$23,$43,$63,$43,$23,$03,$23,$43,$63
        .byte   $83,$a3,$c3,$e3,$f3

; ------------------------------------------------------------------------------

; [ battle ]

; there is a bug in the Japanese ROM v1.0 described here:
; https://tcrf.net/final_fantasy_iv_(snes,_playstation)/version_differences

ExecBattle:
@8959:  ldx     $1800
        cpx     #$01b7
        bcc     @896b
        cpx     #$01b9
        bcs     @896b
        lda     #$10                    ; use final battle bg
        sta     $1802
@896b:
.if BUGFIX_WORLD_BATTLE
        lda     $1700
        cmp     #$03
        bne     @8993                   ; branch if not a sub-map
        lda     $1701
        beq     @8993                   ; branch if on overworld
.else
        lda     $1701
        cmp     #$01
        bne     @8993                   ; branch if not an underground/moon map
.endif
        lda     $1702
        cmp     #$5a                    ; cave bahamut maps
        bcc     @8980
        cmp     #$5d
        bcs     @8980
        jmp     @898b
@8980:
.if !BUGFIX_WORLD_BATTLE
        lda     $1702
.endif
        cmp     #$67                    ; lunar subterrane/core maps
        bcc     @8993
        cmp     #$7f
        bcs     @8993
@898b:  lda     $1801                   ; use moon monster action scripts
        ora     #$80
        sta     $1801
@8993:  jsr     ScreenOff
        php
        sei
        jsl     Battle_ext
        jsr     InitInterrupts
        plp
        lda     $1803
        bpl     @89b0
        jsl     ClearRAM
        ldx     #stack+$ff
        txs
        jmp     SoftReset
@89b0:  lda     $c6
        beq     @89bc
        sta     $1804
        stz     $c6
        jmp     @89d6
@89bc:  lda     $1804
        ora     $1805
        ora     $1806
        ora     $1807
        ora     $1808
        ora     $1809
        ora     $180a
        ora     $180b
        beq     @89dd                   ; branch if no items obtained
@89d6:  jsl     TreasureMenu_ext
        jsr     InitInterrupts
@89dd:  lda     #$80
        sta     $2100                   ; screen off
        lda     $1700
        cmp     #$03
        bne     @89ec
        jsr     ReloadNPCs
@89ec:  rts

; ------------------------------------------------------------------------------

; [ init interrupt jump code ]

InitInterrupts:
@89ed:  lda     #$5c                    ; jml
        sta     JmpNMI
        sta     JmpIRQ
        ldx     #FieldNMI
        stx     JmpNMI+1
        stz     JmpNMI+3
        ldx     #FieldIRQ
        stx     JmpIRQ+1
        stz     JmpIRQ+3
        rts

; ------------------------------------------------------------------------------

; [ fade out for menu ]

FadeOutMenu:
@8a08:  lda     #0
        jsr     FadeOut
        jsr     ScreenOff
        rts

; ------------------------------------------------------------------------------

; [ fade in after menu ]

FadeInMenu:
@8a11:  lda     $1700
        cmp     #3
        beq     @8a23                   ; branch if a sub-map
        lda     #$07                    ; set bg mode 7
        sta     $2105
        jsr     LoadPlayerGfxWorld
        jmp     @8a3e
@8a23:  lda     #$09                    ; set bg mode 1
        sta     $2105
        jsr     LoadPlayerGfxSub
        jsr     ReloadNPCs
        lda     $0fe4
        lsr
        bcc     @8a3e                   ; branch if no color addition
        lda     #$03
        sta     $2130
        lda     #$43
        sta     $2131
@8a3e:  jsl     InitHWRegs
        jsl     GetTopCharPtr
        lda     $1000,x
        bne     @8a4f
        jsl     ValidateTopChar
@8a4f:  jsr     ResetSprites
        lda     #$81
        sta     $4200                   ; enable nmi
        lda     #0
        jsr     FadeIn
        cli
        rts

; ------------------------------------------------------------------------------

; [ load cave water graphics ]

LoadCaveWaterGfx:

@CaveWaterGfx := MapGfx_000e + 67 * 24

@8a5e:  lda     #$7f
        pha
        plb
        ldx     #0
        ldy     #0
@8a68:  lda     f:@CaveWaterGfx,x
        sta     $5800,y
        inx
        iny
        tya
        and     #$0f
        bne     @8a68
@8a76:  lda     f:@CaveWaterGfx,x
        sta     $5800,y
        inx
        iny
        lda     #0
        sta     $5800,y
        iny
        tya
        and     #$0f
        bne     @8a76
        cpy     #$0100                  ; load 8 tiles (only 4 are used)
        bne     @8a68
        lda     #0
        pha
        plb
        rts

; ------------------------------------------------------------------------------

; [ transfer cave water graphics to vram ]

TfrCaveWaterGfx:
@8a94:  lda     $0fdd                   ; tileset
        cmp     #$0e
        beq     @8a9c                   ; branch if overworld cave
        rts
@8a9c:  lda     #$80
        sta     $2115
        jsr     InitDMA
        ldx     #$0430
        stx     $2116
        lda     #$01
        sta     $4300
        ldx     #$5800                  ; cave animated water graphics buffer
        stx     $4302
        lda     #$7f
        sta     $4304
        ldx     #$0100
        stx     $4305
        jsr     ExecDMA
        rts

; ------------------------------------------------------------------------------

; [ update cave animated water ]

UpdateCaveWaterGfx:
@8ac4:  lda     $7a
        and     #$01
        beq     @8acb
        rts
@8acb:  lda     $7a
        and     #$1e
        lsr
        tax
        lda     f:CaveWaterTbl,x        ; cave animated water data
        asl
        tax
        lda     $7f5800,x
        sta     $08
        lda     $7f5820,x
        jsr     RotateWord
        sta     $7f5800,x
        lda     $07
        sta     $7f5820,x
        lda     $7f5801,x
        sta     $08
        lda     $7f5821,x
        jsr     RotateWord
        sta     $7f5801,x
        lda     $07
        sta     $7f5821,x
        lda     $7f5810,x
        sta     $08
        lda     $7f5830,x
        jsr     RotateWord
        sta     $7f5810,x
        lda     $07
        sta     $7f5830,x
        rts

; ------------------------------------------------------------------------------

; [ rotate word ]

RotateWord:
@8b1d:  sta     $09
        sta     $07
        ror     $09
        ror     $08
        ror     $07
        lda     $08
        rts

; ------------------------------------------------------------------------------

; [ init dma ]

InitDMA:
@8b2a:  stz     hMDMAEN
        lda     #$18
        sta     $4301
        stz     $4304
        rts

; ------------------------------------------------------------------------------

; [ execute dma ]

ExecDMA:
@8b36:  lda     #1
        sta     hMDMAEN
        rts

; ------------------------------------------------------------------------------

.include "rand_battle.asm"

; ------------------------------------------------------------------------------

; [ fade out music (fast) ]

FadeOutSongFast:
@8d49:  lda     #$86                    ; fade out music (fast)
        sta     $1e00
        jsl     ExecSound_ext
        rts

; ------------------------------------------------------------------------------

; [ fade out music (slow) ]

FadeOutSongSlow:
@8d53:  lda     #$85                    ; fade out music (slow)
        sta     $1e00
        jsl     ExecSound_ext
        rts

; ------------------------------------------------------------------------------

; [ play map song ]

PlayMapSong:
@8d5d:  lda     $1704
        beq     @8d71
        lda     $1704
        tax
        lda     VehicleSongTbl,x        ; vehicle songs
        sta     $1e01
        lda     #$03
        jmp     @8d87
@8d71:  lda     $1700
        cmp     #$03
        beq     @8d7f
        tax
        lda     WorldSongTbl,x          ; world map song
        jmp     @8d82
@8d7f:  lda     $0fe2                   ; sub-map song
@8d82:  sta     $1e01
        lda     #$01                    ; play song
@8d87:  sta     $1e00
        jsl     ExecSound_ext
        rts

; ------------------------------------------------------------------------------

; world map songs
WorldSongTbl:
@8d8f:  .byte   $0d,$06,$31

; vehicle songs
VehicleSongTbl:
@8d92:  .byte   $0d,$04,$05,$0d,$18,$18,$0e

; ------------------------------------------------------------------------------

; [ play sound effect ]

PlaySfx:
@8d99:  sta     $1e01
        lda     #$80
        sta     $1e02
        lda     #$ff
        sta     $1e03
        lda     #$02
        sta     $1e00
        jsl     ExecSound_ext
        rts

; ------------------------------------------------------------------------------

; [ fade in ]

; a: fade rate (frame counter mask)

FadeIn:
@8db0:  sta     $82
        stz     $79
        stz     $80
@8db6:  jsr     WaitVblankShort
        lda     $80
        sta     $2100                   ; set screen brightness
        inc     $79
        lda     $79
        and     $82
        bne     @8db6
        inc     $80
        lda     $80
        cmp     #$10
        bne     @8db6
        dec     $80
        rts

; ------------------------------------------------------------------------------

; [ fade out ]

; A: fade rate (frame counter mask)

FadeOut:
@8dd1:  sta     $82
        stz     $79
        lda     #$0f
        sta     $80
@8dd9:  jsr     WaitVblankShort
        lda     $80
        sta     hINIDISP
        lda     $1700
        cmp     #3
        beq     @8ded                   ; branch if a sub-map
        lda     #$30                    ; enable mode 7 zoom hdma
        sta     hHDMAEN
@8ded:  inc     $79
        lda     $79
        and     $82
        bne     @8dd9
        dec     $80
        bpl     @8dd9
        stz     $80
        rts

; ------------------------------------------------------------------------------

; [ wait for key up ]

WaitKeyUp:
@8dfc:  lda     $02
        bne     @8dfc
        lda     $03
        bne     @8dfc
        rts

; ------------------------------------------------------------------------------

; [ wait for keypress ]

WaitKeyDown:
@8e05:  lda     $02
        bne     @8e0d
        lda     $03
        beq     @8e05
@8e0d:  rts

; ------------------------------------------------------------------------------

; [ transfer water/lava tile to vram ]

TfrWaterTiles:
@8e0e:  lda     $7f5800,x
        sta     $2119
        lda     $7f5801,x
        sta     $2119
        lda     $7f5802,x
        sta     $2119
        lda     $7f5803,x
        sta     $2119
        lda     $7f5804,x
        sta     $2119
        lda     $7f5805,x
        sta     $2119
        lda     $7f5806,x
        sta     $2119
        lda     $7f5807,x
        sta     $2119
        rts

; ------------------------------------------------------------------------------

; [ update water/lava animation ]

UpdateWaterLavaAnim:
@8e47:  lda     $1700
        bne     @8e4f                   ; branch if not overworld
        jmp     UpdateWaterAnim
@8e4f:  cmp     #$01
        bne     @8e56                   ; branch if not underground
        jmp     UpdateLavaAnim
@8e56:  rts

; ------------------------------------------------------------------------------

; [ transfer water/lava graphics to vram ]

TfrWaterLavaGfx:
@8e57:  lda     $1700
        bne     @8e5f                   ; branch if not overworld
        jmp     TfrWaterGfx
@8e5f:  cmp     #$01
        bne     @8e66                   ; branch if not underground
        jmp     TfrLavaGfx
@8e66:  rts

; ------------------------------------------------------------------------------

; [ transfer overworld water graphics to vram ]

TfrWaterGfx:
@8e67:  lda     #$80
        sta     $2115
        lda     $7c
        lsr
        and     #$0f
        tax
        lda     WaterShiftX,x
        tax
        sta     $2116
        lda     #$20
        sta     $2117
        jsr     TfrWaterTiles
        lda     $7c
        lsr
        and     #$0f
        tax
        lda     WaterShiftX,x
        clc
        adc     #$40
        tax
        sta     $2116
        lda     #$20
        sta     $2117
        jsr     TfrWaterTiles
        lda     #$80
        sta     $2115
        ldx     #$1e80
        stx     $2116
        stz     $420b
        stz     $4300
        lda     #$19
        sta     $4301
        ldx     #$5900
        stx     $4302
        lda     #$7f
        sta     $4304
        ldx     #$0100
        stx     $4305
        jsr     ExecDMA
        rts

; ------------------------------------------------------------------------------

; [ transfer underground lava graphics from vram ]

LoadLavaGfx:
@8ec4:  lda     #$80
        sta     $2115
        ldx     #$3800
        stx     $2116
        lda     $213a
        ldx     #$0000
@8ed5:  lda     $213a
        sta     $7f5800,x
        inx
        cpx     #$0100
        bne     @8ed5
        rts

; ------------------------------------------------------------------------------

; [ update underground lava animation ]

UpdateLavaAnim:
@8ee3:  lda     $7c
        and     #$01
        beq     @8eea
        rts
@8eea:  lda     $7c
        lsr
        and     #$0f
        tax
        lda     WaterShiftX,x
        ora     #$07
        tax
        lda     $7f5800,x
        sta     $06
        ldy     #$0007
@8eff:  lda     $7f57ff,x
        sta     $7f5800,x
        dex
        dey
        bne     @8eff
        txa
        and     #$f8
        clc
        adc     #$47
        tax
        lda     $7f5800,x
        sta     $7f57b9,x
        ldy     #$0007
@8f1d:  lda     $7f57ff,x
        sta     $7f5800,x
        dex
        dey
        bne     @8f1d
        txa
        and     #$f8
        tax
        lda     $06
        sta     $7f5800,x
        rts

; ------------------------------------------------------------------------------

; [ transfer underground lava graphics to vram ]

TfrLavaGfx:
@8f34:  lda     #$80
        sta     $2115
        lda     $7c
        lsr
        and     #$0f
        tax
        lda     WaterShiftX,x
        tax
        sta     $2116
        lda     #$38
        sta     $2117
        jsr     TfrWaterTiles
        lda     $7c
        lsr
        and     #$0f
        tax
        lda     WaterShiftX,x
        clc
        adc     #$40
        tax
        sta     $2116
        lda     #$38
        sta     $2117
        jsr     TfrWaterTiles
        inc     $7c
        rts

; ------------------------------------------------------------------------------

; [ transfer overworld water graphics from vram ]

LoadWaterGfx:
@8f69:  lda     #$80
        sta     $2115
        ldx     #$2000
        stx     $2116
        lda     $213a
        ldx     #$0000
@8f7a:  lda     $213a
        sta     $7f5800,x
        inx
        cpx     #$0100
        bne     @8f7a
        ldx     #$1e80
        stx     $2116
        lda     $213a
        ldx     #$0000
@8f93:  lda     $213a
        sta     $7f5900,x
        inx
        cpx     #$0100
        bne     @8f93
        rts

; ------------------------------------------------------------------------------

; [ update overworld water animation ]

UpdateWaterAnim:
@8fa1:  lda     $7c
        and     #$01
        beq     @8faa
        jmp     @8ff3
@8faa:  lda     $7c
        lsr
        and     #$0f
        tax
        lda     WaterShiftX,x
        ora     #$07
        tax
        lda     $7f5800,x
        sta     $06
        ldy     #$0007
@8fbf:  lda     $7f57ff,x
        sta     $7f5800,x
        dex
        dey
        bne     @8fbf
        txa
        and     #$f8
        clc
        adc     #$47
        tax
        lda     $7f5800,x
        sta     $7f57b9,x
        ldy     #$0007
@8fdd:  lda     $7f57ff,x
        sta     $7f5800,x
        dex
        dey
        bne     @8fdd
        txa
        and     #$f8
        tax
        lda     $06
        sta     $7f5800,x
@8ff3:  lda     $7c
        and     #$0f
        tax
        lda     WaterShiftY,x
        clc
        adc     #$38
        tax
        lda     $7f5900,x
        sta     $06
        ldy     #$0007
@9008:  lda     $7f58f8,x
        sta     $7f5900,x
        txa
        sec
        sbc     #$08
        tax
        dey
        bne     @9008
        lda     $7c
        and     #$0f
        tax
        lda     WaterShiftY,x
        clc
        adc     #$b8
        tax
        lda     $7f5900,x
        sta     $7f5848,x
        ldy     #$0007
@902f:  lda     $7f58f8,x
        sta     $7f5900,x
        txa
        sec
        sbc     #$08
        tax
        dey
        bne     @902f
        lda     $06
        sta     $7f5900,x
        lda     $7c
        and     #$0f
        tax
        lda     WaterShiftY,x
        clc
        adc     #$38
        tax
        lda     $7f5900,x
        sta     $06
        ldy     #$0007
@905a:  lda     $7f58f8,x
        sta     $7f5900,x
        txa
        sec
        sbc     #$08
        tax
        dey
        bne     @905a
        lda     $7c
        and     #$0f
        tax
        lda     WaterShiftY,x
        clc
        adc     #$b8
        tax
        lda     $7f5900,x
        sta     $7f5848,x
        ldy     #$0007
@9081:  lda     $7f58f8,x
        sta     $7f5900,x
        txa
        sec
        sbc     #$08
        tax
        dey
        bne     @9081
        lda     $06
        sta     $7f5900,x
        inc     $7c
        rts

; ------------------------------------------------------------------------------

; overworld water data (offset of row to shift each frame)
; 0, 9, 2, 11, 4, 13, 6, 15, 8, 1, 10, 3, 12, 5, 14, 7

WaterShiftY:
@909a:  .byte   $00,$41,$02,$43,$04,$45,$06,$47,$40,$01,$42,$03,$44,$05,$46,$07
WaterShiftX:
@90aa:  .byte   $00,$88,$10,$98,$20,$a8,$30,$b8,$80,$08,$90,$18,$a0,$28,$b0,$38

; ------------------------------------------------------------------------------

; [ calculate mode 7 rotation parameters ]

CalcMode7Rot:
@90ba:  lda     #$40                    ; zoom * cos(theta)
        jsr     CalcSine
        sty     $6e
        lda     #$00                    ; zoom * sin(theta)
        jsr     CalcSine
        sty     $70
        lda     #$80                    ; -zoom * sin(theta)
        jsr     CalcSine
        sty     $72
        rts

; ------------------------------------------------------------------------------

; [ calculate mode 7 trig function ]

CalcSine:
@90d0:  clc
        adc     $06fb                   ; rotation angle
        sta     $06
        and     #$7f
        asl
        tax
        lda     f:Mode7SineTbl,x        ; sine table
        sta     hM7A
        lda     f:Mode7SineTbl+1,x
        sta     hM7A
        lda     $ad                     ; zoom level
        sta     hM7B
        sta     hM7B
        ldy     hMPYM
        lda     $06
        bpl     @9103
        longa
        tya
        eor     #$ffff
        inc
        tay
        tdc
        xba
        shorta
@9103:  rts

; ------------------------------------------------------------------------------

; [ update mode 7 registers ]

UpdateMode7Regs:
@9104:  lda     $6e
        sta     hM7A
        lda     $6f
        sta     hM7A
        lda     $70
        sta     hM7B
        lda     $71
        sta     hM7B
        lda     $72
        sta     hM7C
        lda     $73
        sta     hM7C
        lda     $6e
        sta     hM7D
        lda     $6f
        sta     hM7D
        rts

; ------------------------------------------------------------------------------

; [ wait for vblank (w/ animations) ]

WaitVblankLong:
@912d:  lda     #1
        sta     $7d
@9131:  lda     $7d
        bne     @9131
        jsl     _15c23d
        inc     $7d
        rts

; ------------------------------------------------------------------------------

; [ wait for vblank (no animations) ]

WaitVblankShort:
@913c:  lda     #1
        sta     $7e
@9140:  lda     $7e
        bne     @9140
        jsl     _15c23d
        inc     $7d
        rts

; ------------------------------------------------------------------------------

; [ wait one frame ]

WaitFrame:
@914b:  jsr     WaitVblankShort

; overworld
        lda     $1700
        bne     @915c
        jsr     UpdateWaterAnim
        jsr     TfrWaterGfx
        jmp     @916a

; underground
@915c:  cmp     #1
        bne     @916a
        jsr     UpdateLavaAnim
        jsr     TfrLavaGfx
        jsl     UpdateLavaPal
@916a:  jsl     TfrBGAnimGfx
        jsl     UpdateWhalePal
        jsl     UpdateBabilPal
        rts

; ------------------------------------------------------------------------------

; [ reset all sprites ]

ResetSprites:
@9177:  ldx     #0
        lda     #$f0
@917c:  sta     sprite_ram+1,x
        inx4
        cpx     #$0200
        bne     @917c
        ldx     #0
@918b:  stz     sprite_ram_hi,x
        inx
        cpx     #$20
        bne     @918b
        rts

; ------------------------------------------------------------------------------

; [ reset sprites 0-63 ]

ResetSprites64:
@9195:  ldx     #0
        lda     #$f0
@919a:  sta     sprite_ram+1,x
        inx4
        cpx     #$0100
        bne     @919a
        ldx     #0
@91a9:  stz     sprite_ram_hi,x
        inx
        cpx     #$20
        bne     @91a9
        rts

; ------------------------------------------------------------------------------

; [ load world map palette ]

;  A: source bank
; +X: source address

LoadWorldPal:
@91b3:  pha
        plb
        ldy     #0
@91b8:  lda     a:$0000,x
        sta     $0cdb,y
        inx
        iny
        cpy     #$0100
        bne     @91b8
        lda     #0
        pha
        plb
        rts

; ------------------------------------------------------------------------------

; [ update screen wipe (during irq) ]

UpdateWipeIRQ:
@91ca:  lda     $7f
        bne     @91f3                   ; branch if not 1st irq

; 1st irq
        lda     $79
        asl
        tax
        lda     #$6f
        clc
        adc     f:WipeScanlineTbl+1,x
        tay
        sty     hVTIMEL
        lda     $b1
        bne     @91e6
        lda     #$0f
        jmp     @91e8
@91e6:  lda     $80
@91e8:  ldx     #3
@91eb:  dex
        bne     @91eb
        nop
        sta     hINIDISP
        rts

; 2nd irq
@91f3:  ldx     #10
@91f6:  dex
        bne     @91f6
        lda     #$80
        sta     hINIDISP
        lda     #$81
        sta     hNMITIMEN
        rts

; ------------------------------------------------------------------------------

; [ update screen wipe (during nmi) ]

UpdateWipeNMI:
@9204:  lda     $79
        asl
        tax
        lda     #$6f
        sec
        sbc     f:WipeScanlineTbl+1,x
        tay
        sty     hVTIMEL
        lda     #$80
        sec
        sbc     f:WipeScanlineTbl,x
        sta     hWH0
        lda     #$7f
        clc
        adc     f:WipeScanlineTbl,x
        sta     hWH1
        lda     $79
        lsr
        asl4
        clc
        adc     #$03
        sta     $0677
        lda     #$a1                    ; enable nmi and irq
        sta     hNMITIMEN
        lda     #$80
        sta     hINIDISP
        rts

; ------------------------------------------------------------------------------

; [ screen wipe (out) ]

WipeOut:
@923f:  lda     #$01
        sta     $d9
        lda     #$07
        sta     hTM
        lda     #$01
        sta     hTS
        stz     $7a
        stz     $79
        lda     #$81                    ; enable nmi
        sta     hNMITIMEN
        cli
@9257:  jsr     WaitVblankLong
@925a:  lda     $7f
        cmp     #$02
        bne     @925a                   ; wait for 2nd irq
        inc     $79
        lda     $79
        cmp     #$20
        bne     @9257
        rts

; ------------------------------------------------------------------------------

; [ screen wipe (in) ]

WipeIn:
@9269:  lda     #$01
        sta     $d9
        stz     $7a
        lda     #$1f
        sta     $79
        lda     #$80
        sta     hINIDISP
        lda     #$81
        sta     hNMITIMEN
        cli
@927e:  jsr     WaitVblankLong
@9281:  lda     $7f
        cmp     #$02
        bne     @9281                   ; wait for 2nd irq
        dec     $79
        bpl     @927e
        stz     $d9
        lda     $b1
        bne     @9296
        lda     #$0f
        jmp     @9298
@9296:  lda     $80
@9298:  sta     hINIDISP
        rts

; ------------------------------------------------------------------------------

; [ asl ]

; unused

UnusedAsl:
@929c:  asl
@929d:  asl
@929e:  asl
@929f:  asl
@92a0:  asl2
        rts

; ------------------------------------------------------------------------------

; [ field nmi ]

FieldNMI:
@92a3:  php
        longa
        pha
        phx
        phy
        phb
        phd
        lda     #0
        shorta
        lda     hRDNMI
        lda     hRDNMI
        stz     hMDMAEN
        stz     hHDMAEN
        ldx     #field_dp
        phx
        pld
        lda     #0
        pha
        plb
        stz     $7f
        jsl     TfrSprites
        lda     $c4
        beq     @92d7
        jsr     TfrInvertPal
        stz     $c4
        jmp     @92db
@92d7:  jsl     TfrPal
@92db:  jsl     UpdateZoomHDMA
        lda     $7e
        beq     @92e8                   ; branch if not short vblank
        stz     $7e
        jmp     @937c
@92e8:  lda     $d9
        beq     @92f2
        jsr     UpdateWipeNMI
        jmp     @937c
@92f2:  lda     $1700
        cmp     #$03
        bne     @92fc
        jmp     @932f

; world map
@92fc:  jsr     TfrWaterLavaGfx
        lda     $7a
        lsr
        bcc     @9307
        jmp     @931f
@9307:  lda     $94
        beq     @9310
        stz     $94
        jsr     TfrWorldTilemap
@9310:  jsl     UpdateWhalePal
        jsl     UpdateBabilPal
        jsl     UpdateLavaPal
        jmp     @937c
@931f:  lda     $94
        beq     @9328
        stz     $94
        jsr     TfrWorldTilemap
@9328:  jsl     LoadPlayerGfx
        jmp     @937c

; sub-map
@932f:  lda     $94
        beq     @9338
        stz     $94
        jsr     TfrBG1Tilemap
@9338:  jsl     TfrChestDoor
        jsr     TfrSecretDoor
        jsr     TfrMapTitle
        jsr     HideMapTitle
        jsr     HideDlgWindow
        jsr     TfrDlgWindow
        lda     $df
        beq     @9352
        jsr     InitDlgIRQ
@9352:  lda     $da
        beq     @9359
        jsr     InitItemWindowIRQ
@9359:  lda     $7a
        lsr
        bcc     @936e
        jmp     @9361
@9361:  jsr     TfrDlgText
        jsr     TfrItemWindow
        jsl     UpdateAnimPal
        jmp     @937c
@936e:  jsl     LoadPlayerGfx
        jsr     TfrCaveWaterGfx
        jsl     TfrBGAnimGfx
        jmp     @937c
@937c:  lda     $ca
        cmp     #$02
        bne     @938f
        inc     $80
        lda     $80
        sta     hINIDISP
        cmp     #$0f
        bne     @938f
        stz     $ca
@938f:  jsr     UpdateBG2Scroll
        lda     $c2
        beq     @93ad
        lda     $d9
        bne     @93ad
        lda     $b1
        bne     @93ad
        lda     $1704
        bne     @93ad
        lda     $7b
        and     #$0c
        asl2
        ora     #$03
        sta     $77
@93ad:  lda     $77
        sta     hMOSAIC
        stz     $10
        lda     $e3
        beq     @93c3
        lda     #$01
        sta     $10
        jsr     Rand
        and     #$01
        bne     @93e4
@93c3:  lda     $5a
        clc
        adc     $10
        sta     hBG1HOFS
        lda     $5b
        adc     #0
        sta     hBG1HOFS
        lda     $5e
        clc
        adc     $10
        sta     hBG2HOFS
        lda     $5f
        adc     #0
        sta     hBG2HOFS
        jmp     @9402
@93e4:  lda     $5a
        sec
        sbc     $10
        sta     hBG1HOFS
        lda     $5b
        sbc     #0
        sta     hBG1HOFS
        lda     $5e
        sec
        sbc     $10
        sta     hBG2HOFS
        lda     $5f
        sbc     #0
        sta     hBG2HOFS
@9402:  lda     $5c
        sta     hBG1VOFS
        lda     $5d
        sta     hBG1VOFS
        lda     $60
        sta     hBG2VOFS
        lda     $61
        sta     hBG2VOFS
        lda     $5a
        clc
        adc     #$78
        sta     $6a
        lda     $5b
        adc     #0
        sta     $6b
        lda     $5c
        clc
        adc     #$78
        sta     $6c
        lda     $5d
        adc     #0
        sta     $6d
        lda     $6a
        sta     hM7X
        lda     $6b
        sta     hM7X
        lda     $6c
        sta     hM7Y
        lda     $6d
        sta     hM7Y
        lda     $1700
        cmp     #$03
        beq     @9450                   ; branch if a sub-map
        lda     #$30                    ; enable mode 7 zoom hdma
        sta     hHDMAEN
@9450:  jsl     UpdateCtrlField_ext
        inc     $7a
        inc     $0fff
        inc     $16a3                   ; increment game time
        lda     $16a3
        cmp     #60
        bcc     @9473
        stz     $16a3
        inc     $16a4
        bne     @9473
        inc     $16a5
        bne     @9473
        inc     $16a6
@9473:  stz     $7d
        longa
        pld
        plb
        ply
        plx
        pla
        plp
        rti
.a8
.i16

; ------------------------------------------------------------------------------

; [ field irq ]

FieldIRQ:
@947e:  php
        longa
        pha
        phx
        phy
        phb
        phd
        lda     #0
        shorta
        ldx     #field_dp
        phx
        pld
        lda     #0
        pha
        plb
        lda     hTIMEUP
        lda     $d9
        beq     @94a1
        jsr     UpdateWipeIRQ
        jmp     @94b5
@94a1:  lda     $df
        beq     @94ab
        jsr     update_dlg_irq
        jmp     @94b5
@94ab:  lda     $da
        beq     @94b5
        jsr     update_item_window_irq
        jmp     @94b5
@94b5:  inc     $7f                      ; set irq flag
        longa
        pld
        plb
        ply
        plx
        pla
        plp
        rti
.a8
.i16

; ------------------------------------------------------------------------------

; [ draw world map sprites ]

DrawWorldSprites:
@94c0:  jsl     DrawPlayerWorld
        jsl     DrawChoco
        jsl     DrawBkChoco
        jsl     DrawHover
        jsl     DrawEnterprise
        jsl     DrawFalcon
        jsl     DrawWhale
        jsl     DrawShip
        lda     #$3e
        jsr     CheckEventSwitch
        cmp     #0
        beq     @94ed
        jsl     DrawTank
@94ed:  rts

; ------------------------------------------------------------------------------

; [ init character properties ]

; initializes cecil only

InitCharProp:
@94ee:  ldx     #0
        ldy     #0
@94f4:  lda     f:CharProp,x
        sta     $1000,y
        inx
        iny
        cpy     #20
        bne     @94f4
        ldy     #0
@9505:  lda     f:CharProp,x            ; crit rate, bonus, and ???
        sta     $102d,y
        inx
        iny
        cpy     #3
        bne     @9505
        ldy     #0
@9516:  lda     f:CharProp,x
        sta     $1037,y
        inx
        iny
        cpy     #9
        bne     @9516
        ldy     #0
        sty     $3d
        jsr     InitMainCharEquip
        lda     #0
        jsl     UpdateEquip_ext
        rts

; ------------------------------------------------------------------------------

; [ travel from overworld to underground ]

GoDownTunnel:
@9533:  lda     #$03
        sta     $1705                   ; face left
        lda     #$1f
        sta     $79
@953c:  jsr     WaitFrame
        lda     $79
        sta     $ad
        lda     $1704
        cmp     #$04
        bne     @9551
        dec     $b7
        lda     $b7
        jmp     @9555
@9551:  dec     $b8
        lda     $b8
@9555:  jsl     UpdateZoomPal
        jsr     ResetSprites
        jsl     DrawEnterprise
        jsl     DrawFalcon
        dec     $79
        lda     $79
        cmp     #$10
        bcs     @953c
        lda     #$1f
        sta     $79
@9570:  lda     #$1f
        sec
        sbc     $79
        tax
        lda     f:TunnelRotTbl,x
        sta     $06fb
        lda     $79
        sta     $ad
        jsr     WaitVblankShort
        stz     hHDMAEN
        jsr     CalcMode7Rot
        jsr     UpdateMode7Regs
        jsr     _00a527
        jsl     DrawEnterprise
        jsl     DrawFalcon
        dec     $79
        lda     $79
        bpl     @9570
        lda     #$71
        sta     $1706
        lda     #$10
        sta     $1707
        lda     #$01
        sta     $1700
        sta     $1701
        lda     $1704
        cmp     #$04
        bne     @95c9
        lda     #$01
        sta     $171f
        lda     $06d0
        beq     @95ce                   ; branch if not holding hovercraft
        lda     #$01
        sta     $171b
        jmp     @95ce
@95c9:  lda     #$01
        sta     $1723
@95ce:  jsr     LoadUnderground
        lda     #$10
        jsl     UpdateZoomPal
        lda     #$03
        sta     $1705                   ; face left
        lda     #$81                    ; enable nmi
        sta     hNMITIMEN
        lda     #$00
        sta     hINIDISP
        lda     #$20
        sta     $ad
        lda     #$2f
        sta     $79
@95ee:  jsr     WaitFrame
        lda     #$2f
        sec
        sbc     $79
        cmp     #$10
        bcs     @95fd
        sta     hINIDISP
@95fd:  lda     $79
        tax
        lda     $1704
        cmp     #$04
        bne     @9610
        lda     f:TunnelYTbl,x
        sta     $b7
        jmp     @9616
@9610:  lda     f:TunnelYTbl,x
        sta     $b8
@9616:  jsl     DrawEnterprise
        jsl     DrawFalcon
        dec     $79
        lda     $79
        cmp     #$ff
        bne     @95ee
        rts

; ------------------------------------------------------------------------------

; [ travel from underground to overworld ]

GoUpTunnel:
@9627:  jsr     TunnelAnim
        lda     #$30
        jsr     CheckEventSwitch
        cmp     #0
        bne     @9647
        lda     #$3d
        jsr     CheckEventSwitch
        cmp     #0
        beq     @9647
        lda     #1
        sta     $b1
        lda     #$c6
        jsr     ExecEvent
        stz     $b1
@9647:  jsr     DrillAnim
        rts

; ------------------------------------------------------------------------------

; [ animation to rise from underground ]

TunnelAnim:
@964b:  lda     #$03
        sta     $1705                   ; face left
        lda     #$00
        sta     $79
@9654:  jsr     WaitFrame
        lda     #$2f
        sec
        sbc     $79
        cmp     #$10
        bcs     @9663
        sta     hINIDISP
@9663:  lda     $79
        tax
        lda     $1704
        cmp     #$04
        bne     @9676
        lda     f:TunnelYTbl,x
        sta     $b7
        jmp     @967c
@9676:  lda     f:TunnelYTbl,x
        sta     $b8
@967c:  jsr     ResetSprites
        jsl     DrawEnterprise
        jsl     DrawFalcon
        inc     $79
        lda     $79
        cmp     #$30
        bne     @9654
        rts

; ------------------------------------------------------------------------------

; [ animation when using drill to return to the overworld ]

DrillAnim:
@9690:  lda     #$6a
        sta     $1706
        lda     #$d4
        sta     $1707
        lda     #$00
        sta     $1700
        sta     $1701
        lda     $1704
        cmp     #$04
        bne     @96b7
        stz     $171f
        lda     $06d0
        beq     @96ba                   ; branch if not holding hovercraft
        stz     $171b
        jmp     @96ba
@96b7:  stz     $1723
@96ba:  jsr     LoadOverworld
        lda     #$03
        sta     $1705                   ; face left
        lda     #$81
        sta     $4200                   ; enable nmi
        stz     $79
        lda     $1704
        cmp     #$04
        bne     @96d5
        stz     $b7
        jmp     @96d7
@96d5:  stz     $b8
@96d7:  jsr     WaitVblankShort
        stz     hHDMAEN
        lda     #$20
        sec
        sbc     $79
        tax
        lda     f:TunnelRotTbl,x
        sta     $06fb
        lda     $79
        sta     $ad
        jsr     CalcMode7Rot
        jsr     UpdateMode7Regs
        jsr     _00a527
        jsl     DrawEnterprise
        jsl     DrawFalcon
        inc     $79
        lda     $79
        cmp     #$20
        bne     @96d7
        lda     #$11
        sta     $79
        sta     $ad
@970d:  jsr     WaitFrame
        lda     $79
        sta     $ad
        lda     $1704
        cmp     #$04
        bne     @9722
        inc     $b7
        lda     $b7
        jmp     @9726
@9722:  inc     $b8
        lda     $b8
@9726:  jsl     UpdateZoomPal
        jsl     DrawEnterprise
        jsl     DrawFalcon
        inc     $79
        lda     $79
        cmp     #$21
        bne     @970d
        rts

; ------------------------------------------------------------------------------

; [ load vehicle graphics ]

LoadVehicleGfx:
@973b:  ldx     #$4200
        stx     $4c
        ldx     #$0100
        stx     $4e
        ldx     #$c680                  ; 1b/c680 (chocobo graphics)
        stx     $4a
        lda     #$1b
        sta     $49
        jsl     Tfr3bppGfx
        ldx     #$4300
        stx     $4c
        ldx     #$1d00
        stx     $4e
        ldx     #.loword(VehicleGfx)
        stx     $4a
        lda     #.bankbyte(VehicleGfx)
        sta     $49
        jsl     Tfr3bppGfx
        ldy     #0
        ldx     #0
@976f:  lda     $0d8040,x
        sta     $0e5b,y
        inx
        iny
        tya
        and     #$0f
        bne     @976f
@977d:  lda     #0
        sta     $0e5b,y
        iny
        tya
        and     #$0f
        bne     @977d
        cpy     #$0080
        bne     @976f
        jsl     _15c144
        rts

; ------------------------------------------------------------------------------

; [ load player sprite graphics (world map) ]

LoadPlayerGfxWorld:
@9792:  lda     #1                      ; enable player graphics update
        sta     $cc
        jsl     LoadPlayerGfx
        jsl     LoadPlayerPal
        jsr     LoadVehicleGfx
        rts

; ------------------------------------------------------------------------------

; [ load player sprite graphics (sub-map) ]

LoadPlayerGfxSub:
@97a2:  lda     #1                      ; enable player graphics update
        sta     $cc
        jsl     LoadPlayerGfx
        jsl     LoadPlayerPal
        jsl     _15c144
        rts

; ------------------------------------------------------------------------------

.include "trigger.asm"
.include "vehicle.asm"
.include "move.asm"
.include "window.asm"
.include "npc.asm"
.include "special.asm"
.include "event.asm"

; ------------------------------------------------------------------------------

; [ init mode 7 hdma zoom data ]

InitZoomHDMA:

; airship
@f432:  lda     #0
        sta     hBGMODE
        ldx     #0
        stx     $3d
        stx     $40
        stx     $43
@f440:  phx
        ldx     $3d                     ; current scanline
        lda     f:AirshipZoomTbl,x
        inx
        stx     $3d
        plx
        sta     hM7A
        stz     hM7A
        lda     $40                     ; zoom multiplier
        sta     hM7B
        sta     hM7B
        longa
        lda     hMPYM
        asl3
        clc
        adc     #$0100
        sta     $7f0000,x
        lda     #0
        shorta
        inx2                            ; next scanline
        ldy     $3d
        cpy     #$00f0
        bne     @f440
        jsr     IncZoomMult
        lda     $40                     ; next zoom level
        cmp     #$80
        bne     @f440
@f480:  phx
        ldx     $3d
        lda     f:AirshipZoomTbl,x
        inx
        stx     $3d
        plx
        stz     $06
        asl
        rol     $06
        asl
        rol     $06
        sta     $7f0000,x
        lda     $06
        inc
        sta     $7f0001,x
        inx2                            ; next scanline
        ldy     $3d
        cpy     #$00f0
        bne     @f480

; big whale
        ldx     #0
        stx     $3d
        stx     $40
        stx     $43
@f4b0:  phx
        ldx     $3d
        lda     f:WhaleZoomTbl,x
        inx
        stx     $3d
        plx
        sta     hM7A
        stz     hM7A
        lda     $40
        sta     hM7B
        sta     hM7B
        longa
        lda     hMPYM
        asl3
        clc
        adc     #$0100
        sta     $7f2200,x
        lda     #0
        shorta
        inx2
        ldy     $3d
        cpy     #$00f0
        bne     @f4b0
        jsr     IncZoomMult
        lda     $40
        cmp     #$80
        bne     @f4b0
@f4f0:  phx
        ldx     $3d
        lda     f:WhaleZoomTbl,x
        inx
        stx     $3d
        plx
        stz     $06
        asl
        rol     $06
        asl
        rol     $06
        sta     $7f2200,x
        lda     $06
        inc
        sta     $7f2201,x
        inx2
        ldy     $3d
        cpy     #$00f0
        bne     @f4f0
        rts

; ------------------------------------------------------------------------------

; [ increment zoom multiplier ]

IncZoomMult:
@f518:  ldy     #0
        sty     $3d
        lda     $40
        clc
        adc     #8
        sta     $40
        sta     $44
        stz     $43
        lsr     $44
        ror     $43
        lsr     $44
        ror     $43
        ldx     $43
        rts

; ------------------------------------------------------------------------------

.include "tilemap.asm"

; ------------------------------------------------------------------------------

.segment "field_code2"

.include "bg_gfx.asm"
.include "sprite.asm"

; ------------------------------------------------------------------------------

; [ update mode 7 zoom hdma table ]

UpdateZoomHDMA:
@c163:  lda     $1700
        cmp     #3
        bne     @c16b                   ; return if not on a world map
        rtl
@c16b:  stz     hM7B                    ; clear off-diagonal matrix elements
        stz     hM7B
        stz     hM7C
        stz     hM7C
        lda     #$f0                    ; 224 scanlines total
        sta     $7f5a00
        sta     $7f5a03
        lda     $1704
        cmp     #$06
        beq     @c1a8                   ; branch if in big whale

; not big whale
        lda     $ad
        sec
        sbc     #$10
        asl
        clc
        adc     #$00
        sta     $7f5a02
        sta     $7f5a05
        lda     #$00
        sta     $7f5a01
        lda     #$e0
        sta     $7f5a04
        jmp     @c1c6

; big whale
@c1a8:  lda     $ad
        sec
        sbc     #$10
        and     #$fe
        clc
        adc     #$22
        sta     $7f5a02
        sta     $7f5a05
        lda     #$00
        sta     $7f5a01
        lda     #$e0
        sta     $7f5a04
@c1c6:  lda     #$80                    ; hdma terminator
        sta     $7f5a06
        stz     hHDMAEN
        lda     #$42
        sta     $4340
        sta     $4350
        lda     #<hM7A                  ; $211b (top left matrix element)
        sta     $4341
        lda     #<hM7D                  ; $211e (bottom right matrix element)
        sta     $4351
        ldx     #$5a00                  ; both hdma channels use the same data
        stx     $4342
        stx     $4352
        lda     #$7f
        sta     $4344
        sta     $4354
        sta     $4347
        sta     $4357
        rtl

; ------------------------------------------------------------------------------

; [ load map palette ]

LoadMapPal:
@c1f9:  lda   $0fe0
        sta   $19
        stz   $18
        lsr   $19
        ror   $18
        ldx   $18
        ldy   #$0020
@c209:  lda   f:MapPal+$10,x
        sta   $0cdb,y
        lda   f:MapPal+$90,x
        sta   $0ceb,y
        inx
        iny
        tya
        and   #$0f
        bne   @c209
        tya
        clc
        adc   #$10
        tay
        bne   @c209
        rtl

; ------------------------------------------------------------------------------

; [ load text window palette ]

LoadWindowPal:
@c226:  ldx     #0
@c229:  lda     f:WindowPal,x           ; window palette
        sta     $0cdb,x
        inx
        cpx     #$0020
        bne     @c229
        ldx     $16aa
        stx     $0cdd
        rtl

; ------------------------------------------------------------------------------

; [ no effect ]

_15c23d:
.if DEBUG
        jsl     DrawPos
.endif
@c23d:  rtl

; ------------------------------------------------------------------------------

; [ load initial spell lists ]

InitSpellLists:
@c23e:  ldx     #0
        ldy     #0
        stz     $07
@c246:  lda     f:SpellListInit,x
        cmp     #$ff
        beq     @c25f
        sta     $1560,y
        iny
        inc     $07
        lda     $07
        cmp     #$18
        bne     @c26f
        stz     $07
        jmp     @c26f
@c25f:  lda     #$00
        sta     $1560,y
        iny
        inc     $07
        lda     $07
        cmp     #$18
        bne     @c25f
        stz     $07
@c26f:  inx
        cpy     #$0138
        bne     @c246
        rtl

; ------------------------------------------------------------------------------

; [ draw player's current position ]

; debug code, unused but works in the english translation

DrawPos:

.if LANG_EN .or DEBUG
    @PosX := $1706
    @PosY := $1707
    @MapID := $1702
.else
    @PosX := $86
    @PosY := $87
    @MapID := $88
.endif

@c276:  lda     #$80
        sta     $2115
        ldx     #$2882
        stx     $2116
        lda     @PosX
        lsr4
        cmp     #10
        bcc     @c291
        clc
        adc     #$38
        jmp     @c293
@c291:  ora     #$80
@c293:  sta     $2118
        lda     #$20
        sta     $2119
        lda     @PosX
        and     #$0f
        cmp     #10
        bcc     @c2a9
        clc
        adc     #$38
        jmp     @c2ab
@c2a9:  ora     #$80
@c2ab:  sta     $2118
        lda     #$20
        sta     $2119
        stz     $2118
        stz     $2119
        lda     @PosY
        lsr4
        cmp     #10
        bcc     @c2c9
        clc
        adc     #$38
        jmp     @c2cb
@c2c9:  ora     #$80
@c2cb:  sta     $2118
        lda     #$20
        sta     $2119
        lda     @PosY
        and     #$0f
        cmp     #10
        bcc     @c2e1
        clc
        adc     #$38
        jmp     @c2e3
@c2e1:  ora     #$80
@c2e3:  sta     $2118
        lda     #$20
        sta     $2119
        ldx     #$28c2
        stx     $2116
        lda     @MapID
        lsr4
        cmp     #10
        bcc     @c301
        clc
        adc     #$38
        jmp     @c303
@c301:  ora     #$80
@c303:  sta     $2118
        lda     #$20
        sta     $2119
        lda     @MapID
        and     #$0f
        cmp     #10
        bcc     @c319
        clc
        adc     #$38
        jmp     @c31b
@c319:  ora     #$80
@c31b:  sta     $2118
        lda     #$20
        sta     $2119
        rtl

; ------------------------------------------------------------------------------

; [ convert hex to decimal ]

HexToDec:
@c324:  phx
        phy
        ldx     #0
@c329:  ldy     #$0080
        stz     $33
@c32e:  longa
        lda     $30
        sec
        sbc     f:Pow10Lo,x
        sta     $30
        lda     $32
        sbc     f:Pow10Hi,x
        sta     $32
        bcc     @c347
        iny
        jmp     @c32e
@c347:  lda     $30
        clc
        adc     f:Pow10Lo,x
        sta     $30
        lda     $32
        adc     f:Pow10Hi,x
        sta     $32
        lda     #0
        shorta
        phx
        txa
        lsr
        tax
        tya
        sta     $34,x
        plx
        inx2
        cpx     #16
        bne     @c329
        ply
        plx
        rtl

; ------------------------------------------------------------------------------

; powers of 10 (lo word)
Pow10Lo:
@c36f:  .word   $9680,$4240,$86a0,$2710,$03e8,$0064,$000a,$0001

; powers of 10 (hi word)
Pow10Hi:
@c37f:  .word   $0098,$000f,$0001,$0000,$0000,$0000,$0000,$0000

; ------------------------------------------------------------------------------

; [ multiply (16-bit) ]

; ++$30 = +$18 * +$1a

Mult16:
@c38f:  stz     $1c
        stz     $30
        stz     $31
        stz     $32
        ldy     #16
@c39a:  lsr     $19
        ror     $18
        bcc     @c3b3
        lda     $30
        clc
        adc     $1a
        sta     $30
        lda     $31
        adc     $1b
        sta     $31
        lda     $32
        adc     $1c
        sta     $32
@c3b3:  asl     $1a
        rol     $1b
        rol     $1c
        dey
        bne     @c39a
        rtl

; ------------------------------------------------------------------------------

.include "pal_anim.asm"

; ------------------------------------------------------------------------------

; [ modify overworld tilemap ]

; modifies tiles in a row based on event switches

ModOverworldTilemap:
@c6f4:  lda     $93
        and     #$3f
        sta     $3e
        stz     $3d
        ldx     $3d
        lda     $1282                   ; check event switch $0c
        and     #$10
        beq     @c727
        lda     $93
        cmp     #$39                    ; destroyed damcyan (118,57)
        bne     @c717
        lda     #$2d
        sta     $7f5ce7,x
        inc
        sta     $7f5ce8,x
        rtl
@c717:  cmp     #$3a
        bne     @c727
        lda     #$3d
        sta     $7f5ce7,x
        inc
        sta     $7f5ce8,x
        rtl
@c727:  lda     $1281                   ; check event switch $0e
        and     #$40
        beq     @c785
        lda     $93
        cmp     #$76                    ; mist mountains (97,118)
        bne     @c74b
        lda     #$13
        sta     $7f5cd2,x
        sta     $7f5cd3,x
        sta     $7f5cd4,x
        sta     $7f5cd5,x
        sta     $7f5cd6,x
        rtl
@c74b:  cmp     #$77
        bne     @c76a
        lda     #$12
        sta     $7f5cd2,x
        lda     #$13
        sta     $7f5cd3,x
        sta     $7f5cd4,x
        sta     $7f5cd5,x
        lda     #$14
        sta     $7f5cd6,x
        rtl
@c76a:  cmp     #$78
        bne     @c785
        lda     #$13
        sta     $7f5cd2,x
        sta     $7f5cd3,x
        sta     $7f5cd4,x
        sta     $7f5cd5,x
        sta     $7f5cd6,x
        rtl
@c785:  lda     $1286                   ; check event switch $30
        and     #$01
        bne     @c7e4
        lda     $93
        cmp     #$d2                    ; agart hole to underground (106,210)
        bne     @c799
        lda     #$13
        sta     $7f5cdb,x
        rtl
@c799:  cmp     #$d3
        bne     @c7ac
        lda     #$13
        sta     $7f5cda,x
        sta     $7f5cdb,x
        sta     $7f5cdc,x
        rtl
@c7ac:  cmp     #$d4
        bne     @c7c7
        lda     #$13
        sta     $7f5cd9,x
        sta     $7f5cda,x
        sta     $7f5cdb,x
        sta     $7f5cdc,x
        sta     $7f5cdd,x
        rtl
@c7c7:  cmp     #$d5
        bne     @c7da
        lda     #$13
        sta     $7f5cda,x
        sta     $7f5cdb,x
        sta     $7f5cdc,x
        rtl
@c7da:  cmp     #$d6
        bne     @c7e4
        lda     #$13
        sta     $7f5cdb,x
@c7e4:  rtl

; ------------------------------------------------------------------------------

; [ transfer chest/door tilemap to vram ]

TfrChestDoor:
@c7e5:  lda     $d4
        bne     @c7ea
        rtl
@c7ea:  stz     $d4
        lda     #$80
        sta     $2115
        ldx     $06fe
        stx     $2116
        ldx     $0700
        stx     $2118
        ldx     $0702
        stx     $2118
        lda     $06fe
        clc
        adc     #$20
        sta     $06fe
        lda     $06ff
        adc     #$00
        sta     $06ff
        ldx     $06fe
        stx     $2116
        ldx     $0704
        stx     $2118
        ldx     $0706
        stx     $2118
        rtl

; ------------------------------------------------------------------------------

.include "player.asm"
.include "hardware.asm"
.include "bg_anim.asm"

; ------------------------------------------------------------------------------
