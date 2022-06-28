
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: weapon.asm                                                           |
; |                                                                            |
; | description: weapon animation routines                                     |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

; [ weapon animation $0a: whip ]

WeaponAnim_0a:
@cd42:  lda     #1
        sta     $f233
        bra     _cd4c

; ------------------------------------------------------------------------------

; [ weapon animation $01: sword ]

WeaponAnim_01:
@cd49:  stz     $f233
_cd4c:  lda     $4e
        bne     @cd53
        jmp     SwordWhipAnimRight
@cd53:  jmp     SwordWhipAnimLeft

; ------------------------------------------------------------------------------

; [ weapon animation $0b: hammer ]

WeaponAnim_0b:
@cd56:  lda     #$2c
        bra     _cd5c

; ------------------------------------------------------------------------------

; [ weapon animation $02: rod ]

WeaponAnim_02:
@cd5a:  lda     #$0b
_cd5c:  sta     $f4a0
        stz     $f233
        lda     $4e
        bne     @cd69
        jmp     RodHammerAnimRight
@cd69:  jmp     RodHammerAnimLeft

; ------------------------------------------------------------------------------

; [ update weapon sprite ]

UpdateWeaponSprite:
@cd6c:  lda     $52
        inc
        and     #$04
        tax
        lda     $f242
        beq     @cd7c
        txa
        clc
        adc     #$08
        tax
@cd7c:  lda     f:WeaponSpriteTbl,x
        sta     $f0cb
        lda     f:WeaponSpriteTbl+1,x
        sta     $f0d1
        lda     f:WeaponSpriteTbl+2,x
        sta     $f0d2
        lda     f:WeaponSpriteTbl+3,x
        sta     $f0ce
        rts

; ------------------------------------------------------------------------------

; [  ]

_02cd99:
@cd99:  lda     $f233
        beq     @cdc1
        lda     $f242
        bne     @cda7
        lda     #$3f
        bra     @cda9
@cda7:  lda     #$7f
@cda9:  sta     $f0ce
        lda     $f0cd
        clc
        adc     #$08
        sta     $f0cd
        lda     $52
        inc
        and     #$04
        beq     @cdc1
        lda     #$82
        sta     $f0cb
@cdc1:  rts

; ------------------------------------------------------------------------------

; [ rod/hammer animation ]

RodHammerAnim:
@cdc2:  sta     $f0cf
        jsr     GetAttackerCharSpritePtr
        stz     $efcd,x
        stz     $efd3,x
        lda     #$10                    ; 16 frames
        sta     $54
        jsr     ResetAnimSpritesLarge

; start of frame loop
@cdd5:  jsr     WaitFrame
        lda     $52
        and     #$07
        bne     @cde7
        lda     $f4a0
        jsr     PlaySfx
        jsr     CritFlash
@cde7:  jsr     GetAttackerCharSpritePtr
        lda     $52
        and     #$01
        bne     @cdf3
        inc     $efd3,x
@cdf3:  inc     $52
        lda     $52
        and     #$03
        jsr     _02d6ec
        lda     $52
        and     #$02
        clc
        adc     #$a0
        sta     $f0c6
        jsr     RandHitPos
        jsr     UpdateWeaponSprite
        jsr     _02cd99
        jsr     GetAttackerCharSpritePtr
        lda     $efc5,x
        clc
        adc     $efc7,x
        adc     $f0d1
        sta     $f0cc
        lda     $efc6,x
        clc
        adc     $efc8,x
        adc     $f0d2
        sta     $f0cd
        lda     $48
        tax
        lda     f:FirstCharSpriteAboveTbl,x
        clc
        adc     $f0cf
        sta     $f0ca
        inc     $f0c9
        lda     $34c4
        bpl     @ce4c
        lda     $34c7
        and     #$08
        bne     @ce4c
        inc     $f0c1
@ce4c:  dec     $54
        beq     @ce53
        jmp     @cdd5
@ce53:  stz     $f0c9
        rts

; ------------------------------------------------------------------------------

; [ init weapon animation for left or right hand ]

; A: character pose

InitLeftWeaponAnim:
@ce57:  pha
        lda     $48
        tax
        lda     f:FirstCharSpriteBelowTbl,x
        bra     _ce69

InitRightWeaponAnim:
@ce61:  pha
        lda     $48
        tax
        lda     f:FirstCharSpriteAboveTbl,x
_ce69:  sta     $f0bc,x
        pla
        sta     $f099,x
        lda     $4e
        tax
        lda     $50,x
        jsr     LoadWeaponAnim
        stz     $52
        rts

; ------------------------------------------------------------------------------

; [ rod/hammer animation (left hand) ]

RodHammerAnimLeft:
@ce7b:  lda     #$06
        jsr     InitLeftWeaponAnim
        clr_a
        jmp     RodHammerAnim

; ------------------------------------------------------------------------------

; [ rod/hammer animation (right hand) ]

RodHammerAnimRight:
@ce84:  lda     #$05
        jsr     InitRightWeaponAnim
        lda     #$06
        jmp     RodHammerAnim

; ------------------------------------------------------------------------------

; [ throw animation (right hand) ]

ThrowAnimRight:
@ce8e:  lda     #$05
        jsr     InitRightWeaponAnim
        lda     #$06
        jmp     ThrowAnim1

; ------------------------------------------------------------------------------

