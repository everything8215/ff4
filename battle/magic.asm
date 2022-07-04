
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: magic.asm                                                            |
; |                                                                            |
; | description: magic command                                                 |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

; [ battle command $02: magic ]

Cmd_02:
DoMagicCmd:
@cc36:  clr_ax
        stx     $2896       ; clear action script pointer
        lda     $cd
        bmi     @cc42       ; branch if monster attacker
        jmp     @cd10

; monster attacker
@cc42:  clr_ax
        txy
@cc45:  lda     $33c2,x
        sta     $289c,y
        cmp     #$ff
        beq     @cc53
        inx
        iny
        bra     @cc45
@cc53:  clr_ax
        txy
@cc56:  lda     $289c,x
        sta     $33c2,y
        cmp     #$ff
        beq     @cc9a
        cmp     #$fa
        bcs     @cc96
        cmp     #$e8
        bcs     @cc6e
        cmp     #$c0        ; insert message display before attack
        bcc     @cc78
        bra     @cc96
@cc6e:  inx
        iny
        lda     $289c,x
        sta     $33c2,y
        bra     @cc96
@cc78:  pha
        lda     #$f8        ; display text
        sta     $33c2,y
        lda     #$02        ; attack name
        sta     $33c3,y
        pla
        cmp     #$31
        bcc     @cc91
        cmp     #$5f
        bcs     @cc91
        sec
        sbc     #$30
        bra     @cc91
@cc91:  sta     $33c4,y
        iny2
@cc96:  inx
        iny
        bra     @cc56
@cc9a:  lda     $3601
        cmp     #$ff
        beq     @ccb1
        clr_ax
@cca3:  lda     $33c2,x
        cmp     #$fc
        beq     @ccb1
        cmp     #$ff
        beq     @ccfa
        inx
        bra     @cca3
@ccb1:  clr_ax
        txy
@ccb4:  lda     $33c2,x
        sta     $289c,y
        cmp     #$ff
        beq     @ccc2
        inx
        iny
        bra     @ccb4
@ccc2:  clr_axy
@ccc5:  lda     $289c,x
        sta     $33c2,y
        cmp     #$ff
        beq     @ccfa
        cmp     #$fa
        bcs     @ccf6
        cmp     #$e8
        bcs     @ccdd
        cmp     #$c0        ; insert damage numeral display after attack
        bcc     @cce7
        bra     @ccf6
@ccdd:  inx
        iny
        lda     $289c,x
        sta     $33c2,y
        bra     @ccf6
@cce7:  iny
        sty     $2896
        lda     #$f8        ; display text
        sta     $33c2,y
        iny
        lda     #$04        ; damage numerals
        sta     $33c2,y
@ccf6:  inx
        iny
        bra     @ccc5
@ccfa:  clr_ax
@ccfc:  lda     $33c2,x
        cmp     #$c2
        bne     @cd0a
        lda     #$00
        sta     $33c2,x
        bra     @cd0d
@cd0a:  inx
        bra     @ccfc
@cd0d:  jmp     _cd3e

; character attacker
@cd10:  lda     $26d2       ; magic id
        cmp     #$19
        bcc     DoMagicAttack
        cmp     #$31
        bcc     @cd1f       ; branch if black magic ($c3)
        cmp     #$40
        bcc     @cd23       ; branch if summon ($c4)
@cd1f:  lda     #$c3        ; otherwise treat as black magic ($c3)
        bra     @cd2b
@cd23:  jsr     GetSummonAttack
        lda     #$c4
        sta     $35ff       ; save previous command id
@cd2b:  sta     $33c4       ; add command id to graphics script

; do magic attack
DoMagicAttack:
@cd2e:  lda     $26d2
        sta     $33c5       ; add magic id to graphics script
        lda     #$f8        ; display text
        sta     $33c6
        lda     #$04        ; damage numerals
        sta     $33c7
_cd3e:  inc     $355b       ; allow zero damage
        lda     $ce
        and     #$80
        sta     $34c4       ; monster target flag
        stz     $3522       ; clear reflected targets
        stz     $3523
        lda     $26d2
        cmp     #$92
        bne     @cd5f       ; branch if not retreat (monster attack)
        pha
        lda     #$04
        sta     $38e6
        pla
        inc     $3882
@cd5f:  tax
        stx     $e5         ; set array item id
        lda     $352a
        bne     @cd9a       ; branch if an item
        lda     $26d2
        jsr     CheckAttackName
        sta     $34c8       ; show attack name
        bne     @cd7a
        lda     $34c2       ; disable monster flash
        ora     #$40
        sta     $34c2
@cd7a:  lda     $26d2
        jsr     CheckMonsterFlash
        beq     @cd8a
        lda     $34c2       ; disable monster flash
        ora     #$40
        sta     $34c2
@cd8a:  lda     #$40
        sta     $34c7       ; show magic name
        ldx     #.loword(AttackProp)
        stx     $80
        lda     #^AttackProp
        sta     $82
        bra     @cdb5

; item
@cd9a:  lda     $26d2
        sta     $34c8
        lda     #$20
        sta     $34c7       ; show item name
        ldx     #.loword(ItemProp)
        stx     $80
        lda     #^ItemProp
        sta     $82
        sec
        lda     $e5
        sbc     #$b0
        sta     $e5
@cdb5:  lda     #$06
        jsr     LoadArrayItem
        lda     $28a0
        pha
        and     #$80
        sta     $38e2       ; set character hit pose flag
        pla
        and     #$7f
        sta     $df
        lda     #$03
        sta     $e1
        jsr     Mult8
        ldx     $e3
        clr_ay
@cdd3:  lda     f:ElementStatus,x   ; element/status effects
        sta     $28a2,y
        iny
        inx
        cpy     #$0003
        bne     @cdd3
        lda     $28a2
        sta     $3600
        lda     $ce
        and     #$80
        sta     $354e
        bmi     @cdfd
        jsr     FindValidChar
        lda     $a9
        beq     @cdfd       ; branch if there is a valid target
@cdf7:  stz     $3550       ; clear targets
        jmp     @d290
@cdfd:  lda     $26d3       ; monster targets
        bne     @ce05
        lda     $26d4       ; character targets
@ce05:  jsr     ValidateMagicTargets
        sta     $354f
        sta     $3550
        jsr     CountBits
        txa
        sta     $3906       ; number of targets hit
        sta     $354d       ; number of targets remaining
        beq     @cdf7       ; branch if there are no valid targets
        lda     $289c       ; item/magic targeting
        and     #$60
        cmp     #$40
        bne     @ce28       ; branch if not auto-target all
        lda     #$01
        sta     $3906       ; don't divide damage
@ce28:  lda     $26d2
        beq     @ce6b       ; branch if invalid magic/item id
        lda     $355d
        beq     @ce6b       ; branch if attack doesn't consume mp
        lda     $cd
        bmi     @ce6b       ; branch if monster attacker
        lda     $388b
        bne     @ce6b       ; branch if auto-battle
        lda     $28a1
        and     #$7f        ; mp cost
        sta     $a9
        sec
        lda     $268b       ; subtract from attacker's mp
        sbc     $a9
        sta     $a9
        lda     $268c
        sbc     #$00
        sta     $aa
        bcs     @ce61
        stz     $3550       ; clear targets
        jsr     AddMsg3
        lda     #$01        ; ＭＰが　たりない (not enough mp)
        sta     $34ca
        jmp     @d290
@ce61:  lda     $a9
        sta     $268b       ; set attacker's mp
        lda     $aa
        sta     $268c
@ce6b:  lda     $352a
        bne     @cea7       ; branch if an item
        lda     $38eb
        bne     @cea7       ; branch if weapon magic
        lda     $2683
        and     #$04
        beq     @ce83       ; branch if attacker is not mute
        lda     $26d2
        cmp     #$5f
        bcc     @cea1       ; branch if white, black, or summon
@ce83:  lda     $2683
        and     #$20
        beq     @ce93       ; branch if attacker doesn't have mini status
        lda     $26d2
        cmp     #$19
        beq     @cea7       ; branch if using mini spell
        bne     @cea1
@ce93:  lda     $2683
        and     #$08
        beq     @cea7       ; branch if attacker doesn't have piggy status
        lda     $26d2
        cmp     #$1a
        beq     @cea7       ; branch if using piggy spell
@cea1:  stz     $3550
        jmp     @d290
@cea7:  clr_ax
        lda     $26d2
        cmp     #$19
        bcs     @ceb1       ; branch if not white magic
        inx
