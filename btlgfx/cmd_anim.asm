
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: cmd_anim.asm                                                         |
; |                                                                            |
; | description: animations for character battle commands                      |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

; [ do command animation ]

DoCmdAnim:
@c033:  sec
        sbc     #$c0
        asl
        tax
        lda     $34c4
        sta     $f485
        lda     f:CmdAnimTbl,x
        sta     $00
        lda     f:CmdAnimTbl+1,x
        sta     $01
        jmp     ($0000)

; ------------------------------------------------------------------------------

; command animation jump table
CmdAnimTbl:
@c04d:  .addr CmdAnim_00
        .addr CmdAnim_01
        .addr CmdAnim_02
        .addr CmdAnim_03
        .addr CmdAnim_04
        .addr CmdAnim_05
        .addr CmdAnim_06
        .addr CmdAnim_07
        .addr CmdAnim_08
        .addr CmdAnim_09
        .addr CmdAnim_0a
        .addr CmdAnim_0b
        .addr CmdAnim_0c
        .addr CmdAnim_0d
        .addr CmdAnim_0e
        .addr CmdAnim_0f
        .addr CmdAnim_10
        .addr CmdAnim_11
        .addr CmdAnim_12
        .addr CmdAnim_13
        .addr CmdAnim_14
        .addr CmdAnim_15
        .addr CmdAnim_16
        .addr CmdAnim_17
        .addr CmdAnim_18
        .addr CmdAnim_19
        .addr CmdAnim_1a
        .addr CmdAnim_1b
        .addr CmdAnim_1c
        .addr CmdAnim_1d
        .addr CmdAnim_1e
        .addr CmdAnim_1f
        .addr CmdAnim_20
        .addr CmdAnim_21
        .addr CmdAnim_22
        .addr CmdAnim_23
        .addr CmdAnim_24
        .addr CmdAnim_25
        .addr CmdAnim_26
        .addr CmdAnim_27

; ------------------------------------------------------------------------------

; [ command animation $10: twin 1 ]

CmdAnim_10:
@c09d:  lda     $3539
        and     #$7f
        tax
        lda     #$0a
        sta     $f099,x
        lda     $353a
        and     #$7f
        tax
        lda     #$0a
        sta     $f099,x
        rts

; ------------------------------------------------------------------------------

; [ unused command animation ]

CmdAnim_0d:
CmdAnim_15:
CmdAnim_1d:
CmdAnim_21:
CmdAnim_22:
CmdAnim_23:
CmdAnim_24:
CmdAnim_26:
CmdAnim_27:
@c0b4:  rts

; ------------------------------------------------------------------------------

; [  ]

_02c0b5:
@c0b5:  and     #$7f
        tax
        lda     #1
        sta     $f0af,x
        stz     $f099,x
        rts

; ------------------------------------------------------------------------------

; [ command animation $20: twin 2 ]

CmdAnim_20:
@c0c1:  lda     $3529
        bne     @c102
        lda     $3539
        bmi     @c0ce
        jsr     _02c0b5
@c0ce:  lda     $353a
        bmi     @c0d6
        jsr     _02c0b5
@c0d6:  lda     $3539
        bmi     @c0ec
        asl4
        tax
@c0e0:  phx
        jsr     WaitFrame
        plx
        lda     $efc5,x
        cmp     #$c0
        bne     @c0e0
@c0ec:  lda     $353a
        bmi     @c102
        asl4
        tax
@c0f6:  phx
        jsr     WaitFrame
        plx
        lda     $efc5,x
        cmp     #$c0
        bne     @c0f6
@c102:  clr_ay
@c104:  lda     $3539,y
        and     #$7f
        sta     $3539,y
        tax
        stz     $f099,x
        iny
        cpy     #$0002
        bne     @c104
        rts

; ------------------------------------------------------------------------------

; [ command animation $16: throw ]

CmdAnim_16:
@c117:  jsr     StepForwardToAttack
        lda     $3580       ; thrown item id
        cmp     #$41
        beq     @c125       ; branch if ninja star
        cmp     #$40
        bne     @c12e       ; branch if not shuriken
@c125:  lda     #$40
        sta     $50
        stz     $51
        jmp     DoItemAnim
