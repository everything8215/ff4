
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: equip.asm                                                            |
; |                                                                            |
; | description: character equipment routines                                  |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

; [ update character equipment (external) ]

UpdateEquip:
@97fd:  lda     $3975
        pha
        jsr     InitRAM
        pla
        sta     $3975
        jsr     LoadCharProp
        jsr     LoadEquipProp
        jsr     UpdateCharStats
        lsr     $a7
        ror     $a6
        ldx     $a6
        clr_ay
@9819:  lda     ($80),y
        sta     $1000,x
        inx
        iny
        cpy     #$0040
        bne     @9819
        ldy     #$0041
        lda     ($80),y
        ldx     $a6
        sta     $102d,x
        iny
        inx
        lda     ($80),y
        sta     $102d,x
        rts

; ------------------------------------------------------------------------------

; [ update character stats ]

UpdateCharStats:
@9837:  lda     $3975
        jsr     SelectObj
        clc
        lda     $a6
        adc     #$00
        sta     $80         ; +$80: pointer to character properties
        lda     $a7
        adc     #$20
        sta     $81
        longa
        clc
        lda     $3532
        adc     #$2780      ; +$82: pointer to equipped item data
        sta     $82
        shorta0
        lda     $352c
        beq     @9883       ; branch if no magnetization
        clr_ay
        sty     $a9
        sty     $ab
@9863:  lda     ($82),y
        bpl     @986b       ; branch if item is not magnetic
        inc     $a9
        bra     @9878
@986b:  tya
        clc
        adc     #$0b
        tay
        inc     $ab
        lda     $ab
        cmp     #$05
        bne     @9863
@9878:  lda     $a9
        beq     @9883       ; branch if no magnetic items
        ldy     #$0005
        lda     #$80        ; magnetized
        sta     ($80),y
@9883:  ldy     #$0014
        clr_a
@9887:  sta     ($80),y     ; clear mod. stats
        iny
        cpy     #$0019
        bne     @9887
        stz     $af
        ldy     #$0007

; start of item loop for stat modifiers
@9894:  lda     ($82),y
        pha
        and     #$f8
        sta     $a9         ; modified stats
        pla
        and     #$07
        asl
        tax
        lda     f:EquipStatTbl,x   ; equipment stat modifiers
        sta     $ab         ; modifier if bit set
        inx
        lda     f:EquipStatTbl,x
        sta     $ac         ; modifier if bit clear
        phy
        ldy     #$0014
@98b1:  asl     $a9
        bcc     @98bc
        clc
        lda     ($80),y     ; add 1st value if stat bit set
        adc     $ab
        bra     @98c1
@98bc:  clc
        lda     ($80),y     ; add 2nd value if stat bit clear
        adc     $ac
@98c1:  sta     ($80),y
        iny
        cpy     #$0019
        bne     @98b1
        ply                 ; next item
        tya
        clc
        adc     #$0b
        tay
        inc     $af
        lda     $af
        cmp     #$05
        bne     @9894
        ldy     #$000f      ; base stat
        sty     $a9
        ldy     #$0014      ; mod. stat
        sty     $ab
@98e1:  ldy     $a9
        clc
        lda     ($80),y     ; apply net stat modifier
        ldy     $ab
        adc     ($80),y
        cmp     #$b6        ; -74
        bcs     @98f6       ; branch if negative
        cmp     #$63
        bcc     @98f8
        lda     #$63        ; max 99
        bra     @98f8
@98f6:  lda     #$01        ; min 1
@98f8:  sta     ($80),y
        inc     $a9         ; next stat
        inc     $ab
        lda     $a9
        cmp     #$14
        bne     @98e1
        ldy     #2
        lda     ($80),y     ; character level
        sta     $3965
        clr_ax
        ldy     #$0014
@9911:  lda     ($80),y     ; mod. stats
        sta     $3966,x
        iny
        inx
        cpx     #5
        bne     @9911
        stz     $396b
        stz     $396c
        stz     $396d
        stz     $396e
        stz     $396f
        stz     $3970
        stz     $3971
        stz     $3972
        stz     $3973
        stz     $3974
        ldy     #$0025
        lda     ($82),y
        bpl     @994e       ; branch if left hand item is not a shield
        ldy     #$0021
        jsr     GetShieldProp
        lda     $396d
        sta     $396e
