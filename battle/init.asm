
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: init.asm                                                             |
; |                                                                            |
; | description: character and monster initialization                          |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

; [ init characters and monsters ]

InitObjects:
@8929:  lda     $1800
        cmp     #$b6
        beq     @8934
        cmp     #$b7
        bne     @893c
@8934:  lda     $1801
        beq     @893c       ; branch if not battle $01b7 (zeromus)
        inc     $3881
@893c:  jsr     LoadCharProp
        jsr     InitPoison
        jsr     InitCharRows
        lda     $29a2
        sta     $38e5
        and     #$20
        sta     $388b
        beq     @89af
        clr_ax
@8954:  lda     f:AutoBattleTbl,x   ; battles with auto-battle scripts
        cmp     $1800
        beq     @8966
        inx2
        cpx     #$0010
        bne     @8954
        bra     @89af
@8966:  stx     $84
        lda     f:AutoBattleTbl+1,x
        cmp     $1801
        bne     @89af
        txa
        lda     f:AutoBattlePtrs,x   ; pointers to auto-battle scripts
        sta     $80
        lda     f:AutoBattlePtrs+1,x
        sta     $81
        lda     #^AutoBattlePtrs
        sta     $82
        clr_ayx
@8985:  lda     [$80],y
        sta     $388c,x     ; load auto-battle script
        iny
        inx
        cmp     #$ff
        bne     @8985
        lda     $84
        cmp     #$0c
        beq     @899a
        cmp     #$0e
        bne     @89af
; has golbez script
@899a:  clr_ax
@899c:  lda     [$80],y
        sta     $389a,x     ; golbez' auto-battle script
        iny
        inx
        cmp     #$ff
        bne     @899c
        lda     #$63        ; monster slots 0 and 1 base agility = 99
        sta     $2190
        sta     $2210
@89af:  jsr     LoadEquipProp
        stz     $3975
@89b5:  lda     $3975
        tax
        lda     $3540,x
        bne     @89c1
        jsr     UpdateCharStats
@89c1:  inc     $3975
        lda     $3975
        cmp     #$05
        bne     @89b5
        clr_axy
        stx     $a9
        sty     $ab
@89d2:  lda     $a9
        jsr     SelectObj
        ldx     $a6
        lda     $2001,x
        and     #$0f
        sta     $b7
        asl
        clc
        adc     $b7
        sta     $b7
        stz     $b8
        stz     $b5
@89ea:  ldx     $b7
        lda     f:SpellListTbl,x   ; spell lists for each character
        cmp     #$ff
        bne     @8a03
        clc
        lda     $ab
        adc     #$60
        sta     $ab
        lda     $ac
        adc     #$00
        sta     $ac
        bra     @8a28
@8a03:  sta     $df
        lda     #$18
        sta     $e1
        jsr     Mult8
        ldx     $e3
        stz     $ad
        ldy     $ab
@8a12:  lda     f:$001560,x
        sta     $2c7b,y
        iny4
        inx
        inc     $ad
        lda     $ad
        cmp     #$18
        bne     @8a12
        sty     $ab
@8a28:  inc     $b7
        inc     $b5
        lda     $b5
        cmp     #$03
        beq     @8a35
        jmp     @89ea
@8a35:  inc     $a9
        lda     $a9
        cmp     #$05
        beq     @8a40
        jmp     @89d2
@8a40:  clr_ax
        stx     $a9
@8a44:  ldx     $a9
        lda     $2c7b,x
        beq     @8a6f
        tax
        stx     $e5
        ldx     #.loword(AttackProp)
        stx     $80
        lda     #^AttackProp
        sta     $82
        lda     #$06        ; size: 6 bytes
        jsr     LoadArrayItem
        ldx     $a9
        lda     $289c
        and     #$e0
        lsr
        sta     $2c7a,x
        lda     $28a1
        and     #$7f
        sta     $2c7d,x
@8a6f:  inx4
        stx     $a9
        cpx     #$05a0
        bne     @8a44
        clr_axy
@8a7d:  lda     $1440,x
        sta     $321b,y
        lda     $1441,x
.if BUGFIX_REV1
        bne     @8a86
        sta     $1440,x
        sta     $321b,y
        bra     @8a89
.endif
@8a86:  sta     $321c,y
@8a89:  inx2
        iny4
        cpx     #$0060
        bne     @8a7d
        clr_ax
        stx     $a9
@8a98:  stz     $c7
        ldx     $a9
        lda     $321b,x
        beq     @8b14
        cmp     #$de
        bcs     @8b14
        cmp     #$b0
        bcs     @8aed
        cmp     #$6d
        bcs     @8b14
        cmp     #$61
        bcc     @8ab5
        lda     #$00
        beq     @8b11