; [ throw animation (left hand) ]

ThrowAnimLeft:
@ce98:  lda     #$06
        jsr     InitLeftWeaponAnim
        clr_a
        jmp     ThrowAnim1

; ------------------------------------------------------------------------------

; [ harp animation (left hand) ]

HarpAnimLeft:
@cea1:  lda     #$06
        jsr     InitLeftWeaponAnim
        jsr     GetAttackerCharSpritePtr
        clr_a
        sta     $efd3,x
        jmp     HarpAnim

; ------------------------------------------------------------------------------

; [ harp animation (right hand) ]

HarpAnimRight:
@ceb0:  lda     #$06
        jsr     InitRightWeaponAnim
        jsr     GetAttackerCharSpritePtr
        lda     #$03
        sta     $efd3,x
        lda     #$06
        jmp     HarpAnim

; ------------------------------------------------------------------------------

; [ bow animation (no arrows) ]

BowAnimNoArrows:
@cec2:  lda     #$06
        jsr     InitRightWeaponAnim
        jsr     GetAttackerCharSpritePtr
        lda     #$03
        sta     $efd3,x
        lda     #$06
        jmp     BowAnim

; ------------------------------------------------------------------------------

; [ bow animation (with arrows) ]

BowAnimWithArrows:
@ced4:  lda     #$06
        jsr     InitLeftWeaponAnim
        jsr     GetAttackerCharSpritePtr
        clr_a
        sta     $efd3,x
        jmp     BowAnim

; ------------------------------------------------------------------------------

; [ sword/whip animation (left hand) ]

SwordWhipAnimLeft:
@cee3:  lda     #$06
        jsr     InitLeftWeaponAnim
        clr_a
        jmp     SwordWhipAnim

; ------------------------------------------------------------------------------

; [ sword/whip animation (right hand) ]

SwordWhipAnimRight:
@ceec:  lda     #$05
        jsr     InitRightWeaponAnim
        lda     #$06
        jmp     SwordWhipAnim

; ------------------------------------------------------------------------------

; [ sword/whip animation ]

SwordWhipAnim:
@cef6:  sta     $f0cf
        jsr     GetAttackerCharSpritePtr
        stz     $efcd,x
        stz     $efd3,x
        lda     #$10
        sta     $54
        lda     $49
        asl
        tay
        lda     $f043,y
        sta     $f0c4
        lda     $f044,y
        sta     $f0c5

; start of frame loop
@cf16:  jsr     WaitFrame
        lda     $52
        and     #$07
        bne     @cf28                   ; once per 8 frames
        lda     $f4a0
        jsr     PlaySfx
        jsr     CritFlash
@cf28:  jsr     GetAttackerCharSpritePtr
        lda     $52
        and     #$01
        bne     @cf34                   ; every other frame
        inc     $efd3,x
@cf34:  inc     $52
        inc     $f42b
        stz     $f0c7
        lda     #$3f
        sta     $f0c8
        stx     $00
        lda     $53                     ; weapon animation type
        asl3
        sta     $04
        lda     $52                     ; frame counter
        and     #$07
        clc
        adc     $04
        tax
        lda     #$a0
        sta     $f0c6
        lda     f:SwordWhipHitFrameTbl,x
        sta     $f0c3
        lda     #$10
        sta     $f0c2
        stz     $f42b
        jsr     UpdateWeaponSprite
        jsr     _02cd99
        ldx     $00
        lda     $efc5,x
        clc
        adc     $efc7,x
        adc     $f0d1
        sta     $f0cc
        lda     $efc6,x
        clc
        adc     $efc8,x
        adc     $f0d2
        sta     $f0cd
        lda     $48
        tax
        lda     f:FirstCharSpriteAboveTbl,x
        clc
        adc     $f0cf
        sta     $f0ca
        inc     $f0c9
        lda     $f468
        bne     @cfad
        lda     $34c4
        bpl     @cfad
        lda     $34c7
        and     #$08
        bne     @cfad
        inc     $f0c1
@cfad:  dec     $54
        beq     @cfb4
        jmp     @cf16
@cfb4:  stz     $f0c9
        rts

; ------------------------------------------------------------------------------

; [ do fight/item animation ]

DoFightAnim:
@cfb8:  stz     $f480
        lda     $48
        asl3
        tax
        lda     $32db,x                 ; right hand item
        sta     $50
        lda     $32df,x                 ; left hand item
        sta     $51

DoItemAnim:
@cfcb:  lda     $49
        asl
        tax
        lda     $34c4
        bmi     @cfd9
        lda     $34d5,x                 ; check if attack missed
        bra     @cfdc
@cfd9:  lda     $34df,x
@cfdc:  and     #$40
        lsr3
        sta     $00
        lda     $34c7
        ora     $00
        sta     $34c7
        lda     $34c2
        bmi     @d02b                   ; branch if monster attacker

; character attacker
        jsr     GetAttackerCharSpritePtr
@cff3:  lda     $efc5,x
        cmp     #$c0
        bne     @cff3                   ; wait for character to step forward
        lda     $f480
        bne     @d00f
        lda     $50                     ; ignore equipped shields
        cmp     #$60
        bcc     @d007
        stz     $50
@d007:  lda     $51
        cmp     #$60
        bcc     @d00f
        stz     $51
