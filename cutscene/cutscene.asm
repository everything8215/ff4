
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: cutscene.asm                                                         |
; |                                                                            |
; | description: solar system and end credits code                             |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

.p816

.include "const.inc"
.include "hardware.inc"
.include "macros.inc"
.include "cutscene_data.asm"

.import ExecSound_ext

.export SolarSystem1_ext, SolarSystem2_ext, EndCredits_ext

; ------------------------------------------------------------------------------

.segment "cutscene_code_ext"

SolarSystem1_ext:
@fff7:  jmp     SolarSystem1

SolarSystem2_ext:
@fffa:  jmp     SolarSystem2

EndCredits_ext:
@fffd:  jmp     EndCredits

; ------------------------------------------------------------------------------

.segment "cutscene_code"

; [ end credits ]

EndCredits:
@d610:  longi
        shorta
        php
        phb
        phd
        lda     #2                      ; cutscene id: 2
        sta     f:$000064
        lda     #$20                    ; cutscene duration: $0a20
        sta     f:$00006a
        lda     #$0a
        sta     f:$00006b
        bra     _d66b

; ------------------------------------------------------------------------------

; [ solar system 2 (moon departs) ]

SolarSystem2:
@d62b:  longi
        shorta
        php
        phb
        phd
        ldx     #$0008
        stx     a:$00a1
        ldx     #$fff2
        stx     a:$00a3
        lda     #1                      ; cutscene id: 1
        sta     f:$000064
        lda     #$80                    ; cutscene duration: $0a80
        sta     f:$00006a
        lda     #$0a
        sta     f:$00006b
        bra     _d66b

; ------------------------------------------------------------------------------

; [ solar system 1 (prophecy) ]

SolarSystem1:
@d652:  longi
        shorta
        php
        phb
        phd
        lda     #0                      ; cutscene id: 0
        sta     f:$000064
        lda     #$e0                    ; cutscene duration: $13e0
        sta     f:$00006a
        lda     #$13
        sta     f:$00006b

_d66b:  jsr     InitHWRegs
        jsr     ClearSprites
        jsr     InitRAM
        jsr     InitSolarSystem
        jsr     LoadMode7Gfx
        jsr     LoadTheEndGfx
        jsr     LoadMode7Tiles
        stz     $95
        ldx     #$8000
        stx     $57
        clr_ax
        stx     $66
        lda     $64
        cmp     #1
        beq     @d6ab
        cmp     #2
        beq     @d69d

; solar system 1 (prophecy)
        jsr     _13d92d
        jsr     InitHDMA
        bra     @d6ab

; end credits
@d69d:  ldx     #$0050
        stx     $96
        jsr     LoadCreditsStarsGfx
        jsr     InitCreditsStars
        jsr     InitHDMA

@d6ab:  stz     $7d1f
        stz     $7d20
        stz     $3303
        inc     $63
@d6b6:  lda     f:hRDNMI
        bpl     @d6b6
        lda     #$11
        sta     $7d28
        sta     f:hTM
        lda     #$81
        sta     f:hNMITIMEN
        jsr     FadeIn
        clr_ax
        stx     a:$0068

; start of frame loop
@d6d3:  jsr     WaitVBlank
        ldx     a:$0068
        inx
        stx     a:$0068
        cpx     a:$006a
        bcc     @d6d3
        lda     $64
        cmp     #2
        bne     @d6eb
        jmp     _13ee07
@d6eb:  jsr     FadeOut
        clr_a
        sta     f:hNMITIMEN
        sta     f:hMDMAEN
        sta     f:hHDMAEN
        lda     #$80
        sta     f:hINIDISP
        pld
        plb
        plp
        rtl

; ------------------------------------------------------------------------------

; [ fade out screen ]

FadeOut:
@d705:  stz     $9a
@d707:  jsr     WaitVBlank
        inc     $9a
        lda     $9a
        and     #$0f
        bne     @d707
        dec     $3303
        bne     @d707
        rts

; ------------------------------------------------------------------------------

; [ fade in screen ]

FadeIn:
@d718:  stz     $9a
@d71a:  jsr     WaitVBlank
        inc     $9a
        lda     $9a
        and     #$0f
        bne     @d71a
        inc     $3303
        lda     $3303
        cmp     #$0f
        bne     @d71a
        rts

; ------------------------------------------------------------------------------

; [ load fancy "THE END" graphics and "A" for square logo ]

LoadTheEndGfx:
@d730:  lda     $64
        cmp     #2
        bne     @d763                   ; return if not end credits
        ldx     #$001b
        stx     hBG1SC
        phb
        clr_a
        pha
        plb
        ldx     #$3000
        stx     hVMADDL
        clr_ax
@d748:  lda     f:TheEndGfx,x
        pha
        and     #$0f
        sta     hVMDATAH
        pla
        and     #$f0
        lsr4
        sta     hVMDATAH
        inx
        cpx     #$0320
        bne     @d748
        plb
@d763:  rts

; ------------------------------------------------------------------------------

; [ load graphics for mode 7 bg ]

LoadMode7Gfx:
@d764:  ldx     #$0000                  ; clear all vram
        ldy     #$8000
        jsr     ClearVRAM
        phb
        clr_a
        pha
        plb
        ldx     #0
        stx     hVMADDL
        stz     $04
        lda     $64
        cmp     #1
        beq     @d7a6
        cmp     #2
        bne     @d787
        lda     #$40
        sta     $04
@d787:  clr_ax
@d789:  lda     f:WindowGfx+1,x         ; convert to mode 7 format
        sta     $00
        ldy     #8
@d792:  asl     $00
        rol
        and     #$01
        sta     hVMDATAH
        dey
        bne     @d792
        inx2
        cpx     #$1000
        bne     @d789
        plb
        rts

; solar system 2 (moon flies away)
@d7a6:  ldx     #$0040
        clr_a
@d7aa:  sta     hVMDATAH
        dex
        bne     @d7aa
        clr_ax
@d7b2:  lda     f:BigMoonGfx,x
        pha
        and     #$0f
        beq     @d7bd
        ora     #$10
@d7bd:  sta     hVMDATAH
        pla
        and     #$f0
        beq     @d7cb
        lsr4
        ora     #$10
@d7cb:  sta     hVMDATAH
        inx
        cpx     #$0800
        bne     @d7b2
        plb
        rts

; ------------------------------------------------------------------------------

; [ draw end credits text ]

DrawCreditsText:
@d7d6:  clr_a
        sta     a:$00a0
        sta     f:hM7SEL
        tax
@d7df:  sta     $7e8000,x
        inx
        cpx     #$8000
        bne     @d7df
        ldx     #$8000
        stx     $7d1b
        ldx     #.loword(CreditsText)
        stx     $7d19
        lda     #^CreditsText
        sta     $7d1e
        lda     #$20
        sta     $7d1d
        jmp     DrawText

; ------------------------------------------------------------------------------

; [ load tilemap for mode 7 bg layer ]

LoadMode7Tiles:
@d802:  lda     $64
        cmp     #1
        beq     @d82e
        cmp     #2
        bne     @d812
        jsr     DrawCreditsText
        jmp     @d85d

; solar system 1 (prophecy)
@d812:  ldx     #$3d1e
        stx     $7d1b
        ldx     #.loword(ProphecyText)
        stx     $7d19
        lda     #^ProphecyText
        sta     $7d1e
        lda     #$80
        sta     $7d1d
        jsr     DrawText
        jmp     @d85d

; solar system 2 (moon flies away)
@d82e:  clr_ax
        ldy     #$3d19
        sty     $06
        lda     #$06
        sta     $02
        lda     #$01
        sta     $04
