
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: summon.asm                                                           |
; |                                                                            |
; | description: routines for summon and enemy character animations            |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

; [ draw enemy character weapon sprite ]

DrawEnemyCharWeapon:
@f0f2:  lda     $f40f
        bne     @f0f7                   ; this has no effect
@f0f7:  lda     $f410
        asl3
        tax
        clr_ay
@f100:  lda     f:EnemyCharWeaponTbl,x
        sta     $f0ca,y
        inx
        iny
        cpy     #6
        bne     @f100
        inc     $f0c9
        rtl

; ------------------------------------------------------------------------------

; [ update summon and other misc. things at vblank ]

UpdateSummon:
@f112:  jsr     DrawSummon
        jsl     UpdateFinalBGScroll
        lda     $38e8
        beq     @f133                   ; branch if no auto-battle command
        lda     $38e9                   ; auto-battle character
        tay
        lda     $38ea                   ; auto-battle command
        tax
        lda     f:CmdReadyPoseTbl,x
        sta     $f099,y
        sta     $f09e,y
        stz     $38e8
@f133:  lda     $38bd
        beq     @f14a                   ; branch if no song change
        lda     $38be                   ; song id
        sta     $1e01
        lda     #$01                    ; play song
        sta     $1e00
        jsl     ExecSound_ext
        stz     $38bd
@f14a:  lda     $f416
        beq     @f159                   ; branch if no system sound effect
        sta     $1e00
        jsl     ExecSound_ext
        stz     $f416
@f159:  lda     $f412
        beq     @f17e                   ; branch if no game sound effect
        ldx     $f412
        stx     $1e00
        ldx     $f414
        stx     $1e02
        lda     $6cc0
        beq     @f177
        lda     $1e02
        eor     #$ff                    ; reverse pan for back attack
        sta     $1e02
@f177:  jsl     ExecSound_ext
        stz     $f412
@f17e:  stz     $352d
        lda     $f472
        ora     $388b
        bne     @f19a
        lda     f:hSTDCNTRL1L
        ora     f:hSTDCNTRL2L
        and     #$30
        cmp     #$30
        bne     @f19a                   ; branch if not holding r and l buttons
        inc     $352d
@f19a:  stz     $1811
        stz     $1812
        inc     $97
        rtl

; ------------------------------------------------------------------------------

; [ enemy character jump animation ]

EnemyCharJump:
@f1a3:  lda     a:$0049
        asl
        tax
        lda     $f053,x
        and     #$f8
        sta     $f111
        tay
        sty     $00
        sty     $f133
        lda     $f054,x
        and     #$f8
        sta     $f112
        tay
        sty     $f135
        sty     $02
        lsr3
        sta     $f137
        longa
        lda     #$0028
        sec
        sbc     $00
        sec
        sbc     $02
        sta     $f406
        lda     #$0050
        sta     $f408
        shorta
        jsl     SetMonsterScroll
@f1e4:  jsr     WaitFrame_near
        longa
        lda     $f406
        clc
        adc     #$0008
        sta     $f406
        lda     $f408
        sec
        sbc     #$0008
        sta     $f408
        shorta0
        jsl     SetMonsterScroll
        dec     $f137
        bne     @f1e4
        lda     #$38
        sta     $f113
        lda     #$50
        sta     $f114
        lda     #$08
        sta     $f115
        jsl     CalcTrajectory_far
        jsl     _02c3e1
        lda     #$28
        jsl     PlaySfx_far
@f226:  jsr     WaitFrame_near
        jsl     UpdateTrajectory_far
        jsl     _02c404
        lda     $2b
        sta     $2a
        lda     $2b
        bmi     @f23d
        stz     $2b
        bra     @f241
@f23d:  lda     #$ff
        sta     $2b
@f241:  longa
        lda     $f406
        clc
        adc     #$0008
        sta     $f406
        lda     $f408
        sec
        sbc     $f121
        sta     $f408
        shorta0
        lda     $f406
        beq     @f266
        jsl     SetMonsterScrollJump
        jmp     @f226
@f266:  ldx     #0
        stx     $f406
        stx     $f408
        jsl     SetMonsterScroll
        rtl

; ------------------------------------------------------------------------------

; [ enemy character kick (go forward) ]

EnemyCharKickForward:
@f274:  clr_ax
        stx     $f406
        stx     $f408
@f27c:  jsr     WaitFrame_near
        jsl     SetMonsterScroll
        longa
        lda     $f406
        sec
        sbc     #$0008
        sta     $f406
        shorta0
        inx
        cpx     #$0014
        bne     @f27c
        rtl

; ------------------------------------------------------------------------------

; [ enemy character kick (go back) ]

EnemyCharKickBack:
@f299:  clr_ax
@f29b:  jsr     WaitFrame_near
        jsl     SetMonsterScroll
        longa
        lda     $f406
        clc
        adc     #$0008
        sta     $f406
        shorta0
        inx
        cpx     #$0015
        bne     @f29b
        rtl

; ------------------------------------------------------------------------------

; [ draw enemy character ]

DrawEnemyChar:
@f2b8:  lda     $f40e
        beq     @f2c3
        lda     $07
        eor     #$40
        sta     $07
