
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: ai.asm                                                               |
; |                                                                            |
; | description: monster a.i scripts                                           |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

; [ action type 1: choose monster attack ]

GetMonsterAttack:
@b3b6:  jsr     InitAIGfxScript
        jsr     ClearGfxScriptBuf
        sec
        lda     $d2
        sbc     #$05
        sta     $361c
        lda     $3877
        beq     @b3d6
        lda     $d2
        cmp     $3601
        beq     @b3d3
        jmp     @b68c
@b3d3:  jmp     @b517
@b3d6:  jsr     InitGfxScript
        ldx     $a6
        stz     $2050,x
        stz     $2052,x
        stz     $2055,x
        stz     $2056,x
        stz     $2053,x
        stz     $2054,x
        lda     #$e1
        sta     $2051,x
        lda     $2004,x
        and     #$0c
        bne     @b422
        lda     $2070,x
        bmi     @b422       ; branch if a boss
        lda     $3583
        cmp     $202f,x
        bcc     @b422
        jsr     Rand
        ldx     $a6
        cmp     $2029,x
        bcs     @b422
        lda     $38e5
        and     #$01
        bne     @b422
        lda     #$e4
        sta     $2051,x
        jsr     InitAIDelay
        jmp     @b68c
@b422:  ldx     $a6
        lda     $2004,x
        and     #$04
        beq     @b44c                   ; branch if not berserk
        lda     #$05
        sta     $ab
        ldx     $a6
        stz     $2051,x
        jsr     GetDefaultAITarget
        lda     $2051,x
        cmp     #$e1
        beq     @b446
        lda     #$c0
        sta     $2051,x
        sta     $3839
@b446:  jsr     InitAIDelay
        jmp     @b68c
@b44c:  stz     $35be
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
@b4a3:  lda     $35be
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
        lda     $397f,x
        beq     @b517
        stz     $35c7
@b4d7:  ldx     $35ca
        lda     $3a1f,x
        cmp     #$ff
        beq     @b517
        clr_ay
        ldx     $35ce
@b4e6:  lda     $3b5f,x
        sta     $289c,y
        inx
        iny
        cpy     #4
        bne     @b4e6
        stx     $35ce
        jsr     CheckAICond
        lda     $de
        beq     @b50c
        inc     $35ca
        inc     $35c7
        lda     $35c7
        cmp     #$04
        bne     @b4d7
        beq     @b517
@b50c:  inc     $35c5
        inc     $35c5
        inc     $35be
        bra     @b4a3
@b517:  lda     $361c
        tax
        lda     $35be
        cmp     $3604,x
        beq     @b52c
        sta     $3604,x
        jsr     GetAIScriptPtr
        stz     $3877
@b52c:  lda     $3877
        bne     @b582
        clr_ax
        stx     $3875
        lda     $361c
        asl
        tax
        lda     $360c,x
        sta     $35c1
        lda     $360d,x
        sta     $35c2
        ldx     $35c1
        clr_ay
        lda     $405f,x
        cmp     #$ff
        bne     @b55a
        lda     #$e1
        sta     $361d,y
        bra     @b56c
@b55a:  lda     $405f,x
        inx
        sta     $361d,y
        cmp     #$fe
        beq     @b571
        cmp     #$ff
        beq     @b56c
        iny
        bra     @b55a
@b56c:  jsr     GetAIScriptPtr
        bra     @b582
@b571:  stx     $a9
        lda     $361c
        asl
        tax
        lda     $a9
        sta     $360c,x
        lda     $aa
        sta     $360d,x
@b582:  clr_ay
        ldx     $3875
@b587:  lda     $361d,x
        cmp     #$c0
        bcs     @b5a1
        sta     $383a,y
        phx
        ldx     $a6
        sta     $2052,x
        plx
        lda     #$c2
        sta     $3839,y
        iny
        inx
        bra     @b5c7
@b5a1:  sta     $3839,y
        inx
        cmp     #$fa
        bcs     @b5b7
        cmp     #$e8
        bcc     @b5c7

; get command parameter ($e8-$f9)
        iny
        lda     $361d,x
        sta     $3839,y
        inx
        bra     @b5c7