@d00f:  jsr     DoWeaponAnim
        jsr     ResetAnimSpritesLarge
        jsr     WeaponHitAnim
        lda     $48
        tax
        clr_a
        sta     $f0bc,x
        sta     $f099,x
        jsr     GetAttackerCharSpritePtr
        lda     #1
        sta     $efcd,x
        rts

; monster attacker
@d02b:  lda     $ed4e
        and     #$10
        beq     @d04d                   ; branch if not enemy character
        lda     #$18
        jsr     LoadWeaponAnim
        jsr     EnemyCharWeaponAnim
        jsr     EnemyCharWeaponAnim
        ldx     #8
        jsr     WaitX
        stz     $f0c9
        jsr     ResetAnimSpritesLarge
        clr_a
        jsr     SetEnemyCharFrame
@d04d:  jmp     WeaponHitAnim

; ------------------------------------------------------------------------------

; [ do enemy character weapon animation ]

EnemyCharWeaponAnim:
@d050:  stz     $f410
        jsl     DrawEnemyCharWeapon
        lda     #$06
        jsr     SetEnemyCharFrame
        inc     $f410
        jsl     DrawEnemyCharWeapon
        lda     #$05
        jsr     SetEnemyCharFrame
        rts

; ------------------------------------------------------------------------------

; [ hit character animation (for magic attacks) ]

MagicHitCharAnim_near:
@d069:  jsl     MagicHitCharAnim
        rts

; ------------------------------------------------------------------------------

; [ weapon hit animation ]

; used for all weapon attacks except character vs. monster ???

WeaponHitAnim:
@d06e:  lda     $34c4
        bmi     @d0e9                   ; branch if monster target

; character target
        clr_ax
@d075:  lda     f:BitOrTbl,x
        cmp     $34c6
        beq     @d086                   ; skip covered targets
        inx
        cpx     #8
        bne     @d075
        clr_ax
@d086:  txa
        sta     $f133                   ; covered target
        stz     $4e
        lda     $34c7
        and     #$08
        bne     @d09b                   ; branch if attack missed
        lda     #$2a
        jsr     PlaySfx
        jsr     CritFlash
@d09b:  lda     $49
        tay
        lda     $f099,y
        sta     $f09e,y

; start of frame loop
@d0a4:  jsr     WaitFrame
        jsr     UpdateHitCharPose
        jsr     GetTargetCharSpritePtr
        lda     $34c7
        and     #$08
        bne     @d0c9                   ; branch if attack missed
        lda     $34c7
        and     #$04                    ; crit flag
        asl2
        sta     $00
        lda     $4e
        and     #$04
        eor     #$04
        clc
        adc     $00
        sta     $efc7,x
@d0c9:  inc     $4e
        lda     $4e
        cmp     #$10
        bne     @d0a4
        clr_a
        sta     $efc7,x
        lda     $49
        tay
        lda     $f09e,y
        sta     $f099,y
        lda     $49
        tax
        clr_a                           ; clear covering char position
        sta     $f316,x
        sta     $f31b,x
        rts

; monster vs. monster
@d0e9:  lda     $34c2
        bpl     @d106                   ; return if character attacker
        lda     $34c7
        and     #$08
        bne     @d106
        jsr     ResetAnimSpritesLarge
        clr_a
        jsr     LoadWeaponAnim
        lda     #$08
        sta     $34c8
        lda     #$08
        jsr     _02d734
@d106:  rts

; ------------------------------------------------------------------------------

; [ update hit character pose (and covering char position) ]

UpdateHitCharPose:
@d107:  lda     $34c6
        beq     @d12f                   ; branch if no targets covered
        lda     $49
        tax
        lda     $f133                   ; covered target
        asl4
        tay
        lda     $efc5,y                 ; x position
        sec
        sbc     #$10
        sta     $f316,x
        lda     $efc6,y                 ; y position
        sta     $f31b,x
        lda     $49
        tay
        lda     #$0e                    ; set covering target pose
        sta     $f099,y
        rts
@d12f:  lda     $34c7
        and     #$08
        bne     @d13e                   ; return if attack missed
        lda     $49
        tay
        lda     #$07                    ; set target pose
        sta     $f099,y
@d13e:  rts

; ------------------------------------------------------------------------------

; [ do weapon animation ]

DoWeaponAnim:
@d13f:  lda     $48
        asl2
        tax
        lda     $f015,x                 ; ignore weapon if toad or mini
        and     #$30
        beq     @d14f
        clr_ax
        stx     $50
@d14f:  stz     $f242
        lda     $f016,x
        and     #$08
        beq     @d15c                   ; branch if not charmed
        inc     $f242
@d15c:  stz     $4e

; start of right/left hand loop
@d15e:  lda     $4e
        tax
        lda     $50,x
        jsr     GetWeaponAnimPropPtr
        lda     f:WeaponAnimProp+3,x
        asl
        tax
        lda     f:WeaponAnimTbl,x
        sta     $00
        lda     f:WeaponAnimTbl+1,x
        sta     $01
        jsr     @d187
        jsr     ResetAnimSpritesLarge
        inc     $4e
        lda     $4e
        cmp     #2                      ; right and left hand
        bne     @d15e
        rts
@d187:  jmp     ($0000)

; ------------------------------------------------------------------------------