@d83d:  clr_ay
@d83f:  lda     $04
        sta     ($06),y
        inc     $04
        iny
        inx
        cpy     #$0005
        bne     @d83f
        longa
        lda     $06
        clc
        adc     #$0080
        sta     $06
        shorta0
        dec     $02
        bne     @d83d

@d85d:  clr_a
        sta     f:hVMAINC
        sta     f:hVMADDL
        sta     f:hVMADDH
        tax
@d86b:  lda     $3d19,x
        sta     f:hVMDATAL
        inx
        cpx     #$4000
        bne     @d86b
        lda     #$80
        sta     f:hVMAINC
        rts

; ------------------------------------------------------------------------------

; [  ]

_13d87f:
@d87f:  rol     $2b0a,x
        rol     $2b09,x
        rol     $2b08,x
        rol     $2b07,x
        rol     $2b06,x
        rol     $2b05,x
        rol     $2b04,x
        rol     $2b03,x
        rol     $02
        rts

; ------------------------------------------------------------------------------

; [  ]

_13d89a:
@d89a:  ror     $02
        ror     $2f03,x
        ror     $2f04,x
        ror     $2f05,x
        ror     $2f06,x
        ror     $2f07,x
        ror     $2f08,x
        ror     $2f09,x
        ror     $2f0a,x
        rts

; ------------------------------------------------------------------------------

; [ init solar system data ]

InitSolarSystem:
@d8b5:  jsr     InitStars
        ldx     #.loword(SolarSystemGfx)
        stx     $00
        lda     #^SolarSystemGfx
        sta     $02
        clr_ax
        stx     $0a
@d8c5:  ldy     $0a
        lda     #$20
        sta     $08
@d8cb:  lda     [$00],y
        sta     $2703,x
        longa
        tya
        clc
        adc     #$0020
        tay
        shorta0
        inx
        dec     $08
        bne     @d8cb
        inc     $0a
        lda     $0a
        cmp     #$20
        bne     @d8c5
        rts

; ------------------------------------------------------------------------------

; [ load credits stars graphics ]

LoadCreditsStarsGfx:
@d8e9:  ldx     #$0032
        stx     $00
        ldx     #.loword(CreditsStarsGfx)
        ldy     #$4000
        lda     #^CreditsStarsGfx
        jsr     Tfr3bppGfx
        rts

; ------------------------------------------------------------------------------

; [ transfer 3bbp graphics to vram ]

Tfr3bppGfx:
@d8fa:  phb
        pha
        plb
        sty     hVMADDL
        stx     $02
        ldy     #0
@d905:  longa
        pha
        ldx     #8
@d90b:  lda     ($02),y
        sta     hVMDATAL
        iny2
        dex
        bne     @d90b
        ldx     #8
        pla
        shorta
@d91b:  lda     ($02),y
        sta     hVMDATAL
        stz     hVMDATAH
        iny
        dex
        bne     @d91b
        dec     $00
        bne     @d905
        plb
        rts

; ------------------------------------------------------------------------------

; [  ]

_13d92d:
@d92d:  ldx     #$fe00
        stx     $66
        ldx     #$8000
        stx     $53
        lda     #$7e
        sta     $55
        ldx     #0
@d93e:  phx
        jsr     _13d990
        ldx     #$2f03
        stx     $00
        clr_ax
        stx     $0a
@d94b:  ldy     $0a
        lda     #$20
        sta     $08
@d951:  lda     ($00),y
        sta     [$53]
        longa
        inc     $53
        tya
        clc
        adc     #$0020
        tay
        shorta0
        inx
        dec     $08
        bne     @d951
        inc     $0a
        lda     $0a
        cmp     #$20
        bne     @d94b
        plx
        inx
        cpx     #$0020
        bne     @d93e
        rts

; ------------------------------------------------------------------------------

; [  ]

_13d977:
@d977:  rol     $270a,x
        rol     $2709,x
        rol     $2708,x
        rol     $2707,x
        rol     $2706,x
        rol     $2705,x
        rol     $2704,x
        rol     $2703,x
        rts

; ------------------------------------------------------------------------------

; [  ]

_13d990:
@d990:  clr_ax
        stx     $00
        stz     $0a
@d996:  lda     $2703,x
        asl
        jsr     _13d977
        jsr     _13d977
        longa
        lda     $2703,x
        sta     $2b03,x
        lda     $2705,x
        sta     $2b05,x
        lda     $2707,x
        sta     $2b07,x
        lda     $2709,x
        sta     $2b09,x
        stz     $2f03,x
        stz     $2f05,x
        stz     $2f07,x
        stz     $2f08,x
        shorta0
        phx
        lda     $00
        clc
        adc     $01
        tax
        clr_ay
@d9d2:  lda     f:_13df57,x
        sta     $0042,y
        inx
        iny
        cpy     #8
        bne     @d9d2
        plx
        lda     #$30
        sta     $04
@d9e5:  jsr     _13d87f
        asl     $47
        rol     $46
        rol     $45
        rol     $44
        rol     $43
        rol     $42
        bcc     @d9f9
        jsr     _13d89a
@d9f9:  dec     $04
        bne     @d9e5
        phx
        lda     $00
        lsr3
        sta     $04
        lda     $01
        lsr3
        clc
        adc     $04
        and     #$1f
        tax
        lda     f:_13e4f2,x
        beq     @da36
        plx
        sta     $04
@da19:  lsr     $2f03,x
        ror     $2f04,x
        ror     $2f05,x
        ror     $2f06,x
        ror     $2f07,x
        ror     $2f08,x
        ror     $2f09,x
        ror     $2f0a,x
        dec     $04
        bne     @da19
        phx
@da36:  lda     $00
        clc
        adc     #$40
        sta     $00
        inc     $0a
        lda     $0a
        and     #$07
        bne     @da4c
        lda     $01
        clc
        adc     #$08
        sta     $01
@da4c:  lda     $0a
        and     #$3f
        bne     @da54
        stz     $01
@da54:  plx
        longa
        txa
        clc
        adc     #$0008
        tax
        shorta0
        cpx     #$0400
        beq     @da68
        jmp     @d996
@da68:  rts

; ------------------------------------------------------------------------------

; [ draw planet/sun sprite ]

DrawOtherPlanet:
@da69:  asl
        sta     $52                     ; set sprite palette
        bra     _da70

DrawSolarSystemSprite:
@da6e:  stz     $52                     ; use sprite palette 0

_da70:  lda     $4f
        longa
        asl2
        tax
        lda     $50
        and     #$00ff
        asl2
        tay
        shorta0
        lda     $50
        sta     $30
@da86:  lda     f:SolarSystemSpriteTbl,x
        sta     $28
        stz     $29
        lda     f:SolarSystemSpriteTbl+1,x
        clc
        adc     $4d
        sta     $0301,y
        longa
        lda     $28
        clc
        adc     $4b
        and     #$01ff
        sta     $28
        shorta0
        lda     $28
        sta     $0300,y
        lda     f:SolarSystemSpriteTbl+2,x
        sta     $0302,y
        lda     $52
        beq     @dac1
        lda     f:SolarSystemSpriteTbl+3,x
        and     #$f1
        ora     $52
        bra     @dac5
@dac1:  lda     f:SolarSystemSpriteTbl+3,x
@dac5:  sta     $0303,y
        phx
        lda     $30
        lsr2
        sta     $2c
        lda     $30
        and     #$03
        sta     $2e
        tax
        lda     f:LargeSpriteAndTbl,x
        sta     $2d
        lda     $2e
        beq     @dae8
@dae0:  asl     $29
        asl     $29
        dec     $2e
        bne     @dae0