@8ab5:  tax
        stx     $e5
        ldx     #.loword(EquipProp)
        stx     $80
        lda     #^EquipProp
        sta     $82
        lda     #$08        ; size: 8 bytes
        jsr     LoadArrayItem
        lda     $289c
        jsr     Lsr_3
        and     #$08
        sta     $c7
        lda     $289f
        pha
        tax
        stx     $e5
        ldx     #.loword(AttackProp)
        stx     $80
        lda     #^AttackProp
        sta     $82
        lda     #$06        ; size: 6 bytes
        jsr     LoadArrayItem
        ldx     $a9
        pla
        sta     $321d,x
        bra     @8b09
@8aed:  sec
        sbc     #$b0
        tax
        stx     $e5
        ldx     #.loword(ItemProp)
        stx     $80
        lda     #^ItemProp
        sta     $82
        lda     #$06        ; size: 6 bytes
        jsr     LoadArrayItem
        ldx     $a9
        lda     $289f
        sta     $321d,x
@8b09:  lda     $289c
        and     #$e0
        ora     $c7
        lsr
@8b11:  sta     $321a,x
@8b14:  inx4
        stx     $a9
        cpx     #$00c0
        beq     @8b22
        jmp     @8a98
@8b22:  clr_ax
        stx     $a9
@8b26:  stz     $c7
        ldx     $a9
        lda     $32db,x
        beq     @8b70
        tax
        stx     $e5
        ldx     #.loword(EquipProp)
        stx     $80
        lda     #^EquipProp
        sta     $82
        lda     #$08
        jsr     LoadArrayItem
        lda     $289c
        jsr     Lsr_3
        and     #$08
        sta     $c7
        ldx     $a9
        lda     $289f
        sta     $32dd,x
        tax
        stx     $e5
        ldx     #.loword(AttackProp)
        stx     $80
        lda     #^AttackProp
        sta     $82
        lda     #$06
        jsr     LoadArrayItem
        ldx     $a9
        lda     $289c
        and     #$e0
        ora     $c7
        lsr
        sta     $32da,x
@8b70:  inx4
        stx     $a9
        cpx     #$0028
        bne     @8b26
        clr_ay
        sty     $a9
@8b7f:  ldx     $a9
        lda     $2000,x
        and     #$1f
        bne     @8b89
        inc
@8b89:  dec
        sta     $df
        lda     #$05
        sta     $e1
        jsr     Mult8
        lda     #$05
        sta     $ab
        ldx     $e3
@8b99:  lda     f:ClassCmd,x            ; battle commands for each class
        sta     $3303,y
        cmp     #$ff
        bne     @8ba7
        phx
        bra     @8bad
@8ba7:  phx
        tax
        lda     f:CmdTargetTbl,x   ; command targeting flags
@8bad:  sta     $3302,y
        plx
        inx
        iny4
        dec     $ab
        lda     $ab
        bne     @8b99
        lda     #$1a
        sta     $3303,y
        iny4
        lda     #$1b
        sta     $3303,y
        iny4
        php
        longa
        clc
        lda     $a9
        adc     #$0080
        sta     $a9
        clr_a
        plp
.a8
        cpy     #$008c
        bne     @8b7f
        clr_ax
        stx     $b9
@8be4:  stz     $bd
        ldx     $b9
        lda     $29b5,x
        cmp     #$ff
        bne     @8bf9
        txa
        clc
        adc     #$05
        tax
        inc     $3540,x
        bra     @8c0e
@8bf9:  tax
        lda     $299c
        jsr     CheckBit
        beq     @8c04
        inc     $bd
@8c04:  lda     $29ad,x
        sta     $bb
        stz     $bc
        jsr     InitMonster
@8c0e:  inc     $b9
        lda     $b9
        cmp     #$08
        bne     @8be4
        lda     $29a0
        and     #$03
        beq     @8c66
        cmp     #$01
        bne     @8c32
        clr_ax
@8c23:  lda     $29b5,x
        cmp     #$01
        beq     @8c2d
        inx
        bra     @8c23
@8c2d:  jsr     HideMonster
        bra     @8c66
@8c32:  cmp     #$02
        bne     @8c4c
        clr_ax
        stx     $c7
@8c3a:  ldx     $c7
        lda     $29b5,x
        beq     @8c48
        cmp     #$ff
        beq     @8c66
        jsr     HideMonster
@8c48:  inc     $c7
        bra     @8c3a
@8c4c:  clr_ax
        stx     $c7