; weapon animation jump table
WeaponAnimTbl:
@d18a:  .addr   WeaponAnim_00
        .addr   WeaponAnim_01
        .addr   WeaponAnim_02
        .addr   WeaponAnim_03
        .addr   WeaponAnim_04
        .addr   WeaponAnim_05
        .addr   WeaponAnim_06
        .addr   WeaponAnim_07
        .addr   WeaponAnim_08
        .addr   WeaponAnim_09
        .addr   WeaponAnim_0a
        .addr   WeaponAnim_0b

; ------------------------------------------------------------------------------

; [ weapon animation $06: shuriken ]

WeaponAnim_06:
@d1a2:  stz     $f233
        lda     $4e
        bne     @d1ae
        jsr     ThrowAnimRight
        bra     @d1b1
@d1ae:  jsr     ThrowAnimLeft
@d1b1:  jsr     GetAttackerCharSpritePtr
        stz     $efcd,x
        lda     $efc5,x
        clc
        adc     $efc7,x
        sec
        sbc     #$08
        sta     $f111
        lda     $efc6,x
        clc
        adc     $efc8,x
        sta     $f112
        lda     #$08
        sta     $f115
        lda     $49
        asl
        tay
        lda     $f043,y
        sta     $f113
        lda     $f044,y
        sta     $f114
        jsr     CalcTrajectory
        jsr     ResetAnimSpritesLarge
        stz     $52
@d1eb:  jsr     WaitFrame
        clr_a
        jsr     _02d6ec
        lda     $52
        and     #$01
        asl
        clc
        adc     #$80
        sta     $f0c6
        jsr     UpdateTrajectory
        bcs     @d221
        lda     $f118
        clc
        adc     #$18
        sta     $f0c4
        lda     $f119
        clc
        adc     #$18
        sta     $f0c5
        lda     $34c4
        bpl     @d21c
        inc     $f0c1
@d21c:  inc     $52
        jmp     @d1eb
@d221:  lda     $34c4
        bpl     @d238
        lda     $34c7
        and     #$08
        bne     @d238
        lda     #$a0
        sta     $f0c6
        inc     $f0c1
        jsr     ArrowShurikenAnim
@d238:  rts
        ldx     $f111
        phx
        ldx     $f113
        stx     $f111
        plx
        stx     $f113
        rts

; ------------------------------------------------------------------------------

; [ weapon animation $07: throw ]

WeaponAnim_07:
@d248:  stz     $f233
        lda     $4e
        bne     @d254
        jsr     ThrowAnimRight
        bra     ThrowAnim2
@d254:  jsr     ThrowAnimLeft

; 2nd part of throw animation (weapon flies to target)
ThrowAnim2:
@d257:  lda     $34c4
        bmi     @d25d                   ; return if not monster target
        rts
@d25d:  stz     $f234
        jsr     GetAttackerCharSpritePtr
        stz     $efcd,x
        lda     $efc5,x
        clc
        adc     $efc7,x
        sec
        sbc     #$10
        sta     $f111
        lda     $efc6,x
        clc
        adc     $efc8,x
        sta     $f112
        lda     #$08
        sta     $f115
        lda     $49
        asl
        tay
        lda     $f043,y
        sec
        sbc     #$08
        sta     $f113
        lda     $f044,y
        sec
        sbc     #$08
        sta     $f114
        jsr     CalcTrajectory
        jsr     ResetAnimSpritesLarge
        stz     $52
        lda     #$7c
        jsr     PlaySfx
        jsr     _02d2ce
        jsr     _02d343
        ldx     $f111                   ; reverse trajectory
        phx
        ldx     $f113
        stx     $f111
        plx
        stx     $f113
        lda     #$08
        sta     $f115
        jsr     CalcTrajectory
        jsr     _02d2c7
        jmp     ResetAnimSpritesLarge

; ------------------------------------------------------------------------------

; [  ]

; from target to attacker
ThrowToAttacker:
_02d2c7:
@d2c7:  lda     #1
        sta     $f426
        bra     _d2d1

; from attacker to target
ThrowToTarget:
_02d2ce:
@d2ce:  stz     $f426
_d2d1:  jsl     _02c3e1

; start of frame loop
@d2d5:  jsr     WaitFrame
        lda     #$10
        sta     $f0c2
        lda     #$21
        sta     $f0c3
        lda     #$ff
        sta     $f0c7
        inc     $52
        lda     $52
        and     #$06
        lsr
        tax
        lda     f:_16fd68,x
        sta     $f0c6
        lda     $f233
        bne     @d301                   ; branch if boomerang
        lda     f:_16fd6c,x
        bra     @d305
@d301:  lda     f:_16fd70,x
@d305:  sta     $f0c8
        jsr     UpdateTrajectory
        bcs     @d342
        jsl     _02c404
        lda     $f118
        sta     $f137
        clc
        adc     #$18
        sta     $f0c4
        lda     $f426
        bne     @d32d
        lda     $f119
        sta     $f138
        sec
        sbc     $2b
        bra     @d336
@d32d:  lda     $f119
        sta     $f138
        clc
        adc     $2b
@d336:  clc
        adc     #$18
        sta     $f0c5
        inc     $f0c1
        jmp     @d2d5
@d342:  rts

; ------------------------------------------------------------------------------

; [  ]