@dae8:  lda     $2c
        tax
        lda     $0500,x
        and     $2d
        ora     $29
        sta     $0500,x
        plx
        inc     $30
        inc     $4f
        inc     $50
        inx4
        iny4
        dec     $51
        beq     @db0b
        jmp     @da86
@db0b:  rts

; ------------------------------------------------------------------------------

LargeSpriteAndTbl:
@db0c:  .byte   $fc,$f3,$cf,$3f

; ------------------------------------------------------------------------------

; [  ]

_13db10:
@db10:  ldx     #$0008
        stx     $2080
        stx     $2082
        ldx     #$0010
        stx     $20c0
        stx     $20c2
        rts

; ------------------------------------------------------------------------------

; [  ]

_13db23:
@db23:  ldx     #$0020
        stx     $2080
        stx     $2082
        ldx     #$0040
        stx     $20c0
        stx     $20c2
        rts

; ------------------------------------------------------------------------------

HDMATbl:
; M7A and M7B
@db36:  .byte   $f0
        .word   $3319
        .byte   $f0
        .word   $34d9
        .byte   $00

; M7C and M7D
        .byte   $f0
        .word   $3719
        .byte   $f0
        .word   $38d9
        .byte   $00

; BG1VOFS and BG2HOFS (unused)
        .byte   $f0
        .word   $3b19
        .byte   $f0
        .word   $3bf9
        .byte   $00

; ------------------------------------------------------------------------------

; [ init hdma for scrolling text ]

InitHDMA:
@db4b:  clr_ax
@db4d:  lda     f:HDMATbl,x
        sta     $3304,x
        inx
        cpx     #$0015
        bne     @db4d
        phb
        clr_a
        pha
        plb
        lda     #$43
        sta     $4300
        sta     $4310
        lda     #$42
        sta     $4320
        lda     #<hM7A
        sta     $4301
        lda     #<hM7C
        sta     $4311
        lda     #<hBG1VOFS              ; channel 2 is never enabled
        sta     $4321
        ldx     #$3304
        stx     $4302
        ldx     #$330b
        stx     $4312
        ldx     #$3312
        stx     $4322
        lda     #$7e
        sta     $4304
        sta     $4307
        sta     $4314
        sta     $4317
        sta     $4324
        sta     $4327
        lda     #$03
        sta     hHDMAEN
        plb
        rts

; ------------------------------------------------------------------------------

_13dba7:
@dba7:  .byte   $00,$e0

; ------------------------------------------------------------------------------

; [  ]

_13dba9:
@dba9:  lda     $4a
        lsr
        and     #$01
        tax
        lda     f:_13dba7,x
        tax
        clr_ay
@dbb6:  lda     f:SolarSystemPal,x
        sta     $2203,y
        inx
        iny
        cpy     #$0020
        bne     @dbb6
        lda     $4a
        and     #$07
        bne     @dbe7
        longa
        lda     $22c1
        pha
        ldx     #$001c
@dbd3:  lda     $22a3,x
        sta     $22a5,x
        dex2
        cpx     #$0012
        bne     @dbd3
        pla
        sta     $22b7
        shorta0
@dbe7:  rts

; ------------------------------------------------------------------------------

; [ set zoom hdma data ]

SetZoomHDMA:
@dbe8:  phx
        longa
        txa
        ldx     #0
@dbef:  sta     $3319,x
        sta     $371b,x
        stz     $331b,x
        stz     $3719,x
        inx4
        cpx     #$0400
        bne     @dbef
        shorta0
        plx
        rts

; ------------------------------------------------------------------------------

; [ init ram ]

InitRAM:
@dc09:  stz     $7d25
        ldx     #$0080
        stx     $08
        stx     $0a
        ldx     #$0100
        stx     $00
        stx     $06
        ldx     #$0100                  ; zoom 1:1
        jsr     SetZoomHDMA
        longa
        clr_ax
        ldy     #$0280
@dc27:  lda     $00
        sta     $3319,y
        lda     $06
        sta     $371b,y
        lda     $00
        sec
        sbc     #$0002
        sta     $00
        lda     $06
        sec
        sbc     #$0001
        sta     $06
        tya
        clc
        adc     #$0004
        tay
        inx
        cpy     #$0400
        bne     @dc27
        lda     $64
        and     #$00ff
        tax
        cpx     #2
        beq     @dc7b                   ; branch if end credits
        ldy     #$0280
        ldx     #$0104
@dc5e:  lda     $3319,y
        sta     $3319,x
        lda     $371b,y
        sta     $371b,x
        txa
        sec
        sbc     #$0004
        tax
        tya
        clc
        adc     #$0004
        tay
        cpy     #$0400
        bne     @dc5e
@dc7b:  shorta0
        lda     $64
        cmp     #1
        beq     @dc92                   ; branch if solar system 2
        ldx     #$0080
        stx     a:$008c
        stx     a:$008e
        ldx     #$0100
        bra     @dca0
@dc92:  clr_ax
        stx     a:$008c
        ldx     #$0020
        stx     a:$008e
        ldx     #$0a00
@dca0:  stx     a:$0061
        clr_ax
        stx     $40
        stx     $5d
        stx     $5f
        sta     $63
        sta     $4a
        sta     a:$005b
        ldx     #$1000
        stx     $92
        ldx     #$8000
        stx     $90
        clr_ax
@dcbe:  lda     $64
        cmp     #2
        bne     @dcca
        lda     f:CreditsPal,x
        bra     @dcce
@dcca:  lda     f:SolarSystemPal,x
@dcce:  sta     $2103,x
        sta     $2203,x
        inx
        cpx     #$0100
        bne     @dcbe
        stz     $2100
        ldx     #$1000
        stx     $00
        ldx     #.loword(SolarSystemGfx)
        ldy     #$4000
        lda     #^SolarSystemGfx
        jsr     _13ddd6
        ldx     #$0070
        stx     $6c
        ldx     #$0050
        stx     $6e
        ldx     #$0070
        stx     $70
        ldx     #$0050
        stx     $72
        jsr     _13db23
        jsr     _13e122
        ldx     #$0040
        stx     $2084
        ldx     #$0180
        stx     $20c4
        ldx     #$0040
        stx     $208a
        ldx     #$00c0
        stx     $20ca
        ldx     #$0180
        stx     $200a
        ldx     #$0300
        stx     $204a
        ldx     #$0018
        stx     $2086
        ldx     #$0100
        stx     $20c6
        ldx     #$0008
        stx     $2088
        ldx     #$00a0
        stx     $20c8
        ldx     #$0000
        ldy     #$0100
        jsr     _13e10c
        ldx     #$0002
        ldy     #$0000
        jsr     _13e10c
        ldx     #$0004
        ldy     #$0100
        jsr     _13e10c
        ldx     #$0006
        ldy     #$0154
        jsr     _13e10c
        ldx     #$0008
        ldy     #$02f4
        jsr     _13e10c
        jsr     _13dd7f
        clr_ax
@dd75:  sta     $3d19,x
        inx
        cpx     #$4000
        bne     @dd75
        rts

; ------------------------------------------------------------------------------

; [  ]

_13dd7f:
@dd7f:  ldx     #$0000
        ldy     #$0008
        jsr     _13ddbb
        ldx     #$0002
        ldy     #$000c
        jsr     _13ddbb
        ldx     #$0004
        ldy     #$0010
        jsr     _13ddbb
        ldx     #$0006
        ldy     #$0014
        jsr     _13ddbb
        ldx     #$0008
        ldy     #$0018
        jsr     _13ddbb
        lda     a:$005b
        beq     @ddba
        ldx     #$000a
        ldy     #$001c
        jsr     _13ddbb
@ddba:  rts

; ------------------------------------------------------------------------------

; [  ]

