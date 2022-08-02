
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: magic.asm                                                            |
; |                                                                            |
; | description: magic animation routines                                      |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

; [  ]

_02e9f3:
@e9f3:  pha
        lda     #$20
        sta     $28
        pla
        jsr     CalcSine
        sta     $04
        asl     $2b
        rol     $05
        lda     $05
        and     #$01
        sta     $05
        ldy     #$0018
        sty     $00
        lda     $02
        longa
        asl2
        tay
        lda     $04
@ea16:  sta     $7612,y
        iny4
        dec     $00
        bne     @ea16
        shorta0
        lda     $02
        clc
        adc     #$18
        sta     $02
        rtl

; ------------------------------------------------------------------------------

; sound effects for pre-magic animations
PreMagicSfxTbl:
@ea2c:  .byte   $fc,$fd,$fe

; ------------------------------------------------------------------------------

; [ pre-magic animation (init and black magic) ]

; A: pre-magic animation id
;      0: black magic
;      1: white magic (also sing and brace)
;      2: summon magic

PreMagicAnim1:
@ea2f:  pha
        tax
        lda     f:PreMagicSfxTbl,x
        sta     $f47f
        pla
        pha
        lda     $48
        asl4
        tax
@ea41:  lda     $efc5,x
        cmp     #$c0
        bne     @ea41
        pla
        stz     $f2a0
        pha
        jsr     LoadPreMagicGfx
        pla
        pha
        clc
        adc     #$06
        ldx     #$000f
        sta     $f457
        jsr     LoadAnimPal
        stz     $00
        jsr     GetAttackerMask
        stz     $02
        pla
        sta     $04
        lda     $38e2                   ; save magic damage flag
        pha
        stz     $38e2
        lda     $34c2
        sta     $f485
        lda     $04
        jsr     ExecAnimScript
        pla
        sta     $38e2
        jsr     ResetAnimSpritesLarge
        rts

; ------------------------------------------------------------------------------

; [ load summon graphics ]

LoadSummonGfx:
@ea82:  pha
        sec
        sbc     #$4d
        pha
        pha
        tax
        lda     f:SummonPalTbl,x
        ldx     #$000c
        jsr     LoadMonsterPal
        pla
        asl
        tax
        longa
        lda     #128                    ; load 128 tiles
        sta     $00
        lda     f:SummonGfxPtrs,x
        tay
        ldx     #$dbe6
        shorta0
        lda     #^SummonGfxPtrs
        jsr     Load3bppGfx
        pla
        asl
        tax
        longa
        lda     f:SummonTilemapPtrs,x
        tax
        shorta0
        lda     #^SummonTilemapPtrs
        jsr     TfrSummonGfx
        pla
        rts

; ------------------------------------------------------------------------------

; [ do magic animation ]

DoMagicAnim:
@eac1:  stz     $f2d0
        lda     ($3f)
        bne     DoItemMagicAnim
        rts

DoItemMagicAnim:
@eac9:  sta     $f49a
        sta     $f47f
        dec     $f47f
        stz     $f451
        stz     $f285
        cmp     #$4d                    ; check if it's a summon
        bcc     @eafe
        cmp     #$5e
        bcs     @eafe

; summon attack
        pha
        jsr     LoadSummonGfx
        jsl     InitSummonSprite
        lda     #1
        sta     $f320                   ; hide character sprites
        jsl     _03f825
        jsr     DarkenBattleBG
        lda     $34c5
        bne     @eafd                   ; branch if there are valid targets
        pla
        jmp     AfterMagicAnim
@eafd:  pla
@eafe:  dec
        longa
        asl2
        tax
        shorta0
        lda     f:AnimProp,x
        phx
        ldx     #$000f
        sta     $f457
        jsr     LoadAnimPal
        plx
        lda     f:AnimProp+1,x
        phx
        jsr     LoadMagicGfx
        lda     $34c4
        sta     $f485
        plx
        lda     f:AnimProp+2,x
        cmp     #$ff
        beq     @eb51
        sta     $f397
        lda     #1
        sta     $f266
        sta     $f267
        lda     f:AnimProp+3,x
        cmp     #$ff
        beq     @eb51
        asl
        tax
        lda     f:MagicAnimTbl,x   ; magic animation jump table
        sta     $00
        lda     f:MagicAnimTbl+1,x
        sta     $01
        jsr     @eb57
@eb51:  stz     $f2d0
        jmp     ResetAnimSpritesLarge

@eb57:  stz     $f42b
        jmp     ($0000)

; ------------------------------------------------------------------------------

; [ do magic animation (far) ]

DoMagicAnim_far:
@eb5d:  cmp     #$ff
        beq     @eb72
        asl
        tax
        lda     f:MagicAnimTbl,x
        sta     $00
        lda     f:MagicAnimTbl+1,x
        sta     $01
        jsr     @eb73
@eb72:  rtl

@eb73:  stz     $f42b
        jmp     ($0000)

; ------------------------------------------------------------------------------

; magic animation jump table
MagicAnimTbl:
@eb79:  .addr   MagicAnim_00
        .addr   MagicAnim_01
        .addr   MagicAnim_02
        .addr   MagicAnim_03
        .addr   MagicAnim_04
        .addr   MagicAnim_05
        .addr   MagicAnim_06
        .addr   MagicAnim_07
        .addr   MagicAnim_08
        .addr   MagicAnim_09
        .addr   MagicAnim_0a
        .addr   MagicAnim_0b
        .addr   MagicAnim_0c
        .addr   MagicAnim_0d
        .addr   MagicAnim_0e
        .addr   MagicAnim_0f
        .addr   MagicAnim_10
        .addr   MagicAnim_11
        .addr   MagicAnim_12
        .addr   MagicAnim_13
        .addr   MagicAnim_14
        .addr   MagicAnim_15
        .addr   MagicAnim_16
        .addr   MagicAnim_17
        .addr   MagicAnim_18
        .addr   MagicAnim_19
        .addr   MagicAnim_1a
        .addr   MagicAnim_1b
        .addr   MagicAnim_1c
        .addr   MagicAnim_1d
        .addr   MagicAnim_1e
        .addr   MagicAnim_1f
        .addr   MagicAnim_20
        .addr   MagicAnim_21
        .addr   MagicAnim_22
        .addr   MagicAnim_23
        .addr   MagicAnim_24
        .addr   MagicAnim_25
        .addr   MagicAnim_26
        .addr   MagicAnim_27
        .addr   MagicAnim_28
        .addr   MagicAnim_29
        .addr   MagicAnim_2a
        .addr   MagicAnim_2b
        .addr   MagicAnim_2c
        .addr   MagicAnim_2d
        .addr   MagicAnim_2e
        .addr   MagicAnim_2f

; ------------------------------------------------------------------------------

; [ magic animation $2f: black hole ]

MagicAnim_2f:
@ebd9:  jsr     PlayMagicSfx
        jsr     DarkenBattleBG
        jsl     FlashScreenWhite
        ldx     #32
        jsr     WaitX
        stz     $ef87
        jmp     LightenBattleBG

; ------------------------------------------------------------------------------