@f2c3:  lda     $f404
        asl
        tax
        lda     f:EnemyCharTilesPtrs,x
        sta     $00
        lda     f:EnemyCharTilesPtrs+1,x
        sta     $01
        lda     #^EnemyCharTilesPtrs
        sta     $02
        ldy     #$0000
        jsr     LoadEnemyCharTiles
        ldy     #$0040
        jsr     LoadEnemyCharTiles
        ldy     #$0080
        jsr     LoadEnemyCharTiles
        rtl

; ------------------------------------------------------------------------------

; [ load enemy character pose tiles ]

LoadEnemyCharTiles:
@f2eb:  ldx     #3
@f2ee:  lda     [$00]
        cmp     #$ff
        bne     @f2fd
        clr_a
        sta     ($04),y
        iny
        lda     #$22
        jmp     @f305
@f2fd:  clc
        adc     $06
        sta     ($04),y
        iny
        lda     $07
@f305:  sta     ($04),y
        iny
        phx
        ldx     $00
        inx
        stx     $00
        plx
        dex
        bne     @f2ee
        rts

; ------------------------------------------------------------------------------

; [  ]

_01f313:
@f313:  jsr     _01f33c
        rtl

; ------------------------------------------------------------------------------

; [  ]

_01f317:
@f317:  stz     $4e
@f319:  jsr     WaitFrame_near
        lda     $4e
        and     #$04
        lsr2
        bne     @f329
        lda     #$34
        jmp     @f32b
@f329:  lda     #$38
@f32b:  sta     $f330
        inc     $4e
        lda     $4e
        cmp     #$10
        bne     @f319
        lda     #$38
        sta     $f330
        rts

; ------------------------------------------------------------------------------

; [  ]

_01f33c:
@f33c:  phx
        lda     $f321
        sec
        sbc     #$08
        sta     $f321
        bne     @f34b
        inc     $f32b
@f34b:  lda     $f32b
        beq     @f365
        lda     $f329
        cmp     #$ff
        beq     @f365
        lda     $f32b
        tax
        lda     f:_0dfd5c,x
        sta     $f329
        inc     $f32b
@f365:  plx
        rts

; ------------------------------------------------------------------------------

; [  ]

_01f367:
@f367:  lda     #$20
        sta     $f0c2
        jsl     _02f9d9
        rts

; ------------------------------------------------------------------------------

; [ goblin summon animation ]

GoblinAnim:
@f371:  jsr     SummonEntry
        jsr     _01f317
        jsr     PlayMagicSfx_near
        jsr     _01f367
        jsr     SummonExit
        rtl

; ------------------------------------------------------------------------------

; [ bomb summon animation ]

BombAnim:
@f381:  jsr     SummonEntry
        jsr     _01f317
        rtl

; ------------------------------------------------------------------------------

; [ chocobo summon animation ]

ChocoboAnim:
@f388:  inc     $f327
        jsr     PlayMagicSfx_near
        jsr     _01f367
        stz     $f326
        stz     $f327
        rtl

; ------------------------------------------------------------------------------

; [ wait X frames ]

SummonWaitX:
@f398:  jsr     WaitFrame_near
        dex
        bne     @f398
        rts

; ------------------------------------------------------------------------------

; [ asura summon animation ]

AsuraAnim:
@f39f:  inc     $f327
        ldx     #$0020
        jsr     SummonWaitX
        stz     $f326
        stz     $f327
        ldx     #$0008
        jsr     SummonWaitX
        rts

; ------------------------------------------------------------------------------

; [ asura summon animation (far) ]

AsuraAnim_far:
@f3b5:  jsr     AsuraAnim
        rtl

; ------------------------------------------------------------------------------

; [ demolish/disrupt animation ]

DemolishAnim:
_01f3b9:
@f3b9:  jsr     ResetAnimSpritesLarge_near
        jsr     PlayMagicSfx_near
        stz     $00
        lda     #$40
        sta     $02
        clr_ax
@f3c7:  lda     $00
        sta     $f133,x
        clc
        adc     #$10
        sta     $00
        pha
        lda     $02
        sta     $f173,x
        clc
        adc     #$10
        sta     $02
        clc
        adc     #$70
        sta     $f177,x
        pla
        clc
        adc     #$70
        sta     $f137,x
        lda     #$18
        sta     $f1b3,x
        sta     $f1b7,x
        sta     $f1f3,x
        sta     $f1f7,x
        inx
        cpx     #4
        bne     @f3c7
        lda     a:$0049
        asl
        tax
        lda     $34c4
        bmi     @f418
        lda     $f053,x
        clc
        adc     #$18
        sta     $f3a8
        lda     $f054,x
        sta     $f3a9
        bra     @f424
@f418:  lda     $f043,x
        sta     $f3a8
        lda     $f044,x
        sta     $f3a9
@f424:  lda     $f3a8
        sec
        sbc     #$08
        sta     $f3a8
        lda     $f3a9
        sec
        sbc     #$08
        sta     $f3a9
@f436:  ldx     #4
        jsr     SummonWaitX
        clr_ax
@f43e:  jsr     CalcPolarX_near
        sta     $f398,x
        jsr     CalcPolarY_near
        sta     $f3a0,x
        lda     #$f0
        jsr     IncPolarAngle_near
        inx
        cpx     #8
        bne     @f43e
        jsr     _01f48e
        jsr     _01f461
        lda     $f1b3
        bne     @f436
        rtl

