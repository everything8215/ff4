
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: pal_anim.asm                                                         |
; |                                                                            |
; | description: palette animation routines                                    |
; |                                                                            |
; | created: 3/27/2022                                                         |
; +----------------------------------------------------------------------------+

; [ update big whale palette animation ]

UpdateWhalePal:
@c3bd:  lda     $1704
        cmp     #$06
        bne     @c3d9       ; return if not in big whale
        lda     $7a
        lsr2
        and     #$0e
        tax
        lda     f:WhalePal,x
        sta     $0ec7
        lda     f:WhalePal+1,x
        sta     $0ec8
@c3d9:  rtl

; ------------------------------------------------------------------------------

; big whale palette animation colors
WhalePal:
@c3da:  .word   $021f,$0198,$0110,$0088,$0088,$0110,$0198,$021f

; ------------------------------------------------------------------------------

; [ update tower of bab-il palette animation ]

UpdateBabilPal:
@c3ea:  lda     $1700
        cmp     #$02
        bcs     @c419       ; return if not overworld or underground
; overworld
        cmp     #$00
        bne     @c3fb
        ldx     #$001e      ; bg palette 0
        jmp     @c3fe
; underground
@c3fb:  ldx     #$007e      ; bg palette 3
@c3fe:  lda     $1288
        and     #$04
        beq     @c413       ; branch if not flashing
        lda     $7a
        asl
        sta     $0cdb,x
        eor     #$ff
        sta     $0cdc,x
        jmp     @c419
@c413:  stz     $0cdb,x
        stz     $0cdc,x
@c419:  rtl

; ------------------------------------------------------------------------------

; [ update sub-map palette animation ]

UpdateAnimPal:
@c41a:  lda     $0fdd
        cmp     #$09                    ; underground cave
        beq     @c493
        cmp     #$08
        beq     @c42d
        cmp     #$0a
        bcc     @c492
        cmp     #$0c
        bcs     @c492
; big whale, tower of zot/babil, giant of babil
@c42d:  lda     $7a
        lsr2
        and     #$0e
        tax
        longa
        lda     f:TowerAnimBlueLight,x
        sta     $0cfd
        lda     f:TowerAnimRedLight,x
        sta     $0d1d
        lda     f:TowerAnimYellowLight,x
        sta     $0d5d
        lda     #0
        shorta
        lda     $0fdd
        cmp     #$0b
        beq     @c477                   ; branch if giant of babil
        lda     $7a
        lsr3
        and     #$0f
        cmp     #$08
        bcc     @c467
        eor     #$ff
        clc
        adc     #$09
@c467:  asl
        tax
        ldy     #0
@c46c:  lda     f:TowerNoEffectTbl,x     ; this has no effect ???
        inx
        iny
        cpy     #16
        bne     @c46c
@c477:  lda     $7a
        lsr
        and     #$1e
        tax
        ldy     #0
@c480:  lda     f:TowerAnimBluePal,x
        sta     $0dbd,y
        inx
        txa
        and     #$1f
        tax
        iny
        cpy     #16
        bne     @c480
@c492:  rtl
; underground cave
@c493:  lda     $7a
        lsr2
        and     #$0e
        tax
        lda     $0fe0
        cmp     #$0f                    ; branch if cave of monsters
        bne     @c4a6
        txa
        clc
        adc     #$40                    ; add $40 for sylvan cave
        tax
@c4a6:  longa
        lda     f:MonsterCaveAnimPal,x
        sta     $0cfd
        lda     f:MonsterCaveAnimPal+16,x
        sta     $0cff
        sta     $0d7f
        lda     f:MonsterCaveAnimPal+32,x
        sta     $0d01
        lda     f:MonsterCaveAnimPal+48,x
        sta     $0d7d
        lda     #0
        shorta
        rtl

; ------------------------------------------------------------------------------

; [ update lava palette ]

UpdateLavaPal:
@c4cd:  lda     $1700
        cmp     #1
        bne     @c4fc                   ; underground only
        lda     $7a
        and     #$70
        lsr4
        tax
        lda     f:LavaPalTbl,x
        tax
        ldy     #0
        longa
@c4e7:  lda     f:LavaAnimPal,x
        sta     $0cff,y
        inx2
        iny2
        cpy     #16
        bne     @c4e7
        lda     #0
        shorta
@c4fc:  rtl

; ------------------------------------------------------------------------------

LavaPalTbl:
@c4fd:  .byte   $00,$10,$20,$30,$30,$20,$10,$00

; ------------------------------------------------------------------------------

; [ update world map zoomed bg palettes ]

; this is what causes the ocean to be a solid color when in an airship

; a: zoom level

UpdateZoomPal:
@c505:  and     #$fe
        tax
        lda     $1700
        bne     @c523
