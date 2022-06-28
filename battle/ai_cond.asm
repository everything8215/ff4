
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: ai_cond.asm                                                          |
; |                                                                            |
; | description: check monster a.i conditional                                 |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

; [ check monster condition ]

CheckAICond:
@bcce:  stz     $de
        lda     $289c
        asl
        tax
        lda     f:AICondTbl,x   ; monster condition jump table
        sta     $80
        lda     f:AICondTbl+1,x
        sta     $81
        lda     #$03
        sta     $82
        jml     [$0080]

; ------------------------------------------------------------------------------

; [ monster condition $00: target status ]

AICond_00:
@bce8:  jsr     GetAICondTarget
        lda     $dd
        beq     @bd3c
        clc
        lda     #$03
        adc     $289e
        sta     $80
        lda     #$20
        adc     #$00
        sta     $81
        clr_ax
@bcff:  lda     $35d0,x
        sta     $a9
        lda     $35d1,x
        sta     $aa
        ldy     $a9
        cpy     #$ffff
        beq     @bd28
        lda     ($80)
        and     $289f
        bne     @bd1f
        lda     $289d
        bpl     @bd28
        stz     $de
        rts
@bd1f:  lda     #$01
        sta     $de
        lda     $289d
        bpl     @bd3c
@bd28:  longa
        clc
        lda     $80
        adc     #$0080
        sta     $80
        shorta0
        inx2
        cpx     #$001a
        bne     @bcff
@bd3c:  rts

; ------------------------------------------------------------------------------

; [ monster condition $01: target hp ]

AICond_01:
@bd3d:  jsr     GetAICondTarget
        lda     $dd
        beq     @bda8
        lda     $289f
        asl
        tax
        lda     f:AICondHP,x
        sta     $ad
        lda     f:AICondHP+1,x
        sta     $ae
        clr_ax
        stx     $a9
@bd59:  lda     $a9
        asl
        tay
        lda     $35d0,y
        sta     $ab
        lda     $35d1,y
        sta     $ac
        ldy     $ab
        cpy     #$ffff
        beq     @bd9d
        longa
        lda     $ad
        cmp     #$ffff
        bne     @bd81
        lda     $2007,x
        cmp     $2009,x
        bne     @bd93
        beq     @bd88
@bd81:  lda     $ad
        cmp     $2007,x
        bcs     @bd93
@bd88:  shorta0
        lda     $289d
        bpl     @bd9d
        stz     $de
        rts
@bd93:  shorta0
        inc     $de
        lda     $289d
        bpl     @bda8
@bd9d:  jsr     NextObj
        inc     $a9
        lda     $a9
        cmp     #$0d
        bne     @bd59
@bda8:  rts

; ------------------------------------------------------------------------------

; [ monster condition $02: battle variable ]

AICond_02:
@bda9:  lda     $289e
        tax
        lda     $35f3,x
        cmp     $289f
        bne     @bdb7
        inc     $de
@bdb7:  rts

; ------------------------------------------------------------------------------

; [ monster condition $03: target valid ]

AICond_03:
@bdb8:  jsr     GetAICondTarget
        lda     $289e
        bne     @bdc6
        lda     $dd
        bne     @bded
        beq     @bdef
@bdc6:  lda     $289e
        dec
        bne     @bdd2
        lda     $dd
        beq     @bded
        bne     @bdef
@bdd2:  lda     $dd
        beq     @bdef
        clr_ax
        stx     $a9
@bdda:  lda     $29eb,x
        beq     @bde1
        inc     $a9
@bde1:  inx2
        cpx     #10
        bne     @bdda
        lda     $a9
        dec
        bne     @bdef
@bded:  inc     $de
@bdef:  rts

; ------------------------------------------------------------------------------

; [ monster condition $04: monster type ]

AICond_04:
@bdf0:  clr_ax
        stx     $a9
@bdf4:  lda     $289f
        cmp     $29ad,x
        beq     @be06
        inx
        cpx     #3
        bne     @bdf4
@be02:  inc     $a9
        bra     @be14
@be06:  lda     $29ca,x
        beq     @be02
        cmp     $29cd
        bne     @be14
        inc     $a9
        inc     $a9
@be14:  lda     $289e
        cmp     $a9
        bne     @be1d
        inc     $de
@be1d:  rts

; ------------------------------------------------------------------------------

; [ monster condition $05: battle id ]