; ------------------------------------------------------------------------------

; [  ]

_01f461:
@f461:  clr_ax
@f463:  lda     $f1b3,x
        sta     $f1b4,x
        lda     $f1f3,x
        sta     $f1f4,x
        lda     $f1b7,x
        sta     $f1b8,x
        lda     $f1f7,x
        sta     $f1f8,x
        inx
        cpx     #3
        bne     @f463
        dec     $f1b3
        dec     $f1b7
        dec     $f1f3
        dec     $f1f7
        rts

; ------------------------------------------------------------------------------

; [  ]

_01f48e:
@f48e:  clr_axy
@f491:  lda     $f398,x
        clc
        adc     $f3a8
        sta     $0340,y
        lda     $f3a0,x
        clc
        adc     $f3a9
        sta     $0341,y
        lda     f:_0dfe07,x
        sta     $0342,y
        lda     $6cc0
        beq     @f4c4
        lda     $f398,x
        clc
        adc     $f3a8
        eor     #$ff
        sec
        sbc     #$10
        sta     $0340,y
        lda     #$7f
        bra     @f4d0
@f4c4:  lda     $f398,x
        clc
        adc     $f3a8
        sta     $0340,y
        lda     #$3f
@f4d0:  sta     $0343,y
        iny4
        inx
        cpx     #8
        bne     @f491
        rts

; ------------------------------------------------------------------------------

; [ drain/osmose animation ]

DrainAnim:
@f4de:  jsr     ResetAnimSpritesLarge_near
        jsr     PlayMagicSfx_near
        lda     #$84
        sta     $f427
        lda     #$70
        sta     $04
        sta     $06
        jsr     _01f627
        lda     #$04
        sta     $f3ac
        sta     $f3ad
        jsr     _01f676
        lda     $6cc0
        beq     @f506
        lda     #$08
        bra     @f508
@f506:  lda     #$f8
@f508:  sta     $02
        lda     a:$0049
        asl
        tay
        lda     $34c2
        bpl     @f52a
        lda     $f053,y
        clc
        adc     #$18
        adc     $02
        sta     $f111
        lda     $f054,y
        sec
        sbc     #$08
        sta     $f112
        bra     @f53c
@f52a:  lda     $f043,y
        clc
        adc     $02
        sta     $f111
        lda     $f044,y
        sec
        sbc     #$08
        sta     $f112
@f53c:  lda     a:$0048
        asl
        tay
        lda     $34c4
        bpl     @f55a
        lda     $f053,y
        clc
        adc     #$18
        sta     $f113
        lda     $f054,y
        sec
        sbc     #$08
        sta     $f114
        bra     @f56c
@f55a:  lda     $f043,y
        clc
        adc     $02
        sta     $f113
        lda     $f044,y
        sec
        sbc     #$08
        sta     $f114
@f56c:  lda     #$10
        sta     $f115
        jsl     CalcTrajectory_far
        inc     $f428
        lda     $34c2
        and     #$80
        sta     $00
        lda     $34c4
        and     #$80
        cmp     $00
        beq     @f599
@f588:  jsl     UpdateTrajectory_far
        bcs     @f599
        ldx     $f118
        stx     $f429
        jsr     _01f6a7
        bra     @f588
@f599:  rtl

; ------------------------------------------------------------------------------

; [  ]

_01f59a:
@f59a:  jsr     ResetAnimSpritesLarge_near
        clr_ax
        dec
        sta     $f427
@f5a3:  lda     $1900,x                 ; rng table
        jsr     _01f60f
        clr_a
        sta     $eca6,x
        inx
        cpx     #$0040
        bne     @f5a3
        jsr     _01ee8b
        ldx     #$0018
@f5b9:  phx
        stz     $f428
        clr_ay
@f5bf:  lda     $f1b3,y
        lsr5
        and     #$03
        tax
        lda     f:_0dfe0f,x
        sta     $ec66,y
        iny
        cpy     #$0040
        bne     @f5bf
        lda     #$40
        jsr     _01f6ba
        clr_ax
@f5de:  lda     $eca6,x
        bne     @f5f8
        lda     $f1b3,x
        sec
        sbc     #$08
        sta     $f1b3,x
        sta     $f1f3,x
        cmp     #$10
        bcs     @f5f8
        lda     #$01
        sta     $eca6,x
@f5f8:  inx
        cpx     #$0040
        bne     @f5de
        plx
        cpx     #9
        bne     @f608
        jsl     FlashScreenRed
@f608:  dex
        bne     @f5b9
        stz     $ef87
        rtl

; ------------------------------------------------------------------------------

; [  ]

_01f60f:
@f60f:  pha
        tay
        lda     $1900,y                 ; rng table
        sta     $f133,x
        clc
        adc     #$40
        sta     $f173,x
        pla
        and     #$fc
        sta     $f1b3,x
        sta     $f1f3,x
        rts

; ------------------------------------------------------------------------------

; [  ]

_01f627:
@f627:  stz     $f428
        clr_ax
        stz     $00
        lda     #$40
        sta     $02
@f632:  lda     $00
        sta     $f133,x
        clc
        adc     #$20
        sta     $00
        lda     $02
        sta     $f173,x
        clc
        adc     #$20
        sta     $02
        lda     $04
        sta     $f1b3,x
        lda     $06
        sta     $f1f3,x
        inx
        cpx     #$0040
        bne     @f632
        rts