@c12e:  lda     #$11
        jsr     LoadWeaponGfx
        lda     $3580
        longa
        asl2
        tax
        shorta0
        lda     f:WeaponAnimProp,x
        jsr     LoadWeaponPal
        lda     f:WeaponAnimProp+1,x
        pha
        jsr     _02c28d
        lda     #$0f
        jsr     SetAttackerPose
        jsr     GetAttackerCharSpritePtr
        lda     $efc5,x
        sta     $f111
        lda     $efc6,x
        sta     $f112
        lda     $49
        asl
        tax
        lda     $f043,x
        and     #$f8
        sta     $f113
        lda     $f044,x
        and     #$f8
        sta     $f114
        lda     #$08
        sta     $f115
        jsr     CalcTrajectory
        lda     $f11c
        lsr3
        tax
        lsr
        sta     $f139
        stx     $28
        ldx     #$0000
        stx     $26
        jsr     Div16
        ldx     $2a
        stx     $f133
        stz     $f135
        stz     $f136
        stz     $f137
        inc     $f139
        lda     #$25
        jsr     PlaySfx
@c1a8:  jsr     WaitFrame
        inc     $f137
        jsr     UpdateTrajectory
        bcs     @c222
        dec     $f139
        bmi     @c1c5
        lda     $f135
        clc
        adc     $f133
        sta     $f135
        jmp     @c1cf
@c1c5:  lda     $f135
        sec
        sbc     $f133
        sta     $f135
@c1cf:  lda     $f135
        tax
        lda     f:AnimSineTbl,x
        sta     $26
        lda     $f11c
        lsr
        sta     $28
        jsr     Mult8
        lda     $48
        tax
        lda     f:FirstCharSpriteAboveTbl,x
        sta     $f0ca
        lda     $f137
        and     #$08
        lsr
        tax
        lda     f:_16fd50,x
        sta     $f0cb
        lda     f:_16fd50+1,x
        clc
        adc     $f118
        sta     $f0cc
        lda     f:_16fd50+2,x
        clc
        adc     $f119
        sec
        sbc     $2b
        sta     $f0cd
        lda     f:_16fd50+3,x
        sta     $f0ce
        lda     #$01
        sta     $f0c9
        jmp     @c1a8
@c222:  lda     $49
        asl
        tax
        lda     $f043,x
        sec
        sbc     #$08
        sta     $f0cc
        lda     $f044,x
        sec
        sbc     #$08
        sta     $f0cd
        clr_ax
        lda     f:_16fd50,x
        sta     $f0cb
        lda     #$01
        sta     $f0c9
        pla
        jsr     LoadWeaponGfx
        lda     #$28
        jsr     PlaySfx
        ldx     #$0014
        stz     $f111
@c255:  jsr     WaitFrame
        inc     $f111
        lda     $f111
        cmp     #$10
        beq     @c276
        tax
        lda     f:_16fd39,x
        clc
        adc     $f0cd
        sta     $f0cd
        lda     #$01
        sta     $f0c9
        jmp     @c255
@c276:  stz     $f0c9
; fallthrough

; ------------------------------------------------------------------------------

; [  ]

_02c279:
@c279:  jsr     _02c2a1
        clr_a
        jmp     SetAttackerPose

; ------------------------------------------------------------------------------

; [  ]

_02c280:
@c280:  jsr     SetAttackerPose
        ldx     #30
        jsr     WaitX
        clr_a
        jmp     SetAttackerPose

; ------------------------------------------------------------------------------

; [  ]

_02c28d:
@c28d:  lda     $48
        tax
        lda     #$01
        sta     $f2bc,x
@c295:  jsr     WaitFrame
        jsr     GetAttackerCharSpritePtr
        lda     $efcf,x
        bne     @c295
        rts

; ------------------------------------------------------------------------------

; [  ]

_02c2a1:
@c2a1:  lda     $48
        tax
        clr_a
        sta     $f2bc,x
        rts

; ------------------------------------------------------------------------------

; [ command animation $1b: defend ]

CmdAnim_1b:
@c2a9:  lda     #$02
        jmp     SetAttackerPose

; ------------------------------------------------------------------------------

; [  ]