_13ddbb:
@ddbb:  jsr     _13e578
        longa
        lda     $1e
        sta     a:$006c,y
        shorta0
        jsr     _13e565
        longa
        lda     $1e
        sta     a:$006e,y
        shorta0
        rts

; ------------------------------------------------------------------------------

; [ transfer graphics to vram ]

;  A: source bank
; +X: source address
; +Y: destination address

_13ddd6:
@ddd6:  phb
        pha
        clr_a
        pha
        plb
        pla
        sty     hVMADDL
        stx     $4352
        sta     $4354
        lda     #$01
        sta     $4350
        lda     #<hVMDATAL
        sta     $4351
        ldx     $00
        stx     $4355
        lda     #$20
        sta     hMDMAEN
        plb
        rts

; ------------------------------------------------------------------------------

; [ clear sprite data ]

ClearSprites:
@ddfb:  ldx     #$0220
        clr_a
@ddff:  sta     $02ff,x
        dex
        bne     @ddff
        rts

; ------------------------------------------------------------------------------

; [ reset sprite data ]

ResetSprites:
@de06:  clr_ax
        lda     #$f0
@de0a:  sta     $0300,x
        inx
        cpx     #$0118
        bne     @de0a
        rts

; ------------------------------------------------------------------------------

; [ init hardware registers ]

InitHWRegs:
@de14:  lda     #$00
        sta     hNMITIMEN
        pha
        plb
        ldx     #$0000
        phx
        pld
        lda     #$80
        sta     hINIDISP
        lda     #$07
        sta     hBGMODE
        ldx     #$0300
        stx     hOAMADDL
        lda     #$80
        sta     a:$00a0
        sta     hM7SEL
        lda     #$02
        sta     hOBJSEL
        lda     #$00
        sta     hBG12NBA
        sta     hBG34NBA
        lda     #$80
        sta     hVMAINC
        clr_ax
        sta     hM7A
        sta     hM7A
        sta     hM7B
        sta     hM7B
        sta     hM7C
        sta     hM7C
        sta     hM7D
        sta     hM7D
        sta     hM7X
        sta     hM7X
        sta     hM7Y
        sta     hM7Y
        sta     hMOSAIC
        sta     hBG1SC
        sta     hBG2SC
        sta     hBG3SC
        sta     hBG4SC
        sta     hBG1HOFS
        sta     hBG1HOFS
        sta     hBG1VOFS
        sta     hBG1VOFS
        sta     hBG2HOFS
        sta     hBG2HOFS
        sta     hBG2VOFS
        sta     hBG2VOFS
        sta     hBG3HOFS
        sta     hBG3HOFS
        sta     hBG3VOFS
        sta     hBG3VOFS
        sta     hBG4HOFS
        sta     hBG4HOFS
        sta     hBG4VOFS
        sta     hBG4VOFS
        sta     hWH2
        sta     hWH3
        stx     hWBGLOG
        sta     hTM
        sta     hTS
        sta     hTMW
        sta     hTSW
        sta     hMDMAEN
        sta     hHDMAEN
        sta     hCGADSUB
        sta     hSETINI
        sta     hCGSWSEL
        stx     a:$008c
        stx     a:$008e
        lda     #$08
        sta     hWH0
        lda     #$ff
        sta     hWH1
        lda     #$11
        sta     hTM
        sta     hTMW
        lda     #$33
        sta     hW12SEL
        sta     hW34SEL
        sta     hWOBJSEL
        lda     #^CutsceneNMI
        sta     $0203
        ldx     #.loword(CutsceneNMI)
        stx     $0201
        lda     #^CutsceneIRQ
        sta     $0207
        ldx     #.loword(CutsceneIRQ)
        stx     $0205
        lda     #$5c                    ; jml
        sta     $0200
        sta     $0204
        lda     #$7e
        pha
        plb
        rts

; ------------------------------------------------------------------------------

; [ clear vram ]

; +X: start address
; +Y: size

ClearVRAM:
@df19:  phb
        clr_a
        pha
        plb
        stx     hVMADDL
        ldx     #.loword(@Zero)
        stx     $4352
        lda     #$09
        sta     $4350
        lda     #<hVMDATAL
        sta     $4351
        lda     #^@Zero
        sta     $4354
        sty     $4355
        lda     #$20
        sta     hMDMAEN
        plb
        rts

@Zero:
@df3f:  .word   0

; ------------------------------------------------------------------------------

; [ wait for vblank ]

WaitVBlank:
@df41:  phx
        inc     $41
@df44:  lda     $41
        bne     @df44
        jsr     _13df4d
        plx
        rts

; ------------------------------------------------------------------------------

; [  ]

_13df4d:
@df4d:  lda     $64
        cmp     #2
        bne     @df56
        jsr     _13ec81
@df56:  rts

; ------------------------------------------------------------------------------

_13df57:
@df57:  .byte   $40,$02,$08,$20,$01,$00,$00,$00
        .byte   $88,$21,$1c,$42,$08,$80,$00,$00
        .byte   $a2,$22,$3e,$22,$22,$80,$00,$00
        .byte   $92,$49,$3e,$49,$24,$80,$00,$00
        .byte   $a4,$92,$ff,$a4,$92,$80,$00,$00
        .byte   $a4,$95,$ff,$d4,$92,$80,$00,$00
        .byte   $a4,$95,$ff,$d4,$92,$80,$00,$00
        .byte   $a4,$ab,$ff,$ea,$92,$80,$00,$00
        .byte   $a4,$af,$ff,$fa,$92,$80,$00,$00
        .byte   $a4,$af,$ff,$fa,$92,$80,$00,$00
        .byte   $a4,$bf,$ff,$fe,$92,$80,$00,$00
        .byte   $a4,$bf,$ff,$fe,$92,$80,$00,$00
        .byte   $a4,$bf,$ff,$fe,$92,$80,$00,$00
        .byte   $c9,$7f,$ff,$ff,$49,$80,$00,$00
        .byte   $c9,$7f,$ff,$ff,$49,$80,$00,$00
        .byte   $c9,$7f,$ff,$ff,$49,$80,$00,$00
        .byte   $c9,$7f,$ff,$ff,$49,$80,$00,$00
        .byte   $c9,$7f,$ff,$ff,$49,$80,$00,$00
        .byte   $c9,$7f,$ff,$ff,$49,$80,$00,$00
        .byte   $a4,$bf,$ff,$fe,$92,$80,$00,$00
        .byte   $a4,$bf,$ff,$fe,$92,$80,$00,$00
        .byte   $a4,$bf,$ff,$fe,$92,$80,$00,$00
        .byte   $a4,$af,$ff,$fa,$92,$80,$00,$00
        .byte   $a4,$af,$ff,$fa,$92,$80,$00,$00
        .byte   $a4,$ab,$ff,$ea,$92,$80,$00,$00
        .byte   $a4,$95,$ff,$d4,$92,$80,$00,$00
        .byte   $a4,$95,$ff,$d4,$92,$80,$00,$00
        .byte   $a4,$92,$ff,$a4,$92,$80,$00,$00
        .byte   $92,$49,$3e,$49,$24,$80,$00,$00
        .byte   $a2,$22,$3e,$22,$22,$80,$00,$00
        .byte   $88,$21,$1c,$42,$08,$80,$00,$00
        .byte   $40,$02,$08,$20,$01,$00,$00,$00

; ------------------------------------------------------------------------------

; [ cutscene irq ]

; *** bug *** unused, but should be rti

CutsceneIRQ:
@e057:  rtl

; ------------------------------------------------------------------------------

; [  ]