AICond_05:
@be1e:  lda     $289e
        cmp     $1801
        bne     @be30
        lda     $289f
        cmp     $1800
        bne     @be30
        inc     $de
@be30:  rts

; ------------------------------------------------------------------------------

; [ monster condition $06: only monster type remaining ]

AICond_06:
@be31:  sec
        lda     $d2
        sbc     #$05
        tax
        lda     $29b5,x
        tax
        lda     $29ca,x
        cmp     $29cd
        bne     @be45
        inc     $de
@be45:  rts

; ------------------------------------------------------------------------------

; [ monster condition $07: attacked by character/monster slot ]

AICond_07:
@be46:  sec
        lda     $d2
        sbc     #$05
        tax
        jsr     Asl_5
        sta     $a9
        lda     $35f7,x     ; retaliation stack size
        cmp     #$ff
        beq     @be9f       ; branch if retaliation stack is empty
        jsr     Asl_2
        clc
        adc     $a9
        tax
        clr_ay
@be61:  lda     $2b78,x     ; copy previous attack data to buffer
        sta     $291c,y
        inx
        iny
        cpy     #4
        bne     @be61
        jsr     GetAICondTarget
        lda     $dd
        beq     @be9f
        lda     $291c       ; previous attacker
        bpl     @be7f       ; branch if character attacker
        and     #$7f
        clc
        adc     #$05
@be7f:  asl
        tax
        lda     $35d0,x
        and     $35d1,x
        cmp     #$ff
        beq     @be9f
        lda     $289e
        cmp     $291d
        bne     @be9f       ; branch if command doesn't match
        lda     $289f
        beq     @be9d       ; branch if element doesn't matter
        and     $291f
        beq     @be9f       ; branch if element doesn't match
@be9d:  inc     $de
@be9f:  rts

; ------------------------------------------------------------------------------

; [ monster condition $08: attacked with command ]

AICond_08:
@bea0:  sec
        lda     $d2
        sbc     #5
        jsr     Asl_5
        tax
        clr_ay
@beab:  lda     $2b78,x     ; copy previous attack data to buffer
        sta     $291c,y
        inx
        iny
        cpy     #$0020
        bne     @beab
        clr_ax
@beba:  lda     $289e
        cmp     $291d,x
        beq     @becc       ; branch if command matches
        inx4
        cpx     #$0020
        bne     @beba
        rts
@becc:  clr_a
@becd:  lda     $289f
        beq     @bee1       ; branch if element doesn't matter
        and     $291f,x
        bne     @bee1       ; branch if element matches
        inx4
        cpx     #$0020
        bne     @becd
        rts
@bee1:  inc     $de
        rts

; ------------------------------------------------------------------------------

; [ monster condition $09: party used escape ]

AICond_09:
@bee4:  lda     $38d3
        beq     @beeb
        inc     $de
@beeb:  rts

; ------------------------------------------------------------------------------

; [ monster condition $0a: took damage ]

AICond_0a:
@beec:  sec
        lda     $d2
        sbc     #$05
        asl
        tax
        lda     $34d4,x     ; damage taken
        ora     $34d5,x
        beq     @bf04
        lda     $34d5,x
        and     #$c0
        bne     @bf04       ; branch if mp damage or hp restored
        inc     $de
@bf04:  rts

; ------------------------------------------------------------------------------

; [ monster condition $0b: alone ]

AICond_0b:
@bf05:  lda     $29cd       ; check if only 1 monster remains
        cmp     #$01
        bne     @bf0e
        inc     $de
@bf0e:  rts

; ------------------------------------------------------------------------------

; [ get monster condition target ]

GetAICondTarget:
@bf0f:  stz     $dd
        ldx     #$0019
        lda     #$ff
@bf16:  sta     $35d0,x
        dex
        bpl     @bf16
        lda     $289d
        and     #$7f
        asl
        tax
        lda     f:AICondTargetTbl,x   ; monster condition target jump table
        sta     $80
        lda     f:AICondTargetTbl+1,x
        sta     $81
        lda     #$03
        sta     $82
        jml     [$0080]

; ------------------------------------------------------------------------------

; [ monster condition target $00-$15: specific character id ]

AICondTarget_00:
@bf36:  lda     $289d
        sta     $ab
        clr_ax
        stx     $a9
