
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: char.asm                                                             |
; |                                                                            |
; | description: character attack selection routines                           |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

; [ update enabled inventory items ]

UpdateEnabledItems:
@a0f7:  stz     $a9
        stz     $aa
        lda     $1822
        jsr     SelectObj
        ldx     $a6
        lda     $2001,x     ; character graphics id
        and     #$0f
        tay
        iny
        sec
@a10b:  rol     $a9         ; set flag for character graphics id in +$a9
        rol     $aa
        dey
        bne     @a10b
        clr_ax
        stx     $af
; start of item loop
@a116:  ldx     $af
        lda     $321b,x     ; inventory item id
        beq     @a14c       ; branch if empty
        cmp     #$c8
        bne     @a12e       ; branch if not crystal
        ldx     $a6
        lda     $2000,x
        and     #$1f
        cmp     #$0b
        bne     @a136       ; branch if not paladin cecil
        beq     @a142
@a12e:  jsr     CheckCanUseItem
        lda     $353d
        beq     @a142       ; branch if character can use item
@a136:  ldx     $af
        lda     $321a,x     ; disable item
        ora     #$80
        sta     $321a,x
        bra     @a14c
@a142:  ldx     $af
        lda     $321a,x     ; enable item
        and     #$7f
        sta     $321a,x
@a14c:  clc                 ; next item
        lda     $af
        adc     #$04
        sta     $af
        cmp     #$c0
        bne     @a116
        rts

; ------------------------------------------------------------------------------

; [ check if character can use item ]

CheckCanUseItem:
@a158:  stz     $353d
        cmp     #$6d
        bcc     @a169
        cmp     #$de
        bcs     @a197
        cmp     #$b0
        bcc     @a197
        bcs     @a19a
@a169:  tax
        stx     $e5
        ldx     #.loword(EquipProp)
        stx     $80
        lda     #^EquipProp
        sta     $82
        lda     #$08
        jsr     LoadArrayItem
        lda     $28a2
        and     #$1f
        asl
        tax
        lda     f:ItemClasses,x   ; item equipability
        sta     $ab
        lda     f:ItemClasses+1,x
        sta     $ac
        longa
        lda     $ab
        and     $a9
        shorta
        bne     @a19a       ; branch if character can use item
@a197:  inc     $353d
@a19a:  longa
        shorta0
        rts

; ------------------------------------------------------------------------------

; [ update enabled commands and spells ]

UpdateEnabledCmds:
@a1a0:  stz     $a9         ; is mute
        stz     $aa
        stz     $ab         ; is toad
        stz     $ac         ; is pig
        ldx     $a6
        lda     $2003,x
        and     #$04
        beq     @a1b5       ; branch if not mute
        lda     #$80
        sta     $a9
@a1b5:  lda     $2003,x
        and     #$20
        beq     @a1c0       ; branch if not toad
        lda     #$80
        sta     $ab
@a1c0:  lda     $2003,x
        and     #$08
        beq     @a1cb       ; branch if not pig
        lda     #$80
        sta     $ac
@a1cb:  lda     $200b,x     ; $ad: current mp (max 255)
        sta     $ad
        lda     $200c,x
        beq     @a1d9
        lda     #$ff
        sta     $ad
@a1d9:  ldx     $a6
        lda     $2006,x
        bmi     @a1f7       ; branch if hiding
        ldy     #5
        ldx     $3534
@a1e6:  lda     $3303,x     ; battle command id
        cmp     #$ff
        beq     @a1f0       ; branch if no command
        jsr     CheckCmdEnabled
@a1f0:  inx4
        dey
        bne     @a1e6
@a1f7:  lda     $aa
        beq     @a205       ; branch if no commands changed
        lda     $1822
        sta     $00
        lda     #$09        ; battle graphics $09: draw battle command list
        jsr     ExecBtlGfx
@a205:  ldx     $3536
        stx     $af
        clr_ax
        stx     $b1
; start of spell loop
@a20e:  ldx     $af
        lda     $2c7b,x     ; spell id
        beq     @a260
        lda     $2c7a,x
        and     #$7f
        ora     $a9
        ora     $ab
        ora     $ac
        sta     $2c7a,x
        lda     $a9
        bne     @a24f       ; branch if mute
        lda     $ab
        bpl     @a23c       ; branch if no toad status
        lda     $2c7b,x
        cmp     #$19
        bne     @a24f
        lda     $2c7a,x
        and     #$7f
        sta     $2c7a,x
        bra     @a24f
