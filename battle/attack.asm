
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: attack.asm                                                           |
; |                                                                            |
; | description: attack execution                                              |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

; [ action type 2: do attack ]

DoAttack:
@ad57:  lda     #$14        ; battle graphics $14: update monster rows
        jsr     ExecBtlGfx
        ldx     #$0280
        clr_ay
@ad61:  lda     $2001,x
        and     #$7f
        ora     $35eb,y     ; set monster rows
        sta     $2001,x
        jsr     NextObj
        iny
        cpy     #8
        bne     @ad61
        stz     $390a
_ad78:  stz     $38e7
        stz     $3907
        stz     $355b
        stz     $355c
        stz     $3553
        stz     $355d
        stz     $352a
        stz     $3584
        stz     $38e2
        stz     $38eb
        stz     $38ed
        lda     #$04
        sta     $2c78       ; seems to be unused
        stz     $2c79
        lda     $d2
        jsr     SelectObj
        jsr     InitGfxScript
        lda     $d2
        cmp     #$05
        bcc     @add5       ; branch if attacker is a character
        sec
        lda     $d2
        sbc     #$05
        sta     $df
        lda     #$3c        ; monster id * 60
        sta     $e1
        jsr     Mult8
        clr_ay
        ldx     $e3
@adc1:  lda     $3659,x     ; copy graphics script from buffer
        sta     $33c2,y
        inx
        iny
        cpy     #$003c
        bne     @adc1
        lda     $d2
        sec
        sbc     #$05
        ora     #$80
@add5:  sta     $cd         ; set attacker id
        pha
        pha
        and     #$7f
        sta     $34c3
        pla
        and     #$80
        sta     $34c2
        pla
        jsr     GetObjPtr
        ldy     #$007f
@adeb:  lda     ($80),y
        sta     $2680,y     ; copy attacker properties to buffer
        dey
        bpl     @adeb
        clr_ax
@adf5:  lda     $3540,x     ; copy "target not present" flags to buffer
        sta     $289c,x
        inx
        cpx     #13
        bne     @adf5
        ldx     $a6
        lda     $2053,x     ; get all targets
        ora     $2054,x
        sta     $8a
        bne     @ae32       ; branch if there are any targets
        lda     #$21
        sta     $2051,x     ; do nothing
        lda     $cd
        sta     $ce         ; self-target
        bpl     @ae63       ; branch if a character
        jsr     EndMultiAttack
        lda     $a9
        bne     @ae2e
        ldx     $a6
        lda     #$e1
        sta     $2051,x
        sta     $33c2
        lda     #$ff
        sta     $33c3
@ae2e:  lda     $cd
        bra     @ae63
@ae32:  ldx     #0
@ae35:  asl
        bcs     @ae3b       ; branch if target found
        inx
        bne     @ae35
@ae3b:  txa
        sta     $ce         ; set target id
        ldx     $a6
        lda     $2053,x
        beq     @ae58       ; branch if targeting characters

; monster targets
        lda     #$80
        sta     $34c4
        lda     $2053,x
        jsr     SetTargets
        lda     $ce
        ora     #$80
        sta     $ce
        bra     @ae63

; character targets
@ae58:  stz     $34c4
        lda     $2054,x
        jsr     SetTargets
        lda     $ce
@ae63:  jsr     GetObjPtr
        ldy     #$007f
@ae69:  lda     ($80),y
        sta     $2700,y     ; copy target properties to buffer
        dey
        bpl     @ae69
        lda     $26d2
        cmp     #$ba
        bne     @ae7e
        inc     $38e7
        jmp     @af6f
@ae7e:  lda     $8a
        jsr     CountBits
        dex
        beq     @ae89       ; branch if single target
        jmp     @afeb
@ae89:  lda     $cd
        bmi     @ae9c       ; branch if monster attacker

; character attacker
        lda     $26d1       ; battle command id
        sta     $a9
        lda     $ce
        bmi     @aea4       ; branch if monster target
        lda     $a9
        bne     @aed7
        bra     @aea4

; monster attacker
@ae9c:  sec
        lda     $26d1
        sbc     #$c0
        sta     $a9
@aea4:  lda     $2703
        and     #$80
        beq     @aedd       ; branch if target is not dead
        lda     $a9
        beq     @af12
        cmp     #$03
        bcs     @af12       ; branch if not item or magic
        cmp     #$02
        bne     @aed0