_02c2ae:
@c2ae:  phx
        lda     $48
        tax
        jsr     GetObjPtr
        lda     $48
        asl4
        tay
        lda     $2000,x
        and     #$3f
        sta     $efc4,y
        plx
        rts

; ------------------------------------------------------------------------------

; [  ]

_02c2c6:
@c2c6:  sta     $f279
        lda     $34c5
        sta     $f281
        sta     $f284
        sta     $f283
        clr_a
        jmp     _02f524

; ------------------------------------------------------------------------------

; [ command animation $0e: kick ]

CmdAnim_0e:
@c2d9:  lda     #$73
        jsr     PlaySfx
        lda     $34c2
        bpl     @c318

; monster attacker
        lda     #$0c
        jsr     SetEnemyCharFrame
        clr_a
        jsr     _02c2c6
        lda     #$03
        sta     $f281
        inc     $f42e
        inc     $f481
        jsl     EnemyCharKickForward
        clr_a
        sta     $f42e
        sta     $f481
        sta     $f283
        inc     $f40e
        lda     #$0d
        jsr     SetEnemyCharFrame
        jsl     EnemyCharKickBack
        clr_a
        sta     $f40e
        jmp     SetEnemyCharFrame

; character attacker
@c318:  jsr     _02c28d
        jsr     _02c87b
        lda     #$0f
        jsr     SetAttackerPose
        lda     #$10
        sta     $f113
        lda     #$4c
        sta     $f114
        jsr     GetAttackerCharSpritePtr
        lda     $efc5,x
        sta     $f111
        lda     $efc6,x
        sta     $f112
        lda     #$08
        sta     $f115
        jsr     CalcTrajectory
        lda     #$01
        jsr     _02c2c6
        jsr     _02f4f8
        lda     #1
        jsr     SwapMonsterScreen
        lda     #$03
        sta     $f281
        lda     #$01
        sta     $f283
        inc     $f42e
        inc     $f481
        jsr     _02c3c7
        jsr     GetAttackerCharSpritePtr
        lda     $efce,x                 ; toggle h-flip
        eor     #$01
        sta     $efce,x
        lda     $efc5,x
        sta     $f111
        lda     $efc6,x
        sta     $f112
        lda     $f014
        bne     @c38b
        phx
        lda     $48
        tax
        lda     f:CharSpriteDefaultXTbl,x
        plx
        bra     @c394
@c38b:  phx
        lda     $48
        tax
        lda     f:CharSpriteDefaultXTbl+5,x
        plx
@c394:  sta     $f113
        lda     $48
        tax
        lda     f:CharSpriteDefaultYTbl,x
        sta     $f114
        lda     #$08
        sta     $f115
        jsr     CalcTrajectory
        clr_a
        sta     $f481
        sta     $f42e
        sta     $f283
        jsr     SwapMonsterScreen
        jsr     _02c3c7
        lda     $efce,x                 ; toggle h-flip
        eor     #$01
        sta     $efce,x
        jsr     _02c883
        jmp     _02c279

; ------------------------------------------------------------------------------

; [  ]

_02c3c7:
@c3c7:  jsr     WaitFrame
        jsr     UpdateTrajectory
        bcs     @c3e0
        jsr     GetAttackerCharSpritePtr
        lda     $f118
        sta     $efc5,x
        lda     $f119
        sta     $efc6,x
        bra     @c3c7
@c3e0:  rts

; ------------------------------------------------------------------------------

; [  ]

_02c3e1:
@c3e1:  lda     $f11c
        lsr3
        tax
        lsr
        sta     $f139
        stx     $28
        ldx     #$0080
        stx     $26
        jsr     Div16
        ldx     $2a
        stx     $f133
        clr_ax
        stx     $f135
        inc     $f139
        rtl

; ------------------------------------------------------------------------------

; [  ]

_02c404:
@c404:  dec     $f139
        bmi     @c415
        lda     $f135
        clc
        adc     $f133
        sta     $f135
        bra     @c41f
@c415:  lda     $f135
        sec
        sbc     $f133
        sta     $f135
@c41f:  lda     $f135
        tax
        lda     f:AnimSineTbl,x
        sta     $26
        lda     $f11c
        lsr
        sta     $28
        jsr     Mult8
        rtl