@b5b7:  cmp     #$fb
        beq     @b5cd
        cmp     #$fc
        beq     @b5cd
        cmp     #$fe
        beq     @b5ca
        cmp     #$ff
        beq     @b5ca
@b5c7:  iny
        bra     @b587
@b5ca:  stz     $3877
@b5cd:  stx     $3875
        clr_ax
        stx     $cb
        ldx     $cb
@b5d6:  lda     $3839,x
        cmp     #$fd
        beq     @b5ed
        cmp     #$fc
        beq     @b606
        cmp     #$fb
        beq     @b61f
        cmp     #$e8
        bcc     @b613
        inx2
        bra     @b5d6
@b5ed:  inc     $3877
        lda     $d2
        sta     $3601
        stz     $3602
        ldx     $a6
        lda     $2060,x
        sta     $3878
        clr_a
        sta     $2060,x
        bra     @b61f
@b606:  dec     $3877
        ldx     $a6
        lda     $3878
        sta     $2060,x
        bra     @b61f
@b613:  inx
        lda     $3839,x
        cmp     #$fc
        beq     @b606
        cmp     #$ff
        bne     @b613
@b61f:  clr_ax
@b621:  lda     $3839,x
        cmp     #$fa
        bcs     @b62d
        cmp     #$e8
        bcc     @b630
        inx
@b62d:  inx
        bra     @b621
@b630:  ldx     $a6
        sta     $2051,x
        clr_ax
        stx     $80
@b639:  ldx     $80
        lda     $3839,x
        cmp     #$ff
        beq     @b67f
        cmp     #$f9
        beq     @b670
        cmp     #$e8
        bcc     @b67b
        cmp     #$fb
        bcs     @b67b
        cmp     #$f0
        bcs     @b65f

; $e8-$ef: change monster stat
        pha
        inx
        lda     $3839,x
        sta     $a9
        pla
        jsr     ChangeMonsterStat
        bra     @b679

; $f4-$f7: change battle variable
@b65f:  cmp     #$f4
        bcc     @b679
        pha
        inx
        lda     $3839,x
        sta     $a9
        pla
        jsr     ChangeBattleVar
        bra     @b679

; $f9: choose target
@b670:  inx
        lda     $3839,x
        sta     $a9
        jsr     GetAITarget
@b679:  inc     $80
@b67b:  inc     $80
        bra     @b639

; $ff: end of script
@b67f:  jsr     SetMonsterTarget
        jsr     InitAIDelay
        lda     $361c
        tax
        stz     $3879,x
@b68c:  jmp     CopyGfxScript

; ------------------------------------------------------------------------------

; [ set monster target ]

SetMonsterTarget:
@b68f:  lda     $361c
        tax
        lda     $3883,x
        beq     @b6a6                   ; branch if no "targeting" target
        stz     $3883,x
        ldx     $a6
        sta     $2054,x
        stz     $2053,x
        jmp     @b74b
@b6a6:  lda     $361c
        tax
        lda     $3879,x
        beq     @b6b2
        jmp     @b74b
@b6b2:  ldx     $a6
        lda     $2051,x
        cmp     #$c2
        beq     @b6be                   ; branch if using white magic
        jmp     @b744
@b6be:  lda     $2052,x
        cmp     #$31
        bcs     @b6e2                   ; branch if not using a spell
        tax
        stx     $e5
        ldx     #.loword(AttackProp)
        stx     $80
        lda     #^AttackProp
        sta     $82
        lda     #$06
        jsr     LoadArrayItem
@b6d6:  lda     $289c
        bpl     @b6de
        jmp     @b744
@b6de:  lda     #8                      ; random monster target
        bra     @b746
@b6e2:  cmp     #$5f
        bcs     @b716
        sec
        sbc     #$30
        ldx     $a6
        sta     $2052,x
        tax
        stx     $e5
        ldx     #.loword(AttackProp)
        stx     $80
        lda     #^AttackProp
        sta     $82
        lda     #$06
        jsr     LoadArrayItem
@b6ff:  ldx     $a6
        lda     $289c
        bmi     @b70d
        lda     #$ff
        sta     $2053,x
        bra     @b74b
@b70d:  lda     #$f8
        ldx     $a6
        sta     $2054,x
        bra     @b74b
