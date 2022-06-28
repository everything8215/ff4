
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: fight.asm                                                            |
; |                                                                            |
; | description: fight command                                                 |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

; [ battle command $00: fight ]

Cmd_00:
DoFightCmd:
@c489:  stz     $34c7       ; clear attack graphics flags
        stz     $38e1
        clr_ax
        stx     $2896       ; clear action script pointer
        lda     $cd
        bmi     @c4a7       ; branch if monster attacker

; character attacker
        lda     #$f8        ; display text
        sta     $33c6
        lda     #$04        ; damage numerals
        sta     $33c7
        jsr     DecArrows
        bra     @c4fb

; monster attacker
@c4a7:  lda     $3601
        cmp     #$ff
        beq     @c4be
        clr_ax
@c4b0:  lda     $33c2,x
        cmp     #$fc
        beq     @c4be
        cmp     #$ff
        beq     @c4fb
        inx
        bra     @c4b0
@c4be:  clr_axy
@c4c1:  lda     $33c2,x
        sta     $289c,y
        cmp     #$ff
        beq     @c4cf
        inx
        iny
        bra     @c4c1
@c4cf:  clr_axy
@c4d2:  lda     $289c,x
        sta     $33c2,y
        cmp     #$ff
        beq     @c4fb
        cmp     #$c0        ; insert damage numeral display after attack
        beq     @c4e8
        cmp     #$c6
        beq     @c4e8
        cmp     #$de
        bne     @c4f7
@c4e8:  iny
        sty     $2896
        lda     #$f8        ; display text
        sta     $33c2,y
        iny
        lda     #$04        ; damage numerals
        sta     $33c2,y
@c4f7:  inx
        iny
        bra     @c4d2
@c4fb:  stz     $c7
        stz     $38fc
        lda     $269c       ; hit rate
        sta     $38f8
        lda     $2683
        and     #$02
        beq     @c510       ; branch if not blind
        lsr     $38f8       ; halve hit rate
@c510:  lda     $2681
        bpl     @c526       ; branch if in front row
        lda     $2681
        and     #$20
        bne     @c526       ; branch if no back row penalty
        lda     $2685
        and     #$02
        bne     @c526       ; branch if jumping
        lsr     $38f8       ; halve hit rate
@c526:  lda     $cd
        and     #$7f
        bne     @c545       ; branch if attacker not in 1st slot
        lda     $38f8
        sta     $df
        lda     #$05        ; hit rate +25%
        sta     $e1
        jsr     Mult8
        lsr     $e4
        ror     $e3
        lsr     $e4
        ror     $e3
        lda     $e3
        sta     $38f8
@c545:  lda     $2701
        bpl     @c55b       ; branch if in front row
        lda     $2681
        and     #$20
        bne     @c55b
        lda     $2685
        and     #$02
        bne     @c55b
        lsr     $38f8       ; halve hit rate
@c55b:  lda     $38f8
        sta     $38fa       ; set attack rate
        lda     $269b       ; attack multiplier
        sta     $38fb
        jsr     CalcHits
        lda     $38fd
        sta     $38f8       ; set number of hits
        lda     $ce
        bpl     @c579
        and     #$7f
        clc
        adc     #$05
@c579:  jsr     SelectObj
        lda     $2706
        and     #$10
        bne     @c59b       ; branch if target has barrier status
        lda     $2706
        and     #$0c
        beq     @c59f       ; branch if target doesn't have image status

; image
        lsr
        and     #$04        ; remove 1 image charge
        sta     $a9
        ldx     $a6
        lda     $2006,x
        and     #$f3
        ora     $a9
        sta     $2006,x

; barrier
@c59b:  lda     #$ff        ; 255 hits defended
        bra     @c5ea
@c59f:  lda     $2729       ; defense rate
        sta     $38f9
        lda     $2703
        and     #$02
        beq     @c5af       ; branch if target is not blind
        lsr     $38f9       ; halve defense rate
@c5af:  lda     $ce
        and     #$7f
        bne     @c5ce       ; branch if target not in 1st slot
        lda     $38f9
        sta     $df
        lda     #$05        ; defense rate +25%
        sta     $e1
        jsr     Mult8
        lsr     $e4
        ror     $e3
        lsr     $e4
        ror     $e3
        lda     $e3
        sta     $38f9
