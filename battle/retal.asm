
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: retal.asm                                                            |
; |                                                                            |
; | description: monster retaliation                                           |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

; [ do retaliation ]

DoRetal:
@c16c:  lda     $34c4
        bmi     @c172
        rts
@c172:  lda     #$02        ; battle graphics $02: wait one frame
        jsr     ExecBtlGfx
        lda     $34c5
        sta     $38b2
@c17d:  lda     $3877
        bne     @c187
        lda     $38b2
        bne     @c18a
@c187:  jmp     @c401
@c18a:  jsr     FindValidChar
        lda     $a9
        bne     @c187
        lda     #$01
        sta     $390a
        sta     $38b3
        ldx     #5
        lda     $38b2
@c19f:  asl
        bcs     @c1a5
        inx
        bra     @c19f
@c1a5:  txa
        sta     $d2
        sec
        sbc     #$05
        tax
        lda     $38b2
        jsr     ClearBit
        sta     $38b2
        lda     $38aa,x
        beq     @c1d8
        lda     $d2
        jsr     SelectObj
        clr_ay
        ldx     $a6
        lda     $2003,x
        and     #$c0
        bne     @c1d8
        lda     $2004,x
        and     #$3c
        bne     @c1d8
        lda     $2005,x
        and     #$40
        beq     @c1e0
@c1d8:  stz     $390a
        stz     $38b3
        bra     @c17d
@c1e0:  lda     $2050,x
        sta     $38b4,y
        inx
        iny
        cpy     #7
        bne     @c1e0
        clr_ay
        ldx     $a6
@c1f1:  stz     $2050,x
        inx
        iny
        cpy     #7
        bne     @c1f1
        sec
        lda     $d2
        sbc     #$05
        sta     $361c
        sta     $df
        lda     #$3c
        sta     $e1
        jsr     Mult8
        ldx     $e3
        clr_ay
@c210:  lda     $3659,x
        sta     $3839,y
        inx
        iny
        cpy     #$003c
        bne     @c210
        jsr     InitAIGfxScript
        stz     $35be
        lda     $361c
        sta     $df
        lda     #$14
        sta     $e1
        jsr     Mult8
        ldx     $e3
        stx     $35c3
        stx     $35c5
        lda     $361c
        tax
        stx     $393d
        ldx     #$0258
        stx     $393f
        jsr     Mult16
        ldx     $3941
        stx     $35bf
        stx     $35c1
        lda     $361c
        sta     $df
        lda     #$28
        sta     $e1
        jsr     Mult8
        ldx     $e3
        stx     $35c8
        lda     $361c
        tax
        stx     $393d
        ldx     #$00a0
        stx     $393f
        jsr     Mult16
        ldx     $3941
        stx     $35cc
@c277:  lda     $35be
        jsr     Asl_2
        clc
        adc     $35c8
        sta     $35ca
        lda     $35c9
        adc     #$00
        sta     $35cb
        lda     $35be
        tax
        longa
        txa
        jsr     Asl_4
        clc
        adc     $35cc
        sta     $35ce
        shorta0
        ldx     $35c5
        lda     $531f,x
        cmp     #$ff
        beq     @c2f0
        stz     $35c7
@c2ad:  ldx     $35ca
        lda     $53bf,x
        cmp     #$ff
        beq     @c2e0
        clr_ay
        ldx     $35ce
@c2bc:  lda     $54ff,x
        sta     $289c,y
        inx
        iny
        cpy     #4
        bne     @c2bc
        stx     $35ce
        jsr     CheckAICond
        lda     $de
        beq     @c2e5
        inc     $35ca
        inc     $35c7
        lda     $35c7
        cmp     #$04
        bne     @c2ad
@c2e0:  inc     $35be
        bra     @c2f0
@c2e5:  inc     $35c5
        inc     $35c5
        inc     $35be
        bra     @c277
@c2f0:  lda     $de
        beq     @c2fd
        lda     $35be
        dec
        sta     $35be
        bra     @c300
@c2fd:  jmp     @c3d6
@c300:  lda     $361c
        tax
        stx     $393d
        ldx     #$0258
        stx     $393f
        jsr     Mult16
        lda     $35be
        sta     $df
        lda     #$3c
        sta     $e1
        jsr     Mult8
        clc
        lda     $3941
        adc     $e3
        sta     $e3
        lda     $3942
        adc     $e4
        sta     $e4
        ldx     $e3
        clr_ay