; [ magic animation $2e: bomb's soul item ]

MagicAnim_2e:
@ebef:  jsr     SelfTargetMagicAnim
        jmp     MagicAnim_1c

; ------------------------------------------------------------------------------

; [ magic animation $27: big bang ]

MagicAnim_27:
@ebf5:  lda     #$07
        sta     $f2d0
        jsl     BigBang
        rts

; ------------------------------------------------------------------------------

; [ $2a: glance ]

MagicAnim_2a:
@ebff:  jsr     PlayMagicSfx
        jsl     FlashScreenBlue
        jmp     _ec24

; ------------------------------------------------------------------------------

; [ magic animation $2b: crush ]

MagicAnim_2b:
@ec09:  jsr     PlayMagicSfx
        jsl     FlashScreenRed
        jmp     _ec24

; ------------------------------------------------------------------------------

; [ magic animation $2c:  ]

MagicAnim_2c:
@ec13:  jsr     PlayMagicSfx
        jsl     FlashScreenYellow
        jmp     _ec24

; ------------------------------------------------------------------------------

; [ $2d: gaze, slap ]

MagicAnim_2d:
@ec1d:  jsr     PlayMagicSfx
        jsl     FlashScreenWhite
_ec24:  ldx     #16
        jsr     WaitX
        stz     $ef87
        jmp     MagicAnim_00

; ------------------------------------------------------------------------------

; [  ]

_02ec30:
@ec30:  jsr     InitPolarAngle
        lda     #$18
        jsr     SetPolarRadius
        ldx     #$0004
@ec3b:  lda     #$80
        jsr     IncPolarAngle
        inx
        cpx     #8
        bne     @ec3b
        jsr     _02f2f3
        lda     #$04
        sta     $f2a0
        rts

; ------------------------------------------------------------------------------

; [ magic animation $29: cure 4 ]

MagicAnim_29:
@ec4f:  jsr     _02ec30
        jsr     MagicAnim_1c
        jsr     _02ec30
        jmp     ReflectMagicAnim

; ------------------------------------------------------------------------------

; [ pre-holy animation (near) ]

PreHolyAnim_near:
@ec5b:  lda     #$0a                    ; play sound effect $0a
        sta     $f47f
        jsl     PreHolyAnim
        lda     #$ff
        sta     $f47f
        rts

; ------------------------------------------------------------------------------

; [ magic animation $25: holy (white) ]

MagicAnim_25:
@ec6a:  jsr     _02f2f3
        inc     $f2a0
        lda     $34c4
        sta     $f462
        lda     $34c5
        ora     $3522
        sta     $f463
        jsr     PreHolyAnim_near
        jsr     MagicAnim_1c
        lda     $3522
        beq     @ec9e
        lda     $34c4
        eor     #$80
        sta     $f462
        lda     $3523
        sta     $f463
        jsr     PreHolyAnim_near
        jsr     ReflectMagicAnim
@ec9e:  rts

; ------------------------------------------------------------------------------

; [ magic animation $24: no effect ]

MagicAnim_24:
@ec9f:  jsl     _01fcb5
        rts

; ------------------------------------------------------------------------------

; [ attack animation $26: odin attack ]

MagicAnim_26:
@eca4:  jsr     _02c46d
        jsl     _01fcb6
        rts

; ------------------------------------------------------------------------------

; [ magic animation $28: fission ]

MagicAnim_28:
@ecac:  ldx     $34c4
        phx
        lda     $34c2
        sta     $34c4
        lda     $34c3
        tax
        lda     f:BitOrTbl,x
        sta     $34c5
        jsr     MagicAnim_00
        plx
        stx     $34c4
        rts

; ------------------------------------------------------------------------------

; [ magic animation $23: fire 3 ]

MagicAnim_23:
@ecc9:  jsr     _02f2f3
        lda     #$03
        sta     $f2a0
        lda     #$0f
        sta     $04
        jsl     _01e826
        stz     $f458
        lda     #$01
        jsr     MagicAnim_1c
        lda     $34c4
        sta     $f13e
        lda     $34c5
        beq     @ecf0
        jsl     FiragaAnim
@ecf0:  stz     $f458
        lda     $34c4
        eor     #$80
        sta     $f13e
        jsr     ReflectMagicAnim
        lda     $3523
        beq     @ed07
        jsl     FiragaAnim
@ed07:  rts

; ------------------------------------------------------------------------------

; [ magic animation $22: big wave, wave ]

MagicAnim_22:
@ed08:  jsl     _01fd22
        rts

; ------------------------------------------------------------------------------

; [  ]

_02ed0d:
@ed0d:  pha
        lda     $34c4
        and     #$80
        sta     $f279
        lda     $34c5
        sta     $f27a
        sta     $f281
        sta     $f284
        jsr     _02f4f8
        jsr     EnableTargetPalEffect
        lda     #$03
        sta     $f281
        pla
        jsr     _02f524
        inc     $f42e
        rts

; ------------------------------------------------------------------------------

; [  ]

_02ed35:
@ed35:  lda     #$00
        jsr     _02ed0d
        jsr     PlayMagicSfx
        jsl     _01f59a
        lda     #$ff
        sta     $f47f
        rts

; ------------------------------------------------------------------------------

; [ magic animation $21: nuke ]

MagicAnim_21:
@ed47:  lda     $34c5
        beq     @ed56
        jsr     _02ed35
        jsr     MagicAnim_02
        stz     $f42e
        rts
@ed56:  lda     $3522
        beq     @ed73
        jsr     MagicAnim_1c
        jsr     _02ed74
        jsr     _02ed35
        jsr     _02f2f3
        inc     $f2a0
        jsr     _02ed92
        jsr     ReflectMagicAnim
        stz     $f42e
@ed73:  rts

; ------------------------------------------------------------------------------

; [  ]

_02ed74:
@ed74:  ldx     $34c4
        stx     $f42f
        lda     $34c4
        eor     #$80
        sta     $34c4
        lda     a:$0049
        sta     $f431
        jsr     _02edce
        lda     $3523
        sta     $34c5
        rts

; ------------------------------------------------------------------------------

; [  ]

_02ed92:
@ed92:  lda     $f431
        sta     a:$0049
        ldx     $f42f
        stx     $34c4
        rts

; ------------------------------------------------------------------------------

; [ magic animation $20: warp, demolish, disrupt ]

MagicAnim_20:
@ed9f:  lda     $34c5
        beq     @eda9
        jsl     _01f3b9
        rts
@eda9:  lda     $3522
        beq     @edcd
        jsr     MagicAnim_1c
        lda     $34c4
        pha
        eor     #$80
        sta     $34c4
        lda     a:$0049
        pha
        jsr     _02edce
        jsl     _01f3b9
        pla
        sta     a:$0049
        pla
        sta     $34c4
@edcd:  rts

; ------------------------------------------------------------------------------

; [  ]

_02edce:
@edce:  ldx     #0
@edd1:  lda     f:BitOrTbl,x
        cmp     $3523
        beq     @ede3
        inx
        cpx     #8
        bne     @edd1
        ldx     #0
@ede3:  txa
        sta     a:$0049
        rts

; ------------------------------------------------------------------------------

; [ show animation with attacker as target ]

SelfTargetMagicAnim:
@ede8:  lda     $34c2
        and     #$80
        sta     $00
        jsr     GetAttackerMask
        jmp     DefaultMagicAnim

; ------------------------------------------------------------------------------

; [ magic animation $1f: reaction ??? ]

MagicAnim_1f:
@edf5:  jsr     SelfTargetMagicAnim
        lda     a:$0048
        jmp     _02e8e7

; ------------------------------------------------------------------------------

; [ magic animation $1e: reaction ]

MagicAnim_1e:
@edfe:  jsl     _01f803
        rts

; ------------------------------------------------------------------------------

; [ magic animation $1d: explode ]

MagicAnim_1d:
@ee03:  jsr     MagicAnim_1f
        jmp     MagicAnim_1c

; ------------------------------------------------------------------------------

; [ magic animation $06: drain, etc. ]

MagicAnim_06:
@ee09:  lda     $34c5
        beq     @ee13
        jsl     DrainAnim
        rts
@ee13:  lda     $3522
        beq     @ee25
        jsr     MagicAnim_1c
        jsr     _02ed74
        jsl     DrainAnim
        jsr     _02ed92
@ee25:  rts

; ------------------------------------------------------------------------------

; [ get attacker bit mask ]

GetAttackerMask:
@ee26:  lda     $34c3
        tax
        lda     f:BitOrTbl,x
        sta     $01
        rts

; ------------------------------------------------------------------------------

; [  ]

_02ee31:
@ee31:  ldx     #$0004
        stx     $00
        lda     #$1c
        ldx     #$dbe6
        jsr     Load3bppGfx
        ldx     #$0080
        stx     $00
        lda     #$7e
        ldx     #$dbe6
        ldy     #$0600
        jsr     ExecTfr
        ldx     #$0080
        stx     $00
        lda     #$7e
        ldx     #$dc26
        ldy     #$0700
        jmp     ExecTfr

; ------------------------------------------------------------------------------

; [ magic animation $0a: goblin (imp) ]

MagicAnim_0a:
@ee5e:  ldy     #$e380
        jsr     _02ee31
        jsl     GoblinAnim
        jmp     AfterMagicAnim

; ------------------------------------------------------------------------------

; [ magic animation $0b: bomb ]

MagicAnim_0b:
@ee6b:  jsl     BombAnim
        stz     $f2a0
        stz     $00
        lda     #$06
        sta     $f2d0
        lda     #$80
        sta     $01
        stz     $02
        lda     $f397
        jsr     ExecAnimScript
        lda     #$ff
        sta     $f320
        stz     $f2d0
        jsr     MagicAnim_00
        jmp     AfterMagicAnim

; ------------------------------------------------------------------------------

; [ magic animation $0c: cockatrice ]

MagicAnim_0c:
@ee93:  inc     $f285
        jsl     CockatriceAnim
        jmp     AfterMagicAnim

; ------------------------------------------------------------------------------

; [ magic animation $0d: mindflayer (mage) ]

MagicAnim_0d:
@ee9d:  jsl     CockatriceAnim
        jmp     AfterMagicAnim

; ------------------------------------------------------------------------------

; [ magic animation $0e: chocobo ]

MagicAnim_0e:
@eea4:  ldy     #$e3e0
        jsr     _02ee31
        ldx     $f321
        phx
        lda     #$08
        sta     $f115
        ldx     $f321
        stx     $f111
        lda     $49
        asl
        tax
        lda     $f2a1,x
        asl2
        clc
        adc     $f043,x
        sta     $f113
        lda     $f044,x
        sec
        sbc     #$10
        sta     $f114
        jsr     CalcTrajectory
        jsr     _02eef4
        jsl     ChocoboAnim
        plx
        stx     $f113
        ldx     $f321
        stx     $f111
        lda     #$08
        sta     $f115
        jsr     CalcTrajectory
        jsr     _02eef4
        jmp     AfterMagicAnim

; ------------------------------------------------------------------------------

_02eef4:
@eef4:  jsr     WaitFrame
        jsr     UpdateTrajectory
        bcs     @ef05
        ldx     $f118
        stx     $f321
        jmp     @eef4
@ef05:  rts

; ------------------------------------------------------------------------------

; [ magic animation $0f: shiva ]

MagicAnim_0f:
@ef06:  jsl     ShivaAnim
        jmp     AfterMagicAnim

; ------------------------------------------------------------------------------

; [ magic animation $10: ramuh (indra) ]

MagicAnim_10:
@ef0d:  jsl     RamuhAnim
        jmp     AfterMagicAnim

; ------------------------------------------------------------------------------

; [ magic animation $11: many ??? ]

MagicAnim_11:
@ef14:  lda     #$05
        sta     $f2d0
        lda     #$08
        sta     $f326
        jsr     MagicAnim_00
        jsl     IfritAnim
        jmp     AfterMagicAnim

; ------------------------------------------------------------------------------

; [ magic animation $12: titan ]

MagicAnim_12:
@ef28:  jsl     TitanAnim
        jmp     AfterMagicAnim

; ------------------------------------------------------------------------------

; [ magic animation $13: mist dragon ]

MagicAnim_13:
@ef2f:  jsl     MistDrgnAnim
        jmp     AfterMagicAnim

; ------------------------------------------------------------------------------

; [ magic animation $14: sylph ]

MagicAnim_14:
@ef36:  jsl     SylphAnim
        jsr     MagicAnim_00
        jsr     ResetAnimSpritesLarge
        jsr     AfterMagicAnim
        lda     $34c2
        and     #$80
        sta     $00
        stz     $01
        ldy     #0
@ef4f:  lda     $29c5,y
        cmp     #$ff
        beq     @ef60
        tya
        tax
        lda     f:BitOrTbl,x
        ora     $01
        sta     $01
@ef60:  iny
        cpy     #5
        bne     @ef4f
        stz     $02
        lda     #$3d
        jsr     ExecAnimScript
        lda     #$00
        jmp     PlaySfx

; ------------------------------------------------------------------------------

; [ magic animation $15: odin (summon) ]

MagicAnim_15:
@ef72:  jsl     OdinSummonAnim
        jmp     AfterMagicAnim

; ------------------------------------------------------------------------------

; [ magic animation $16: leviathan ]

MagicAnim_16:
@ef79:  jsl     LeviathanAnim
        jmp     AfterMagicAnim

; ------------------------------------------------------------------------------

; [ magic animation $17-$19: asura ]

MagicAnim_17:
MagicAnim_18:
MagicAnim_19:
@ef80:  jsl     AsuraAnim_far
        jsr     AfterMagicAnim
        jmp     MagicAnim_00

; ------------------------------------------------------------------------------

; [ magic animation $1a: bahamut ]

MagicAnim_1a:
@ef8a:  jsl     BahamutAnim
        jmp     AfterMagicAnim

; ------------------------------------------------------------------------------

; [ magic animation $07: quake ]

MagicAnim_07:
@ef91:  lda     $34c5
        beq     @efaa
        ldx     #$80b0
        stx     $f289       ; sprite $30 is highest priority
        lda     #$01
        sta     $f2d0
        jsr     MagicAnim_00
        ldx     #$0000
        stx     $f289       ; disable sprite priority order shifting
@efaa:  rts

; ------------------------------------------------------------------------------

; [ magic animation $08:  ]

MagicAnim_08:
@efab:  lda     #$02
        sta     $f2d0
        jmp     MagicAnim_01

; ------------------------------------------------------------------------------

; [ magic animation $09:  ]

MagicAnim_09:
@efb3:  lda     #$03
        sta     $f2d0
        jmp     MagicAnim_01

; ------------------------------------------------------------------------------

; [ magic animation $04: meteo, w.meteo ]

MagicAnim_04:
@efbb:  lda     #$8c                    ; sprite tile id
        jmp     _efc2

; [ magic animation $05: comet ]

MagicAnim_05:
@efc0:  lda     #$e4                    ; sprite tile id
_efc2:  sta     $f133
        lda     $34c5
        bne     @efcb
        rts
@efcb:  lda     #$04
        sta     $f2d0
        ldx     #$8060
        stx     $f289                   ; sprite $60 is highest priority
        jsr     MagicAnim_00
        lda     #$8d
        jsr     EnableAnimPalEffect
        jsl     FlashScreenRed
        lda     #$02
        sta     $ef87
        stz     $f2d0
        clr_ax
@efec:  stz     $ebe6,x
        sta     $ebe7,x
        pha
        lda     #$80
        sta     $ec06,x
        pla
        clc
        adc     #$10
        inx2
        cpx     #$0020
        bne     @efec
        lda     #$a0
        sta     $f29f
@f008:  jsr     WaitFrame
        jsr     UpdatePalSwap
        ldx     #0
@f011:  lda     $ebe7,x
        bne     @f030
        lda     $34c4
        bmi     @f025
        jsr     Rand1
        and     #$7f
        clc
        adc     #$60
        bra     @f028
@f025:  jsr     Rand1
@f028:  sta     $ebe6,x
        lda     #$0f
        sta     $ec06,x
@f030:  txa
        and     #$07
        clc
        adc     #$03
        sta     $02
        lda     $34c4
        bpl     @f057
        lda     #$3f
        sta     $00
        lda     $ebe6,x
        sec
        sbc     $02
        sta     $ebe6,x
        bcs     @f054
        lda     $ec06,x
        ora     #$80
        sta     $ec06,x
@f054:  jmp     @f06e
@f057:  lda     #$7f
        sta     $00
        lda     $ebe6,x
        clc
        adc     $02
        sta     $ebe6,x
        bcc     @f06e
        lda     $ec06,x
        ora     #$80
        sta     $ec06,x
@f06e:  lda     $ebe7,x
        clc
        adc     #$08
        sta     $ebe7,x
        inx2
        cpx     #$0020
        bne     @f011
        ldx     #0
        ldy     #0
@f084:  lda     $ec06,x
        bpl     @f094
        lda     #$f0
        sta     $03c0,y
        sta     $03c1,y
        jmp     @f0d7
@f094:  dec     $ec06,x
        lda     $ebe6,x
        sta     $03c0,y
        lda     $ebe7,x
        sec
        sbc     #$04
        sta     $03c1,y
        lda     $f133
        cmp     #$e4
        beq     @f0b6
        lda     $1813
        and     #$02
        clc
        adc     $f133
@f0b6:  sta     $03c2,y
        lda     $6cc0
        beq     @f0d2
        lda     $00
        eor     #$40
        sta     $03c3,y
        lda     $ebe6,x
        eor     #$ff
        sec
        sbc     #$10
        sta     $03c0,y
        bra     @f0d7
@f0d2:  lda     $00
        sta     $03c3,y
@f0d7:  iny4
        inx2
        cpx     #$0020
        bne     @f084
        dec     $f29f
        beq     @f0ea
        jmp     @f008
@f0ea:  stz     $ef87
        ldx     #0
        stx     $f289       ; disable sprite priority order shifting
        rts

; ------------------------------------------------------------------------------

; [ magic animation $03: teleport (exit) ]

MagicAnim_03:
@f0f4:  lda     $34c5
        bne     @f0fa
        rts
@f0fa:  jsr     PlayMagicSfx
        jsr     ResetAnimSpritesLarge
        jsl     TeleportPalAnim
        ldx     #$0005
        lda     #$27
        jsr     LoadAnimPal
        jsr     InitPolarAngle
        clr_ax
        stx     $f111
        stx     $f113
        jsr     SetPolarRadius
        lda     #$60
        sta     f:hBG1SC
        lda     #$58
        sta     f:hBG2SC
        lda     #$03
        sta     $f1b5
        inc
        sta     $f1b3
        lda     $ed4e
        and     #$bf
        sta     $ed4e                   ; disable monster flying animation
        clr_a
        jsr     SetFlyingHDMA
        jsr     CloseMenu

; start of frame loop
@f13e:  jsr     WaitFrame
        jsr     UpdateTeleportFadeOut
        lda     $f111
        clc
        adc     #$04
        sta     $f111
        sta     $f133
        lda     $f113
        clc
        adc     #$08
        sta     $f113
        sta     $f134
        ldy     #0
@f15f:  ldx     #0
        jsr     CalcPolarY
        sta     $7614,y
        sta     $7694,y
        sta     $7714,y
        sta     $7794,y
        sta     $7814,y
        ldx     #$0001
        jsr     CalcPolarY
        pha
        pha
        sta     $7612,y
        sta     $7692,y
        sta     $7712,y
        sta     $7792,y
        sta     $7812,y
        pla
        bmi     @f191
        clr_a
        bra     @f193
@f191:  lda     #$01
@f193:  sta     $7613,y
        sta     $7693,y
        sta     $7713,y
        sta     $7793,y
        sta     $7813,y
        pla
        sta     $7992,y
        sta     $7a12,y
        sta     $7a92,y
        sta     $7b12,y
        cpy     #$0030
        bcs     @f1b7
        sta     $7b92,y
@f1b7:  lda     $f133
        clc
        adc     #$08
        sta     $f133
        lda     $f134
        clc
        adc     #$08
        sta     $f134
        iny4
        cpy     #$0080
        beq     @f1d5
        jmp     @f15f
@f1d5:  lda     $f112
        lsr3
        sta     $f1b4
        lda     $f111
        sta     $f133
        lda     $f113
        sta     $f134
        inc     $f112
        lda     $f112
        cmp     #$64
        beq     @f1f7
        jmp     @f13e
@f1f7:  inc     $f425
        rts

; ------------------------------------------------------------------------------

; [ fade out palettes for teleport animation ]

UpdateTeleportFadeOut:
@f1fb:  lda     $f112
        and     #$40
        beq     @f225
        ldx     #0
@f205:  lda     $ed70,x
        sta     $00
        lda     $ed71,x
        sta     $01
        lda     #1
        jsr     DecColor
        lda     $00
        sta     $ed70,x
        lda     $01
        sta     $ed71,x
        inx2
        cpx     #$00c0
        bne     @f205
@f225:  rts

; ------------------------------------------------------------------------------

; [ darken battle bg palette ]

DarkenBattleBG:
@f226:  lda     $f487
        beq     @f22c
        rts
@f22c:  inc     $f487
        ldx     #0
@f232:  lda     $ed70,x                 ; save character color palettes
        sta     $f3c4,x
        inx
        cpx     #$0040
        bne     @f232
        lda     $1802                   ; battle bg id
        and     #$1f
        tax
        lda     f:DarkenBattleBGTbl,x
        tax
@f249:  jsr     WaitFrame
        jsr     DecBattleBGPal
        dex
        bne     @f249
        rts

; ------------------------------------------------------------------------------

; [ decrement battle bg palette ]

DecBattleBGPal:
@f253:  phx
        ldx     #0
@f257:  lda     $ed70,x
        sta     $00
        lda     $ed71,x
        sta     $01
        lda     #1
        jsr     DecColor
        lda     $00
        sta     $ed70,x
        lda     $01
        sta     $ed71,x
        inx2
        cpx     #$0040
        bne     @f257
        plx
        rts

; ------------------------------------------------------------------------------

; [ lighten battle bg palette ]

LightenBattleBG:
@f279:  lda     $f487
        bne     @f27f
        rts
@f27f:  stz     $f487
        lda     $1802                   ; battle bg id
        and     #$1f
        tax
        lda     f:DarkenBattleBGTbl,x
        tax
@f28d:  jsr     WaitFrame
        txa
        sta     $02
        jsr     IncBattleBGPal
        dex
        bne     @f28d
        ldx     #0
@f29c:  lda     $f3c4,x                 ; restore color palettes
        sta     $ed70,x
        inx
        cpx     #$0040
        bne     @f29c
        rts

; ------------------------------------------------------------------------------

; [  ]

IncBattleBGPal:
@f2a9:  phx
        ldx     #0
@f2ad:  lda     $f3c4,x
        sta     $00
        lda     $f3c5,x
        sta     $01
        lda     $02
        jsr     DecColor
        lda     $00
        sta     $ed70,x
        lda     $01
        sta     $ed71,x
        inx2
        cpx     #$0040
        bne     @f2ad
        plx
        rts

; ------------------------------------------------------------------------------

; [  ]

_02f2cf:
@f2cf:  ldx     #0
@f2d2:  lda     $edb0,x
        sta     $00
        lda     $edb1,x
        sta     $01
        lda     #1
        jsr     DecColor
        lda     $00
        sta     $edb0,x
        lda     $01
        sta     $edb1,x
        inx2
        cpx     #$0080
        bne     @f2d2
        rtl

; ------------------------------------------------------------------------------

; [  ]

_02f2f3:
@f2f3:  lda     #1
        sta     $f2a0
        rts

; ------------------------------------------------------------------------------

; [ magic animation $02: many attacks use this ??? ]

MagicAnim_02:
@f2f9:  jsr     _02f2f3
        inc     $f2a0
        lda     #$01                    ; this does nothing
        jmp     _02f310

; ------------------------------------------------------------------------------

; [ magic animation $01:  ]

MagicAnim_01:
@f304:  jsr     _02f2f3
        jmp     _02f310

; ------------------------------------------------------------------------------

; [ magic animation $1b:  ]

MagicAnim_1b:
@f30a:  inc     $f285
; fallthrough

; ------------------------------------------------------------------------------

; [ magic animation $00: default ]

MagicAnim_00:
@f30d:  stz     $f2a0

_02f310:
@f310:  jsr     MagicAnim_1c
        jmp     ReflectMagicAnim

; ------------------------------------------------------------------------------

; [ magic animation $1c: default, no reflect ]

MagicAnim_1c:
@f316:  lda     $34c4                   ; character/monster target
        and     #$80
        sta     $00
        lda     $34c5                   ; targets
        sta     $01

DefaultMagicAnim:
@f322:  lda     $3522                   ; targets reflected off of
        sta     $02
        lda     $f397                   ; animation script
        jmp     ExecAnimScript

; ------------------------------------------------------------------------------

; [ show reflected magic animation ]

ReflectMagicAnim:
@f32d:  lda     $34c4                   ; invert monster/character target
        and     #$80
        eor     #$80
        sta     $00
        lda     $3523                   ; targets reflected onto
        sta     $01
        stz     $02
        lda     $f397                   ; animation script
        jmp     ExecAnimScript

; ------------------------------------------------------------------------------

; [  ]

_02f343:
@f343:  lda     $f24e
        asl3
        sta     $26
        lda     $2d
        sec
        sbc     $26
        sta     $2d
        rts

; ------------------------------------------------------------------------------

; [  ]

_02f353:
@f353:  lda     $f24e
        asl3
        clc
        adc     $2d
        sta     $2d
        rts

; ------------------------------------------------------------------------------

; [  ]

_02f35f:
@f35f:  clr_ax
@f361:  sta     $f28f,x
        inx
        cpx     #$0010
        bne     @f361
        lda     $f2d0
        cmp     #$06
        bne     @f384

; bomb
        ldx     #$f28f
        stx     $08
        lda     #$80
        sta     $f27a
        lda     #$c8
        sta     $2c
        lda     #$54
        sta     $2d
        rts

; all others
@f384:  lda     [$02]
        and     #$f0
        cmp     #$d0
        beq     @f394
        cmp     #$e0
        beq     @f394
        cmp     #$30
        bne     @f3b0
@f394:  lda     #$44
        sta     $2d
        ldx     #$f28f
        stx     $08
        lda     #$80
        sta     $f27a
        lda     $00
        bne     @f3ab
        lda     #$d8
        sta     $2c
        rts
@f3ab:  lda     #$60
        sta     $2c
        rts
@f3b0:  cmp     #$40
        bne     @f3ce
        lda     $f49a
        cmp     #$91
        beq     @f3e5
        lda     #$60
        sta     $2c
        lda     #$44
        sta     $2d
        ldx     #$f28f
        stx     $08
        lda     #$80
        sta     $f27a
        rts
@f3ce:  cmp     #$50
        bne     @f3e5
        lda     #$80
        sta     $2c
        lda     #$44
        sta     $2d
        ldx     #$f28f
        stx     $08
        lda     #$80
        sta     $f27a
        rts
@f3e5:  ldy     #1
        lda     [$02],y
        and     #$60
        bne     @f410
        lda     $00
        bne     @f403
        stz     $2d
        lda     #$18
        sta     $2c
        lda     #$01
        sta     $f261
        ldx     #$f053
        jmp     @f494
@f403:  clr_ax
        stx     $2c
        sta     $f261
        ldx     #$f043
        jmp     @f494
@f410:  cmp     #$40
        bne     @f43e
        lda     $00
        bne     @f42d
        lda     #$f4
        sta     $2d
        lda     #$17
        sta     $2c
        jsr     _02f353
        lda     #$01
        sta     $f261
        ldx     #$f039
        bra     @f494
@f42d:  ldx     #0
        stx     $2c
        jsr     _02f353
        clr_a
        sta     $f261
        ldx     #$f029
        bra     @f494
@f43e:  cmp     #$60
        bne     @f46d
        lda     $00
        bne     @f45b
        lda     #$e8
        sta     $2d
        lda     #$17
        sta     $2c
        jsr     _02f353
        lda     #$01
        sta     $f261
        ldx     #$f039
        bra     @f494
@f45b:  stz     $2c
        lda     #$f0
        sta     $2d
        jsr     _02f353
        clr_a
        sta     $f261
        ldx     #$f029
        bra     @f494
@f46d:  lda     $00
        bne     @f484
        stz     $2c
        lda     #$f8
        sta     $2d
        jsr     _02f343
        lda     #$01
        sta     $f261
        ldx     #$f06d
        bra     @f494
@f484:  ldx     #0
        stx     $2c
        jsr     _02f343
        lda     #$00
        sta     $f261
        ldx     #$f05d
@f494:  stx     $08
        rts

; ------------------------------------------------------------------------------

; [ update shaking monster hdma data ]

UpdateShakeMonsters:
@f497:  pha
        ldx     #0
@f49b:  sta     $7612,x
        sta     $769e,x
        sta     $772a,x
        sta     $77b6,x
        inx4
        cpx     #$008c
        bne     @f49b
        pla
        rts

; ------------------------------------------------------------------------------

; [ update shaking battle bg hdma data ]

UpdateShakeBattleBG:
@f4b2:  pha
        lda     $1802       ; battle bg id
        cmp     #$10
        bne     @f4bc       ; return if final battle bg
        pla
        rts
@f4bc:  pla
        ldx     #0
@f4c0:  sta     $7992,x
        sta     $7a1e,x
        sta     $7aaa,x
        sta     $7b36,x
        inx4
        cpx     #$008c
        bne     @f4c0
        rts

; ------------------------------------------------------------------------------

; [  ]

_02f4d6:
@f4d6:  lda     $f2d0
        cmp     #$02
        beq     @f4e2
        cmp     #$03
        beq     @f4e2
        rts

; magic animation $08 and $09
@f4e2:  lda     #$ff
        sta     $f27a
        clr_ay
@f4e9:  sta     $f251,y
        iny
        cpy     #$0010
        bne     @f4e9
        lda     $f2a0
        jmp     _02f93a

; ------------------------------------------------------------------------------

; [  ]

_02f4f8:
@f4f8:  jsr     _02e8dd
        jsr     UpdateBG1Tiles
        ldx     #0
@f501:  asl     $f281
        bcc     @f514
        txa
        sta     $f109
        lda     #$07
        sta     $f10a
        phx
        jsr     _028a89
        plx
@f514:  inx
        cpx     #8
        bne     @f501
        jsr     ModifyBG1Tiles_near
        jsr     TfrLeftMonsterTiles
        jsr     _02e8e2
        rts

; ------------------------------------------------------------------------------

; [  ]

_02f524:
@f524:  clc
        adc     #$28
        sta     $26
        lda     #$10
        sta     $28
        jsr     Mult8
        lda     $f279
        bne     @f567
        lda     $f284
        sta     $26
        ldy     #0
@f53d:  asl     $26
        bcc     @f560
        phy
        tya
        asl5
        tay
        lda     #$10
        sta     $28
        ldx     $2a
@f54f:  lda     f:AnimPal,x
        sta     $ee70,y
        sta     $ee80,y
        inx
        iny
        dec     $28
        bne     @f54f
        ply
@f560:  iny
        cpy     #5
        bne     @f53d
        rts
@f567:  ldy     #0
        ldx     $2a
@f56c:  lda     f:AnimPal,x
        sta     $ee30,y
        sta     $ee40,y
        inx
        iny
        cpy     #$0010
        bne     @f56c
        rts

; ------------------------------------------------------------------------------

; [ disable animation palette for target ]

DisableTargetPalEffect:
@f57e:  lda     $f279
        bne     @f587

; character targets
        stz     $f283
        rts

; monster targets
@f587:  lda     $f282
        cmp     #1
        bne     @f595                   ; return if already disabled
        stz     $f282
        clr_a
        jmp     SwapMonsterScreen
@f595:  rts

; ------------------------------------------------------------------------------

; [ enable animation palette for target ]

EnableTargetPalEffect:
@f596:  lda     $f279
        bne     @f5a1

; character targets
        lda     #1
        sta     $f283
@f5a0:  rts

; monster targets
@f5a1:  lda     $f282                   ; return if already enabled
        bne     @f5a0
        lda     #1
        sta     $f282
        lda     #1
        jmp     SwapMonsterScreen

; ------------------------------------------------------------------------------

; [ disable shaking monsters and battle bg ]

DisableShakeBG_far:
@f5b0:  clr_a
        jsr     DisableShakeBG
        rtl

; ------------------------------------------------------------------------------

; [ update shaking monsters (don't shake battle bg) ]

UpdateShakeMonstersOnly:
@f5b5:  lda     $1813
        and     #$07
        tax
        lda     f:AnimShakeTbl,x
        jsr     UpdateShakeMonsters
        rtl

; ------------------------------------------------------------------------------

; [ update shaking monsters and battle bg ]

; unused

_02f5c3:
@f5c3:  lda     $1813
        and     #$07
        tax
        jsr     UpdateShakeMonstersAndBG
        rtl

; ------------------------------------------------------------------------------

; [ set/disable shaking monsters and battle bg ]

UpdateShakeMonstersAndBG:
@f5cd:  lda     f:AnimShakeTbl,x

DisableShakeBG:
@f5d1:  jsr     UpdateShakeMonsters
        jmp     UpdateShakeBattleBG

; ------------------------------------------------------------------------------

; [ play magic sound effect (far) ]

PlaySfx_far:
@f5d7:  jsr     PlaySfx
        rtl

; ------------------------------------------------------------------------------

; [ play default magic sound effect (far) ]

PlayMagicSfx_far:
@f5db:  jsr     PlayMagicSfx
        rtl

; ------------------------------------------------------------------------------

; [ play sound effect ]

PlaySfx:
@f5df:  sta     $f47f
        phx
        phy
        jmp     _f5f5

; ------------------------------------------------------------------------------

; [ play default magic sound effect ]

PlayMagicSfx:
@f5e7:  phx
        phy
        lda     $f47f
        cmp     #$ff
        beq     _f623
        tax
        lda     f:AttackSfx,x   ; attack sound effect
_f5f5:  pha
        cmp     #$31
        beq     @f5fe
        cmp     #$33
        bne     @f602
@f5fe:  lda     #$80        ; pan center
        bra     @f60d
@f602:  lda     $f485
        bmi     @f60b
        lda     #$c0        ; pan left (toward monsters)
        bra     @f60d
@f60b:  lda     #$40        ; pan right (toward characters)
@f60d:  sta     $f414       ; sound effect pan
        pla
        sta     $f413       ; sound effect id
        lda     #$ff
        sta     $f415
        lda     #$02        ; play sound effect
        sta     $f412
@f61e:  lda     $f412       ; wait for sound effect
        bne     @f61e
_f623:  ply
        plx
        rts

; ------------------------------------------------------------------------------

; [ enable animation palette effect (far) ]

EnableAnimPalEffect_far:
@f626:  jsr     EnableAnimPalEffect
        rtl

; ------------------------------------------------------------------------------

; [ disable animation palette effect (far) ]

DisableAnimPalEffect_far:
@f52a:  jsr     DisableAnimPalEffect
        rtl

; ------------------------------------------------------------------------------

; [ disable animation palette effect ]

DisableAnimPalEffect:
@f62e:  lda     $f457
        ldx     #$000f
        jsr     LoadAnimPal
        stz     $f451                   ; disable palette swap
        rts

; ------------------------------------------------------------------------------

; [ enable animation palette effect ]

EnableAnimPalEffect:
@f63b:  phx
        pha
        and     #$08
        beq     @f673
        pla
        pha
        and     #$f0
        bne     @f64d

; $08: disable palette effect
        jsr     DisableAnimPalEffect
        pla
        plx
        rts

; pppp1sss palette swap
;   p: battle animation palette index
;   s: animation speed (higher = faster)
@f64d:  lsr3
        tax
        longa
        lda     f:PalSwapTbl,x
        sta     $f455
        shorta0
        pla
        and     #$07
        tax
        lda     f:PalSwapSpeedTbl,x
        sta     $f452
        inc     $f451
        stz     $f453
        stz     $f454
        plx
        rts

; bgr-0ttt color flash
;   b: flash blue
;   g: flash green
;   r: flash red
;   t: flash type
;        0: disabled
;        1: every other frame
;        2: gradual
;        3: once
;        4: increase only
;        5: decrease only
@f673:  pla
        pha
        and     #$e0
        sta     $ef88
        pla
        pha
        lda     #$1f
        sta     $f435
        sta     $f434
        sta     $f433
        stz     $ef8a
        stz     $ef89
        pla
        and     #$07
        sta     $ef87
        plx
        rts

; ------------------------------------------------------------------------------

; [ update animation palette (far) ]

UpdatePalSwap_far:
@f695:  jsr     UpdatePalSwap
        rtl

; ------------------------------------------------------------------------------

; [ swap animation palette ]

UpdatePalSwap:
@f699:  lda     $f451
        beq     @f6bb
        lda     $f453
        and     $f452
        bne     @f6b8
        inc     $f454
        lda     $f454
        and     #$01
        tax
        lda     $f455,x
        ldx     #$000f
        jsr     LoadAnimPal
@f6b8:  inc     $f453
@f6bb:  rts

; ------------------------------------------------------------------------------

; [ execute animation script ]

;   A: animation id
; $00: monster attacker if msb set
; $01: targets
; $02: reflected targets

ExecAnimScript:
@f6bc:  asl
        tax
        stz     $f44e
        lda     #$01
        sta     $f261
        lda     $02                     ; reflected targets
        sta     $f24c
        sta     $06
        lda     f:AnimScriptPtrs,x
        sta     $02
        lda     f:AnimScriptPtrs+1,x
        sta     $03
        lda     #^AnimScriptPtrs
        sta     $04
        sta     $f280
        lda     $01
        ora     $f24c
        bne     @f6ea                   ; return if there are no targets
        jmp     _02f8f3
@f6ea:  lda     $00
        sta     $f485
        jsr     PlayMagicSfx
        ldx     $00
        stx     $f279
        lda     $01
        sta     $f281
        sta     $f284
        lda     $f2d0
        cmp     #$02
        beq     @f70a
        cmp     #$03
        bne     @f70f

; magic animation $08 and $09
@f70a:  lda     #$ff                    ; hit all targets
        sta     $f27a

@f70f:  ldx     $02
        inx2
        stx     $f27c
        lda     [$02]
        and     #$f0                    ; frame size id
        lsr3
        tax
        lda     f:AnimFrameSizeTbl,x
        sta     $f24d
        lda     f:AnimFrameSizeTbl+1,x
        sta     $f24e
        lda     [$02]
        and     #$0f
        inc
        sta     $f27b                   ; repeat count
        jsr     _02f35f
        ldy     #0
@f73a:  lda     ($08),y
        clc
        adc     $2c
        sta     $f251,y
        iny
        lda     ($08),y
        clc
        adc     $2d
        sta     $f251,y
        iny
        cpy     #$0010
        bne     @f73a
        ldx     #0
@f754:  stz     $f268,x
        inx
        cpx     #$0010
        bne     @f754
        jsr     _02f4d6
        ldy     #1
        lda     [$02],y                 ; animation speed id
        and     #$18
        lsr3
        tax
        lda     f:AnimSpeedTbl,x
        sta     $f29f
        ldy     #1
        lda     [$02],y
        bpl     @f77c
        stz     $f261
@f77c:  lda     [$02],y
        and     #$07
        sta     $f249
        lda     #$10
        sta     $f24f
        sta     $f250
        jsr     ResetAnimSpritesLarge
        stz     $f27e
        stz     $f27f
        stz     $f24a
        stz     $f24b
        jsr     _02f4f8
        ldx     #0
        stx     $f281

; start of frame loop
@f7a3:  jsr     WaitFrame
        jsr     UpdatePalSwap
        lda     $f27e
        and     $f29f
        bne     @f7bc
        lda     $f2a0
        cmp     #$03
        bne     @f7bc
        jsl     _01e85d
@f7bc:  lda     $f2a0
        cmp     #$04
        bne     @f7c7
        jsl     _01fef8
@f7c7:  lda     $f281                   ; target palette effect
        beq     @f7ed
        cmp     #$03
        beq     @f7ed
        cmp     #$01

; 2: slow flash (swap palette every 4 frames)
        beq     @f7d9
        lda     #$04
        jmp     @f7db

; 1: fast flash (swap palette every 2 frames)
@f7d9:  lda     #$02
@f7db:  sta     $00
        lda     $1813
        and     $00
        beq     @f7ea
        jsr     EnableTargetPalEffect
        jmp     @f7ed
@f7ea:  jsr     DisableTargetPalEffect
@f7ed:  lda     $f2d0
        beq     @f81f
        cmp     #$01
        bne     @f817
        lda     $f27e
        and     #$07
        tax
        lda     $f279
        bne     @f811

; shake battle bg and characters
        lda     f:AnimShakeTbl,x
        sta     $f268
        jsr     UpdateShakeBattleBG
        jsr     UpdateShakeChars
        jmp     @f81f

; shake battle bg and monsters
@f811:  jsr     UpdateShakeMonstersAndBG
        jmp     @f81f

;
@f817:  cmp     #$05
        bne     @f81f
        jsl     _01f313
@f81f:  inc     $f27e
@f822:  ldy     $f27c
        sty     $02
        lda     $f280
        sta     $04
        lda     $f27f
        tay
        lda     [$02],y                 ; get script command
        cmp     #$ff
        bne     @f839
        jmp     @f8c8
@f839:  lda     [$02],y                 ; get script command again
        bmi     @f840
        jmp     @f8aa

; $88: enable animation palette effect
@f840:  sta     $06
        cmp     #$88
        bne     @f855
        inc     $f27f
        iny
        lda     [$02],y                 ; palette effect parameter
        inc     $f44e
        jsr     EnableAnimPalEffect
        jmp     @f878

; $8c: disable target palette effect
@f855:  and     #$08
        beq     @f87e
        and     #$04
        beq     @f863
        jsr     DisableTargetPalEffect
        jmp     @f878

; $8f: enable target palette effect
@f863:  lda     $06
        pha
        lsr4
        and     #$07
        jsr     _02f524
        pla
        and     #$03
        sta     $f281
        jsr     EnableTargetPalEffect
@f878:  inc     $f27f
        jmp     @f822

; move animation sprite
@f87e:  lda     $06
        lsr4
        and     #$07
        asl
        tax
        lda     $06                     ; direction
        and     #$07
        inc
        sta     $08                     ; distance
        jsr     MoveAnim
        lda     $f24a
        clc
        adc     $06
        sta     $f24a
        lda     $f24b
        clc
        adc     $07
        sta     $f24b
        inc     $f27f
        jmp     @f822

; show animation frame
@f8aa:  and     #$7f
        sta     $f248
        lda     $f27a
        sta     $f262
        lda     #$01
        sta     $f247
        lda     $f27e
        and     $f29f
        bne     @f8c5
        inc     $f27f                   ; go to next animation frame
@f8c5:  jmp     @f7a3

; end of script
@f8c8:  stz     $f27f
        lda     $f2a0
        beq     @f8d3
        jsr     _02f93a
@f8d3:  dec     $f27b                   ; decrement repeat counter
        beq     @f8db
        jmp     @f7a3
@f8db:  lda     $f285
        bne     @f8e3
        jsr     DisableTargetPalEffect
@f8e3:  jsr     _02f8f3
        lda     $f284
        sta     $f467
        jsr     MagicHitCharAnim_near
        clr_a
        jmp     DisableShakeBG

; ------------------------------------------------------------------------------

; [  ]

_02f8f3:
@f8f3:  clr_a
        sta     $f42e
        sta     $efc7
        sta     $efd7
        sta     $efe7
        sta     $eff7
        sta     $f007
        sta     $f281
        sta     $f283
        sta     $f451
        lda     $f44e
        beq     @f917
        stz     $ef87
@f917:  lda     $f279
        sta     $f466
        rts

; ------------------------------------------------------------------------------

; [  ]

_02f91e:
@f91e:  lda     $1813
        tax
        ldy     #0
@f925:  lda     $1900,x     ; rng table
        and     #$0f
        sec
        sbc     #$06
        sta     $f3b0,y
        inx
        txa
        tax
        iny
        cpy     #$0012
        bne     @f925
        rts

; ------------------------------------------------------------------------------

; [  ]

_02f93a:
@f93a:  cmp     #$03
        beq     @f942
        cmp     #$04
        bne     @f943
@f942:  rts
@f943:  cmp     #$02
        bne     @f94a
        jmp     _02f91e
@f94a:  lda     $f2d0
        cmp     #$02
        bne     @f975
        ldx     #0
        lda     #$20
        sta     $00
@f958:  lda     #$20
        jsr     _02fa42
        clc
        adc     #$d0
        sta     $f268,x
        lda     $00
        sta     $f269,x
        clc
        adc     #$0c
        sta     $00
        inx2
        cpx     #$0010
        bne     @f958
        rts
@f975:  cmp     #$03
        bne     @f99c
        clr_ax
        lda     #$20
        sta     $00
@f97f:  lda     #$90
        jsr     _02fa42
        clc
        adc     #$18
        sta     $f268,x
        lda     $00
        sta     $f269,x
        clc
        adc     #$0c
        sta     $00
        inx2
        cpx     #$0010
        bne     @f97f
        rts
@f99c:  clr_ax
        lda     $f279
        bne     @f9c1
@f9a3:  lda     #$08
        jsr     _02fa42
        sec
        sbc     #$04
        sta     $f268,x
        lda     #$0c
        jsr     _02fa42
        sec
        sbc     #$06
        sta     $f269,x
        inx2
        cpx     #$000a
        bne     @f9a3
        rts
@f9c1:  lda     $f2a1,x
        asl2
        sta     $00
        asl
        jsr     _02fa42
        sec
        sbc     $00
        sta     $f268,x
        inx
        cpx     #$0010
        bne     @f9c1
        rts

; ------------------------------------------------------------------------------

; [  ]

_02f9d9:
@f9d9:  ldx     #$0010
@f9dc:  phx
        jsr     _02f9ee
        jsr     WaitFrame
        jsr     WaitFrame
        plx
        dex
        bne     @f9dc
        jsr     ResetAnimSpritesLarge
        rtl

; ------------------------------------------------------------------------------

; [  ]

_02f9ee:
@f9ee:  lda     #$08
        jsr     PlaySfx
        lda     #$50
        sta     $f0c2
        lda     #$22
        sta     $f0c3
        stz     $f0c6
        lda     #$ff
        sta     $f0c7
        lda     #$3e
        sta     $f0c8
        lda     $49
        asl
        tax
        lda     $f2a1,x
        asl2
        sta     $00
        asl
        jsr     _02fa42
        sec
        sbc     $00
        sbc     #$08
        clc
        adc     $f043,x
        sta     $f0c4
        lda     $f2a2,x
        asl2
        sta     $00
        asl
        jsr     _02fa42
        sec
        sbc     $00
        sbc     #$08
        clc
        adc     $f044,x
        sta     $f0c5
        lda     #1
        sta     $f0c1
        rts

; ------------------------------------------------------------------------------

; [  ]

_02fa42:
@fa42:  sta     $26
        jsr     Rand1
        sta     $28
        jsr     Mult8
        lda     $2b
        rts

; ------------------------------------------------------------------------------

; [ random (0..255) ]

Rand1:
@fa4f:  inc     $97
        lda     $97
        tay
        lda     $1900,y     ; rng table
        rts

; ------------------------------------------------------------------------------

; [ move shaking characters ]

UpdateShakeChars:
@fa58:  ldx     #0
        sta     $00
        lda     $f284
        sta     $02
@fa62:  asl     $02
        bcc     @fa71
        txa
        asl4
        tay
        lda     $00
        sta     $efc7,y
@fa71:  inx
        cpx     #5
        bne     @fa62
        rts

; ------------------------------------------------------------------------------

; [ move animation sprite ]

MoveAnim:
@fa78:  lda     $f261
        beq     @fa82
        txa
        clc
        adc     #$10
        tax
@fa82:  lda     f:MoveAnimTbl,x
        sta     $06
        lda     f:MoveAnimTbl+1,x
        sta     $07
        jmp     ($0006)

; ------------------------------------------------------------------------------

MoveAnimTbl:
@fa91:  .addr   MoveAnimDownBack
        .addr   MoveAnimDown
        .addr   MoveAnimDownForward
        .addr   MoveAnimBack
        .addr   MoveAnimForward
        .addr   MoveAnimUpBack
        .addr   MoveAnimUp
        .addr   MoveAnimUpForward

; h-flip animation
        .addr   MoveAnimDownForward
        .addr   MoveAnimDown
        .addr   MoveAnimDownBack
        .addr   MoveAnimForward
        .addr   MoveAnimBack
        .addr   MoveAnimUpForward
        .addr   MoveAnimUp
        .addr   MoveAnimUpBack

; ------------------------------------------------------------------------------

; [ move animation $00/$0a: down/back ]

MoveAnimDownBack:
@fab1:  clr_a
        sec
        sbc     $08
        sta     $06
        lda     $08
        sta     $07
        rts

; ------------------------------------------------------------------------------

; [ move animation $01/$09: down ]

MoveAnimDown:
@fabc:  stz     $06
        lda     $08
        sta     $07
        rts

; ------------------------------------------------------------------------------

; [ move animation $02/$08: down/forward ]

MoveAnimDownForward:
@fac3:  lda     $08
        sta     $06
        sta     $07
        rts

; ------------------------------------------------------------------------------

; [ move animation $03/$0c: back ]

MoveAnimBack:
@faca:  clr_a
        sec
        sbc     $08
        sta     $06
        stz     $07
        rts

; ------------------------------------------------------------------------------

; [ move animation $04/$0b: forward ]

MoveAnimForward:
@fad3:  lda     $08
        sta     $06
        stz     $07
        rts

; ------------------------------------------------------------------------------

; [ move animation $05/$0f: up/back ]

MoveAnimUpBack:
@fada:  clr_a
        sec
        sbc     $08
        sta     $06
        sta     $07
        rts

; ------------------------------------------------------------------------------

; [ move animation $06/$0e: up ]

MoveAnimUp:
@fae3:  stz     $06
        clr_a
        sec
        sbc     $08
        sta     $07
        rts

; ------------------------------------------------------------------------------

; [ move animation $07/$0d: up/forward ]

MoveAnimUpForward:
@faec:  lda     $08
        sta     $06
        clr_a
        sec
        sbc     $08
        sta     $07
        rts

; ------------------------------------------------------------------------------

; [ update animation target palette ]

UpdateTargetPal:
@faf7:  lda     $f42e
        beq     @fb45
        lda     $f279
        bne     @fb46
        lda     $f283
        beq     @fb45

; cycle target character palette
        ldx     #0
        lda     $f284
        sta     $0e
@fb0e:  asl     $0e
        bcc     @fb3f                   ; branch if character is not a target
        txa
        longa
        asl5                            ; get pointer to character palette
        tay
        lda     $ee8e,y                 ; copy animation palette
        pha
        phy
        lda     #13                     ; copy 13 colors
        sta     $10
        tya
        clc
        adc     #$001c
        tay
@fb2b:  lda     $ee70,y
        sta     $ee72,y
        dey2
        dec     $10
        bne     @fb2b
        ply
        pla
        sta     $ee74,y
        shorta0
@fb3f:  inx
        cpx     #5
        bne     @fb0e
@fb45:  rts

; update target palette cycle
@fb46:  lda     $f281
        cmp     #$03
        bne     @fb6a
        longa
        lda     $ee3e
        pha
        ldx     #$000c
@fb56:  lda     $ee30,x                 ; cycle palette by 1
        sta     $ee32,x
        dex2
        bne     @fb56
        pla
        sta     $ee32
        sta     $ee42
        shorta0
@fb6a:  rts

; ------------------------------------------------------------------------------

; [ update animation sprites ]

UpdateAnimSprites:
@fb6b:  lda     $f481
        beq     @fb73
        jsr     UpdateTargetPal
@fb73:  lda     $f247
        bne     @fb79
        rts
@fb79:  sta     $f42e
        jsr     UpdateTargetPal
        lda     $f267
        dec
        bne     @fb8e
        lda     $f24f
        sta     $f250
        jsr     ResetAnimSpritesLarge
@fb8e:  stz     $f247
        lda     $f24c
        sta     $f263
        stz     $18
        jsr     LoadAnimFrame
        ldx     $f2b2
        stx     $0e
        lda     $f250
        longa
        asl2
        tay
        shorta0
@fbac:  asl     $f263
        bcc     @fbba                   ; branch if target not reflected

; reflected off target
        asl     $f262
        jsr     DrawReflectSprites
        jmp     @fbbf

@fbba:  asl     $f262
        bcs     @fbd9                   ; branch if target hit

; next target
@fbbf:  inc     $18
        lda     $18
        cmp     #$08
        bne     @fbac
        dec     $f267
        bne     @fbd8
        lda     $f24f
        sta     $f250
        lda     $f266
        sta     $f267
@fbd8:  rts

; hit target
@fbd9:  ldx     $f2b2
        beq     @fbac
        jsr     DrawAnimSprites
        jmp     @fbbf

; ------------------------------------------------------------------------------

; [ draw animation sprites ]

DrawAnimSprites:
@fbe4:  lda     $18
        asl
        tax
        lda     $f251,x
        clc
        adc     $f268,x
        sta     $12
        lda     $f252,x
        clc
        adc     $f269,x
        sta     $13
        ldx     #0
@fbfd:  lda     $6cc0
        beq     @fc47
        lda     $ebe6,x
        clc
        adc     #$0f
        bpl     @fc11
        clc
        adc     $12
        bcc     @fc29
        bra     @fc16
@fc11:  clc
        adc     $12
        bcs     @fc29
@fc16:  eor     #$ff
        sta     $0300,y
        lda     $ebe7,x
        clc
        adc     $13
        cmp     #$8c
        bcc     @fc33
        cmp     #$f8
        bcs     @fc33
@fc29:  lda     #$f0
        sta     $0300,y
        sta     $0301,y
        bra     @fc36
@fc33:  sta     $0301,y
@fc36:  lda     $ebe8,x
        sta     $0302,y
        lda     $ebe9,x
        eor     #$40
        sta     $0303,y
        jmp     @fc82
@fc47:  lda     $ebe6,x
        bpl     @fc53
        clc
        adc     $12
        bcc     @fc69
        bra     @fc58
@fc53:  clc
        adc     $12
        bcs     @fc69
@fc58:  sta     $0300,y
        lda     $ebe7,x
        clc
        adc     $13
        cmp     #$8c
        bcc     @fc73
        cmp     #$f8
        bcs     @fc73
@fc69:  lda     #$f0
        sta     $0300,y
        sta     $0301,y
        bra     @fc76
@fc73:  sta     $0301,y
@fc76:  lda     $ebe8,x
        sta     $0302,y
        lda     $ebe9,x
        sta     $0303,y
@fc82:  inc     $f250
        inx4
        iny4
        cpx     $0e
        beq     @fc94
        jmp     @fbfd
@fc94:  rts

; ------------------------------------------------------------------------------

; [ draw reflected sprites ]

DrawReflectSprites:
@fc95:  lda     $18
        asl
        tax
        lda     $f279
        bne     @fcad
        lda     $f053,x
        sta     $12
        lda     $f054,x
        clc
        adc     #$06
        sta     $13
        bra     @fcb7
@fcad:  lda     $f043,x
        sta     $12
        lda     $f044,x
        sta     $13
@fcb7:  ldx     #0
@fcba:  lda     $6cc0
        beq     @fceb
        lda     f:ReflectSpriteTbl,x
        clc
        adc     $12
        eor     #$ff
        sec
        sbc     #$0f
        sta     $0300,y
        lda     f:ReflectSpriteTbl+1,x
        clc
        adc     $13
        sta     $0301,y
        lda     f:ReflectSpriteTbl+2,x
        sta     $0302,y
        lda     f:ReflectSpriteTbl+3,x
        eor     #$40
        sta     $0303,y
        jmp     @fd0d
@fceb:  lda     f:ReflectSpriteTbl,x
        clc
        adc     $12
        sta     $0300,y
        lda     f:ReflectSpriteTbl+1,x
        clc
        adc     $13
        sta     $0301,y
        lda     f:ReflectSpriteTbl+2,x
        sta     $0302,y
        lda     f:ReflectSpriteTbl+3,x
        sta     $0303,y
@fd0d:  lda     $f279
        beq     @fd1a
        lda     $0303,y
        eor     #$40
        sta     $0303,y
@fd1a:  inc     $f250
        inx4
        iny4
        cpx     #8
        bne     @fcba
        rts

; ------------------------------------------------------------------------------

; [ load animation frame ]

LoadAnimFrame:
@fd2b:  lda     $f2d0
        cmp     #$07
        beq     @fd3f
        cmp     #$01
        beq     @fd3f
        cmp     #$04
        beq     @fd3f

; all others
        lda     #$30
        jmp     @fd41

; big bang, quake, comet
@fd3f:  lda     #$20
@fd41:  sta     $1a
        lda     $f24d
        asl3
        sta     $12
        lda     $f24e
        asl3
        sta     $13
        lda     $f24a
        sec
        sbc     $12
        sta     $12
        lda     $f24b
        sec
        sbc     $13
        sta     $13
        lda     $f248
        tax
        stx     $1c
        lda     $f249
        longa
        asl7
        clc
        adc     $1c
        asl
        tax
        shorta0
        lda     f:AnimFramePtrs,x
        sta     $1c
        lda     f:AnimFramePtrs+1,x
        sta     $1d
        lda     #^AnimFramePtrs
        sta     $1e
        ldx     $f24d
        stx     $10
        ldx     $12
        stx     $14
        ldy     #0

; start of tile loop
@fd99:  lda     [$1c]
        bmi     @fdab

; single tile
        ldx     $1c
        inx
        stx     $1c
        jsl     _03f4d8
        bcc     @fdce
        jmp     @fd99

; end of frame
@fdab:  cmp     #$ff
        beq     @fdce

; rle
        sta     $16
        ldx     $1c
        inx
        stx     $1c
        lda     [$1c]                   ; repeat count
        sta     $17
        ldx     $1c
        inx
        stx     $1c
@fdbf:  lda     $16
        jsl     _03f4d8
        bcc     @fdce
        dec     $17
        bne     @fdbf
        jmp     @fd99

; end of frame
@fdce:  sty     $f2b2
        lda     $f2a0
        cmp     #$04
        beq     @fde0
        cmp     #$03
        beq     @fde0
        cmp     #$02
        bne     @fe05
@fde0:  ldx     #0
        ldy     #0
@fde6:  lda     $ebe6,y
        clc
        adc     $f3b0,x
        sta     $ebe6,y
        lda     $ebe7,y
        clc
        adc     $f3b1,x
        sta     $ebe7,y
        inx2
        iny4
        cpy     #$0024
        bne     @fde6
@fe05:  rts

; ------------------------------------------------------------------------------

; [ load pre-magic animation graphics ]

LoadPreMagicGfx:
@fe06:  tax
        lda     f:PreMagicGfxTbl,x
        jmp     LoadMagicGfx

; ------------------------------------------------------------------------------

_02fe0e:
@fe0e:  .word   $0060,$0040,$0020

; ------------------------------------------------------------------------------

; [ load magic graphics ]

LoadMagicGfx:
@fe14:  ldy     #$0080
        sty     $f469
        ldy     #$1000
        sty     $f46b
        bra     _fe2e

LoadDarkWaveGfx:
@fe22:  ldy     #$0020
        sty     $f469
        ldy     #$0400
        sty     $f46b
_fe2e:  pha
        cmp     #$15
        bcc     @fe46
        sec
        sbc     #$15
        phx
        longa
        asl
        tax
        lda     f:_02fe0e,x
        sta     $f469
        shorta0
        plx
@fe46:  lda     #$7f
        sta     $06
        lda     #$0c
        sta     $02
        pla
        longa
        asl6
        tax
        lda     #$dbe6
        sta     $08
        lda     #$f000
        sta     $04
        ldy     $f469
@fe65:  phy
        lda     f:AnimTiles,x
        pha
        pha
        and     #$3fff
        asl
        tay
        lda     [$04],y
        sta     $00
        pla
        and     #$4000
        sta     $0a
        pla
        and     #$8000
        bne     @feab
        ldy     #$0000
@fe84:  lda     [$00]
        jsr     _02ff09
        sta     ($08),y
        inc     $00
        inc     $00
        iny2
        cpy     #$0010
        bne     @fe84
@fe96:  lda     [$00]
        jsr     _02ff09
        and     #$00ff
        sta     ($08),y
        inc     $00
        iny2
        cpy     #$0020
        bne     @fe96
        bra     @fed6
@feab:  ldy     #$000e
@feae:  lda     [$00]
        jsr     _02ff09
        sta     ($08),y
        inc     $00
        inc     $00
        dey2
        cpy     #$fffe
        bne     @feae
        ldy     #$001e
@fec3:  lda     [$00]
        jsr     _02ff09
        and     #$00ff
        sta     ($08),y
        inc     $00
        dey2
        cpy     #$000e
        bne     @fec3
@fed6:  lda     $08
        clc
        adc     #$0020
        sta     $08
        inx2
        ply
        dey
        bne     @fe65
        shorta0
        clr_ax
@fee9:  sta     $e9a6,x
        sta     $eba6,x
        inx
        cpx     #$0040
        bne     @fee9
        ldy     #$1800
        ldx     $f46b
        stx     $00
        lda     #$7e
        ldx     #$dbe6
        jsr     ExecTfr
        jsr     _02ff20
        rts

; ------------------------------------------------------------------------------

; [  ]

_02ff09:
@ff09:  pha
        lda     $0a
        beq     @ff1e
        pla
        xba
        sta     $0c
        phx
        ldx     #$0010
@ff16:  asl     $0c
        ror
        dex
        bne     @ff16
        plx
        rts
@ff1e:  pla
        rts

; ------------------------------------------------------------------------------

; [  ]

_02ff20:
@ff20:  ldx     #$0440
        jsr     _02ff42
        ldy     #$1ec0
        jsr     @ff35
        ldx     #$0460
        jsr     _02ff42
        ldy     #$1fc0
@ff35:  ldx     #$0040
        stx     $00
        lda     #$7e
        ldx     #$dbe6
        jmp     _02ff62

; ------------------------------------------------------------------------------

; [  ]

_02ff42:
@ff42:  longa
        lda     f:AnimTiles,x
        and     #$03ff
        asl
        tax
        lda     $7ff000,x
        tay
        shorta0
        ldx     #2
        stx     $00
        ldx     #$dbe6
        lda     #^AnimGfx
        jmp     Load3bppGfx

; ------------------------------------------------------------------------------

; [  ]

_02ff62:
@ff62:  pha
        phx
        phy
        ldx     $00
        phx
@ff68:  lda     $efa8
        beq     @ff72
        jsr     WaitFrame
        bra     @ff68
@ff72:  plx
        stx     $00
        ply
        plx
        pla
        sta     $efaf
        stx     $efa9
        sty     $efab
        ldx     #$0040
        stx     $efad
        longa
        lda     $00
        asl2
        and     #$ff00
        sta     $00
        shorta0
        lda     $01
        sta     $efb0
@ff9a:  inc     $efa8
        jsr     WaitFrame
        dec     $efb0
        beq     @ffc0
        longa
        lda     $efa9
        clc
        adc     #$0040
        sta     $efa9
        lda     $efab
        clc
        adc     #$0020
        sta     $efab
        shorta0
        bra     @ff9a
@ffc0:  rts

; ------------------------------------------------------------------------------