@994e:  ldy     #$0030
        lda     ($82),y
        bpl     @995b       ; branch if right hand item is not a shield
        ldy     #$002c
        jsr     GetShieldProp
@995b:  clr_ax
        stx     $a9         ; clear $a9 and $aa
        ldy     #8
@9962:  lda     ($82),y     ; elemental resistance
        sta     $ad,x
        tya
        clc
        adc     #$0b
        tay
        inx
        cpx     #3
        bne     @9962
        lda     $396d       ; right hand shield
        sta     $b0
        lda     $396e       ; left hand shield
        sta     $b1
        clr_ax
@997d:  lda     $ad,x
        bmi     @9987       ; branch if immune
        ora     $a9
        sta     $a9
        bra     @998b
@9987:  ora     $aa
        sta     $aa
@998b:  inx
        cpx     #5
        bne     @997d
        ldy     #$0025
        lda     $a9
        sta     ($80),y     ; strong elements
        iny
        lda     $aa
        sta     ($80),y     ; immune elements
        ldy     #5
        clr_ax
        stz     $a9         ; change to stx to fix the bug below
@99a4:  lda     ($82),y     ; creature type
        ora     $a9
        sta     $a9
        tya
        clc
        adc     #11
        tay
        inx
        cpx     #3
        bne     @99a4
        ldy     #$0027
        lda     $a9
        ora     $3974       ; shield creature type
        sta     ($80),y     ; defense vs. creature types

; defense multiplier
        ldy     #$0028
        lda     $3965
        jsr     Lsr_4
        sta     $df
        lda     $396b       ; shield multiplier
        sta     $e1
        jsr     Mult8
        lda     $3967       ; agility / 8
        jsr     Lsr_3
        clc
        adc     $e3         ; add level / 16 * shield multiplier
        sta     ($80),y     ; set defense multiplier

; defense %
        ldy     #2
        clr_ax
@99e2:  clc
        lda     ($82),y     ; defense %
        and     #$7f
        adc     $aa         ; *** bug *** this doesn't get initialized
        sta     $aa         ; retains immune elements (affects adamant armor)
        tya
        clc
        adc     #11
        tay
        inx
        cpx     #3
        bne     @99e2
        ldy     #$0029
        clc
        lda     $aa
        adc     $396c       ; shield defense %
        jsr     Max99
        sta     ($80),y     ; set defense rate

; defense
        lda     $3968       ; mod. stamina / 2
        lsr
        sta     $a9
        clr_axy
        iny
@9a0e:  clc
        lda     ($82),y     ; defense
        adc     $a9
        sta     $a9
        tya
        clc
        adc     #$0b
        tay
        inx
        cpx     #3
        bne     @9a0e
        ldy     #$002a
        clc
        lda     $a9
        adc     $396f       ; add defense from shields
        jsr     Max255
        sta     ($80),y     ; set defense

; status immunity
        clr_ax
        stx     $a9
        ldy     #9
@9a35:  lda     ($82),y     ; status 1
        ora     $a9
        sta     $a9
        iny
        lda     ($82),y     ; status 2
        ora     $aa
        sta     $aa
        tya
        clc
        adc     #$0a
        tay
        inx
        cpx     #3
        bne     @9a35

; elemental defense
        ldy     #$002b
        lda     $a9
        ora     $3970       ; shield status 1
        sta     ($80),y     ; set status 1 immunity
        iny
        lda     $aa
        ora     $3971       ; shield status 1
        sta     ($80),y     ; set status 2 immunity
        ldy     #$0025
        lda     ($80),y     ; strong elements
        sta     $a9
        jsr     GetAntiElem
        ldy     #$0020
        sta     ($80),y     ; weak elements
        ldy     #$0026
        lda     ($80),y     ; immune elements
        sta     $a9
        jsr     GetAntiElem
        beq     @9a81       ; branch if no opposing elements
        ldy     #$0021
        ora     #$80        ; set very weak flag
        sta     ($80),y     ; very weak elements

