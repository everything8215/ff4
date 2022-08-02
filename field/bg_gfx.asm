
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: bg_gfx.asm                                                           |
; |                                                                            |
; | description: background graphics routines                                  |
; |                                                                            |
; | created: 3/26/2022                                                         |
; +----------------------------------------------------------------------------+

.pushseg

; 1d/8000
.segment "world_gfx"
        .include "gfx/world_bg_gfx.asm"

.segment "map_gfx1"

MapGfxPtrs:
        make_ptr_tbl_abs MapGfx, 16

MapGfx_0002:
        .include .sprintf("gfx/cave1_gfx_%s.asm", LANG_SUFFIX)

MapGfx_0004:
        .include .sprintf("gfx/town_ex_gfx_%s.asm", LANG_SUFFIX)

MapGfx_0005:
        .include .sprintf("gfx/town_in_gfx_%s.asm", LANG_SUFFIX)

MapGfx_0006:
        .include .sprintf("gfx/castle_in_gfx_%s.asm", LANG_SUFFIX)

MapGfx_0007:
        .include .sprintf("gfx/crystal_gfx_%s.asm", LANG_SUFFIX)

MapGfx_0001:
MapGfx_000c:
        .include .sprintf("gfx/lunar_gfx_%s.asm", LANG_SUFFIX)

.segment "map_gfx2"

MapGfx_0009:
        .include .sprintf("gfx/underground_gfx_%s.asm", LANG_SUFFIX)

MapGfx_0008:
MapGfx_000a:
MapGfx_000b:
        .include .sprintf("gfx/tower_gfx_%s.asm", LANG_SUFFIX)

        .include "gfx/map_anim_gfx.asm"

MapGfx_000d:
        .include .sprintf("gfx/mountain_gfx_%s.asm", LANG_SUFFIX)

MapGfx_000e:
        .include .sprintf("gfx/cave2_gfx_%s.asm", LANG_SUFFIX)

.segment "map_gfx3"

MapGfx_0003:
        .include .sprintf("gfx/castle_ex_gfx_%s.asm", LANG_SUFFIX)

.segment "map_gfx4"

MapGfx_0000:
MapGfx_000f:
        .include .sprintf("gfx/ship_gfx_%s.asm", LANG_SUFFIX)

.popseg

; ------------------------------------------------------------------------------

; [ transfer 3bpp graphics to vram ]

;  $49: source bank
; +$4a: source address
; +$4c: destination address (vram)
; +$4e: size

Tfr3bppGfx:
@b000:  stz     $420b
        lda     #$80
        sta     $2115
        lda     #$08
        sta     $4300
        lda     #$19
        sta     $4301
        stz     $4304
        ldx     $4c
        stx     $2116
        stz     $10
        ldx     #$0610
        stx     $4302
        ldx     $4e
        stx     $4305
        lda     #$01
        sta     $420b
        stz     $420b
        lsr     $4f                     ; size / 16
        ror     $4e
        lsr     $4f
        ror     $4e
        lsr     $4f
        ror     $4e
        lsr     $4f
        ror     $4e
        lda     #$18
        sta     $4301
        ldx     $4c
        stx     $2116
        ldx     $4a
        stx     $4302
        lda     $49
        sta     $4304
        ldy     #0
@b056:  stz     $420b
        lda     #$80
        sta     $2115
        lda     #$01
        sta     $4300
        ldx     #$0010                  ; transfer 16 bytes
        stx     $4305
        lda     #$01
        sta     $420b
        stz     $420b
        stz     $2115
        stz     $4300
        ldx     #8                      ; transfer 8 bytes
        stx     $4305
        lda     #$01
        sta     $420b
        iny
        cpy     $4e
        bne     @b056
        rtl

; ------------------------------------------------------------------------------

; [ load map bg graphics ]

LoadBGGfx:
@b088:  lda     $0fdd
        beq     @b091                   ; airship and ship graphics are 4bpp
        cmp     #$0f
        bne     @b094
@b091:  jmp     @b0be

