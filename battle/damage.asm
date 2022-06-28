
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: damage.asm                                                           |
; |                                                                            |
; | description: damage calculation                                            |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

; [ get number of hits ]

CalcHits:
@c987:  stz     $38fd       ; clear number of hits
        lda     $38fb
        beq     @c99e       ; return if no base hits
        tay
@c990:  jsr     Rand99
        cmp     $38fa       ; check vs. hit rate
        bcs     @c99b
        inc     $38fd       ; increment number of hits
@c99b:  dey
        bne     @c990
@c99e:  rts

; ------------------------------------------------------------------------------

; [ calculate damage ]

CalcDmg:
@c99f:  ldx     $3902       ; base attack
        stx     $3956
        stx     $3958
        lsr     $3957
        ror     $3956
        lda     $3957
        beq     @c9b9
        ldx     #$00ff
        stx     $3956
@c9b9:  clr_ax
        lda     $3956
        jsr     RandXA
        tax
        stx     $3956
        jsr     Add16
        ldx     $395a
        stx     $a4
        lda     $38fe       ; elemental multiplier
        jsr     ApplyDmgMult
        lda     $38ff       ; creature type multiplier
        jsr     ApplyDmgMult
        lda     $3900
        beq     @c9ec       ; branch if not a crit
        clc
        lda     $a4
        adc     $3901       ; add crit bonus
        sta     $a4
        lda     $a5
        adc     #0
        sta     $a5
@c9ec:  sec
        lda     $a4
        sbc     $3904
        sta     $a4
        lda     $a5
        sbc     $3905
        sta     $a5
        bcs     @ca01
        clr_ax
        stx     $a4
@ca01:  ldx     $a4
        stx     $393d
        lda     $38fc
        tax
        stx     $393f
        jsr     Mult16
        ldx     $3943
        beq     @ca1b
        ldx     #$ffff
        stx     $3941
@ca1b:  ldx     $3941
        stx     $3945
        lda     $3906
        tax
        stx     $3947
        jsr     Div16
        ldx     $3949
        stx     $a4
        cpx     #$270f
        bcc     @ca3a
        ldx     #$270f
        stx     $a4
@ca3a:  ldx     $a4
        bne     @ca40
        inc     $a4
@ca40:  rts

; ------------------------------------------------------------------------------

; [ apply damage multiplier ]

ApplyDmgMult:
@ca41:  bne     @ca48
        stz     $a4
        stz     $a5
        rts
@ca48:  lsr
        bne     @ca50
        lsr     $a5
        ror     $a4
        rts
@ca50:  tax
        stx     $393d
        ldx     $a4
        stx     $393f
        jsr     Mult16
        ldx     $3941
        stx     $a4
        rts

; ------------------------------------------------------------------------------

; [ get pointer to damage buffer ]

GetDmgPtr:
@ca62:  sta     $a9
        bpl     @ca6b       ; branch if a character
        and     #$7f
        clc
        adc     #$05
@ca6b:  asl
        tax
        rts

; ------------------------------------------------------------------------------

; [ update hp after damage ]

ApplyDmg:
@ca6e:  longa
        clr_ax
        stx     $a9
        tay
; start of loop
@ca75:  tya
        lsr
        tax
        lda     $3540,x
        and     #$00ff
        beq     @ca83       ; branch if target is present
        jmp     @cb22
@ca83:  ldx     $a9
        lda     $34d4,y
        and     #$4000
        beq     @ca9e       ; branch if attack didn't miss
        lda     $355b
        beq     @ca9e       ; branch if attack can show zero damage
        lda     $34d4,y
        and     #$bfff      ; clear miss flag
        sta     $34d4,y
        jmp     @cb22
@ca9e:  lda     $34d4,y
        bpl     @cab4       ; branch if attack did damage
; restore hp
        clc
        lda     $34d4,y
        and     #$3fff
        adc     $2007,x     ; add to target hp
        bcc     @cae6
        lda     #$ffff      ; max $ffff
        bra     @cae6