; mag. def multiplier
@9a81:  ldy     #$0022
        clc
        lda     $3969       ; intellect
        adc     $396a       ; spirit
        sta     $aa
        jsr     Lsr_5
        sta     $a9
        lda     $3967       ; agility / 32
        jsr     Lsr_5
        clc
        adc     $a9         ; add (int + spirit) / 32
        sta     ($80),y     ; set mag. def multiplier

; mag. def %
        lda     $aa
        jsr     Lsr_3
        sta     $a9         ; (int + spirit) / 8
        clr_ayx
@9aa7:  clc
        lda     ($82),y     ; armor mag. def %
        and     #$7f
        adc     $a9
        sta     $a9
        tya
        clc
        adc     #$0b
        tay
        inx
        cpx     #3
        bne     @9aa7
        ldy     #$0023
        clc
        lda     $a9
        adc     $3972       ; add shield mag. def %
        jsr     Max99
        sta     ($80),y

; mag. def base
        ldy     #3
        clr_ax
        stx     $a9
@9ad0:  clc
        lda     ($82),y     ; armor mag. def base
        adc     $a9
        sta     $a9
        tya
        clc
        adc     #$0b
        tay
        inx
        cpx     #3
        bne     @9ad0
        ldy     #$0024
        clc
        lda     $a9
        adc     $3973       ; add shield mag. def base
        jsr     Max255
        sta     ($80),y
        ldx     #$0015
@9af3:  stz     $289c,x     ; clear buffer
        dex
        bpl     @9af3
        stz     $3977
        ldy     #1
        lda     ($80),y     ; character id
        and     #$0f
        cmp     #$06
        bne     @9b0a       ; branch if not yang
        inc     $3977
@9b0a:  ldy     #$0033
        lda     ($80),y
        beq     @9b31       ; branch if no left hand item
        ldy     #$0025
        lda     ($82),y
        bmi     @9b31       ; branch if shield in left hand
        lda     $3977
        ora     #$80
        sta     $3977
        ldy     #$0021
        clr_ax
@9b25:  lda     ($82),y
        sta     $289c,x     ; copy left hand weapon to buffer
        iny
        inx
        cpx     #11
        bne     @9b25
@9b31:  ldy     #$0035
        lda     ($80),y
        beq     @9b59       ; branch if no right hand item
        ldy     #$0030
        lda     ($82),y
        bmi     @9b59       ; branch if shield in right hand
        lda     $3977
        ora     #$40
        sta     $3977
        ldy     #$002c
        ldx     #11
@9b4d:  lda     ($82),y
        sta     $289c,x     ; copy right hand weapon to buffer
        iny
        inx
        cpx     #$0016
        bne     @9b4d
@9b59:  lda     $3977
        and     #$c0
        beq     @9b69       ; branch if no weapons equipped
        eor     #$c0
        bne     @9bb9       ; branch if one weapon equipped
        lda     $28a2
        and     #$c0
@9b69:  beq     @9bb7       ; branch if no bow or arrow in left hand

; has bow and arrow
        lda     #$80
        sta     $3978       ; bow in left hand
        lda     $28a2
        and     #$80
        bne     @9bad       ; branch if bow in left hand
        lda     #$40
        sta     $3978
        clr_ax
        ldy     #$0016
@9b81:  lda     $289c,x     ; swap left and right hand
        sta     $289c,y
        inx
        iny
        cpx     #11
        bne     @9b81
        clr_ay
@9b90:  lda     $289c,x
        sta     $289c,y
        inx
        iny
        cpx     #$0016
        bne     @9b90
        ldy     #11
@9ba0:  lda     $289c,x
        sta     $289c,y
        inx
        iny
        cpy     #$0016
        bne     @9ba0
@9bad:  lda     $3977
        and     #$3f
        ora     #$a0
        sta     $3977
@9bb7:  bra     @9be4

; one weapon
@9bb9:  lda     $3977
        bmi     @9be4       ; branch if left hand has a weapon
        ldx     #11
        clr_ay
@9bc3:  lda     $289c,x     ; copy right hand to left hand
        sta     $289c,y
        inx
        iny
        cpy     #11
        bne     @9bc3
        tyx
@9bd1:  stz     $289c,x     ; clear right hand
        inx
        cpx     #$0016
        bne     @9bd1
        lda     $3977       ; treat right hand weapon as left hand
        and     #$3f
        ora     #$80
        sta     $3977