_02d343:
@d343:  lda     $34c7
        and     #$08
        bne     @d36f                   ; return if attack missed
        ldx     $f113
        stx     $0344
        lda     #$a0
        sta     $0346
        lda     #$3f
        sta     $0347
        lda     $6cc0
        beq     @d36f
        lda     #$7f
        sta     $0347
        lda     $f113
        eor     #$ff
        sec
        sbc     #$08
        sta     $0344
@d36f:  rts

; ------------------------------------------------------------------------------

; [ weapon animation $08: boomerang ]

WeaponAnim_08:
@d370:  lda     #1
        sta     $f233
        lda     $4e
        bne     @d37e
        jsr     ThrowAnimRight
        bra     @d381
@d37e:  jsr     ThrowAnimLeft
@d381:  jmp     ThrowAnim2

; ------------------------------------------------------------------------------

; [ 1st part of throw animation (character sprite animation) ]

ThrowAnim1:
@d384:  sta     $f0cf
        jsr     GetAttackerCharSpritePtr
        stz     $efcd,x
        stz     $efd3,x
        lda     #$05
        sta     $54
        lda     #$25
        jsr     PlaySfx
@d399:  jsr     WaitFrame
        jsr     GetAttackerCharSpritePtr
        lda     $52
        and     #$01
        bne     @d3a8
        inc     $efd3,x
@d3a8:  inc     $52
        stx     $00
        jsr     UpdateWeaponSprite
        lda     $f233                   ; branch if not boomerang
        beq     @d3c2
        lda     $f242
        bne     @d3bd
        lda     #$3f
        bra     @d3bf
@d3bd:  lda     #$7f
@d3bf:  sta     $f0ce
@d3c2:  ldx     $00
        lda     $efc5,x
        clc
        adc     $efc7,x
        adc     $f0d1
        sta     $f0cc
        lda     $efc6,x
        clc
        adc     $efc8,x
        adc     $f0d2
        sta     $f0cd
        lda     $48
        tax
        lda     f:FirstCharSpriteAboveTbl,x
        clc
        adc     $f0cf
        sta     $f0ca
        inc     $f0c9
        dec     $54
        bne     @d399
        stz     $f0c9
        rts

; ------------------------------------------------------------------------------

; [ weapon animation $09: harp ]

WeaponAnim_09:
@d3f7:  lda     $4e
        bne     @d3fe
        jmp     HarpAnimLeft
@d3fe:  jmp     HarpAnimRight

; ------------------------------------------------------------------------------

; [ harp animation ]

HarpAnim:
@d401:  sta     $f0cf
        jsr     GetAttackerCharSpritePtr
        stz     $efcd,x
        lda     #$10
        sta     $54
        lda     $efc5,x
        clc
        adc     $efc7,x
        sta     $f111
        lda     $efc6,x
        clc
        adc     $efc8,x
        clc
        adc     #$08
        sta     $f112
        lda     #$08
        sta     $f115
        lda     $49
        asl
        tay
        lda     $f043,y
        sta     $f113
        sec
        sbc     #$08
        lda     $f044,y
        sta     $f114
        jsr     CalcTrajectory
        lda     $f0cf
        beq     @d448
        jsr     UpdateTrajectory
@d448:  jsr     ResetAnimSpritesLarge
        jsr     InitPolarAngle
        lda     #$08
        jsr     SetPolarRadius
        lda     #$3a
        jsr     PlaySfx

; start of 1st frame loop (sprites move toward target)
@d458:  jsr     WaitFrame
        inc     $52
        lda     #$10
        sta     $f0c2
        lda     #$21
        sta     $f0c3
        lda     #$fe
        sta     $f0c7
        lda     $52
        and     #$02
        clc
        adc     #$a0
        sta     $f0c6
        lda     #$3f
        sta     $f0c8
        jsr     GetAttackerCharSpritePtr
        lda     #$80
        sta     $f0cb
        lda     #$3f
        sta     $f0ce
        lda     $efc5,x
        clc
        adc     $efc7,x
        sec
        sbc     #$04
        sta     $f0cc
        lda     $efc6,x
        clc
        adc     $efc8,x
        sta     $f0cd
        lda     $f242
        beq     @d4b2
        lda     $f0cc
        clc
        adc     #$08
        sta     $f0cc
        lda     #$7f
        sta     $f0ce
@d4b2:  lda     $48
        tax
        lda     f:FirstCharSpriteAboveTbl,x
        clc
        adc     $f0cf
        sta     $f0ca
        dec     $54
        jsr     UpdateTrajectory
        bcs     @d4f9
        lda     $f118
        clc
        adc     #$18
        sta     $f0c4
        clr_ax
        jsr     CalcPolarY
        sta     $00
        lda     $f133                   ; increment polar angle
        clc
        adc     #$10
        sta     $f133
        lda     $f119
        clc
        adc     #$10
        adc     $00
        sta     $f0c5
        lda     $34c4
        bpl     @d4f3
        inc     $f0c1
@d4f3:  inc     $f0c9
        jmp     @d458
@d4f9:  stz     $52

; start of 2nd frame loop (sprites disappear)
@d4fb:  lda     $34c4
        bpl     @d51b
        lda     $34c7
        and     #$08
        bne     @d51b                   ; branch if attack missed
        inc     $f0c1
        jsr     WaitFrame
        inc     $f0c1
        inc     $52
        lda     $52
        cmp     #$08
        bne     @d4fb
        jsr     _02d732
@d51b:  stz     $f0c9
        jmp     ResetAnimSpritesLarge