@ceb1:  stx     $c7
        lda     $2697,x     ; magic/item hit rate + (intellect or spirit) / 2
        lsr
        sta     $a9
        lda     $289e
        and     #$7f
        clc
        adc     $a9
        bcc     @cec5
        lda     #$ff        ; max 255
@cec5:  sta     $38fa       ; set hit rate
        lda     $2683
        and     #$02
        beq     @ced2       ; branch if attacker is not blind
        lsr     $38fa       ; halve hit rate
@ced2:  lda     $cd
        and     #$7f
        bne     @cef1       ; branch if attacker not in 1st slot
        lda     $38fa
        sta     $df
        lda     #$05        ; hit rate +25%
        sta     $e1
        jsr     Mult8
        lsr     $e4
        ror     $e3
        lsr     $e4
        ror     $e3
        lda     $e3
        sta     $38fa
@cef1:  lda     $289f
        and     #$80
        beq     @ceff       ; branch if not fixed no. of hits
        lda     #$01
        sta     $38fb       ; 1 hit
        bra     @cf0b
@ceff:  ldx     $c7
        lda     $2697,x     ; (intellect or spirit) / 2 + 1
        jsr     Lsr_2
        inc
        sta     $38fb       ; set base no. of hits
@cf0b:  jsr     CalcHits
        lda     $38fd
        sta     $3551       ; set no. of hits
        lda     $352a
        bne     @cf1e       ; branch if an item
        lda     $38ed
        beq     @cf23       ; branch if not using a summon
@cf1e:  lda     #$08        ; 8 hits
        sta     $3551
@cf23:  lda     $38eb
        beq     @cf2e       ; branch if not weapon magic
        lda     $38ec       ; use weapon magic no. of hits
        sta     $3551

; start of target loop
@cf2e:  stz     $3554       ; clear reflect target flag
        clr_ax
        lda     $354f       ; targets
@cf36:  asl
        bcs     @cf3c       ; find first target
        inx
        bne     @cf36
@cf3c:  lda     $354f
        jsr     ClearBit
        sta     $354f
        txa
        ora     $354e
        sta     $ce
        lda     $ce
        bpl     @cf54       ; branch if character target
        and     #$7f
        clc
        adc     #$05
@cf54:  tax
        lda     $3540,x
        beq     @cf5d       ; branch if target present
        jmp     @d033
@cf5d:  lda     $ce
        jsr     GetObjPtr
        ldy     #$007f
@cf65:  lda     ($80),y
        sta     $2700,y     ; copy target properties to buffer
        dey
        bpl     @cf65
        lda     $2706
        and     #$20
        beq     @cf79       ; branch if target doesn't have reflect
        lda     $28a1
        bpl     @cf7c       ; branch if attack can be reflected
@cf79:  jmp     @d004

; magic reflected
@cf7c:  lda     $ce
        bpl     @cf8d       ; branch if character target
        jsr     FindValidChar
        lda     $a9
        beq     @cf8d       ; branch if a target was found
        stz     $3550       ; clear targets
        jmp     @d290
@cf8d:  jsr     RemoveTarget
        lda     $ce
        and     #$7f
        tax
        clr_a
        jsr     SetBit
        sta     $a9
        lda     $3522       ; set target reflected off of
        ora     $a9
        sta     $3522
@cfa3:  lda     $354e       ; toggle target side
        eor     #$80
        bpl     @cfae
        lda     #$07        ; choose random monster
        bra     @cfb0
@cfae:  lda     #4          ; choose random character
@cfb0:  ldx     #0
        jsr     RandXA
        sta     $a9
        lda     $354e
        eor     #$80
        bpl     @cfc6
        lda     $a9
        clc
        adc     #$05
        bra     @cfc8
@cfc6:  lda     $a9
@cfc8:  tax
        lda     $3540,x
        bne     @cfa3       ; branch if target is not present
        lda     $354e
        and     #$80
        eor     #$80
        ora     $a9
        sta     $ce
        jsr     GetObjPtr
        ldy     #$007f
@cfdf:  lda     ($80),y
        sta     $2700,y     ; copy target properties to buffer
        dey
        bpl     @cfdf
        lda     $2703
        and     #$c0
        bne     @cfa3       ; branch if target is dead or stone
        lda     $ce
        and     #$7f
        tax
        clr_a
        jsr     SetBit
        sta     $a9
        lda     $3523       ; set target reflected onto
        ora     $a9
        sta     $3523
        inc     $3554       ; set reflect target flag

; end of reflect section
@d004:  lda     $2703
        and     #$c0
        bne     @d017       ; branch if target is dead or stone
        lda     $2705
        and     #$02
        bne     @d033       ; remove target if jumping
        lda     $2706
        bpl     @d039       ; branch if target is not hiding
@d017:  and     #$80
        bne     @d026       ; branch if hiding or dead

; stone target
        lda     $289f       ; magic effect
        and     #$7f
        cmp     #$0b
        beq     @d039       ; branch if esuna (heal)
        bne     @d033       ; otherwise, remove stone target

; dead target
@d026:  lda     $289f
        and     #$7f
        cmp     #$0a
        beq     @d039       ; branch if life
        cmp     #$30
        beq     @d039       ; branch if revive monster
@d033:  jsr     RemoveTarget
        jmp     @d274

; valid target
@d039:  lda     #$02        ; set damage multipliers to 1x
        sta     $38fe
        sta     $38ff
        lda     #$00
        sta     $3900       ; clear crit flag
        sta     $aa
        lda     $289d       ; magic/item attack power
        sta     $a9
        lda     $3584
        beq     @d060       ; branch if not a summon
        asl     $a9         ; power * 8
        rol     $aa
        asl     $a9
        rol     $aa
        asl     $a9
        rol     $aa
        bra     @d068
@d060:  asl     $a9         ; power * 4
        rol     $aa
        asl     $a9
        rol     $aa
@d068:  ldx     $a9
        stx     $3902       ; set base attack
        clr_ax
        stx     $a4
        stx     $a2
        lda     $cd
        and     #$80
        bne     @d084       ; branch if monster attacker
        lda     $ce
        and     #$80
        bne     @d084       ; branch if monster target

; character vs. character
        stx     $3904       ; set defense to zero
        bra     @d08b
@d084:  lda     $2724       ; mag. def
        tax
        stx     $3904
@d08b:  lda     $ce
        bpl     @d094       ; branch if character target
        and     #$7f
        clc
        adc     #$05
@d094:  sta     $cf
        jsr     SelectObj
        lda     $2723       ; mag. def rate
        sta     $38fa
        lda     $2703
        and     #$02
        beq     @d0a9       ; branch if target is not blind
        lsr     $38fa       ; halve mag. def rate
@d0a9:  lda     $cd
        and     #$7f
        bne     @d0c8       ; branch if attacker not in 1st slot
        lda     $38fa
        sta     $df
        lda     #$05        ; mag. def rate +25%
        sta     $e1
        jsr     Mult8
        lsr     $e4
        ror     $e3
        lsr     $e4
        ror     $e3
        lda     $e3
        sta     $38fa
@d0c8:  lda     $2722       ; mag. def multiplier
        sta     $38fb
        beq     @d0dc       ; branch if zero mag. def
        lda     $289f
        and     #$80
        beq     @d0dc       ; branch if not fixed no. of hits
        lda     #$01        ; 1 hit
        sta     $38fb
@d0dc:  lda     $2703
        and     #$20
        bne     @d0ea       ; branch if toad
        lda     $2705
        and     #$08
        beq     @d0ed       ; branch if not using focus
@d0ea:  stz     $38fb       ; zero mag. def multiplier
@d0ed:  lda     $ce
        bpl     @d100       ; branch if character target
        lda     $2724
        cmp     #$ff
        bne     @d100       ; branch if not 255 mag.def (katsuhisa higuchi)
        lda     #$63
        sta     $38fb       ; mag. def multiplier = 99
        sta     $38fa       ; mag. def rate = 99
@d100:  jsr     CalcHits
        lda     $cd
        and     #$80
        bne     @d115       ; branch if monster attacker
        lda     $ce
        and     #$80
        bne     @d115       ; branch if monster target

; character vs. character
        sec
        lda     $3551       ; don't subtract mag.def hits
        bra     @d126
@d115:  lda     $2770
        bpl     @d11f       ; branch if not a boss
        lda     $289e
        bmi     @d12d       ; branch if always misses bosses