; magic
        lda     $26d2       ; magic id
        cmp     #$13        ; raise (life)
        beq     @aed7
        cmp     #$14        ; arise (life2)
        beq     @aed7
        cmp     #$ab        ; restore (recover)
        beq     @aed7
        cmp     #$ac        ; reraise (remedy)
        beq     @aed7
        cmp     #$8f        ; return to darkness (vanish)
        beq     @aed7
        bra     @af12

; item
@aed0:  lda     $26d2       ; item id
        cmp     #$d4
        bne     @af12       ; branch if not phoenix tail
@aed7:  inc     $38e7
        jmp     @af6f
@aedd:  lda     $2703
        and     #$40
        beq     @af06       ; branch if target is not stone
        lda     $a9
        beq     @af12
        cmp     #$03
        bcs     @af12
        cmp     #$02
        bne     @aef9
        lda     $26d2
        cmp     #$12
        beq     @af6f
        bra     @af12
@aef9:  lda     $26d2
        cmp     #$d5
        beq     @af6f
        cmp     #$dd
        beq     @af6f
        bra     @af12
@af06:  lda     $2705
        and     #$02
        bne     @af12       ; branch if target is jumping
        lda     $2706
        bpl     @af6f       ; branch if target is not hiding

; invalid target
@af12:  lda     $ce
        bpl     @af26

; monster target
        ldx     #5
@af19:  lda     $289c,x
        beq     @af5f       ; branch if at least one monster present
        inx
        cpx     #13
        bne     @af19
        bra     @af33

; character target
@af26:  clr_ax
@af28:  lda     $289c,x
        beq     @af5f       ; branch if at least one character present
        inx
        cpx     #5
        bne     @af28

; no targets present
@af33:  ldx     $a6
        cpx     #$0280
        bcc     @af4e

; monster attacker
        jsr     EndMultiAttack
        lda     $a9
        beq     @af4a
        ldx     $a6
        lda     #$e1
        sta     $2051,x     ; do nothing
        bra     @af6f
@af4a:  lda     #$e1
        bra     @af50

; character attacker
@af4e:  lda     #$21
@af50:  ldx     $a6
        sta     $2051,x     ; do nothing
        sta     $33c2
        lda     #$ff
        sta     $33c3
        bra     @af6f
@af5f:  jsr     Retarget
        pha
        lda     $8b
        tax
        lda     #$01
        sta     $289c,x
        pla
        jmp     @ae32

; valid target
@af6f:  lda     $ce
        bmi     @afeb       ; branch if monster target
        lda     $2706
        and     #$02
        bne     @af81       ; branch if target is using cover
        lda     $2706
        and     #$01
        beq     @afeb       ; branch if target is not critical
@af81:  lda     $26d1
        cmp     #$c0
        bne     @afeb       ; branch if not fight
        lda     $355e
        bmi     @afeb       ; branch if paladin cecil is not present
        lda     $cd
        cmp     $ce
        beq     @afeb       ; branch if self-target
        cmp     $355e
        beq     @afeb       ; branch if paladin cecil is attacker
        lda     $355e
        cmp     $ce
        beq     @afeb       ; branch if paladin cecil is target
        lda     $355e
        jsr     SelectObj
        ldx     $a6
        lda     $2003,x
        and     #$c0
        bne     @afe6       ; branch if paladin cecil is dead or stone
        lda     $2004,x
        and     #$3c
        bne     @afe6       ; paralyze, sleep, charm, berserk
        lda     $2005,x
        and     #$50
        bne     @afe6       ; stop or defend ???
        lda     $2006,x
        and     #$01
        bne     @afe6       ; critical
        lda     $34c5
        sta     $34c6       ; targets being covered
        ldx     $355e
        txa
        sta     $ce         ; change target to paladin cecil
        clr_a
        jsr     SetBit
        sta     $34c5
        lda     $ce
        jsr     GetObjPtr
        ldy     #$007f
@afde:  lda     ($80),y
        sta     $2700,y     ; copy target properties to buffer
        dey
        bpl     @afde
@afe6:  lda     $d2
        jsr     SelectObj
@afeb:  lda     $cd
        bpl     @aff4       ; branch if character attacker
        and     #$7f
        clc
        adc     #$05