@c32f:  lda     $7e59ff,x
        sta     $289c,y
        cmp     #$ff
        beq     @c33e
        inx
        iny
        bra     @c32f
@c33e:  clr_ax
        ldy     $38bb
@c343:  lda     $289c,x
        sta     $3659,y
        cmp     #$ff
        beq     @c37e
        cmp     #$c0
        bcs     @c361
        sta     $365a,y
        phx
        ldx     $a6
        sta     $2052,x
        plx
        lda     #$c2
        sta     $3659,y
        iny
@c361:  cmp     #$e8
        bcc     @c373
        cmp     #$fa
        bcs     @c37a
        inx
        iny
        lda     $289c,x
        sta     $3659,y
        bra     @c37a
@c373:  phx
        ldx     $a6
        sta     $2051,x
        plx
@c37a:  inx
        iny
        bra     @c343
@c37e:  ldx     $38bb
@c381:  lda     $3659,x
        cmp     #$ff
        beq     @c3c9
        cmp     #$f9
        beq     @c3ba
        cmp     #$e8
        bcc     @c3c6
        cmp     #$f0
        bcc     @c3ab
        cmp     #$f4
        bcc     @c3c5
        cmp     #$f8
        bcs     @c3c6
        phx
        pha
        inx
        lda     $3659,x
        sta     $a9
        pla
        jsr     ChangeBattleVar
        plx
        bra     @c3c5
@c3ab:  phx
        pha
        inx
        lda     $3659,x
        sta     $a9
        pla
        jsr     ChangeMonsterStat
        plx
        bra     @c3c5
@c3ba:  phx
        inx
        lda     $3659,x
        sta     $a9
        jsr     GetAITarget
        plx
@c3c5:  inx
@c3c6:  inx
        bra     @c381
@c3c9:  jsr     SetMonsterTarget
        lda     $361c
        tax
        stz     $3879,x
        jsr     _ad78
@c3d6:  lda     $d2
        jsr     SelectObj
        clr_ay
        ldx     $a6
@c3df:  lda     $38b4,y
        sta     $2050,x
        inx
        iny
        cpy     #7
        bne     @c3df
        ldx     $38bb
        clr_ay
@c3f1:  lda     $3839,y
        sta     $3659,x
        inx
        iny
        cpy     #$003c
        bne     @c3f1
        jmp     @c17d
@c401:  stz     $390a
        stz     $38b3
        rts

; ------------------------------------------------------------------------------

; [ find valid character target ]

; $a9: set to 1 if no valid targets found

FindValidChar:
@c408:  clr_axy
        sty     $a9
@c40d:  lda     $3540,y
        bne     @c425       ; branch if not present
        lda     $2003,x
        and     #$c0
        bne     @c425       ; branch if dead
        lda     $2005,x
        and     #$82
        bne     @c425       ; branch if magnetized or jumping
        lda     $2006,x
        bpl     @c430       ; branch if not hiding
@c425:  jsr     NextObj
        iny
        cpy     #5
        bne     @c40d
        inc     $a9
@c430:  rts

; ------------------------------------------------------------------------------

; [ skip a.i. multi-action (normal) ]

SkipMultiAttack:
@c431:  clr_ay
        sty     $a9
        ldx     $38bb
@c438:  lda     $3659,x
        cmp     #$ff
        beq     @c45d
        cmp     #$fc
        beq     @c446
        inx
        bra     @c438
@c446:  inc     $a9
        ldx     $38bb
        lda     #$e1
        sta     $3659,x
        clr_a
        sta     $365a,x
        dec
        sta     $365b,x
        lda     #$fc
        sta     $365b,x
@c45d:  rts

; ------------------------------------------------------------------------------

; [ skip a.i. multi-action (retaliation) ]

SkipMultiAttackRetal:
@c45e:  clr_ay
        sty     $a9
        phx
@c463:  lda     $3839,x
        cmp     #$ff
        beq     @c487
        cmp     #$fc
        beq     @c471
        inx
        bra     @c463
@c471:  inc     $a9
        plx
        lda     #$e1
        sta     $3659,x
        clr_a
        sta     $365a,x
        dec
        sta     $365c,x
        lda     #$fc
        sta     $365b,x
        rts
@c487:  plx
        rts

; ------------------------------------------------------------------------------