_13e058:
@e058:  phb
        pha
        clr_a
        pha
        plb
        pla
        sty     hVMADDL
        stx     $4342
        sta     $4344
        lda     #$01
        sta     $4340
        lda     #<hVMDATAL
        sta     $4341
        ldx     $28
        stx     $4345
        lda     #$10
        sta     hMDMAEN
        plb
        rts

; ------------------------------------------------------------------------------

; [  ]

_13e07d:
@e07d:  lda     $4a
        and     #$0f
        bne     @e0a5
        ldx     #$0400
        stx     $28
        ldx     $57
        ldy     #$4000
        lda     #$7e
        jsr     _13e058
        longa
        lda     $57
        clc
        adc     #$0400
        and     #$7fff
        ora     #$8000
        sta     $57
        shorta0
@e0a5:  rts

; ------------------------------------------------------------------------------

; [ transfer color palettes to ppu ]

TfrPal:
@e0a6:  phb
        clr_a
        pha
        plb
        sta     hCGADD
        ldx     #$2202
        stx     $4340
        ldx     #$2103
        stx     $4342
        lda     #$7e
        sta     $4344
        ldx     #$0200
        stx     $4345
        lda     #$10
        sta     hMDMAEN
        plb
        rts

; ------------------------------------------------------------------------------

; [ transfer sprite data to ppu ]

TfrSprites:
@e0cb:  phb
        clr_a
        pha
        plb
        tax
        stx     hOAMADDL
        ldx     #$0400
        stx     $4340
        ldx     #$0300
        stx     $4342
        clr_a
        sta     $4344
        sta     $4347
        ldx     #$0220
        stx     $4345
        lda     #$10
        sta     hMDMAEN
        plb
        rts

; ------------------------------------------------------------------------------

; [ multiply (8-bit) ]

; unused

MultHW:
@e0f3:  phx
        lda     $18
        sta     f:hWRMPYA
        lda     $1a
        sta     f:hWRMPYB
        phb
        clr_a
        pha
        plb
        ldx     hRDMPYL
        stx     $1c
        plb
        plx
        rts

; ------------------------------------------------------------------------------

; [  ]

_13e10c:
@e10c:  longa
        tya
        clc
        adc     $2000,x
        sta     $2000,x
        tya
        clc
        adc     $2040,x
        sta     $2040,x
        shorta0
        rts

; ------------------------------------------------------------------------------

; [  ]

_13e122:
@e122:  clr_ax
        lda     #$80
        longa
@e128:  stz     $2000,x
        sta     $2040,x
        inx2
        cpx     #$0040
        bne     @e128
        shorta0
        rts

; ------------------------------------------------------------------------------

; [ get the position of the earth sprite ]

GetEarthSpritePos:
@e139:  longa
        lda     $6c
        clc
        adc     $7c
        sta     $4b
        lda     $6e
        clc
        adc     $7e
        sta     $4d
        shorta0
        rts

; ------------------------------------------------------------------------------

; [ update earth ]

UpdateEarth:
@e14d:  lda     $2100
        beq     @e161

; earth behind sun
        jsr     GetEarthSpritePos
        lda     #$4c                    ; small earth
        sta     $4f
        lda     #$04
        sta     $51
        jsr     DrawSolarSystemSprite
        rts

; earth in front of sun
@e161:  jsr     GetEarthSpritePos
        lda     #$52                    ; big earth outline
        sta     $4f
        lda     #$0f
        sta     $51
        jsr     DrawSolarSystemSprite
        jsr     GetEarthSpritePos
        stz     $4f                     ; big earth texture
        lda     #$10
        sta     $51
        jsr     DrawSolarSystemSprite
        rts

; ------------------------------------------------------------------------------

; [ update sun ]

UpdateSun:
@e17c:  lda     $4a
        and     #$07
        beq     @e195
        ldx     $70
        stx     $4b
        ldx     $72
        stx     $4d
        lda     #$30
        sta     $4f
        lda     #$18
        sta     $51
        jsr     DrawSolarSystemSprite
@e195:  rts

; ------------------------------------------------------------------------------

; [ update the two smaller planets ]

UpdateOtherPlanets:
@e196:  ldx     #$0006
        jsr     GetOtherPlanetTile
        longa
        lda     $80
        clc
        adc     $70
        sta     $4b
        lda     $82
        clc
        adc     $72
        adc     #$000c
        sta     $4d
        shorta0
        lda     #$04
        sta     $51
        lda     #$02
        jsr     DrawOtherPlanet
        ldx     #$0008
        jsr     GetOtherPlanetTile
        longa
        lda     $84
        clc
        adc     $70
        sta     $4b
        lda     $86
        clc
        adc     $72
        adc     #$000c
        sta     $4d
        shorta0
        lda     #$04
        sta     $51
        lda     #$03
        jsr     DrawOtherPlanet
        rts

; ------------------------------------------------------------------------------

; [ update the moon that flies away ]

UpdateMoon1:
@e1e1:  ldx     #$0000
        jsr     GetMoonTile
        longa
        lda     $74
        clc
        adc     $6c
        adc     $7c
        adc     #$0008
        sta     $4b
        lda     $76
        clc
        adc     $6e
        adc     $7e
        adc     #$0008
        sta     $4d
        shorta0
        lda     #$04
        sta     $51
        lda     a:$005b
        beq     @e243
        longa
        lda     $70
        clc
        adc     $88
        eor     #$ffff
        sec
        sbc     $a1
        sta     $5d
        lda     $72
        clc
        adc     $8a
        eor     #$ffff
        sec
        sbc     $a3
        sta     $5f
        shorta0
        ldx     a:$0061
        cpx     #$0004
        bcc     @e242
        dex3
        stx     a:$0061
        ldx     $20c0
        inx2
        stx     $20c0
@e242:  rts
@e243:  jsr     DrawSolarSystemSprite
        rts

; ------------------------------------------------------------------------------

; [ init solar system background stars ]

InitStars:
@e247:  lda     #$48                    ; use sprites 72-127
        sta     $50
        clr_ax
@e24d:  inc     $7d27
        pha
        phx
        lda     f:RNGTbl,x
        tay
        sty     $4b
        tax
        lda     f:RNGTbl,x
        tay
        sty     $4d
        tya
        lda     $7d27
        and     #$07
        beq     @e26b
        lda     #1                      ; every 8th sprite is a big star
@e26b:  clc
        adc     #$50
        sta     $4f
        lda     #$01
        sta     $51
        jsr     DrawSolarSystemSprite
        plx
        inx2
        pla
        inc
        cmp     #$38                    ; draw 56 stars (i only see about 48)
        bne     @e24d
        rts

; ------------------------------------------------------------------------------

; [ update the normal moon ]

UpdateMoon2:
@e281:  ldx     #$0002
        jsr     GetMoonTile
        longa
        lda     $78
        clc
        adc     $6c
        adc     $7c
        adc     #$0008
        sta     $4b
        lda     $7a
        clc
        adc     $6e
        adc     $7e
        adc     #$0008
        sta     $4d
        shorta0
        lda     #$04
        sta     $51
        jsr     DrawSolarSystemSprite
        rts

; ------------------------------------------------------------------------------

MoonTileTbl:
@e2ac:  .byte   4,3,2,1,0,1,2,3,4,5,6,7,7,7,6,5
        .byte   7,6,6,6,6,6,6,6,7,7,7,7,7,7,7,7

OtherPlanetTileTbl:
@e2cc:  .byte   5,4,4,3,2,3,4,4,5,5,6,6,7,6,6,5

; ------------------------------------------------------------------------------

; [ get tile id for other planets and moons ]

GetOtherPlanetTile:
@e2dc:  lda     #$20
        sta     $28
        bra     _e2ed