; ------------------------------------------------------------------------------

; [  ]

; unused

_01f657:
@f657:  jsr     _01f6b8
        clr_ax
@f65c:  lda     #$08
        jsr     IncPolarAngle_near
        lda     $f3ac
        jsr     IncPolarRadius_near
        inx
        cpx     #8
        bne     @f65c
        lda     $f1b3
        cmp     $f3ad
        bne     @f657
        rts

; ------------------------------------------------------------------------------

; [  ]

_01f676:
@f676:  jsr     _01f6b8
        clr_ax
@f67b:  lda     #$08
        jsr     IncPolarAngle_near
        lda     $f1b3,x
        beq     @f68c
        sec
        sbc     $f3ac
        sta     $f1b3,x
@f68c:  lda     $f1f3,x
        beq     @f698
        sec
        sbc     $f3ac
        sta     $f1f3,x
@f698:  inx
        cpx     #$0008
        bne     @f67b
        lda     $f1f3
        cmp     $f3ad
        bne     @f676
        rts

; ------------------------------------------------------------------------------

; [  ]

_01f6a7:
@f6a7:  jsr     _01f6b8
        clr_ax
@f6ac:  lda     #$08
        jsr     IncPolarAngle_near
        inx
        cpx     #$0010
        bne     @f6ac
        rts

; ------------------------------------------------------------------------------

; [  ]

_01f6b8:
@f6b8:  lda     #$08

_01f6ba:
@f6ba:  sta     $f42c
        stz     $f42d
        jsr     WaitFrame_near
        clr_ax
@f6c5:  jsr     CalcPolarX_near
        sta     $ebe6,x
        jsr     CalcPolarY_near
        sta     $ec26,x
        inx
        cpx     $f42c
        bne     @f6c5
        clr_ax
        stx     $04
        ldx     #$0040
        stx     $06
        lda     $6cc0
        beq     @f6e9
        lda     #$08
        bra     @f6eb
@f6e9:  lda     #$f8
@f6eb:  sta     $02
        lda     $f428
        beq     @f6fa
        ldx     $f429
        stx     $00
        jmp     _01f75f
@f6fa:  lda     $34c4
        bmi     @f730
        clr_ax
        lda     $34c5
        sta     $0c
@f706:  asl     $0c
        bcc     @f729
        lda     $29c5,x
        cmp     #$ff
        beq     @f729
        txa
        asl
        tay
        lda     $f053,y
        clc
        adc     #$18
        adc     $02
        sta     $00
        lda     $f054,y
        sec
        sbc     #$08
        sta     $01
        jsr     _01f75f
@f729:  inx
        cpx     #5
        bne     @f706
        rts
@f730:  clr_ax
        lda     $34c5
        sta     $0c
@f737:  asl     $0c
        bcc     @f758
        lda     $f123,x
        cmp     #$ff
        beq     @f758
        txa
        asl
        tay
        lda     $f043,y
        clc
        adc     $02
        sta     $00
        lda     $f044,y
        sec
        sbc     #$08
        sta     $01
        jsr     _01f75f
@f758:  inx
        cpx     #8
        bne     @f737
        rts

; ------------------------------------------------------------------------------

; [  ]

_01f75f:
@f75f:  inc     $f42b
        phx
        clr_ax
        ldy     $06
@f767:  lda     $ebe6,x
        bmi     @f773
        clc
        adc     $00
        bcs     @f778
        bra     @f77a
@f773:  clc
        adc     $00
        bcs     @f77a
@f778:  bra     @f794
@f77a:  sta     $0300,y
        lda     $ec26,x
        bmi     @f789
        clc
        adc     $01
        bcs     @f78e
        bra     @f790
@f789:  clc
        adc     $01
        bcs     @f790
@f78e:  bra     @f794
@f790:  cmp     #$80
        bcc     @f79e
@f794:  lda     #$f0
        sta     $0300,y
        sta     $0301,y
        bra     @f7a1
@f79e:  sta     $0301,y
@f7a1:  lda     $f427
        cmp     #$ff
        bne     @f7bc
        lda     $eca6,x
        beq     @f7b7
        lda     #$f0
        sta     $0300,y
        sta     $0301,y
        bra     @f7e0
@f7b7:  lda     $ec66,x
        bra     @f7c4
@f7bc:  txa
        and     #$01
        asl
        clc
        adc     $f427
@f7c4:  sta     $0302,y
        lda     $6cc0
        beq     @f7db
        lda     $0300,y
        eor     #$ff
        sta     $0300,y
        lda     #$7f
        sta     $0303,y
        bra     @f7e0
@f7db:  lda     #$3f
        sta     $0303,y
@f7e0:  inx
        iny4
        cpx     $f42c
        beq     @f7ed
        jmp     @f767
@f7ed:  sty     $06
        plx
        stz     $f42b
        rts

; ------------------------------------------------------------------------------

; [ cockatrice/mindflayer summon animation ]

CockatriceAnim:
@f7f4:  jsr     SummonEntry
        jsr     _01f317
        clr_a
        jsl     DoMagicAnim_far
        jsr     SummonExit
        rtl

; ------------------------------------------------------------------------------

; [ reaction animation ??? ]

_01f803:
@f803:  lda     #$1f
        jsl     DoMagicAnim_far
        clr_ax
