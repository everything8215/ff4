
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: cmd.asm                                                              |
; |                                                                            |
; | description: battle command routines (other than fight and magic)          |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

; [ battle command $14: search (peep) ]

Cmd_14:
@e156:  lda     $2770
        bpl     @e15e       ; branch if not a boss
        jmp     @e1b4
@e15e:  longa
        lda     $2707
        sta     $359a
        lda     $2709
        sta     $359d
        shorta0
        stz     $359c
        stz     $359f
        lda     $2720
        and     $2725
        eor     #$ff
        and     $2720
        and     #$3f
        sta     $a9
        bne     @e18d
        lda     #$14
        sta     $34cb
        bra     @e1a2
@e18d:  clr_axy
@e190:  lsr     $a9
        bcc     @e19c
        tya
        clc
        adc     #$15
        sta     $34cb,x
        inx
@e19c:  iny
        cpy     #6
        bne     @e190
@e1a2:  jsr     AddMsg2
        lda     #$1e        ; target's hp text
        sta     $34ca
        lda     #$14
        sta     $34c8       ; set command name
        lda     #$10
        sta     $34c7       ; show command name
@e1b4:  rts

; ------------------------------------------------------------------------------

; [ battle command $24: run away ]

Cmd_24:
@e1b5:  lda     #$04
        sta     $38e6
        ldx     $a6
        lda     $2003,x
        ora     #$80
        sta     $2003,x
        lda     #$05
        sta     $34ca
        inc     $390a
        jmp     AddMsg1

; ------------------------------------------------------------------------------

; [ battle command $17: steal (sneak) ]

; steal rate is (attacker level + 50) - (monster level + 10)
; so 40% if attacker and monster are at the same level
; after a failed steal, there is a (monster level + 10) chance
; that edge takes damage of (max hp) / 16

Cmd_17:
@e1cf:  lda     #$17
        sta     $34c8       ; set command name
        lda     #$10
        sta     $34c7       ; show command name
        lda     #$f8        ; display text
        sta     $33c6
        lda     #$04        ; damage numerals
        sta     $33c7
        jsr     AddMsg3
        lda     $ce
        bmi     @e1ed       ; branch if monster target
        jmp     @e23c
@e1ed:  jsr     Rand99
        sta     $a9
        clc
        lda     #$32
        adc     $2682       ; attacker level + 50
        sec
        sbc     $272f       ; subtract (monster level + 10)
        bcs     @e202
        lda     #$01        ; min 1
        bra     @e208
@e202:  cmp     #$63        ; max 99
        bcc     @e208
        lda     #$63
@e208:  cmp     $a9         ; compare to random value
        bcs     @e242
        jsr     Rand99
        cmp     $272f
        bcc     @e23c       ; branch if less than (monster level + 10)
; steal failed and caught by monster
        longa
        lda     $2689       ; attacker max hp / 16
        jsr     Lsr_4
        sta     $a9
        lda     #0
        shorta
        lda     $cd
        jsr     GetDmgPtr
        lda     $a9
        sta     $34d4,x
        lda     $aa
        sta     $34d5,x
        jsr     ApplyDmg
        lda     #$1c        ; モンスターにみつかった (caught by the monster)
        sta     $34ca
        bra     @e241
; steal failed
@e23c:  lda     #$1b        ; ぬすみそこなった (couldn't steal)
        sta     $34ca
@e241:  rts
; steal succeeded
@e242:  lda     $2773       ; item drop rate
        and     #$c0
        cmp     #$c0
        bne     @e24c       ; branch if nonzero
        rts
@e24c:  clr_a
        inc
        sta     $aa         ; qty: 1
        lda     $2773       ; monster item set
        and     #$3f
        jsr     Asl_2
        tax
        lda     f:MonsterItems,x        ; monster items (always choose 1st item)
        beq     @e23c       ; branch if no item
        sta     $a9
        cmp     #$61
        bcs     @e26d
        cmp     #$54
        bcc     @e26d
        lda     #$0a        ; qty: 10 (arrows)
        sta     $aa
@e26d:  clr_ax
        txy
@e270:  lda     $321b,x     ; find item in inventory
        cmp     $a9
        beq     @e2a4
@e277:  inx4
        iny
        cpy     #$0030
        bne     @e270
        lda     $38f4
        cmp     #$ff
        beq     @e23c       ; branch if no empty inventory slots
        tay
        longa
        asl2
        tax
        shorta0
        lda     $aa
        sta     $321c,x     ; add item to inventory
        lda     $a9
        sta     $321b,x
        stx     $ab
        phy
        jsr     LoadStolenItemProp
        ply
        bra     @e2c4
