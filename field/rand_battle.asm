
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: rand_battle.asm                                                      |
; |                                                                            |
; | description: random battle routines                                        |
; |                                                                            |
; | created: 5/11/2022                                                         |
; +----------------------------------------------------------------------------+

.pushseg

.segment "rand_battle"

; 0e/c300
OverworldBattleRate:
        .byte   10,10,10, 8, 8,10,10,10
        .byte   10,10,10, 8, 8,10,10,10
        .byte   10,10,10, 8, 8,10,10,10
        .byte   10,10, 7, 8, 8, 8,10,10
        .byte    8, 8, 7, 7, 8, 8,10,10
        .byte    8, 8, 7, 7, 8,10,10,10
        .byte    8, 8, 8, 8, 8,10,10,10
        .byte    8, 8, 8, 8, 8,10,10,10

; 0e/c340
UndergroundBattleRate:
        .byte   8

; 0e/c341
MoonBattleRate:
        .byte   8

; 0e/c342
        .include "data/sub_battle_rate.asm"

; 0e/c542
OverworldBattleGrp:
        .byte   5,5,5,2,2,3,3,3,5,5,5,2,2,3,3,3
        .byte   5,5,1,1,1,3,3,3,5,5,1,1,1,1,3,3
        .byte   5,5,0,0,1,1,5,3,6,6,0,0,4,4,4,4
        .byte   6,6,6,6,4,4,4,4,6,6,6,6,4,4,4,4

; 0e/c582
UndergroundBattleGrp:
        .byte   8,7,7,7
        .byte   10,7,7,7
        .byte   8,7,7,7
        .byte   8,8,8,8

; 0e/c592
MoonBattleGrp:
        .byte   9,9
        .byte   9,9

; 0e/c596
        .include "data/sub_battle_grp.asm"

; 0e/c796
        .include "data/world_battles.asm"

; 0e/c816
        .include "data/sub_battles.asm"

.popseg

; ------------------------------------------------------------------------------

; [ check random battle ]

CheckBattle:
@8b3c:  lda     $1704
        bne     @8b56
        lda     $a2
        and     #$40
        beq     @8b56
        lda     $c0
        bne     @8b6b
        lda     $ab
        beq     @8b56
        lda     $d5
        beq     @8b56       ; branch if player control is disabled
        jmp     @8b6b
@8b56:  lda     $c0
        beq     @8b6a
        stz     $c0
        lda     #$02
        sta     $1e00
        lda     #$01        ; play sound effect $01
        sta     $1e01
        jsl     ExecSound_ext
@8b6a:  rts
@8b6b:  inc     $88
        inc     $86
        bne     @8b7a
        lda     $17ef
        clc
        adc     #$11
        sta     $17ef
@8b7a:  lda     $1700
        cmp     #$00
        bne     @8bbb
; overworld
        lda     $1707
        lsr2
        and     #$f8
        sta     $06
        lda     $1706
        lsr5
        clc
        adc     $06
        tax
        lda     f:OverworldBattleRate,x
        sta     $06
        phx
        ply
        lda     $c0
        bne     @8bb2
        lda     $86
        tax
        lda     f:RNGTbl,x   ; rng table
        clc
        adc     $17ef
        cmp     $06
        bcc     @8bb2
        rts
@8bb2:  phy
        plx
        lda     f:OverworldBattleGrp,x
        jmp     @8c29
; underground
@8bbb:  cmp     #$01
        bne     @8bf2
        lda     $c0
        bne     @8bd5
        lda     $86
        tax
        lda     f:RNGTbl,x   ; rng table
        clc
        adc     $17ef
        cmp     f:UndergroundBattleRate
        bcc     @8bd5
        rts
@8bd5:  lda     $1707
        lsr3
        and     #$fc
        sta     $06
        lda     $1706
        lsr5
        clc
        adc     $06
        tax
        lda     f:UndergroundBattleGrp,x
        jmp     @8c29
; moon
@8bf2:  cmp     #$02
        bne     @8c53
        lda     $c0
        bne     @8c0c
        lda     $86
        tax
        lda     f:RNGTbl,x   ; rng table
        clc
        adc     $17ef
        cmp     f:MoonBattleRate
        bcc     @8c0c
        rts
@8c0c:  stz     $06
        lda     $1707
        cmp     #$20
        bcc     @8c19
        lda     #$02
        sta     $06