@d11f:  sec
        lda     $3551
        sbc     $38fd       ; subtract mag.def hits from base hits
@d126:  sta     $38fc
        beq     @d12d
        bcs     @d152

; no hits
@d12d:  lda     $352a
        bne     @d14c       ; branch if an item
        lda     $26d2
        cmp     #$a0
        beq     @d145       ; branch if self-destruct (explode)
        cmp     #$5f
        bcc     @d14c       ; spell $5f
        cmp     #$94
        bcc     @d145
        cmp     #$a9
        bcc     @d14c
@d145:  lda     #$01        ; do 1 hit anyway
        sta     $38fc
        bra     @d152
@d14c:  jsr     RemoveTarget
        jmp     @d1b1

; 1 or more hits
@d152:  lda     $ce
        bpl     @d16b       ; branch if character target
        cmp     $cd
        beq     @d16b       ; branch if self-target
        lda     $3881
        beq     @d16b       ; branch if monsters are not invincible
        lda     $352a
        beq     @d14c       ; branch if not an item
        lda     $26d2
        cmp     #$c8
        bne     @d14c       ; branch if not crystal
@d16b:  lda     $3584
        beq     @d17f       ; branch if summon flag is not set
        lda     $26d2
        cmp     #$5a
        bcc     @d17b       ; branch if not asura
        cmp     #$5d
        bcc     @d17f       ; branch if asura
@d17b:  lda     $ce
        bpl     @d12d       ; no hits if character target
@d17f:  lda     $289f       ; attack effect
        and     #$7f
        cmp     #$7e
        beq     @d194       ; branch if graphics only
        cmp     #$7f
        bne     @d19a       ; branch if not no effect
        jsr     AddMsg3
        lda     #$00        ; こうかが　なかった (nothing happened)
        sta     $34ca
@d194:  stz     $3550       ; clear targets
        jmp     @d274
@d19a:  pha
        lda     $ce
        cmp     $cd
        bne     @d1ad       ; branch if not self-target
        lda     $268b       ; copy attacker mp to target
        sta     $270b
        lda     $268c
        sta     $270c
@d1ad:  pla
        jsr     DoMagicEffect
@d1b1:  lda     $3553
        bne     @d20f       ; branch if self-target
        lda     $cd         ; attacker
        jsr     GetDmgPtr
        lda     $34d4,x
        ora     $34d5,x
        beq     @d205       ; branch if target hasn't taken damage yet

; add to previous damage (attacker)
        lda     $a3
        and     #$3f
        sta     $a3
        lda     $34d5,x
        pha
        and     #$80
        sta     $a9
        pla
        and     #$3f
        sta     $34d5,x
        clc
        lda     $34d4,x
        adc     $a2
        sta     $34d4,x
        lda     $34d5,x
        adc     $a3
        sta     $34d5,x
        longa
        lda     $34d4,x
        cmp     #$270f
        bcc     @d1f8
        lda     #$270f
        sta     $34d4,x
@d1f8:  shorta0
        lda     $34d5,x
        ora     $a9
        sta     $34d5,x
        bra     @d20f

; set attacker damage
@d205:  lda     $a2
        sta     $34d4,x
        lda     $a3
        sta     $34d5,x
@d20f:  lda     $ce         ; target
        jsr     GetDmgPtr
        lda     $34d4,x
        ora     $34d5,x
        beq     @d25e       ; branch if no damage
        lda     $a5
        and     #$3f
        sta     $a5
        lda     $34d5,x
        pha
        and     #$80
        sta     $a9         ; save msb
        pla
        and     #$3f
        sta     $34d5,x
        clc
        lda     $34d4,x
        adc     $a4
        sta     $34d4,x
        lda     $34d5,x
        adc     $a5
        sta     $34d5,x
        longa
        lda     $34d4,x
        cmp     #$270f      ; max 9999
        bcc     @d251
        lda     #$270f
        sta     $34d4,x
@d251:  shorta0
        lda     $34d5,x
        ora     $a9
        sta     $34d5,x
        bra     @d268
@d25e:  lda     $a4
        sta     $34d4,x     ; set target damage
        lda     $a5
        sta     $34d5,x
@d268:  lda     $ce
        cmp     $cd
        bne     @d271       ; branch if not self-target
        inc     $3553       ; set self-target flag
@d271:  jsr     CopyObj

; next target
@d274:  dec     $354d
        lda     $354d
        beq     @d27f
        jmp     @cf2e
@d27f:  lda     $cd
        bpl     @d28d       ; branch if character attacker
        ldx     $2896
        lda     $33c2,x
        cmp     #$f8
        bne     @d290       ; branch if an attack chain ???
@d28d:  jsr     ApplyDmg
@d290:  lda     $3550
        sta     $34c5       ; set targets for graphics ???
        rts

; ------------------------------------------------------------------------------

; [ do magic effect ]

DoMagicEffect:
@d297:  asl
        tax
        lda     f:MagicEffectTbl,x   ; magic effect jump table
        sta     $80
        lda     f:MagicEffectTbl+1,x
        sta     $81
        lda     #$03
        sta     $82
        jml     [$0080]

; ------------------------------------------------------------------------------

; [ validate magic targets ]

; A: targets

ValidateMagicTargets:
@d2ac:  sta     $a9
        jsr     CountBits
        dex
        beq     @d32b
        lda     $38e7
        bne     @d32b       ; branch if must target must be dead
        lda     $352a
        bne     @d2d9
        lda     $26d2
        cmp     #$13
        beq     @d32b
        cmp     #$14
        beq     @d32b
        cmp     #$ab
        beq     @d32b
        cmp     #$ac
        beq     @d32b
        cmp     #$8f
        beq     @d32b
        cmp     #$5c
        beq     @d32b
@d2d9:  ldx     #$0005
        stx     $ab
        clr_axy
        lda     $354e
        bpl     @d2ed
        ldx     #$0005
        lda     #$0d
        sta     $ab
@d2ed:  lda     $3540,x
        bne     @d326
        phx
        txa
        sta     $df
        lda     #$80
        sta     $e1
        jsr     Mult8
        plx
        ldy     $e3
        lda     $2003,y
        and     #$c0
        bne     @d313
        lda     $2005,y
        and     #$02
        bne     @d313
        lda     $2006,y
        bpl     @d326
@d313:  phx
        cpx     #$0005
        bcc     @d31e
        txa
        sec
        sbc     #$05
        tax
@d31e:  lda     $a9
        jsr     ClearBit
        sta     $a9
        plx
@d326:  inx
        cpx     $ab
        bne     @d2ed
@d32b:  lda     $a9
        rts

; ------------------------------------------------------------------------------

; [ check if attack name is shown ]

CheckAttackName:
@d32e:  pha
        stz     $a9
        lsr
        ror     $a9
        lsr
        ror     $a9
        lsr
        ror     $a9
        tax
        lda     $a9
        jsr     Lsr_5
        sta     $a9
        lda     $a9
        tay
        lda     f:NoNameAttackTbl,x   ; attacks that don't show attack name