@b716:  tax
        stx     $e5
        ldx     #.loword(AttackProp)
        stx     $80
        lda     #^AttackProp
        sta     $82
        lda     #$06
        jsr     LoadArrayItem
        lda     $289c
        and     #$e0
        bne     @b73d
        lda     $361c
        tax
        clr_a
        jsr     SetBit
        ldx     $a6
        sta     $2053,x
        bra     @b74b
@b73d:  and     #$40
        bne     @b6ff
        jmp     @b6d6
@b744:  lda     #5                      ; random character target
@b746:  sta     $ab
        jsr     GetDefaultAITarget
@b74b:  rts

; ------------------------------------------------------------------------------

; [ get pointer to monster script ]

GetAIScriptPtr:
@b74c:  lda     $35be       ; monster script id
        sta     $df
        lda     #$3c
        sta     $e1
        jsr     Mult8
        lda     $361c
        asl
        tax
        clc
        lda     $35bf
        adc     $e3
        sta     $360c,x
        lda     $35c0
        adc     $e4
        sta     $360d,x
        rts

; ------------------------------------------------------------------------------

; [ change monster stat ]

ChangeMonsterStat:
@b76f:  ldx     $a6
; $e8: creature type
        cmp     #$e8
        bne     @b77d
        lda     $a9
        sta     $2040,x
        jmp     @b7fe
; $e9: attack
@b77d:  cmp     #$e9
        bne     @b799
        lda     $a9
        jsr     LoadMonsterStat
        lda     $291c
        sta     $201b,x
        lda     $291d
        sta     $201c,x
        lda     $291e
        sta     $201d,x
        rts
; $ea: defense
@b799:  cmp     #$ea
        bne     @b7b5
        lda     $a9
        jsr     LoadMonsterStat
        lda     $291c
        sta     $2028,x
        lda     $291d
        sta     $2029,x
        lda     $291e
        sta     $202a,x
        rts
; $eb: mag.def
@b7b5:  cmp     #$eb
        bne     @b7d1
        lda     $a9
        jsr     LoadMonsterStat
        lda     $291c
        sta     $2022,x
        lda     $291d
        sta     $2024,x
        lda     $291e
        sta     $2024,x
        rts
; $ec: speed modifier
@b7d1:  cmp     #$ec
        bne     @b7d8
        jmp     @b7ff       ; apply speed modifier
; $ed: strong/immune elements
@b7d8:  cmp     #$ed
        bne     @b7ea
        lda     $a9
        sta     $2025,x
        bpl     @b7fe       ; branch if not nullified
        sta     $2026,x
        stz     $2025,x
        rts
; $ee: intellect
@b7ea:  cmp     #$ee
        bne     @b7f4
        lda     $a9
        sta     $2017,x
        rts
; weak/very elements elements
@b7f4:  lda     $a9
        bpl     @b7fb       ; branch if not very weak
        sta     $2021,x
@b7fb:  sta     $2020,x
@b7fe:  rts
; apply speed modifier
@b7ff:  phx
        lda     $a9
        sta     $393d
        stz     $393e
        lda     $2060,x     ; multiply by base timer duration
        sta     $393f
        lda     $2061,x
        sta     $3940
        jsr     Mult16
        ldx     $3941
        stx     $393d
        ldx     #100      ; multiply by 100
        stx     $393f
        jsr     Mult16
        ldx     $3941
        stx     $3945
        ldx     #1000      ; divide by 1000
        stx     $3947
        jsr     Div16
        lda     $3949
        ora     $394a
        bne     @b840
        inc     $3949       ; min 1
@b840:  plx
        lda     $a9
        bmi     @b859       ; branch if negative speed
        clc
        lda     $2060,x     ; add to base timer duration
        adc     $3949
        sta     $2060,x
        lda     $2061,x
        adc     $394a
        sta     $2061,x
        rts
@b859:  sec
        lda     $2060,x
        sbc     $3949
        sta     $2060,x
        lda     $2061,x
        sbc     $394a
        sta     $2061,x
        bcs     @b876
        lda     #$01
        sta     $2060,x
        stz     $2061,x
@b876:  rts

; ------------------------------------------------------------------------------

; [ change battle variable ]