@aff4:  tax
        stz     $3560,x
        lda     $d2
        jsr     SelectObj
        ldx     $a6
        lda     $2003,x
        and     #$c0
        bne     @b00d       ; branch if dead or stone
        lda     $2004,x
        and     #$30
        beq     @b01c       ; branch if not paralyzed or asleep
@b00d:  lda     $d2
        cmp     #$05
        bcc     @b017       ; branch if a character
        lda     #$e1
        bra     @b019
@b017:  lda     #$21
@b019:  sta     $2051,x     ; do nothing
@b01c:  jsr     ExecCmd
        clr_a
        lda     $38b3
        bne     @b042
        lda     a:$00cd
        bpl     @b042       ; branch if character attacker
        clr_ax
@b02c:  lda     $33c2,x
        cmp     #$ff
        beq     @b042       ; find end of graphics script
        cmp     #$fc
        beq     @b03a
        inx
        bra     @b02c
@b03a:  lda     #$ff
        sta     $3601
        sta     $3602
@b042:  lda     $38e4
        bne     @b04a       ; branch if monster death is delayed
        jsr     AddRetal
@b04a:  jsr     UpdateDead
        stz     $38e4
        clr_ax
@b052:  lda     $33c2,x     ; copy graphics script to buffer
        sta     $289c,x
        cmp     #$ff
        beq     @b05f
        inx
        bra     @b052
@b05f:  lda     #$05        ; battle graphics $05: graphics script
        jsr     ExecBtlGfx
        lda     #$0c        ; battle graphics $0c: draw hp text
        jsr     ExecBtlGfx
        lda     #$0b        ; battle graphics $0b: draw monster names
        jsr     ExecBtlGfx
        lda     $390a
        bne     @b09d       ; return if no retaliation ???
        stz     $d6
        lda     $cd         ; timer duration 0 (atb)
        bpl     @b07e
        and     #$7f
        clc
        adc     #$05
@b07e:  jsr     CalcTimerDur
        ldx     $3530
        lda     $2a09,x     ; restart timer
        and     #$76
        sta     $2a09,x
        ldx     $a6
        lda     $2004,x
        and     #$30
        bne     @b09d       ; branch if paralyzed or asleep
        lda     #$03        ; action timer
        jsr     SetTimer
        stz     $2a06,x     ; start timer
@b09d:  rts

; ------------------------------------------------------------------------------

; [ Retarget ]

Retarget:
@b09e:  ldx     #4
        lda     $ce
        bpl     @b0a8       ; branch if character target
        ldx     #7
@b0a8:  txa
        ldx     #0
        jsr     RandXA
        sta     $aa         ; $aa = random target slot
        sta     $8b
        lda     $ce
        bpl     @b0be       ; branch if character target
        clc
        lda     $8b
        adc     #5
        sta     $8b
@b0be:  lda     $8b
        tax
        lda     $3540,x
        bne     @b09e       ; branch if not present
        lda     $ce
        bpl     @b0dc       ; branch if character target
        lda     $8b
        sta     $df
        lda     #$80
        sta     $e1
        jsr     Mult8
        ldx     $e3
        lda     $2001,x
        bmi     @b09e       ; branch if dead
@b0dc:  lda     $aa
        tax
        clr_a
        jsr     SetBit
        pha
        lda     $d2
        jsr     SelectObj
        ldx     $a6
        lda     $ce
        bmi     @b0f7
        pla
        sta     $2054,x
        sta     $26d4
        rts
@b0f7:  pla
        sta     $2053,x
        sta     $26d3
        rts

; ------------------------------------------------------------------------------

; [ execute battle command ]

ExecCmd:
@b0ff:  lda     $d2
        cmp     #$05
        bcc     @b11c       ; branch if a character

; monster
        ldx     $a6
        lda     $2051,x
        cmp     #$c0
        bcc     @b112
        cmp     #$e1
        bcc     @b114
@b112:  lda     #$e1
@b114:  sta     $35ff       ; treat as "do nothing" for retaliations
        sec
        sbc     #$c0
        bra     @b14e

; character
@b11c:  lda     #$f8        ; display text
        sta     $33c2
        lda     #$02        ; attack name
        sta     $33c3
        ldx     $a6
        lda     $2051,x     ; battle command used
        cmp     #$02
        beq     @b137
        cmp     #$07
        beq     @b137
        cmp     #$20
        bne     @b13a
