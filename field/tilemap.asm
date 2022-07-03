
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: tilemap.asm                                                          |
; |                                                                            |
; | description: tilemap loading/scrolling                                     |
; |                                                                            |
; | created: 3/26/2022                                                         |
; +----------------------------------------------------------------------------+

.pushseg

.segment "sub_tilemap"

SubTilemapPtrs:
        make_ptr_tbl_rel SubTilemap1, $0100, SubTilemapPtrs
        make_ptr_tbl_rel SubTilemap2, $80, SubTilemapPtrs + $8000

        .include .sprintf("data/sub_tilemap1_%s.asm", LANG_SUFFIX)
        .include .sprintf("data/sub_tilemap2_%s.asm", LANG_SUFFIX)

.segment "world_tilemap"

; 16/8000
OverworldTilemapPtrs:
        make_ptr_tbl_rel OverworldTilemap, $0100, OverworldTilemap

; 16/8200
UndergroundTilemapPtrs:
        make_ptr_tbl_rel UndergroundTilemap, $0100, UndergroundTilemap

; 16/8400
MoonTilemapPtrs:
        make_ptr_tbl_rel MoonTilemap, $40, MoonTilemap

; 16/8480
        .include "data/overworld_tilemap.asm"
        .res $4000+OverworldTilemap-*

; 16/c480
        .include "data/underground_tilemap.asm"
        .res $1d00+UndergroundTilemap-*

; 16/e180
        .include "data/moon_tilemap.asm"

.popseg

; ------------------------------------------------------------------------------

; [ update bg2 scroll ]

UpdateBG2Scroll:
@f533:  lda     $c9
        bne     @f545
        lda     $1700
        cmp     #$03
        bne     @f545
        lda     $0fe4
        and     #$c0
        bne     @f546
@f545:  rts
@f546:  lda     $0fe4
        and     #$06
        bne     @f593
; continuous scroll
        lda     $0fe4
        and     #$c0
        lsr6
        tay
        lda     $7a
        and     BG2ScrollRateTbl,y     ; bg2 scroll speed
        bne     @f57b
        lda     $0fe4
        and     #$30
        lsr3
        tay
        longa
        lda     $66
        clc
        adc     HorzMoveRateTbl,y
        sta     $66
        lda     $68
        clc
        adc     VertMoveRateTbl,y
        sta     $68
@f57b:  longa
        lda     $5a
        clc
        adc     $66
        sta     $5e
        lda     $5c
        clc
        adc     $68
        sta     $60
        lda     #$0000
        shorta
        jmp     @f5f8
; parallax scroll
@f593:  lda     $0fe4
        and     #$04
        beq     @f5c7
        ldx     $5a
        stx     $5e
        lda     $0fe4
        and     #$c0
        cmp     #$80
        beq     @f5b6
        cmp     #$40
        beq     @f5b2
        asl     $5e
        rol     $5f
        jmp     @f5b6
@f5b2:  lsr     $5f
        ror     $5e
@f5b6:  lda     $0fe4
        and     #$06
        cmp     #$04
        bne     @f5c7
        ldx     #$0000
        stx     $60
        jmp     @f5f8
@f5c7:  lda     $0fe4
        and     #$02
        beq     @f5f8
        ldx     $5c
        stx     $60
        lda     $0fe4
        and     #$c0
        cmp     #$80
        beq     @f5ea
        cmp     #$40
        beq     @f5e6
        asl     $60
        rol     $61
        jmp     @f5ea
@f5e6:  lsr     $61
        ror     $60
@f5ea:  lda     $0fe4
        and     #$06
        cmp     #$02
        bne     @f5f8
        ldx     #$0000
        stx     $5e
@f5f8:  rts

; ------------------------------------------------------------------------------

; bg2 scroll speeds
BG2ScrollRateTbl:
@f5f9:  .byte   $00,$07,$01,$00

; movement h-scroll speeds
HorzMoveRateTbl:
@f5fd:  .word   0,.loword(-1),0,1

