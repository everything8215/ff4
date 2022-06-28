
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: sort.asm                                                             |
; |                                                                            |
; | description: sort items in inventory or fat chocobo                        |
; |                                                                            |
; | created: 4/19/2022                                                         |
; +----------------------------------------------------------------------------+

; [ sort items ]

; +x: $1340 or $1440 (fat chocobo items or inventory)

SortItems:
@ae2a:  stx     $1d
        stx     $1f
        longa
        txa
        cmp     #$1340
        bne     @ae3c
        clc
        adc     #$00fa                  ; fat chocobo holds 126 items
        bra     @ae40
@ae3c:  clc
        adc     #$005e                  ; inventory holds 48 items
@ae40:  sta     $21
        inc2
        sta     $25
        shorta
        inx
@ae49:  ldy     #2
        ldx     $1f
        inx
        stx     $23
@ae51:  lda     ($1f)
        beq     @ae6c
        cmp     ($1f),y
        bne     @ae6c
        iny
        lda     ($1f),y
        clc
        adc     ($23)
        cmp     #100
        bcs     @ae6d
        sta     ($23)
        lda     #0
        sta     ($1f),y
        dey
        sta     ($1f),y
@ae6c:  iny
@ae6d:  iny
        longa
        tya
        clc
        adc     $1f
        cmp     $25
        shorta
        bne     @ae51
        longa
        inc     $1f
        inc     $1f
        shorta
        ldx     $1f
        cpx     $21
        bne     @ae49
        ldx     $1d
        phx
        jsr     @ae91
        plx
        stx     $1d
@ae91:  ldx     $1d
        inx
        stx     $23
        lda     ($1d)
        bne     @aebe
        ldy     $1d
        iny2
@ae9e:  lda     a:$0000,y
        beq     @aeb8
        cmp     #$fe
        bcs     @aeb8       ; branch if -sort- or trash can
        sta     ($1d)
        lda     a:$0001,y
        sta     ($23)
        lda     #0
        sta     a:$0000,y
        sta     a:$0001,y
        bra     @aebe
@aeb8:  iny2
        cpy     $25
        bne     @ae9e
@aebe:  ldx     $1d
        inx2
        stx     $1d
        cpx     $21
        bne     @ae91
        rts

; ------------------------------------------------------------------------------