; $a9: aavvvvvv
;        a: 0 = add, 1 = subtract, 2/3 = set
;        v: value

ChangeBattleVar:
@b877:  sec
        sbc     #$f4
        tay
        lda     $a9
        pha
        and     #$3f
        sta     $a9
        pla
; add
        and     #$c0
        bne     @b88f
        clc
        lda     $a9
        adc     $35f3,y
        bra     @b89d
; subtract
@b88f:  and     #$80
        bne     @b89b
        sec
        lda     $35f3,y
        sbc     $a9
        bra     @b89d
; set
@b89b:  lda     $a9
@b89d:  sta     $35f3,y
        rts

; ------------------------------------------------------------------------------

; [ choose monster target ]

GetAITarget:
@b8a1:  stx     $88
        lda     $361c
        tax
        inc     $3879,x
        ldx     $a6
        stz     $2053,x
        stz     $2054,x
        lda     $a9
        cmp     #$16
        bcc     @b8d0
        sec
        sbc     #$16
        asl
        tax
        lda     f:AITargetTbl,x   ; monster target jump table
        sta     $a9
        lda     f:AITargetTbl+1,x
        sta     $aa
        lda     #$03
        sta     $ab
        jml     [$00a9]

; monster target $00-$15: character id
@b8d0:  clr_axy
@b8d3:  lda     $3540,y
        bne     @b8f4       ; branch if not present
        lda     $2000,x
        and     #$1f
        cmp     $a9
        bne     @b8f4       ; branch if not the right character
        lda     $2003,x
        and     #$c0
        bne     @b8fd       ; branch if dead or stone
        lda     $2005,x
        and     #$82
        bne     @b8fd       ; branch if magnetized or jumping
        lda     $2006,x
        bpl     @b900       ; branch if not hiding
@b8f4:  jsr     NextObj
        iny
        cpy     #5
        bne     @b8d3
@b8fd:  jmp     SkipAITurn
@b900:  ldx     $a6
        sec
@b903:  ror     $2054,x     ; set target
        dey
        bpl     @b903
        rts

; ------------------------------------------------------------------------------

; [ monster target $16: self ]

AITarget_16:
@b90a:  lda     $361c
        tay
        ldx     $a6
        sec
@b911:  ror     $2053,x
        dey
        bpl     @b911
        rts

; ------------------------------------------------------------------------------

; [ monster target $17: all monsters ]

AITarget_17:
@b918:  ldx     $a6
        lda     #$ff
        sta     $2053,x
        rts

; ------------------------------------------------------------------------------

; [ monster target $18: all monsters (not self) ]

AITarget_18:
@b920:  lda     $29cd
        dec
        bne     @b929
        jmp     SkipAITurn
@b929:  lda     $361c
        tax
        lda     #$ff
        jsr     ClearBit
        ldx     $a6
        sta     $2053,x
        rts

; ------------------------------------------------------------------------------

; [ monster target $19: all monster type 1 ]

AITarget_19:
@b938:  lda     #0
        jmp     TargetMonsterTypeAll

; ------------------------------------------------------------------------------

; [ target all monsters of a given type ]

; A: monster type

TargetMonsterTypeAll:
@b93d:  sta     $a9
        clr_ax
        stx     $ab
@b943:  lda     $29b5,x
        cmp     $a9
        bne     @b951
        lda     $ab
        jsr     SetBit
        sta     $ab
@b951:  inx
        cpx     #8
        bne     @b943
        ldx     $a6
        lda     $ab
        bne     @b960
        jmp     SkipAITurn
@b960:  sta     $2053,x
        rts

; ------------------------------------------------------------------------------

; [ monster target $1a: all monster type 2 ]

AITarget_1a:
@b964:  lda     #1
        jmp     TargetMonsterTypeAll

; ------------------------------------------------------------------------------

; [ monster target $1b: all monster type 3 ]

AITarget_1b:
@b969:  lda     #2
        jmp     TargetMonsterTypeAll

; ------------------------------------------------------------------------------

; [ monster target $1c: all front row characters ]

AITarget_1c:
@b96e:  jsr     GetFrontRowChars
        ldx     $a6
        lda     $ab
        bne     @b97a
        jmp     SkipAITurn