GetMoonTile:
@e2e2:  stz     $28
        lda     $2100
        beq     _e2ed
        lda     #$10
        sta     $28
_e2ed:  longa
        lda     $2000,x
        and     #$01ff
        lsr5
        sta     $2a
        shorta0
        lda     $2a
        clc
        adc     $28
        tax
        lda     f:MoonTileTbl,x
        asl2
        clc
        adc     #$10
        sta     $4f
        rts

; ------------------------------------------------------------------------------

; [ update solar system sprites ]

UpdateSolarSystemSprites:
@e311:  stz     $2101
        stz     $2102
        stz     $50
        lda     $2005
        and     #$01
        sta     $2100
        lda     $2001
        and     #$01
        bne     @e32e
        jsr     UpdateMoon1
        inc     $2101
@e32e:  lda     $2003
        and     #$01
        bne     @e33b
        jsr     UpdateMoon2
        inc     $2102
@e33b:  jsr     UpdateEarth
        lda     $2101
        bne     @e346
        jsr     UpdateMoon1
@e346:  lda     $2102
        bne     @e34e
        jsr     UpdateMoon2
@e34e:  lda     $2007
        and     #$01
        beq     @e35d
        jsr     UpdateSun
        jsr     UpdateOtherPlanets
        bra     @e363
@e35d:  jsr     UpdateOtherPlanets
        jsr     UpdateSun
@e363:  lda     $2100
        bne     @e36d
        jsr     _13db23
        bra     @e370
@e36d:  jsr     _13db10
@e370:  jsr     _13dd7f
        ldx     #$0000
        ldy     #$ffff
        jsr     _13e10c
        ldx     #$0002
        ldy     #$ffff
        jsr     _13e10c
        lda     $2100
        tax
        lda     f:_13e3b1,x
        sta     $28
        lda     $4a
        and     $28
        bne     @e3b0
        ldx     #$0004
        ldy     #$ffff
        jsr     _13e10c
        ldx     #$0006
        ldy     #$ffff
        jsr     _13e10c
        ldx     #$0008
        ldy     #$ffff
        jsr     _13e10c
@e3b0:  rts

; ------------------------------------------------------------------------------

_13e3b1:
@e3b1:  .byte   $03,$07

; ------------------------------------------------------------------------------

; [ cutscene nmi ]

CutsceneNMI:
@e3b3:  php
        longai
        pha
        phx
        phy
        phb
        phd
        ldx     #$0000
        phx
        pld
        shorta0
        lda     f:hRDNMI
        lda     #$7e
        pha
        plb
        lda     $40
        beq     @e3d2
        jmp     @e4e9
@e3d2:  inc     $40
        lda     $3303
        sta     f:hINIDISP
        lda     $a0
        sta     f:hM7SEL
        lda     $7d28
        sta     f:hTM
        lda     $64
        cmp     #1
        beq     @e449
        lda     $4a
        and     #$03
        beq     @e3f7
        jmp     @e495
@e3f7:  lda     $66
        sta     f:hBG1VOFS
        lda     $67
        sta     f:hBG1VOFS
        lda     $8c
        sta     f:hM7X
        lda     $8d
        sta     f:hM7X
        lda     $8e
        sta     f:hM7Y
        lda     $8f
        sta     f:hM7Y
        lda     $7d1f
        bne     @e495
        lda     $64
        beq     @e431
        longa
        lda     $66
        inc
        cmp     #$0400
        bne     @e43c
        clr_a
        bra     @e43c
@e431:  longa
        lda     $66
        inc
        cmp     #$0400
        bne     @e43c
        dec
@e43c:  sta     $66
        clc
        adc     #$0080
        sta     $8e
        shorta0
        bra     @e495
@e449:  lda     a:$0061
        sta     f:hM7A
        lda     a:$0062
        sta     f:hM7A
        lda     a:$0061
        sta     f:hM7D
        lda     a:$0062
        sta     f:hM7D
        lda     $5d
        sta     f:hBG1HOFS
        lda     $5e
        sta     f:hBG1HOFS
        lda     $5f
        sta     f:hBG1VOFS
        lda     $60
        sta     f:hBG1VOFS
        lda     $8c
        sta     f:hM7X
        lda     $8d
        sta     f:hM7X
        lda     $8e
        sta     f:hM7Y
        lda     $8f
        sta     f:hM7Y
@e495:  jsr     TfrSprites
        jsr     TfrPal
        lda     $64
        cmp     #2
        bne     @e4aa

; end credits
        jsr     _13ebb8
        jsr     DrawCreditsStars
        jmp     @e4c7

; solar system
@e4aa:  jsr     _13e07d
        jsr     ResetSprites
        jsr     _13dba9
        jsr     UpdateSolarSystemSprites
        lda     $64
        beq     @e4c7
        ldx     $2004
        cpx     #$ff80
        bne     @e4c7
        lda     #$01
        sta     a:$005b

@e4c7:  lda     a:$005b
        beq     @e4db
        lda     $4a
        and     #$03
        bne     @e4db
        ldx     #$000a
        ldy     #$0001
        jsr     _13e10c
@e4db:  lda     $7d25
        beq     @e4e3
        jsr     _13ef19
@e4e3:  stz     $40
        stz     $41
        inc     $4a
@e4e9:  longai
        pld
        plb
        ply
        plx
        pla
        plp
        rti

.a8
.i16

; ------------------------------------------------------------------------------

_13e4f2:
@e4f2:  .byte   13,10,8,7,5,4,4,3,2,2,1,1,1,0,0,0
        .byte   0,0,0,1,1,1,2,2,3,4,4,5,7,8,10,13

; ------------------------------------------------------------------------------

; [ 16-bit multiply ]

; +++$12 = +$0e * +$10

Mult16_1:
@e512:  phx
        longa
        pha
        stz     $16
        stz     $12
        stz     $14
        ldx     #$0010
@e51f:  lsr     $0e
        bcc     @e530
        clc
        lda     $12
        adc     $10
        sta     $12
        lda     $14
        adc     $16
        sta     $14
@e530:  asl     $10
        rol     $16
        dex
        bne     @e51f
        pla
        shorta
        plx
        rts

; ------------------------------------------------------------------------------

; [ 16-bit multiply ]

; +++$1c = +$18 * +$1a

Mult16_2:
@e53c:  phx
        longa
        stz     $20
        stz     $1c
        stz     $1e
        ldx     #$0010
@e548:  lsr     $18
        bcc     @e559
        clc
        lda     $1c
        adc     $1a
        sta     $1c
        lda     $1e
        adc     $20
        sta     $1e
@e559:  asl     $1a
        rol     $20
        dex
        bne     @e548
        shorta0
        plx
        rts

; ------------------------------------------------------------------------------

; [  ]

_13e565:
@e565:  phx
        longa
        lda     $2080,x
        sta     $18
        lda     $2000,x
        jsr     _13e58b
        shorta0
        plx
        rts

; ------------------------------------------------------------------------------

; [  ]

_13e578:
@e578:  phx
        longa
        lda     $20c0,x
        sta     $18
        lda     $2040,x
        jsr     _13e58b
        shorta0
        plx
        rts

; ------------------------------------------------------------------------------

; [  ]

_13e58b:
@e58b:  longa
        and     #$01ff
        asl
        tax
        lda     f:SolarSystemSineTbl,x
        bpl     @e5b1
        eor     #$ffff
        sta     $1a
        jsr     Mult16_2
        longa
        lda     $1e
        eor     #$ffff
        inc
        bpl     @e5be
@e5aa:  sta     $1e
        shorta0
        sec
        rts
@e5b1:  longa
        sta     $1a
        jsr     Mult16_2
        longa
        lda     $1e
        bmi     @e5aa
