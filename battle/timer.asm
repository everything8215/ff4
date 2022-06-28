
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: timer.asm                                                            |
; |                                                                            |
; | description: timer effect routines                                         |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

; [ action type 3: do timer effect ]

DoTimerEffect:
@a856:  jsr     InitGfxScript
        lda     $d2                     ; attacker id
        jsr     SelectObj
        lda     $d3                     ; timer id
        sta     $ab                     ; multiply by 3
        asl
        clc
        adc     $ab
        jsr     GetTimerPtr
        ldx     $3598
        stx     $3555                   ; set pointer to expired timer
        lda     $d3
        asl
        tax
        lda     f:TimerEffectTbl,x
        sta     $80
        lda     f:TimerEffectTbl+1,x
        sta     $81
        lda     #^TimerEffectTbl
        sta     $82
        jml     [$0080]
        rts

; ------------------------------------------------------------------------------

; [ timer effect 0: stop timer ]

TimerEffect_00:
@a887:  ldx     $a6
        lda     $2005,x     ; clear stop status
        and     #$bf
        sta     $2005,x
        ldx     $3530
        stz     $2a06,x     ; clear stop timer flags
        lda     #$03
        jsr     GetTimerPtr
        ldx     $3598
        lda     $2a06,x
        bpl     @a8af       ; branch if action timer is not expired
        stz     $2a06,x
        lda     #$01
        sta     $2a04,x     ; set action timer duration to 1
        stz     $2a05,x
@a8af:  lda     $d2         ; current character/monster id
        asl
        tax
        lda     $29eb,x     ; disable stop timer
        and     #$7f
        sta     $29eb,x
        rts

; ------------------------------------------------------------------------------

; [ timer effect 1: action timer (sleep/paralyze wore off) ]

TimerEffect_01:
@a8bc:  ldx     $a6
        lda     $2004,x     ; clear paralyze and sleep status
        and     #$cf
        sta     $2004,x
        stz     $d6
        lda     $d2
        jsr     CalcTimerDur
        lda     #$03        ; action timer
        jsr     SetTimer
        stz     $2a06,x     ; start timer
        rts

; ------------------------------------------------------------------------------

; [ timer effect 2: sap timer ]

TimerEffect_02:
@a8d6:  ldx     $a6
        lda     $2006,x     ; remove sap status
        and     #$bf
        sta     $2006,x
        lda     $d2
        asl
        tax
        lda     $29eb,x     ; disable sap timer
        and     #$df
        sta     $29eb,x
        rts

; ------------------------------------------------------------------------------

; [ timer effect 3: poison timer ]

TimerEffect_03:
@a8ed:  ldx     $a6
        lda     $2005,x
        and     #$02
        bne     @a967       ; return if jumping
        lda     $2006,x
        bmi     @a967       ; return if hiding
        lda     $d2
        asl
        tax
        lda     $2b2a,x
        sta     $a9
        lda     $2b2b,x
        sta     $aa
        ldx     $3555
        lda     $a9
        sta     $2a04,x
        lda     $aa
        sta     $2a05,x
        lda     #$40
        sta     $2a06,x
        longa
        ldx     $a6
        lda     $2009,x
        jsr     Lsr_3
        sta     $a9
        lda     $a9
        bne     @a92d
        inc     $a9
@a92d:  shorta0
        lda     $d2
        asl
        tax
        lda     $a9
        sta     $34d4,x
        lda     $aa
        sta     $34d5,x
        jsr     ApplyDmg
        lda     #$f8        ; display text
        sta     $33c2
        lda     #$03        ; battle message
        sta     $33c3
        lda     #$35
        sta     $34ca
        lda     #$05        ; battle graphics $05: graphics script
        jsr     ExecBtlGfx
        jsr     UpdateDead
        lda     #$11        ; battle graphics $11: display damage numerals
        jsr     ExecBtlGfx
        lda     #$0c        ; battle graphics $0c: draw hp text
        jsr     ExecBtlGfx
        lda     #$10        ; battle graphics $10:
        jsr     ExecBtlGfx
@a967:  rts

; ------------------------------------------------------------------------------

; [ timer effect 4: petrify timer ]