; item already in inventory
@e2a4:  clc
        lda     $321c,x     ; add to quantity
        adc     $aa
        cmp     #$64
        bcc     @e2c1
        pha
        lda     #$63        ; max 99
        sta     $321c,x
        jsr     DrawStolenItem
        pla
        sec
        sbc     #$63        ; try to put overflow in another slot
        beq     @e2c4
        sta     $aa
        bra     @e277
@e2c1:  sta     $321c,x
@e2c4:  jsr     DrawStolenItem
        lda     $a9
        sta     $359a       ; item id for message display
        lda     #$1d        ; <item>を　ぬすんだ (stole item)
        sta     $34ca
        rts

; ------------------------------------------------------------------------------

; [ draw stolen item text in inventory ]

DrawStolenItem:
@e2d2:  phx
        phy
        tya
        sta     $01
        lda     #$06        ; battle graphics $06: draw inventory item text
        jsr     ExecBtlGfx
        ply
        plx
        rts

; ------------------------------------------------------------------------------

; [ battle command $0a: salve ]

Cmd_0a:
@e2df:  lda     #$c1
        sta     $33c4
        clr_axy
@e2e7:  lda     $321b,x
        cmp     #$ce
        beq     @e302
        iny
        inx4
        cpx     #$00c0
        bne     @e2e7
@e2f8:  jsr     AddMsg2
        lda     #$0f
        sta     $34ca
        bra     @e344
@e302:  lda     $321a,x
        and     #$7f
        sta     $321a,x
        lda     $321c,x
        cmp     #$01
        bcc     @e2f8
        sec
        lda     $321c,x
        sbc     #$01
        sta     $321c,x
        bne     @e327
        stz     $321c,x
        stz     $321b,x
        lda     #$80
        sta     $321a,x
@e327:  tya
        sta     $01
        lda     #$06        ; battle graphics $06: draw inventory item text
        jsr     ExecBtlGfx
        lda     #$f8
        sta     $26d4
        lda     #$ce
        sta     $26d2
        inc     $352a
        jsr     DoMagicAttack
        lda     #$ce
        sta     $33c5
@e344:  lda     #$0a
        sta     $34c8       ; set command name
        lda     #$10
        sta     $34c7       ; show command name
        rts

; ------------------------------------------------------------------------------

; [ battle command $16: throw (dart) ]

Cmd_16:
@e34f:  lda     #$16
        sta     $34c8       ; set command name
        lda     #$10
        sta     $34c7       ; show command name
        lda     #$f8        ; display text
        sta     $33c6
        lda     #$04        ; damage numerals
        sta     $33c7
        lda     $ce
        bmi     @e377
@e367:  lda     #$d3
        sta     $33c4
        jsr     AddMsg2
        lda     #$00
        sta     $34ca
        jmp     @e3d3
@e377:  lda     $3881
        bne     @e367
        lda     $26d2
        sta     $3580       ; thrown item id
        tax
        stx     $e5
        ldx     #.loword(EquipProp)
        stx     $80
        lda     #^EquipProp
        sta     $82
        lda     #$08
        jsr     LoadArrayItem
        lda     $289d
        sta     $df
        lda     $2682
        sta     $e1
        jsr     Mult8
        ldx     $e3
        stx     $289c
        jsr     Rand99
        clc
        adc     $289c
        sta     $e3
        lda     #$00
        adc     $289d
        sta     $e4
        ldx     $e3
        cpx     #$270f
        bcc     @e3c1
        ldx     #$270f
        stx     $e3
@e3c1:  lda     $ce
        jsr     GetDmgPtr
        lda     $e3
        sta     $34d4,x
        lda     $e4
        sta     $34d5,x
        jsr     ApplyDmg
@e3d3:  rts

; ------------------------------------------------------------------------------

; [ battle command $1a: change row ]

Cmd_1a:
@e3d4:  clr_axy
@e3d7:  lda     $2001,x
        sta     $a9
        and     #$80
        eor     #$80
        sta     $aa
        lda     $a9
        and     #$7f
        ora     $aa
        sta     $2001,x
        longa
        txa
        clc
        adc     #$0080
        tax
        shorta0
        iny
        cpy     #5
        bne     @e3d7
        rts

; ------------------------------------------------------------------------------

; [ battle command $19: regen ]