@8c50:  ldx     $c7
        lda     $29b5,x
        cmp     #$ff
        beq     @8c66
        cmp     #$02
        bne     @8c62
        beq     @8c5f
@8c5f:  jsr     HideMonster
@8c62:  inc     $c7
        bra     @8c50
@8c66:  lda     $3581
        and     #$08
        beq     @8c75
        lda     #$80
        sta     $38d8
@8c72:  jmp     @8d44
@8c75:  lda     $3582
        bne     @8c72       ; branch if a boss battle
        lda     $38e5
        and     #$01
        bne     @8c72
        lda     $38ef
        bne     @8c72
        clr_axy
        stx     $a9
        stx     $ab
        stx     $ad
@8c8f:  lda     $3540,y
        bne     @8ca4
        clc
        lda     $2002,x
        adc     $a9
        sta     $a9
        lda     #$00
        adc     $aa
        sta     $aa
        inc     $ad
@8ca4:  jsr     NextObj
        iny
        cpy     #5
        bne     @8c8f
@8cad:  lda     $3540,y
        bne     @8cc2
        clc
        lda     $2002,x
        adc     $ab
        sta     $ab
        lda     #$00
        adc     $ac
        sta     $ac
        inc     $ae
@8cc2:  jsr     NextObj
        iny
        cpy     #8
        bne     @8cad
        ldx     $a9
        stx     $3945
        lda     $ad
        tax
        stx     $3947
        jsr     Div16
        ldx     $3949
        txa
        sta     $38d4
        clr_a
        ldx     $ab
        stx     $3945
        lda     $ae
        tax
        stx     $3947
        jsr     Div16
        ldx     $3949
        txa
        sta     $38d5
        clr_a
        clr_ax
        stx     $a9
        inc     $a9
        inc     $aa
        lda     #99
        jsr     RandXA
        cmp     $38d4
        bcs     @8d0b
        inc     $a9
@8d0b:  jsr     Rand99
        cmp     $38d5
        bcs     @8d15
        inc     $aa
@8d15:  lda     $a9
        cmp     $aa
        beq     @8d44
        bcc     @8d25
        inc     $38d7
        inc     $38d8
        bra     @8d44
@8d25:  lda     #$80
        sta     $38d7
        sta     $38d8
        lda     $38d5
        lsr
        sta     $a9
        clr_ax
        lda     $38d4
        jsr     RandXA
        cmp     $a9
        bcs     @8d44
        lda     #$08
        sta     $3581
@8d44:  clr_axy
        stx     $c7
@8d49:  lda     $3540,y
        bne     @8d5f
        lda     $c7
        bne     @8d7a
        lda     $2000,x
        and     #$1f
        cmp     #$01
        beq     @8d7a
        cmp     #$0b
        beq     @8d77
@8d5f:  longa
        txa
        clc
        adc     #$0080
        tax
        shorta0
        iny
        cpy     #5
        bne     @8d49
        inc     $c7
        clr_axy
        bra     @8d49
@8d77:  sty     $355e
@8d7a:  lda     $2015,x
        tax
        stx     $393d
        ldx     #$0032
        stx     $393f
        jsr     Mult16
        ldx     $3941
        stx     $cb
        clr_ax
        stx     $c7
        stx     $c9
@8d95:  ldx     $c9
        lda     $3540,x
        bne     @8dcd
        ldx     $c7
        lda     $2015,x
        sta     $df
        lda     #$0a
        sta     $e1
        jsr     Mult8
        ldx     $cb
        stx     $3945
        ldx     $e3
        stx     $3947
        jsr     Div16
        ldx     $3949
        bne     @8dbf
        inc     $3949
@8dbf:  ldx     $c7
        lda     $3949
        sta     $2060,x
        lda     $394a
        sta     $2061,x
@8dcd:  longa
        clc
        lda     $c7
        adc     #$0080
        sta     $c7
        shorta0
        inc     $c9
        lda     $c9
        cmp     #$0d
        bne     @8d95
        clr_ax
        stx     $c7
@8de6:  ldx     $c7
        lda     $3540,x
        bne     @8e53
        txa
        sta     $df
        lda     #$80
        sta     $e1
        jsr     Mult8
        ldx     $e3
        lda     $2003,x
        bmi     @8e53
        lda     $c7
        cmp     #$05
        bcs     @8e1d
        lda     $3581
        and     #$08
        beq     @8e1d
        lda     $2001,x
        pha
        and     #$7f
        sta     $a9
        pla
        and     #$80
        eor     #$80
        ora     $a9
        sta     $2001,x
@8e1d:  stz     $d6
        ldx     $c7
        txa
        jsr     CalcTimerDur
        lda     $38d8
        beq     @8e4e
        bmi     @8e42
        lda     $c7
        cmp     #$05
        bcc     @8e48
