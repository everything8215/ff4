
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: player.asm                                                           |
; |                                                                            |
; | description: player graphics routines                                      |
; |                                                                            |
; | created: 3/27/2022                                                         |
; +----------------------------------------------------------------------------+

.export MapSpritePal

; ------------------------------------------------------------------------------

.pushseg

.segment "map_sprite_gfx"
        .include .sprintf("gfx/map_sprite_gfx_%s.asm", LANG_SUFFIX)

.segment "map_sprite_pal"
        .include "gfx/map_sprite_pal.asm"

.popseg

; ------------------------------------------------------------------------------

; [ load player sprite palettes ]

LoadPlayerPal:
@c827:  ldy     #0
        ldx     #0
@c82d:  lda     f:MapSpritePal,x
        sta     $0ddb,y
        inx
        iny
        tya
        and     #$0f
        bne     @c82d
@c83b:  lda     #0
        sta     $0ddb,y
        iny
        tya
        and     #$0f
        bne     @c83b
        cpy     #$0080
        bne     @c82d
        rtl

; ------------------------------------------------------------------------------

; [ update showing character ]

UpdateTopChar:
@c84c:  lda     $1704
        bne     @c85b       ; return if in a vehicle
        lda     $02
        and     #JOY_R
        beq     @c85b       ; branch if top r button is not pressed
        lda     $53
        beq     @c85c
@c85b:  rtl
@c85c:  inc     $53         ; reset top r button
; fallthrough

; ------------------------------------------------------------------------------

; [ validate showing character ]

ValidateTopChar:
@c85e:  inc     $1703
        lda     $1703
        cmp     #5
        bne     @c86d
        lda     #$00
        sta     $1703
@c86d:  jsl     GetTopCharPtr
        lda     $1000,x
        beq     @c85e
        lda     #1
        sta     $cc
        rtl

; ------------------------------------------------------------------------------

; [ get showing character properties pointer ]

GetTopCharPtr:
@c87b:  lda     $1703
        stz     $4a
        lsr
        ror     $4a
        lsr
        ror     $4a
        sta     $4b
        ldx     $4a
        rtl

; ------------------------------------------------------------------------------

; [ load player sprite graphics ]

LoadPlayerGfx:
@c88b:  lda     $cc
        bne     @c890
        rtl
@c890:  stz     $cc
        jsl     GetTopCharPtr
        lda     $1003,x
        and     #$20
        beq     @c8a2
        lda     #$0f
        jmp     @c8bf
@c8a2:  lda     $1003,x
        and     #$10
        beq     @c8ae
        lda     #$0e
        jmp     @c8bf
@c8ae:  lda     $1003,x
        and     #$08
        beq     @c8ba
        lda     #$10
        jmp     @c8bf
@c8ba:  lda     $1001,x
        and     #$1f
@c8bf:  sta     $06
        asl
        clc
        adc     $06
        clc
        adc     #$80
        sta     $4b
        stz     $4a
        ldx     #$4000
        stx     $4c
        ldx     #$0200
        stx     $4e
        lda     #.bankbyte(MapSpriteGfx)
        sta     $49
        jsl     Tfr3bppGfx
        rtl

; ------------------------------------------------------------------------------