; movement v-scroll speeds
VertMoveRateTbl:
@f605:  .word   1,0,.loword(-1),0

; ------------------------------------------------------------------------------

; [ load world tileset ]

;  a: source bank
; +y: source address

LoadWorldTileset:
@f60d:  pha
        plb
        ldx     #0
@f612:  lda     a:$0000,y
        sta     $7f4800,x
        iny
        inx
        cpx     #$0200
        bne     @f612
        lda     #0
        pha
        plb
        rts

; ------------------------------------------------------------------------------

; [ clear bg tilemap ]

; a: fill tile

ClearBGTilemap:
@f625:  ldx     #0
@f628:  sta     $7f5c71,x
        inx
        cpx     #$4000
        bne     @f628
        rts

; ------------------------------------------------------------------------------

; [ update tilemap scrolling (world map) ]

UpdateScrollWorld:
@f633:  lda     $ab
        bne     @f638       ; return if not moving
        rts
@f638:  and     #$01
        beq     @f63f
        jmp     @f6c9
; moving right
@f63f:  lda     $ab
        and     #$02
        beq     @f650
        lda     $1706
        clc
        adc     #$21
        sta     $3d
        jmp     @f658
; moving left
@f650:  lda     $1706
        sec
        sbc     #$1f
        sta     $3d
@f658:  lda     $1707
        sec
        sbc     #$1f
        and     #$3f
        sta     $3e
        ldx     $3d
        stx     $40
        ldy     #$0000
@f669:  ldx     $3d
        lda     $7f5c71,x
        tax
        lda     $7f4800,x
        sta     $0adb,y
        lda     $7f4900,x
        sta     $0adc,y
        lda     $7f4880,x
        sta     $0b5b,y
        lda     $7f4980,x
        sta     $0b5c,y
        lda     $3e
        inc
        and     #$3f
        sta     $3e
        iny2
        cpy     #$0080
        bne     @f669
        stz     $98
        stz     $96
        stz     $9c
        stz     $a0
        lda     $40
        asl
        and     #$7f
        sta     $99
        sta     $9b
        inc
        sta     $9d
        sta     $9f
        lda     $1707
        sec
        sbc     #$1f
        and     #$3f
        sta     $9a
        sta     $9e
        asl
        sta     $97
        lda     #$80
        sec
        sbc     $97
        sta     $95
        inc     $94
        rts
; moving up
@f6c9:  lda     $ab
        and     #$02
        bne     @f6de
        lda     $1707
        sec
        sbc     #$1f
        sta     $06
        and     #$3f
        sta     $3e
        jmp     @f6ea
; moving down
@f6de:  lda     $1707
        clc
        adc     #$20
        sta     $06
        and     #$3f
        sta     $3e
@f6ea:  lda     $1706
        sec
        sbc     #$1f
        sta     $3d
        ldx     $3d
        stx     $40
        ldy     #$0000
@f6f9:  ldx     $3d
        lda     $7f5c71,x
        tax
        lda     $7f4800,x
        sta     $0adb,y
        lda     $7f4880,x
        sta     $0adc,y
        lda     $7f4900,x
        sta     $0b5b,y
        lda     $7f4980,x
        sta     $0b5c,y
        iny2
        inc     $3d
        cpy     #$0080
        bne     @f6f9
        stz     $97
        stz     $98
        lda     #$80
        sta     $95
        stz     $96
        stz     $9b
        lda     #$80
        sta     $9f
        lda     $06
        and     #$3f
        sta     $9a
        sta     $9c
        sta     $9e
        sta     $a0
        lda     $1706
        sec
        sbc     #$1f
        and     #$3f
        asl
        sta     $99
        clc
        adc     #$80
        sta     $9d
        lda     $99
        sta     $97
        lda     #$80
        sec
        sbc     $97
        sta     $95
        inc     $94
        rts

; ------------------------------------------------------------------------------