@f80b:  lda     $f123,x
        cmp     #$ff
        beq     @f821
        txa
        sta     $34c3
        sta     a:$0048
        phx
        lda     #$1f
        jsl     DoMagicAnim_far
        plx
@f821:  inx
        cpx     #8
        bne     @f80b
        rtl

; ------------------------------------------------------------------------------

; [ draw snow sprites for shiva summon ]

DrawShivaSnowSprites:
@f828:  clr_ax
        ldy     #$0040                  ; use sprites 16-87
@f82d:  lda     $ed06,x
        bne     @f83d
        lda     #$f0
        sta     $0300,y
        sta     $0301,y
        jmp     @f86e
@f83d:  lda     $6cc0
        beq     @f859
        lda     $ebe6,x
        clc
        adc     $ec76,x
        eor     #$ff
        sec
        sbc     #$08
        sta     $0300,y
        lda     #$7f
        sta     $0303,y
        jmp     @f868
@f859:  lda     $ebe6,x
        clc
        adc     $ec76,x
        sta     $0300,y
        lda     #$3f
        sta     $0303,y
@f868:  lda     $ec2e,x
        sta     $0301,y
@f86e:  lda     $1813
        and     #$02
        clc
        adc     #$9c
        sta     $0302,y
        inx
        iny4
        cpx     #$0048                  ; draw 72 sprites
        bne     @f82d
        rts

; ------------------------------------------------------------------------------

; [ shiva summon animation ]

ShivaAnim:
@f884:  jsr     SummonEntry
        jsr     PlayMagicSfx_near
        lda     #$08
        sta     $f326
        jsl     ResetAnimSpritesSmall_far
        clr_ax
        stz     $00
        stz     $02
@f899:  lda     $1900,x     ; rng table
        sta     $ebe6,x
        lda     $02
        sta     $ec2e,x
        clc
        adc     #$08
        sta     $02
        cmp     #$88
        bne     @f8af
        stz     $02
@f8af:  clr_a
        sta     $ec76,x
        sta     $ed06,x
        lda     $1900,x     ; rng table
        sta     $ecbe,x
        inx
        cpx     #$0048
        bne     @f899
        jsr     _01ee8f
        ldx     #$0080
@f8c8:  phx
        jsr     WaitFrame_near
        jsr     DrawShivaSnowSprites
        clr_ax
@f8d1:  lda     $1900,x     ; rng table
        and     #$02
        clc
        adc     #$02
        sta     $00
        lda     $ec2e,x
        clc
        adc     $00
        cmp     #$88
        bcc     @f8e9
        inc     $ed06,x
        clr_a
@f8e9:  sta     $ec2e,x
        inx
        cpx     #$0048
        bne     @f8d1
        clr_ax
@f8f4:  lda     #$18
        sta     $28
        stx     $00
        lda     $ecbe,x
        clc
        adc     #$08
        sta     $ecbe,x
        jsl     CalcSine_far
        ldx     $00
        sta     $ec76,x
        inx
        cpx     #$0048
        bne     @f8f4
        clr_ax
@f914:  lda     $1900,x     ; rng table
        and     #$0f
        sta     $00
        lda     $ebe6,x
        sec
        sbc     $00
        sta     $ebe6,x
        lda     $ec0a,x
        sec
        sbc     #$04
        sta     $ec0a,x
        inx
        cpx     #$0024
        bne     @f914
        plx
        dex
        bne     @f8c8
        stz     $ef87
        jsl     ResetAnimSpritesSmall_far
        jsr     SummonExit
        rtl

; ------------------------------------------------------------------------------

; [ ramuh summon animation ]

RamuhAnim:
@f942:  jsr     SummonEntry
        lda     #$08
        sta     $f326
        clr_a
        jsl     DoMagicAnim_far
        jsr     SummonExit
        rtl

; ------------------------------------------------------------------------------

; [ titan summon animation ]

TitanAnim:
@f953:  jsr     SummonEntry
        lda     #$08
        sta     $f326
        lda     #$07
        jsl     DoMagicAnim_far
        jsr     SummonExit
        rtl

; ------------------------------------------------------------------------------

; [ calculate polar y coordinate ]

CalcPolarY_near:
@f965:  phx
        lda     $f1b3,x
        asl
        sta     $28
        lda     $f133,x
        jsl     CalcSine_far
        plx
        rts

; ------------------------------------------------------------------------------

; [ calculate polar x coordinate ]

CalcPolarX_near:
@f975:  phx
        lda     $f1f3,x
        asl
        sta     $28
        lda     $f173,x
        jsl     CalcSine_far
        plx
        rts

; ------------------------------------------------------------------------------

; [ increase polar angle ]

IncPolarRadius_near:
@f985:  pha
        clc
        adc     $f1f3,x
        sta     $f1f3,x
        pla
        clc
        adc     $f1b3,x
        sta     $f1b3,x
        rts

; ------------------------------------------------------------------------------

; [ increase polar radius ]

IncPolarAngle_near:
@f996:  pha
        clc
        adc     $f173,x
        sta     $f173,x
        pla
        clc
        adc     $f133,x
        sta     $f133,x
        rts

; ------------------------------------------------------------------------------

; [  ]