; weapon element
@9be4:  clr_ax
        stx     $a9
        lda     $28a0
        bmi     @9bf2       ; branch if shield in left hand
        lda     $28a4       ; left hand weapon element
        sta     $a9
@9bf2:  lda     $28ab
        bmi     @9bfc       ; branch if shield in right hand
        lda     $28af       ; right hand weapon element
        sta     $aa
@9bfc:  lda     $a9
        ora     $aa
        ldy     #$0019
        sta     ($80),y     ; set attack element

; weapon creature type bonus
        clr_ax
        stx     $a9
        lda     $28a0
        bmi     @9c13       ; branch if shield in left hand
        lda     $28a1       ; left hand creature type
        sta     $a9
@9c13:  lda     $28ab
        bmi     @9c1d       ; branch if shield in right hand
        lda     $28ac       ; right hand creature type
        sta     $aa
@9c1d:  lda     $a9
        ora     $aa

; attack multiplier
        ldy     #$001a
        sta     ($80),y     ; set creature type attack bonus
        lda     $3966       ; strength / 8
        jsr     Lsr_3
        sta     $a9
        lda     $3967       ; agility / 16
        jsr     Lsr_4
        clc
        adc     $a9
        inc
        ldy     #$001b
        sta     ($80),y     ; attack multiplier

; attack %
        lda     $3965       ; level / 4
        jsr     Lsr_2
        sta     $a9
        lda     $3977
        and     #$c0
        beq     @9c6d       ; branch if unarmed
        eor     #$c0
        bne     @9c76       ; branch if one weapon

; dual-wield
        clc
        lda     $289e       ; left hand weapon attack %
        and     #$7f
        adc     $a9
        sta     $aa
        clc
        lda     $28a9       ; right hand weapon attack %
        and     #$7f
        adc     $a9
        adc     $aa
        lsr
        cmp     #$63        ; max 99
        bcc     @9c81
        lda     #$63
        bra     @9c81

; unarmed
@9c6d:  clc
        lda     f:EquipProp+2           ; unarmed attack % + level / 4
        adc     $a9
        bra     @9c7e

; single weapon
@9c76:  clc
        lda     $289e       ; left hand weapon attack %
        and     #$7f
        adc     $a9
@9c7e:  jsr     Max99
@9c81:  ldy     #$001c
        sta     ($80),y     ; set attack %

; attack power
        lda     $3966       ; strength / 4
        jsr     Lsr_2
        sta     $aa
        lda     $3977
        and     #$01
        beq     @9ca0       ; branch if not yang

; yang (attack = strength / 4 + level * 2 + 2)
        lda     $3965       ; level * 2
        asl
        clc
        adc     $aa
        adc     #$02
        bra     @9d06

; not yang
@9ca0:  lda     $3977
        and     #$c0
        beq     @9cfe       ; branch if unarmed
        eor     #$c0
        bne     @9cc2       ; branch if single weapon

; dual-wield
        clc
        lda     $289d       ; left hand weapon attack
        adc     $a9         ; add level / 4
        adc     $aa         ; add strength / 4
        sta     $ab
        clc
        lda     $28a8       ; right hand weapon attack
        adc     $a9         ; add level / 4
        adc     $aa         ; add strength / 4
        clc
        adc     $ab
        bra     @9d06

; single weapon
@9cc2:  lda     $3977
        and     #$20
        beq     @9cfe       ; branch if bow with no arrows
        lda     $289d       ; weapon attack (bow)
        lsr
        clc
        adc     $28a8       ; arrow attack
        adc     $aa         ; add strength / 4
        sta     $bf
        ldy     #0
        lda     ($80),y     ; character handedness
        and     #$c0
        and     $3978
        beq     @9cfa       ; branch if bow is in main hand
        lda     $bf
        tax
        stx     $3945
        ldx     #5          ; 20% attack penalty if bow in off-hand
        stx     $3947
        jsr     Div16
        sec
        lda     $bf
        sbc     $3949
        sta     $bf
        bra     @9d09
@9cfa:  lda     $bf
        bra     @9d09

; unarmed
@9cfe:  clc
        lda     $289d
        adc     $a9
        adc     $aa
@9d06:  jsr     Max255
@9d09:  ldy     #$001d
        sta     ($80),y     ; set attack