; [ update tilemap scrolling (sub-map) ]

UpdateScrollSub:
@f75f:  lda     $ab
        bne     @f764       ; return if not moving
        rts
@f764:  and     #$01
        beq     @f76b
        jmp     @f83f
@f76b:  lda     $ab
        and     #$02
        beq     @f77c
; moving right
        lda     $1706
        clc
        adc     #$09
        sta     $3d
        jmp     @f784
; moving left
@f77c:  lda     $1706
        sec
        sbc     #$08
        sta     $3d
@f784:  lda     $1707
        sec
        sbc     #$07
        and     #$3f
        sta     $3e
        ldx     $3d
        stx     $43
        ldy     #$0000
@f795:  ldx     $3d
        lda     $7f5c71,x   ; tile id
        sta     $18
        stz     $19
        longa
        asl     $18
        ldx     $18
        lda     $7f4800,x   ; copy from tileset to tilemap buffer
        sta     $0adb,y
        lda     $7f4a00,x
        sta     $0add,y
        lda     $7f4900,x
        sta     $0b1b,y
        lda     $7f4b00,x
        sta     $0b1d,y
        lda     #$0000
        shorta
        lda     $3e
        inc
        and     #$3f
        sta     $3e
        iny4
        cpy     #$0040
        beq     @f7d9
        jmp     @f795
@f7d9:  stz     $99
        lda     $44
        and     #$0f
        sta     $9a
        lsr     $9a
        ror     $99
        lsr     $9a
        ror     $99
        lda     $43
        and     #$1f
        asl
        sta     $43
        and     #$20
        beq     @f7fb
        lda     $9a
        clc
        adc     #$04
        sta     $9a
@f7fb:  lda     $43
        and     #$1f
        clc
        adc     $99
        sta     $99
        lda     $9a
        clc
        adc     #$18
        sta     $9a
        lda     $44
        and     #$0f
        asl2
        sta     $97
        stz     $98
        lda     #$40
        sec
        sbc     $97
        sta     $95
        stz     $96
        lda     $9a
        and     #$fc
        sta     $9c
        lda     $99
        and     #$1f
        sta     $9b
        lda     $99
        inc
        sta     $9d
        lda     $9a
        sta     $9e
        lda     $9b
        inc
        sta     $9f
        lda     $9c
        sta     $a0
        inc     $94
        rts
; moving up
@f83f:  lda     $ab
        and     #$02
        bne     @f852
        lda     $1707
        sec
        sbc     #$08
        and     #$3f
        sta     $3e
        jmp     @f85c
; moving down
@f852:  lda     $1707
        clc
        adc     #$08
        and     #$3f
        sta     $3e
@f85c:  lda     $1706
        sec
        sbc     #$07
        sta     $3d
        ldx     $3d
        stx     $43
        jsr     CopyTilemapToBuffer
        jsr     _00f8af
        rts

; ------------------------------------------------------------------------------

; [ copy tilemap row to vram buffer ]

CopyTilemapToBuffer:
@f86f:  ldy     #0
@f872:  ldx     $3d
        lda     $7f5c71,x
        sta     $18
        stz     $19
        longa
        asl     $18
        ldx     $18
        lda     $7f4800,x   ; copy to tilemap vram buffer
        sta     $0adb,y
        lda     $7f4900,x
        sta     $0add,y
        lda     $7f4a00,x
        sta     $0b1b,y
        lda     $7f4b00,x
        sta     $0b1d,y
        lda     #0
        shorta
        iny4
        inc     $3d
        cpy     #$0040
        bne     @f872
        rts

; ------------------------------------------------------------------------------

; [  ]

_00f8af:
@f8af:  stz     $99
        lda     $44
        and     #$0f
        sta     $9a
        lsr     $9a
        ror     $99
        lsr     $9a
        ror     $99
        lda     $43
        and     #$1f
        asl
        sta     $43
        and     #$20
        beq     @f8d1
        lda     $9a
        clc
        adc     #$04
        sta     $9a
