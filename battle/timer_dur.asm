
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: timer_dur.asm                                                        |
; |                                                                            |
; | description: calculate timer durations                                     |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

; [ calculate timer duration ]

CalcTimerDur:
@9e2c:  stz     $3558
        cmp     #$05
        bcc     @9e36
        inc     $3558
@9e36:  jsr     SelectObj
        ldx     $a6
        lda     $2060,x     ; base timer duration
        sta     $a9
        lda     $2061,x
        sta     $aa
        lda     $203b,x     ; speed modifier
        tay
        sty     $3979
        phx
        lda     $d6         ; timer duration function
        asl
        tax
        lda     f:TimerDurTbl,x
        sta     $80
        lda     f:TimerDurTbl+1,x
        sta     $81
        lda     #$03
        sta     $82
        plx
        jml     [$0080]

; ------------------------------------------------------------------------------

; [ timer duration $00: action ]

TimerDur_00:
@9e65:  jsr     ApplySpeedMod
        ldy     $ab
        bne     @9e6e
        inc     $ab         ; min 1
@9e6e:  jmp     SetTimerDur

; ------------------------------------------------------------------------------

; [ timer duration $01/$02: immediate ]

TimerDur_01:
TimerDur_02:
@9e71:  lda     $3558
        bne     @9e7a
        clr_ax
        bra     @9e7d
@9e7a:  ldx     #1
@9e7d:  stx     $a9
        jsr     ApplySpeedMod
        jmp     SetTimerDur

; ------------------------------------------------------------------------------

; [ timer duration $0b: item ]

TimerDur_0b:
@9e85:  lda     $397b
        sta     $df
        lda     #$06
        sta     $e1
        jsr     Mult8
        ldx     $e3
        lda     f:ItemProp,x   ; item action delay (all are zero in vanilla)
        bra     _9eab

; ------------------------------------------------------------------------------

; [ timer duration $03: magic ]

TimerDur_03:
@9e99:  lda     $397b
        sta     $df
        lda     #$06
        sta     $e1
        jsr     Mult8
        ldx     $e3
        lda     f:AttackProp,x   ; magic action delay
_9eab:  and     #$1f
        tax
        stx     $a9
        asl     $a9         ; multiply by 2
        rol     $aa
        lda     $388b
        beq     @9ebd       ; branch if not auto-battle
        clr_ax
        stx     $a9
@9ebd:  jsr     ApplySpeedMod
        jmp     SetTimerDur

; ------------------------------------------------------------------------------

; [ timer duration $04/$05: sleep/paralyze ]

TimerDur_04:
TimerDur_05:
@9ec3:  lda     $3558
        beq     @9ecd       ; branch if a character
        lda     $202f,x     ; monster level + 10
        bra     @9ed0
@9ecd:  lda     $2018,x     ; mod. spirit
@9ed0:  sta     $ad
        asl     $ad
        asl     $ad
        sec
        lda     #$2c        ; 300 - 4 * (mod. spirit)
        sbc     $ad
        sta     $a9
        lda     #$01
        sbc     #$00
        sta     $aa
        bcs     @9eea
        ldx     #1          ; min 1
        stx     $a9
@9eea:  jsr     ApplySpeedMod
        ldx     $ab
        stx     $3945
        ldx     #6          ; divide by 6
        stx     $3947
        jsr     Div16
        ldx     $3949
        stx     $ab
        jmp     SetTimerDur

; ------------------------------------------------------------------------------

; [ timer duration $06/$07: poison/petrify ]

TimerDur_06:
TimerDur_07:
@9f03:  lda     $3558
        beq     @9f0d
        lda     $202f,x
        bra     @9f10
@9f0d:  lda     $2016,x
@9f10:  clc
        adc     #$14
        tax
        stx     $a9
        jsr     ApplySpeedMod
        jmp     SetTimerDur

; ------------------------------------------------------------------------------

; [ timer duration $08: reflect ]

TimerDur_08:
@9f1c:  lda     $397b
        sta     $ad
        stz     $ae
        asl     $ad
        rol     $ae
        clc
        lda     $ad
        adc     #$1e
        sta     $a9
        lda     $ae
        adc     #$00
        sta     $aa
        jsr     ApplySpeedMod
        jmp     SetTimerDur

; ------------------------------------------------------------------------------

; [ timer duration $09: sap ]

TimerDur_09:
@9f3a:  lda     $3558
        beq     @9f4a
        lda     $202f,x
        sta     $ad
        lda     #$04
        sta     $ae
        bra     @9f57
@9f4a:  clc
        lda     $2017,x
        adc     $2018,x
        sta     $ad
        lda     #$02
        sta     $ae
@9f57:  lda     $ad
        sta     $df
        lda     $ae
        sta     $e2
        jsr     Mult8
        clc
        lda     $e3
        adc     #$1e
        sta     $a9
        lda     $e4
        adc     #$00
        sta     $aa
        jsr     ApplySpeedMod
        jmp     SetTimerDur

; ------------------------------------------------------------------------------

; [ timer duration $0a: stop ]

TimerDur_0a:
@9f75:  lda     $397b
        sta     $df
        lda     #$03
        sta     $e1
        jsr     Mult8
        ldx     $e3
        stx     $a9
        jsr     ApplySpeedMod
        jmp     SetTimerDur

; ------------------------------------------------------------------------------

; [ timer duration $0c: action delay ]

TimerDur_0c:
@9f8b:  lda     $397b       ; battle command id
        cmp     #$06
        bne     @9f97       ; branch if not jump 1
        ldx     #4
        bra     @9fca
@9f97:  tax
        lda     f:CmdDelayTbl,x   ; action delay for each command
        bne     @9fa1
        jmp     TimerDur_01
@9fa1:  bpl     @9fb8

; msb set: delay is multiple of a turn
        and     #$7f
        tax
        stx     $393f
        ldx     $a9
        stx     $393d
        jsr     Mult16
        ldx     $3941
        stx     $a9
        bra     @9fcc

; msb clear: delay is fraction of a turn
@9fb8:  tax
        stx     $3947
        ldx     $a9
        stx     $3945
        jsr     Div16
        ldx     $3949
        bne     @9fca
        inx
@9fca:  stx     $a9
@9fcc:  jsr     ApplySpeedMod
; fallthrough

; ------------------------------------------------------------------------------

; [ set timer duration ]

SetTimerDur:
@9fcf:  ldy     $ab
        bpl     @9fd5       ; min zero
        clr_ay
@9fd5:  sty     $d4
        rts

; ------------------------------------------------------------------------------

; [ apply speed multiplier ]

ApplySpeedMod:
@9fd8:  ldx     $a9         ; base duration
        stx     $393d
        ldx     $3979       ; multiplier
        stx     $393f
        jsr     Mult16
        ldx     $3941
        stx     $3945
        ldx     #$0010
        stx     $3947
        jsr     Div16
        ldx     $3949
        stx     $ab         ; mod. duration
        rts

; ------------------------------------------------------------------------------

; timer duration jump table
TimerDurTbl:
@9ffb:  .addr   TimerDur_00
        .addr   TimerDur_01
        .addr   TimerDur_02
        .addr   TimerDur_03
        .addr   TimerDur_04
        .addr   TimerDur_05
        .addr   TimerDur_06
        .addr   TimerDur_07
        .addr   TimerDur_08
        .addr   TimerDur_09
        .addr   TimerDur_0a
        .addr   TimerDur_0b
        .addr   TimerDur_0c

; ------------------------------------------------------------------------------