; ------------------------------------------------------------------------------

; [ get pointer to weapon animation properties ]

GetWeaponAnimPropPtr:
@d521:  longa
        asl2
        tax
        shorta0
        rts

; ------------------------------------------------------------------------------

; [ weapon animation $04: bow ]

WeaponAnim_04:
@d52a:  lda     $4e
        bne     @d54e
        lda     $50
        jsr     GetWeaponAnimPropPtr
        lda     f:WeaponAnimProp+3,x
        cmp     #$04
        bne     _d553
        lda     $51
        jsr     GetWeaponAnimPropPtr
        lda     f:WeaponAnimProp+3,x
        cmp     #$05
        bne     _d553
        jsr     BowAnimWithArrows
        inc     $4e
        rts
@d54e:  lda     $50
        beq     _d553
        rts

_d553:  clr_a
        sta     $50
        sta     $51
        sta     $4e
        jmp     WeaponAnim_00

; ------------------------------------------------------------------------------

; [ weapon animation $05: unarmed ]

WeaponAnim_05:
@d55d:  lda     $4e
        bne     @d581
        lda     $50
        jsr     GetWeaponAnimPropPtr
        lda     f:WeaponAnimProp+3,x
        cmp     #$05
        bne     _d553
        lda     $51
        jsr     GetWeaponAnimPropPtr
        lda     f:WeaponAnimProp+3,x
        cmp     #$04
        bne     _d553
        jsr     BowAnimNoArrows
        inc     $4e
        rts
@d581:  lda     $50
        beq     _d553
        rts

; ------------------------------------------------------------------------------

; [ flash screen for a critical hit ]

CritFlash:
@d586:  lda     $34c7
        and     #$04
        beq     @d59b
        lda     $ef87
        bne     @d59b
        jsl     FlashScreenYellow
        lda     #$03
        sta     $ef87
@d59b:  rts

; ------------------------------------------------------------------------------

; [ bow animation ]

BowAnim:
@d59c:  sta     $f0cf
        jsr     GetAttackerCharSpritePtr
        stz     $efcd,x
        lda     #$10
        sta     $54
        lda     $efc5,x
        clc
        adc     $efc7,x
        sta     $f111                   ; initial x position
        lda     $efc6,x
        clc
        adc     $efc8,x
        clc
        adc     #$08
        sta     $f112                   ; initial y position
        lda     #$08
        sta     $f115                   ; speed ???
        lda     $49
        asl
        tay
        lda     $f043,y
        sta     $f113                   ; final x position
        sec
        sbc     #$08
        lda     $f044,y
        sta     $f114                   ; final y position
        jsr     CalcTrajectory
        lda     #$16
        jsr     PlaySfx
        lda     $f0cf
        beq     @d5e8
        jsr     UpdateTrajectory
@d5e8:  jsr     ResetAnimSpritesLarge
@d5eb:  jsr     WaitFrame
        inc     $52
        lda     #$10
        sta     $f0c2
        lda     #$21
        sta     $f0c3
        lda     #$ff
        sta     $f0c7
        lda     #$a0
        sta     $f0c6
        lda     #$3f
        sta     $f0c8
        jsr     GetAttackerCharSpritePtr
        lda     $52
        inc
        and     #$fc
        bne     @d617
        lda     #$82
        bra     @d619
@d617:  lda     #$80
@d619:  sta     $f0cb
        lda     #$3f
        sta     $f0ce
        jsr     GetAttackerCharSpritePtr
        lda     $efc5,x
        clc
        adc     $efc7,x
        adc     #$fc
        sta     $f0cc
        lda     $efc6,x
        clc
        adc     $efc8,x
        adc     #$08
        sta     $f0cd
        lda     $f242
        beq     @d64f
        lda     $f0cc
        clc
        adc     #$0c
        sta     $f0cc
        lda     #$7f
        sta     $f0ce
@d64f:  lda     $48
        tax
        lda     f:FirstCharSpriteAboveTbl,x
        clc
        adc     $f0cf
        sta     $f0ca
        dec     $54
        jsr     UpdateTrajectory
        bcs     @d689
        lda     $f118
        clc
        adc     #$18
        sta     $f0c4
        lda     $f119
        clc
        adc     #$18
        sta     $f0c5
        lda     $34c4
        bpl     @d67e
        inc     $f0c1
@d67e:  lda     $f480
        bne     @d686
        inc     $f0c9
@d686:  jmp     @d5eb
@d689:  stz     $f0c9
        lda     $34c4
        bpl     @d6b2
        lda     $34c7
        and     #$08
        bne     @d6b2
        lda     #$a2
        sta     $f0c6
        inc     $f0c1
        lda     $f480
        cmp     #$02
        beq     @d6aa
        jmp     ArrowShurikenAnim
@d6aa:  lda     #$a0
        sta     $f0c6
        jmp     _02d6b3
@d6b2:  rts

; ------------------------------------------------------------------------------

; [  ]

_02d6b3:
@d6b3:  stz     $52
@d6b5:  ldx     #8
        jsr     WaitX
        lda     #$18
        jsr     PlaySfx
        jsr     CritFlash
        inc     $52
        lda     $52
        pha
        and     #$03
        clc
        jsr     _02d6ec
        pla
        ror3
        and     #$40
        ora     #$3f
        sta     $f0c8
        jsr     RandHitPos
        inc     $f0c1
        lda     $52
        cmp     #$04
        bne     @d6b5
        rts