Cmd_19:
@e3fd:  stz     $357c
        ldx     #10         ; 10 hp gain per tick
        stx     $357d
        inc     $390a
        lda     #$19
        sta     $34c8       ; set command name
        lda     #$10
        sta     $34c7       ; show command name
        lda     #$22
        sta     $397b
        lda     #$0c
        sta     $d6
        lda     $cd
        jsr     CalcTimerDur
        lda     #$03        ; action timer
        jsr     SetTimer
        lda     #$08
        sta     $2a06,x
        ldx     $a6
        lda     #$22
        sta     $2051,x
        jsr     AddMsg2
        lda     #$36
        sta     $34ca
        rts

; ------------------------------------------------------------------------------

; [ battle command $22: end regen ]

Cmd_22:
@e43b:  lda     #$ff
        sta     $357c
        rts

; ------------------------------------------------------------------------------

; [ battle command $10: twin 1 ]

Cmd_10:
@e441:  ldx     #$0001
        lda     $cd
        cmp     $3539
        beq     @e44c
        dex
@e44c:  lda     $3539,x
        jsr     SelectObj
        ldx     $a6
        lda     $2003,x
        and     #$c0
        beq     @e45e
        jmp     TwinFailed
@e45e:  lda     $2004,x
        and     #$3c
        beq     @e468
        jmp     TwinFailed
@e468:  lda     $2005,x
        and     #$40
        beq     @e472
        jmp     TwinFailed
@e472:  lda     $2005,x
        ora     #$04
        sta     $2005,x
        lda     $26d0
        sta     $2050,x
        lda     $26d3
        sta     $2053,x
        lda     #$20
        sta     $2051,x
        ldx     $3530
        stx     $92
        lda     #$20
        sta     $397b
        lda     #$0c
        sta     $d6
        lda     $cd
        jsr     CalcTimerDur
        lda     #$03        ; action timer
        jsr     SetTimer
        lda     #$08
        sta     $2a06,x
        clc
        lda     $92
        adc     #$03
        sta     $92
        lda     $93
        adc     #$00
        sta     $93
        ldx     $92
        lda     $d4
        sta     $2a04,x
        lda     $d5
        sta     $2a05,x
        lda     #$08
        sta     $2a06,x
        ldx     $a6
        lda     $2005,x
        ora     #$04
        sta     $2005,x
        lda     #$20
        sta     $2051,x
        inc     $390a
        rts

; ------------------------------------------------------------------------------

; [ twin attack failed ]

TwinFailed:
@e4d9:  lda     #$ff
        sta     $357b
        lda     #$11
        sta     $34ca
        jmp     AddMsg2

; ------------------------------------------------------------------------------

; [ battle command $20: twin 2 ]

Cmd_20:
@e4e6:  lda     #$ff
        sta     $357b
        ldx     $a6
        stx     $8c
        lda     $2005,x
        and     #$fb
        sta     $2005,x
        lda     $2685
        and     #$fb
        sta     $2685
        ldx     #$0001
        lda     $cd
        cmp     $3539
        beq     @e50a
        dex
@e50a:  stz     $d6
        lda     $3539,x
        jsr     CalcTimerDur
        ldx     $a6
        lda     $2005,x
        and     #$fb
        sta     $2005,x
        lda     $2003,x
        and     #$c0
        bne     @e52a
        lda     $2004,x
        and     #$3c
        beq     @e54e
@e52a:  lda     #$21
        sta     $2051,x
        longa
        txa
        jsr     Lsr_6
        lsr
        sta     $a9
        shorta
        clr_ax
@e53c:  lda     $3539,x
        cmp     $a9
        beq     @e546
        inx
        bra     @e53c
@e546:  ora     #$80
        sta     $3539,x
        jmp     TwinFailed
@e54e:  lda     #$03        ; action timer
        jsr     SetTimer
        stz     $2a06,x
        ldx     $a6
        stx     $92
        lda     $2005,x
        and     #$40
        bne     @e52a
        ldx     $8c
        lda     $2003,x
        and     #$c0
        bne     @e52a
        lda     $2004,x
        and     #$3c
        bne     @e52a
        lda     $2000,x
        and     #$1f
        cmp     #$13
        beq     @e57e
        cmp     #$15
        bne     @e582
@e57e:  lda     #$5e
        bra     @e59b
@e582:  jsr     Rand
        cmp     #$ff
        bcc     @e591
        lda     #$11
        sta     $34ca
        jmp     AddMsg2