@a23c:  lda     $ac
        bpl     @a24f       ; branch if no pig status
        lda     $2c7b,x
        cmp     #$1a
        bne     @a24f
        lda     $2c7a,x
        and     #$7f
        sta     $2c7a,x
@a24f:  lda     $2c7d,x
        cmp     $ad
        beq     @a260
        bcc     @a260
        lda     $2c7a,x
        ora     #$80
        sta     $2c7a,x
@a260:  ldx     $af
        inx4
        stx     $af
        inc     $b1
        lda     $b1
        cmp     #$48
        beq     @a273
        jmp     @a20e
@a273:  lda     $1822
        sta     $00
        lda     #$0e        ; battle graphics $0e: draw spell list
        jsr     ExecBtlGfx
        rts

; ------------------------------------------------------------------------------

; [ check if battle command is enabled ]

CheckCmdEnabled:
@a27e:  stz     $b5
        phx
        lda     $3303,x     ; command id
        cmp     #$05
        beq     @a294
        cmp     #$08
        beq     @a294
        cmp     #$0c
        beq     @a294
        cmp     #$10
        bne     @a29b
; dark wave, sing, aim, twin
@a294:  jsr     CheckCmdReq
        lda     $b3
        bne     @a2be
@a29b:  plx
        phx
        lda     $3303,x
        asl
        tax
        lda     f:DisableCmdStatusTbl,x   ; status 1 and 2 that disable each command
        sta     $b3
        lda     f:DisableCmdStatusTbl+1,x
        sta     $b4
        ldx     $a6
        lda     $2003,x
        and     $b3
        bne     @a2be
        lda     $2004,x
        and     $b4
        beq     @a2c2
@a2be:  lda     #$80
        sta     $b5
@a2c2:  plx
        lda     $3302,x     ; set disabled bit
        pha
        and     #$7f
        ora     $b5
        sta     $3302,x
        pla
        cmp     $3302,x
        beq     @a2d8
        lda     #$01        ; enabled/disabled flag changed
        sta     $aa
@a2d8:  rts

; ------------------------------------------------------------------------------

; [ check command requirements ]

CheckCmdReq:
@a2d9:  ldx     $a6
        stz     $b3
        cmp     #$08
        beq     @a2ff
        cmp     #$0c
        beq     @a31b
        cmp     #$10
        beq     @a32f
; dark wave (must have a weapon equipped)
        lda     $2033,x
        beq     @a2f5
        cmp     #$61
        bcs     @a2f5
        jmp     @a370
@a2f5:  lda     $2035,x
        beq     @a36e
        cmp     #$61
        bcs     @a36e
        rts
; sing (must have a harp equipped)
@a2ff:  lda     $2033,x
        beq     @a30d
        cmp     #$44
        bcc     @a36e
        cmp     #$4d
        bcs     @a36e
        rts
@a30d:  lda     $2035,x
        beq     @a36e
        cmp     #$44
        bcc     @a36e
        cmp     #$4d
        bcs     @a36e
        rts
; aim (must have a bow equipped)
@a31b:  lda     $2033,x
        beq     @a36e
        cmp     #$4d
        bcc     @a36e
        cmp     #$61
        bcs     @a36e
        lda     $2035,x
        beq     @a36e
        bne     @a370
; twin (other twin must be available)
@a32f:  phx
        ldx     $3536
        phx
        ldx     $a6
        lda     $2003,x
        and     #$3c
        bne     @a367
        ldx     #1
        lda     $d0
        cmp     $3539
        beq     @a348
        dex
@a348:  lda     $3539,x
        jsr     SelectObj
        ldx     $a6
        lda     $2003,x
        and     #$fc
        bne     @a367
        lda     $2004,x
        and     #$3c
        bne     @a367
        lda     $2005,x
        and     #$40
        bne     @a367
        dec     $b3
@a367:  plx
        stx     $3536
        plx
        stx     $a6
@a36e:  inc     $b3
@a370:  rts