@c5ce:  lda     $38f9
        sta     $38fa
        lda     $2728       ; defense multiplier
        sta     $38fb
        lda     $2703
        and     #$30
        beq     @c5e4       ; branch if target is not toad or mini
        stz     $38fb       ; zero defense multiplier
@c5e4:  jsr     CalcHits
        lda     $38fd
@c5ea:  sta     $38f9       ; set number of hits defended
        sec
        lda     $38f8
        sbc     $38f9       ; subtract from number of hits
        sta     $34c8
        sta     $38fc
        beq     @c5fe
        bcs     @c623

; zero net hits
@c5fe:  clr_a
        sta     $38fc       ; zero hits
        inc
        sta     $34c8       ; 1 hit ???
        lda     $ce
        sta     $a9
        bpl     @c611       ; branch if target is a character
        and     #$7f
        clc
        adc     #$05
@c611:  asl
        tax
        lda     $34d4,x
        ora     $34d5,x
        bne     @c620       ; branch if target already took damage
        lda     #$40
        sta     $34d5,x     ; set miss flag
@c620:  jmp     @c7fb

; nonzero net hits
@c623:  lda     $ce
        bpl     @c62c       ; branch if target is a character
        lda     $3881
        bne     @c5fe       ; branch if monsters are invincible ???
@c62c:  lda     $34c7
        ora     #$80
        sta     $34c7
        ldx     $a6
        lda     $2004,x
        sta     $a9
        and     #$f7        ; clear charm status
        sta     $2004,x
        lda     #$02        ; set damage multipliers to 1x
        sta     $38fe
        sta     $38ff

; get elemental multiplier
        lda     $2699       ; attack element
        sta     $3600
        and     $2721
        beq     @c65a       ; branch if not very weak
        lda     #$08        ; 4x elemental damage multiplier
        sta     $38fe
        bra     @c685
@c65a:  lda     $2699
        and     $2720       ; branch if not weak
        beq     @c669
        lda     #$04        ; 2x elemental damage multiplier
        sta     $38fe
        bra     @c685
@c669:  lda     $2699
        and     $2726       ; branch if not immune
        beq     @c678
        lda     #$00        ; 0x elemental damage multiplier
        sta     $38fe
        bra     @c685
@c678:  lda     $2699
        and     $2725       ; branch if not strong
        beq     @c685
        lda     #$01        ; 1/2x elemental damage multiplier
        sta     $38fe

; get creature type multiplier
@c685:  lda     $cd
        bmi     @c69c       ; branch if attacker is a monster
        lda     $ce
        bpl     @c6ad       ; branch if target is a character

; character vs. monster
        lda     $269a       ; attack strong vs. creature type
        and     $2740       ; creature type
        beq     @c6ad
        lda     #$08        ; 4x creature type multiplier
        sta     $38ff
        bra     @c6ad
@c69c:  lda     $ce
        bmi     @c6ad       ; branch if target is a monster

; monster vs. character
        lda     $26c0
        and     $2727       ; defense strong vs. creature type
        beq     @c6ad
        lda     #$01        ; 1/2x creature type multiplier
        sta     $38ff
@c6ad:  stz     $3900       ; clear crit flag
        lda     $269d       ; attacker's attack power
        tax
        stx     $3902
        lda     $2684
        and     #$04
        beq     @c6d7       ; branch if not berserk
        stx     $a9
        lsr     $aa
        ror     $a9         ; attack power +50%
        clc
        lda     $3902
        adc     $a9
        sta     $3902
        lda     $3903
        adc     $aa
        sta     $3903
        bra     @c6e4
@c6d7:  lda     $2685
        and     #$0a
        beq     @c6e4       ; branch if not using jump or focus
        asl     $3902
        rol     $3903       ; attack power +100%
@c6e4:  lda     $2684
        and     #$80
        beq     @c6f1       ; branch if cursed
        lsr     $3903
        ror     $3902       ; attack power -50%
@c6f1:  lda     $272a       ; target's defense
        tax
        stx     $3904
        lda     $2701
        bpl     @c703       ; branch if not in back row
        asl     $3904
        rol     $3905       ; defense +100%