@8c19:  lda     $1706
        cmp     #$20
        bcc     @8c22
        inc     $06
@8c22:  lda     $06
        tax
        lda     f:MoonBattleGrp,x
@8c29:  jsr     ChooseRandBattle
        stz     $3e
        ldx     $3d
        lda     f:WorldBattles,x
        sta     $1800
        lda     $1701
        beq     @8c3e
        lda     #$01
@8c3e:  sta     $1801
        lda     $a2
        and     #$07
        tay
        lda     WorldBattleBGTbl,y     ; world map battle backgrounds
        sta     $1802
        stz     $c0
        lda     #$01        ; enable battle
        sta     $85
        rts
; sub-map
@8c53:  lda     $1702
        sta     $3d
        lda     $1701
        beq     @8c5f
        lda     #$01
@8c5f:  sta     $3e
        ldx     $3d
        lda     f:SubBattleRate,x
        beq     @8c7e
        sta     $06
        lda     $c0
        bne     @8c91
        lda     $86
        tax
        lda     f:RNGTbl,x   ; rng table
        clc
        adc     $17ef
        cmp     $06
        bcc     @8c91
@8c7e:  lda     $c0
        beq     @8c90
        stz     $c0
        lda     #$02        ; play sound effect $00
        sta     $1e00
        stz     $1e01
        jsl     ExecSound_ext
@8c90:  rts
@8c91:  ldx     $3d
        lda     $0ec596,x
        jsr     ChooseRandBattle
        ldx     $3d
        lda     f:SubBattles,x
        sta     $1800
        jsr     UpdateBattleParams
        stz     $c0
        lda     #$01        ; enable battle
        sta     $85
        stz     $88
        rts

; ------------------------------------------------------------------------------

; world map battle backgrounds
WorldBattleBGTbl:
@8caf:  .byte   $00,$0a,$01,$09,$0f,$05

; ------------------------------------------------------------------------------

; [ update battle parameters ]

UpdateBattleParams:
@8cb5:  lda     $1701
        beq     @8cbc
        lda     #$01        ; set msb of battle id
@8cbc:  sta     $1801
        jsr     GetBattleBG
        lda     #$e1
        jsr     CheckEventSwitch
        cmp     #$00
        bne     @8cd3
        lda     $1802       ; disable magnetization
        and     #$7f
        sta     $1802
@8cd3:  rts

; ------------------------------------------------------------------------------

; [ get battle bg (sub-map) ]

GetBattleBG:
@8cd4:  lda     $a2         ; use cave w/ water battle bg
        and     #$20
        asl
        sta     $06
        lda     $0fdb       ; use alternate battle bg palette
        and     #$40
        lsr
        ora     $06
        sta     $06
        lda     $0fdb       ; battle bg id and magnetization flag
        and     #$8f
        ora     $06
        sta     $1802
        rts

; ------------------------------------------------------------------------------

; [ choose random battle ]

; battle probabilities
;   0: 43/256 (16.8%)
;   1: 43/256 (16.8%)
;   2: 43/256 (16.8%)
;   3: 43/256 (16.8%)
;   4: 32/256 (12.5%)
;   5: 32/256 (12.5%)
;   6: 16/256 (6.25%)
;   7: 4/256  (1.56%)

ChooseRandBattle:
@8cf0:  sta     $3d
        stz     $3e
        asl     $3d
        rol     $3e
        asl     $3d
        rol     $3e
        asl     $3d
        rol     $3e
        lda     $c0
        bne     @8d1f
        lda     $87
        tax
        lda     f:RNGTbl,x   ; rng table
        clc
        adc     $17ee
        inc     $87
        bne     @8d21
        lda     $17ee
        clc
        adc     #$11
        sta     $17ee
        jmp     @8d21
@8d1f:  lda     #$ff
@8d21:  ldx     $3d
        cmp     #$2b
        bcc     @8d46
        inx
        cmp     #$56
        bcc     @8d46
        inx
        cmp     #$81
        bcc     @8d46
        inx
        cmp     #$ac
        bcc     @8d46
        inx
        cmp     #$cc
        bcc     @8d46
        inx
        cmp     #$ec
        bcc     @8d46
        inx
        cmp     #$fc
        bcc     @8d46
        inx
@8d46:  stx     $3d
        rts