@f8d1:  lda     $43
        and     #$1f
        clc
        adc     $99
        sta     $99
        lda     $9a
        clc
        adc     #$18
        sta     $9a
        lda     $99
        and     #$1f
        asl
        sta     $97
        stz     $98
        lda     #$40
        sec
        sbc     $97
        sta     $95
        stz     $96
        lda     $99
        and     #$e0
        sta     $9b
        lda     $9a
        clc
        adc     #$04
        and     #$07
        clc
        adc     #$18
        sta     $9c
        lda     $99
        clc
        adc     #$20
        sta     $9d
        lda     $9a
        adc     #$00
        sta     $9e
        lda     $9b
        clc
        adc     #$20
        sta     $9f
        lda     $9c
        adc     #$00
        sta     $a0
        inc     $94
        rts

; ------------------------------------------------------------------------------

; [  ]

_00f922:
@f922:  stz     $99
        lda     $44
        and     #$0f
        sta     $9a
        lda     $44
        and     #$10
        beq     @f937
        lda     $9a
        clc
        adc     #$20
        sta     $9a
@f937:  lsr     $9a
        ror     $99
        lsr     $9a
        ror     $99
        lda     $43
        and     #$1f
        asl
        sta     $43
        and     #$20
        beq     @f951
        lda     $9a
        clc
        adc     #$04
        sta     $9a
@f951:  lda     $43
        and     #$1f
        clc
        adc     $99
        sta     $99
        lda     $9a
        clc
        adc     #$30
        sta     $9a
        lda     $99
        clc
        adc     #$20
        sta     $9d
        lda     $9a
        adc     #$00
        sta     $9e
        inc     $94
        rts

; ------------------------------------------------------------------------------

; [  ]

_00f971:
@f971:  longa
        lda     $1707
        and     #$00ff
        sec
        sbc     #$0007
        asl4
        and     #$07ff
        sta     $5c
        lda     $1706
        and     #$00ff
        sec
        sbc     #$0007
        asl4
        and     #$07ff
        sta     $5a
        lda     #$0000
        shorta
        lda     #$40
        sta     $07
        lda     $1707
        sta     $070a
@f9a8:  jsr     DecodeWorldTilemap
        inc     $070a
        dec     $07
        bne     @f9a8
        lda     #$40
        sta     $07
        lda     $1707
        sec
        sbc     #$1f
        sta     $08
@f9be:  lda     $08
        and     #$3f
        sta     $3e
        lda     $1706
        sec
        sbc     #$1f
        sta     $3d
        ldx     $3d
        ldy     #$0000
@f9d1:  ldx     $3d
        lda     $7f5c71,x
        tax
        lda     $7f4800,x
        sta     $0adb,y
        lda     $7f4880,x
        sta     $0adc,y
        lda     $7f4900,x
        sta     $0b5b,y
        lda     $7f4980,x
        sta     $0b5c,y
        iny2
        inc     $3d
        cpy     #$0080
        bne     @f9d1
        stz     $97
        stz     $98
        lda     #$80
        sta     $95
        stz     $96
        stz     $9b
        lda     #$80
        sta     $9f
        lda     $08
        and     #$3f
        sta     $9a
        sta     $9c
        sta     $9e
        sta     $a0
        lda     $1706
        sec
        sbc     #$1f
        and     #$3f
        asl
        sta     $99
        clc
        adc     #$80
        sta     $9d
        lda     $99
        sta     $97
        lda     #$80
        sec
        sbc     $97
        sta     $95
        stz     $2115
        jsr     InitDMA
        stz     $4300
        ldx     $99
        stx     $2116
        ldx     #$0adb
        stx     $4302
        ldx     $95
        stx     $4305
        jsr     ExecDMA
        ldx     $9b
        stx     $2116
        stz     $420b
        ldx     $97
        beq     @fa62
        stx     $4305
        jsr     ExecDMA