@8e32:  asl     $d4
        rol     $d5
        lda     $d4
        ora     $d5
        bne     @8e4e
        inc2
        sta     $d4
        bra     @8e4e
@8e42:  lda     $c7
        cmp     #$05
        bcc     @8e32
@8e48:  lda     #$01        ; duration: 1
        sta     $d4
        stz     $d5
@8e4e:  lda     #$03        ; action timer
        jsr     SetTimer
@8e53:  inc     $c7
        lda     $c7
        cmp     #$0d
        bne     @8de6
        longa
        lda     #$ffff
        sta     $a9
        ldy     #13
        clr_ax
@8e67:  lda     $2a07,x
        beq     @8e72
        cmp     $a9
        bcs     @8e72
        sta     $a9
@8e72:  txa
        clc
        adc     #$0015
        tax
        dey
        bne     @8e67
        dec     $a9
        tyx
@8e7e:  sec
        lda     $2a07,x
        beq     @8e89
        sbc     $a9
        sta     $2a07,x
@8e89:  txa
        clc
        adc     #$0015
        tax
        iny
        cpy     #13
        bne     @8e7e
        shorta0
        rts

; ------------------------------------------------------------------------------

; [ hide monster ]

HideMonster:
@8e99:  txa
        clc
        adc     #$05
        sta     $8a
        lda     $29b5,x     ; save monster type
        sta     $a9
        lda     #$ff
        sta     $29b5,x     ; clear monster type
        lda     $a9
        tax
        dec     $29ca,x     ; decrement monster type count
        dec     $29cd       ; decrement total monster count
        lda     $8a
        sta     $df
        lda     #$80
        sta     $e1
        jsr     Mult8
        ldx     $e3
        lda     #$80
        sta     $2003,x     ; set dead status
        lda     $8a
        asl
        tax
        stz     $29eb,x     ; disable all timers
        rts

; ------------------------------------------------------------------------------

; [ load equipment properties ]

LoadEquipProp:
@8ecc:  ldy     #$2030      ; equipment in character properties
        sty     $86
        ldy     #$2780      ; pointer to equipment properties
        sty     $84
        stz     $a9
; start of character loop
@8ed8:  clr_ax
        stx     $ab
        txy
@8edd:  lda     ($86),y     ; item id
        bne     @8ee3
        lda     #$60        ; empty armor slot
@8ee3:  sta     $ad,x
        iny
        inx
        cpx     #3          ; copy helmet, armor, and accessory
        bne     @8edd
@8eec:  lda     ($86),y
        sta     $ad,x
        iny
        inx
        cpx     #7          ; copy left and right hand item and qty
        bne     @8eec
        lda     $a9
        jsr     Asl_3
        tax
        lda     $b0
        sta     $32db,x     ; left hand item
        lda     $b1
        sta     $32dc,x     ; left hand quantity
        lda     $b2
        sta     $32df,x     ; right hand item
        lda     $b3
        sta     $32e0,x     ; right hand quantity
        lda     $b2
        sta     $b1
        stz     $b7
        stz     $b8
        lda     $b0
        beq     @8f33       ; branch if no left hand item
        cmp     #$4d
        bcc     @8f33       ; branch if a weapon
        cmp     #$54
        bcs     @8f2b       ; branch if not a bow
        lda     #$80
        sta     $b7
        bra     @8f33
@8f2b:  cmp     #$61
        bcs     @8f33       ; branch if not arrows
        lda     #$40
        sta     $b7
@8f33:  lda     $b1
        beq     @8f4d       ; branch if no right hand item
        cmp     #$4d
        bcc     @8f4d
        cmp     #$54
        bcs     @8f45
        lda     #$80
        sta     $b8
        bra     @8f4d
@8f45:  cmp     #$61
        bcs     @8f4d
        lda     #$40
        sta     $b8
@8f4d:  lda     $b7
        ora     $b8
        beq     @8f5b       ; branch if no bow or arrows
        eor     #$c0
        beq     @8f5b       ; branch if not both bow and arrow
        stz     $b0         ; treat as unarmed
        stz     $b1
; start of equipment slot loop
@8f5b:  ldx     $ab
        lda     $ad,x       ; item id
        tax
        stx     $e5
        ldx     #.loword(EquipProp)
        stx     $80
        lda     #^EquipProp
        sta     $82
        lda     #$08
        jsr     LoadArrayItem
        clr_axy