@b97a:  sta     $2054,x
        rts

; ------------------------------------------------------------------------------

; [ get front row characters ]

; $ab: front row characters mask (out)

GetFrontRowChars:
@b97e:  clr_axy
        stx     $ab
@b983:  lda     $3540,x
        bne     @b9a7       ; branch if not present
        lda     $2003,y
        and     #$c0
        bne     @b9a7       ; branch if dead or stone
        lda     $2005,y
        and     #$82
        bne     @b9a7       ; branch if magnetized or jumping
        lda     $2006,y
        bmi     @b9a7       ; branch if hiding
        lda     $2001,y
        bmi     @b9a7       ; branch if back row
        lda     $ab
        jsr     SetBit
        sta     $ab
@b9a7:  longa
        tya
        clc
        adc     #$0080
        tay
        shorta0
        inx
        cpx     #5
        bne     @b983
        rts

; ------------------------------------------------------------------------------

; [ monster target $1d: all back row characters ]

AITarget_1d:
@b9b9:  jsr     GetBackRowChars
        ldx     $a6
        lda     $ab
        bne     @b9c5
        jmp     SkipAITurn
@b9c5:  sta     $2054,x
        rts

; ------------------------------------------------------------------------------

; [ get back row characters ]

GetBackRowChars:
@b9c9:  clr_axy
        stx     $ab
@b9ce:  lda     $3540,x
        bne     @b9f2
        lda     $2003,y
        and     #$c0
        bne     @b9f2
        lda     $2005,y
        and     #$82
        bne     @b9f2
        lda     $2006,y
        bmi     @b9f2
        lda     $2001,y
        bpl     @b9f2
        lda     $ab
        jsr     SetBit
        sta     $ab
@b9f2:  longa
        tya
        clc
        adc     #$0080
        tay
        shorta0
        inx
        cpx     #5
        bne     @b9ce
        rts

; ------------------------------------------------------------------------------

; [ monster target $1e: paralyzed monster ]

AITarget_1e:
@ba04:  lda     #$20
        sta     $ad
        stz     $ae
        stz     $af
        stz     $b0
        jmp     GetMonsterWithStatus

; ------------------------------------------------------------------------------

; [ get monster with status ]

GetMonsterWithStatus:
@ba11:  ldy     #$0280
        clr_ax
        stx     $ab
        stx     $a9
@ba1a:  clc
        lda     $a9
        adc     #$05
        tax
        lda     $3540,x
        bne     @ba47       ; branch if not present
        lda     $2003,y
        and     $af
        bne     @ba3a       ; branch if status 1 matches
        lda     $2004,y
        and     $ad
        bne     @ba3a       ; branch if status 2 matches
        lda     $2006,y
        and     $ae
        beq     @ba47       ; branch if status 3 doesn't match
@ba3a:  ldx     $a9
        lda     $ab
        jsr     SetBit
        sta     $ab
        lda     $b0
        beq     @ba5a
@ba47:  longa        ; next monster
        tya
        clc
        adc     #$0080
        tay
        shorta0
        inc     $a9
        lda     $a9
        cmp     #$08
        bne     @ba1a
@ba5a:  ldx     $a6
        lda     $ab
        bne     @ba63
        jmp     SkipAITurn
@ba63:  sta     $2053,x
        rts

; ------------------------------------------------------------------------------

; [ monster target $1f: sleeping monster ]

AITarget_1f:
@ba67:  lda     #$10
        sta     $ad
        stz     $ae
        stz     $af
        stz     $b0
        jmp     GetMonsterWithStatus

; ------------------------------------------------------------------------------

; [ monster target $20: charmed monster ]

AITarget_20:
@ba74:  lda     #$08
        sta     $ad
        stz     $ae
        stz     $af
        stz     $b0
        jmp     GetMonsterWithStatus

; ------------------------------------------------------------------------------

; [ monster target $21: critical monster ]

AITarget_21:
@ba81:  stz     $ad
        lda     #$01
        sta     $ae
        stz     $af
        stz     $b0
        jmp     GetMonsterWithStatus

; ------------------------------------------------------------------------------

; [ monster target $22: random character or monster ]