; 3bpp
@b094:  jsl     ClearBGGfx
        stz     $420b
        lda     $0fdd
        asl
        tax
        lda     f:MapGfxPtrs,x          ; map graphics pointers
        sta     $4302
        lda     f:MapGfxPtrs+1,x
        sta     $4303
        lda     $0fdd
        tax
        lda     f:MapGfxBankTbl,x       ; bank byte for map graphics pointers
        sta     $4304
        jsl     TfrBGGfx
        rtl

; 4bpp
@b0be:  ldx     #0
        stx     $47
        ldx     #$2400                  ; copy $2400 bytes -> vram $0000-$11ff
        stx     $45
        lda     #.bankbyte(MapGfx_0000)
        sta     $3c
        lda     f:MapGfxPtrs
        sta     $3d
        lda     f:MapGfxPtrs+1
        sta     $3e
        lda     #$80
        sta     $2115
        stz     hMDMAEN
        lda     #$01
        sta     $4300
        lda     #$18
        sta     $4301
        lda     $3c
        sta     $4304
        ldx     $47
        stx     $2116
        ldx     $3d
        stx     $4302
        ldx     $45
        stx     $4305
        lda     #1
        sta     hMDMAEN
        rtl

; ------------------------------------------------------------------------------

; bank byte for map graphics pointers (at 1e/8000)
MapGfxBankTbl:
@b104:
.repeat 16, i
      .bankbytes .ident(.sprintf("MapGfx_%04x", i))
.endrep

; ------------------------------------------------------------------------------

; [ clear bg1/bg2 graphics in vram ]

; this only clears the high byte of each vram address to prepare to
; load 3bpp graphics

ClearBGGfx:
@b114:  stz     hMDMAEN
        lda     #$80
        sta     hVMAINC
        lda     #$08
        sta     $4300
        lda     #$19
        sta     $4301
        ldx     #$0000
        stx     hVMADDL
        stz     $06         ; fixed value for clearing vram
        ldx     #$0606
        stx     $4302
        stz     $4304
        ldx     #$1800      ; clear $3000 bytes (vram $0000-$17ff)
        stx     $4305
        lda     #1
        sta     hMDMAEN
        rtl

; ------------------------------------------------------------------------------

; [ transfer bg1/bg2 graphics to vram (3bpp) ]

; this does not affect the bytes which determine the 4th bitplane, so
; they must be cleared first by calling ClearBGGfx

TfrBGGfx:
@b143:  lda     #$18
        sta     $4301
        ldx     #$0000
        stx     hVMADDL
        ldy     #0
@b151:  lda     #$80
        sta     hVMAINC
        lda     #$01
        sta     $4300
        ldx     #$0010
        stx     $4305
        lda     #$01
        sta     hMDMAEN
        stz     hMDMAEN
        stz     hVMAINC
        stz     $4300
        ldx     #8
        stx     $4305
        lda     #$01
        sta     hMDMAEN
        iny
        cpy     #$0180      ; copy 384 tiles (vram $0000-$17ff)
        bne     @b151
        rtl

; ------------------------------------------------------------------------------

; [ transfer world map graphics to vram ]

TfrWorldGfx:
@b181:  lda     #$80
        sta     hVMAINC
        ldx     #$0000
        stx     hVMADDL
        lda     $1700
        sta     $3e
        stz     $3d
        ldx     $3d
        ldy     #0
@b198:  lda     f:WorldTilePal,x
        sta     $0bdb,y
        inx
        iny
        cpy     #$0100
        bne     @b198
        lda     $1700
        asl5
        sta     $3e
        stz     $3d
        ldx     $3d
        ldy     #0
@b1b7:  lda     f:WorldBGGfx,x
        sta     $08
        inx
        and     #$0f
        clc
        adc     $0bdb,y
        sta     hVMDATAH
        lda     $08
        lsr4
        clc
        adc     $0bdb,y
        sta     hVMDATAH
        txa
        and     #$1f
        bne     @b1b7
        iny
        cpy     #$0100
        bne     @b1b7
        rtl

; --------------------------------------------------------------------------