TimerEffect_04:
@a968:  ldx     $a6
        lda     $2005,x
        and     #$02
        bne     @a9c7
        lda     $2006,x
        bmi     @a9c7
        lda     $2004,x
        and     #$03
        inc
        sta     $a9
        cmp     #$04
        bne     @a99f
        lda     $2004,x
        and     #$fc
        sta     $2004,x
        lda     $2003,x
        ora     #$40
        sta     $2003,x
        lda     $d2
        asl
        tax
        lda     $29eb       ; disable petrify timer
        and     #$f7
        sta     $29eb
        rts
@a99f:  lda     $2004,x
        ora     $a9
        sta     $2004,x
        lda     $d2
        asl
        tax
        lda     $2b44,x
        sta     $a9
        lda     $2b45,x
        sta     $aa
        ldx     $3555
        lda     $a9
        sta     $2a04,x
        lda     $aa
        sta     $2a05,x
        lda     #$40
        sta     $2a06,x
@a9c7:  rts

; ------------------------------------------------------------------------------

; [ timer effect 5: reflect timer ]

TimerEffect_05:
@a9c8:  ldx     $a6
        lda     $2006,x
        and     #$df
        sta     $2006,x
        lda     $d2
        asl
        tax
        lda     $29eb,x     ; disable reflect timer
        and     #$fb
        sta     $29eb,x
        rts

; ------------------------------------------------------------------------------

; [ timer effect 6: doom timer ]

TimerEffect_06:
@a9df:  ldx     $a6
        lda     $2005,x
        and     #$02
        bne     @a9fe
        lda     $2006,x
        bmi     @a9fe
        ldx     $a6
        lda     $2003,x
        ora     #$80
        sta     $2003,x
        lda     $d2
        asl
        tax
        stz     $29eb,x     ; disable all timers
@a9fe:  rts

; ------------------------------------------------------------------------------

; [ do sap and regen ]

SapRegenEffect:
@a9ff:  inc     $3557
        lda     $3557
        cmp     #$01
        bne     @aa85
        stz     $3557
        jsr     InitGfxScript
        lda     #$00
        sta     $8a

; start of character/monster loop
@aa13:  lda     $8a
        tax
        lda     $3540,x
        bne     @aa4c       ; branch if not present
        lda     $8a
        asl
        tax
        lda     $29eb,x
        and     #$20
        beq     @aa4c       ; branch if sap timer is disabled
        lda     $8a
        jsr     SelectObj
        ldx     $a6
        lda     $2003,x
        and     #$c0
        bne     @aa4c       ; branch if dead or stone
        lda     $2005,x
        and     #$42
        bne     @aa4c       ; branch if stopped or jumping
        lda     $2006,x
        bmi     @aa4c       ; branch if hiding
        lda     $8a
        asl
        tax
        lda     #$02
        sta     $34d4,x     ; 2 damage
        stz     $34d5,x
@aa4c:  inc     $8a         ; next character/monster
        lda     $8a
        cmp     #$0d
        bne     @aa13
        stz     $3907
        jsr     ApplyDmg
        lda     #$ff
        sta     $33c2
        lda     $3907
        beq     @aa85       ; branch if character/monster didn't die
        lda     #$f8        ; display text
        sta     $33c2
        lda     #$03        ; battle message
        sta     $33c3
        lda     #$38        ; じょじょに　たいりょくをうばわれ　ちからつきた (hp ran out)
        sta     $34ca
        lda     #$05        ; battle graphics $05: graphics script
        jsr     ExecBtlGfx
        jsr     UpdateDead
        lda     #$10        ; battle graphics $10:
        jsr     ExecBtlGfx
        lda     #$02        ; battle graphics $02: wait one frame
        jsr     ExecBtlGfx
@aa85:  jsr     InitGfxScript
        jsl     CheckRegen
        lda     $357c
        cmp     #$ff
        beq     @aad8       ; branch if regen is disabled
        inc     $357c       ; increment regen counter
        cmp     #$05
        bne     @aad8       ; do hp gain every 5 turns
        stz     $357c
        jsr     InitGfxScript
        clr_ax
        txy
@aaa3:  lda     $3540
        bne     @aac1
        lda     $2003,x
        and     #$c0
        bne     @aac1
        phx
        phy
        tya
        asl
        tax
        lda     $357d       ; regen hp amount
        sta     $34d4,x
        lda     #$80
        sta     $34d5,x
        ply
        plx
@aac1:  longa
        txa
        clc
        adc     #$0080
        tax
        shorta0
        iny
        cpy     #5
        bne     @aaa3
        jsr     ApplyDmg
        jsr     UpdateDead