; ------------------------------------------------------------------------------

; [ init hit sprite ]

; projectile (arrow, shuriken, or harp)
_02d6e6:
@d6e6:  inc     $52
        lda     $52
        and     #$07

; all others
_02d6ec:
@d6ec:  clc
        adc     #$10
        sta     $f0c2
        lda     #$21
        sta     $f0c3
        lda     #$ff
        sta     $f0c7
        lda     #$3f
        sta     $f0c8
        rts

; ------------------------------------------------------------------------------

; [ arrow/shuriken hit animation ]

ArrowShurikenAnim:
@d702:  ldx     #8                      ; wait 8 frames before first hit
        stz     $52
@d707:  phx
        jsr     WaitFrame
        plx
        dex
        bne     @d707
        lda     #$18
        jsr     PlaySfx
        jsr     CritFlash
        jsr     _02d6e6
        jsr     RandHitPos
        inc     $f0c1
        ldx     #4                      ; wait 4 frames between hits
        lda     $34c8                   ; number of hits
        cmp     #$10
        bcc     @d72c
        lda     #$10                    ; max 16 hits shown
@d72c:  inc
        cmp     $52
        bne     @d707
        rts

; ------------------------------------------------------------------------------

; [ harp hit animation ??? ]

_02d732:
@d732:  lda     #$18

_02d734:
@d734:  sta     $f49f
        stz     $52
@d739:  jsr     WaitFrame
        jsr     WaitFrame
        lda     $52
        and     #$03
        beq     @d74e
        lda     $f49f
        jsr     PlaySfx
        jsr     CritFlash
@d74e:  jsr     _02d6e6
        lda     #$a0
        sta     $f0c6
        jsr     RandHitPos
        inc     $f0c1
        jsr     WaitFrame
        jsr     WaitFrame
        lda     #$a2
        sta     $f0c6
        inc     $f0c1
        jsr     WaitFrame
        lda     $34c8
        cmp     #$10
        bcc     @d776
        lda     #$10
@d776:  inc
        cmp     $52
        bne     @d739
        rts

; ------------------------------------------------------------------------------

; [ randomize hit sprite position ]

RandHitPos:
@d77c:  lda     $1813
        tay
        lda     $1900,y     ; rng table
        and     #$1f
        clc
        adc     #$08
        sta     $00
        lda     $1904,y     ; this could overflow beyond the rng table
        and     #$1f
        sta     $02
        lda     $49
        asl
        tay
        lda     $f043,y
        clc
        adc     $00
        sta     $f0c4
        lda     $f044,y
        clc
        adc     $02
        sta     $f0c5
        rts

; ------------------------------------------------------------------------------

; [ weapon animation $00:  ]

WeaponAnim_00:
@d7a8:  lda     $50
        ora     $51
        beq     @d7af
        rts
@d7af:  jsr     WeaponAnim_03
        inc     $4e

; ------------------------------------------------------------------------------

; [ weapon animation $03: claw ]

WeaponAnim_03:
@d7b4:  lda     $4e
        and     #$01
        sta     $00
        lda     $48
        tax
        lda     #$05
        clc
        adc     $00
        sta     $f099,x
        lda     $4e
        tax
        lda     $50,x
        jsr     LoadWeaponAnim
        stz     $52
        jsr     GetAttackerCharSpritePtr
        stz     $efcd,x
        lda     #$02
        sta     $efd3,x
        lda     $34c8
        lsr3
        clc
        adc     #$08
        sta     $54
        stz     $f0c9
        stz     $f0c1
        jsr     ResetAnimSpritesLarge
@d7ee:  jsr     WaitFrame
        lda     $52
        and     #$03
        bne     @d7ff
        lda     #$08
        jsr     PlaySfx
        jsr     CritFlash
@d7ff:  lda     $48
        tax
        lda     f:FirstCharSpriteAboveTbl,x
        sta     $f0ca
        lda     #$80
        sta     $f0cb
        lda     #$3f
        sta     $f0ce
        lda     $1813
        tax
        lda     $1900,x                 ; rng table
        and     #$01
        sta     $00
        lda     $1901,x
        and     #$01
        sta     $01
        jsr     GetAttackerCharSpritePtr
        lda     $efc5,x
        sec
        sbc     #$0a
        clc
        adc     $efc7,x
        adc     $00
        sta     $f0cc
        lda     $efc6,x
        clc
        adc     $efc8,x
        adc     $00
        sta     $f0cd
        lda     $f242
        beq     @d859
        lda     $f0cc
        clc
        adc     #$12
        sta     $f0cc
        lda     $f0ce
        eor     #$40
        sta     $f0ce
@d859:  lda     $48
        asl2
        tax
        lda     $f015,x
        and     #$30
        bne     @d868
        inc     $f0c9
@d868:  lda     $52
        and     #$01
        asl
        clc
        adc     #$a0
        sta     $f0c6
        lda     $52
        and     #$01
        bne     @d884
        lda     $52
        and     #$06
        lsr
        jsr     _02d6ec
        jsr     RandHitPos
@d884:  lda     $34c4
        bpl     @d893
        lda     $34c7
        and     #$08
        bne     @d893
        inc     $f0c1
@d893:  dec     $54
        beq     @d89c
        inc     $52
        jmp     @d7ee