AITarget_22:
@ba8e:  lda     #$0c
        sta     $b0
        lda     #$00
        sta     $af
        dec
        sta     $ad
        jmp     RandAITarget

; ------------------------------------------------------------------------------

; [ choose a random target within a give range ]

; $af: min target slot
; $b0: max target slot

RandAITarget:
@ba9c:  lda     $af
        tax
        lda     $b0
        jsr     RandXA
        cmp     $ad
        beq     @ba9c
        sta     $a9
        tax
        lda     $3540,x
        bne     @ba9c
        txa
        sta     $df
        lda     #$80
        sta     $e1
        jsr     Mult8
        ldx     $e3
        lda     $2003,x
        and     #$c0
        bne     @ba9c
        lda     $2005,x
        and     #$82
        bne     @ba9c
        lda     $2006,x
        bmi     @ba9c
        lda     $a9
        cmp     #5
        bcs     @bae1
        tax
        clr_a
        jsr     SetBit
        ldx     $a6
        sta     $2054,x
        bra     @baee
@bae1:  sec
        sbc     #5
        tax
        clr_a
        jsr     SetBit
        ldx     $a6
        sta     $2053,x
@baee:  rts

; ------------------------------------------------------------------------------

; [ monster target $23: random character or monster (not self) ]

AITarget_23:
@baef:  lda     #$00
        sta     $af
        lda     #$0c
        sta     $b0
        lda     $d2
        sta     $ad
        jmp     RandAITarget

; ------------------------------------------------------------------------------

; [ monster target $24: random monster ]

AITarget_24:
@bafe:  lda     #$05
        sta     $af
        lda     #$0c
        sta     $b0
        lda     #$ff
        sta     $ad
        jmp     RandAITarget

; ------------------------------------------------------------------------------

; [ monster target $25: random monster (not self) ]

AITarget_25:
@bb0d:  lda     $29cd
        dec
        bne     @bb16
        jmp     SkipAITurn
@bb16:  lda     #$05
        sta     $af
        lda     #$0c
        sta     $b0
        lda     $d2
        sta     $ad
        jmp     RandAITarget

; ------------------------------------------------------------------------------

; [ monster target $26: random front row character ]

AITarget_26:
@bb25:  jsr     GetFrontRowChars
        lda     $ab
        bne     @bb2f
        jmp     SkipAITurn
@bb2f:  jsr     RandChar
        tax
        lda     $ab
        jsr     CheckBit
        beq     @bb2f
        clr_a
        jsr     SetBit
        ldx     $a6
        sta     $2054,x
        rts

; ------------------------------------------------------------------------------

; [ monster target $27: random back row character ]

AITarget_27:
@bb44:  jsr     GetBackRowChars
        lda     $ab
        bne     @bb4e
        jmp     SkipAITurn
@bb4e:  jsr     RandChar
        tax
        lda     $ab
        jsr     CheckBit
        beq     @bb4e
        clr_a
        jsr     SetBit
        ldx     $a6
        sta     $2054,x
        rts

; ------------------------------------------------------------------------------

; [ monster target $28: all characters ]

AITarget_28:
@bb63:  ldx     $a6
        lda     #$f8
        sta     $2054,x
        rts

; ------------------------------------------------------------------------------

; [ monster target $29: all dead monsters ]

AITarget_29:
@bb6b:  stz     $ad
        stz     $ae
        lda     #$80
        sta     $af
        sta     $b0
        jmp     GetMonsterWithStatus

; ------------------------------------------------------------------------------

; unused
@bb78:  rts

; ------------------------------------------------------------------------------

; [ skip a turn ]

SkipAITurn:
@bb79:  lda     $38b3
        beq     @bb97                   ; branch if not retaliating

; retaliation
        jsr     SkipMultiAttack
        lda     $a9
        bne     @bbae
        ldx     $38bb
        lda     #$e1                    ; do nothing
        sta     $3659,x
        clr_a
        sta     $365a,x
        dec
        sta     $365b,x
        bra     @bbae

; not a retaliation
@bb97:  ldx     $88
        inx
        jsr     SkipMultiAttackRetal
        lda     $a9
        bne     @bbae
        lda     #$e1                    ; do nothing
        sta     $3839,x
        clr_a
        sta     $383a,x
        dec
        sta     $383b,x