; ------------------------------------------------------------------------------

; [  ]

_02c433:
@c433:  jsl     _02c3e1
@c437:  jsr     WaitFrame
        jsr     UpdateTrajectory
        bcs     @c45d
        jsl     _02c404
        jsr     GetAttackerCharSpritePtr
        lda     $f118
        sta     $f137
        sta     $efc5,x
        lda     $f119
        sta     $f138
        sec
        sbc     $2b
        sta     $efc6,x
        bra     @c437
@c45d:  jsr     GetAttackerCharSpritePtr
        lda     $f137
        sta     $efc5,x
        lda     $f138
        sta     $efc6,x
        rts

; ------------------------------------------------------------------------------

; [  ]

_02c46d:
@c46d:  phx
        jsr     ClearTileBuf
        jsr     TfrLeftMonsterTiles
        plx
        rts

; ------------------------------------------------------------------------------

; [ command animation $1e: jump 2 ]

CmdAnim_1e:
@c476:  lda     $34c2
        bpl     @c494

; monster attacker
        jsr     _02c46d
        lda     #$01
        sta     $f40e
        lda     #$0d
        jsr     SetEnemyCharFrame
        jsl     EnemyCharJump
        clr_a
        sta     $f40e
        jsr     SetEnemyCharFrame
        rts

; character attacker
@c494:  jsr     _02c28d
        lda     $49
        asl
        tax
        lda     $f05d,x
        and     #$f8
        sta     $00
        sta     $f133
        lda     $f05e,x
        sec
        sbc     #$18
        and     #$f8
        sta     $f134
        sta     $01
        jsr     GetAttackerCharSpritePtr
        clr_a
        sta     $efc6,x
        lda     $00
        sec
        sbc     $01
        sta     $efc5,x
        bcc     @c4c6
        jsr     _02c2ae
@c4c6:  lda     $efce,x                 ; toggle h-flip
        eor     #$01
        sta     $efce,x
        lda     #$0f
        jsr     SetAttackerPose
@c4d3:  jsr     WaitFrame
        jsr     GetAttackerCharSpritePtr
        lda     $efc5,x
        clc
        adc     #$08
        sta     $efc5,x
        bcc     @c4e7
        jsr     _02c2ae
@c4e7:  lda     $efc6,x
        clc
        adc     #$08
        sta     $efc6,x
        lda     $f134
        sec
        sbc     #$08
        sta     $f134
        bne     @c4d3
        lda     $efc5,x
        sta     $f111
        lda     $efc6,x
        sta     $f112
        lda     $f014
        bne     @c517
        phx
        lda     $48
        tax
        lda     f:CharSpriteDefaultXTbl,x
        plx
        bra     @c520
@c517:  phx
        lda     $48
        tax
        lda     f:CharSpriteDefaultXTbl+5,x
        plx
@c520:  sta     $f113
        pha
        lda     $48
        tax
        lda     f:CharSpriteDefaultYTbl,x
        pha
        sta     $f114
        lda     #$08
        sta     $f115
        jsr     CalcTrajectory
        lda     #$28
        jsr     PlaySfx
        jsr     _02c433
        jsr     GetAttackerCharSpritePtr
        pla
        sta     $efc6,x
        pla
        sta     $efc5,x
        lda     $efce,x                 ; toggle h-flip
        eor     #$01
        sta     $efce,x
        jmp     _02c279

; ------------------------------------------------------------------------------

; [ command animation $1c: appear (show) ]

CmdAnim_1c:
@c555:  jsr     _02c28d
        jsr     GetAttackerCharSpritePtr
        txa
        tay
        lda     $efce,y                 ; don't h-flip
        and     #$fe
        sta     $efce,y
        lda     $48
        tax
        jsr     GetObjPtr
        lda     $2000,x
        and     #$3f
        sta     $efc4,y
        clr_a
        sta     $efd1,y
        sta     $efd3,y
        sta     $efc8,y
        lda     $48
        tax
        lda     #1
        sta     $f0af,x
        lda     #$03
        jsr     SetAttackerPose