; ------------------------------------------------------------------------------

; [ action type 0: choose character action ]

GetCharAttack:
@a371:  lda     $1800
        cmp     #$b7
        bne     @a382
        lda     $1801
        beq     @a382       ; branch if not battle $01b7 (zeromus)
        lda     $38f7
        beq     @a3e2
@a382:  lda     $38f3
        bne     @a396
        lda     $2282
        cmp     #$63
        beq     @a399
        cmp     #$62
        beq     @a399
        cmp     #$61
        beq     @a399
@a396:  stz     $38d6
@a399:  clr_ax
@a39b:  lda     $3929,x
        cmp     $d2
        beq     @a3e2
        inx
        cpx     #5
        bne     @a39b
        lda     $d0
        sta     $8c
        lda     $d2
        jsr     SelectObj
        lda     #$03
        jsr     GetTimerPtr
        ldx     $3598
        lda     $2a06,x
        and     #$fe
        sta     $2a06,x
        lda     $d2
        sta     $d0
        jsr     ValidateChar
        lda     $d0
        sta     $aa
        lda     $8c
        sta     $d0
        lda     $aa
        cmp     #$ff
        beq     @a3e2
        lda     $392f
        tax
        lda     $d2
        sta     $3929,x
        inc     $392f
@a3e2:  rts

; ------------------------------------------------------------------------------

; [ open/close menu ]

UpdateMenu:
@a3e3:  lda     $d7
        beq     @a439       ; branch if menu is not open

; check if menu needs to close
        lda     $d0
        cmp     #$ff
        beq     @a438       ; return if no selected character
        jsr     ValidateChar
        lda     $d0
        cmp     #$ff
        beq     @a42f       ; close menu if character was invalid
        ldx     $a6
        lda     $2000,x
        and     #$1f
        cmp     #$05
        bne     @a415       ; branch if not edward
        lda     $3582
        bne     @a415       ; branch if a boss battle
        lda     $38db       ; number of character targets
        dec
        beq     @a415       ; branch if edward is alone
        lda     $2006,x
        bmi     @a415       ; branch if hiding
        and     #$01
        bne     @a42f       ; branch if critical
@a415:  jsr     UpdateEnabledCmds
        lda     $d0
        jsr     Asl_3
        tax
        lda     $32db,x     ; left hand item id
        cmp     #$4c
        beq     @a42c       ; branch if avenger sword
        lda     $32df,x     ; right hand item id
        cmp     #$4c
        bne     @a438       ; return if not avenger sword
@a42c:  jsr     AvengerEffect
@a42f:  lda     #$ff
        sta     $d0
        lda     #$01        ; battle graphics $01: close menu
        jsr     ExecBtlGfx
@a438:  rts

; do selected command
@a439:  lda     $d0
        cmp     #$ff
        beq     @a463       ; branch if no selected character
        jsr     ValidateChar
        lda     $d0
        cmp     #$ff
        beq     @a462       ; branch if character was invalid
        lda     $388b
        beq     @a450       ; branch if no auto-battle
        jsr     GetAutoCmd
@a450:  ldx     #5
@a453:  lda     $d7,x
        sta     $3937,x     ; copy to character action buffer
        dex
        bpl     @a453
        jsr     ValidateCmd
        lda     #$ff
        sta     $d0         ; deselect character
@a462:  rts

; check if menu needs to open
@a463:  lda     $352d
        bne     @a4c7       ; return if holding l and r
        lda     $3929
        cmp     #$ff
        beq     @a4c7       ; return if battle menu queue is empty
        pha
        clr_ax
@a472:  lda     $392a,x     ; shift battle menu queue
        sta     $3929,x
        inx
        cpx     #5
        bne     @a472
        dec     $392f       ; decrement battle menu queue size
        pla
        sta     $1822       ; set selected character for menu
        sta     $d0
        jsr     ValidateArrows
        jsr     ValidateChar
        lda     $d0
        cmp     #$ff
        beq     @a4c7       ; return if character is invalid
        jsr     UpdateEnabledItems
        jsr     UpdateEnabledCmds
        ldx     $a6
        lda     $2005,x     ; clear defend status
        and     #$ef
        sta     $2005,x
        lda     $357b
        cmp     $d0
