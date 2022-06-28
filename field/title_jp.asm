
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: title_jp.asm                                                         |
; |                                                                            |
; | description: title screen (japanese version)                               |
; |                                                                            |
; | created: 3/26/2022                                                         |
; +----------------------------------------------------------------------------+

.pushseg

.segment "title_gfx"

        .include "gfx/title_gfx_jp.asm"
        .include "gfx/title_bg_tiles_jp.asm"
        .include "gfx/title_crystal_tiles.asm"
        .include "gfx/title_pal_jp.asm"

.popseg

; ------------------------------------------------------------------------------

; [ show title screen ]

ShowTitle:
@85fa:  jsr     ScreenOff
        stz     hMDMAEN
        stz     hHDMAEN
        lda     #1
        sta     $1e00
        lda     #$15
        sta     $1e01
        jsl     ExecSound_ext
        jsl     InitHWRegs
        lda     #3
        sta     $1700
        lda     #$13
        sta     hTM
        lda     #$02
        sta     hTS
        sta     hCGSWSEL
        lda     #$43
        sta     hCGADSUB
        lda     #1
        sta     hBGMODE
        jsr     ResetSprites
.if EASY_VERSION
        ldx     #0
        stx     $47
        ldx     #$2800
        stx     $45
        lda     #$08
        sta     $3c
        ldx     #$c000
        stx     $3d
        jsl     TfrVRAM
        ldx     #$4000
        stx     $47
        jsl     TfrVRAM
.else
        jsr     LoadTitleGfx
.endif
        lda     #$80
        sta     hVMAINC
        ldx     #$1800                  ; clear $1800-$3fff (all tilemaps)
        stx     hVMADDL
@8642:  lda     #$df                    ; use tile $df, palette 0 (black)
        sta     hVMDATAL
        stz     hVMDATAH
        inx
        cpx     #$4000
        bne     @8642
        ldx     #$1880                  ; load title screen tilemap
        stx     $47
        ldx     #$0180
        stx     $45
        ldx     #.loword(TitleBGTiles)
        stx     $3d
        jsl     TfrVRAM
        ldx     #$3080
        stx     $47
        ldx     #.loword(TitleBGTiles)+$0180
        stx     $3d
        jsl     TfrVRAM
        ldx     #0
@8674:  lda     f:TitleTextSprites,x
        sta     sprite_ram,x
        inx
        cpx     #9*4
        bne     @8674
        ldy     #0
        ldx     #.loword(TitleCrystalTiles)
        stx     $3d
@8689:  lda     TitleCrystalVRAMTbl,y
        sta     $47
        lda     TitleCrystalVRAMTbl+1,y
        sta     $48
        jsr     TfrTitleCrystalTiles
        cpy     #20
        bne     @8689
        ldy     #0
        ldx     #.loword(TitleCrystalTiles)+80
        stx     $3d
@86a3:  lda     TitleCrystalVRAMTbl,y
        sta     $47
        lda     TitleCrystalVRAMTbl+1,y
        clc
        adc     #$18
        sta     $48
        jsr     TfrTitleCrystalTiles
        cpy     #20
        bne     @86a3
        ldx     #0
@86bb:  stz     $0cdb,x
        inx
        cpx     #32*16
        bne     @86bb
        jsl     TfrPal
        ldx     #$0060
        stx     $0a6d
        ldx     #$0068
        stx     $0a6f
        stx     $0a73
        ldx     #$0048
        stx     $0a71
        ldx     #0
        stx     $5a
        stx     $5c
.if EASY_VERSION
        stx     $5e
        stx     $60
        lda     #1
        sta     $54
        sta     $7e
        stz     $7a
.else
        inx
        stx     $5e
        ldx     #$ffff
        stx     $60
        lda     #1
        sta     $54
        stz     $7a
        lda     #1
        sta     $7e
.endif
        lda     #$0f
        sta     hINIDISP
        lda     #$81
        sta     hNMITIMEN
; start of frame loop (fade in)
@8700:  jsr     WaitVblankShort
        inc     $7e
        lda     $02
        and     #JOY_A
        bne     @8710                   ; branch if A button is pressed
        stz     $54
        jmp     @8717
@8710:  lda     $54
        bne     @8717
        jmp     @8834
@8717:  lda     $7a
        and     #7
        bne     @8700
        lda     #16
        sta     $07
        ldy     #32
        ldx     $0a6d
@8727:  cpx     #32
        bcs     @8739
        longa
        lda     f:TitlePal+$60,x
        sta     $0cfb,y
        tdc
        xba
        shorta
@8739:  dey2
        dex2
        dec     $07
        bne     @8727
        ldx     $0a6d
        cpx     #32
        beq     @874e
        dex2
        stx     $0a6d
@874e:  lda     #16
        sta     $07
        ldy     #32
        ldx     $0a6f
