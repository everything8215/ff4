
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: win.asm                                                              |
; |                                                                            |
; | description: battle victory routines                                       |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

; [ update party after victory ]

WinUpdate:
@ec72:  clr_ax
        stx     $3591
        stx     $3593
        stx     $3594
        stx     $3595
        stx     $b5
        stx     $b7
@ec84:  ldx     $b7
        lda     $3585,x
        sta     $b1
        bne     @ec90
        jmp     @ed68
@ec90:  ldx     $b7
        lda     $358b,x
        sta     $af
        stz     $b0
        asl     $af
        rol     $b0
        ldx     $af
        clc
        lda     f:MonsterXP,x
        adc     $3591
        sta     $3591
        lda     f:MonsterXP+1,x
        adc     $3592
        sta     $3592
        lda     $3593
        adc     #$00
        sta     $3593
        ldx     $b7
        lda     $3588,x
        sta     $af
        stz     $b0
        asl     $af
        rol     $b0
        ldx     $af
        clc
        lda     f:MonsterGil,x
        adc     $3594
        sta     $3594
        lda     f:MonsterGil+1,x
        adc     $3595
        sta     $3595
        lda     $3596
        adc     #$00
        sta     $3596
        ldx     $b7
        lda     $358e,x
        sta     $b3
        lda     $358e,x
        and     #$c0
        cmp     #$c0
        beq     @ed0f
        cmp     #$40
        bne     @ed00
        lda     #$05
        bra     @ed06
@ed00:  cmp     #$80
        bne     @ed5f
        lda     #$19
@ed06:  sta     $b4
        jsr     Rand99
        cmp     $b4
        bcs     @ed5f
@ed0f:  asl     $b3
        asl     $b3
        lda     $b3
        tax
        clr_ay
        sty     $a9
@ed1a:  lda     f:MonsterItems,x
        sta     $289c,y
        inx
        iny
        inc     $a9
        lda     $a9
        cmp     #$04
        bne     @ed1a
        lda     $16a3
        adc     $97
        sta     $97
        jsr     Rand
        cmp     #$80
        bcs     @ed3d
        lda     #$00
        bra     @ed4f
@ed3d:  cmp     #$d0
        bcs     @ed45
        lda     #$01
        bra     @ed4f
@ed45:  cmp     #$fc
        bcs     @ed4d
        lda     #$02
        bra     @ed4f
@ed4d:  lda     #$03
@ed4f:  tax
        lda     $289c,x
        ldx     $b5
        cpx     #$0008
        beq     @ed5f
        sta     $1804,x
        inc     $b5
@ed5f:  dec     $b1
        lda     $b1
        beq     @ed68
        jmp     @ec90
@ed68:  inc     $b7
        lda     $b7
        cmp     #$03
        beq     @ed73
        jmp     @ec84
@ed73:  clc
        lda     $16a0
        adc     $3594
        sta     $16a0
        lda     $16a1
        adc     $3595
        sta     $16a1
        lda     $16a2
        adc     $3596
        sta     $16a2
        sec
        lda     $16a0
        sbc     #$7f
        lda     $16a1
        sbc     #$96
        lda     $16a2
        sbc     #$98
        bcc     @edb0
        lda     #$7f
        sta     $16a0
        lda     #$96
        sta     $16a1
        lda     #$98
        sta     $16a2
@edb0:  clr_ax
        stx     $a9
        stx     $ab
        stx     $ad
        stx     $405f
        stx     $4061
        stx     $4063
        stx     $4065
        stx     $4067
@edc7:  ldx     $a9
        cpx     #$0005
        bcs     @edd3
        lda     $3540,x
        bne     @edef
@edd3:  ldx     $ad
        lda     $1000,x
        and     #$1f
        beq     @edef
        lda     $1003,x
        and     #$c0
        bne     @edef
        ldx     $a9
        inc     $405f,x
        cpx     #$0005
        bcs     @edef
        inc     $ab
@edef:  longa
        clc
        lda     $ad
        adc     #$0040
        sta     $ad
        shorta0
        inc     $a9
        lda     $a9
        cmp     #$0a
        bne     @edc7
        lda     $3591
        ora     $3592
        ora     $3593
        beq     @ee40
        clr_ax
        stx     $ad
        stx     $af
        lda     $3591
        ora     $3592
        ora     $3593
        bne     @ee28
        stz     $ad
        stz     $ae
        stz     $af
        bra     @ee2c
@ee28:  jsl     DivXP
@ee2c:  lda     $ad
        ora     $ae
        ora     $af
        bne     @ee36
        inc     $ad
@ee36:  ldx     $ad
        stx     $3591
        lda     $af
        sta     $3593
@ee40:  jsr     InitGfxScript
        jsr     AddMsg1
        lda     $3594
        sta     $359a
        lda     $3595
        sta     $359b
        lda     $3596
        sta     $359c
        lda     $3591
        sta     $359d
        lda     $3592
        sta     $359e
        lda     $3593
        sta     $359f
        clr_ax
        lda     $3594
        ora     $3595
        beq     @ee7a
        lda     #$1f
        sta     $34ca
        inx