@bf3f:  lda     $a9
        tay
        lda     $3540,y
        bne     @bf6d
        lda     $2000,x
        and     #$1f
        cmp     $ab
        bne     @bf6d
        jsr     ValidateAITarget
        lda     $35ea
        bne     @bf6d
        stx     a:$00ab
        lda     $a9
        asl
        tax
        lda     $ab
        sta     $35d0,x
        lda     $ac
        sta     $35d1,x
        inc     $dd
        bra     @bf78
@bf6d:  jsr     NextObj
        inc     $a9
        lda     $a9
        cmp     #$05
        bne     @bf3f
@bf78:  rts

; ------------------------------------------------------------------------------

; [ monster condition target $16: monster of same type ]

AICondTarget_16:
@bf79:  sec
        lda     $d2
        sbc     #$05
        tax
        lda     $29b5,x
        sta     $ab
        ldx     #5
        stx     $a9
        clr_ax
@bf8b:  sec
        lda     $a9
        sbc     #$05
        tay
        lda     $29b5,y
        cmp     $ab
        bne     @bfa6
        lda     $a9
        asl
        tay
        longa
        clr_a
        sta     $35d0,y
        shorta
        inc     $dd
@bfa6:  jsr     NextObj
        inc     $a9
        lda     $a9
        cmp     #$0d
        bne     @bf8b
        rts

; ------------------------------------------------------------------------------

; [ monster condition target $17: self ]

AICondTarget_17:
@bdb2:  lda     $d2
        asl
        tay
        lda     $a6
        sta     $35d0,y
        lda     $a7
        sta     $35d1,y
        inc     $dd
        rts

; ------------------------------------------------------------------------------

; [ monster condition target $18/$19/$2e: character ]

AICondTarget_18:
AICondTarget_19:
AICondTarget_2e:
TargetCharacter:
@bfc3:  stz     $a9
        lda     #$05
        sta     $ab
_bfc9:  clr_ax
@bfcb:  lda     $a9
        tay
        lda     $3540,y
        bne     @bfea
        jsr     ValidateAITarget
        lda     $35ea
        bne     @bfea
        lda     $a9
        asl
        tay
        longa
        txa
        sta     $35d0,y
        shorta0
        inc     $dd
@bfea:  jsr     NextObj
        inc     $a9
        lda     $a9
        cmp     $ab
        bne     @bfcb
        rts

; ------------------------------------------------------------------------------

; [ monster condition target $1a/$25: type 1 monster ]

AICondTarget_1a:
AICondTarget_25:
@bff6:  stz     $ab
        jmp     TargetMonsterType

TargetMonsterType:
@bffb:  clr_ay
        sty     $a9
        ldx     #$0280
@c002:  ldy     $a9
        lda     $29b5,y
        cmp     $ab
        bne     @c02f
        clc
        lda     $a9
        adc     #$05
        sta     $ac
        tay
        lda     $3540,y
        bne     @c02f
        jsr     ValidateAITarget
        lda     $35ea
        bne     @c02f
        lda     $ac
        asl
        tay
        longa
        txa
        sta     $35d0,y
        shorta0
        inc     $dd
@c02f:  jsr     NextObj
        inc     $a9
        lda     $a9
        cmp     #$08
        bne     @c002
        rts

; ------------------------------------------------------------------------------

; [ monster condition target $1b: type 2 monster ]

AICondTarget_1b:
AICondTarget_26:
@c03b:  lda     #$01
        sta     $ab
        jmp     TargetMonsterType

; ------------------------------------------------------------------------------

; [ monster condition target $1c: type 3 monster ]

AICondTarget_1c:
AICondTarget_27:
@c042:  lda     #$02
        sta     $ab
        jmp     TargetMonsterType

; ------------------------------------------------------------------------------

; [ monster condition target $1d: any target ]

AICondTarget_1d:
AnyTarget:
@c049:  jsr     TargetCharacter
        jmp     TargetMonster

; ------------------------------------------------------------------------------

; [ monster condition target $1e: any target (not self) ]

AICondTarget_1e:
@c04f:  jsr     AnyTarget

NoSelfTarget:
@c052:  lda     $d2
        asl
        tax
        lda     #$ff
        sta     $35d0,x
        sta     $35d1,x
        dec     $dd
        rts

; ------------------------------------------------------------------------------

; [ monster condition target $1f/$24/$2f: monster ]

AICondTarget_1f:
AICondTarget_24:
AICondTarget_2f:
TargetMonster:
@c061:  lda     #$05
        sta     $a9
        lda     #$0d
        sta     $ab
        jmp     _bfc9