@8f73:  lda     $289c,x     ; copy to equipment data
        sta     ($84),y
        iny
        inx
        cpx     #8
        bne     @8f73
        lda     $28a0       ; element/status effect
        and     #$7f
        sta     $df
        lda     #$03
        sta     $e1
        jsr     Mult8
        ldx     $e3
@8f8f:  lda     f:ElementStatus,x   ; element/status effects
        sta     ($84),y
        iny
        inx
        cpy     #11
        bne     @8f8f
        clc                 ; next equipment slot
        lda     $84
        adc     #$0b
        sta     $84
        lda     $85
        adc     #$00
        sta     $85
        inc     $ab
        lda     $ab
        cmp     #$05
        bne     @8f5b
        clc                 ; next character
        lda     $86
        adc     #$80
        sta     $86
        lda     $87
        adc     #$00
        sta     $87
        inc     $a9
        lda     $a9
        cmp     #$05
        beq     @8fc9
        jmp     @8ed8
@8fc9:  rts

; ------------------------------------------------------------------------------

; [ init monster properties ]

InitMonster:
@8fca:  lda     $b9
        sta     $35a0
        asl
        clc
        adc     #$0a
        tax
        lda     #$40                    ; enable action timer
        sta     $29eb,x
        longa
        lda     $bb
        asl
        tax
        sec
        lda     f:MonsterPropPtrs,x
        sbc     #.loword(MonsterProp)
        tax
        shorta0
        clr_ay
@8fed:  lda     f:MonsterProp,x
        sta     $289c,y
        inx
        iny
        cpy     #$0014
        bne     @8fed
        clc
        lda     $35a0
        adc     #$05
        jsr     SelectObj
        ldx     $a6
        lda     $bd
        beq     @901e
        lda     #$20
        sta     $2005,x
        phx
        lda     $35a0
        tax
        lda     $29b5,x
        tax
        lda     #$01
        sta     $38d0,x
        plx
@901e:  lda     $289c
        sta     $2070,x     ; monster level and boss flag
        bpl     @9029
        inc     $3582       ; boss flag
@9029:  and     #$7f
        sta     $2002,x     ; monster level
        clc
        adc     #$0a
        sta     $202f,x     ; monster level + 10
        lda     $289d
        sta     $2007,x
        sta     $2009,x
        lda     $289e
        sta     $2008,x
        sta     $200a,x
        longa
        lda     $289d
        jsr     Lsr_4
        sta     $200b,x
        sta     $200d,x
        shorta0
        phx
        lda     $28a2
        and     #$3f
        asl
        tax
        lda     f:MonsterAgility+1,x
        sta     $a9
        lda     f:MonsterAgility,x
        tax
        lda     $a9
        jsr     RandXA
        plx
        sta     $2015,x
        lda     $29a2
        and     #$20
        beq     @9081
        lda     #$01        ; auto-battle speed modifier
        sta     $203b,x
        bra     @9086
@9081:  lda     #$10        ; normal speed modifier
        sta     $203b,x
@9086:  lda     $28a4
        sta     $35a1
        phx
        lda     $b9
        tax
        lda     $29b5,x
        tax
        lda     $bb
        sta     $358b,x
        sta     $3588,x
        lda     $28a3
        sta     $358e,x
        plx
        sta     $2073,x     ; monster item set and drop rate
        lda     $289f
        jsr     LoadMonsterStat
        lda     $291c
        sta     $201b,x
        lda     $291d
        sta     $201c,x
        lda     $291e
        sta     $201d,x
        lda     $28a0
        jsr     LoadMonsterStat
        lda     $291c
        sta     $2028,x
        lda     $291d
        sta     $202a,x
        lda     $291e
        sta     $202a,x
        lda     $28a1
        jsr     LoadMonsterStat
        lda     $291c
        sta     $2022,x
        lda     $291d
        sta     $2024,x
        lda     $291e
        sta     $2024,x
        lda     $28a5
        bne     @90f6
        jmp     @92e5
@90f6:  clr_ay
        lda     $28a5
        and     #$80
        beq     @9114
        lda     $28a6,y
        sta     $2019,x
        iny
        lda     $28a6,y
        sta     $201e,x
        iny
        lda     $28a6,y
        sta     $201f,x
        iny
@9114:  lda     $28a5
        and     #$40
        beq     @9137
        lda     $28a6,y
        bpl     @9125
        sta     $2026,x
        bra     @9128
@9125:  sta     $2025,x
@9128:  iny
        lda     $28a6,y
        sta     $202b,x
        iny
        lda     $28a6,y
        sta     $202c,x
        iny
@9137:  lda     $28a5
        and     #$20
        beq     @9153
        lda     $28a6,y
        bpl     @9146
        sta     $2021,x