@e591:  cmp     #$40
        bcc     @e599
        lda     #$41
        bra     @e59b
@e599:  lda     #$40
@e59b:  sta     $94
        tax
        stx     $e5
        ldx     #.loword(AttackProp)
        stx     $80
        lda     #^AttackProp
        sta     $82
        lda     #$06
        jsr     LoadArrayItem
        lda     $28a0
        and     #$7f        ; element status effect
        sta     $df
        lda     #$03
        sta     $e1
        jsr     Mult8
        ldx     $e3
        clr_ay
@e5c0:  lda     f:ElementStatus,x
        sta     $28a2,y
        iny
        inx
        cpy     #$0003
        bne     @e5c0
        lda     $268b
        sta     $a9
        lda     $268c
        beq     @e5dc
        lda     #$ff
        sta     $a9
@e5dc:  lda     $28a1
        and     #$7f
        sta     $ab
        cmp     $a9
        beq     @e5e9
        bcs     @e611
@e5e9:  ldx     $92
        sec
        lda     $200b,x
        sbc     $ab
        sta     $a9
        lda     $200c,x
        sbc     #$00
        sta     $aa
        bcc     @e611
        lda     $a9
        sta     $200b,x
        lda     $aa
        sta     $200c,x
        lda     $94
        sta     $26d2
        inc     $355d
        jsr     DoMagicAttack
@e611:  rts

; ------------------------------------------------------------------------------

; [ battle command $13: cover ]

Cmd_13:
@e612:  lda     $ce
        sta     $357a
        jsr     SelectObj
        ldx     $a6
        lda     $2006,x
        ora     #$02
        sta     $2006,x
        lda     $cd
        jsr     SelectObj
        ldx     $3534
@e62c:  lda     $3303,x
        cmp     #$13
        beq     @e639
        inx4
        bra     @e62c
@e639:  lda     #$1d
        sta     $3303,x
        clr_a
        sta     $3302,x
        lda     $cd
        sta     $00
        lda     #$09        ; battle graphics $09: draw battle command list
        jsr     ExecBtlGfx
        lda     #$13
        sta     $34c8       ; set command name
        lda     #$10
        sta     $34c7       ; show command name
        rts

; ------------------------------------------------------------------------------