@c703:  lda     $2704
        and     #$80
        beq     @c710       ; branch if not cursed
        lsr     $3905       ; defense -100%
        ror     $3904
@c710:  jsr     Rand99
        cmp     $26ad       ; compare to crit rate
        bcs     @c723
        inc     $3900       ; set crit flag for damage
        lda     #$04
        ora     $34c7       ; set crit flag for graphics
        sta     $34c7
@c723:  lda     $2705
        and     #$10
        beq     @c730       ; branch if not using defend command
        asl     $3904       ; defense +100%
        rol     $3905
@c730:  lda     $2705
        and     #$08
        beq     @c73d       ; branch if not using focus
        lsr     $3905       ; defense -100%
        ror     $3904
@c73d:  lda     $2683
        and     #$30
        beq     @c74d       ; branch if attacker is not toad or mini
        ldx     #$0001
        stx     $3902       ; set attack power to 1
        stz     $3900       ; clear crit flag
@c74d:  lda     $2703
        and     #$30
        beq     @c75f       ; branch if target is not toad or mini
        asl     $3902
        rol     $3903       ; attack power +100%
        clr_ax
        stx     $3904       ; set defense to zero
@c75f:  lda     #$01
        sta     $3906       ; single target (don't divide damage)
        lda     $26ae       ; set crit bonus
        sta     $3901
        jsr     CalcDmg
        lda     $2699
        and     #$40
        bne     @c7b0       ; branch if attack has drain element

; no drain
        lda     $ce
        jsr     GetDmgPtr
        lda     $34d4,x
        ora     $34d5,x
        beq     @c7a4       ; branch if current damage is zero
        lda     $34d5,x
        pha
        and     #$80        ; save msb
        sta     $a9
        pla
        and     #$3f
        sta     $34d5,x     ; add to damage buffer
        clc
        lda     $34d4,x
        adc     $a4
        sta     $34d4,x
        lda     $34d5,x
        adc     $a5
        ora     $a9         ; restore msb
        sta     $34d5,x
        bra     @c7ae
@c7a4:  lda     $a4
        sta     $34d4,x     ; set damage
        lda     $a5
        sta     $34d5,x
@c7ae:  bra     @c7fb

; drain
@c7b0:  lda     $ce
        beq     @c7db       ; branch if character slot 1 (should be bpl ???)
        lda     $2740
        bpl     @c7db       ; branch if not undead

; undead target
        lda     $ce
        jsr     GetDmgPtr
        lda     $a4
        sta     $34d4,x
        lda     $a5
        ora     #$80        ; restore target hp
        sta     $34d5,x
        lda     $cd
        jsr     GetDmgPtr
        lda     $a4
        sta     $34d4,x     ; damage attacker
        lda     $a5
        sta     $34d5,x
        bra     @c7fb

; not undead target
@c7db:  lda     $cd
        jsr     GetDmgPtr
        lda     $a4
        sta     $34d4,x
        lda     $a5
        ora     #$80        ; restore attacker hp
        sta     $34d5,x
        lda     $ce
        jsr     GetDmgPtr
        lda     $a4
        sta     $34d4,x     ; damage target
        lda     $a5
        sta     $34d5,x
@c7fb:  lda     $cd
        bpl     @c809       ; branch if character attacker
        ldx     $2896
        lda     $33c2,x
        cmp     #$f8
        bne     @c80c       ; branch if no battle message ???
@c809:  jsr     ApplyDmg
@c80c:  lda     $3907
        bne     @c816       ; branch if target died
        lda     $38fc
        bne     @c819       ; branch if one or more hits
@c816:  jmp     @c900       ; skip status effects
@c819:  lda     $269e
        ora     $269f
        beq     @c816       ; branch if no status inflicted
        lda     $269e
        and     $272b
        bne     @c816       ; branch if target is immune to status 1
        lda     $269f
        and     $272c
        bne     @c816       ; branch if target is immune to status 2
        sec
        lda     $269c       ; hit rate - defense rate
        sbc     $2729
        beq     @c816
        bcc     @c816       ; branch if less than 1
        sta     $38fa
        lda     $38fc       ; number of hits from attack
        sta     $38fb
        jsr     CalcHits
        lda     $38fd
        beq     @c816       ; branch if no hits for status
        lda     $2770
        bmi     @c816       ; branch if a boss
        lda     $269e
        sta     $3908       ; set status 1 inflicted
        sta     $aa
        and     $2703
        bne     @c816       ; branch if target already had that status
        lda     $269f
        sta     $3909       ; set status 2 inflicted
        sta     $a9
        and     $2704
        bne     @c88d       ; branch if target already had that status
        lda     $ce
        bpl     @c875       ; branch if target is a character
        and     #$7f
        clc
        adc     #$05
@c875:  sta     $cf
        jsr     Asl_2
        tax
        stx     $c7
        lda     $cf
        jsr     SelectObj
        lda     #$03        ; action timer
        jsr     GetTimerPtr
        ldx     $3598
        lda     $2a06,x
@c88d:  bne     @c900       ; branch if not waiting for turn
        lda     $2683
        and     #$30
        bne     @c88d       ; branch if toad or mini
        longa
        clr_ax
        txy
@c89b:  asl     $a9
        bcc     @c8ab       ; find first status inflicted
        shorta
        txa
        clc
        adc     #$25        ; status inflicted messages
        sta     $34ca,y     ; add to battle message buffer
        iny
        longa
@c8ab:  inx
        cpx     #$0010
        bne     @c89b
        shorta0
        jsr     ApplyAttackStatus
        lda     $3908
        ora     $3909
        bne     @c8c1       ; branch if any status was inflicted
        bra     @c900
@c8c1:  lda     $cd
        bmi     @c8ca       ; branch if monster attacker
        jsr     AddMsg3
        bra     @c900
@c8ca:  clr_ax
@c8cc:  lda     $33c2,x     ; copy graphics script to data buffer
        sta     $289c,x
        inx
        cmp     #$ff
        bne     @c8cc
        clr_axy
@c8da:  lda     $289c,x
        sta     $33c2,y
        cmp     #$ff
        beq     @c900
        cmp     #$c0        ; insert message display after attack
        beq     @c8f0
        cmp     #$c6
        beq     @c8f0
        cmp     #$de
        bne     @c8fc
@c8f0:  iny
        lda     #$f8        ; display text
        sta     $33c2,y
        iny
        lda     #$03        ; battle message
        sta     $33c2,y
@c8fc:  inx
        iny
        bra     @c8da
@c900:  lda     $38e1
        beq     @c913       ; return if no arrow quantity update needed
        lda     $cd         ; attacker id
        sta     $00
        lda     $38e3       ; arrow hand
        sta     $01
        lda     #$08        ; battle graphics $08: update arrow quantity
        jsr     ExecBtlGfx
@c913:  rts

; ------------------------------------------------------------------------------

; [ decrement arrow quantity ]

DecArrows:
@c914:  lda     $2683
        and     #$30
        bne     @c986       ; return if toad or mini
        lda     $cd
        jsr     SelectObj
        clc
        lda     $3532       ; pointer to equipped item data
        adc     #$21        ; skip defensive items
        sta     $a9
        lda     $3533
        adc     #$00
        sta     $aa
        clr_ay
        sty     $ab
        sta     $38e3
        ldx     $a9
        lda     $2786,x     ; left hand item equipability
        and     #$40
        beq     @c942       ; branch if not an arrow
        iny
        bra     @c952
@c942:  lda     $2791,x     ; right hand item equipability
        and     #$40
        beq     @c952       ; branch if not an arrow
        lda     #$80
        sta     $ab
        inc     $38e3
        iny2
@c952:  lda     $cd
        jsr     Asl_3
        tax
        tya
        beq     @c986       ; branch if no arrows equipped
        dey
        beq     @c962
        inx4
@c962:  sec
        lda     $32dc,x     ; decrement item quantity
        sbc     #$01
        bne     @c978

; ran out of arrows
        lda     $cd
        tax
        lda     $38dc,x     ; set flag to validate equipped arrows
        inc
        ora     $ab
        sta     $38dc,x
        bra     @c97b

; didn't run out of arrows
@c978:  sta     $32dc,x
@c97b:  inc     $38e1
        lda     $cd
        sta     $3975
        jsr     CopyEquip
@c986:  rts

; ------------------------------------------------------------------------------