; overworld
        longa
        lda     f:ZoomPalTbl+18*15,x
        sta     $0d25       ; bg palette 2, color 5 (light ocean)
        lda     f:ZoomPalTbl+18*16,x
        sta     $0d29       ; bg palette 2, color 7 (dark ocean)
        lda     #0
        shorta
        rtl
; underground
@c523:  cmp     #$01
        bne     @c567
        longa
        lda     f:ZoomPalTbl+18*7,x
        sta     $0cf3       ; bg palette 0, color 12
        lda     f:ZoomPalTbl+18*8,x
        sta     $0cf5       ; bg palette 0, color 13
        lda     f:ZoomPalTbl+18*9,x
        sta     $0d1d       ; bg palette 2, color 1
        lda     f:ZoomPalTbl+18*10,x
        sta     $0d1f       ; bg palette 2, color 2
        lda     f:ZoomPalTbl+18*11,x
        sta     $0d21       ; bg palette 2, color 3
        lda     f:ZoomPalTbl+18*12,x
        sta     $0cdf       ; bg palette 0, color 2
        lda     f:ZoomPalTbl+18*13,x
        sta     $0ce5       ; bg palette 0, color 5
        lda     f:ZoomPalTbl+18*14,x
        sta     $0cdd       ; bg palette 0, color 1
        lda     #0
        shorta
        rtl
; moon
@c567:  longa
        lda     f:ZoomPalTbl,x
        sta     $0cdd
        lda     f:ZoomPalTbl+18*1,x
        sta     $0ce5
        lda     f:ZoomPalTbl+18*2,x
        sta     $0cf3
        sta     $0d13
        lda     f:ZoomPalTbl+18*3,x
        sta     $0cdf
        lda     f:ZoomPalTbl+18*4,x
        sta     $0d0b
        lda     f:ZoomPalTbl+18*5,x
        sta     $0d0d
        lda     f:ZoomPalTbl+18*6,x
        sta     $0d11
        lda     #0
        shorta
        rtl

; ------------------------------------------------------------------------------

; world map zoomed bg palettes (17 * 2 bytes each)

;     $00: on foot
; $01-$0f: transitioning up or down
;     $10: in airship

; moon
ZoomPalTbl:
@c5a3:  .word   $3dee,$3dee,$3ded,$39cd,$39cc,$39cc,$35ab,$35ab,$35ab
@c5b5:  .word   $56d4,$52b2,$4a71,$464f,$420e,$3ded,$39cc,$35ab,$35ab
@c5c7:  .word   $35ef,$35ef,$31ef,$31ce,$2dce,$2dce,$29ad,$29ad,$29ad
@c5d9:  .word   $35ab,$35ab,$318b,$318a,$2d6a,$2d6a,$2949,$2949,$2949
@c5eb:  .word   $333c,$333c,$331b,$2f1a,$2efa,$2ef9,$2ad9,$2ad8,$2ad8
@c5fd:  .word   $2ad8,$2ab7,$2675,$2654,$2232,$2211,$1dd0,$1daf,$1daf
@c60f:  .word   $4f9e,$4b7c,$473a,$4319,$36d7,$3296,$2e55,$2a33,$2a33
; underground
@c621:  .word   $24a6,$20a6,$1ca6,$1886,$1487,$0c87,$0867,$0067,$0067
@c633:  .word   $0067,$0067,$0047,$0046,$0026,$0026,$0005,$0005,$0005
@c645:  .word   $25d0,$25cf,$21af,$1d8e,$1d8e,$196c,$156c,$114d,$114d
@c657:  .word   $21af,$1daf,$1d8f,$198e,$196e,$156e,$154d,$114d,$114d
@c669:  .word   $196e,$196e,$196e,$156e,$154d,$154d,$114d,$114d,$114d
@c67b:  .word   $155b,$115a,$1159,$0d58,$0937,$0936,$0535,$0135,$0135
@c68d:  .word   $15dd,$11ba,$11b9,$0d98,$0977,$0976,$0555,$0135,$0135
@c69f:  .word   $37df,$2f7d,$2b1c,$22ba,$1a59,$11f7,$0976,$0135,$0135
; overworld
@c6b1:  .word   $6520,$5d20,$5900,$5500,$50e0,$4ce0,$48c0,$44c0,$3ca0  ; light ocean
@c6c3:  .word   $2460,$2860,$2c60,$3080,$3480,$3880,$3ca0,$3ca0,$3ca0  ; dark ocean

; ------------------------------------------------------------------------------

; [ invert map palette ]

InvertPal:
@c6d5:  longa
        ldx     #0
@c6da:  lda     $0cdb,x
        eor     #$7fff
        and     #$7bde
        lsr
        sta     $0bdb,x
        inx2
        cpx     #$0100
        bne     @c6da
        lda     #0
        shorta
        rtl

; ------------------------------------------------------------------------------