@8758:  cpx     #32
        bcs     @876a
        longa
        lda     f:TitlePal+$80,x
        sta     $0d1b,y
        tdc
        xba
        shorta
@876a:  dex2
        dey2
        dec     $07
        bne     @8758
        ldx     $0a6f
        cpx     #32
        beq     @87b0
        dex2
        stx     $0a6f
        lda     #16
        sta     $07
        ldy     #$0020
        ldx     $0a71
@8789:  cpx     #32
        bcs     @879b
        longa
        lda     f:TitlePal+$a0,x
        sta     $0d3b,y
        tdc
        xba
        shorta
@879b:  dex2
        dey2
        dec     $07
        bne     @8789
        ldx     $0a71
        cpx     #32
        beq     @87b0
        dex2
        stx     $0a71
@87b0:  ldx     $0a73
        cpx     #32
        bcs     @87d4
        txa
        lsr
        and     #$fe
        tax
        longa
        lda     f:TitleSpritePal,x
        sta     $0ddd                   ; color 1 is white
        lda     f:TitleSpritePal,x
        and     #$001f
        sta     $0ddf                   ; color 2 is red
        tdc
        xba
        shorta
@87d4:  ldx     $0a73
        dex2
        stx     $0a73
        beq     @87e1
        jmp     @8700
@87e1:  ldx     #0
@87e4:  lda     $0cfb,x
        sta     $0a6d,x
        inx
        cpx     #32*3
        bne     @87e4
        stz     $7a

; start of frame loop (sparkle)
@87f2:  jsr     WaitVblankShort
        inc     $7e
        lda     $02
        and     #JOY_A
        bne     @8802                   ; branch if a button is pressed
        stz     $54
        jmp     @8809
@8802:  lda     $54
        bne     @8809
        jmp     @8834
@8809:  ldx     #0
@880c:  lda     $0a6d,x                 ; revert color palettes
        sta     $0cfb,x
        inx
        cpx     #32*3
        bne     @880c
        lda     $7a
        lsr
        and     #$7e
        cmp     #$16
        bcs     @87f2
        tay
        longa
        lda     #$ffff                  ; change a color to white (sparkle)
        sta     $0d3d,y
        sta     $0cfd,y
        tdc
        xba
        shorta
        jmp     @87f2
@8834:  lda     #0
        jsr     FadeOut
        jsr     ScreenOff
        rts

; ------------------------------------------------------------------------------

.if !EASY_VERSION

; [ load title screen graphics ]

LoadTitleGfx:
@883d:  ldx     #0
        stx     $47
        ldx     #$2800
        stx     $45
        lda     #.bankbyte(TitleGfx)
        sta     $3c
        ldx     #.loword(TitleGfx)
        stx     $3d
        jsl     TfrVRAM
        ldx     #$4000
        stx     $47
        jsl     TfrVRAM
        rts

.endif

; ------------------------------------------------------------------------------

; [ transfer title screen crystal tilemap to vram ]

; transfer 1 row of crystal (4 tiles)

TfrTitleCrystalTiles:
@885e:  lda     #$80
        sta     hVMAINC
        ldx     $47
        stx     hVMADDL
        ldx     $3d
@886a:  lda     f:.bankbyte(TitleCrystalTiles)<<16,x
        sta     hVMDATAL
        lda     f:.bankbyte(TitleCrystalTiles)<<16+1,x
        sta     hVMDATAH
        inx2
        txa
        and     #7
        bne     @886a
        longa
        lda     $3d
        clc
        adc     #8
        sta     $3d
        tdc
        xba
        shorta
        iny2
        rts

; ------------------------------------------------------------------------------

; [ clear vram (prologue) ]

ClearPrologueVRAM:
@8890:  sta     $76
        ldx     #$1800
        stx     $47
        ldx     #$1000
        stx     $45
        jsl     ClearVRAM
        ldx     #$3000
        stx     $47
        jsl     ClearVRAM
        rts

; ------------------------------------------------------------------------------

; sprite data for copyright

TitleTextSprites:
@88aa:  .byte   $58,$cc,$3c,$21
        .byte   $60,$cc,$3d,$21
        .byte   $68,$cc,$3e,$21
        .byte   $78,$cc,$08,$20
        .byte   $80,$cc,$18,$20
        .byte   $88,$cc,$28,$20
        .byte   $90,$cc,$6c,$20
        .byte   $98,$cc,$7c,$20
        .byte   $a0,$cc,$8c,$20

; ------------------------------------------------------------------------------

; vram location for crystal tilemap (10 rows)

TitleCrystalVRAMTbl:
@88ce:  .word   $19ce,$19ee,$1a0e,$1a2e,$1a4e,$1a6e,$1a8e,$1aae
        .word   $1ace,$1aee

; ------------------------------------------------------------------------------