@e5be:  sta     $1e
        shorta0
        clc
        rts

; ------------------------------------------------------------------------------

; sine table
@e5c5:  .include "data/solar_system_sine.asm"
@e9c5:  .include .sprintf("text/prophecy_text_%s.asm", LANG_SUFFIX)

; ------------------------------------------------------------------------------

; [ draw text ]

DrawText:
@eacd:  ldx     $7d19
        stx     $36
        lda     $7d1e
        sta     $38
        ldx     $7d1b
        stx     $39
        lda     $39
        clc
        adc     $7d1d
        sta     $3c
        lda     $3a
        adc     #$00
        sta     $3d
        clr_ay
@eaec:  lda     [$36]
        beq     @eb04                   ; branch if null-terminator
        cmp     #$0f
        bcc     @eafc
        jsr     DrawLetter
        jsr     IncTextPtr
        bra     @eaec
@eafc:  jsr     DoTextCmd
        jsr     IncTextPtr
        bra     @eaec
@eb04:  rts

; ------------------------------------------------------------------------------

; [ do text command ]

DoTextCmd:
@eb05:  cmp     #$01
        beq     @eb21
        cmp     #$0a
        bne     @eb10

; $0a: period "."
        jmp     DrawLetterNoDakuten

; $02: tab (next byte is how many spaces)
@eb10:  jsr     IncTextPtr
        lda     [$36]
        sta     $00
@eb17:  lda     #$ff                    ; draw a space
        jsr     DrawLetterNoDakuten
        dec     $00
        bne     @eb17
        rts

; $01: newline
@eb21:  jmp     NewLine

; ------------------------------------------------------------------------------

; [ new line of text ]

NewLine:
@eb24:  lda     $7d1d
        longa
        pha
        asl
        clc
        adc     $39
        sta     $39
        pla
        clc
        adc     $39
        sta     $3c
        clr_ay
        shorta
        rts

; ------------------------------------------------------------------------------

; [ increment pointer to text ]

IncTextPtr:
@eb3b:  ldx     $36
        inx
        stx     $36
        rts

; ------------------------------------------------------------------------------

; [ draw letter ]

DrawLetter:
@eb41:  cmp     #$42
        bcc     _eb4d

DrawLetterNoDakuten:
@eb45:  sta     ($3c),y
        lda     #$ff
        sta     ($39),y
        iny
        rts

_eb4d:  sec
        sbc     #$0f
        asl
        tax
        lda     f:DakutenTbl,x          ; dakuten
        sta     ($39),y
        lda     f:DakutenTbl+1,x        ; kana
        sta     ($3c),y
        iny
        rts

; ------------------------------------------------------------------------------

; [  ]

_13eb60:
@eb60:  lda     $7d20
        beq     @ebb7
        phb
        clr_a
        pha
        plb
        lda     #$00
        sta     hVMAINC
        ldx     $92
        stx     hVMADDL
        ldx     $90
        stx     $4352
        lda     #$7e
        sta     $4354
        lda     #$00
        sta     $4350
        lda     #<hVMDATAL
        sta     $4351
        ldx     #$0100
        stx     $4355
        lda     #$20
        sta     hMDMAEN
        lda     #$80
        sta     hVMAINC
        plb
        longa
        lda     $90
        clc
        adc     #$0100
        sta     $90
        lda     $92
        clc
        adc     #$0100
        sta     $92
        shorta0
        ldx     $92
        cpx     #$4000
        bne     @ebb7
        stz     $7d20
@ebb7:  rts

; ------------------------------------------------------------------------------

; [ update credits text ??? ]

_13ebb8:
@ebb8:  lda     $7d1f
        bne     @ec14
        lda     $4a
        and     #$1f
        bne     @ec14
        phb
        clr_a
        pha
        plb
        lda     #$00
        sta     hVMAINC
        ldx     $92
        stx     hVMADDL
        ldx     $90
        stx     $4352
        lda     #$7e
        sta     $4354
        lda     #$00
        sta     $4350
        lda     #<hVMDATAL
        sta     $4351
        ldx     #$0080
        stx     $4355
        lda     #$20
        sta     hMDMAEN
        lda     #$80
        sta     hVMAINC
        plb
        longa
        lda     $90
        clc
        adc     #$0020
        and     #$7fff
        ora     #$8000
        sta     $90
        lda     $92
        clc
        adc     #$0080
        and     #$3fff
        sta     $92
        shorta0
@ec14:  jsr     _13eb60
        rts

; ------------------------------------------------------------------------------

; [ random (0..255) ]

Rand:
@ec18:  phx
        inc     $94
        lda     $94
        tax
        lda     f:RNGTbl,x
        plx
        rts

; ------------------------------------------------------------------------------

; [  ]

_13ec24:
@ec24:  longa
        and     #$01ff
        asl
        tax
        lda     f:SolarSystemSineTbl,x
        bpl     @ec4a
        eor     #$ffff
        sta     $10
        jsr     Mult16_1
        longa
        lda     $14
        eor     #$ffff
        inc
        bpl     @ec57
@ec43:  sta     $14
        shorta0
        sec
        rts
@ec4a:  longa
        sta     $10
        jsr     Mult16_1
        longa
        lda     $14
        bmi     @ec43
@ec57:  sta     $14
        shorta0
        clc
        rts

; ------------------------------------------------------------------------------

; [ init credits stars ]

InitCreditsStars:
@ec5e:  clr_ax
@ec60:  sta     $2303,x
        inx
        cpx     #$0900
        bne     @ec60
        clr_ax
@ec6b:  lda     f:RNGTbl,x
        sta     $2883,x
        inx
        cpx     #$0080
        bne     @ec6b
        rts

; ------------------------------------------------------------------------------

_13ec79:
@ec79:  .word   $1000,$2000,$a000,$4000

; ------------------------------------------------------------------------------

; [  ]

_13ec81:
@ec81:  clr_axy
@ec84:  lda     $2303,x
        bne     @ec96
        dec     $2883,x
        beq     @ec91
        jmp     @ed59
@ec91:  inc     $2303,x
        bra     @eca3
@ec96:  longa
        lda     $2a03,y
        cmp     #$0140
        bcc     @eceb
        shorta0
@eca3:  jsr     Rand
        sta     $00
        and     #$03
        sta     $2683,x
        stz     $01
        lda     $00
        longa
        sta     $2903,y
        asl
        sta     $2783,y
        lda     $00
        sta     $2903,y
        lda     $00
        and     #$003f
        sta     $02
        and     #$000f
        adc     $02
        sta     $2a03,y
        lda     #$0001
        sta     $2b03,y
        phx
        lda     $00
        and     #$0003
        asl
        tax
        lda     f:_13ec79,x
        sta     $2583,y
        lda     f:_13ec79+1,x
        sta     $2584,y
        plx
@eceb:  longa
        lda     $2a03,y
        sta     $00
        sta     $0e
        lda     $2783,y
        sta     $02
        phx
        jsr     _13ec24
        plx
        longa
        lda     $14
        clc
        adc     #$0070
        sta     $2483,y
        lda     $00
        sta     $0e
        lda     $02
        clc
        adc     #$0080
        phx
        jsr     _13ec24
        plx
        longa
        lda     $14
        clc
        adc     #$0080
        sta     $2383,y
        lda     $2583,y
        sta     $98
        lda     $2903,y
        clc
        adc     $98
        sta     $2903,y
        lda     $2b03,y
        php
        adc     #0
        plp
        adc     #0
        sta     $2b03,y
        sta     $02
        lda     $00
        clc
        adc     $02
        sta     $2a03,y
        lsr4
        sta     $00
        shorta0
        lda     $00
        and     #$0f
        sta     $2703,x