@ee7a:  lda     $3591
        ora     $3592
        beq     @ee88
        lda     #$20
        sta     $34ca,x
        inx
@ee88:  txa
        beq     @ee90
        lda     #$05                    ; battle graphics $05: graphics script
        jsr     ExecBtlGfx
@ee90:  lda     #$ff
        sta     $34cb
        clr_ax
        stx     $a9
        stx     $ab
@ee9b:  ldx     $a9
        lda     $405f,x
        beq     @eee1
        ldx     $ab
        clc
        lda     $1037,x
        adc     $3591
        sta     $1037,x
        lda     $1038,x
        adc     $3592
        sta     $1038,x
        lda     $1039,x
        adc     $3593
        sta     $1039,x
        sec
        lda     $1037,x
        sbc     #$7f
        lda     $1038,x
        sbc     #$96
        lda     $1039,x
        sbc     #$98
        bcc     @eee1
        lda     #$7f
        sta     $1037,x
        lda     #$96
        sta     $1038,x
        lda     #$98
        sta     $1039,x
@eee1:  longa
        clc
        lda     $ab
        adc     #$0040
        sta     $ab
        shorta0
        inc     $a9
        lda     $a9
        cmp     #$0a
        bne     @ee9b
        clr_ax
        stx     $98
        stx     $a6
@eefc:  ldx     $98
        lda     $405f,x
        bne     @ef06
        jmp     @eff6
@ef06:  ldx     $a6
        lda     $1000,x
        and     #$1f
        dec
        asl
        tax
        lda     f:LevelUpPropPtrs,x
        sta     $80
        lda     f:LevelUpPropPtrs+1,x
        sta     $81
        lda     #^LevelUpPropPtrs
        sta     $82
        ldx     $a6
        lda     $1002,x
        cmp     #$46
        bcc     @ef2b
        lda     #$45
@ef2b:  dec
        sta     $df
        lda     #$05
        sta     $e1
        jsr     Mult8
        ldy     $e3
        clr_ax
@ef39:  lda     [$80],y
        sta     $289c,x
        iny
        inx
        cpx     #5
        bne     @ef39
        ldx     $a6
        lda     $1002,x
        cmp     #$46
        bcc     @ef6a
        phy
        ldx     #0
        lda     #7
        jsr     RandXA
        tax
        stx     $ad
        ply
        longa
        tya
        clc
        adc     $ad
        tay
        shorta0
        lda     [$80],y
        sta     $289c
@ef6a:  lda     $289f
        sta     $ad
        lda     $28a0
        sta     $ae
        lda     $289e
        jsr     Lsr_5
        sta     $af
        ldx     $a6
        clc
        lda     $103d,x
        adc     $ad
        sta     $ad
        lda     $103e,x
        adc     $ae
        sta     $ae
        lda     $103f,x
        adc     $af
        sta     $af
        sec
        lda     $1037,x
        sbc     $ad
        lda     $1038,x
        sbc     $ae
        lda     $1039,x
        sbc     $af
        bcc     @eff6
        lda     $ad
        sta     $103d,x
        lda     $ae
        sta     $103e,x
        lda     $af
        sta     $103f,x
        lda     $1002,x
        cmp     #$63
        bcs     @eff6
        inc     $1002,x
        jsr     LevelUp
        lda     $98
        cmp     #$05
        bcs     @eff3
        sta     $359a
        lda     #$21
        sta     $34ca
        lda     #$05                    ; battle graphics $05: graphics script
        jsr     ExecBtlGfx
        lda     #$23
        sta     $34ca
        clr_ax
        stx     $af
@efde:  ldx     $af
        lda     $291c,x
        cmp     #$ff
        beq     @eff3
        sta     $359a
        lda     #$05                    ; battle graphics $05: graphics script
        jsr     ExecBtlGfx
        inc     $af
        bra     @efde
@eff3:  jmp     @ef06
@eff6:  longa
        clc
        lda     $a6
        adc     #$0040
        sta     $a6
        shorta0
        inc     $98
        lda     $98
        cmp     #$0a
        beq     @f00e
        jmp     @eefc
@f00e:  jsr     LoadCharProp
        jsr     LoadEquipProp
        stz     $3975
@f017:  lda     $3975
        tax
        lda     $3540,x
        bne     @f023
        jsr     UpdateCharStats
@f023:  inc     $3975
        lda     $3975
        cmp     #5
        bne     @f017
        rts

; ------------------------------------------------------------------------------

; [ update character at level up ]

LevelUp:
@f02e:  lda     $289c
        and     #$07
        sta     $af
        longa
        lda     $a6
        adc     #$000f
        tax
        shorta0
        ldy     #$0005
@f043:  asl     $289c
        bcc     @f06b
        lda     $af
        cmp     #$07
        bne     @f05c
        sec
        lda     $1000,x
        sbc     #1
        cmp     #1
        bcs     @f068
        lda     #1
        bra     @f068