_01f9a7:
@f9a7:  clr_axy
@f9aa:  lda     $ec66,x
        beq     @f9d0
        lda     $ec26,x
        bne     @f9d0
        jsr     CalcPolarX_near
        clc
        adc     $ebe6,x
        sta     $00
        jsr     CalcPolarY_near
        clc
        adc     #$48
        sta     $02
        lda     $00
        cmp     #$e0
        bcc     @f9d6
        lda     #$01
        sta     $ec26,x
@f9d0:  lda     #$f0
        sta     $00
        sta     $02
@f9d6:  lda     $1813
        and     #$02
        clc
        adc     #$8c
        stz     $f484
        jsr     DrawDarkWaveSprites
        inx
        cpx     #$0040
        bne     @f9aa
        rts

; ------------------------------------------------------------------------------

; [ mist dragon summon animation ]

MistDrgnAnim:
@f9eb:  jsr     SummonEntry
        clr_ax
@f9f0:  lda     $1900,x     ; rng table
        sta     $f133,x
        clc
        adc     #$40
        sta     $f173,x
        stz     $f1b3,x
        lda     #$08
        sta     $f1f3,x
        lda     #$98
        sta     $ebe6,x
        stz     $ec26,x
        stz     $ec66,x
        inx
        cpx     #$0040
        bne     @f9f0
        jsr     ResetAnimSpritesLarge_near
        jsr     _01ee93
        jsr     PlayMagicSfx_near
@fa1e:  jsr     WaitFrame_near
        jsr     _01f9a7
        lda     $ebe6
        sec
        sbc     #$06
        sta     $ebe6
        lda     #$01
        sta     $ec66
        clr_ax
@fa34:  lda     #$10
        jsr     IncPolarAngle_near
        inx
        cpx     #$0040
        bne     @fa34
        lda     $f1b3
        clc
        adc     #$02
        sta     $f1b3
        ldx     #$003e
@fa4b:  lda     $ebe6,x
        sta     $ebe7,x
        lda     $ec66,x
        sta     $ec67,x
        lda     $f1b3,x
        sta     $f1b4,x
        lda     $f1f3,x
        sta     $f1f4,x
        dex
        cpx     #$ffff
        bne     @fa4b
        clr_ax
@fa6b:  lda     $ec26,x
        beq     @fa1e
        inx
        cpx     #$0040
        bne     @fa6b
        stz     $ef87
        jsr     SummonExit
        rtl

; ------------------------------------------------------------------------------

; [ ifrit summon animation (no effect) ]

IfritAnim:
@fa7d:  rtl

; ------------------------------------------------------------------------------

; [ sylph summon animation ]

SylphAnim:
@fa7e:  stz     $f326
        stz     $f485
        jsr     PlayMagicSfx_near
        ldx     #$0078
@fa8a:  jsr     WaitFrame_near
        lda     $f326
        inc
        and     #$0f
        sta     $f326
        dex
        bne     @fa8a
        lda     #$10
        sta     $f326
        rtl

; ------------------------------------------------------------------------------

; [ odin summon animation ]

OdinSummonAnim:
@fa9f:  jsr     PlayMagicSfx_near
        inc     $f327
        ldx     #$0012
        jsr     SummonWaitX
        stz     $f327
        ldx     #$0020
@fab1:  jsr     WaitFrame_near
        jsr     _01f33c
        dex
        bne     @fab1
        lda     #$62
        sta     f:hBG1SC
        clr_a
        sta     $f133
        lda     #$80
        sta     $f134
@fac9:  jsr     WaitFrame_near
        lda     $f133
        cmp     #$10
        bcc     @fae7
        lda     #$02
        sta     f:hCGSWSEL
        sta     f:hTS
        lda     #$41
        sta     f:hCGADSUB
        jsl     _02f2cf
@fae7:  stz     $02
        lda     #$03
        sta     $06
@faed:  lda     $f133
        jsl     _02e9f3
        lda     $f134
        jsl     _02e9f3
        dec     $06
        bne     @faed
        inc     $f133
        inc     $f134
        lda     $f133
        cmp     #$40
        bne     @fac9
        lda     #$1e
        sta     f:hTM
        inc     $f483
        rtl

; ------------------------------------------------------------------------------

; [  ]

_01fb16:
@fb16:  stz     $f446
        bra     _fb20

_01fb1b:
@fb1b:  lda     #$01
        sta     $f446
_fb20:  clr_axy
@fb23:  lda     f:_0dfe13,x
        sta     $0342,y
        inx
        cpx     #$000c
        bne     @fb32
        clr_ax
@fb32:  lda     $6cc0
        beq     @fb40
        lda     $f446
        beq     @fb45
@fb3c:  lda     #$7f
        bra     @fb47
@fb40:  lda     $f446
        beq     @fb3c
@fb45:  lda     #$3f
@fb47:  sta     $0343,y
        iny4
        cpy     #$0120
        bne     @fb23
        clr_axy
@fb56:  lda     f:_0dfe1f,x
        sta     $ebe6,y
        lda     f:_0dfe1f+1,x
        sta     $ec76,y
        clr_a
        sta     $ec77,y
        inx2
        cpx     #$0018
        bne     @fb71
        clr_ax
@fb71:  lda     $f446
        sta     $ebe7,y
        iny2
        cpy     #$0090
        bne     @fb56
        clr_axy
@fb81:  lda     #$0c
        sta     $02