; damage hp
@cab4:  lda     $34d4,y
        and     #$bfff      ; clear miss flag
        sta     $2898
        sec
        lda     $2007,x
        beq     @cad1
        sbc     $2898       ; subtract from target hp
        beq     @caca
        bcs     @cae6
; hp reached zero
@caca:  shorta
        inc     $3907       ; increment number of targets that died
        longa
@cad1:  tya
        asl
        tax
        shorta0
        lda     $338e,x     ; set dead status
        and     #$fe
        ora     #$80
        sta     $338e,x
        longa
        clr_a
        ldx     $a9
@cae6:  sta     $2007,x     ; cap at max hp
        cmp     $2009,x
        bcc     @caf6
        lda     $2009,x
        sta     $2007,x
        bra     @cb13
@caf6:  lda     $2009,x
        jsr     Lsr_2
        cmp     $2007,x
        bcc     @cb13       ; branch if not at critical hp
        tya
        asl
        tax
        shorta0
        lda     $3391,x     ; set critical status
        ora     #$01
        sta     $3391,x
        longa
        bra     @cb22
@cb13:  shorta0
        ldx     $a9
        lda     $2006,x     ; clear critical status
        and     #$fe
        sta     $2006,x
        longa
@cb22:  ldx     $a9         ; next target
        txa
        clc
        adc     #$0080
        tax
        stx     $a9
        iny2
        cpy     #$001a
        beq     @cb36
        jmp     @ca75
@cb36:  shorta0
        rts

; ------------------------------------------------------------------------------

; [ apply attack status ]

ApplyAttackStatus:
@cb3a:  lda     $3908
        bpl     @cb4d
        lda     $2740
        and     #$82
        beq     @cb4d
        stz     $3908
        stz     $3909
        rts
@cb4d:  longa
        lda     $2703
        and     #$bfff
        cmp     $3908
        bcc     @cb60
        stz     $3908
        jmp     @cc32
@cb60:  ldx     $c7
        lda     $2703
        ora     $3908
        sta     $338e,x
        lda     $3908
        and     #$3b01
        bne     @cb76
        jmp     @cc32
@cb76:  shorta0
        lda     $3908
        and     #$01
        beq     @cba9
        lda     #$06
        sta     $d6
        lda     $cf
        jsr     CalcTimerDur
        lda     #$09        ; poison timer
        jsr     SetTimer
        lda     #$40
        sta     $2a06,x
        lda     $cf
        asl
        tax
        lda     $29eb,x     ; enable poison timer
        ora     #$10
        sta     $29eb,x
        lda     $d4
        sta     $2b2a,x
        lda     $d5
        sta     $2b2b,x
@cba9:  lda     $3909
        and     #$30
        beq     @cbc4
        lda     #$04
        sta     $d6
        lda     $cf
        jsr     CalcTimerDur
        lda     #$03        ; action timer
        jsr     SetTimer
        lda     #$40
        sta     $2a06,x
        rts
@cbc4:  lda     $3909
        and     #$03
        beq     @cc31
        ldx     $c7
        lda     $2704
        and     #$fc
        sta     $a9
        lda     $2704
        and     #$03
        beq     @cc07
        clc
        adc     $269f
        sta     $aa
        and     #$04
        beq     @cbff
        lda     $a9
        sta     $338f,x
        lda     $2703
        ora     #$40
        sta     $338e,x
        lda     $cf
        asl
        tax
        lda     $29eb,x     ; disable petrify timer
        and     #$f7
        sta     $29eb,x
        rts
@cbff:  lda     $a9
        ora     $aa
        sta     $338f,x
        rts
@cc07:  lda     #$04
        sta     $d6
        lda     $cf
        jsr     CalcTimerDur
        lda     #$0c        ; petrify timer
        jsr     SetTimer
        lda     #$40
        sta     $2a06,x
        lda     $cf
        asl
        tax
        lda     $29eb,x     ; enable petrify timer
        ora     #$08
        sta     $29eb,x
        lda     $d4
        sta     $2b44,x
        lda     $d5
        sta     $2b45,x
        rts
@cc31:  rts
@cc32:  shorta0
        rts

; ------------------------------------------------------------------------------