@aad8:  lda     #$11        ; battle graphics $11: display damage numerals
        jsr     ExecBtlGfx
        lda     #$0c        ; battle graphics $0c: draw hp text
        jmp     ExecBtlGfx

; ------------------------------------------------------------------------------

; [ do forced character actions ]

ForceCharActions:
@aae2:  clr_ax
        stx     $8e

; start of character loop
@aae6:  ldx     $8e
        lda     $3540,x
        bne     @aaf2       ; branch if not present
        lda     $3560,x
        beq     @aaf5
@aaf2:  jmp     @ab91
@aaf5:  txa
        jsr     SelectObj
        ldx     $a6
        lda     $2003,x
        and     #$c0
        bne     @ab07       ; branch if dead or stone
        lda     $2004,x
        and     #$30
@ab07:  bne     @ab10       ; branch if paralyzed or asleep
        lda     $2005,x
.if BUGFIX_REV1
        and     #$42        ; check stop and jump
.else
        and     #$40        ; check stop only
.endif
        beq     @ab13       ; branch if not stopped
@ab10:  jmp     @ab91
@ab13:  lda     $2004,x
        and     #$0c
        beq     @ab3a       ; branch if not charmed or berserk
        lda     $2005,x     ; clear twin status
        and     #$fb
        sta     $2005,x
        lda     $2004,x
        and     #$04
        beq     @ab2e       ; branch if not berserk
        jsr     GetBerserkAttack
        bra     @ab7b
@ab2e:  lda     $2004,x
        and     #$08
        beq     @ab3a       ; branch if not charmed
        jsr     GetCharmAttack
        bra     @ab7b
@ab3a:  lda     $2006,x
        and     #$01
        beq     @ab91       ; branch if not critical
        lda     $2000,x
        and     #$1f
        cmp     #$05
        bne     @ab91       ; branch if not edward
        lda     $3582
        bne     @ab91       ; branch if a boss battle
        lda     #$03
        jsr     GetTimerPtr
        ldx     $3598
        lda     $2a06,x
        and     #$08
        bne     @ab91       ; branch if command is already pending
        ldx     $a6
        lda     $2006,x
        bpl     @ab70       ; branch if not hiding
        jsr     CountCharTargets
        dec
        bne     @ab91       ; branch if not alone
        jsr     ForceAppear
        bra     @ab82
@ab70:  jsr     CountCharTargets
        dec
        beq     @ab91       ; branch if alone
        jsr     ForceHide
        bra     @ab82
@ab7b:  stz     $d6
        lda     $8e
        jsr     CalcTimerDur
@ab82:  lda     #$03        ; action timer
        jsr     SetTimer
        lda     #$08
        sta     $2a06,x     ; do command when timer expires
        ldx     $8e
        inc     $3560,x
@ab91:  inc     $8e         ; next character
        lda     $8e
        cmp     #5
        beq     @ab9c
        jmp     @aae6
@ab9c:  rts

; ------------------------------------------------------------------------------

; [ choose charmed attack ]

GetCharmAttack:
@ab9d:  ldx     $a6
        stz     $2053,x
        stz     $2054,x
        jsr     Rand99
        cmp     #70
        bcs     @abd0       ; 70% chance

; 30% chance to use a random spell
        ldx     $3534       ; pointer to battle commands
        ldy     #5
@abb2:  lda     $3303,x
        cmp     #$02
        beq     @abc6       ; branch if white magic
        cmp     #$03
        beq     @abc6       ; branch if black magic
        inx4
        dey
        bne     @abb2
        bra     @abd0
@abc6:  stz     $90
        jsr     GetCharmMagic
        lda     $90
        bne     @abd0
        rts

; 70% chance to attack a random character
@abd0:  ldx     $a6
        lda     #$80
        sta     $2050,x
        stz     $2051,x     ; use fight command
@abda:  jsr     RandChar
        tax
        lda     $3540,x
        bne     @abda       ; branch if not present
        clr_a
        jsr     SetBit
        ldx     $a6
        sta     $2054,x
        rts

; ------------------------------------------------------------------------------

; [ choose charmed spell ]

GetCharmMagic:
@abed:  ldx     $3536       ; pointer to spell list
        stx     $a9
        ldy     #$0030
@abf5:  lda     $2c7a,x
        bpl     @ac06       ; branch if at least one spell is enabled
        inx4
        dey
        bne     @abf5
        inc     $90
        jmp     @ac8b