@fb85:  lda     $f446
        bne     @fb90
        lda     f:_0dfe41,x
        bra     @fb94
@fb90:  lda     f:_0dfe3c,x
@fb94:  sta     $00
        lda     $ebe6,y
        clc
        adc     $00
        sta     $ebe6,y
        lda     f:_0dfe37,x
        sta     $00
        lda     $ec76,y
        clc
        adc     $00
        sta     $ec76,y
        iny2
        dec     $02
        bne     @fb85
        inx
        cpx     #6
        bne     @fb81
        clr_ax
@fbbc:  lda     f:$001900,x   ; rng table
        sta     $ed06,x
        inx
        cpx     #6
        bne     @fbbc
        jsl     InitPolarAngle_far
        clr_ax
@fbcf:  lda     $1900,x     ; rng table
        and     #$07
        clc
        adc     #$04
        sta     $f1b3,x
        sta     $f1f3,x
        txa
        asl5
        jsr     IncPolarAngle_near
        inx
        cpx     #8
        bne     @fbcf
        stz     $f1b3
        stz     $f1f3
        rts

; ------------------------------------------------------------------------------

; [  ]

_01fbf3:
@fbf3:  lda     $1813
        tax
        lda     $1901,x
        and     #$03
        sta     $01
        clr_axy
@fc01:  lda     $6cc0
        beq     @fc15
        lda     $f446
        beq     @fc1a
@fc0b:  lda     $ebe6,x
        eor     #$ff
        sta     $0340,y
        bra     @fc20
@fc15:  lda     $f446
        beq     @fc0b
@fc1a:  lda     $ebe6,x
        sta     $0340,y
@fc20:  lda     $ec76,x
        clc
        adc     $01
        adc     $ec77,x
        sta     $0341,y
        inx2
        iny4
        cpx     #$0078
        bne     @fc01
        clr_ay
@fc39:  tya
        lsr3
        tax
        lda     $ebe7,y
        lsr
        ror     $0504,x
        sec
        ror     $0504,x
        iny2
        cpy     #$0078
        bne     @fc39
        rts

; ------------------------------------------------------------------------------

; [  ]

_01fc51:
@fc51:  clr_ay
@fc53:  lda     $ed06,y
        and     #$04
        inc
        sta     $02
        stz     $03
        tya
        tax
        lda     f:_0dfe46,x
        tax
        longa
        lda     #12
        sta     $00
@fc6b:  lda     $02
        sta     $04
@fc6f:  dec     $ebe6,x
        dec     $04
        bne     @fc6f
        inx2
        dec     $00
        bne     @fc6b
        shorta0
        tya
        tax
        lda     #$02
        jsr     IncPolarAngle_near
        lda     $f133,x
        ora     #$80
        sta     $f133,x
        jsr     CalcPolarY_near
        pha
        tya
        tax
        lda     f:_0dfe46,x
        tax
        lda     #12
        sta     $00
        pla
@fc9e:  sta     $ec77,x
        inx2
        dec     $00
        bne     @fc9e
        lda     $ed06,y
        inc
        sta     $ed06,y
        iny
        cpy     #6
        bne     @fc53
        rts

; ------------------------------------------------------------------------------

; [ magic animation $24 (no effect) ]

_01fcb5:
@fcb5:  rtl

; ------------------------------------------------------------------------------

; [ odin boss attack animation ]

OdinBossAnim:
_01fcb6:
@fcb6:  clr_ax
        stx     $f406
        stx     $f408
        lda     #$03
        jsl     PlaySfx_far
@fcc4:  jsr     WaitFrame_near
        jsl     SetMonsterScroll
        longa
        lda     $f406
        sec
        sbc     #$0008
        sta     $f406
        tax
        shorta0
        cpx     #$ffa8
        bne     @fcc4
        jsl     SetMonsterScroll
        lda     #$2c
        jsl     _02cc5e
        ldx     #$0010
        jsr     SummonWaitX
        lda     #$2a
        jsl     _02cc5e
        ldx     $34c4
        stx     $f466
        jsl     MagicHitCharAnim
        stz     $38e2
@fd03:  jsr     WaitFrame_near
        jsl     SetMonsterScroll
        longa
        lda     $f406
        clc
        adc     #$0008
        sta     $f406
        pha
        shorta0
        plx
        bne     @fd03
        jsl     SetMonsterScroll
        rtl

; ------------------------------------------------------------------------------

; [  ]

_01fd22:
@fd22:  jsr     PlayMagicSfx_near
        jsr     ResetAnimSpritesLarge_near
        jsr     _01fb16
        jsr     _01fc51
        ldx     #$0040
@fd31:  phx
        jsr     WaitFrame_near
        inc     $f42b
        jsr     _01fc51
        jsr     _01fbf3
        stz     $f42b
        plx
        dex
        bne     @fd31
        ldx     $34c4
        stx     $f466
        jsl     MagicHitCharAnim
        stz     $38e2
        rtl

; ------------------------------------------------------------------------------

; [ leviathan summon animation ]

LeviathanAnim:
@fd53:  jsr     PlayMagicSfx_near
        jsr     ResetAnimSpritesLarge_near
        jsr     _01fb1b
        jsr     _01fc51
        jsr     _01ee8f
        ldx     #$0080