@d89c:  stz     $f0c9
        rts

; ------------------------------------------------------------------------------

; [ load weapon palette ]

LoadWeaponPal:
@d8a0:  phx
        longa
        asl4
        tax
        shorta0
        clr_ay
@d8ad:  lda     f:AnimPal,x
        sta     $ef30,y
        iny
        inx
        cpy     #$0010
        bne     @d8ad
        plx
        rts

; ------------------------------------------------------------------------------

; [ load weapon animation properties ]

LoadWeaponAnim:
@d8bd:  longa
        asl2
        tax
        shorta0
        lda     f:WeaponAnimProp+1,x
        jsr     LoadWeaponGfx
        lda     f:WeaponAnimProp+2,x
        sta     $53
        jsr     LoadHitGfx
        lda     f:WeaponAnimProp,x
        jsr     LoadWeaponPal
        lda     f:WeaponAnimProp+3,x
        sta     $4f
        rts

; ------------------------------------------------------------------------------

; [ load hit graphics ]

LoadHitGfx:
@d8e3:  phx
        pha
        tax
        lda     f:WeaponTileOffsetTbl,x
        sta     $26
        lda     #$18
        sta     $28
        jsr     Mult8
        pla
        cmp     #$08
        bcc     @d91e
        ldx     #$1a00
        stx     $f0b7
        lda     #^WeaponGfx
        sta     $f0b9
        lda     #$08
        sta     $f0ba
        sta     $f0bb
        longa
        lda     $2a
        clc
        adc     #.loword(WeaponGfx)
        sta     $f0b5
        shorta0
        jsr     TfrWeaponGfx
        plx
        rts

@d91e:  pha
        cmp     #$04
        bne     @d927
        lda     #$77
        bra     @d941
@d927:  cmp     #$05
        bne     @d92f
        lda     #$79
        bra     @d941
@d92f:  cmp     #$06
        bne     @d937
        lda     #$78
        bra     @d941
@d937:  cmp     #$07
        bne     @d93f
        lda     #$0e
        bra     @d941
@d93f:  lda     #$07
@d941:  sta     $f4a0
        pla
        longa
        lda     $2a
        clc
        adc     #.loword(WeaponGfx)
        tay
        shorta0
        ldx     #$0010
        stx     $00
        ldx     #$dbe6
        lda     #^WeaponGfx
        jsr     Load3bppGfx
        ldx     #$0200
        stx     $00
        lda     #$7e
        ldx     #$dbe6
        ldy     #$1a00
        jsr     ExecTfr
        plx
        rts

; ------------------------------------------------------------------------------

; [ load weapon graphics ]

LoadWeaponGfx:
@d970:  phx
        tax
        lda     f:WeaponGfxOffset,x
        sta     $26
        lda     #$18
        sta     $28
        jsr     Mult8
        ldx     #$1800
        stx     $f0b7
        lda     #^WeaponGfx
        sta     $f0b9
        lda     #$08
        sta     $f0ba
        sta     $f0bb
        longa
        lda     $2a
        clc
        adc     #.loword(WeaponGfx)
        sta     $f0b5
        shorta0
        jsr     TfrWeaponGfx
        plx
        rts

; ------------------------------------------------------------------------------

; [ transfer weapon animation graphics to vram ]

TfrWeaponGfx:
@d9a5:  lda     $efa8
        beq     @d9af
        jsr     WaitFrame
        bra     @d9a5
@d9af:  lda     $f0bb
        tax
        stx     $00
        ldx     #$dbe6
        ldy     $f0b5
        lda     $f0b9
        jsr     Load3bppGfx
        lsr     $f0bb
        lsr     $f0bb
        ldx     #$dbe6
        stx     $f0b5
        ldx     #$0040
        stx     $efad
        stx     $efb6
        lda     #$7e
        sta     $efaf
        sta     $efb8
@d9de:  jsr     WaitFrame
        longa
        lda     $f0b5
        sta     $efa9
        clc
        adc     #$0040
        sta     $efb2
        lda     $f0b7
        sta     $efab
        clc
        adc     #$0100
        sta     $efb4
        lda     $f0b5
        clc
        adc     #$0080
        sta     $f0b5
        lda     $f0b7
        clc
        adc     #$0020
        sta     $f0b7
        shorta0
        dec     $f0ba
        bne     @da2d
        lda     #$08
        sta     $f0ba
        longa
        lda     $f0b7
        clc
        adc     #$0100
        sta     $f0b7
        shorta0
@da2d:  lda     #1
        sta     $efa8
        sta     $efb1
        dec     $f0bb
        bne     @d9de
        jmp     WaitFrame

; ------------------------------------------------------------------------------

; [ load 3bpp graphics ]

;    A: source bank
;   +Y: source address
;   +X: destination address
; +$00: tile count

Load3bppGfx:
@da3d:  sty     $02
        sta     $04
        clr_ay
        longa
@da45:  lda     #8
        sta     $06
@da4a:  lda     [$02],y
        sta     a:$0000,x
        iny2
        inx2
        dec     $06
        bne     @da4a
        lda     #8
        sta     $06
@da5c:  lda     [$02],y
        and     #$00ff
        sta     a:$0000,x
        iny
        inx2
        dec     $06
        bne     @da5c
        dec     $00
        bne     @da45
        shorta0
        rts

; ------------------------------------------------------------------------------