@bbae:  lda     #$e1                    ; do nothing
        ldx     $a6
        sta     $2051,x
        rts

; ------------------------------------------------------------------------------

; monster ai target jump table
AITargetTbl:
@bbb6:  .addr   AITarget_16
        .addr   AITarget_17
        .addr   AITarget_18
        .addr   AITarget_19
        .addr   AITarget_1a
        .addr   AITarget_1b
        .addr   AITarget_1c
        .addr   AITarget_1d
        .addr   AITarget_1e
        .addr   AITarget_1f
        .addr   AITarget_20
        .addr   AITarget_21
        .addr   AITarget_22
        .addr   AITarget_23
        .addr   AITarget_24
        .addr   AITarget_25
        .addr   AITarget_26
        .addr   AITarget_27
        .addr   AITarget_28
        .addr   AITarget_29

; ------------------------------------------------------------------------------

; [ init monster action delay ]

InitAIDelay:
@bbde:  lda     #$02        ; immediate
        sta     $d6
        lda     $d2
        jsr     CalcTimerDur
        lda     #$03        ; action timer
        jsr     SetTimer
        lda     #$08
        sta     $2a06,x     ; use battle command when timer expires
        rts

; ------------------------------------------------------------------------------

; [ init monster graphics script ]

InitAIGfxScript:
@bbf2:  sec
        lda     $d2
        sbc     #$05
        sta     $df
        lda     #$3c
        sta     $e1
        jsr     Mult8
        ldy     #$003c
        ldx     $e3
        stx     $38bb
        lda     #$ff
@bc0a:  sta     $3659,x
        inx
        dey
        bne     @bc0a
        rts

; ------------------------------------------------------------------------------

; [ clear graphics script buffer ]

ClearGfxScriptBuf:
@bc12:  ldx     #$003b
        lda     #$ff
@bc17:  sta     $3839,x
        dex
        bpl     @bc17
        rts

; ------------------------------------------------------------------------------

; [ copy monster graphic script from buffer ]

CopyGfxScript:
@bc1e:  ldx     $38bb
        clr_ay
@bc23:  lda     $3839,y
        sta     $3659,x
        inx
        iny
        cpy     #$003c
        bne     @bc23
        rts

; ------------------------------------------------------------------------------

; [ choose default a.i. target (if berserk or no valid target) ]

GetDefaultAITarget:
@bc31:  lda     $ab
        cmp     #8
        beq     @bc83

; choose character target
        clr_axy
        stx     $a9
@bc3c:  lda     $3540,y
        bne     @bc58
        lda     $2003,x
        and     #$c0
        bne     @bc58
        lda     $2005,x
        and     #$82
        bne     @bc58
        lda     $2006,x
        bmi     @bc58
        inc     $a9
        bra     @bc61
@bc58:  jsr     NextObj
        iny
        cpy     #5
        bne     @bc3c
@bc61:  lda     $a9
        bne     @bc83
        clr_ax
        jsr     SkipMultiAttackRetal
        lda     $a9
        bne     @bc82
        lda     #$e1
        sta     $3839
        clr_a
        sta     $383a
        dec
        sta     $383b
        lda     #$e1
        ldx     $a6
        sta     $2051,x
@bc82:  rts

; choose monster target
@bc83:  stz     $ad
        lda     $ab
        cmp     #$08
        bne     @bc8d
        inc     $ad
@bc8d:  ldx     #1
        lda     $ab
        jsr     RandXA
        dec
        sta     $a9
        lda     $ad
        beq     @bca3
        clc
        lda     $a9
        adc     #$05
        bra     @bca5
@bca3:  lda     $a9
@bca5:  asl
        tay
        lda     $29eb,y
        beq     @bc8d
        lda     $a9
        tay
        iny
        ldx     $a6
        stz     $2054,x
        stz     $2053,x
        lda     $ab
        cmp     #$08
        beq     @bcc6
        sec
@bcbf:  ror     $2054,x
        dey
        bne     @bcbf
        rts
@bcc6:  sec
@bcc7:  ror     $2053,x
        dey
        bne     @bcc7
        rts

; ------------------------------------------------------------------------------