@fa62:  ldx     $9d
        stx     $2116
        stz     $420b
        ldx     #$0b5b
        stx     $4302
        ldx     $95
        stx     $4305
        jsr     ExecDMA
        ldx     $9f
        stx     $2116
        stz     $420b
        ldx     $97
        beq     @fa8a
        stx     $4305
        jsr     ExecDMA
@fa8a:  inc     $08
        dec     $07
        beq     @fa93
        jmp     @f9be
@fa93:  rts

; ------------------------------------------------------------------------------

; [ init bg1 tilemap ]

InitBG1Tilemap:
@fa94:  longa
        lda     $1707
        and     #$00ff
        sec
        sbc     #$0007
        asl4
        sta     $5c
        lda     $1706
        and     #$00ff
        sec
        sbc     #$0007
        asl4
        sta     $5a
        lda     #$0000
        shorta
        jsr     DecodeBG1Tilemap
        jsr     InitTreasures
        lda     #$10
        sta     $07
        lda     $1707
        sec
        sbc     #$07
        sta     $08
@facd:  lda     $08
        and     #$3f
        sta     $3e
        lda     $1706
        sec
        sbc     #$07
        sta     $3d
        ldx     $3d
        stx     $43
        jsr     CopyTilemapToBuffer
        jsr     _00f8af
        lda     #$80
        sta     $2115
        jsr     InitDMA
        lda     #$01
        sta     $4300
        ldx     $99
        stx     $2116
        ldx     #$0adb
        stx     $4302
        ldx     $95
        stx     $4305
        jsr     ExecDMA
        ldx     $9b
        stx     $2116
        stz     $420b
        ldx     $97
        beq     @fb17
        stx     $4305
        jsr     ExecDMA
@fb17:  ldx     $9d
        stx     $2116
        stz     $420b
        ldx     #$0b1b
        stx     $4302
        ldx     $95
        stx     $4305
        jsr     ExecDMA
        ldx     $9f
        stx     $2116
        stz     $420b
        ldx     $97
        beq     @fb3f
        stx     $4305
        jsr     ExecDMA
@fb3f:  inc     $08
        dec     $07
        beq     @fb48
        jmp     @facd
@fb48:  rts

; ------------------------------------------------------------------------------

; [ init bg2 tilemap ]

InitBG2Tilemap:
@fb49:  lda     #$80
        sta     $2115
        jsr     InitDMA
        lda     #$01
        sta     $4300
        jsr     DecodeBG2Tilemap
        lda     #$20
        sta     $07
        lda     #$00
        sta     $08
@fb61:  lda     $08
        and     #$1f
        sta     $3e
        lda     #$00
        sta     $3d
        ldx     $3d
        stx     $43
        jsr     CopyTilemapToBuffer
        jsr     _00f922
        jsr     TfrBG2Tilemap
        lda     #$10
        sta     $3d
        ldx     $3d
        stx     $43
        jsr     CopyTilemapToBuffer
        jsr     _00f922
        jsr     TfrBG2Tilemap
        inc     $08
        dec     $07
        beq     @fb92
        jmp     @fb61
@fb92:  rts

; ------------------------------------------------------------------------------

; [ transfer bg2 tilemap to vram ]

TfrBG2Tilemap:
@fb93:  ldx     $99
        stx     $2116
        stz     $420b
        ldx     #$0adb
        stx     $4302
        ldx     #$0040
        stx     $4305
        jsr     ExecDMA
        ldx     $9d
        stx     $2116
        stz     $420b
        ldx     #$0b1b
        stx     $4302
        ldx     #$0040
        stx     $4305
        jsr     ExecDMA
        rts

; ------------------------------------------------------------------------------

; [ transfer bg1 tilemap to vram (scrolling) ]

TfrBG1Tilemap:
@fbc2:  lda     $ab
        and     #$01
        bne     @fbcb
        jmp     @fc1d