.if BUGFIX_REV1 .and (!EASY_VERSION)
        bne     @a4aa
        lda     #$ff
        sta     $d0
        bra     @a4c7
.else
        beq     @a4c7       ; return if this is the other twin
.endif
@a4aa:  lda     $2033,x     ; left hand item
        cmp     #$4c
        beq     @a4b8       ; branch if avenger sword
        lda     $2035,x     ; right hand item
        cmp     #$4c
        bne     @a4bb       ; branch if not avenger sword
@a4b8:  jmp     AvengerEffect
@a4bb:  lda     $388b
        beq     @a4c3       ; branch if not auto-battle
        stz     $d7         ; menu is closed
        rts
@a4c3:  clr_a               ; battle graphics $00: open menu
        jsr     ExecBtlGfx
@a4c7:  rts

; ------------------------------------------------------------------------------

; [ set berserk status (avenger sword) ]

AvengerEffect:
@a4c8:  ldx     $a6
        lda     $2004,x
        ora     #$04
        sta     $2004,x
        lda     $d0
        tax
        stz     $3560,x
        rts

; ------------------------------------------------------------------------------

; [ get auto-battle command ]

GetAutoCmd:
@a4d9:  lda     $38e8
        bne     @a4d9
        stz     $db
        stz     $d9
        lda     $d0
        sta     $38e9
        jsr     SelectObj
        ldx     $a6
        lda     $2000,x
        and     #$1f
        cmp     #$15
        bne     @a512       ; branch if not golbez
@a4f5:  lda     $38a9       ; golbez' auto-battle script pointer
        asl
        tax
        lda     $389a,x     ; golbez' auto-battle script
        cmp     #$ff
        beq     @a50d
        sta     $a9
        lda     $389b,x     ; attack id
        sta     $aa
        inc     $38a9
        bra     @a52f
@a50d:  stz     $38a9
        bra     @a4f5
@a512:  lda     $38a8       ; auto-battle script pointer
        asl
        tax
        lda     $388c,x     ; auto-battle script
        cmp     #$ff
        beq     @a52a
        sta     $a9
        lda     $388d,x     ; attack id
        sta     $aa
        inc     $38a8
        bra     @a52f
@a52a:  stz     $38a8
        bra     @a512
@a52f:  lda     $a9
        cmp     #$c0
        bcc     @a566

; use command
        sec
        sbc     #$c0
        sta     $dc
        sta     $38ea
        lda     $a9
        cmp     #$ce
        bne     @a549       ; branch if not kick
        lda     #$ff
        sta     $da         ; target all monsters
        bra     @a560
@a549:  jsr     RandMonster
        sta     $a9
        clc
        adc     #$05
        tax
        lda     $3540,x
        bne     @a549
        lda     $a9
        tax
        clr_a
        jsr     SetBit
        sta     $da
@a560:  lda     #$80
        sta     $d8
        bra     @a589
; use magic
@a566:  cmp     #$01
        beq     @a57d
        lda     #$02
        sta     $38ea
        lda     $aa
        sta     $dc
        lda     #$20
        sta     $d8
        lda     #$ff
        sta     $da
        bra     @a589

; use item
@a57d:  lda     $aa
        sta     $dc
        lda     #$40
        sta     $d8
        lda     #$ff
        sta     $da
@a589:  inc     $38e8
        rts

; ------------------------------------------------------------------------------

; [ validate selected character ]

ValidateChar:
@a58d:  lda     $d0
        cmp     #$ff
        beq     @a5ad
        jsr     SelectObj
        ldx     $a6
        lda     $2003,x
        and     #$c0
        bne     @a5ad       ; branch if dead or stone
        lda     $2004,x
        and     #$3c
        bne     @a5ad       ; paralyze, sleep, charm, berserk
        lda     $2005,x
        and     #$c6
        beq     @a5b1       ; magnetized, stopped, twin, jump
@a5ad:  lda     #$ff
        sta     $d0
@a5b1:  rts

; ------------------------------------------------------------------------------

; [ validate selected command ]

ValidateCmd:
@a5b2:  lda     $d0
        sta     $3975
        jsr     SelectObj
        lda     $352b
        beq     @a5cb
        jsr     CopyEquip
        jsr     LoadEquipProp
        jsr     UpdateCharStats
        stz     $352b