@9146:  sta     $2020,x
        iny
        and     #$20
        beq     @9153
        lda     #$40
        sta     $2004,x
@9153:  lda     $28a5
        and     #$10
        beq     @916a
        lda     $28a6,y
        sta     $2012,x
        sta     $2013,x
        sta     $2017,x
        sta     $2018,x
        iny
@916a:  lda     $28a5
        and     #$08
        beq     @9178
        lda     $28a6,y
        sta     $2040,x
        iny
@9178:  lda     $28a5
        and     #$04
        bne     @9182
        jmp     @92e5
@9182:  lda     $35a0
        tax
        inc     $38aa,x
        lda     $28a6,y
        sta     $35a2
        lda     $35a0
        sta     $df
        lda     #$14
        sta     $e1
        jsr     Mult8
        lda     $35a2
        sta     $e5
        ldy     #.loword(AIScript)
        lda     #^AIScript
        jsr     GetScriptPtr
        tyx
        ldy     $e3
        sty     $98
        sty     $9c
@91af:  lda     f:AIScript,x
        sta     $531f,y
        inx
        iny
        cmp     #$ff
        bne     @91af
        lda     $35a0
        sta     $df
        lda     #$28
        sta     $e1
        jsr     Mult8
        ldy     $e3
        sty     $9a
        sty     $9e
@91ce:  ldx     $98
        lda     $531f,x
        cmp     #$ff
        beq     @920c
        sta     $e5
        ldy     #.loword(AICondScript)
        lda     #^AICondScript
        jsr     GetScriptPtr
        tyx
        ldy     $9a
        lda     #$04
        sta     $a9
@91e8:  lda     f:AICondScript,x
        sta     $53bf,y
        cmp     #$ff
        beq     @91f4
        inx
@91f4:  iny
        dec     $a9
        lda     $a9
        bne     @91e8
        sty     $9a
        clc
        lda     $98
        adc     #$02
        sta     $98
        lda     $99
        adc     #$00
        sta     $99
        bra     @91ce
@920c:  lda     $35a0
        sta     $df
        lda     #$a0
        sta     $e1
        jsr     Mult8
        ldy     $e3
        sty     $9a
        lda     #$0a
        sta     $ab
@9220:  lda     #$04
        sta     $a9
@9224:  ldx     $9e
        lda     $53bf,x
        cmp     #$ff
        beq     @924d
        sta     $df
        lda     #$04
        sta     $e1
        jsr     Mult8
        ldx     $e3
        ldy     $9a
        lda     #$04
        sta     $aa
@923e:  lda     f:AICond,x
        sta     $54ff,y
        inx
        iny
        dec     $aa
        lda     $aa
        bne     @923e
@924d:  clc
        lda     $9a
        adc     #4
        sta     $9a
        lda     $9b
        adc     #0
        sta     $9b
        clc
        lda     $9e
        adc     #1
        sta     $9e
        lda     $9f
        adc     #0
        sta     $9f
        dec     $a9
        lda     $a9
        bne     @9224
        dec     $ab
        lda     $ab
        bne     @9220
        lda     $35a0
        tax
        stx     $393d
        ldx     #$0258
        stx     $393f
        jsr     Mult16
        ldy     $3941
        sty     $9a
@9288:  ldx     $9c
        lda     $531f,x
        cmp     #$ff
        beq     @92e5
        inx
        lda     $531f,x
        sta     $e5
        ldy     #.loword(AIAction1)
        lda     $38ef
        beq     @92a2
        ldy     #.loword(AIAction2)
@92a2:  lda     #^AIAction1
        jsr     GetScriptPtr
        lda     $38ef
        bne     @92be
        tyx
        ldy     $9a
@92af:  lda     f:AIAction1,x
        sta     $59ff,y
        inx
        iny
        cmp     #$ff
        bne     @92af
        bra     @92ce
@92be:  tyx
        ldy     $9a
@92c1:  lda     f:AIAction2,x
        sta     $59ff,y
        inx
        iny
        cmp     #$ff
        bne     @92c1
@92ce:  longa
        clc
        lda     $9a
        adc     #$003c
        sta     $9a
        clc
        lda     $9c
        adc     #2
        sta     $9c
        shorta0
        bra     @9288
@92e5:  lda     $35a0
        sta     $df
        lda     #$14
        sta     $e1
        jsr     Mult8
        lda     $35a1
        sta     $e5
        ldy     #.loword(AIScript)
        lda     #^AIScript
        jsr     GetScriptPtr
        tyx
        ldy     $e3
        sty     $98
        sty     $9c