@b137:  inc     $355d       ; consume mp if magic, recall, or twin
@b13a:  pha
        clc
        adc     #$c0
        sta     $33c4       ; add to graphics script
        cmp     #$c1
        bne     @b147       ; branch if not using an item
        lda     #$c2        ; treat item as magic for retaliations
@b147:  sta     $35ff
        stz     $33c5
        pla
@b14e:  asl
        tax
        lda     f:CmdTbl,x   ; battle command jump table
        sta     $80
        lda     f:CmdTbl+1,x
        sta     $81
        lda     #^CmdTbl
        sta     $82
        jml     [$0080]

; ------------------------------------------------------------------------------

; [ get pointer to character/monster properties ]

GetObjPtr:
@b163:  pha
        and     #$7f
        sta     $df
        lda     #$80
        sta     $e1
        jsr     Mult8
        pla
        bmi     @b180       ; branch if a monster
        clc
        lda     $e3
        adc     #$00
        sta     $80
        lda     $e4
        adc     #$20
        sta     $81
        rts
@b180:  clc
        lda     $e3
        adc     #$80
        sta     $80
        lda     $e4
        adc     #$22
        sta     $81
        rts

; ------------------------------------------------------------------------------

; [ set targets ]

SetTargets:
@b18e:  sta     $34c5
        jsr     CountBits
        dex
        beq     @b19f       ; branch if single target
        lda     $34c4       ; multi-target
        ora     #$40
        sta     $34c4
@b19f:  rts

; ------------------------------------------------------------------------------

; [ update dead targets ]

UpdateDead:
@b1a0:  clr_ax
        stx     $a9

; start of loop
@b1a4:  lda     $a9
        jsr     SelectObj
        ldx     $a6
        lda     $a9
        jsr     Asl_2
        tay
        lda     $338e,y     ; apply pending status 1
        ora     $2003,x
        sta     $2003,x
        and     #$c0
        beq     @b234       ; branch if not dead or stone
        and     #$80
        beq     @b1c8       ; branch if not dead
        stz     $2007,x     ; set hp to zero
        stz     $2008,x
@b1c8:  phx
        lda     $a9
        asl
        tax
        clr_a
        sta     $29eb,x     ; disable all timers
        lda     $a9
        cmp     #$05
        bcc     @b226       ; branch if a character
        sec
        sbc     #$05
        tax
        lda     $29bd,x
        sta     $aa
        lda     $29b5,x
        bmi     @b219
        lda     #$ff
        sta     $29b5,x
        lda     $aa
        tax
        lda     $29ca,x     ; decrement monster type count
        beq     @b1f5
        dec     $29ca,x
@b1f5:  plx
        phx
        lda     $2051,x
        cmp     #$e4
        beq     @b209       ; branch if summon was used
        lda     $3882
        bne     @b209
        lda     $aa
        tax
        inc     $3585,x
@b209:  lda     $aa
        tax
        lda     $29ca,x
        bne     @b219       ; branch if not the last monster of this type
        lda     $aa
        tax
        lda     #$ff
        sta     $29ad,x     ; clear monster type
@b219:  clc
        lda     $29ca       ; update total monster count
        adc     $29cb
        adc     $29cc
        sta     $29cd
@b226:  plx
        lda     $2003,x
        and     #$80
        beq     @b234
        stz     $2007,x     ; set hp to zero
        stz     $2008,x
@b234:  iny
        lda     $338e,y     ; apply pending status 2
        ora     $2004,x
        sta     $2004,x
        iny
        lda     $338e,y     ; apply pending status 3
        ora     $2005,x
        sta     $2005,x
        iny
        lda     $338e,y     ; apply pending status 4
        ora     $2006,x
        sta     $2006,x
        lda     $2003,x
        and     #$c0
        beq     @b279       ; branch if not dead or stone
        lda     $2003,x     ; clear poison status
        and     #$fe
        sta     $2003,x
        lda     $2004,x     ; clear all but curse and float
        and     #$c0
        sta     $2004,x
        lda     $2005,x     ; clear stop, defend, focus, twin, doom
        and     #$a2
        sta     $2005,x
        lda     $2006,x     ; clear all but hide
        and     #$80
        sta     $2006,x
@b279:  inc     $a9         ; next character/monster
        lda     $a9
        cmp     #$0d
        beq     @b284
        jmp     @b1a4
@b284:  stz     $3882
        rts