@c58a:  jsr     WaitFrame
        lda     $48
        tax
        lda     $f014
        bne     @c59b
        lda     f:CharSpriteDefaultXTbl,x
        bra     @c59f
@c59b:  lda     f:CharSpriteDefaultXTbl+5,x
@c59f:  sta     $04
        jsr     GetAttackerCharSpritePtr
        jsr     UpdateCharAppear_near
        lda     $efc5,x
        cmp     $04
        bne     @c58a
        lda     $48
        tax
        clr_a
        sta     $f0af,x
        jmp     _02c279

; ------------------------------------------------------------------------------

; [ get pointer to character sprite data (at $EFC4) ]

GetAttackerCharSpritePtr:
@c5b8:  lda     $48
_c5ba:  asl4
        tax
        rts

GetTargetCharSpritePtr:
@c5c0:  lda     $49
        bra     _c5ba

; ------------------------------------------------------------------------------

; [ command animation $09: hide (far) ]

HideAnim_far:
@c5c4:  jsr     CmdAnim_09
        rtl

; ------------------------------------------------------------------------------

; [ command animation $1c: appear (far) ]

AppearAnim_far:
@c5c8:  jsr     CmdAnim_1c
        rtl

; ------------------------------------------------------------------------------

; [ command animation $09: hide ]

CmdAnim_09:
@c5cc:  lda     #$0f
        jsr     SetAttackerPose
        ldx     #10
        jsr     WaitX
        lda     #$03
        jsr     SetAttackerPose
        jsr     _02c28d
        jsr     GetAttackerCharSpritePtr
        lda     $efce,x                 ; h-flip sprite
        ora     #$01
        sta     $efce,x
        stz     $efd1,x
        stz     $efd3,x
        stz     $efc8,x
        lda     $48
        tax
        lda     #1
        sta     $f0af,x
@c5fb:  jsr     WaitFrame
        jsr     GetAttackerCharSpritePtr
        tax
        jsr     UpdateCharRun_near
        lda     $efc5,x
        cmp     #$f0
        bcc     @c5fb
        clr_a
        sta     $efc4,x
        lda     $efce,x                 ; don't h-flip sprite
        and     #$fe
        sta     $efce,x
        rts

; ------------------------------------------------------------------------------

; [ command animation $06: jump 1 ]

CmdAnim_06:
@c619:  lda     #$3d
        jsr     CmdSfx
        lda     $34c2
        bmi     @c65f

; character attacker
        jsr     _02c87b
        jsr     StepForwardToAttack
        lda     #$04
        jsr     SetAttackerPose
        ldx     #10
        jsr     WaitX
        lda     #$0c
        jsr     SetAttackerPose
        jsr     _02c28d
@c63c:  jsr     WaitFrame
        jsr     GetAttackerCharSpritePtr
        lda     $efc5,x
        sec
        sbc     #$02
        sta     $efc5,x
        lda     $efc6,x
        sec
        sbc     #$08
        sta     $efc6,x
        cmp     #$f8
        bcc     @c63c
        clr_a
        sta     $efc4,x
        jmp     _02c883

; monster attacker
@c65f:  lda     #$03
        jsr     SetEnemyCharFrame
        ldx     #10
        jsr     WaitX
        lda     #$08
        jsr     SetEnemyCharFrame
        clr_ax
        stx     $f406
        stx     $f408
@c677:  jsr     WaitFrame
        jsl     SetMonsterScroll
        longa
        lda     $f406
        sec
        sbc     #$0002
        sta     $f406
        lda     $f408
        clc
        adc     #$0008
        sta     $f408
        shorta0
        inx
        cpx     #$0010
        bne     @c677
        lda     #$0a
        jmp     SetEnemyCharFrame

; ------------------------------------------------------------------------------

; [ set enemy character animation frame ]

SetEnemyCharFrame:
@c6a2:  sta     $f404
        jsr     LoadMonsterTiles
        ldy     #$6140
        ldx     #$0100
        stx     $00
        lda     #$7e
        ldx     #$6f7d
        jmp     ExecTfr

; ------------------------------------------------------------------------------

; [ command animation $1a: row (change) ]

CmdAnim_1a:
@c6b8:  jsr     ToggleCharRows
        clr_a
        jmp     SetAttackerPose