@9305:  lda     f:AIScript,x
        sta     $397f,y
        inx
        iny
        cmp     #$ff
        bne     @9305
        lda     $35a0
        sta     $df
        lda     #$28
        sta     $e1
        jsr     Mult8
        ldy     $e3
        sty     $9a
        sty     $9e
@9324:  ldx     $98
        lda     $397f,x
        cmp     #$ff
        beq     @9362
        sta     $e5
        ldy     #.loword(AICondScript)
        lda     #^AICondScript
        jsr     GetScriptPtr
        tyx
        ldy     $9a
        lda     #$04
        sta     $a9
@933e:  lda     f:AICondScript,x
        sta     $3a1f,y
        cmp     #$ff
        beq     @934a
        inx
@934a:  iny
        dec     $a9
        lda     $a9
        bne     @933e
        sty     $9a
        clc
        lda     $98
        adc     #$02
        sta     $98
        lda     $99
        adc     #$00
        sta     $99
        bra     @9324
@9362:  lda     $35a0
        sta     $df
        lda     #$a0
        sta     $e1
        jsr     Mult8
        ldy     $e3
        sty     $9a
        lda     #$0a
        sta     $ab
@9376:  lda     #$04
        sta     $a9
@937a:  ldx     $9e
        lda     $3a1f,x
        cmp     #$ff
        beq     @93a3
        sta     $df
        lda     #$04
        sta     $e1
        jsr     Mult8
        ldx     $e3
        ldy     $9a
        lda     #$04
        sta     $aa
@9394:  lda     f:AICond,x
        sta     $3b5f,y
        inx
        iny
        dec     $aa
        lda     $aa
        bne     @9394
@93a3:  clc
        lda     $9a
        adc     #$04
        sta     $9a
        lda     $9b
        adc     #$00
        sta     $9b
        clc
        lda     $9e
        adc     #$01
        sta     $9e
        lda     $9f
        adc     #$00
        sta     $9f
        dec     $a9
        lda     $a9
        bne     @937a
        dec     $ab
        lda     $ab
        bne     @9376
        lda     $35a0
        tax
        stx     $393d
        ldx     #$0258
        stx     $393f
        jsr     Mult16
        ldy     $3941
        sty     $9a
        sty     $2896
@93e1:  ldx     $9c
        lda     $397f,x
        cmp     #$ff
        beq     @943e
        inx
        lda     $397f,x
        sta     $e5
        ldy     #.loword(AIAction1)
        lda     $38ef
        beq     @93fb
        ldy     #.loword(AIAction2)
@93fb:  lda     #^AIAction1
        jsr     GetScriptPtr
        lda     $38ef
        bne     @9417
        tyx
        ldy     $9a
@9408:  lda     f:AIAction1,x
        sta     $405f,y
        inx
        iny
        cmp     #$ff
        bne     @9408
        bra     @9427
@9417:  tyx
        ldy     $9a
@941a:  lda     f:AIAction2,x
        sta     $405f,y
        inx
        iny
        cmp     #$ff
        bne     @941a
@9427:  longa
        clc
        lda     $9a
        adc     #$003c
        sta     $9a
        clc
        lda     $9c
        adc     #2
        sta     $9c
        shorta0
        bra     @93e1
@943e:  lda     $35a0
        sta     $df
        lda     #$14
        sta     $e1
        jsr     Mult8
        ldx     $e3
        clr_ay
        sty     $a9
@9450:  lda     $397f,x
        beq     @945d
        inx2
        inc     $a9
        inc     $a9
        bra     @9450
@945d:  lda     $a9
        lsr
        pha
        lda     $35a0
        tax
        pla
        sta     $3604,x
        sta     $df
        lda     #$3c
        sta     $e1
        jsr     Mult8
        lda     $35a0
        asl
        tax
        clc
        lda     $2896
        adc     $e3
        sta     $360c,x
        lda     $2897
        adc     $e4
        sta     $360d,x
        rts

; ------------------------------------------------------------------------------

; [ load monster attack/defense values ]

LoadMonsterStat:
@9489:  phx
        sta     $df
        lda     #3
        sta     $e1
        jsr     Mult8
        ldx     $e3
        ldy     #$0080
@9498:  lda     f:MonsterStats,x
        sta     $289c,y
        inx
        iny
        cpy     #$0083
        bne     @9498
        plx
        rts

; ------------------------------------------------------------------------------

; [ load character properties ]

LoadCharProp:
@94a8:  ldx     #$2000
        stx     $80
        clr_ax
        stz     $a9