; ------------------------------------------------------------------------------

; [ add attack to retaliation stack ]

AddRetal:
@b288:  lda     $34c4
        bpl     @b2d6       ; return if character target
        lda     $34c5       ; targets mask
        sta     $a9
        clr_ax

; start of monster loop
@b294:  asl     $a9
        bcc     @b2d0       ; branch if monster wasn't a target
        txa
        jsr     Asl_5
        tay
        sty     $ab         ; pointer to retaliation stack
        lda     $35f7,x     ; retaliation stack size
        inc
        cmp     #$04
        bne     @b2ae
        phx
        jsr     ShiftRetalStack
        plx
        lda     #$03
@b2ae:  sta     $35f7,x
        jsr     Asl_2
        clc
        adc     $ab
        tay
        lda     $cd
        sta     $2b78,y     ; set previous attacker
        lda     $35ff
        sta     $2b79,y     ; set previous command
        clr_a
        sta     $2b7a,y
        lda     $3600
        sta     $2b7b,y     ; previous element
        stz     $3600
@b2d0:  inx                 ; next monster
        cpx     #8
        bne     @b294
@b2d6:  rts

; ------------------------------------------------------------------------------

; [ shift retaliation stack ]

ShiftRetalStack:
@b2d7:  phx
        clr_ay
        ldx     $ab
@b2dc:  lda     $2b78,x     ; copy retaliation stack to buffer
        sta     $289c,y
        inx
        iny
        cpy     #$0020
        bne     @b2dc
        ldy     #4
        ldx     $ab
@b2ee:  lda     $289c,y     ; shift out the least recent attack
        sta     $2b78,x
        inx
        iny
        cpy     #$0024
        bne     @b2ee
        plx
        rts

; ------------------------------------------------------------------------------

; [ init graphics script ]

InitGfxScript:
@b2fd:  lda     #$ff
        ldx     #$00ff
@b302:  sta     $33c2,x
        dex
        bpl     @b302
        ldx     #$0011
@b30b:  stz     $34c2,x
        dex
        bpl     @b30b
        stz     $3528
        stz     $3529
        stz     $352a
        ldx     #$0033
@b31d:  stz     $338e,x
        dex
        bpl     @b31d
        lda     #$ff
        ldx     #9
@b328:  sta     $34ca,x
        dex
        bpl     @b328
        lda     $3601
        cmp     #$ff
        bne     @b33e
        ldx     #$004d
@b338:  stz     $34d4,x
        dex
        bpl     @b338
@b33e:  rts

; ------------------------------------------------------------------------------

; [ battle command $21: do nothing ]

Cmd_21:
@b33f:  lda     $34c2
        ora     #$40
        sta     $34c2
        rts

; ------------------------------------------------------------------------------

; [ end a monster's multi-attack ]

EndMultiAttack:
@b348:  clr_ax
        stx     $a9
@b34c:  lda     $33c2,x
        cmp     #$ff
        beq     @b36b
        cmp     #$fc
        beq     @b35a
        inx
        bra     @b34c
@b35a:  inc     $a9
        lda     #$e1
        sta     $33c2
        lda     #$fc
        sta     $33c3
        lda     #$ff
        sta     $33c4
@b36b:  rts

; ------------------------------------------------------------------------------

; battle command jump table
CmdTbl:
@b36c:  .addr Cmd_00
        .addr Cmd_01
        .addr Cmd_02
        .addr 0
        .addr 0
        .addr Cmd_05
        .addr Cmd_06
        .addr Cmd_07
        .addr Cmd_08
        .addr Cmd_09
        .addr Cmd_0a
        .addr Cmd_0b
        .addr Cmd_0c
        .addr Cmd_0d
        .addr Cmd_0e
        .addr Cmd_0f
        .addr Cmd_10
        .addr Cmd_11
        .addr Cmd_12
        .addr Cmd_13
        .addr Cmd_14
        .addr 0
        .addr Cmd_16
        .addr Cmd_17
        .addr 0
        .addr Cmd_19
        .addr Cmd_1a
        .addr Cmd_1b
        .addr Cmd_1c
        .addr Cmd_1d
        .addr Cmd_1e
        .addr Cmd_1f
        .addr Cmd_20
        .addr Cmd_21
        .addr Cmd_22
        .addr 0
        .addr Cmd_24

; ------------------------------------------------------------------------------