; ------------------------------------------------------------------------------

; [ command animation $00/$1f: fight/focus 2 ]

CmdAnim_00:
CmdAnim_1f:
@c6bf:  jsr     StepForwardToAttack
        jmp     DoFightAnim

; ------------------------------------------------------------------------------

; [ command animation $08/$0f: sing/brace ]

CmdAnim_08:
CmdAnim_0f:
@c6c5:  jsr     StepForwardToAttack
        lda     #$0b
        jsr     SetAttackerPose
        lda     #1
        jmp     PreMagicAnim

; ------------------------------------------------------------------------------

; [ command animation $02: white magic ]

CmdAnim_02:
@c6d2:  jsr     StepForwardToAttack
        lda     #$0c
        jsr     SetAttackerPose
        lda     #1
        jmp     PreMagicAnim

; ------------------------------------------------------------------------------

; [ command animation $03: black magic ]

CmdAnim_03:
@c6df:  jsr     StepForwardToAttack
        lda     #$0c
        jsr     SetAttackerPose
        clr_a
        jmp     PreMagicAnim

; ------------------------------------------------------------------------------

; [ show character sprites (summon animation) ]

ShowCharSpritesSummon:
@c6eb:  clr_axy
@c6ee:  lda     $f354,y
        sta     $efc4,x
        iny
        txa
        clc
        adc     #$10
        tax
        cpy     #5
        bne     @c6ee
        rts

; ------------------------------------------------------------------------------

; [ hide character sprites (summon animation) ]

HideCharSpritesSummon:
@c700:  clr_axy
@c703:  lda     $efc4,x
        sta     $f354,y
        stz     $efc4,x
        iny
        txa
        clc
        adc     #$10
        tax
        cpy     #5
        bne     @c703
        rts

; ------------------------------------------------------------------------------

; [ command animation $04: summon ]

CmdAnim_04:
@c718:  jsr     StepForwardToAttack
        lda     #$0f
        jsr     SetAttackerPose
        lda     $f474
        bne     _c72a       ; branch if mist dragon vs. golbez
        lda     #2
        jsr     PreMagicAnim
; fallthrough

; ------------------------------------------------------------------------------

; [ command animation $25: hide character sprites for summon animation ]

CmdAnim_25:
_c72a:  jsr     CharSpritesSummonAnim
        lda     #$ff
        sta     $f320
        inc     $f35a
        rts

; ------------------------------------------------------------------------------

; [  ]

_02c736:
@c736:  clr_ax
        stx     $0a
@c73a:  lda     $f235,x
        jsr     ReloadCharGfx
        longa
        lda     $0a
        clc
        adc     #$0400
        sta     $0a
        shorta0
        inx
        cpx     #2
        bne     @c73a
        rts

; ------------------------------------------------------------------------------

; [ flash characters in/out for summon ]

CharSpritesSummonAnim:
@c754:  stz     $f359
@c757:  jsr     WaitVblank
        lda     $f359
        and     #$03
        beq     @c76b
        cmp     #$02
        bne     @c76e
        jsr     ShowCharSpritesSummon
        jmp     @c76e
@c76b:  jsr     HideCharSpritesSummon
@c76e:  inc     $f359
        lda     $f359
        cmp     #$20
        bne     @c757
        rts

; ------------------------------------------------------------------------------

; [ do pre-magic animation ]

; A: pre-magic animation id
;      0: black magic
;      1: white magic (also sing and brace)
;      2: summon magic

PreMagicAnim:
@c779:  pha
        lda     #1
        sta     $f266
        sta     $f267
        stz     $f2a0
        pla
        pha
        jsr     PreMagicAnim1           ; includes black pre-magic animation
        pla
        jsl     PreMagicAnim2           ; includes white and summon animation
        clr_a
        jmp     SetAttackerPose

; ------------------------------------------------------------------------------

; [ command animation $12: cry ]

CmdAnim_12:
@c793:  lda     #$74
        jsr     CmdSfx
        bra     _c7a9

; ------------------------------------------------------------------------------

; [ command animation $11: bluff ]

CmdAnim_11:
@c79a:  lda     #$75
        jsr     CmdSfx
        bra     _c7a9