@a5cb:  lda     $393a
        ora     $393b
        bne     @a5dd       ; branch if there is at least one target
        lda     $d0
        tax
        clr_a
        jsr     SetBit
        sta     $393b       ; target self
@a5dd:  ldx     $a6
        stz     $2052,x     ; clear spell/item being used
        lda     $3938
        sta     $2050,x
        bpl     @a62e       ; branch if using an item or magic

; command
        ldx     #$001c      ; 28 bytes each
        stx     $ab
        ldx     #$3302      ; character battle commands
        stx     $ad
        jsr     GetAttackDataPtr
        lda     $388b
        beq     @a600
        lda     $dc
        bra     @a605
@a600:  ldy     #1
        lda     ($80),y     ; $3303 (battle command id)
@a605:  sta     $397b
        pha
        cmp     #$10
        bne     @a620
        ldx     #1
        lda     $d0
        cmp     $3539
        beq     @a618
        dex
@a618:  lda     $3539,x
        sta     $357b
        bra     @a627
@a620:  cmp     #$0a
        bne     @a627       ; branch if not salve
        jsr     SalveEffect
@a627:  lda     #$0c        ; battle command delay
        sta     $d6
        pla
        bra     @a69f

; item
@a62e:  and     #$40
        beq     @a6a1       ; branch if not using an item
        clr_ax
        stx     $ab
        ldx     #$321a      ; inventory
        stx     $ad
        jsr     GetAttackDataPtr
        ldx     $a6
        lda     $2050,x
        and     #$08
        beq     @a661
        lda     #$02
        sta     $d6
        ldy     #1
        lda     ($80),y
        sta     $2052,x
        iny
        lda     ($80),y
        dec
        sta     ($80),y
        jsr     RedrawItemText
        lda     #$16
        jmp     @a6f0
@a661:  lda     $388b
        beq     @a66a
        lda     $dc
        bra     @a66f
@a66a:  ldy     #1
        lda     ($80),y
@a66f:  cmp     #$b0
        bcs     @a67c
        sta     $2052,x
        lda     #$02
        sta     $d6
        bra     @a69d
@a67c:  sta     $2052,x
        sta     $397b
        lda     #$0b
        sta     $d6
        lda     $388b
        bne     @a69d
        lda     $397b
        cmp     #$c8
        beq     @a69d
        ldy     #2
        lda     ($80),y     ; decrement item quantity
        dec
        sta     ($80),y
        jsr     RedrawItemText
@a69d:  lda     #$01
@a69f:  bra     @a6f0

; magic
@a6a1:  lda     $3938
        and     #$20
        beq     @a6d3
        lda     #$03
        sta     $d6
        ldx     #$0120
        stx     $ab
        ldx     #$2c7a      ; spell lists
        stx     $ad
        jsr     GetAttackDataPtr
        ldx     $a6
        lda     $388b
        beq     @a6c4
        lda     $dc
        bra     @a6c9
@a6c4:  ldy     #1
        lda     ($80),y
@a6c9:  sta     $397b
        sta     $2052,x
        lda     #$02
        bra     @a6f0

; item spellcast
@a6d3:  lda     #$02
        sta     $d6
        ldx     #8          ; monsters only
        stx     $ab
        ldx     #$32da      ; equipped items
        stx     $ad
        jsr     GetAttackDataPtr
        ldx     $a6
        ldy     #1
        lda     ($80),y
        sta     $2052,x
        lda     #$01
@a6f0:  ldx     $a6
        sta     $2051,x
        jsr     ValidateSelTargets
        lda     $393a       ; set targets
        sta     $2053,x
        lda     $393b
        sta     $2054,x
        lda     $d0
        jsr     CalcTimerDur
        lda     #$03        ; action timer
        jsr     SetTimer
        lda     #$08
        sta     $2a06,x     ; do command when timer expires
        rts

; ------------------------------------------------------------------------------

; [ validate selected targets ]