@d349:  asl
        dey
        bpl     @d349
        bcc     @d352
        pla
        clr_a               ; if set, return zero (don't show name)
        rts
@d352:  pla                 ; otherwise, return attack id
        rts

; ------------------------------------------------------------------------------

; [ check if monster flash is disabled ]

CheckMonsterFlash:
@d354:  stz     $a9
        lsr
        ror     $a9
        lsr
        ror     $a9
        lsr
        ror     $a9
        tax
        lda     $a9
        jsr     Lsr_5
        sta     $a9
        lda     $a9
        tay
        lda     f:NoMonsterFlashTbl,x   ; attacks with no monster flash
@d36e:  asl
        dey
        bpl     @d36e
        bcc     @d376
        ror
        rts
@d376:  clr_a
        rts

; ------------------------------------------------------------------------------

; [ magic effect $00: magic damage ]

MagicEffect_00:
MagicDmgEffect:
@d378:  jsr     CheckStrongElem
        lda     $38fe
        bpl     @d388
        and     #$7f
        sta     $38fe
        jmp     _d416
@d388:  jsr     CheckWeakElem
        lda     $2704
        and     #$40
        beq     _d3ae
        lda     $352a
        bne     @d3a7
        lda     $26d2
        cmp     #$28
        beq     _d3b1
        cmp     #$55
        beq     _d3b1
        cmp     #$a1
        bne     _d3ae
        rts
@d3a7:  lda     $26d2
        cmp     #$c7
        beq     _d3b1
_d3ae:  jsr     CalcDmg
_d3b1:  rts

; ------------------------------------------------------------------------------

; [ magic effect $01: magic damage w/ sap ]

MagicEffect_01:
@d3b2:  jsr     CheckStrongElem
        lda     $38fe
        bpl     @d3c2
        and     #$7f
        sta     $38fe
        jmp     RestoreHP
@d3c2:  jsr     CheckWeakElem
        jsr     CalcDmg
        lda     $352a
        bne     @d3d6
        lda     $26d2
        cmp     #$0b
        bne     _d3e4
        beq     @d3dd
@d3d6:  lda     $26d2
        cmp     #$c8
        bne     _d3e4
@d3dd:  lda     $2740
        and     #$80
        beq     _d40b
_d3e4:  lda     $2706
        ora     #$40
        sta     $2706
        lda     #$09
        sta     $d6
        lda     $cf
        jsr     CalcTimerDur
        lda     #$06        ; sap timer
        jsr     SetTimer
        lda     #$40
        sta     $2a06,x
        lda     $cf
        asl
        tax
        lda     $29eb,x     ; enable sap timer
        ora     #$20
        sta     $29eb,x
_d40b:  rts

; ------------------------------------------------------------------------------

; [ magic effect $02: restore hp ]

MagicEffect_02:
RestoreHP:
@d40c:  lda     $2740
        and     #$80
        beq     _d416
        jmp     _d3ae
_d416:  lda     $352a
        bne     @d439
        lda     $26d2
        cmp     #$11
        bne     @d439
        lda     $3906
        cmp     #$01
        bne     @d439
        longa
        sec
        lda     $2709
        sbc     $2707
        sta     $a4
        shorta0
        bra     @d43c
@d439:  jsr     CalcDmg
@d43c:  lda     $a5
        ora     #$80
        sta     $a5
        rts

; ------------------------------------------------------------------------------

; [ magic effect $03: tornado/weak (single digit hp) ]

MagicEffect_03:
@d443:  ldx     #1
        lda     #9
        jsr     RandXA
        tax
        stx     $a9
        longa
        lda     $2707
        cmp     $a9
        bcc     @d45f
        lda     $a9
        sta     $2707
        shorta
        rts
@d45f:  shorta0
        jsr     RemoveTarget
        rts

; ------------------------------------------------------------------------------

; [ magic effect $04: drain hp ]

MagicEffect_04:
@d466:  lda     $cd
        cmp     $ce
        beq     @d487
        jsr     CalcDmg
        ldx     $a4
        stx     $a2
        lda     $2740
        and     #$80
        beq     @d481
        lda     $a5
        ora     #$80
        sta     $a5
        rts
@d481:  lda     $a3
        ora     #$80
        sta     $a3
@d487:  rts

; ------------------------------------------------------------------------------

; [ magic effect $05: drain mp ]

MagicEffect_05:
@d488:  lda     $cd
        cmp     $ce
        bne     @d48f
        rts
@d48f:  jsr     CalcDmg
        ldx     $a4
        stx     $a2
        lda     $2740
        and     #$80
        beq     @d49f
        bra     @d4dc
@d49f:  longa
        sec
        lda     $270b
        sbc     $a4
        bcs     @d4b5
        lda     $270b
        sta     $a4
        sta     $a2
        stz     $270b
        bra     @d4b8
@d4b5:  sta     $270b
@d4b8:  clc
        lda     $268b
        adc     $a4
        sta     $268b
        lda     $268d
        cmp     $268b
        bcs     @d4cc
        sta     $268b
@d4cc:  shorta0
        lda     $a5
        ora     #$40
        sta     $a5
        lda     $a3
        ora     #$c0
        sta     $a3
        rts
@d4dc:  longa
        sec
        lda     $268b
        sbc     $a4
        bcs     @d4f2
        lda     $268b
        sta     $a4
        sta     $a2
        stz     $268b
        bra     @d4f5
@d4f2:  sta     $268b
@d4f5:  shorta0
        lda     $a3
        ora     #$40
        sta     $a3
        lda     $a5
        ora     #$c0
        sta     $a5
        rts

; ------------------------------------------------------------------------------

; [ magic effect $06: set status ]

MagicEffect_06:
SetMagicStatus:
@d505:  lda     $28a3
        bpl     SetMagicStatus2
        lda     $2740
        and     #$8a
        beq     SetMagicStatus2
        jmp     _d5a2

SetMagicStatus2:
@d514:  lda     $2703
        sta     $ac
        sta     $a9
        lda     $2704
        sta     $aa
        and     #$bf
        sta     $ab
        lda     $28a3
        sta     $ae
        lda     $28a4
        sta     $ad
        longa
        lda     $ab
        cmp     $ad
        bcc     @d53c
        shorta0
        jmp     _d5a2
@d53c:  shorta0
        lda     $272b
        and     $28a3
        bne     @d54d
        lda     $272c
        and     $28a4
@d54d:  bne     _d5a2
        lda     $2703
        ora     $ae
        sta     $2703
        lda     $2704
        ora     $ad
        sta     $2704
        lda     $28a4
        and     #$28
        beq     @d5a0
        lda     $2704
        and     #$fb
        sta     $2704
        lda     $cf
        sta     $df
        lda     #$15
        sta     $e1
        jsr     Mult8
        ldx     $e3
        stx     $3530
        lda     #$03
        jsr     GetTimerPtr
        ldx     $3598
        lda     $2704
        and     #$20
        beq     @d5a0
        lda     $2704
        and     #$f7
        sta     $2704
        lda     #$01
        sta     $2a04,x
        stz     $2a05,x
        stz     $2a06,x
@d5a0:  bra     _d5a5
_d5a2:  jsr     RemoveTarget
_d5a5:  rts

; ------------------------------------------------------------------------------

; [ magic effect $07: sleep/paralyze ]

MagicEffect_07:
SleepParalyzeEffect:
@d5a6:  lda     #$04        ; timer duration function $04 (sleep/paralyze)
        sta     $d6
        lda     $cf         ; target id
        jsr     CalcTimerDur
        lda     #$03        ; action timer
        jsr     GetTimerPtr
        ldx     $3598
        lda     $2a06,x
        bne     @d5e5       ; branch if action timer is already stopped
        lda     $272c
        and     $28a4
        bne     @d5e5       ; branch if immune to status
        lda     $2703
        sta     $ac
        lda     $2704
        and     #$bf        ; mask float status
        sta     $ab
        lda     $28a3
        sta     $ae
        lda     $28a4
        sta     $ad
        longa
        lda     $ab
        cmp     $ad
        bcc     @d5e8       ; branch if higher priority than current status
        shorta0
@d5e5:  jmp     RemoveTarget
@d5e8:  lda     $ce
        bpl     @d5f4       ; branch if a character
        lda     $2704       ; clear charm and berserk status
        and     #$f3
        sta     $2704
@d5f4:  shorta0
        lda     $2704       ; set new status
        ora     $28a4
        sta     $2704
        ldx     $3598
        lda     $d4
        sta     $2a04,x     ; set timer duration
        lda     $d5
        sta     $2a05,x
        lda     #$40
        sta     $2a06,x     ; remove status when timer expires
        rts

; ------------------------------------------------------------------------------

; [ magic effect $08: blink/image ]

MagicEffect_08:
@d613:  lda     $2706
        ora     #$0c
        sta     $2706
        rts

; ------------------------------------------------------------------------------

; [ magic effect $09: reflect (wall) ]

MagicEffect_09:
@d61c:  lda     $2706
        ora     $28a4
        sta     $2706
        lda     $289d
        sta     $397b
        lda     #$08
        sta     $d6
        lda     $cf
        jsr     CalcTimerDur
        lda     #$0f        ; reflect timer
        jsr     SetTimer
        lda     #$40
        sta     $2a06,x
        lda     $cf
        asl
        tax
        lda     $29eb,x     ; enable reflect timer
        ora     #$04
        sta     $29eb,x
        rts

; ------------------------------------------------------------------------------

; [ magic effect $0a: life ]

MagicEffect_0a:
@d64b:  lda     #$02
        sta     $38e6
        lda     $2740
        and     #$80
        beq     @d662
        lda     #$80
        sta     $28a3
        stz     $28a4
        jmp     SetMagicStatus2
@d662:  lda     $2703
        bmi     @d668
        rts
@d668:  and     #$7e
        sta     $2703
        lda     $2704
        and     #$c0
        sta     $2704
        lda     $2705
        and     #$20
        sta     $2705
        lda     $2706
        and     #$80
        sta     $2706
        stz     $d6
        lda     $cf
        jsr     CalcTimerDur
        lda     #$03        ; action timer
        jsr     SetTimer
        stz     $2a06,x
        lda     $352f
        asl
        tax
        lda     #$40
        sta     $29eb,x     ; enable action timer
        lda     $cf
        cmp     #$05
        bcc     @d6b5
        sec
        sbc     #$05
        tax
        lda     $29bd,x
        sta     $29b5,x
        tax
        inc     $29ca,x
        inc     $29cd
@d6b5:  lda     $352a
        bne     @d6c9
        lda     $26d2
        cmp     #$14
        beq     @d6db
        cmp     #$ab
        beq     @d6db
        cmp     #$ac
        beq     @d6db
@d6c9:  lda     $2716
        sta     $df
        lda     #$05
        sta     $e1
        jsr     Mult8
        ldx     $e3
        stx     $2707
        rts
@d6db:  lda     $2709
        sta     $2707
        lda     $270a
        sta     $2708
        rts

; ------------------------------------------------------------------------------

; [ magic effect $0b: esuna (heal) ]

MagicEffect_0b:
@d6e8:  lda     $352a
        beq     @d6f7
        lda     $26d2
        cmp     #$dd
        beq     @d705
        jmp     @d773
@d6f7:  lda     $26d2
        cmp     #$12
        beq     @d705
        cmp     #$86
        beq     @d705
        jmp     @d773
@d705:  lda     $ce
        bpl     @d70c
        clc
        adc     #$05
@d70c:  tax
        stz     $3560,x
        lda     $2703
        sta     $a9
        and     #$80
        sta     $2703
        lda     $2704
        sta     $aa
        and     #$44
        sta     $2704
        lda     #$10
        sta     $273b
        lda     $cf
        asl
        tax
        lda     $29eb,x     ; disable poison and petrify timers
        and     #$e6
        sta     $29eb,x
        lda     $a9
        and     #$40
        bne     @d743
        lda     $aa
        and     #$30
        beq     @d75e
        bra     @d74c
@d743:  lda     $cf
        asl
        tax
        lda     #$40
        sta     $29eb,x     ; enable action timer
@d74c:  stz     $d6
        lda     $cf
        jsr     CalcTimerDur
        lda     #$03        ; action timer
        jsr     SetTimer
        stz     $2a06,x
        jmp     @d819
@d75e:  lda     $a9
        and     #$08
        beq     @d772
        lda     a:$00ce
        bpl     @d76d
        lda     #$e1
        bra     @d76f
@d76d:  lda     #$21
@d76f:  sta     $2751
@d772:  rts
@d773:  lda     $2703
        sta     $8a
        and     $28a3
        sta     $2703
        lda     $2704
        sta     $8b
        and     $28a4
        sta     $2704
        lda     $28a3
        eor     #$ff
        sta     $8c
        lda     $28a4
        eor     #$ff
        sta     $8d
        lda     $8a
        and     #$01
        beq     @d7af
        lda     $8c
        and     #$01
        beq     @d7af
        lda     $cf
        asl
        tax
        lda     $29eb,x     ; disable poison timer
        and     #$ef
        sta     $29eb,x
@d7af:  lda     $8a
        and     #$40
        beq     @d7c6
        lda     $8c
        and     #$40
        beq     @d7c6
        lda     $cf
        asl
        tax
        lda     #$40
        sta     $29eb,x     ; enable action timer
        bra     @d7d2
@d7c6:  lda     $8b
        and     #$30
        beq     @d7e1
        lda     $8d
        and     #$30
        beq     @d7e1
@d7d2:  stz     $d6
        lda     $cf
        jsr     CalcTimerDur
        lda     #$03        ; action timer
        jsr     SetTimer
        stz     $2a06,x
@d7e1:  lda     $8b
        and     #$08
        beq     @d801
        lda     $8d
        and     #$08
        beq     @d801
        lda     $ce
        bpl     @d7f8
        lda     #$e1
        sta     $2751
        bra     @d801
@d7f8:  tax
        stz     $3560,x
        lda     #$21
        sta     $2751
@d801:  lda     $8b
        and     #$03
        beq     @d819
        lda     $8d
        and     #$03
        beq     @d819
        lda     $cf
        asl
        tax
        lda     $29eb,x     ; disable petrify timer
        and     #$f7
        sta     $29eb,x
@d819:  rts

; ------------------------------------------------------------------------------

; [ magic effect $0c: pig/size/toad ]

MagicEffect_0c:
@d81a:  lda     $272b
        and     $28a3
        bne     @d832
        lda     $2703
        and     $28a3
        bne     @d835
        lda     $2703
        cmp     $28a3
        bcc     @d835
@d832:  jmp     RemoveTarget
@d835:  lda     $2703
        eor     $28a3
        sta     $2703
        rts

; ------------------------------------------------------------------------------

; [ magic effect $0d: protect (armor) ]

MagicEffect_0d:
@d83f:  lda     $272a
        cmp     #$ff
        bne     @d849
        jmp     RemoveTarget
@d849:  lda     $1800
        cmp     #$b7
        bne     @d855
        lda     $1801
        bne     @d862       ; branch if battle $01b7 (zeromus)
@d855:  clc
        lda     $272a
        adc     #$05
        bcc     @d85f
        lda     #$ff
@d85f:  sta     $272a
@d862:  rts

; ------------------------------------------------------------------------------

; [ magic effect $0e: shell ]

MagicEffect_0e:
@d863:  lda     $2724       ; base mag.def
        cmp     #$ff
        bne     @d86d       ; branch if not maxed out
        jmp     RemoveTarget
@d86d:  lda     $1800
        cmp     #$b7
        bne     @d879
        lda     $1801
        bne     @d886       ; branch if battle $01b7 (zeromus)
@d879:  clc
        lda     $2724
        adc     #$03
        bcc     @d883
        lda     #$ff
@d883:  sta     $2724
@d886:  rts

; ------------------------------------------------------------------------------

; [ magic effect $0f: haste/slow ]

MagicEffect_0f:
@d887:  clc
        lda     $273b
        adc     $289d       ; add modifier (-3 for haste, +8 for slow)
        cmp     #$20
        bcs     @d89a
        cmp     #$0c
        bcs     @d89c
        lda     #$0c        ; max 12
        bra     @d89c
@d89a:  lda     #$20        ; max 32
@d89c:  sta     $273b
        rts

; ------------------------------------------------------------------------------

; [ magic effect $10:  ]

MagicEffect_10:
@d8a0:  lda     $ce
        bpl     @d8a7
        clc
        adc     #$05
@d8a7:  tax
        stz     $356d,x
        lda     $2704
        sta     $a9
        and     #$fb
        sta     $2704
        lda     $a9
        and     #$04
        beq     @d8c9
        lda     a:$00ce
        bpl     @d8c4
        lda     #$e1
        bra     @d8c6
@d8c4:  lda     #$21
@d8c6:  sta     $2751
@d8c9:  lda     $2706
        and     #$83
        sta     $2706
        lda     $cf
        asl
        tax
        lda     $29eb,x     ; disable stop and sap timers
        and     #$5f
        sta     $29eb,x
        rts

; ------------------------------------------------------------------------------

; [ magic effect $11: stop/magnet ]

MagicEffect_11:
@d8de:  lda     $2705
        ora     #$40
        sta     $2705
        lda     $289d
        sta     $397b
        lda     #$0a
        sta     $d6
        lda     $cf
        jsr     CalcTimerDur
        ldx     $3530
        lda     $d4
        sta     $2a04,x
        lda     $d5
        sta     $2a05,x
        lda     #$40
        sta     $2a06,x
.if !BUGFIX_REV1
        stz     $2a09,x
.endif
        lda     $cf
        asl
        tax
        lda     $29eb,x     ; enable stop timer
        ora     #$80
        sta     $29eb,x
        rts

; ------------------------------------------------------------------------------

; [ magic effect $12: libra (peep) ]

MagicEffect_12:
@d917:  lda     $1800
        cmp     #$b7
        bne     @d926
        lda     $1801
        beq     @d926       ; branch if not battle $01b7 (zeromus)
        jmp     RemoveTarget
@d926:  longa
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
        bne     @d955
        lda     #$14
        sta     $34cb
        bra     @d96a
@d955:  clr_axy
@d958:  lsr     $a9
        bcc     @d964
        tya
        clc
        adc     #$15
        sta     $34cb,x
        inx
@d964:  iny
        cpy     #$0006
        bne     @d958
@d96a:  lda     #$1e
        sta     $34ca
        jmp     AddMsg3

; ------------------------------------------------------------------------------

; [ spell effect $13: escape ]

MagicEffect_13:
@d972:  lda     $38e5
        and     #$01
        bne     @d984
        inc     $38f3
        inc
        sta     $38d3
        sta     $35a3
        rts
@d984:  stz     $3550
        jsr     AddMsg3
        lda     #$22
        sta     $34ca
        rts

; ------------------------------------------------------------------------------

; [ magic effect $14: damage based on attacker's current hp ]

MagicEffect_14:
@d990:  jsr     CheckStrongElem
        lda     $38fe
        bpl     @d9a0
        and     #$7f
        sta     $38fe
        jmp     RestoreHP
@d9a0:  jsr     CheckWeakElem
        lda     #$01
        sta     $38fc
        ldx     $2687
        stx     $3945
        lda     $289d
        tax
        stx     $3947
        jsr     Div16
        ldx     $3949
        stx     $3902
        clr_ax
        stx     $3904
        jsr     CalcDmg
        lda     $28a3
        and     #$fe
        bne     @d9d4
        lda     $28a4
        and     #$cc
        beq     @d9d7
@d9d4:  jmp     SetMagicStatus
@d9d7:  lda     $28a3
        and     #$01
        beq     @d9e1
        jmp     _da34
@d9e1:  lda     $28a4
        and     #$30
        beq     @d9eb
        jmp     SleepParalyzeEffect
@d9eb:  rts

; ------------------------------------------------------------------------------

; [ magic effect $15: restore mp ]

MagicEffect_15:
@d9ec:  jsr     CalcDmg
        longa
        clc
        lda     $a4
        adc     $270b
        cmp     $270d
        bcc     @d9ff
        lda     $270d
@d9ff:  sta     $270b
        shorta0
        lda     $a5
        ora     #$c0
        sta     $a5
        rts

; ------------------------------------------------------------------------------

; [ magic effect $16: elixir ]

MagicEffect_16:
@da0c:  longa
        lda     $2709
        sta     $2707
        lda     $270d
        sta     $270b
        shorta0
        rts

; ------------------------------------------------------------------------------

; [ magic effect $17: poison/venom ]

MagicEffect_17:
@da1e:  jsr     CheckStrongElem
        lda     $38fe
        bpl     @da2e
        and     #$7f
        sta     $38fe
        jmp     RestoreHP
@da2e:  jsr     CheckWeakElem
        jsr     CalcDmg
_da34:  lda     $2703
        ora     #$01
        sta     $2703
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
        rts

; ------------------------------------------------------------------------------

; [ magic effect $18: cockatrice ]

MagicEffect_18:
@da66:  jsr     CheckStrongElem
        lda     $38fe
        bpl     @da76
        and     #$7f
        sta     $38fe
        jmp     RestoreHP
@da76:  jsr     CheckWeakElem
        jsr     CalcDmg
        jmp     SetMagicStatus

; ------------------------------------------------------------------------------

; [ magic effect $19: mindflayer (mage) ]

MagicEffect_19:
@da7f:  jsr     CheckStrongElem
        lda     $38fe
        bpl     @da8f
        and     #$7f
        sta     $38fe
        jmp     RestoreHP
@da8f:  jsr     CheckWeakElem
        jsr     CalcDmg
        lda     $3550
        pha
        jsr     SleepParalyzeEffect
        pla
        sta     $3550
        rts

; ------------------------------------------------------------------------------

; [ magic effect $1a: sylph ]

MagicEffect_1a:
@daa1:  jsr     CheckStrongElem
        lda     $38fe
        bpl     @dab1
        and     #$7f
        sta     $38fe
        jmp     RestoreHP
@dab1:  jsr     CheckWeakElem
        jsr     CalcDmg
        lda     $3906
        cmp     $354d
        beq     @dac0
        rts
@dac0:  inc     $3553
        ldx     $a4
        phx
        clr_ax
        stx     $a9
        stx     $ab
        stx     $291c
        stx     $291e
        stx     $2920
@dad5:  ldx     $a9
.if BUGFIX_SYLPH_EFFECT
        lda     $3540,x
.else
        lda     $3540
.endif
        bne     @db03
        lda     $a9
        sta     $df
        lda     #$80
        sta     $e1
        jsr     Mult8
        ldx     $e3
        lda     $2003,x
        and     #$c0
        bne     @db03
        lda     $2005,x
        and     #$02
        bne     @db03
        lda     $2006,x
        bmi     @db03
        inc     $ab
        ldx     $a9
        inc     $291c,x
@db03:  inc     $a9
        lda     $a9
        cmp     #$05
        bne     @dad5
        ldx     $a4
        stx     $3945
        ldx     $ab
        stx     $3947
        jsr     Div16
        ldx     $3949
        stx     $a4
        clr_ax
        stx     $a9
@db21:  ldx     $a9
        lda     $291c,x
        beq     @db5e
        lda     $a9
        sta     $df
        lda     #$80
        sta     $e1
        jsr     Mult8
.if !LANG_EN .or EASY_VERSION
        longa
        ldx     $e3
        clc
        lda     $2007,x
        adc     $a4
        cmp     $2009,x
        bcc     @db45
        lda     $2009,x
@db45:  sta     $2007,x
        shorta0
.endif
        jsr     SummonFailed
        lda     $a9
        asl
        tax
        lda     $a4
        sta     $34d4,x
        lda     $a5
        ora     #$80
        sta     $34d5,x
@db5e:  inc     $a9
        lda     $a9
        cmp     #$05
        bne     @db21
        plx
        stx     $a4
        rts

; ------------------------------------------------------------------------------

; [ magic effect $1b: odin ]

MagicEffect_1b:
@db6a:  lda     #$01
        sta     $354d
        jsr     Rand99
        cmp     #$32
        bcc     @db8c
        clr_a
        sta     $3550
        tax
        stx     $a9
@db7d:  jsr     SummonFailed
        jsr     NextObj
        inc     $a9
        lda     $a9
        cmp     #$05
        bne     @db7d
        rts
@db8c:  lda     $2703
        ora     #$80
        sta     $2703
        stz     $ab
        lda     $354f
        sta     $a9
@db9b:  asl     $a9
        bcc     @dbb7
        clc
        lda     $ab
        adc     #$05
        sta     $df
        lda     #$80
        sta     $e1
        jsr     Mult8
        ldx     $e3
        lda     $2003,x
        ora     #$80
        sta     $2003,x
@dbb7:  inc     $ab
        lda     $ab
        cmp     #$08
        bne     @db9b
        rts

; ------------------------------------------------------------------------------

; [ magic effect $1c/$1d: doom (count) ]

MagicEffect_1c:
MagicEffect_1d:
@dbc0:  lda     $2705
        ora     #$01
        sta     $2705
        lda     $cf
        jsr     SelectObj
        lda     #$12
        jsr     GetTimerPtr
        ldx     $3598
        lda     $289d
        sta     $2a04,x
        stz     $2a05,x
        lda     #$40
        sta     $2a06,x
        lda     $cf
        asl
        tax
        lda     $29eb,x     ; enable doom timer
        ora     #$02
        sta     $29eb,x
        rts

; ------------------------------------------------------------------------------

; [ magic effect $1e: damage based on target max hp ]

MagicEffect_1e:
@dbf0:  lda     $289d
        sta     $a9
        jsr     CheckStrongElem
        lda     $38fe
        bpl     @dc05
        and     #$7f
        sta     $38fe
        jmp     RestoreHP
@dc05:  jsr     CheckWeakElem
        lda     $38fe
        cmp     #$02
        bcs     @dc15
        lda     #$0a
        sta     $a9
        bra     @dc1b
@dc15:  cmp     #$04
        bcc     @dc1b
        lsr     $a9
@dc1b:  lda     $a9
        tax
        stx     $3947
        lda     $2709
        sta     $3945
        lda     $270a
        sta     $3946
        jsr     Div16
        ldx     $3949
        stx     $a4
        rts

; ------------------------------------------------------------------------------

; [ magic effect $1f: gradual petrify ]

MagicEffect_1f:
@dc36:  jsr     CheckStrongElem
        lda     $38fe
        bpl     @dc46
        and     #$7f
        sta     $38fe
        jmp     RestoreHP
@dc46:  lda     $272c
        and     $28a4
        beq     @dc51
        jmp     RemoveTarget
@dc51:  lda     $2704
        and     #$fc
        sta     $aa
        lda     $2704
        and     #$03
        clc
        adc     #$01
        cmp     #$04
        bcc     @dc6c
        lda     $aa
        sta     $2704
        jmp     SetMagicStatus
@dc6c:  ora     $aa
        sta     $2704
        lda     #$07
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

; ------------------------------------------------------------------------------

; [ magic effect $20: gaze ]

MagicEffect_20:
@dc9b:  ldx     #3
        lda     #5
        jsr     RandXA
        tay
        sta     a:$00a9
        sec
@dca8:  ror     $28a4
        dey
        bne     @dca8
        lda     a:$00a9
        cmp     #$05
        beq     @dcb8
        jmp     SleepParalyzeEffect
@dcb8:  jmp     SetMagicStatus2

; ------------------------------------------------------------------------------

; [ magic effect $21: bluster ]

MagicEffect_21:
@dcbb:  ldx     #0
        lda     #1
        jsr     RandXA
        tax
        bne     @dcce
        lda     #$80
        sta     $28a3
        jmp     SetMagicStatus2
@dcce:  lda     #$20
        sta     $28a4
        jmp     SleepParalyzeEffect

; ------------------------------------------------------------------------------

; [ magic effect $22: slap ]

MagicEffect_22:
@dcd6:  ldx     #0
        lda     #2
        jsr     RandXA
        tax
        bne     @dce9
        lda     #$20
        sta     $28a4
        jmp     SleepParalyzeEffect
@dce9:  dec
        bne     @dcf3
        lda     #$04
        sta     $28a3
        bra     @dcf8
@dcf3:  lda     #$80
        sta     $28a4
@dcf8:  jmp     SetMagicStatus2

; ------------------------------------------------------------------------------

; [ magic effect $23: blast ]

MagicEffect_23:
@dcfb:  lda     #$20
        sta     $28a4
        jsr     SleepParalyzeEffect
        jmp     _d3e4

; ------------------------------------------------------------------------------

; [ magic effect $24: hug ]

MagicEffect_24:
@dd06:  longa
        sec
        lda     $2709
        sbc     $2707
        sta     $a4
        shorta0
        lda     $a5
        ora     #$80
        sta     $a5
        jmp     SetMagicStatus

; ------------------------------------------------------------------------------

; [ magic effect $25: explode/fission ]

MagicEffect_25:
@dd1d:  lda     #$05
        sta     $38e6
        longa
        lda     $2687
.if BUGFIX_REV1
        cmp     #9999
        bcc     @dd27
        lda     #9999
.endif
@dd27:  sta     $a4
        shorta0
        lda     #$80
        sta     $2683
        rts

; ------------------------------------------------------------------------------

; [ magic effect $26: reaction ]

MagicEffect_26:
@dd32:  lda     #$05
        sta     $38e6
        lda     #$80
        sta     $2683
        sta     $2703
        ldx     #$0280
        ldy     #$0008
@dd45:  lda     #$80
        sta     $2003,x
        jsr     NextObj
        dey
        bne     @dd45
        rts

; ------------------------------------------------------------------------------

; [ magic effect $27: remedy ]

MagicEffect_27:
@dd51:  lda     $2709
        sta     $3945
        lda     $270a
        sta     $3946
        ldx     #$000a
        stx     $3947
        bra     _dd77

; ------------------------------------------------------------------------------

; [ magic effect $2c: absorb ]

MagicEffect_2c:
@dd65:  lda     $2707
        sta     $3945
        lda     $2708
        sta     $3946
        ldx     #$0003
        stx     $3947
_dd77:  jsr     Div16
        ldx     $3949
        cpx     #$270f
        bcc     @dd88
        ldx     #$270f
        stx     $3949
@dd88:  lda     $3949
        sta     $a4
        lda     $394a
        ora     #$80
        sta     $a5
        rts

; ------------------------------------------------------------------------------

; [ magic effect $28: damage and status ]

MagicEffect_28:
@dd95:  jsr     MagicDmgEffect
        jmp     SetMagicStatus2

; ------------------------------------------------------------------------------

; [ magic effect $29: alert/call ]

MagicEffect_29:
@dd9b:  inc     $38e6
        clr_ax
@dda0:  lda     $29b5,x
        cmp     #$ff
        beq     @ddaa
        inx
        bra     @dda0
@ddaa:  stx     $8a
        lda     #$01
        jmp     ActivateMonster

; ------------------------------------------------------------------------------

; [ magic effect $2a: black hole ]

MagicEffect_2a:
@ddb1:  lda     $2704
        sta     $a9
        and     #$bb
        sta     $2704
        lda     $2706
        and     #$c3
        sta     $2706
        lda     #$10
        sta     $273b
        rts

; ------------------------------------------------------------------------------

; [ magic effect $2b: needle/counter ]

MagicEffect_2b:
@ddc9:  lda     $269d
        tax
        stx     $3902
        asl     $3902
        rol     $3903
        jmp     CalcDmg

; ------------------------------------------------------------------------------

; [ magic effect $2e: make monsters invincible ]

MagicEffect_2e:
@ddd9:  inc     $3881
; fallthrough

; ------------------------------------------------------------------------------

; [ magic effect $2d: no effect ]

MagicEffect_2d:
@dddc:  rts

; ------------------------------------------------------------------------------

; [ magic effect $2f: make monsters un-invincible ]

MagicEffect_2f:
@dddd:  dec     $3881
        rts

; ------------------------------------------------------------------------------

; [ magic effect $30: revive monster ]

MagicEffect_30:
@dde1:  lda     #$02
        sta     $38e6
        lda     $2703
        bpl     @de27
        stz     $2703
        stz     $2704
        stz     $2705
        stz     $2706
        stz     $d6
        lda     $cf
        jsr     CalcTimerDur
        lda     #$03        ; action timer
        jsr     SetTimer
        stz     $2a06,x
        lda     $352f
        asl
        tax
        lda     #$40
        sta     $29eb,x     ; enable action timer
        lda     $cf
        cmp     #$05
        bcc     @de27
        sec
        sbc     #$05
        tax
        lda     $29bd,x
        sta     $29b5,x
        tax
        inc     $29ca,x
        inc     $29cd
@de27:  lda     $2709
        sta     $2707
        lda     $270a
        sta     $2708
        rts

; ------------------------------------------------------------------------------

; [ magic effect $31: change form ]

MagicEffect_31:
@de34:  lda     #$03                    ; monster death type
        sta     $38e6
        inc     $3882
        lda     $2683
        ora     #$80
        sta     $2683
        lda     $2703
        ora     #$80
        sta     $2703
        lda     $29a0
        sta     $a9
        and     #$03
        cmp     #$03
        bne     @de5a
        jmp     @dedb
@de5a:  clr_ax
        stx     $ab
        clc
@de5f:  lda     $29b5,x
        bmi     @de68
        adc     $ab
        sta     $ab
@de68:  inx
        cpx     #8
        bne     @de5f
        lda     $ab
        bne     @deb5
        lda     $a9
        and     #$c0
        jsr     Lsr_6
        tax
        stx     $8a
        stz     $b1
        stz     $b2
        jsr     DeactivateMonster
        lda     $a9
        and     #$30
        jsr     Lsr_4
        tax
        stx     $8c
        beq     @de9a
@de8f:  lda     #1
        jsr     ActivateMonster
        dec     $8c
        lda     $8c
        bne     @de8f
@de9a:  lda     $29a0
        and     #$0c
        jsr     Lsr_2
        tax
        stx     $8c
        beq     @deb2
@dea7:  lda     #2
        jsr     ActivateMonster
        dec     $8c
        lda     $8c
        bne     @dea7
@deb2:  jmp     @df5e
@deb5:  lda     #1
        sta     $b1
        inc
        sta     $b2
        jsr     DeactivateMonster
        clr_ax
        stx     $8a
        lda     $a9
        and     #$c0
        jsr     Lsr_6
        tax
        stx     $8c
@decd:  lda     #0
        jsr     ActivateMonster
        dec     $8c
        lda     $8c
        bne     @decd
        jmp     @df5e
@dedb:  clr_ax
        clc
@dede:  lda     $29b5,x
        cmp     #2
        bne     @dee7
        bra     @df26
@dee7:  inx
        cpx     #8
        bne     @dede
        lda     $a9
        and     #$c0
        jsr     Lsr_6
        sta     a:$00ab
        lda     $a9
        and     #$30
        jsr     Lsr_4
        clc
        adc     a:$00ab
        tax
        stx     $8a
        lda     #0
        sta     $b1
        inc
        sta     $b2
        jsr     DeactivateMonster
        lda     $a9
        and     #$0c
        jsr     Lsr_2
        tax
        stx     $8c
@df19:  lda     #2
        jsr     ActivateMonster
        dec     $8c
        lda     $8c
        bne     @df19
        bra     @df5e
@df26:  clr_ax
        stx     $8a
        lda     #2
        sta     $b1
        sta     $b2
        jsr     DeactivateMonster
        lda     $a9
        and     #$c0
        jsr     Lsr_6
        tax
        stx     $8c
@df3d:  lda     #0
        jsr     ActivateMonster
        dec     $8c
        lda     $8c
        bne     @df3d
        lda     $29a0
        and     #$30
        jsr     Lsr_4
        tax
        stx     $8c
@df53:  lda     #1
        jsr     ActivateMonster
        dec     $8c
        lda     $8c
        bne     @df53
@df5e:  rts

; ------------------------------------------------------------------------------

; [ activate monster ]

; A: monster type to activate

ActivateMonster:
@df5f:  ldx     $8a
        sta     $29b5,x
        tax
        inc     $29ca,x
        inc     $29cd
        clc
        lda     $8a
        adc     #5
        sta     $88
        sta     $df
        lda     #$80
        sta     $e1
        jsr     Mult8
        ldx     $e3
        stz     $2003,x
        stz     $2004,x
        stz     $2005,x
        stz     $2006,x
        lda     $2009,x
        sta     $2007,x
        lda     $200a,x
        sta     $2008,x
        stz     $d6
        lda     $88
        jsr     CalcTimerDur
        lda     #$03                    ; action timer
        jsr     SetTimer
        stz     $2a06,x
        lda     $88
        asl
        tax
        lda     #$40
        sta     $29eb,x                 ; enable action timer
        inc     $8a
        rts

; ------------------------------------------------------------------------------

; [ deactivate monster ]

; $b1, $b2: monster types to deactivate

DeactivateMonster:
@dfb0:  ldx     #$0280
        clr_ay
@dfb5:  lda     $29b5,y
        cmp     $b1
        beq     @dfc0
        cmp     $b2
        bne     @dfc8
@dfc0:  lda     $2003,x                 ; set dead status
        ora     #$80
        sta     $2003,x
@dfc8:  jsr     NextObj
        iny
        cpy     #8
        bne     @dfb5
        rts

; ------------------------------------------------------------------------------

; [ magic effect $32: end battle ]

MagicEffect_32:
@dfd2:  lda     #$04
        sta     a:$00a8
        rts

; ------------------------------------------------------------------------------

; [ magic effect $33: targeting (search) ]

MagicEffect_33:
@dfd8:  lda     $ce         ; target
        tay
        lda     $cd
        and     #$7f
        tax
        lda     #$00
        sec
@dfe3:  ror
        dey
        bpl     @dfe3
        sta     $3883,x     ; set "targeting" target
        rts

; ------------------------------------------------------------------------------

; [ magic effect $34: hatch ]

MagicEffect_34:
@dfeb:  lda     $2705
        and     #$df
        sta     $2705
        lda     $cd
        and     #$7f
        tax
        lda     $29b5,x
        tax
        stz     $38d0,x
        rts

; ------------------------------------------------------------------------------

; [ magic effect $35: mist dragon attack ]

MagicEffect_35:
@e000:  clr_ax
        stx     $a9
@e004:  lda     $2000,x
        and     #$1f
        cmp     #$11
        beq     @e014
        jsr     NextObj
        inc     $a9
        bra     @e004
@e014:  lda     $a9
        jsr     SelectObj
        lda     #$03
        jsr     GetTimerPtr
        ldx     $3598
        lda     #$0a
        sta     $2a04,x
        stz     $2a05,x
        stz     $2a06,x
        inc     $38e4       ; delay monster death
        rts

; ------------------------------------------------------------------------------

; [ remove target ]

RemoveTarget:
@e030:  lda     $3554
        bne     @e044
        lda     $ce
        and     #$7f
        tax
        lda     $3550       ; targets
        jsr     ClearBit
        sta     $3550
        rts
@e044:  lda     $ce
        and     #$7f
        tax
        lda     $3523       ; targets reflected onto
        jsr     ClearBit
        sta     $3523
        rts

; ------------------------------------------------------------------------------

; [ get summon attack id ]

GetSummonAttack:
@e053:  cmp     #$3e
        bcc     @e071
        cmp     #$3f
        bne     @e05f
        lda     #$5d
        bra     @e077
@e05f:  ldx     #0
        lda     #2
        jsr     RandXA
        pha
        lda     #$f8
        sta     $26d4
        pla
        clc
        adc     #$3e
@e071:  sec
        sbc     #$31
        clc
        adc     #$4d
@e077:  sta     $26d2
        inc     $3584
        rts

; ------------------------------------------------------------------------------

; [ subtract mp if summon failed ]

SummonFailed:
@e07e:  lda     $2000,x
        and     #$1f
        cmp     #$11
        bne     @e093       ; return if not rydia
        lda     $268b
        sta     $200b,x
        lda     $268c
        sta     $200c,x
@e093:  rts

; ------------------------------------------------------------------------------

; magic effect jump table
MagicEffectTbl:
@e094:  .addr   MagicEffect_00
        .addr   MagicEffect_01
        .addr   MagicEffect_02
        .addr   MagicEffect_03
        .addr   MagicEffect_04
        .addr   MagicEffect_05
        .addr   MagicEffect_06
        .addr   MagicEffect_07
        .addr   MagicEffect_08
        .addr   MagicEffect_09
        .addr   MagicEffect_0a
        .addr   MagicEffect_0b
        .addr   MagicEffect_0c
        .addr   MagicEffect_0d
        .addr   MagicEffect_0e
        .addr   MagicEffect_0f
        .addr   MagicEffect_10
        .addr   MagicEffect_11
        .addr   MagicEffect_12
        .addr   MagicEffect_13
        .addr   MagicEffect_14
        .addr   MagicEffect_15
        .addr   MagicEffect_16
        .addr   MagicEffect_17
        .addr   MagicEffect_18
        .addr   MagicEffect_19
        .addr   MagicEffect_1a
        .addr   MagicEffect_1b
        .addr   MagicEffect_1c
        .addr   MagicEffect_1d
        .addr   MagicEffect_1e
        .addr   MagicEffect_1f
        .addr   MagicEffect_20
        .addr   MagicEffect_21
        .addr   MagicEffect_22
        .addr   MagicEffect_23
        .addr   MagicEffect_24
        .addr   MagicEffect_25
        .addr   MagicEffect_26
        .addr   MagicEffect_27
        .addr   MagicEffect_28
        .addr   MagicEffect_29
        .addr   MagicEffect_2a
        .addr   MagicEffect_2b
        .addr   MagicEffect_2c
        .addr   MagicEffect_2d
        .addr   MagicEffect_2e
        .addr   MagicEffect_2f
        .addr   MagicEffect_30
        .addr   MagicEffect_31
        .addr   MagicEffect_32
        .addr   MagicEffect_33
        .addr   MagicEffect_34
        .addr   MagicEffect_35

; ------------------------------------------------------------------------------

; [ check elemental resistance ]

CheckStrongElem:
@e100:  lda     $2726
        and     $28a2
        beq     @e119
        clr_a
        sta     $38fe       ; zero damage
        lda     $2726
        and     #$40
        beq     @e132
        lda     #$84        ; 2x hp restored
        sta     $38fe
        rts
@e119:  lda     $2725
        and     $28a2
        beq     @e132
        lda     #$01        ; 1/2x damage
        sta     $38fe
        lda     $2725
        and     #$40
        beq     @e132
        lda     #$82        ; 1x hp restored
        sta     $38fe
@e132:  rts

; ------------------------------------------------------------------------------

; [ check elemental weakness ]

CheckWeakElem:
@e133:  lda     $38fe
        cmp     #$02
        bne     @e155
        lda     $2721
        and     $28a2
        beq     @e148
        lda     #$08        ; 4x hp restored
        sta     $38fe
        rts
@e148:  lda     $2720
        and     $28a2
        beq     @e155
        lda     #$04        ; 2x hp restored
        sta     $38fe
@e155:  rts

; ------------------------------------------------------------------------------