; [ battle command $1d: don't cover (off) ]

Cmd_1d:
@e656:  lda     #$1d
        sta     $34c8       ; set command name
        lda     #$10
        sta     $34c7       ; show command name
        lda     $357a
        jsr     SelectObj
        ldx     $a6
        lda     $2006,x
        and     #$fd
        sta     $2006,x
        lda     $cd
        jsr     SelectObj
        ldx     $3534
@e678:  lda     $3303,x
        cmp     #$1d
        beq     @e685
        inx4
        bra     @e678
@e685:  lda     #$13
        sta     $3303,x
        lda     #$18
        sta     $3302,x
        lda     $cd
        sta     $00
        lda     #$09        ; battle graphics $09: draw battle command list
        jsr     ExecBtlGfx
        rts

; ------------------------------------------------------------------------------

; [ battle command $0f: brace ]

Cmd_0f:
@e699:  lda     #$05        ; barrier spell (armor)
        sta     $26d2
        stz     $33c4
        jsr     DoMagicAttack
        jsr     AddMsg3
        lda     #$3a        ; こうかが　なかった (no effect)
        sta     $34ca
        lda     #$0f
        sta     $34c8       ; set command name
        lda     #$10
        sta     $34c7       ; show command name
        rts

; ------------------------------------------------------------------------------

; [ battle command $0e: kick ]

Cmd_0e:
@e6b7:  stz     $c1
        jmp     DoMultiAttack

; ------------------------------------------------------------------------------

; [ do multi-attack (kick/dark wave) ]

DoMultiAttack:
@e6bc:  lda     $cd
        bpl     @e70a
        sta     $34c7
        lda     #$f8
        sta     $34c5
        clr_axy
@e6cb:  lda     $33c2,x
        sta     $289c,y
        cmp     #$ce
        beq     @e6dd
        cmp     #$c5
        beq     @e6dd
        inx
        iny
        bra     @e6cb
@e6dd:  iny
        lda     #$f8
        sta     $289c,y
        iny
        lda     #$04
        sta     $289c,y
        iny
        inx
@e6eb:  lda     $33c2,x
        sta     $289c,y
        cmp     #$ff
        beq     @e6f9
        inx
        iny
        bra     @e6eb
@e6f9:  clr_ax
@e6fb:  lda     $289c,x
        sta     $33c2,x
        cmp     #$ff
        beq     @e708
        inx
        bra     @e6fb
@e708:  bra     @e714
@e70a:  lda     #$f8        ; display text
        sta     $33c6
        lda     #$04        ; damage numerals
        sta     $33c7
@e714:  lda     $3881
        beq     @e71c
        jmp     @e7f2
@e71c:  ldx     $a6
        lda     $201b,x
        sta     $df
        lda     $c1
        bne     @e72f
        lsr     $df
        lda     $df
        bne     @e72f
        inc     $df
@e72f:  lda     $df
        sta     $84
        lda     $201d,x
        sta     $c5
        sta     $e1
        jsr     Mult8
        lsr     $e4
        ror     $e3
        ldx     $e3
        stx     $cb
        lda     $cd
        bmi     @e755
        ldx     #5
        stx     $c7
        ldx     #13
        stx     $c3
        bra     @e75e
@e755:  clr_ax
        stx     $c7
        ldx     #5
        stx     $c3
@e75e:  clr_ax
        lda     $c5
        jsr     RandXA
        sta     $c9
        clc
        lda     $cb
        adc     $c9
        sta     $c9
        lda     $cc
        adc     #0
        sta     $ca
        lda     $c7
        tax
        lda     $3540,x
        bne     @e7e4
        lda     $c7
        jsr     SelectObj
        ldx     $a6
        lda     $2003,x
        and     #$c0
        bne     @e7e4
        lda     $2005,x
        and     #$02
        bne     @e7e4
        lda     $2006,x
        bmi     @e7e4
        lda     $2040,x
        and     #$20
        bne     @e7e4
        lda     $c1
        beq     @e7ae
        lda     $2040,x
        bpl     @e7ae
        lsr     $ca
        ror     $c9
        lsr     $ca
        ror     $c9
@e7ae:  lda     $c1
        bne     @e7d2
        lda     $84
        sta     $df
        lda     $202a,x
        sta     $e1
        jsr     Mult8
        sec
        lda     $c9
        sbc     $e3
        sta     $c9
        lda     $ca
        sbc     $e4
        sta     $ca
        bcs     @e7d2
@e7cd:  ldx     #$4000
        stx     $c9
@e7d2:  ldx     $c9
        beq     @e7cd
        lda     $c7
        asl
        tax
        lda     $c9
        sta     $34d4,x
        lda     $ca
        sta     $34d5,x
@e7e4:  inc     $c7
        lda     $c7
        cmp     $c3
        beq     @e7ef
        jmp     @e75e
@e7ef:  jsr     ApplyDmg
@e7f2:  rts

; ------------------------------------------------------------------------------

; [ battle command $0d: focus 1 ]

Cmd_0d:
@e7f3:  inc     $390a
        lda     #$1f
        sta     $397b
        lda     #$0c
        sta     $d6
        lda     $cd
        jsr     CalcTimerDur
        lda     #$03        ; action timer
        jsr     SetTimer
        lda     #$08
        sta     $2a06,x
        ldx     $a6
        lda     $2005,x
        ora     #$08
        sta     $2005,x
        lda     #$1f
        sta     $2051,x
        jsr     AddMsg2
        lda     #$39
        sta     $34ca
        rts

; ------------------------------------------------------------------------------

; [ battle command $1f: focus 2 ]

Cmd_1f:
@e826:  jsr     DoFightCmd
        lda     $cd
        jsr     SelectObj
        ldx     $a6
        lda     $2005,x
        and     #$f7
        sta     $2005,x
        rts

; ------------------------------------------------------------------------------

; [ battle command $0c: aim ]

Cmd_0c:
@e839:  lda     $269c
        pha
        lda     $2729
        pha
        clr_a
        sta     $2729
        dec
        sta     $269c
        jsr     DoFightCmd
        pla
        sta     $2729
        pla
        sta     $269c
        rts

; ------------------------------------------------------------------------------

; [ battle command $0b: pray ]

Cmd_0b:
@e855:  jsr     Rand
        cmp     #$80
        bcc     @e866
        jsr     AddMsg2
        lda     #$10
        sta     $34ca
        bra     @e86e
@e866:  lda     #$0e
        sta     $26d2
        jsr     DoMagicAttack
@e86e:  lda     #$0b
        sta     $34c8       ; set command name
        lda     #$10
        sta     $34c7       ; show command name
        rts

; ------------------------------------------------------------------------------

; [ battle command $09: hide ]

Cmd_09:
@e879:  ldx     $a6
        lda     $2006,x
        ora     #$80
        sta     $2006,x
        ldx     $3534
        stz     $a9
@e888:  lda     $3303,x
        cmp     #$09
        bne     @e896
        lda     #$1c
        sta     $3303,x
        bra     @e89e
@e896:  lda     $3302,x
        ora     #$80
        sta     $3302,x
@e89e:  inx4
        inc     $a9
        lda     $a9
        cmp     #$05
        bne     @e888
        lda     $cd
        sta     $00
        lda     #$09        ; battle graphics $09: draw battle command list
        jsr     ExecBtlGfx
        lda     #$09
        sta     $34c8       ; set command name
        lda     #$10
        sta     $34c7       ; show command name
        rts

; ------------------------------------------------------------------------------

; [ battle command $1c: appear (show) ]

Cmd_1c:
@e8be:  ldx     $a6
        lda     $2006,x
        and     #$7f
        sta     $2006,x
        ldx     $3534
        stz     $a9
@e8cd:  lda     $3303,x
        cmp     #$1c
        bne     @e8db
        lda     #$09
        sta     $3303,x
        bra     @e8e3
@e8db:  lda     $3302,x
        and     #$7f
        sta     $3302,x
@e8e3:  inx4
        inc     $a9
        lda     $a9
        cmp     #$05
        bne     @e8cd
        lda     $cd
        sta     $00
        lda     #$09        ; battle graphics $09: draw battle command list
        jsr     ExecBtlGfx
        lda     #$1c
        sta     $34c8       ; set command name
        lda     #$10
        sta     $34c7       ; show command name
        rts

; ------------------------------------------------------------------------------

; [ battle command $08: sing ]

Cmd_08:
@e903:  lda     $2683
        and     #$20
        beq     @e913
        lda     #$0b
        sta     $34ca
        lda     #$19
        bra     @e944
@e913:  jsr     Rand
        cmp     #$c0
        bcc     @e923
        lda     #$00
        sta     $34ca
        lda     #$00
        bra     @e944
@e923:  cmp     #$80
        bcc     @e930
        lda     #$0e
        sta     $34ca
        lda     #$02
        bra     @e944
@e930:  cmp     #$40
        bcc     @e93d
        lda     #$0d
        sta     $34ca
        lda     #$03
        bra     @e944
@e93d:  lda     #$0c
        sta     $34ca
        lda     #$29
@e944:  sta     $26d2
        jsr     DoMagicAttack
        lda     #$08
        sta     $34c8       ; set command name
        lda     #$10
        sta     $34c7       ; show command name
        jmp     AddMsg3

; ------------------------------------------------------------------------------

; [ battle command $06: jump 1 ]

Cmd_06:
@e957:  lda     $cd
        bmi     @e96c       ; branch if monster attacker
        lda     $ce
        bmi     @e96c       ; branch if monster target
        lda     #$d3
        sta     $33c4
        lda     #$00        ; こうかが　なかった (nothing happened)
        sta     $34ca
        jmp     AddMsg2
@e96c:  inc     $390a       ; disable retaliation
        ldx     #$0004
        stx     $d4         ; timer duration: 4
        lda     #$03        ; action timer
        jsr     SetTimer
        lda     #$08
        sta     $2a06,x     ; do command when timer expires
        ldx     $a6
        lda     $2005,x     ; set jumping status
        ora     #$02
        sta     $2005,x
        lda     $cd
        bpl     @e990       ; branch if character attacker
        lda     #$de        ; jump 2 command (monster)
        bra     @e992
@e990:  lda     #$1e        ; jump 2 command
@e992:  sta     $2051,x     ; set pending command
        lda     $cd
        asl
        tax
        lda     $29ea,x     ; save enabled timers *** bug, should be $29eb ***
        sta     $357f
        lda     #$40        ; enable action timer only
        sta     $29ea,x
        rts

; ------------------------------------------------------------------------------

; [ battle command $1e: jump 2 ]

Cmd_1e:
@e9a5:  jsr     DoFightCmd
        lda     $cd
        bpl     @e9b1       ; branch if character attacker
        and     #$7f
        clc
        adc     #$05
@e9b1:  jsr     SelectObj
        ldx     $a6
        lda     $2005,x     ; clear jump status
        and     #$fd
        sta     $2005,x
        lda     $cd
        asl
        tax
        lda     $357f       ; restore enabled timers
        sta     $29ea,x     ; *** bug, should be $29eb ***
        lda     $cd
        bpl     @e9e0       ; return if character attacker
        lda     #$de        ; jump 2 command (monster)
        sta     $33c2
        lda     #$f8        ; display text
        sta     $33c3
        lda     #$04        ; damage numerals
        sta     $33c4
        lda     #$ff
        sta     $33c5
@e9e0:  rts

; ------------------------------------------------------------------------------

; [ battle command $1b: defend ]

Cmd_1b:
@e9e1:  ldx     $a6
        lda     $2005,x     ; set defend status
        ora     #$10
        sta     $2005,x
        rts

; ------------------------------------------------------------------------------

; [ battle command $05: dark wave ]

Cmd_05:
@e9ec:  lda     $cd
        bmi     @ea16
        longa
        ldx     $a6
        lda     $2009,x
        jsr     Lsr_3
        sta     $a9
        sec
        lda     $2007,x
        sbc     $a9
        sta     $2007,x
        bcs     @ea13
        lda     #$0000
        sta     $2007,x
        lda     #$0080
        sta     $2003,x
@ea13:  shorta0
@ea16:  lda     #$01
        sta     $c1
        jmp     DoMultiAttack

; ------------------------------------------------------------------------------

; [ battle command $07: recall ]

Cmd_07:
@ea1d:  clr_ax
        lda     #$a0
        jsr     RandXA
        cmp     #$08
        bcs     @ea2c
        lda     #$2a
        bra     @ea6c
@ea2c:  cmp     #$10
        bcs     @ea34
        lda     #$26
        bra     @ea6c
@ea34:  cmp     #$18
        bcs     @ea3c
        lda     #$27
        bra     @ea6c
@ea3c:  cmp     #$20
        bcs     @ea44
        lda     #$2b
        bra     @ea6c
@ea44:  cmp     #$38
        bcs     @ea4c
        lda     #$1d
        bra     @ea6c
@ea4c:  cmp     #$50
        bcs     @ea54
        lda     #$20
        bra     @ea6c
@ea54:  cmp     #$68
        bcs     @ea5c
        lda     #$23
        bra     @ea6c
@ea5c:  cmp     #$80
        bcs     @ea64
        lda     #$19
        bra     @ea6c
@ea64:  lda     #$09
        sta     $34ca
        jmp     AddMsg3
@ea6c:  pha
        tax
        stx     $e5
        ldx     #.loword(AttackProp)
        stx     $80
        lda     #^AttackProp
        sta     $82
        lda     #$06
        jsr     LoadArrayItem
        lda     $28a0
        and     #$7f
        sta     $df
        lda     #$03
        sta     $e1
        jsr     Mult8
        ldx     $e3
        clr_ay
@ea90:  lda     f:ElementStatus,x
        sta     $28a2,y
        iny
        inx
        cpy     #3
        bne     @ea90
        lda     $268b
        sta     $a9
        lda     $268c
        beq     @eaac
        lda     #$ff
        sta     $a9
@eaac:  lda     $28a1
        and     #$7f
        cmp     $a9
        beq     @eabb
        bcc     @eabb
        pla
        jmp     @eac5
@eabb:  pla
        sta     $26d2
        inc     $355d
        jsr     DoMagicCmd
@eac5:  rts

; ------------------------------------------------------------------------------

; [ battle command $11: bluff ]

Cmd_11:
@eac6:  lda     #$11
        sta     $34c8       ; set command name
        lda     #$10
        sta     $34c7       ; show command name
        ldx     $a6
        clc
        lda     $2017,x
        adc     #$10
        cmp     #$63
        bcc     @eade
        lda     #$63
@eade:  sta     $2017,x
        lda     #$12
        sta     $34ca
        jmp     AddMsg2

; ------------------------------------------------------------------------------

; [ battle command $12: cry ]

; set each monster's level stat to 1 if it is less than
; half porom's level stat

Cmd_12:
@eae9:  lda     #$12
        sta     $34c8       ; set command name
        lda     #$10
        sta     $34c7       ; show command name
        ldx     $a6
        lda     $202f,x     ; porom's (level + 10) / 2
        lsr
        sta     $a9
        ldx     #5
        stx     $ab
; start of monster loop
@eb00:  ldx     $ab
        lda     $3540,x
        bne     @eb1c       ; branch if monster is not present
        txa
        jsr     SelectObj
        ldx     $a6
        sec
        lda     $202f,x
        sbc     $a9
        beq     @eb17
        bcs     @eb19
@eb17:  lda     #$01
@eb19:  sta     $202f,x     ; set level stat to 1
@eb1c:  inc     $ab         ; next monsters
        lda     $ab
        cmp     #13
        bne     @eb00
        lda     #$13        ; まものを　あわてさせた
        sta     $34ca
        jmp     AddMsg2

; ------------------------------------------------------------------------------

; [ load stolen item properties ]

LoadStolenItemProp:
@eb2c:  beq     @eba1       ; return if no item
        cmp     #$de
        bcs     @eba1
        cmp     #$b0
        bcs     @eb7a       ; branch if consumable
        cmp     #$6d
        bcs     @eba1       ; branch if armor
        cmp     #$61
        bcc     @eb42       ; branch if shield
        lda     #$00
        beq     @eb9e
@eb42:  tax
        stx     $e5
        ldx     #.loword(EquipProp)
        stx     $80
        lda     #^EquipProp
        sta     $82
        lda     #$08
        jsr     LoadArrayItem
        pha
        lda     $289c
        jsr     Lsr_3
        and     #$08
        sta     $c7
        pla
        tax
        stx     $e5
        ldx     #.loword(AttackProp)
        stx     $80
        lda     #^AttackProp
        sta     $82
        lda     #$06
        jsr     LoadArrayItem
        ldx     $ab
        lda     $289f
        sta     $321d,x     ; set spell id
        bra     @eb96

; consumable
@eb7a:  sec
        sbc     #$b0
        tax
        stx     $e5
        ldx     #.loword(ItemProp)
        stx     $80
        lda     #^ItemProp
        sta     $82
        lda     #$06
        jsr     LoadArrayItem
        ldx     $ab
        lda     $289f
        sta     $321d,x     ; set spell id
@eb96:  lda     $289c
        and     #$e0
.if !LANG_EN .or EASY_VERSION
        ora     $c7
.endif
        lsr
@eb9e:  sta     $321a,x     ; set flags
@eba1:  rts

; ------------------------------------------------------------------------------

; [ battle command $01: item ]

Cmd_01:
@eba2:  lda     $2683
        and     #$c0
        bne     @ec11
        lda     $2684
        and     #$3c
        bne     @ec11
        lda     $2685
        and     #$c6
        bne     @ec11
        lda     $26d2
        pha
        lda     $26d2
        cmp     #$ca        ; summon book (call)
        bne     @ebc7
        jsr     RandSummon
        bra     @ebfa
@ebc7:  cmp     #$b0
        bcc     @ebd2
        lda     $26d0
        and     #$10
        beq     @ebf7
@ebd2:  ldx     $26d5
        stx     $80
        lda     $26d2
        cmp     #$61
        bcc     @ebe2
        lda     #$00
        bra     @ebf2
@ebe2:  tax
        lda     f:WeaponMagicHits,x
        sta     $38ec
        inc     $38eb       ; set weapon magic flag
        ldy     #$0003
        lda     ($80),y
@ebf2:  sta     $26d2
        bra     @ebfa
@ebf7:  inc     $352a
@ebfa:  jsr     DoMagicAttack
        lda     $38ed
        beq     @ec05
        pla
        bra     @ec09
@ec05:  pla
        sta     $33c5
@ec09:  sta     $34c8
        lda     #$20
        sta     $34c7       ; show item name
@ec11:  rts

; ------------------------------------------------------------------------------

; [ choose a random summon ]

RandSummon:
@ec12:  lda     #$e5
        sta     $33c4
        inc     $38ed
        inc     $3584
        clr_ax
        lda     #$09
        jsr     RandXA
        tax
        lda     f:SummonBookTbl,x   ; summon book attacks
        pha
        and     #$7f
        sta     $26d2
        sta     $33c5
        pla
        bpl     @ec68       ; branch if target all
@ec35:  ldx     #5
        lda     #$0c
        jsr     RandXA
        tay
        sty     $a9
        lda     $3540,y
        bne     @ec35
        tya
        sta     $df
        lda     #$80
        sta     $e1
        jsr     Mult8
        ldx     $e3
        lda     $2003,x
        and     #$c0
        bne     @ec35
        sec
        lda     $a9
        sbc     #$05
        tax
        ora     #$80
        sta     $ce
        clr_a
        jsr     SetBit
        bra     @ec6e
@ec68:  lda     #$80
        sta     $ce
        lda     #$ff
@ec6e:  sta     $26d3
        rts

; ------------------------------------------------------------------------------