; moving vertically
@fbcb:  lda     #$80
        sta     $2115
        jsr     InitDMA
        lda     #$01
        sta     $4300
        ldx     $99
        stx     $2116
        ldx     #$0adb
        stx     $4302
        ldx     $95
        stx     $4305
        jsr     ExecDMA
        ldx     $9b
        stx     $2116
        ldx     $97
        beq     @fbfa
        stx     $4305
        jsr     ExecDMA
@fbfa:  ldx     $9d
        stx     $2116
        ldx     #$0b1b
        stx     $4302
        ldx     $95
        stx     $4305
        jsr     ExecDMA
        ldx     $9f
        stx     $2116
        ldx     $97
        beq     @fc1c
        stx     $4305
        jsr     ExecDMA
@fc1c:  rts
@fc1d:  lda     $ab
        bne     @fc22       ; return if not moving
        rts
; moving horizontally
@fc22:  lda     #$81
        sta     $2115
        jsr     InitDMA
        lda     #$01
        sta     $4300
        ldx     $99
        stx     $2116
        ldx     #$0adb
        stx     $4302
        ldx     $95
        stx     $4305
        jsr     ExecDMA
        ldx     $9b
        stx     $2116
        ldx     $97
        beq     @fc51
        stx     $4305
        jsr     ExecDMA
@fc51:  ldx     $9d
        stx     $2116
        ldx     #$0b1b
        stx     $4302
        ldx     $95
        stx     $4305
        jsr     ExecDMA
        ldx     $9f
        stx     $2116
        ldx     $97
        beq     @fc73
        stx     $4305
        jsr     ExecDMA
@fc73:  rts

; ------------------------------------------------------------------------------

; [ transfer world tilemap to vram ]

TfrWorldTilemap:
@fc74:  lda     $ab
        and     #$01
        bne     @fc7d
        jmp     @fccb
@fc7d:  stz     $2115
        jsr     InitDMA
        stz     $4300
        ldx     $99
        stx     $2116
        ldx     #$0adb
        stx     $4302
        ldx     $95
        stx     $4305
        jsr     ExecDMA
        ldx     $9b
        stx     $2116
        ldx     $97
        beq     @fca8
        stx     $4305
        jsr     ExecDMA
@fca8:  ldx     $9d
        stx     $2116
        ldx     #$0b5b
        stx     $4302
        ldx     $95
        stx     $4305
        jsr     ExecDMA
        ldx     $9f
        stx     $2116
        ldx     $97
        beq     @fcca
        stx     $4305
        jsr     ExecDMA
@fcca:  rts
@fccb:  lda     $ab
        bne     @fcd0
        rts
@fcd0:  lda     #$03
        sta     $2115
        jsr     InitDMA
        stz     $4300
        ldx     $99
        stx     $2116
        ldx     #$0adb
        stx     $4302
        ldx     $95
        stx     $4305
        jsr     ExecDMA
        ldx     $9b
        stx     $2116
        ldx     $97
        beq     @fcfd
        stx     $4305
        jsr     ExecDMA
@fcfd:  ldx     $9d
        stx     $2116
        ldx     #$0b5b
        stx     $4302
        ldx     $95
        stx     $4305
        jsr     ExecDMA
        ldx     $9f
        stx     $2116
        ldx     $97
        beq     @fd1f
        stx     $4305
        jsr     ExecDMA
@fd1f:  rts

; ------------------------------------------------------------------------------

; [ decompress world tilemap ]

DecodeWorldTilemap:
@fd20:  lda     $ab
        and     #$01
        bne     @fd26
@fd26:  lda     $06fa
        tax
        lda     $ab
        and     #$02
        bne     @fd3c
        lda     $070a
        sec
        sbc     #$1f
        and     WorldSizeMask,x
        jmp     @fd45
@fd3c:  lda     $070a
        clc
        adc     #$20
        and     WorldSizeMask,x     ; world map size masks