; ------------------------------------------------------------------------------

; [ monster condition target $20/$23: monster (not self) ]

AICondTarget_20:
AICondTarget_23:
@c06c:  jsr     TargetMonster
        jmp     NoSelfTarget

; ------------------------------------------------------------------------------

; [ monster condition target $21/$2b: front row character ]

AICondTarget_21:
AICondTarget_28:
@c072:  clr_ax
        stx     $a9
@c076:  lda     $a9
        tay
        lda     $3540,y
        bne     @c09a
        jsr     ValidateAITarget
        lda     $35ea
        bne     @c09a
        lda     $2001,x
        bmi     @c09a
        lda     $a9
        asl
        tay
        longa
        txa
        sta     $35d0,y
        shorta0
        inc     $dd
@c09a:  jsr     NextObj
        inc     $a9
        lda     $a9
        cmp     #$05
        bne     @c076
        rts

; ------------------------------------------------------------------------------

; [ monster condition target $22/$29: back row character ]

AICondTarget_22:
AICondTarget_29:
@c0a6:  clr_ax
        stx     $a9
@c0aa:  lda     $a9
        tay
        lda     $3540,y
        bne     @c0ce
        jsr     ValidateAITarget
        lda     $35ea
        bne     @c0ce
        lda     $2001,x
        bpl     @c0ce
        lda     $a9
        asl
        tay
        longa
        txa
        sta     $35d0,y
        shorta0
        inc     $dd
@c0ce:  jsr     NextObj
        inc     $a9
        lda     $a9
        cmp     #$05
        bne     @c0aa
        rts

; ------------------------------------------------------------------------------

; [ monster condition target $2a-$2d: validate target ]

AICondTarget_2a:
AICondTarget_2b:
AICondTarget_2c:
AICondTarget_2d:
ValidateAITarget:
@c0da:  stz     $35ea
        lda     $2003,x
        and     #$c0
        bne     @c0f0
        lda     $2005,x
        and     #$82
        bne     @c0f0
        lda     $2006,x
        bpl     @c0f3
@c0f0:  inc     $35ea
@c0f3:  rts

; ------------------------------------------------------------------------------

; monster condition jump table
AICondTbl:
@c0f4:  .addr   AICond_00
        .addr   AICond_01
        .addr   AICond_02
        .addr   AICond_03
        .addr   AICond_04
        .addr   AICond_05
        .addr   AICond_06
        .addr   AICond_07
        .addr   AICond_08
        .addr   AICond_09
        .addr   AICond_0a
        .addr   AICond_0b

; monster condition target jump table
AICondTargetTbl:
@c10c:  .addr   AICondTarget_00
        .addr   AICondTarget_00
        .addr   AICondTarget_00
        .addr   AICondTarget_00
        .addr   AICondTarget_00
        .addr   AICondTarget_00
        .addr   AICondTarget_00
        .addr   AICondTarget_00
        .addr   AICondTarget_00
        .addr   AICondTarget_00
        .addr   AICondTarget_00
        .addr   AICondTarget_00
        .addr   AICondTarget_00
        .addr   AICondTarget_00
        .addr   AICondTarget_00
        .addr   AICondTarget_00
        .addr   AICondTarget_00
        .addr   AICondTarget_00
        .addr   AICondTarget_00
        .addr   AICondTarget_00
        .addr   AICondTarget_00
        .addr   AICondTarget_00
        .addr   AICondTarget_16
        .addr   AICondTarget_17
        .addr   AICondTarget_18
        .addr   AICondTarget_19
        .addr   AICondTarget_1a
        .addr   AICondTarget_1b
        .addr   AICondTarget_1c
        .addr   AICondTarget_1d
        .addr   AICondTarget_1e
        .addr   AICondTarget_1f
        .addr   AICondTarget_20
        .addr   AICondTarget_21
        .addr   AICondTarget_22
        .addr   AICondTarget_23
        .addr   AICondTarget_24
        .addr   AICondTarget_25
        .addr   AICondTarget_26
        .addr   AICondTarget_27
        .addr   AICondTarget_28
        .addr   AICondTarget_29
        .addr   AICondTarget_2a
        .addr   AICondTarget_2b
        .addr   AICondTarget_2c
        .addr   AICondTarget_2d
        .addr   AICondTarget_2e
        .addr   AICondTarget_2f

; ------------------------------------------------------------------------------
