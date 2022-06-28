
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: bg_anim.asm                                                          |
; |                                                                            |
; | description: background animation routines                                 |
; |                                                                            |
; | created: 3/27/2022                                                         |
; +----------------------------------------------------------------------------+

; [ load bg animation graphics ]

LoadBGAnimGfx:
@cb01:  lda     $0fdd
        tax
        lda     f:BGAnimTbl,x
        sta     $3e
        stz     $3d
        lsr     $3e
        ror     $3d
        lda     $3e
        clc
        adc     f:BGAnimTbl,x
        sta     $3e
        ldx     $3d
        ldy     #0
        lda     #$7f
        pha
        plb
@cb23:  lda     f:MapAnimGfx,x
        sta     $5000,y
        inx
        iny
        tya
        and     #$0f
        bne     @cb23
@cb31:  lda     f:MapAnimGfx,x
        sta     $5000,y
        inx
        iny
        lda     #$00
        sta     $5000,y
        iny
        tya
        and     #$0f
        bne     @cb31
        cpy     #$0800
        bne     @cb23
        lda     #0
        pha
        plb
        rtl

; ------------------------------------------------------------------------------

; bg animation graphics for each map tileset
BGAnimTbl:
@cb4f:  .byte   $00,$00,$00,$02,$03,$06,$07,$0a,$0a,$0a,$0a,$0a,$0d,$0d,$0d,$10

; ------------------------------------------------------------------------------

; [ transfer bg animation graphics to vram ]

TfrBGAnimGfx:
@cb5f:  lda     $1700
        cmp     #3
        bne     @cb6c
        lda     $7a
        and     #$06
        beq     @cb6d
@cb6c:  rtl
@cb6d:  lda     $7a
        and     #$18
        sta     $12
        stz     $13
        longa
        asl     $12
        asl     $12
        asl     $12
        asl     $12
        lda     $12
        clc
        adc     #$5000
        sta     $12
        lda     #0
        shorta
        lda     #$80
        sta     $2115
        stz     $420b
        lda     #$01
        sta     $4300
        lda     #$18
        sta     $4301
        ldx     #$1200
        stx     $2116
        lda     #$7f
        sta     $4304
        ldx     #$1200
        stx     $2116
        ldy     #4
@cbb2:  ldx     $12
        stx     $4302
        ldx     #$0080
        stx     $4305
        lda     #$01
        sta     $420b
        lda     $13
        clc
        adc     #$02
        sta     $13
        dey
        bne     @cbb2
        rtl

; ------------------------------------------------------------------------------