ValidateSelTargets:
@a714:  phx
        lda     $393b
        ora     $393a
        jsr     CountBits
        dex
        beq     @a74b       ; return if there is only one target
        clr_ay
        lda     $393b       ; character targets
        sta     $a9
        sta     $ad
        ldx     #5          ; characters only
        stx     $ab
        jsr     ClearInvalidTargets
        lda     $ad
        sta     $393b
        lda     $393a       ; monster targets
        sta     $a9
        sta     $ad
        ldx     #13         ; characters and monsters
        stx     $ab
        jsr     ClearInvalidTargets
        lda     $ad
        sta     $393a
@a74b:  plx
        rts

; ------------------------------------------------------------------------------

; [ clear invalid targets ]

;  $a9: targets to check
;  $aa: current target id
;  $ab: number of targets to check
;  $ad: validated targets

ClearInvalidTargets:
@a74d:  stz     $aa
@a74f:  asl     $a9
        bcc     @a764       ; branch if not a target
        lda     $2003,y
        and     #$c0
        beq     @a764       ; branch if dead or stone
        lda     $aa
        tax
        lda     $ad
        jsr     ClearBit
        sta     $ad
@a764:  longa
        tya
        clc
        adc     #$0080
        tay
        shorta0
        inc     $aa
        lda     $aa
        cmp     $ab
        bne     @a74f
        rts

; ------------------------------------------------------------------------------

; [ get pointer to selected command/magic/item data ]

; +$ab: array item size
; +$ad: pointer to array (ram)

GetAttackDataPtr:
@a778:  lda     $d0         ; character id
        tax
        stx     $393d
        ldx     $ab
        stx     $393f
        jsr     Mult16
        ldx     $3941
        stx     $3956
        ldx     $ad
        stx     $3958
        jsr     Add16
        lda     $3939       ; selected slot
        sta     $df
        lda     #$04        ; 4 bytes each
        sta     $e1
        jsr     Mult8
        ldx     $e3
        stx     $3956
        ldx     $395a
        stx     $3958
        jsr     Add16
        ldx     $a6
        lda     $395a
        sta     $2055,x
        sta     $80
        lda     $395b
        sta     $2056,x
        sta     $81
        rts

; ------------------------------------------------------------------------------

; [ redraw inventory item text ]

RedrawItemText:
@a7c1:  bne     @a7cc
        dey
        clr_a
        sta     ($80),y     ; remove item from inventory
        dey
        lda     #$80
        sta     ($80),y
@a7cc:  lda     $3939
        sta     $01
        lda     #$06        ; battle graphics $06: draw inventory item text
        jmp     ExecBtlGfx

; ------------------------------------------------------------------------------

; [ use potion (salve) ]

SalveEffect:
@a7d6:  clr_axy
@a7d9:  lda     $321b,x     ; item id
        cmp     #$ce
        beq     @a7eb       ; branch if potion
        iny
        inx4
        cpx     #$00c0
        bne     @a7d9
        rts
@a7eb:  lda     $321c,x
        cmp     #$01
        bcc     @a81a       ; return if quantity is zero
        sec
        lda     $321c,x
        pha
        phx
        sbc     #$01
        sta     $321c,x
        bne     @a80d
        stz     $321c,x     ; quantity reached zero
        stz     $321b,x
        lda     $321a,x
        ora     #$80
        sta     $321a,x
@a80d:  tya
        sta     $01
        lda     #$06        ; battle graphics $06: draw inventory item text
        jsr     ExecBtlGfx
        plx
        pla
        sta     $321c,x
@a81a:  rts

; ------------------------------------------------------------------------------

; [ validate equipped arrows ]

; if character ran out of arrows, remove them

ValidateArrows:
@a81b:  lda     $1822
        tay
        lda     $38dc,y
        beq     @a855       ; branch if didn't run out of arrows
        lda     $1822
        sta     $3975
        jsr     Asl_3
        tax
        lda     $38dc,y
        bpl     @a837       ; branch if arrows were not in right hand
        inx4
@a837:  clr_a
        sta     $38dc,y     ; clear arrow update flag
        stz     $32db,x     ; remove arrows from character
        stz     $32dc,x
        lda     #$80
        sta     $32da,x     ; equipped item flags
        lda     $3975
        jsr     SelectObj
        jsr     CopyEquip
        jsr     LoadEquipProp
        jsr     UpdateCharStats
@a855:  rts

; ------------------------------------------------------------------------------