@f05c:  clc
        lda     $1000,x
        adc     $af
        cmp     #$63
        bcc     @f068
        lda     #$63
@f068:  sta     $1000,x
@f06b:  inx
        dey
        bne     @f043
        lda     $289d
        sta     $b1
        ldx     #$270f
        stx     $b3
        lda     #$09
        jsr     LevelUpHPMP
        lda     $289e
        and     #$1f
        sta     $b1
        ldx     #$03e7
        stx     $b3
        lda     #$0d
        jsr     LevelUpHPMP
        ldx     #$007f
        lda     #$ff
@f094:  sta     $291c,x
        dex
        bpl     @f094
        ldx     $a6
        lda     $1002,x
        sta     $b5
        lda     $1001,x
        and     #$0f
        sta     $af
        asl
        clc
        adc     $af
        tax
        stx     $b1
        stz     $b3
        stz     $9a
        stz     $9b
@f0b5:  ldx     $b1
        lda     f:SpellListTbl,x        ; spell lists for each character
        cmp     #$ff
        beq     @f0c2
        jsr     LevelUpMagic
@f0c2:  inc     $b1
        inc     $b3
        lda     $b3
        cmp     #3
        bne     @f0b5
        rts

; ------------------------------------------------------------------------------

; [ increase hp/mp at level up ]

LevelUpHPMP:
@f0cd:  sta     $b5
        stz     $b6
        longa
        clc
        lda     $a6
        adc     $b5
        sta     $b5
        shorta0
        clr_ax
        lda     $b1
        jsr     Lsr_3
        jsr     RandXA
        clc
        adc     $b1
        sta     $af
        lda     #0
        adc     #0
        sta     $b0
        longa
        ldx     $b5
        lda     $1000,x
        adc     $af
        cmp     $b3
        bcc     @f101
        lda     $b3
@f101:  sta     $1000,x
        shorta0
        rts

; ------------------------------------------------------------------------------

; [ update spell list at level up ]

LevelUpMagic:
@f108:  pha
        sta     $e5
        ldy     #.loword(SpellListLearned)
        lda     #^SpellListLearned
        jsr     GetScriptPtr
        tyx
        clr_ay
@f116:  lda     f:SpellListLearned,x
        sta     $289c,y
        inx
        iny
        cmp     #$ff
        bne     @f116
        clr_ax
@f125:  lda     $289c,x
        cmp     #$ff
        beq     @f13e
        cmp     $b5
        bne     @f13a
        ldy     $9a
        lda     $289d,x
        sta     $291c,y
        inc     $9a
@f13a:  inx2
        bra     @f125
@f13e:  pla
        sta     $df
        lda     #$18
        sta     $e1
        jsr     Mult8
        ldx     $e3
        clr_ay
        sty     $b7
@f14e:  lda     $1560,x
        bne     @f181
        lda     $291c,y
        sta     $b9
        cmp     #$ff
        beq     @f18a
        cmp     #$19
        bcs     @f166
        lda     $b3
        bne     @f181
        bra     @f17b
@f166:  cmp     #$31
        bcs     @f171
@f16a:  lda     $b3
        dec
        bne     @f181
        bra     @f17b
@f171:  cmp     #$42
        bcs     @f16a
        lda     $b3
        cmp     #$02
        bne     @f181
@f17b:  lda     $b9
        sta     $1560,x
        iny
@f181:  inx
        inc     $b7
        lda     $b7
        cmp     #$18
        bne     @f14e
@f18a:  rts

; ------------------------------------------------------------------------------

; [ restore character properties after battle ]

RestoreCharProp:
@f18b:  clr_axy
@f18e:  lda     $2041,x                 ; restore crit % and bonus
        sta     $202d,x
        lda     $2042,x
        sta     $202e,x
        lda     $38bf,y                 ; restore status
        sta     $2003,x
        lda     $38c0,y
        sta     $2004,x
        lda     $38c1,y
        sta     $2006,x
        jsr     NextObj
        iny3
        cpy     #$000f
        bne     @f18e
        clr_axy
        stz     $a9
@f1bc:  stz     $ab
@f1be:  lda     $2000,x                 ; copy character properties to sram
        sta     $1000,y
        inx
        iny
        inc     $ab
        lda     $ab
        cmp     #$40
        bne     @f1be
        longa
        txa
        clc
        adc     #$0040
        tax
        shorta0
        inc     $a9
        lda     $a9
        cmp     #5
        bne     @f1bc
        clr_axy
        stx     $a9
@f1e6:  lda     $321b,x                 ; copy inventory to sram
        sta     $1440,y
        beq     @f1f2
        cmp     #$60
        bne     @f1f8
@f1f2:  clr_a
        sta     $1440,y
        bra     @f1fb
@f1f8:  lda     $321c,x
@f1fb:  sta     $1441,y
        bne     @f204
        clr_a
        sta     $1440,y
@f204:  inx4
        iny2
        inc     $a9
        lda     $a9
        cmp     #$30
        bne     @f1e6
        jmp     InitCharRows

; ------------------------------------------------------------------------------