@fd45:  sta     $3d
        sta     $93
        stz     $3e
        stz     $44
        lda     $3d
        and     #$3f
        sta     $41
        stz     $40
        asl     $3d
        rol     $3e
        lda     $1700
        bne     @fd66
        jsr     DecodeOverworldTilemap
        jsl     ModOverworldTilemap
        rts
@fd66:  cmp     #$01
        bne     @fd6e
        jsr     DecodeUndergroundTilemap
        rts
@fd6e:  jsr     DecodeMoonTilemap
        rts

; ------------------------------------------------------------------------------

; [ decompress overworld tilemap ]

DecodeOverworldTilemap:
@fd72:  ldx     $3d
        lda     f:OverworldTilemapPtrs,x
        sta     $3d
        lda     f:OverworldTilemapPtrs+1,x
        sta     $3e
        ldx     $3d
@fd82:  lda     f:OverworldTilemap,x
        bpl     @fdaa
        and     #$7f
        pha
        lda     f:OverworldTilemap+1,x
        tay
        iny
        pla
        ldx     $40
@fd94:  sta     $7f5c71,x
        inx
        dey
        bne     @fd94
        stx     $40
        txa
        beq     @fdff
        ldx     $3d
        inx2
        stx     $3d
        jmp     @fd82
@fdaa:  cmp     #$00
        beq     @fdce
        cmp     #$10
        beq     @fdce
        cmp     #$20
        beq     @fdce
        cmp     #$30
        beq     @fdce
        ldx     $40
        sta     $7f5c71,x
        inx
        stx     $40
        txa
        beq     @fdff
        ldx     $3d
        inx
        stx     $3d
        jmp     @fd82
@fdce:  ldx     $40
        sta     $7f5c71,x
        inx
        lsr3
        sta     $06
        lsr
        clc
        adc     $06
        clc
        adc     #$70
        sta     $7f5c71,x
        inx
        inc
        sta     $7f5c71,x
        inx
        inc
        sta     $7f5c71,x
        inx
        stx     $40
        txa
        beq     @fdff
        ldx     $3d
        inx
        stx     $3d
        jmp     @fd82
@fdff:  rts

; ------------------------------------------------------------------------------

; [ decompress underground tilemap ]

DecodeUndergroundTilemap:
@fe00:  ldx     $3d
        lda     f:UndergroundTilemapPtrs,x
        sta     $3d
        lda     f:UndergroundTilemapPtrs+1,x
        sta     $3e
        ldx     $3d
@fe10:  lda     f:UndergroundTilemap,x
        bpl     @fe38
        and     #$7f
        pha
        lda     f:UndergroundTilemap+1,x
        tay
        iny
        pla
        ldx     $40
@fe22:  sta     $7f5c71,x
        inx
        dey
        bne     @fe22
        stx     $40
        txa
        beq     @fe4c
        ldx     $3d
        inx2
        stx     $3d
        jmp     @fe10
@fe38:  ldx     $40
        sta     $7f5c71,x
        inx
        stx     $40
        txa
        beq     @fe4c
        ldx     $3d
        inx
        stx     $3d
        jmp     @fe10
@fe4c:  rts

; ------------------------------------------------------------------------------

; [ decompress moon tilemap ]

DecodeMoonTilemap:
@fe4d:  ldx     $3d
        lda     f:MoonTilemapPtrs,x
        sta     $3d
        lda     f:MoonTilemapPtrs+1,x
        sta     $3e
        ldx     $3d
@fe5d:  lda     f:MoonTilemap,x
        bpl     @fe87
        and     #$7f
        pha
        lda     f:MoonTilemap+1,x
        tay
        iny
        pla
        ldx     $40
@fe6f:  sta     $7f5c71,x
        inx
        dey
        bne     @fe6f
        stx     $40
        txa
        cmp     #$40
        beq     @fe9d
        ldx     $3d
        inx2
        stx     $3d
        jmp     @fe5d
@fe87:  ldx     $40
        sta     $7f5c71,x
        inx
        stx     $40
        txa
        cmp     #$40
        beq     @fe9d
        ldx     $3d
        inx
        stx     $3d
        jmp     @fe5d