; ------------------------------------------------------------------------------

; [ command animation $19: regen ]

CmdAnim_19:
@c7a1:  jsr     StepForwardToAttack
        lda     #$24
        jsr     PlaySfx

; ------------------------------------------------------------------------------

; [ command animation $07/$14: recall/search ]

CmdAnim_07:
CmdAnim_14:
_c7a9:  jsr     StepForwardToAttack
        lda     #$0f
        jmp     _02c280

; ------------------------------------------------------------------------------

; [ command animation $01: item ]

CmdAnim_01:
@c7b1:  jsr     StepForwardToAttack
        lda     #$0c
        jsr     _02c280
        jsr     GetNextGfxScriptByte
        tax
        lda     f:ItemMagicAnim,x
        cmp     #$48
        bne     @c7d4
        lda     #$60
        sta     $50
        inc
        sta     $51
        lda     #$01
        sta     $f480
        jmp     DoItemAnim
@c7d4:  cmp     #$4c
        bne     @c7e7
        lda     #$62
        sta     $50
        inc
        sta     $51
        lda     #$02
        sta     $f480
        jmp     DoItemAnim
@c7e7:  lda     f:ItemMagicAnim,x
        beq     @c7f0
        jsr     DoItemMagicAnim
@c7f0:  rts

; ------------------------------------------------------------------------------

; [ command animation: medicine, prayer, protect, steal, ninjutsu ]

CmdAnim_0a:
CmdAnim_0b:
CmdAnim_13:
CmdAnim_17:
CmdAnim_18:
@c7f1:  jsr     StepForwardToAttack
        lda     #$0c
        jmp     _02c280

; ------------------------------------------------------------------------------

; [ set attacker pose ]

SetAttackerPose:
@c7f9:  pha
        lda     $48
        tax
        pla
        sta     $f099,x
        rts

; ------------------------------------------------------------------------------

; [ play command sound effect ]

CmdSfx:
@c802:  pha
        lda     $34c2
        sta     $f485
        pla
        jmp     PlaySfx

; ------------------------------------------------------------------------------

; [ load dark wave graphics ]

InitDarkWaveAnim:
@c80d:  lda     #$08
        ldx     #$000f
        sta     $f457
        jsr     LoadAnimPal
        lda     #$14
        jmp     LoadDarkWaveGfx

; ------------------------------------------------------------------------------

; [ command animation $05: dark wave ]

CmdAnim_05:
@c81d:  inc     $f468
        lda     $34c2
        bpl     @c84d

; monster attacker
        lda     #$18
        jsr     LoadWeaponAnim
        lda     #$0b
        jsr     SetEnemyCharFrame
        ldx     #60
        jsr     WaitX
        lda     #$63
        jsr     CmdSfx
        lda     #$0c
        jsr     SetEnemyCharFrame
        jsr     InitDarkWaveAnim
        jsl     DarkWaveAnim
        stz     $f468
        clr_a
        jmp     SetEnemyCharFrame

; character attacker
@c84d:  jsr     _02c87b
        lda     #$0b
        jsr     SetAttackerPose
        ldx     #30
        jsr     WaitX
        lda     #$63
        jsr     CmdSfx
        lda     #$0f
        jsr     SetAttackerPose
        ldx     #60
        jsr     WaitX
        jsr     InitDarkWaveAnim
        jsl     DarkWaveAnim
        stz     $f468
        jsr     _02c883
        jmp     _02c89c

; ------------------------------------------------------------------------------

; [  ]

_02c87b:
@c87b:  lda     a:$0048
        tax
        inc     $f46d,x
        rts

; ------------------------------------------------------------------------------

; [  ]

_02c883:
@c883:  lda     a:$0048
        tax
        stz     $f46d,x
        rts

; ------------------------------------------------------------------------------

; [ command animation $0c: aim ]

CmdAnim_0c:
@c88b:  lda     #$0f
        jsr     SetAttackerPose
        ldx     #30
        jsr     WaitX
        jsr     StepForwardToAttack
        jsr     DoFightAnim

_02c89c:
@c89c:  clr_a
        jmp     SetAttackerPose

; ------------------------------------------------------------------------------
