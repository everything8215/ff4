
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: title_en.asm                                                         |
; |                                                                            |
; | description: title screen (english translation)                            |
; |                                                                            |
; | created: 3/26/2022                                                         |
; +----------------------------------------------------------------------------+

.pushseg

.segment "title_gfx"

        .include "gfx/title_gfx_en.asm"
        .include "gfx/title_bg_tiles_en.asm"
        .include "gfx/title_pal_en.asm"

.popseg

; ------------------------------------------------------------------------------

; [ show title screen ]

ShowTitle:
@85fa:  jsr     ScreenOff
        stz     $420b
        stz     $420c
        lda     #$01        ; spc command $01 (play song)
        sta     $1e00
        lda     #$15        ; song $15 (the prelude)
        sta     $1e01
        jsl     ExecSound_ext
        jsl     InitHWRegs
        lda     #$03
        sta     $1700       ; set map type to $03 (normal)
        lda     #$01
        sta     $212c       ; enable bg1 in main screen
        lda     #$01
        sta     $212d       ; enable bg1 in subscreen
        lda     #$00
        sta     $2130       ; disable color add/sub
        sta     $2131
        lda     #$01
        sta     $2105       ; set screen mode 1
        jsr     ResetSprites
        jsr     LoadTitleGfx
        ldx     #$1800      ; destination = $1800 (vram)
        stx     $47
        ldx     #$0800      ; size = $0800
        stx     $45
        ldx     #.loword(TitleBGTiles)      ; source = $08e000 (splash screen tile data)
        stx     $3d
        jsl     TfrVRAM
        ldx     #0
@864d:  lda     f:TitlePal,x   ; splash screen color palettes
        sta     $0cdb,x
        inx
        cpx     #$0100
        bne     @864d
        lda     #$00
        sta     $2100       ; screen off
        lda     #$81
        sta     $4200       ; enable nmi and joypad
        lda     #$01
        jsr     FadeIn
        lda     #$01
        sta     $54         ; A button reset
        stz     $7a
        lda     #$01        ; short vblank
        sta     $7e
@8673:  jsr     WaitVblankShort
        inc     $7e
        lda     $02
        and     #JOY_A
        bne     @8683       ; branch if a button pressed
        stz     $54         ; clear a button reset
        jmp     @8673
@8683:  lda     $54
        bne     @8673       ; branch if a button hasn't been pressed
        lda     #$01
        jsr     FadeOut
        jsr     ScreenOff
        rts

; ------------------------------------------------------------------------------

; [ load title screen graphics ]

LoadTitleGfx:
@8690:  ldx     #$0000      ; destination = $0000 (vram)
        stx     $47
        ldx     #$2000      ; size = $2000
        stx     $45
        lda     #.bankbyte(TitleGfx);$08        ; source = $08c000 (splash screen graphics)
        sta     $3c
        ldx     #.loword(TitleGfx)
        stx     $3d
        jsl     TfrVRAM
        rts

; ------------------------------------------------------------------------------

; [ clear vram (prologue) ]

ClearPrologueVRAM:
@86a8:  sta     $76
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