@fe9d:  ldy     #$0040
        ldx     $40
@fea2:  lda     $7f5c31,x
        sta     $7f5c71,x
        sta     $7f5cb1,x
        sta     $7f5cf1,x
        inx
        dey
        bne     @fea2
        rts

; ------------------------------------------------------------------------------

; world map size masks
WorldSizeMask:
@feb7:  .byte   $ff,$ff,$3f

; ------------------------------------------------------------------------------

; [ decompress bg tilemap ]

DecodeSubTilemap:
@feba:  sta     $3d
        stz     $3e
        lda     #.bankbyte(SubTilemapPtrs)
        sta     $06
        lda     $0fe5                   ; tilemap msb
        and     #$01
        bne     @fece
        lda     $1701
        beq     @fed0                   ; branch if on overworld
@fece:  inc     $3e
@fed0:  asl     $3d
        rol     $3e
        ldx     $3d
        lda     f:SubTilemapPtrs,x      ; pointers to sub-map tilemaps
        sta     $3d
        lda     f:SubTilemapPtrs+1,x
        sta     $3e
        bpl     @feea
        inc     $06                     ; increment bank
        and     #$7f
        sta     $3e
@feea:  lda     f:SubTilemapPtrs+2,x    ; next pointer
        sta     $40
        lda     f:SubTilemapPtrs+3,x
        and     #$7f
        sta     $41
        ldx     $3d
        cpx     $40
        bcc     @ff05
        lda     $41
        clc
        adc     #$80
        sta     $41
@ff05:  lda     $0fe5                   ; sub-map tilemap msb
        and     #$01
        bne     @ff11
        lda     $1701
        beq     @ff13
@ff11:  inc     $06
@ff13:  lda     $40
        sec
        sbc     $3d
        sta     $40
        lda     $41
        sbc     $3e
        sta     $41
        ldy     $3d
        ldx     #0
        lda     $06
        pha
        plb
@ff29:  lda     $8000,y
        sta     $7f4400,x               ; copy to buffer
        inx
        cpx     $40
        beq     @ff47
        iny
        cpy     #$8000
        bne     @ff29
        ldy     #0
        inc     $06                     ; next bank
        lda     $06
        pha
        plb
        jmp     @ff29
@ff47:  lda     #$00
        pha
        plb
        ldx     #0
        stx     $40
        stx     $3d
@ff52:  lda     $7f4400,x               ; decode sub-map tilemap
        bpl     @ff89
; rle
        and     #$7f
        pha
        lda     $7f4401,x
        tay
        iny
        pla
        ldx     $40
@ff64:  sta     $7f5c71,x
        inx
        stx     $40
        pha
        txa
        cmp     #$20
        bne     @ff77
        inc     $41
        stz     $40
        ldx     $40
@ff77:  pla
        cpx     #$2000
        beq     @ffaa
        dey
        bne     @ff64
        ldx     $3d
        inx2
        stx     $3d
        jmp     @ff52
; raw
@ff89:  ldx     $40
        sta     $7f5c71,x
        inx
        stx     $40
        txa
        cmp     #$20
        bne     @ff9b
        stz     $40
        inc     $41
@ff9b:  ldx     $40
        cpx     #$2000
        beq     @ffaa
        ldx     $3d
        inx
        stx     $3d
        jmp     @ff52
@ffaa:  rts

; ------------------------------------------------------------------------------

; [ decode bg1 tilemap ]

DecodeBG1Tilemap:
@ffab:  lda     $06f9       ; bg1 tilemap
        jsr     DecodeSubTilemap
        rts

; ------------------------------------------------------------------------------

; [ decode bg2 tilemap ]

DecodeBG2Tilemap:
@ffb2:  lda     $0fe3       ; bg2 tilemap
        jsr     DecodeSubTilemap
        rts

; ------------------------------------------------------------------------------