@94b1:  clr_ay
@94b3:  lda     $1000,x
        sta     ($80),y
        inx
        iny
        cpy     #$0040
        bne     @94b3
        phx
        clr_ay
        lda     ($80),y
        and     #$1f
        bne     @94e0
        lda     $a9
        tax
        inc     $3540,x
        ldy     #$0003
        clr_a
        sta     ($80),y
        iny
        sta     ($80),y
        iny
        sta     ($80),y
        iny
        sta     ($80),y
        jmp     @9566
@94e0:  ldy     #$0003
        lda     ($80),y
        and     #$c0
        bne     @9566
        lda     $a9
        asl
        tax
        lda     #$40        ; enable action timer
        sta     $29eb,x
        longa
        ldy     #$0009
        lda     ($80),y
        jsr     Lsr_2
        ldy     #$0007
        cmp     ($80),y
        bcc     @950f
        ldy     #$0005
        lda     ($80),y
        ora     #$0100
        sta     ($80),y
        bra     @9519
@950f:  ldy     #$0005
        lda     ($80),y
        and     #$feff
        sta     ($80),y
@9519:  shorta0
        ldy     #$003b
        lda     #$10
        sta     ($80),y
        lda     $29a2
        and     #$20
        beq     @952e
        lda     #$01
        sta     ($80),y
@952e:  ldy     #$002d
        lda     ($80),y
        ldy     #$0041
        sta     ($80),y
        ldy     #$002e
        lda     ($80),y
        ldy     #$0042
        sta     ($80),y
        ldy     #$0004
        lda     ($80),y
        and     #$40
        sta     ($80),y
        iny
        lda     ($80),y
        and     #$82
        sta     ($80),y
        iny
        lda     ($80),y
        and     #$01
        sta     ($80),y
        ldy     #$0002
        lda     ($80),y
        cmp     $3583
        bcs     @9566
        sta     $3583
@9566:  plx
        ldy     #$0007
        lda     ($80),y
        ldy     #$0008
        ora     ($80),y
        bne     @957c
        ldy     #$0003
        lda     ($80),y
        ora     #$80
        sta     ($80),y
@957c:  clc
        lda     $80
        adc     #$80
        sta     $80
        lda     $81
        adc     #$00
        sta     $81
        inc     $a9
        lda     $a9
        cmp     #$05
        beq     @9594
        jmp     @94b1
@9594:  ldx     #$2000
        stx     $80
        clr_ayx
        sty     $a9
@959e:  lda     ($80),y
        and     #$1f
        cmp     #$08        ; palom
        beq     @95b2
        cmp     #$09        ; porom
        beq     @95b2
        cmp     #$13        ; fusoya
        beq     @95b2
        cmp     #$15        ; golbez
        bne     @95b8
@95b2:  lda     $a9
        sta     $3539,x
        inx
@95b8:  longa
        clc
        lda     $80
        adc     #$0080
        sta     $80
        shorta0
        inc     $a9
        lda     $a9
        cmp     #$05
        bne     @959e
        rts

; ------------------------------------------------------------------------------

; [ init character rows ]

InitCharRows:
@95ce:  lda     $16a8       ; row setting
        bne     @95fc
        lda     $2001
        and     #$7f
        sta     $2001
        lda     $2081
        and     #$7f
        sta     $2081
        lda     $2101
        and     #$7f
        sta     $2101
        lda     $2181
        ora     #$80
        sta     $2181
        lda     $2201
        ora     #$80
        sta     $2201
        rts
@95fc:  lda     $2001
        ora     #$80
        sta     $2001
        lda     $2081
        ora     #$80
        sta     $2081
        lda     $2101
        ora     #$80
        sta     $2101
        lda     $2181
        and     #$7f
        sta     $2181
        lda     $2201
        and     #$7f
        sta     $2201
        rts

; ------------------------------------------------------------------------------

; [ init poison timers ]

InitPoison:
@9625:  clr_ax
        stx     $cd
@9629:  ldx     $cd
        lda     $3540,x
        bne     @966e
        ldx     $cd
        stx     $df
        ldx     #$0080
        stx     $e1
        jsr     Mult8
        ldx     $e3
        lda     $2003,x
        and     #$01
        beq     @966e
        lda     #$06
        sta     $d6
        lda     $cd
        jsr     CalcTimerDur
        lda     #$09        ; poison timer
        jsr     SetTimer
        lda     #$40
        sta     $2a06,x     ; do timer effect when timer expires
        lda     $cd
        asl
        tax
        lda     $29eb,x     ; enable poison timer
        ora     #$10
        sta     $29eb,x
        lda     $d4
        sta     $2b2a,x
        lda     $d5
        sta     $2b2b,x
@966e:  inc     $cd
        lda     $cd
        cmp     #$05
        bne     @9629
        rts

; ------------------------------------------------------------------------------