; attack status
        lda     $28a5
        ora     $28b0
        ldy     #$001e
        sta     ($80),y
        lda     $28a6
        ora     $28b1
        iny
        sta     ($80),y
        ldy     #$0041
        lda     ($80),y     ; crit rate
        sta     $a9
        iny
        lda     ($80),y     ; crit bonus
        sta     $aa
        lda     $3977
        and     #$c0
        beq     @9d86       ; branch if unarmed
        eor     #$c0
        beq     @9d86       ; branch if single weapon
        lda     $3977
        and     #$20
        beq     @9d62       ; branch if no bow

; bow and arrow
        lda     $a9
        cmp     #$21
        bcc     @9d48
        lda     #$21
@9d48:  sta     $df
        lda     #$03        ; crit rate * 3
        sta     $e1
        jsr     Mult8
        lda     $e3
        sta     $a9
        clc
        lda     $aa
        adc     $28a8       ; add arrow attack to crit bonus
        jsr     Max255
        sta     $aa
        bra     @9d7a

; dual-wield
@9d62:  asl     $a9         ; 2x crit rate
        bcc     @9d6a
        lda     #$63        ; max 99
        bra     @9d6c
@9d6a:  lda     $a9
@9d6c:  sta     $a9
        lda     $289d       ; add left hand attack / 2 to crit bonus
        lsr
        clc
        adc     $aa
        jsr     Max255
        sta     $aa
@9d7a:  ldy     #$002d
        lda     $a9
        sta     ($80),y     ; set crit rate
        iny
        lda     $aa
        sta     ($80),y     ; set crit bonus
@9d86:  lda     $3977
        and     #$20
        bne     @9d94       ; branch if bow and arrow
        lda     $289c
        and     #$20
        beq     @9d9d       ; branch if weapon has back row penalty
@9d94:  ldy     #1
        lda     ($80),y     ; no back row penalty
        ora     #$20
        sta     ($80),y
@9d9d:  rts

; ------------------------------------------------------------------------------

; [ get opposing elements ]

; *** bug *** adamant armor makes a character very weak to fire and ice

GetAntiElem:
@9d9e:  and     #$12        ; mask holy and ice
        lsr                 ; shift to darkness and fire
        sta     $aa
        lda     $a9
        and     #$09        ; mask darkness and fire
        asl                 ; shift to holy and ice
        ora     $aa
        rts

; ------------------------------------------------------------------------------

; [ get shield properties ]

GetShieldProp:
@9dab:  inc     $396b       ; increment shield multiplier
        clc
        lda     ($82),y     ; mag. def %
        and     #$7f
        adc     $3972
        sta     $3972
        iny
        clc
        lda     ($82),y     ; defense
        adc     $396f
        sta     $396f
        iny
        clc
        lda     ($82),y     ; defense %
        and     #$7f
        adc     $396c
        sta     $396c
        iny
        clc
        lda     ($82),y     ; mag. def
        adc     $3973
        sta     $3973
        iny2
        lda     ($82),y     ; creature type
        ora     $3974
        sta     $3974
        iny3
        lda     ($82),y     ; element
        sta     $396d
        iny
        lda     ($82),y     ; status 1
        ora     $3970
        sta     $3970
        iny
        lda     ($82),y     ; status 2
        ora     $3971
        sta     $3971
        rts

; ------------------------------------------------------------------------------

; [ copy equipped item data to character properties ]

CopyEquip:
@9dfe:  lda     $3975       ; current character slot
        jsr     Asl_3
        tay
        ldx     $a6
        lda     $32db,y     ; left hand item
        sta     $2033,x
        lda     $32dc,y     ; left hand quantity
        sta     $2034,x
        lda     $32df,y     ; right hand item
        sta     $2035,x
        lda     $32e0,y     ; right hand quantity
        sta     $2036,x
        rts

; ------------------------------------------------------------------------------

; [ max 99 ]

Max99:
@9e20:  cmp     #99
        bcc     @9e26
        lda     #99
@9e26:  rts

; ------------------------------------------------------------------------------

; [ max 255 ]

Max255:
@9e27:  bcc     @9e2b
        lda     #$ff
@9e2b:  rts

; ------------------------------------------------------------------------------