@ed59:  iny2
        inx
        cpx     $96
        beq     @ed63
        jmp     @ec84
@ed63:  inc     $95
        rts

; ------------------------------------------------------------------------------

; [ draw star sprites ]

DrawCreditsStars:
@ed66:  lda     $95
        bne     @ed6b
        rts
@ed6b:  stz     $95
        jsr     ClearSprites
        clr_axy
@ed73:  phx
        lda     $2303,x
        beq     @edc0
        phx
        txa
        asl
        tax
        lda     $2384,x
        ora     $2484,x
        beq     @ed8f
        lda     #$f0
        sta     $0300,y
        sta     $0301,y
        bra     @ed9b
@ed8f:  lda     $2383,x                 ; x position
        sta     $0300,y
        lda     $2483,x                 ; y position
        sta     $0301,y
@ed9b:  plx
        lda     $2683,x
        asl4
        clc
        adc     $2703,x
        tax
        lda     f:CreditsStarsTileTbl,x
        sta     $28
        and     #$3f
        sta     $0302,y                 ; tile id
        lda     $28
        and     #$c0
        ora     #$0e
        sta     $0303,y                 ; sprite flags
        iny4
@edc0:  plx
        inx
        cpx     $96
        bne     @ed73
        rts

; ------------------------------------------------------------------------------

; tile id for credits star sprites
CreditsStarsTileTbl:
@edc7:  .byte   $08,$08,$08,$08,$07,$07,$07,$07,$06,$06,$06,$06,$06,$05,$05,$05
        .byte   $08,$08,$07,$07,$06,$06,$05,$05,$04,$04,$03,$03,$02,$02,$01,$01
        .byte   $08,$07,$06,$05,$04,$03,$02,$03,$02,$01,$00,$09,$0a,$0b,$0c,$0d
        .byte   $08,$07,$06,$05,$04,$03,$02,$03,$02,$01,$00,$09,$0a,$0b,$0c,$0d

; ------------------------------------------------------------------------------

; [ init "THE END" ]

_13ee07:
@ee07:  inc     $7d1f
        ldx     #$0100
@ee0d:  jsr     WaitVBlank
        jsr     SetZoomHDMA
        txa
        sec
        sbc     #$08
        tax
        cpx     #$0078
        bne     @ee0d
        clr_ax
        stx     $9c
        ldx     #128
        jsr     WaitX
        ldx     #$0100
        stx     $9e
        clr_ax
        stx     $9a
@ee30:  jsr     WaitVBlank
        longa
        lda     $9c
        sec
        sbc     #$0008
        sta     $9c
        dec     $9e
        dec     $9e
        lda     $9e
        sta     $0e
        lda     $9c
        clc
        adc     #$0080
        jsr     _13ec24
        longa
        lda     $14
        sta     $00
        sta     $06
        lda     $9e
        sta     $0e
        lda     $9c
        jsr     _13ec24
        longa
        inc     $9a
        lda     $9a
        and     #$0003
        bne     @ee76
        lda     $2105
        beq     @ee76
        sec
        sbc     #$0421
        sta     $2105
@ee76:  lda     $14
        sta     $02
        eor     #$ffff
        sta     $04
        jsr     _13efef
        shorta
        lda     $2105
        bne     @ee30
        jsr     WaitVBlank
        lda     #$10
        sta     $7d28
        ldx     #$7fff
        stx     $2105
        ldx     #$0cc0
        stx     $2107
        clr_ax
        jsr     WaitVBlank
        clr_a
@eea3:  sta     $3d19,x
        inx
        cpx     #$1000
        bne     @eea3
        jsr     WaitVBlank
        clr_a
@eeb0:  sta     $3d19,x
        inx
        cpx     #$2000
        bne     @eeb0
        jsr     WaitVBlank
        clr_a
@eebd:  sta     $3d19,x
        inx
        cpx     #$3000
        bne     @eebd
        jsr     WaitVBlank
        clr_a
@eeca:  sta     $3d19,x
        inx
        cpx     #$4000
        bne     @eeca
        lda     #$c0
        sta     $00
        lda     #$cc
        sta     $02
        clr_ax
@eedd:  lda     $00
        sta     $43a3,x
        lda     $02
        sta     $4423,x
        inc     $00
        inc     $02
        inx
        cpx     #$000c
        bne     @eedd
        jsr     WaitVBlank
        clr_ax
        stx     $66
        stx     $92
        ldx     #$0070
        stx     $8e
        ldx     #$3d19
        stx     $90
        inc     $7d20
@ef07:  jsr     WaitVBlank
        lda     $7d20
        bne     @ef07
        jmp     _13ef65

; ------------------------------------------------------------------------------

; [ wait X frames ]

WaitX:
@ef12:  jsr     WaitVBlank
        dex
        bne     @ef12
        rts

; ------------------------------------------------------------------------------

; [  ]

_13ef19:
@ef19:  lda     $7d21
        bne     @ef43
        longa
        ldx     #$001c
        lda     $2121
        pha
@ef27:  lda     $2103,x
        sta     $2105,x
        dex2
        cpx     #$0004
        bne     @ef27
        pla
        sta     $2109
        shorta0
        dec     $7d24
        bne     @ef4b
        inc     $7d21
@ef43:  dec     $7d22
        bne     @ef4b
        jmp     _13ef4c
@ef4b:  rts

; ------------------------------------------------------------------------------

; [  ]

_13ef4c:
@ef4c:  stz     $7d21
        stz     $7d23
        lda     #$1a
        sta     $7d24
        lda     $7d26
        inc     $7d26
        tax
        lda     $ee00,x
        sta     $7d22
        rts

; ------------------------------------------------------------------------------

; [ "THE END" ]

_13ef65:
@ef65:  ldx     #0
        stx     $02
        stx     $04
        ldx     #$4000
        stx     $00
        stx     $06
        jsr     _13efef
        jsr     WaitVBlank
        lda     #$80
        sta     $a0
        lda     #$11
        sta     $7d28
        clr_ax
        stx     $9c
        ldx     #$0800
        stx     $9e
@ef8b:  jsr     WaitVBlank
        longa
        lda     $9e
        sec
        sbc     #$0010
        sta     $9e
        lda     $9e
        sta     $0e
        lda     $9c
        clc
        adc     #$0080
        jsr     _13ec24
        longa
        lda     $14
        sta     $00
        sta     $06
        lda     $9e
        sta     $0e
        lda     $9c
        jsr     _13ec24
        longa
        lda     $14
        sta     $02
        eor     #$ffff
        sta     $04
        jsr     _13efef
        shorta
        ldx     $9e
        cpx     #$0200
        bne     @ef8b
        ldx     #180
        jsr     WaitX
        lda     #$01                    ; play song $15 (the prelude)
        sta     f:$001e00
        lda     #$15
        sta     f:$001e01
        jsl     ExecSound_ext
        jsr     _13ef4c
        inc     $7d25

; "THE END" infinite loop
@efe9:  jsr     WaitVBlank
        jmp     @efe9

; ------------------------------------------------------------------------------

; [  ]

_13efef:
@efef:  phx
        longa
        clr_ax
@eff4:  lda     $00
        sta     $3319,x
        lda     $06
        sta     $371b,x
        lda     $02
        sta     $331b,x
        lda     $04
        sta     $3719,x
        inx4
        cpx     #$0400
        bne     @eff4
        shorta0
        plx
        rts

; ------------------------------------------------------------------------------

        .include .sprintf("gfx/the_end_gfx_%s.asm", LANG_SUFFIX)
        .include .sprintf("text/credits_text_%s.asm", LANG_SUFFIX)

; ------------------------------------------------------------------------------