@fd65:  phx
        jsr     WaitFrame_near
        inc     $f42b
        jsr     _01fc51
        jsr     _01fbf3
        stz     $f42b
        jsl     UpdateShakeMonstersOnly
        plx
        dex
        bne     @fd65
        jsr     ResetAnimSpritesLarge_near
        stz     $ef87
        jsl     DisableShakeBG_far
        rtl

; ------------------------------------------------------------------------------

; [ bahamut summon animation ]

BahamutAnim:
@fd88:  ldx     #$0020
        jsr     SummonWaitX
        lda     #$08
        sta     $f326
        jsr     ResetAnimSpritesLarge_near
        jsr     PlayMagicSfx_near
        jsl     MegaflareAnim
        jsr     ResetAnimSpritesLarge_near
        rtl

; ------------------------------------------------------------------------------

; [ summon entry (move forward 8 pixels) ]

SummonEntry:
@fda1:  ldx     #8
@fda4:  jsr     WaitFrame_near
        dec     $f321
        dec     $f321
        dex
        bne     @fda4
        rts

; ------------------------------------------------------------------------------

; [ summon exit (move back 8 pixels) ]

SummonExit:
@fdb1:  ldx     #8
@fdb4:  jsr     WaitFrame_near
        inc     $f321
        inc     $f321
        dex
        bne     @fdb4
        rts

; ------------------------------------------------------------------------------

; [ animated summon entry ??? ]

; unused

_01fdc1:
@fdc1:  ldx     #8
@fdc4:  jsr     WaitFrame_near
        dec     $f321
        dec     $f321
        lda     $f326
        clc
        adc     #$04
        sta     $f326
        dex
        bne     @fdc4
        stz     $f326
        rts

; ------------------------------------------------------------------------------

; [ animated summon exit ??? ]

; unused

_01fddd:
@fddd:  ldx     #8
@fde0:  jsr     WaitFrame_near
        inc     $f321
        inc     $f321
        lda     $f326
        clc
        adc     #$04
        sta     $f326
        dex
        bne     @fde0
        stz     $f326
        rts

; ------------------------------------------------------------------------------

; [ draw summon sprites ]

DrawSummon:
@fdf9:  lda     $f320
        beq     @fe02
        cmp     #$ff
        bne     @fe03
@fe02:  rts
@fe03:  ldx     #$0016
        lda     #$aa                    ; large sprites
@fe08:  sta     $0500,x
        inx
        cpx     #$0020
        bne     @fe08
        lda     $f327
        beq     @fe19
        inc     $f326
@fe19:  lda     $f326
        lsr3
        and     #$03
        sta     $0e
        lda     $f325
        asl2
        clc
        adc     $0e
        tax
        lda     f:_13fa9d,x
        sta     $f328
        clr_ax
        stx     $f32e
        lda     $f32c
        beq     @fe6b
        lda     $f1b3
        asl
        sta     $1e
        lda     $f133
        clc
        adc     $f32d
        sta     $f133
        jsl     GetFloatOffset_far
        sta     $f32f
        lda     $f1f3
        asl
        sta     $1e
        lda     $f173
        clc
        adc     $f32d
        sta     $f173
        jsl     GetFloatOffset_far
        sta     $f32e
@fe6b:  lda     $f328
        asl
        tax
        lda     f:SummonFramePtrs,x
        sta     $1c
        lda     f:SummonFramePtrs+1,x
        sta     $1d
        lda     #^SummonFramePtrs
        sta     $1e
        lda     $f322
        clc
        adc     $f32f
        sta     $23
        lda     $f324
        sta     $21
        stz     $0e
        ldy     #$0160

; start of sprite loop
@fe93:  lda     $f323
        sta     $20
        lda     $f321
        clc
        adc     $f32e
        sta     $22
        lda     $f329
        sta     $f32a
@fea7:  jsl     _03f7e8
        bcc     @fee1
        sta     $0302,y
        asl     $f32a
        bcs     @fee1
        lda     $6cc0
        bne     @fec9
        lda     $22
        sta     $0300,y
        lda     $10
        eor     #$40
        sta     $0303,y
        jmp     @fed8
@fec9:  lda     $22
        eor     #$ff
        sec
        sbc     #$10
        sta     $0300,y
        lda     $10
        sta     $0303,y
@fed8:  lda     $23
        sta     $0301,y
        iny4
@fee1:  lda     $22
        clc
        adc     #$10
        sta     $22
        dec     $20
        bne     @fea7
        lda     $23
        clc
        adc     #$10
        sta     $23
        dec     $21
        bne     @fe93
        rts

; ------------------------------------------------------------------------------

; [  ]

_01fef8:
@fef8:  clr_ayx
@fefb:  phx
        tya
        tax
        jsr     CalcPolarX_near
        plx
        clc
        adc     f:_0df82c,x
        sta     $f3b0,x
        phx
        tya
        tax
        jsr     CalcPolarY_near
        plx
        clc
        adc     f:_0df82c+1,x
        sta     $f3b1,x
        phx
        tya
        tax
        lda     #$0c
        jsr     IncPolarAngle_near
        lda     $f1b3
        beq     @ff2b
        lda     #$ff
        jsr     IncPolarRadius_near
@ff2b:  plx
        iny
        inx2
        cpx     #$0010
        bne     @fefb
        rtl

; ------------------------------------------------------------------------------