@ac06:  clr_ax
        lda     #$2f
        jsr     RandXA
        tax
        stx     $393d       ; multiply by 4
        ldx     #4
        stx     $393f
        jsr     Mult16
        clc
        lda     $a9
        adc     $3941
        sta     $ab
        lda     $aa
        adc     $3942
        sta     $ac
        ldx     $ab
        lda     $2c7a,x
        sta     $ad
        bmi     @ac06       ; branch if spell is disabled
        lda     $2c7b,x     ; spell id
        ldx     $a6
        sta     $2052,x
        lda     #$20
        sta     $2050,x
        lda     #$02        ; battle command
        sta     $2051,x
        lda     $ad
        and     #$40
        bne     @ac6f       ; branch if targets enemy by default
        lda     $ad
        and     #$10
        beq     @ac67       ; branch if target all by default
@ac50:  jsr     RandMonster
        sta     $ab
        clc
        adc     #$05
        tax
        lda     $3540,x
        bne     @ac50       ; branch if target is not present
        lda     $ab
        tax
        clr_a
        jsr     SetBit
        bra     @ac69
@ac67:  lda     #$ff
@ac69:  ldx     $a6
        sta     $2053,x     ; set targetted monsters
        rts
@ac6f:  lda     $ad
        and     #$10
        beq     @ac84       ; branch if target all by default
@ac75:  jsr     RandChar
        tax
        lda     $3540,x     ; branch if target is not present
        bne     @ac75
        clr_a
        jsr     SetBit
        bra     @ac86
@ac84:  lda     #$f8
@ac86:  ldx     $a6
        sta     $2054,x
@ac8b:  rts

; ------------------------------------------------------------------------------

; [ choose berserk attack ]

GetBerserkAttack:
@ac8c:  ldx     $a6
        lda     #$80
        sta     $2050,x
        stz     $2051,x
        stz     $2054,x
        stz     $2053,x
        lda     $2004,x
        and     #$08
        beq     @acde
@aca3:  ldx     #0
        lda     #4
        jsr     RandXA
        sta     $a9
        sta     $df
        tax
        lda     $3540,x
        bne     @aca3
        lda     #$80
        sta     $ab
        jsr     Mult8
        ldx     $e3
        lda     $2003,x
        and     #$c0
        bne     @aca3
        lda     $2005,x
        and     #$82
        bne     @aca3
        lda     $2006,x
        bmi     @aca3
        lda     $a9
        tax
        clr_a
        jsr     SetBit
        ldx     $a6
        sta     $2054,x
        rts
@acde:  jsr     RandMonster
        sta     $a9
        clc
        adc     #$05
        tax
        lda     $3540,x
        bne     @acde
        lda     $a9
        tax
        clr_a
        jsr     SetBit
        ldx     $a6
        sta     $2053,x
        rts

; ------------------------------------------------------------------------------

; [ force edward to hide/appear ]

ForceHide:
@acf9:  ldx     $a6
        lda     #$09        ; use hide command
        sta     $2051,x
        bra     _ad09

ForceAppear:
@ad02:  ldx     $a6
        lda     #$1c        ; use appear command
        sta     $2051,x
_ad09:  lda     #$80
        sta     $2050,x
        stz     $2053,x     ; no monster targets
        lda     $8e
        tax
        clr_a
        jsr     SetBit
        ldx     $a6
        sta     $2054,x     ; character target
        ldx     #1
        stx     $d4         ; timer duration: 1
        rts

; ------------------------------------------------------------------------------

; [ count character targets ]

CountCharTargets:
@ad23:  phx
        phy
        clr_ax
        txy
        stx     $a9
@ad2a:  lda     $3540,y
        bne     @ad38       ; branch if not present
        lda     $2003,x
        and     #$c0
        bne     @ad38       ; branch if dead or stone
        inc     $a9         ; increment number of character targets
@ad38:  jsr     NextObj
        iny
        cpy     #5
        bne     @ad2a
        ply
        plx
        lda     $a9
        sta     $38db       ; number of character targets
        rts

; ------------------------------------------------------------------------------

; expired timer jump table
TimerEffectTbl:
@ad49:  .addr   TimerEffect_00
        .addr   TimerEffect_01
        .addr   TimerEffect_02
        .addr   TimerEffect_03
        .addr   TimerEffect_04
        .addr   TimerEffect_05
        .addr   TimerEffect_06

; ------------------------------------------------------------------------------
