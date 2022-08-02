
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: special.asm                                                          |
; |                                                                            |
; | description: special effect routines                                       |
; |                                                                            |
; | created: 3/29/2022                                                         |
; +----------------------------------------------------------------------------+

.import SolarSystem1_ext, SolarSystem2_ext, EndCredits_ext

; ------------------------------------------------------------------------------

.pushseg

.segment "prologue_gfx"
        .include "gfx/prologue_bg_gfx.asm"
        .include "gfx/prologue_bg1_tiles.asm"
        .include "gfx/prologue_bg2_tiles.asm"
        .include "gfx/prologue_pal.asm"

.segment "prologue_moon"
        .include "gfx/prologue_moon_pal.asm"
        .include "gfx/prologue_moon_gfx.asm"

.segment "telescope_window"
        .include "data/telescope_window.asm"

.popseg

; ------------------------------------------------------------------------------

; [ event command $fd: special effect ]

EventCmd_fd:
@c434:  jsr     GetNextEventByte
        stz     $3e
        asl
        rol     $3e
        sta     $3d
        ldx     $3d
        lda     SpecialTbl,x
        sta     $3d
        lda     SpecialTbl+1,x
        sta     $3e
        jmp     ($063d)

; ------------------------------------------------------------------------------

; special effect jump table
SpecialTbl:
@c44d:  .addr   Special_00
        .addr   Special_01
        .addr   Special_02
        .addr   Special_03
        .addr   Special_04
        .addr   Special_05
        .addr   Special_06
        .addr   Special_07
        .addr   Special_08
        .addr   Special_09
        .addr   Special_0a
        .addr   Special_0b
        .addr   Special_0c
        .addr   Special_0d
        .addr   Special_0e
        .addr   Special_0f
        .addr   Special_10
        .addr   Special_11
        .addr   Special_12
        .addr   Special_13
        .addr   Special_14
        .addr   Special_15
        .addr   Special_16
        .addr   Special_17
        .addr   Special_18
        .addr   Special_19
        .addr   Special_1a
        .addr   Special_1b
        .addr   Special_1c
        .addr   Special_1d
        .addr   Special_1e
        .addr   Special_1f
        .addr   Special_20
        .addr   Special_21
        .addr   Special_22
        .addr   Special_23
        .addr   Special_24
        .addr   Special_25
        .addr   Special_26
        .addr   Special_27
        .addr   Special_28
        .addr   Special_29
        .addr   Special_2a
        .addr   Special_2b
        .addr   Special_2c
        .addr   Special_2d
        .addr   Special_2e
        .addr   Special_2f
        .addr   Special_30
        .addr   Special_31
        .addr   Special_32
        .addr   Special_33
        .addr   Special_34
        .addr   Special_35
        .addr   Special_36
        .addr   Special_37
        .addr   Special_38
        .addr   Special_39
        .addr   Special_3a
        .addr   Special_3b
        .addr   Special_3c
        .addr   Special_3d
        .addr   Special_3e
        .addr   Special_3f
        .addr   Special_40

; ------------------------------------------------------------------------------

; [ special effect $3f: init characters for final battle ]

Special_3f:
@c4cf:  ldx     #0
@c4d2:  lda     $1000,x
        and     #$1f
        cmp     #$0b        ; find paladin cecil
        bne     @c4e3
        stz     $1003,x     ; clear status 1
        lda     #$01        ; set hp to 1
        jmp     @c4ea
@c4e3:  lda     #$80
        sta     $1003,x     ; make all other characters dead
        lda     #$00
@c4ea:  sta     $1007,x
        stz     $1008,x
        stz     $1004,x     ; clear status 2
        jsr     NextChar
        cpx     #$0140
        bne     @c4d2
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $3c: reset game ]

Special_3c:
@c4fe:  lda     #$80
        sta     $2100       ; screen off
        lda     #$00
        sta     $4200       ; disable nmi
        lda     #$ff
        sta     $2140       ; reset spc program
        jmp     Reset

; ------------------------------------------------------------------------------

; [ special effect $3d: fade music to half volume ]

Special_3d:
@c510:  jsr     fade_song_half
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ fade music to half volume ]

fade_song_half:
@c516:  lda     #$87        ; fade music to half volume
        sta     $1e00
        jsl     ExecSound_ext
        rts

; ------------------------------------------------------------------------------

; [ special effect $3e: fade in music ]

Special_3e:
@c520:  jsr     FadeInSong
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ fade in music ]

FadeInSong:
@c526:  lda     #$89        ; fade in music
        sta     $1e00
        jsl     ExecSound_ext
        rts

; ------------------------------------------------------------------------------

; [ special effect $3b: enterprise rescue ]

; after tower of babil

Special_3b:
@c530:  stz     $7b                     ; clear frame counters
        stz     $7a
        ldx     #100                    ; 100 frames
        stx     $89
; start of frame loop
@c539:  jsr     WaitVblankLong
        lda     $89
        cmp     #64                     ; move down for last 64 frames
        bcs     @c54b
        lsr2
        sta     $b7                     ; set enterprise y-offset
        clc
        adc     #$10
        sta     $ad                     ; set zoom level
@c54b:  lda     #1                      ; enable player control
        sta     $d5
        jsr     ResetSprites
        lda     #$02                    ; force player to move left
        sta     $05
        stz     $04
        lda     #1                      ; enable player control
        sta     $d5
        jsr     CheckPlayerMoveWorld
        jsr     MovePlayer
        jsl     DrawEnterprise
        ldx     $89
        dex
        stx     $89
        bne     @c539
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $37: solar system 1 (prophecy) ]

Special_37:
@c570:  jsr     ScreenOff
        sei
        jsl     SolarSystem1_ext
        jsr     AfterCutscene
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $38: solar system 2 (moon departs) ]

Special_38:
@c57e:  jsr     ScreenOff
        sei
        jsl     SolarSystem2_ext
        jsr     AfterCutscene
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $39: end credits ]

Special_39:
@c58c:  jsr     ScreenOff
        sei
        jsl     EndCredits_ext
        jsr     AfterCutscene
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [  ]

AfterCutscene:
@c59a:  jsr     InitInterrupts
        jsl     InitHWRegs
        cli
        lda     #$00
        sta     $2100       ; screen on, zero brightness
        lda     #$81
        sta     $4200       ; enable nmi
        rts

; ------------------------------------------------------------------------------

; [ special effect $36: dwarf tanks attack tower of babil ]

Special_36:
@c5ad:  lda     #$10
        sta     $0acf
        ldx     #$0020
        stx     $0ad2
        lda     #$07
        sta     $0acd
        stz     $0ace
        lda     #$02
        sta     $0ad0
        sta     $0ad1
        jsr     _00e075
        lda     #$01
        sta     $e3
        lda     #$23
        jsr     PlaySfx
        ldx     #$00c0
        stx     $89
@c5d9:  jsr     WaitVblankLong
        jsr     ResetSprites
        lda     $1707
        sec
        sbc     #$10
        tax
        lda     $7a
        lsr4
        and     #$01
        tay
        lda     _00c611,x
        sta     $0ad4
        lda     _00c61b,y
        clc
        adc     _00c616,x
        sta     $0ad5
        jsr     UpdateExplosions
        jsr     DrawWorldSprites
        ldx     $89
        dex
        stx     $89
        bne     @c5d9
        stz     $e3
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

_00c611:
@c611:  .byte   $40,$10,$00,$00,$10

_00c616:
@c616:  .byte   $a0,$90,$00,$00,$60

_00c61b:
@c61b:  .byte   $00,$a0

; ------------------------------------------------------------------------------

; [ special effect $34: telescope ]

Special_34:

@TelescopeWindowData2 := TelescopeWindowData+$f8

@c61d:  jsr     ScreenOff
        jsr     LoadEarthMoonGfx
        lda     #$22
        sta     $2123
        lda     #0
        sta     $420c                   ; disable hdma
        lda     #$f7                    ; 119 scanlines
        sta     $7f5a00
        lda     #<TelescopeWindowData
        sta     $7f5a01
        lda     #>TelescopeWindowData
        sta     $7f5a02
        lda     #$f7                    ; 119 scanlines
        sta     $7f5a03
        lda     #<@TelescopeWindowData2
        sta     $7f5a04
        lda     #>@TelescopeWindowData2
        sta     $7f5a05
        lda     #$00                    ; hdma table terminator
        sta     $7f5a06
        lda     #$41
        sta     $4360
        lda     #$26
        sta     $4361
        ldx     #$5a00                  ; 7f/5a00 (hdma table)
        stx     $4362
        lda     #$7f
        sta     $4364
        lda     #^TelescopeWindowData
        sta     $4367
        lda     #$03
        sta     $1700
        lda     #$00
        sta     $2100                   ; screen on, zero brightness
        lda     #$81
        sta     $4200                   ; enable nmi
        stz     $24

; start of fade in loop
@c682:  jsr     WaitVblankShort
        lda     #$40
        sta     $420c                   ; enable window hdma
        lda     $24
        sta     $2100                   ; set screen brightness
        jsr     DrawTelescopeSprites
        inc     $24
        lda     $24
        cmp     #$10
        bne     @c682

; start of frame loop
@c69a:  jsr     WaitVblankShort
        lda     #$40
        sta     $420c                   ; enable window hdma
        jsr     DrawTelescopeSprites
        lda     $02                     ; wait for keypress
        bne     @c6b0
        lda     $03
        bne     @c6b0
        jmp     @c69a
@c6b0:  lda     #$0f
        sta     $24

; start of fade out loop
@c6b4:  jsr     WaitVblankShort
        lda     #$40
        sta     $420c                   ; enable window hdma
        lda     $24
        sta     $2100                   ; set screen brightness
        jsr     DrawTelescopeSprites
        dec     $24
        lda     $24
        bne     @c6b4
        lda     #$33
        sta     $2123
        lda     #$00
        sta     $420c                   ; disable hdma
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ draw telescope sprites ]

DrawTelescopeSprites:
@c6d7:  jsr     _00a531
        ldy     #$0010
        ldx     #0
@c6e0:  jsr     Rand
        lsr
        clc
        adc     #$40
        sta     $0300,y
        jsr     Rand
        lsr
        clc
        adc     #$40
        sta     $0301,y
        lda     #$ff
        sta     $0302,y
        jsr     Rand
        and     #$07
        asl
        ora     #$01
        sta     $0303,y
        inx2
        iny4
        cpy     #$0200
        bne     @c6e0
        rts

; ------------------------------------------------------------------------------

; [ special effect $33: sight/dwarven bread ]

Special_33:
@c710:  jsr     fade_song_half
        lda     #$20        ; 2x zoom
        sta     $ad
        jsr     ResetSprites
@c71a:  jsr     WaitVblankShort
        stz     $420c
        inc     $ad
        jsr     CalcMode7Rot
        jsr     UpdateMode7Regs
        lda     $ad
        lsr3
        inc
        jsl     UpdateZoomPal
        lda     $ad
        cmp     #$78        ; 7.5x zoom
        bne     @c71a
@c738:  jsr     WaitVblankShort
        stz     $420c
        jsr     UpdateMode7Regs
        lda     $02
        bne     @c749       ; wait for keypress
        lda     $03
        beq     @c738
@c749:  jsr     FadeInSong
@c74c:  jsr     WaitVblankShort
        stz     $420c
        dec     $ad
        jsr     CalcMode7Rot
        jsr     UpdateMode7Regs
        lda     $ad
        lsr3
        jsl     UpdateZoomPal
        lda     $ad
        cmp     #$20        ; 2x zoom
        bne     @c74c
        lda     #$10
        sta     $ad
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $32: prophecy ]

Special_32:
@c770:  jsl     InitHWRegs
        lda     #$09
        sta     hBGMODE
        ldx     #$2000
        stx     $47
        ldx     #$1000
        stx     $45
        lda     #.bankbyte(WindowGfx)
        sta     $3c
        ldx     #.loword(WindowGfx)
        stx     $3d
        jsl     TfrVRAM
        lda     #$80
        sta     hVMAINC
        ldx     #$2c00
        stx     hVMADDL
        ldx     #$0400
@c79e:  lda     #$ff
        sta     hVMDATAL
        lda     #$20
        sta     hVMDATAH
        dex
        bne     @c79e
        lda     #$6a
        sta     $b2
        jsr     GetDlgPtr1H
        stz     $ba
        jsr     DecodeDlgText
        inc     $ed
        jsr     TfrDlgText
        jsr     DecodeDlgText
        inc     $ed
        jsr     TfrDlgText
.if LANG_EN
        jsr     DecodeDlgText
        inc     $ed
        jsr     TfrDlgText
        jsr     DecodeDlgText
        inc     $ed
        jsr     TfrDlgText
        stz     $dd
        stz     $ed
        lda     #$00
        sta     $0cdd
        sta     $0ce1
        lda     #$40
        sta     $0cde
        sta     $0ce2
        lda     #$ff
        sta     $0cf1
        lda     #$7f
        sta     $0cf2
        lda     #$00
        sta     hBG3HOFS
        lda     #$01
        sta     hBG3HOFS
        lda     #$f8
.else
        stz     $dd
        stz     $ed
        lda     #$80
        sta     hVMAINC
        ldx     #$2c00
        stx     hVMADDL
        ldx     #$0000
@c7d6:  longa
        txa
        and     #$01c0
        lsr4
        ora     #$0020
        shorta
        sta     hVMDATAH
        inx
        cpx     #$0200
        bne     @c7d6
        lda     #0
        xba
        ldx     #0
@c7f4:  lda     #0
        sta     $0cdd,x
        sta     $0ce1,x
        lda     #$40
        sta     $0cde,x
        sta     $0ce2,x
        txa
        clc
        adc     #$08
        tax
        cmp     #$40
        bne     @c7f4
        lda     #$00
        sta     hBG3HOFS
        lda     #$01
        sta     hBG3HOFS
        lda     #$c8
.endif
        sta     hBG3VOFS
        lda     #$ff
        sta     hBG3VOFS
        lda     #$81
        sta     hNMITIMEN               ; enable nmi
        lda     #$03
        jsr     FadeIn
        stz     $2e
        stz     $2f
@c82f:  stz     $20
        stz     $21
@c833:
.if !LANG_EN
        jsr     WaitVblankShort
.endif
        lda     $2e
        asl
        tax
        longa
        lda     $20
        lsr3
        sta     $22
        asl5
        ora     $22
        ora     f:ProphecyPal,x
        sta     $22
.if LANG_EN
        sta     $0ce9
        lda     #0
        shorta
        jsr     WaitVblankShort
        lda     #$80
        sta     hVMAINC
        longa
        lda     $2e
        asl6
        clc
        adc     #$2c00
        sta     hVMADDL
        lda     #0
        shorta
        ldx     #$0040
@c5a3:  lda     #$24
        sta     hVMDATAH
        dex
        bne     @c5a3
        inc     $20
        inc     $20
        bne     @c833
        lda     #$80
        sta     hVMAINC
        longa
        lda     $2e
        asl6
        clc
        adc     #$2c00
        sta     hVMADDL
        lda     #0
        shorta
        ldx     #$0040
@c5cf:  lda     #$28
        sta     hVMDATAH
        dex
        bne     @c5cf
        inc     $2e
        lda     $2e
        cmp     #$0d
        beq     @c5e2
        jmp     @c82f
@c5e2:
.else
        txa
        asl2
        tax
        lda     $22
        sta     $0ce1,x
        lda     #0
        shorta
        inc     $20
        bne     @c833
        inc     $2e
        lda     $2e
        cmp     #$08
        bne     @c82f
.endif
        lda     #$03
        jsr     FadeOut
        stz     hBG3HOFS
        stz     hBG3HOFS
        stz     hBG3VOFS
        stz     hBG3VOFS
        jsl     LoadWindowPal
        jsl     LoadMapPal
        lda     #$81
        sta     hNMITIMEN               ; enable nmi
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $30: travel to the moon (after giant of babil) ]

Special_30:
@c88b:  ldx     #$2713
        stx     $170c
        lda     #$00
        sta     $1700
        lda     #1                      ; travel to/from moon
        sta     $c3
        jsr     BoardWhale
        lda     #$ff
        sta     $a2
        jsr     WhaleButton
        lda     #$02        ; big whale is on the moon
        sta     $1727
        ldx     #$2713      ; big whale position
        stx     $1725
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $2e: hide enterprise ]

Special_2e:
@c8b2:  stz     $171c
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $2f: travel to/from moon ]

; when the party uses the crystal

Special_2f:
@c8b8:  lda     #1                      ; travel to/from moon
        sta     $c3
; fallthrough

; ------------------------------------------------------------------------------

; [ special effect $2d: lift-off big whale ]

; when the party uses the controls in the big whale

Special_2d:
@c8bc:  ldx     #0                      ; reset map stack
        stx     $172c
        lda     #$06                    ; set vehicle to big whale
        sta     $1704
        lda     #$03                    ; set movement speed
        sta     $ac
        stz     $e1
        ldx     $1725                   ; move party to big whale position
        stx     $1706
        lda     $1727
        jsr     _00f167
        jsr     BoardWhale
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $20: giant of babil 1 ]

Special_20:
@c8df:  ldx     #$e828                  ; (40,232)
        stx     $1708
        ldx     $1725
        stx     $1706
        lda     $1727
        jsr     _00f167
        lda     #$01
        sta     $c3
        jsr     BoardWhale
        lda     #$ff
        sta     $a2
        jsr     WhaleButton
        lda     #$01
        sta     $06c8
        ldx     #$e828
        stx     $1725
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $21: giant of babil 2 ]

Special_21:
@c90d:  stz     $1704
        stz     $20
        stz     $24
        jsr     _00c95e
@c917:  jsr     WaitVblankLong
        jsr     ResetSprites
        jsr     _00da94
        inc     $20
        lda     $24
        clc
        adc     $20
        sta     $24
        bcc     @c939
        ldx     #$0000
        lda     #$60
        sta     $0c
        lda     #$50
        sta     $0e
        jsr     _00cd8a
@c939:  lda     $20
        cmp     #$ff
        bne     @c917
        jsr     _00cd72
        lda     $1288
        and     #$fb
        sta     $1288
        ldx     #$0003
@c94d:  phx
        jsr     _00ca0f
        jsr     _00c970
        jsr     _00ea14
        plx
        dex
        bne     @c94d
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [  ]

_00c95e:
@c95e:  ldx     #0
@c961:  lda     #$ff        ; white ???
        sta     $0e1b,x     ; sprite palette 2
        sta     $0e3b,x     ; sprite palette 3
        inx
        cpx     #$0010      ; 8 colors
        bne     @c961
        rts

; ------------------------------------------------------------------------------

; [  ]

_00c970:
@c970:  lda     #1
        sta     $c7
        ldx     #$0030
        lda     #$60
        sta     $0c
        lda     #$50
        sta     $0e
        jsr     _00cd8a
        lda     #$cf
        jsr     _00e9cf
        jsr     _00c95e
        ldx     #$0020
        jsr     WaitSpecial
        jsr     _00cd72
        lda     #$10
        sta     $0acf
        ldx     #$0024
        stx     $0ad2
        stz     $0acd
        stz     $0ace
        lda     #$70
        sta     $0ad4
        sta     $0ad5
        jsr     _00e075
        lda     #$23
        jsr     PlaySfx
        lda     #$01
        sta     $e3
@c9b8:  jsr     WaitVblankLong
        jsr     ResetSprites
        jsr     _00da94
        jsr     UpdateExplosions
        ldx     #$0030
        lda     #$60
        sta     $0c
        lda     #$50
        sta     $0e
        jsr     _00cd8a
        jsl     DrawWhale
        ldx     $0ad2
        cpx     #4
        bne     @c9e2
        lda     #1
        sta     $e5
@c9e2:  cpx     #0
        bne     @c9b8
        stz     $e3
        jsr     _00cd72
        stz     $c7
        rts

; ------------------------------------------------------------------------------

; xy points on a circle with radius 60 (signed)
;   (0,60) (55,23) (42,42) (23,55) ...

ExplosionPosTbl:
@c9ef:  .byte   $00,$c4,$17,$c9,$2a,$d6,$37,$e9,$3c,$00,$37,$17,$2a,$2a,$17,$37
        .byte   $00,$3c,$e9,$37,$d6,$2a,$c9,$17,$c4,$00,$c9,$e9,$d6,$d6,$e9,$c9

; ------------------------------------------------------------------------------

; [  ]

_00ca0f:
@ca0f:  stz     $20
        stz     $24
        stz     $7a
@ca15:  jsr     WaitVblankLong
        lda     $20
        beq     @ca38
        dec     $20
        lda     $20
        and     #$01
        beq     @ca38
        lda     $20
        lsr
        sta     $22
        lda     $5c
        clc
        adc     $22
        sta     $210e
        lda     $5d
        adc     #$00
        sta     $210e
@ca38:  lda     $7a
        and     #$7f
        bne     @ca4f
        inc     $24
        lda     $24
        cmp     #$03                    ; take 3 steps total
        beq     @caa4
        lda     #$04                    ; force player to move down
        sta     $05
        stz     $04
        jmp     @ca59
@ca4f:  lda     $7a
        and     #$0f
        bne     @ca59
        stz     $05                     ; don't move
        stz     $04
@ca59:  jsr     ResetSprites
        jsr     _00da94
        lda     #1                      ; enable player control
        sta     $d5
        jsr     CheckPlayerMoveWorld
        jsr     MovePlayer
        lda     $5c
        clc
        adc     #$0f
        and     #$10
        bne     @ca78
        ldx     #$0000
        jmp     @ca7b
@ca78:  ldx     #$0018
@ca7b:  lda     #$60
        sta     $0c
        lda     #$50
        sta     $0e
        jsr     _00cd8a
        lda     $5c
        and     #$0f
        cmp     #$0f
        bne     @ca93
        lda     #$48
        jsr     PlaySfx
@ca93:  jsl     DrawWhale
        lda     $7a
        and     #$7f
        bne     @caa1
        lda     #$20
        sta     $20
@caa1:  jmp     @ca15
@caa4:  rts

; ------------------------------------------------------------------------------

; [ special effect $22: giant of babil 3 ]

Special_22:
@caa5:  ldx     #$0030
        stx     $ef
        ldx     #$00e0
        stx     $f1
        ldx     #$0100
        stx     $f3
        ldx     #$ffe0
        stx     $f5
        jsr     _00cb72
        ldx     #$0140
        stx     $89
@cac1:  jsr     WaitVblankLong
        ldx     $89
        cpx     #$00c0
        bne     @cad0
        lda     #$2c
        jsr     PlaySongEvent
@cad0:  jsr     ResetSprites
        ldx     $89
        cpx     #$00c0
        bcs     @cae5
        lda     $7a
        and     #$03
        bne     @caf8
        dec     $f1
        jmp     @caf8
@cae5:  jsr     UpdateExplosions
        ldx     $89
        cpx     #$0138
        bne     @caf8
        lda     #$23
        jsr     PlaySfx
        lda     #$01
        sta     $e5
@caf8:  jsr     _00cd40
        ldx     $89
        dex
        stx     $89
        bne     @cac1
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [  ]

_00cb05:
@cb05:  stz     $79
@cb07:  lda     $79
        clc
        adc     #$04
        asl
        tay
        jsr     _00df93
        stz     $92
        jsr     _00dfc4
        inc     $79
        lda     $79
        cmp     #$04
        bne     @cb07
        rts

; ------------------------------------------------------------------------------

; [ special effect $23: giant of babil 4 ]

Special_23:
@cb1f:  ldx     #$0030
        stx     $ef
        ldx     #$00b0
        stx     $f1
        ldx     #$0100
        stx     $f3
        ldx     #$ffe0
        stx     $f5
        jsr     _00cb72
        ldx     #$01c0
        stx     $89
@cb3b:  jsr     WaitVblankLong
        jsr     ResetSprites
        ldx     $89
        cpx     #$0140
        bcs     @cb56
        lda     $7a
        and     #$03
        bne     @cb65
        ldx     $f3
        dex
        stx     $f3
        jmp     @cb65
@cb56:  jsr     UpdateExplosions
        ldx     $89
        cpx     #$01b8
        bne     @cb65
        lda     #$23
        jsr     PlaySfx
@cb65:  jsr     _00cd40
        ldx     $89
        dex
        stx     $89
        bne     @cb3b
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [  ]

_00cb72:
@cb72:  jsr     _00cd72
        lda     #$08
        sta     $0acf
        ldx     #$0010
        stx     $0ad2
        stz     $0acd
        stz     $0ace
        lda     #$02
        sta     $0ad0
        sta     $0ad1
        lda     #$60
        sta     $0ad4
        sta     $0ad5
        jsr     _00e075
        rts

; ------------------------------------------------------------------------------

; [ special effect $24: giant of babil 5 ]

Special_24:
@cb9a:  jsr     _00cc32
        ldx     #$0200
        stx     $89
@cba2:  jsr     WaitVblankLong
        jsr     ResetSprites
        lda     $7a
        lsr3
        and     #$06
        tay
        lda     _00cbe3,y
        sta     $0ad4
        lda     _00cbe3+1,y
        sta     $0ad5
        lda     _00cbeb,y
        sta     $0ad0
        lda     _00cbeb+1,y
        sta     $0ad1
        jsr     UpdateExplosions
        jsr     _00cd40
        lda     $89
        and     #$3f
        bne     @cbd9
        lda     #$23
        jsr     PlaySfx
@cbd9:  ldx     $89
        dex
        stx     $89
        bne     @cba2
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

_00cbe3:
@cbe3:  .byte   $70,$58,$c0,$40,$70,$58,$60,$b0
_00cbeb:
@cbeb:  .byte   $02,$02,$02,$01,$02,$02,$01,$02

; ------------------------------------------------------------------------------

; [ special effect $25: giant of babil 6 ]

Special_25:
@cbf3:  jsr     _00cc32
        ldx     #0
        stx     $89
        stz     $7a
@cbfd:  jsr     _00cd68
        stz     $28
        lda     $89
        sta     $29
        sta     $2b
        jsr     _00cc69
        ldx     $89
        inx
        stx     $89
        cpx     #$0020
        bne     @cbfd
        ldx     #0
        stx     $89
        stz     $7a
@cc1c:  jsr     _00cd68
        stz     $28
        lda     $89
        lsr
        clc
        adc     #$20
        sta     $29
        lda     #$20
        sta     $2b
        jsr     _00cc69
        ldx     $89
        inx
        stx     $89
        cpx     #$0020
        bne     @cc1c
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [  ]

_00cc32:
@cc3d:  lda     #$10
        sta     $0acf
        ldx     #$0010
        stx     $0ad2
        stz     $0acd
        stz     $0ace
        jsr     _00e075
        jsr     _00cd72
        ldx     #$0030
        stx     $ef
        ldx     #$00b0
        stx     $f1
        ldx     #$00b0
        stx     $f3
        ldx     #$ffe0
        stx     $f5
        rts

; ------------------------------------------------------------------------------

; [  ]

_00cc69:
@cc69:  ldy     #0
@cc6c:  lda     $03b0,y
        clc
        adc     $28
        sta     $03b0,y
        lda     $03b1,y
        clc
        adc     $29
        sta     $03b1,y
        lda     $7a
        and     #$01
        bne     @cc9b
        cpy     #8
        bcs     @cc9b
        lda     $0410,y
        clc
        adc     $28
        sta     $0410,y
        lda     $0411,y
        clc
        adc     $2b
        sta     $0411,y
@cc9b:  iny4
        cpy     #$0010
        bne     @cc6c
        rts

; ------------------------------------------------------------------------------

; [ special effect $26: giant of babil 7 ]

Special_26:
@cca5:  jsr     _00cc32
        ldx     #$0020
        stx     $89
        stz     $7a
@ccaf:  jsr     _00cd68
        stz     $28
        lda     $89
        lsr
        clc
        adc     #$20
        sta     $29
        lda     #$20
        sta     $2b
        jsr     _00cc69
        ldx     $89
        dex
        stx     $89
        bne     @ccaf
        ldx     #0
        stx     $89
        stz     $7a
@ccd1:  jsr     _00cd68
        lda     #$00
        sec
        sbc     $89
        sta     $28
        lda     #$20
        sta     $29
        sta     $2b
        jsr     _00cc69
        ldx     $89
        inx
        stx     $89
        cpx     #$0060
        bne     @ccd1
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $27: giant of babil 8 ]

Special_27:
@ccf1:  jsr     _00cc32
        ldx     #$0030
        stx     $89
        stz     $7a
@ccfb:  jsr     WaitVblankLong
        lda     $89
        cmp     #$10
        bcs     @cd07
        sta     $2100       ; set screen brightness
@cd07:  jsr     ResetSprites
        jsr     _00cd40
        lda     #$68
        sta     $0c
        lda     $89
        clc
        adc     #$80
        sta     $0e
        lda     #$18
        sta     $91
        lda     #$78
        sta     $8f
        ldy     #$00b0
        lda     #$00
        sta     $92
        jsr     _00dfc4
        lda     #$f0
        sta     $0411
        sta     $0415
        ldx     $89
        dex
        stx     $89
        bne     @ccfb
        stz     $80
        stz     $c8
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [  ]

_00cd40:
@cd40:  jsr     _00da94
        jsl     DrawWhale
        ldx     #0
        lda     #$60
        sta     $0c
        lda     #$50
        sta     $0e
        jsr     _00cd8a
        jsr     _00cb05
        lda     #$18
        sta     $91
        lda     #$78
        sta     $8f
        lda     #$60
        sta     $92
        jsr     _00df53
        rts

; ------------------------------------------------------------------------------

; [  ]

_00cd68:
@cd68:  jsr     WaitVblankLong
        jsr     ResetSprites
        jsr     _00cd40
        rts

; ------------------------------------------------------------------------------

; [ load ??? palette ]

_00cd72:
@cd72:  ldx     #0
@cd75:  lda     f:MapSpritePal+35*16,x
        sta     $0e1b,x
        lda     f:MapSpritePal+36*16,x
        sta     $0e3b,x
        inx
        cpx     #$0010
        bne     @cd75
        rts

; ------------------------------------------------------------------------------

; [  ]

_00cd8a:
@cd8a:  ldy     #0
@cd8d:  lda     f:_14f58e,x
        clc
        adc     $0c
        sta     $0340,y
        lda     f:_14f58e+1,x
        clc
        adc     $0e
        sta     $0341,y
        lda     f:_14f58e+2,x
        sta     $0342,y
        lda     f:_14f58e+3,x
        sta     $0343,y
        jsr     NextSprite
        cpy     #$0018
        bne     @cd8d
        rts

; ------------------------------------------------------------------------------

; [ special effect $40: giant of babil destroyed ]

Special_40:
@cdb8:  jsr     _00cc32
        lda     #$02
        sta     $ca
        ldx     #$0180
        stx     $89
@cdc4:  jsr     WaitVblankLong
        ldx     $89
        cpx     #$0010
        bcs     @cdd2
        txa
        sta     $2100       ; set screen brightness
@cdd2:  jsr     ResetSprites
        lda     #$70
        sta     $0ad4
        lda     #$58
        sta     $0ad5
        lda     #$03
        sta     $0ad0
        sta     $0ad1
        jsr     UpdateExplosions
        jsr     _00cd40
        lda     $89
        and     #$3f
        bne     @cdf8
        lda     #$23
        jsr     PlaySfx
@cdf8:  ldx     $89
        dex
        stx     $89
        bne     @cdc4
        stz     $80
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $29: big whale emerges 1 ]

Special_29:
@ce04:  jsr     _00cf98
@ce07:  jsr     _00cfb4
        lda     $7a
        and     #$07
        bne     @ce07
        inc     $24
        lda     $24
        cmp     #$30
        bne     @ce07
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $35: big whale returns to ocean ]

Special_35:
@ce1b:  jsr     _00cf98
        lda     #$01
        sta     $06c8
@ce23:  jsr     _00cfb4
        lda     #$24
        sec
        sbc     $24
        sta     $b9
        jsl     DrawWhale
        jsr     LoadWhaleFlashPal
        lda     $24
        cmp     #$24
        bcc     @ce63
        lda     #$68
        sta     $0300
        lda     #$78
        sta     $0304
        sta     $0301
        sta     $0305
        lda     $7a
        lsr2
        and     #$02
        clc
        adc     #$e4
        sta     $0302
        eor     #$02
        sta     $0306
        lda     #$37
        sta     $0303
        sta     $0307
@ce63:  lda     $7a
        and     #$07
        bne     @ce23
        inc     $24
        lda     $24
        cmp     #$48
        bne     @ce23
        stz     $c8
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $1f: big whale emerges 2 ]

Special_1f:
@ce76:  lda     #$01
        sta     $06c8
        jsr     _00cf98
@ce7e:  jsr     _00cfb4
        jsr     _00cec5
        lda     $7a
        and     #$07
        bne     @ce7e
        inc     $24
        lda     $24
        cmp     #$32
        bne     @ce7e
        stz     $24
@ce94:  jsr     _00cfb4
        lda     $24
        cmp     #$48
        bcs     @cea2
        clc
        adc     #$dc
        sta     $b9
@cea2:  jsl     DrawWhale
        jsr     LoadWhaleFlashPal
        lda     $24
        cmp     #$24
        bcs     @ceb2
        jsr     _00cec5
@ceb2:  lda     $7a
        and     #$07
        bne     @ce94
        inc     $24
        lda     $24
        cmp     #$64
        bne     @ce94
        stz     $c8
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [  ]

_00cec5:
@cec5:  lda     #$68
        sta     $0300
        lda     #$78
        sta     $0304
        sta     $0301
        sta     $0305
        lda     $7a
        lsr2
        and     #$02
        clc
        adc     #$e4
        sta     $0302
        eor     #$02
        sta     $0306
        lda     #$37
        sta     $0303
        sta     $0307
        rts

; ------------------------------------------------------------------------------

; [  ]

LoadWhaleFlashPal:
@ceef:  lda     $7a
        and     #$1e
        tay
        longa
        ldx     #0
@cef9:  lda     WhaleFlashPal,y
        sta     $0ebb,x
        tya
        inc2
        and     #$001f
        tay
        inx2
        cpx     #16
        bne     @cef9
        lda     #0
        shorta
        rts

; ------------------------------------------------------------------------------

; flashing big whale palette
WhaleFlashPal:
@cf13:  .word   $6108,$4010,$2118,$021f,$2318,$43f0,$6308,$7e00

; ------------------------------------------------------------------------------

; [ special effect $2a: big whale emerges 3 ]

Special_2a:
@cf23:  jsr     _00cf98
        lda     #$01
        sta     $06c8
        ldx     #0
@cf2e:  lda     $0ebb,x
        sta     $0a6d,x
        inx
        cpx     #$0010
        bne     @cf2e
        stz     $26
@cf3c:  jsr     _00cfb4
        lda     #$20
        sta     $b9
        jsl     DrawWhale
        lda     $7a
        lsr
        bcc     @cf4e
        inc     $26
@cf4e:  lda     $26
        bmi     @cf64
        asl
        sta     $22
        lda     $24
        clc
        adc     $22
        sta     $24
        bcs     @cf64
        jsr     LoadWhaleFlashPal
        jmp     @cf7d
@cf64:  and     #$f1
        cmp     #$80
        bne     @cf6e
        lda     #$01
        sta     $c4
@cf6e:  ldx     #0
@cf71:  lda     $0a6d,x
        sta     $0ebb,x
        inx
        cpx     #$0010
        bne     @cf71
@cf7d:  lda     $26
        cmp     #$ff
        bne     @cf3c
        stz     $c8
        lda     #1                      ; show big whale
        sta     $1724
        stz     $1727                   ; big whale is on overworld
        stz     $b9
        ldx     #$c796                  ; (150,199)
        stx     $1725
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [  ]

_00cf98:
@cf98:  lda     #$06
        sta     $1704
        lda     #$03
        sta     $1705
        lda     #$58
        sta     $2c
        lda     #$60
        sta     $2e
        jsr     LoadWhirlpoolPal
        stz     $79
        stz     $7a
        stz     $24
        rts

; ------------------------------------------------------------------------------

; [ draw frame (big whale in whirlpool) ]

_00cfb4:
@cfb4:  jsr     WaitFrame
        jsr     ResetSprites
        jsr     _00da94
        jsr     DrawWhirlpool
        jsr     ShiftWhirlpoolPal
        rts

; ------------------------------------------------------------------------------

; [ special effect $1d: pop map from stack ]

Special_1d:
@cfc4:  ldx     $172c
        dex3
        stx     $172c
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $1c: show enterprise near baron ]

Special_1c:
@cfd0:  stz     $171f                   ; enterprise is on overworld
        stz     $b7
        ldx     #$9e66                  ; (102,158)
        stx     $171d
        lda     #$01                    ; show enterprise
        sta     $171c
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $28: show enterprise near dwarf castle ]

Special_28:
@cfe3:  lda     #1                      ; enterprise is underground
        sta     $171f
        sta     $171c                   ; show enterprise
        stz     $b7
        ldx     #$5266                  ; (102,82)
        stx     $171d
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $19: crushing corridor 1 ]

Special_19:
@cff6:  lda     #$16
        sta     $212c
        lda     #$01
        sta     $c9
        ldx     #$0000
        stx     $5e
        ldx     #$02e0
        stx     $60
        jsr     _00d02f
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $1a: crushing corridor 2 ]

Special_1a:
@d00f:  ldx     #$0100
        stx     $5e
        ldx     #$02e0
        stx     $60
        jsr     _00d02f
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $1b: crushing corridor 3 ]

Special_1b:
@d01f:  ldx     #$0100
        stx     $5e
        ldx     #$01e0
        stx     $60
        jsr     _00d02f
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [  ]

_00d02f:
@d02f:  jsr     WaitVblankShort
        lda     $60
        sec
        sbc     #16
        sta     hBG2VOFS
        lda     $61
        sbc     #0
        sta     hBG2VOFS
        rts

; ------------------------------------------------------------------------------

; [ special effect $11: leviathan attack 3 ]

; ship gets sucked in

Special_11:
@d042:  jsr     LoadOverworldLeviathan
        lda     #$81                    ; enable nmi
        sta     hNMITIMEN
        lda     #$0f                    ; screen on, full brightness
        sta     hINIDISP
        stz     $ac
        stz     $79
        stz     $20
        stz     $7a
; start of frame loop
@d057:  lda     $7a
        lsr3
        and     #$03
        sta     $1705
        jsr     DrawLeviathanFrame
        lda     $7a
        and     #1
        bne     @d06f
        lda     #$04
        jmp     @d071
@d06f:  lda     #0
@d071:  sta     $ab
        jsr     MovePlayer
        jsr     DrawWhirlpool
        lda     $2c
        sta     $0340
        sta     $0300
        clc
        adc     #$10
        sta     $0344
        sta     $0304
        clc
        adc     #$10
        sta     $0348
        sta     $0308
        clc
        adc     #$10
        sta     $034c
        sta     $030c
        lda     #$68
        clc
        adc     $20
        cmp     #$78
        bcc     @d0a7
        lda     #$78
@d0a7:  sta     $0341
        sta     $0345
        sta     $0349
        sta     $034d
        lda     #$30
        sta     $0342
        lda     #$32
        sta     $0346
        lda     #$34
        sta     $034a
        lda     #$36
        sta     $034e
        lda     #$37
        sta     $0343
        sta     $0303
        sta     $0347
        sta     $0307
        sta     $034b
        sta     $030b
        sta     $034f
        sta     $030f
        lda     #$70
        sta     $0301
        sta     $0305
        sta     $0309
        sta     $030d
        lda     $7a
        lsr2
        and     #$02
        clc
        adc     #$e4
        sta     $0302
        eor     #$02
        sta     $0306
        eor     #$02
        sta     $030a
        eor     #$02
        sta     $030e
        lda     $7a
        and     #$07
        bne     @d112
        inc     $20
@d112:  lda     $7a
        and     #$03
        bne     @d11a
        inc     $2c
@d11a:  lda     $20
        cmp     #$20
        beq     @d123
        jmp     @d057
@d123:  stz     $1728
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $10: leviathan attack 2 ]

; leviathan appears

Special_10:
@d129:  jsr     LoadOverworldLeviathan
        lda     #$81
        sta     $4200                   ; enable nmi
        lda     #$0f
        sta     $2100                   ; screen on full brightness
        stz     $79
        stz     $20
@d13a:  lda     #$03
        sta     $1705
        jsr     DrawLeviathanFrame
        lda     #$10
        sta     $0340
        sta     $0300
        lda     #$20
        sta     $0344
        sta     $0304
        lda     #$30
        sta     $0348
        sta     $0308
        lda     #$40
        sta     $034c
        sta     $030c
        lda     #$78
        sec
        sbc     $20
        cmp     #$68
        bcs     @d16d
        lda     #$68
@d16d:  sta     $0341
        sta     $0345
        sta     $0349
        sta     $034d
        lda     #$30
        sta     $0342
        lda     #$32
        sta     $0346
        lda     #$34
        sta     $034a
        lda     #$36
        sta     $034e
        lda     #$37
        sta     $0343
        sta     $0303
        sta     $0347
        sta     $0307
        sta     $034b
        sta     $030b
        sta     $034f
        sta     $030f
        lda     #$70
        sta     $0301
        sta     $0305
        sta     $0309
        sta     $030d
        lda     $7a
        lsr2
        and     #$02
        clc
        adc     #$e4
        sta     $0302
        eor     #$02
        sta     $0306
        eor     #$02
        sta     $030a
        eor     #$02
        sta     $030e
        lda     $7a
        and     #$0f
        bne     @d1d8
        inc     $20
@d1d8:  lda     $20
        cmp     #$20
        beq     @d1e1
        jmp     @d13a
@d1e1:  jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $0f: leviathan attack 1 ]

; leviathan tail

Special_0f:
@d1e4:  jsr     LoadOverworldLeviathan
        lda     #$81
        sta     $4200                   ; enable nmi
        lda     #$0f
        sta     $2100                   ; screen on, full brightness
        ldx     #$0200
        stx     $89
        stz     $79
@d1f8:  lda     #$03
        sta     $1705
        jsr     DrawLeviathanFrame
        lda     #$28
        sta     $0340
        sta     $0300
        lda     $7a
        lsr4
        tax
        lda     LeviathanTailYTbl,x
        sta     $0341
        lda     #$30
        sta     $0342
        txa
        and     #$04
        asl4
        ora     #$37
        sta     $0343
        lda     #$70
        sta     $0301
        lda     $7a
        lsr2
        and     #$02
        clc
        adc     #$e4
        sta     $0302
        lda     #$37
        sta     $0303
        ldx     $89
        dex
        stx     $89
        bne     @d1f8
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

LeviathanTailYTbl:
@d246:  .byte   $74,$73,$71,$6f,$6c,$6a,$69,$68,$68,$69,$6a,$6c,$6f,$71,$73,$74

; ------------------------------------------------------------------------------

; [ draw frame (leviathan attack) ]

DrawLeviathanFrame:
@d256:  jsr     WaitFrame
        jsr     DrawWorldSprites
        jsr     _00da94
        jsr     ShiftWhirlpoolPal
        rts

; ------------------------------------------------------------------------------

; [ load overworld (leviathan attack) ]

LoadOverworldLeviathan:
@d263:  ldx     #$90a8
        stx     $1706
        lda     #$10
        sta     $2c
        lda     #$58
        sta     $2e
        jsl     InitHWRegs
        stz     $1700
        lda     #$07
        sta     $1704
        lda     #$01
        sta     $1728
        jsr     LoadOverworld
        lda     #$10
        sta     $ad
        jsr     LoadWhirlpoolPal
        jsr     ResetSprites
        jsr     DrawWhirlpool
        rts

; ------------------------------------------------------------------------------

; [ load whirlpool palette ]

LoadWhirlpoolPal:
@d293:  ldx     #0
@d296:  lda     f:MapSpritePal+33*16,x
        sta     $0e1b,x
        sta     $0aad,x
        lda     f:MapSpritePal+34*16,x
        sta     $0e3b,x
        inx
        cpx     #$0010
        bne     @d296
        rts

; ------------------------------------------------------------------------------

; [ draw whirlpool sprites ]

DrawWhirlpool:
@d2ae:  ldy     #$01c0
        ldx     #0
        stz     $0c
        stz     $0e
@d2b8:  lda     $0c
        clc
        adc     $2c
        sta     $0300,y
        lda     $0e
        clc
        adc     $2e
        sta     $0301,y
        lda     f:WhirlpoolSpriteTbl,x
        sta     $0302,y
        lda     f:WhirlpoolSpriteTbl+1,x
        sta     $0303,y
        lda     $0c
        clc
        adc     #$10
        and     #$3f
        sta     $0c
        bne     @d2e8
        lda     $0e
        clc
        adc     #$10
        sta     $0e
@d2e8:  inx2
        iny4
        cpx     #$0020
        beq     @d2fe
        cpx     #$0010
        bne     @d2b8
        ldy     #$0010
        jmp     @d2b8
@d2fe:  jsr     _00da94
        lda     #%10101010
        sta     $051c
        sta     $051d
        rts

; ------------------------------------------------------------------------------

; [ shift whirlpool palette ]

ShiftWhirlpoolPal:
@d30a:  lda     $7a
        and     #$03
        bne     @d341
        inc     $79
        lda     $79
        cmp     #$06
        bne     @d31a
        stz     $79
@d31a:  ldx     #0
        lda     $79
        asl
        tay
@d321:  lda     $0aaf,y
        sta     $0e1d,x
        lda     $0ab0,y
        sta     $0e1e,x
        inx2
        cpx     #14
        beq     @d341
        iny2
        cpy     #14
        bne     @d321
        ldy     #0
        jmp     @d321
@d341:  rts

; ------------------------------------------------------------------------------

; [ special effect $0d: show ship at fabul ]

Special_0d:
@d342:  lda     #$01                    ; ship is visible
        sta     $1728
        ldx     #$38de                  ; (222,56)
        stx     $1729
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $0a: return to previous map (warp) ]

Special_0a:
@d350:  ldx     $172c
        beq     @d35e
        dex3
        stx     $172c
        jsr     LoadMapStack
@d35e:  jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $0b: return to world map (exit) ]

Special_0b:
@d361:  ldx     #0
        stx     $172c
        jsr     LoadMapStack
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ load map from map stack ]

LoadMapStack:
@d36d:  stz     $ca
        ldx     $172c
        lda     $172e,x
        cmp     #$fb
        bcs     @d39e
        sta     $1702
        lda     #$03
        pha
        lda     $172f,x
        and     #$3f
        sta     $1706
        lda     $1730,x
        sta     $1707
        lda     $172f,x
        and     #$c0
        lsr6
        sta     $1705
        jmp     @d3ae
@d39e:  sec
        sbc     #$fb
        pha
        lda     $172f,x
        sta     $1706
        lda     $1730,x
        sta     $1707
@d3ae:  pla
        jsr     _00f167
        stz     $1e05
        jsl     ExecSound_ext
        jsr     PlayMapSong
        stz     $d6
        rts

; ------------------------------------------------------------------------------

; [ special effect $05: tent/cabin animation ]

Special_05:
@d3bf:  jsr     WaitFrame
        jsr     ResetSprites
        jsr     _00da94
        lda     $1700
        cmp     #$03
        beq     @d3d5
        jsr     DrawWorldSprites
        jmp     @d3d5
@d3d5:  ldx     #$7070
        stx     $0300
        lda     $1a03                   ; menu event (1: tent, 2: cabin)
        dec
        asl
        clc
        adc     #$e8
        sta     $0302
        lda     $1a03
        asl
        ora     #$31
        sta     $0303
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $09: prologue ]

Special_09:
@d3f2:  jsr     ScreenOff
        lda     #$17
        sta     $212c
        stz     $2130
        stz     $2131
        jsl     ClearBGGfx
        stz     $420b
        ldx     #.loword(PrologueBGGfx)
        stx     $4302
        lda     #.bankbyte(PrologueBGGfx)
        sta     $4304
        jsl     TfrBGGfx
        ldx     #0
@d419:  lda     f:ProloguePal,x
        sta     $0cdb,x
        inx
        cpx     #$0100
        bne     @d419
        lda     #$00
        jsr     ClearPrologueVRAM
        lda     #$80
        sta     $2115
        ldx     #$2800
        stx     $2116
        ldy     #$2000
        ldx     #$0800
@d43c:  sty     $2118
        dex
        bne     @d43c
        ldx     #$1a00
        stx     $47
        ldx     #$0300
        stx     $45
        ldx     #.loword(PrologueBG1Tiles)
        stx     $3d
        lda     #.bankbyte(PrologueBG1Tiles)
        sta     $3c
        jsl     TfrVRAM
        ldx     #$31c0
        stx     $47
        ldx     #$0380
        stx     $45
        ldx     #.loword(PrologueBG2Tiles)
        stx     $3d
        jsl     TfrVRAM
        ldx     #$4000
        stx     $47
        ldx     #$0080
        stx     $45
        ldx     #.loword(PrologueMoonGfx)
        stx     $3d
        lda     #.bankbyte(PrologueMoonGfx)
        sta     $3c
        jsl     TfrVRAM
        ldx     #0
@d486:  lda     f:PrologueMoonPal,x
        sta     $0ddb,x
        inx
        cpx     #16
        bne     @d486
        jsr     ResetSprites
        ldx     #0
@d499:  lda     f:PrologueSpriteTbl,x
        sta     $0300,x
        inx
        cpx     #16
        bne     @d499
        ldx     #0
        stx     $5a
        stx     $5c
        stx     $5e
        stx     $60
        stz     $0fe4
        lda     #$81                    ; enable nmi
        sta     hNMITIMEN
        lda     #7
        jsr     FadeIn
        lda     #1                      ; enable auto-scrolling dialogue
        sta     $cb
        lda     #$d0
        sta     $b2
        jsr     GetDlgPtr1H
        jsr     OpenDlgWindow
        jsr     CloseDlgWindow
        stz     $cb                     ; disable auto-scrolling dialogue
        jsr     FadeOutSongSlow
        lda     #7
        jsr     FadeOut
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $0e: tunnel to underground animation ]

; used when the tunnel opens or closes

Special_0e:
@d4dc:  jsl     InitHWRegs
        ldx     $1706
        phx
        ldx     #$d369
        stx     $1706
        stz     $1700
        jsr     LoadOverworld
        lda     #$20
        sta     $ad
        lda     #$10
        jsl     UpdateZoomPal
        lda     #$81
        sta     $4200                   ; enable nmi
        lda     #$03
        jsr     FadeIn
        ldx     #$0040
        jsr     WaitSpecial
        lda     #$01
        sta     $e3
        lda     #$20
        sta     $0acf
        lda     #$02
        sta     $0ad0
        lda     #$02
        sta     $0ad1
        ldx     #$7070
        stx     $0ad4
        ldx     #$0040
        stx     $0ad2
        stz     $0acd
        lda     #$02
        sta     $0ace
        lda     #$5e
        jsr     PlaySfx
        jsr     _00e075
@d539:  jsr     WaitFrame
        jsr     UpdateExplosions
        ldx     $0ad2
        cpx     #$0010
        bcs     @d54b
        txa
        sta     $2100                   ; set screen brightness
@d54b:  ldx     $0ad2
        bne     @d539
        plx
        stx     $1706
        stz     $e3
        stz     $80
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $04: rydia/titan battle and aftermath ]

Special_04:
@d55b:  lda     #$ec                    ; rydia/titan battle id
        sta     $1800
        stz     $1801
        lda     $0fdb                   ; default battle bg
        and     #$8f
        sta     $1802
        jsr     BattleSub
        jsr     FadeOutSongSlow
        jsl     InitHWRegs
        ldx     $1706
        phx
        ldx     #$7763
        stx     $1706
        stz     $1700
        jsr     LoadOverworld
        lda     #$20
        sta     $ad
        lda     #$81
        sta     $4200       ; enable nmi
        lda     #$03
        jsr     FadeIn
        ldx     #$0040
        jsr     WaitSpecial
        lda     #$01
        sta     $e3
        lda     #$20
        sta     $0acf
        lda     #$02
        sta     $0ad0
        lda     #$03
        sta     $0ad1
        ldx     #$7070
        stx     $0ad4
        ldx     #$0040
        stx     $0ad2
        stz     $0acd
        lda     #$02
        sta     $0ace
        lda     #$42
        sta     $1e01
        lda     #$01
        sta     $1e00
        jsl     ExecSound_ext
        jsr     _00e075
@d5d1:  jsr     WaitFrame
        jsr     UpdateExplosions
        ldx     $0ad2
        cpx     #$0010
        bcs     @d5e6
        txa
        sta     hINIDISP                 ; set screen brightness
        jsr     FadeOutSongSlow
@d5e6:  ldx     $0ad2
        bne     @d5d1
        plx
        stx     $1706
        stz     $e3
        stz     $80
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $03: red wings attack damcyan ]

Special_03:
@d5f6:  lda     #$04
        sta     $0acd
        stz     $0ace
        jsr     _00e075
        ldx     #0
        lda     #$ff
@d606:  sta     $0a6d,x
        inx4
        cpx     #$0060
        bne     @d606
        lda     #$3e
        jsr     PlaySongEvent
        ldx     #$0100
        stx     $2c
        ldx     #$0010
        stx     $2e
@d621:  jsr     WaitFrame
        jsr     ResetSprites
        jsr     DrawWorldSprites
        lda     $ad
        sec
        sbc     #$10
        jsl     UpdateZoomPal
        lda     $067a
        and     #$03
        bne     @d621
        lda     $ad
        inc
        sta     $ad
        cmp     #$20
        bne     @d621
@d643:  jsr     WaitFrame
        jsr     DrawDestroyedDamcyan
        jsr     ResetSprites64
        jsr     SetLargeSprite64
        stz     $79
@d651:  lda     $79
        asl
        tay
        longa
        lda     $2c
        clc
        adc     DamcyanRedWingsXTbl,y
        sta     $0c
        lda     $2e
        clc
        adc     DamcyanRedWingsYTbl,y
        sta     $0e
        lda     $79
        and     #$00ff
        asl4
        ora     #$0100
        tay
        lda     #0
        shorta
        lda     #$1c
        sta     $91
        lda     #$78
        sta     $8f
        lda     #$60
        sta     $92
        jsr     _00dfc4
        inc     $79
        lda     $79
        cmp     #$03
        bne     @d651
        stz     $e3
        lda     $2c
        cmp     #$40
        bcc     @d6eb
        cmp     #$90
        bcs     @d6eb
        lda     #$01
        sta     $e3
        lda     $2c
        and     #$07
        bne     @d6eb
        inc     $c4
        lda     #$23
        jsr     PlaySfx
        ldx     #0
@d6b0:  lda     $0a6d,x
        cmp     #$ff
        beq     @d6c2
        cmp     #$06
        bcs     @d6c2
        inx4
        jmp     @d6b0
@d6c2:  stz     $0a6d,x
        stz     $0a71,x
        stz     $0a75,x
        lda     $2c
        clc
        adc     #$20
        sta     $0a6e,x
        sta     $0a76,x
        sec
        sbc     #$10
        sta     $0a72,x
        lda     #$48
        sta     $0a6f,x
        lda     #$58
        sta     $0a73,x
        lda     #$68
        sta     $0a77,x
@d6eb:  stz     $24
        stz     $25
@d6ef:  ldx     $24
        lda     $0a6d,x
        bmi     @d708
        cmp     #$06
        bcs     @d708
        jsr     DrawExplosion
        lda     $7a
        and     #$07
        bne     @d708
        ldx     $24
        inc     $0a6d,x
@d708:  ldx     $24
        inx4
        stx     $24
        cpx     #$0060
        bne     @d6ef
        lda     $7a
        and     #$01
        bne     @d725
        ldx     $2c
        dex
        stx     $2c
        cpx     #$ffde
        beq     @d72e
@d725:  lda     $2c
        cmp     #$b0
        bcc     @d72b
@d72b:  jmp     @d643
@d72e:  lda     #$23
        jsr     PlaySongEvent
@d733:  jsr     WaitFrame
        jsr     ResetSprites
        jsr     DrawWorldSprites
        lda     $ad
        sec
        sbc     #$10
        jsl     UpdateZoomPal
        lda     $067a
        and     #$03
        bne     @d733
        lda     $ad
        dec
        sta     $ad
        cmp     #$10
        bne     @d733
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ draw destroyed damcyan castle ]

DrawDestroyedDamcyan:
@d758:  lda     $2c
        cmp     #$60
        bne     @d798
        stz     $2115
        lda     #$00
        tax
        tay
@d765:  lda     DestroyedDamcyanVRAMTbl,y
        sta     $2116
        lda     DestroyedDamcyanVRAMTbl+1,y
        sta     $2117
        lda     f:DestroyedDamcyanTiles,x
        sta     $2118
        lda     f:DestroyedDamcyanTiles+1,x
        sta     $2118
        lda     f:DestroyedDamcyanTiles+2,x
        sta     $2118
        lda     f:DestroyedDamcyanTiles+3,x
        sta     $2118
        iny2
        inx4
        cpx     #$0010
        bne     @d765
@d798:  rts

; ------------------------------------------------------------------------------

DamcyanRedWingsXTbl:
@d799:  .word   $0010,$0000,$0010

DamcyanRedWingsYTbl:
@d79f:  .word   $0010,$0020,$0030

DestroyedDamcyanVRAMTbl:
@d7a5:  .word   $396c,$39ec,$3a6c,$3aec

; ------------------------------------------------------------------------------

; [ special effect $31: cpu core destroyed ]

Special_31:
@d7ad:  lda     #$60
        sta     $0ad4
        lda     #$48
        sta     $0ad5
        jsr     _00d7f6
        jsr     WaitVblankShort
        lda     #$80
        sta     $2115
        ldx     #0
@d7c5:  txa
        and     #$03
        bne     @d7db
        txa
        lsr2
        asl
        tay
        lda     CPUCoreVRAMTbl,y
        sta     $2116
        lda     CPUCoreVRAMTbl+1,y
        sta     $2117
@d7db:  lda     #$01
        sta     $2118
        lda     #$15
        sta     $2119
        inx
        txa
        cmp     #$10
        bne     @d7c5
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; vram addresses for bg modification when cpu core is destroyed
CPUCoreVRAMTbl:
@d7ee:  .word   $1a50,$1a70,$1a90,$1ab0

; ------------------------------------------------------------------------------

; [  ]

_00d7f6:
@d7f6:  lda     #$20
        sta     $0acf
        lda     #$02
        sta     $0ad0
        sta     $0ad1
        ldx     #$0030
        stx     $0ad2
        lda     #$06
        sta     $0acd
        stz     $0ace
        jsr     _00e075
@d814:  jsr     WaitFrame
        jsr     _00edf6
        jsr     UpdateExplosions
        lda     $7a
        and     #$3f
        bne     @d828
        lda     #$23
        jsr     PlaySfx
@d828:  ldx     $0ad2
        bne     @d814
        jsr     ResetSprites64
        rts

; ------------------------------------------------------------------------------

; [ special effect $1e: super cannon destroyed ]

Special_1e:
@d831:  lda     #$70
        sta     $0ad4
        lda     #$10
        sta     $0ad5
        jsr     _00d7f6
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $3a: cid suicide bomb ]

Special_3a:
@d841:  lda     #$70
        sta     $0ad4
        lda     #$70
        sta     $0ad5
        jsr     _00d7f6
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $0c: tanks vs. red wings 2 ]

Special_0c:
@d851:  stz     $79
@d853:  lda     #$23
        jsr     PlaySfx
        lda     #$20
        sta     $0acf
        lda     #$02
        sta     $0ad0
        sta     $0ad1
        ldx     #$0008
        stx     $0ad2
        lda     #$06
        sta     $0acd
        stz     $0ace
        lda     $79
        asl
        tax
        lda     f:_14fc56,x
        sta     $0ad4
        lda     f:_14fc56+1,x
        sta     $0ad5
        jsr     _00e075
@d888:  jsr     WaitFrame
        jsr     _00edf6
        jsr     UpdateExplosions
        ldx     $0ad2
        cpx     #4
        bne     @d89d
        lda     #1
        sta     $e5
@d89d:  cpx     #0
        bne     @d888
        inc     $79
        lda     $79
        cmp     #$08
        bne     @d853
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $08: bomb ring 2 ]

Special_08:
@d8ad:  lda     #$51
        jsr     PlaySfx
        lda     #$60
        sta     $ad
        stz     $79
        stz     $7a
@d8ba:  jsr     WaitVblankShort
        lda     $7a
        and     #$1c
        lsr2
        tay
        lda     $83
        and     #$e0
        ora     _00d953,y
        sta     $2132
        lda     $7a
        and     #$0f
        bne     @d8d6
        inc     $79
@d8d6:  jsr     _00da94
        stz     $20
@d8db:  lda     $20
        tay
        lda     _00d95b,y
        clc
        adc     $06fb
        sta     $22
        asl
        clc
        adc     $22
        jsr     _00da79
        jsr     _00d96f
        lda     $20
        tay
        lda     _00d95b,y
        clc
        adc     #$40
        clc
        adc     $06fb
        asl
        jsr     _00da79
        jsr     _00d97f
        lda     $20
        and     #$03
        tax
        lda     _00d96b,x
        sta     $0302,y
        cmp     #$ec
        bne     @d91c
        lda     $7a
        and     #$04
        beq     @d91c
        lda     #$79
@d91c:  lda     #$39
        sta     $0303,y
        inc     $20
        lda     $20
        cmp     #$10
        beq     @d92c
        jmp     @d8db
@d92c:  inc     $06fb
        lda     $7a
        and     #$03
        bne     @d942
        lda     $79
        cmp     #$12
        bcs     @d940
        dec     $ad
        jmp     @d942
@d940:  inc     $ad
@d942:  lda     $ad
        cmp     #$62
        beq     @d94b
        jmp     @d8ba
@d94b:  lda     #$00
        jsr     PlaySfx
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

_00d953:
@d953:  .byte   $14,$18,$1c,$1f,$1c,$18,$14,$10

_00d95b:
@d95b:  .byte   $06,$04,$02,$00
        .byte   $46,$44,$42,$40
        .byte   $86,$84,$82,$80
        .byte   $c6,$c4,$c2,$c0

_00d96b:
@d96b:  .byte   $c4,$ec,$ec,$ec

; ------------------------------------------------------------------------------

; [  ]

_00d96f:
@d96f:  sta     $0300,y
        lda     $23
        and     #$01
        beq     @d97e
        lda     #0
        jsl     SetSpriteMSB
@d97e:  rts

; ------------------------------------------------------------------------------

; [  ]

_00d97f:
@d97f:  ldx     $22
        cpx     #$3ff0
        bcs     @d993
        cpx     #$00f0
        bcc     @d993
        lda     #$f0
        sta     $0301,y
        jmp     @d998
@d993:  lda     $22
        sta     $0301,y
@d998:  rts

; ------------------------------------------------------------------------------

; [ special effect $02: bomb ring 1 ]

Special_02:
@d999:  stz     $ad
        ldx     #0
        stx     $06fb
        stx     $24
        lda     #$c4
        sta     $8f
        lda     #$08
        sta     $90
        lda     #$39
        sta     $91
@d9af:  jsr     WaitVblankShort
        jsr     _00da21
        longa
        lda     $06fb                   ; increment angle
        inc
        sta     $06fb
        lda     $24                     ; increment radius
        inc
        sta     $24
        lsr2
        and     #$00ff
        shorta
        sta     $ad
        cmp     #$5f                    ; 95 frames
        beq     @d9d3
        jmp     @d9af
@d9d3:  jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $06: hp/mp restored animation ]

Special_06:
@d9d6:  lda     #$39
        sta     $91
        lda     #$c0
        jmp     _d9e5

; ------------------------------------------------------------------------------

; [ special effect $07: mist dragon attack effect ]

Special_07:
@d9df:  lda     #$35
        sta     $91
        lda     #$c6
_d9e5:  sta     $8f
        lda     #$5f
        sta     $ad
        ldx     #$017c                  ; 380/2 = 190 frames
        stx     $06fb
        stx     $24
        lda     #$10
        sta     $90
@d9f7:  jsr     WaitFrame
        jsr     _00da21
        longa
        lda     $06fb                   ; decrement angle
        dec2
        sta     $06fb
        lda     $24                     ; decrement radius
        dec2
        sta     $24
        lsr
        lsr
        and     #$00ff
        shorta
        sta     $ad
        beq     @da1b
        jmp     @d9f7
@da1b:  jsr     ResetSprites64
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [  ]

_00da21:
@da21:  jsr     _00da94
        stz     $20
        stz     $21
@da28:  longa
        lda     $20
        asl5
        clc
        adc     #$0100
        sta     $18
        lda     $06fb
        sta     $1a
        lda     #0
        shorta
        jsl     Mult16
        lda     $31
        jsr     _00da79
        jsr     _00d96f
        lda     $31
        clc
        adc     #$40
        jsr     _00da79
        jsr     _00d97f
        lda     $8f
        cmp     #$c0
        bne     @da65
        lda     $7a
        and     #$02
        clc
        adc     $8f
@da65:  sta     $0302,y
        lda     $91
        sta     $0303,y
        inc     $20
        lda     $20
        cmp     $90
        beq     @da78
        jmp     @da28
@da78:  rts

; ------------------------------------------------------------------------------

; [  ]

_00da79:
@da79:  jsr     CalcSine
        longa
        tya
        lsr2
        clc
        adc     #$0070
        sta     $22
        lda     #0
        shorta
        lda     $20
        asl2
        tay
        lda     $22
        rts

; ------------------------------------------------------------------------------

; [  ]

_00da94:
@da94:  lda     #%10101010
        ldx     #0
@da99:  sta     $0500,x
        inx
        cpx     #8
        bne     @da99
        rts

; ------------------------------------------------------------------------------

; [ special effect $00: red wings intro 1 ]

Special_00:
@daa3:  lda     #$e1
        sta     $1706       ; x position
        lda     #$fe
        sta     $1707       ; y position
        jsr     LoadOverworldIntro
        ldx     #$0080
        jsr     WaitSpecial
@dab6:  jsr     WaitVblankLong
        jsr     IncBrightness
        lda     #$08
        sta     $05
        lda     #1        ; enable player control
        sta     $d5
        jsr     DrawRedWings
        lda     $80
        cmp     #$0f
        bne     @dab6       ; wait for fade in
        ldx     #480      ; 480 frames (8 seconds)
        stx     $89
@dad2:  jsr     WaitVblankLong
        lda     #$08
        sta     $05
        jsr     DrawRedWings
        ldx     $89
        dex
        stx     $89
        bne     @dad2
@dae3:  jsr     WaitVblankLong
        jsr     DecBrightness
        lda     #$08
        sta     $05
        jsr     DrawRedWings
        lda     $80
        bne     @dae3
        lda     #$03        ; sub-map
        sta     $1700
        stz     $ac         ; clear movement speed
        stz     $1704       ; no vehicle
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $01: red wings intro 2 ]

Special_01:
@db01:  lda     #$65
        sta     $1706       ; x position
        lda     #$00
        sta     $1707       ; y position
        jsr     LoadOverworldIntro
@db0e:  jsr     WaitVblankLong
        jsr     IncBrightness
        lda     #$08
        sta     $05         ; set scroll speed
        jsr     DrawRedWings
        lda     $80
        cmp     #$0f
        bne     @db0e       ; wait for fade in
        ldx     #272      ; 272 frames (~4.5 seconds)
        stx     $89
@db26:  jsr     WaitVblankLong
        lda     #$08
        sta     $05         ; set scroll speed
        jsr     DrawRedWings
        ldx     $89
        dex
        stx     $89
        bne     @db26
        ldx     #64      ; 64 frames
        stx     $89
@db3c:  jsr     WaitVblankLong
        stz     $05         ; stop scrolling
        jsr     DrawRedWings
        ldx     $89
        dex
        stx     $89
        bne     @db3c
        jsr     FadeOutSongSlow
@db4e:  jsr     WaitVblankLong
        stz     $05
        jsr     DecBrightness
        lda     $80
        clc
        adc     #$10        ; mode 7 zoom = screen brightness + $10
        sta     $ad
        jsr     DrawRedWings
        lda     $80
        bne     @db4e
        lda     #$03
        sta     $1700
        stz     $ac
        stz     $1704
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ draw red wings sprites ]

DrawRedWings:
@db71:  jsr     ResetSprites
        stz     $04
        lda     #1        ; enable player control
        sta     $d5
        jsr     CheckPlayerMoveWorld
        jsr     MovePlayer
        ldy     #0
@db83:  tya
        lsr3
        tax
        lda     RedWingsIntroPos,x     ; x position
        sta     $0c
        lda     RedWingsIntroPos+1,x     ; y position
        sta     $0e
        jsr     _00e013
        lda     #$1c
        sta     $91
        lda     #$78
        sta     $8f
        stz     $0d
        stz     $0f
        stz     $92
        jsr     _00dfc4
        cpy     #$0050
        bne     @db83
        rts

; ------------------------------------------------------------------------------

; [ decrement screen brightness ]

DecBrightness:
@dbac:  lda     $7a
        and     #$07
        bne     @dbb8
        lda     $80
        beq     @dbb8
        dec     $80
@dbb8:  lda     $80
        sta     $2100       ; set screen brightness
        rts

; ------------------------------------------------------------------------------

; [ increment screen brightness ]

IncBrightness:
@dbbe:  lda     $7a
        and     #$07
        bne     @dbcc
        lda     $80
        cmp     #$0f
        beq     @dbcc
        inc     $80
@dbcc:  lda     $80
        sta     $2100       ; set screen brightness
        rts

; ------------------------------------------------------------------------------

; [ load world map for red wings intro ]

LoadOverworldIntro:
@dbd2:  stz     $1700       ; overworld
        lda     #$04        ; enterprise
        sta     $1704
        jsr     LoadOverworld
        lda     #$20
        sta     $ad         ; mode 7 zoom
        lda     #$10
        jsl     UpdateZoomPal
        lda     #$02
        sta     $ac         ; movement speed
        lda     #$81
        sta     $4200       ; enable nmi
        stz     $2100       ; screen on, zero brightness
        stz     $80
        stz     $7b
        stz     $7a
        rts

; ------------------------------------------------------------------------------

; red wings sprite xy positions (5 * 2 bytes)
RedWingsIntroPos:
@dbfa:  .byte   $70,$70,$64,$7c,$7c,$7c,$54,$8c,$8c,$8c

; ------------------------------------------------------------------------------

; [ special effect $15: land enterprise (after tower of zot) ]

Special_15:
@dc04:  lda     #$10
        sta     $a2
        jsr     LandEnterprise
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $12: red wing approaches enterprise ]

Special_12:
@dc0e:  ldx     #$0100
        stx     $2c
        ldx     #$0070
        stx     $2e
        ldx     #$00d0
        stx     $89
@dc1d:  jsr     _00dd58
        ldx     $2c
        dex
        stx     $2c
        cpx     #$0070
        bcs     @dc2f
        ldx     #$0070
        stx     $2c
@dc2f:  ldx     $89
        dex
        stx     $89
        bne     @dc1d
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $13: red wing departs enterprise ]

Special_13:
@dc39:  ldx     #$0070
        stx     $2c
        ldx     #$0070
        stx     $2e
        ldx     #$00d0
        stx     $89
@dc48:  jsr     _00dd58
        ldx     $89
        dex
        stx     $89
        cpx     #$0080
        bcs     @dc48
        ldx     $2c
        dex
        stx     $2c
        cpx     #$fff0
        bne     @dc48
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $14: travel to tower of zot ]

; this is the first time the party enters the tower

Special_14:
@dc62:  ldx     #$0070
        stx     $2c
        ldx     #$0078
        stx     $2e
        ldx     #$00d0
        stx     $89
@dc71:  jsr     WaitVblankLong
        lda     $2e
        cmp     #$10
        bcs     @dc7d
        sta     $2100       ; set screen brightness
@dc7d:  jsr     _00dd3a
        ldx     $2c
        stx     $0c
        lda     $2e
        sec
        sbc     #$08
        sta     $0e
        lda     $2f
        sbc     #$00
        sta     $0f
        lda     #$1c
        sta     $91
        lda     #$d8
        sta     $8f
        ldy     #$0190
        lda     #$60
        sta     $92
        jsr     _00dfc4
        ldy     #$0070
        sty     $0e
        ldy     #$0150
        jsr     _00e013
        ldy     #$0068
        sty     $0e
        ldy     #$0160
        jsr     _00e013
        ldx     $89
        dex
        stx     $89
        cpx     #$0080
        bcs     @dc71
        ldx     $2e
        dex
        stx     $2e
        cpx     #$0000
        bne     @dc71
        stz     $80
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $2b: enter tower of zot ]

; this is used if the player leaves and then re-enters the tower

Special_2b:
@dcd2:  ldx     #$0070
        stx     $2c
        ldx     #$0078
        stx     $2e
@dcdc:  jsr     WaitVblankLong
        lda     $2e
        cmp     #$10
        bcs     @dce8
        sta     $2100       ; set screen brightness
@dce8:  jsr     _00dd3a
        ldy     #$0078
        sty     $0e
        ldy     #$0150
        jsr     _00e013
        ldx     $2e
        dex
        stx     $2e
        cpx     #0
        bne     @dcdc
        stz     $80
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $2c: exit tower of zot ]

; the party uses the teleporter at start of the tower

Special_2c:
@dd05:  lda     #$0f
        sta     $80
        ldx     #$0070
        stx     $2c
        ldx     #0
        stx     $2e
@dd13:  jsr     WaitVblankLong
        lda     $2e
        cmp     #$10
        bcs     @dd1f
        sta     $2100       ; set screen brightness
@dd1f:  jsr     _00dd3a
        ldy     #$0078
        sty     $0e
        ldy     #$0150
        jsr     _00e013
        ldx     $2e
        inx
        stx     $2e
        cpx     #$0078
        bne     @dd13
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [  ]

_00dd3a:
@dd3a:  jsr     ResetSprites
        ldx     $2c
        stx     $0c
        ldx     $2e
        stx     $0e
        lda     #$18
        sta     $91
        lda     #$78
        sta     $8f
        ldy     #$0180
        lda     #$60
        sta     $92
        jsr     _00dfc4
        rts

; ------------------------------------------------------------------------------

; [  ]

_00dd58:
@dd58:  jsr     WaitVblankLong
        jsr     ResetSprites
        jsl     DrawEnterprise
        ldx     $2c
        stx     $0c
        ldx     $2e
        stx     $0e
        lda     #$1c
        sta     $91
        lda     #$78
        sta     $8f
        ldy     #$0180
        lda     #$60
        sta     $92
        jsr     _00dfc4
        ldy     #$0070
        sty     $0e
        ldy     #$0140
        jsr     _00e013
        rts

; ------------------------------------------------------------------------------

; [ special effect $17: red wings chase enterprise 1 ]

; moving down

Special_17:
@dd88:  jsr     _00de04
        ldx     #$00c0
        stx     $89
@dd90:  jsr     WaitVblankLong
        ldx     $89
        cpx     #$000f
        bcs     @dd9e
        txa
        sta     $2100       ; set screen brightness
@dd9e:  jsr     ResetSprites
        jsl     DrawEnterprise
        jsr     _00de2a
        lda     #$40
        jsr     _00de43
        lda     #$04
        sta     $05
        stz     $04
        jsr     _00de1b
        ldx     $89
        dex
        stx     $89
        bne     @dd90
        stz     $80
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ special effect $18: red wings chase enterprise 2 ]

; moving right

Special_18:
@ddc2:  jsr     _00de04
        ldx     #$00b6
        stx     $89
@ddca:  jsr     WaitVblankLong
        ldx     $89
        cpx     #$000f
        bcs     @ddd8
        txa
        sta     $2100       ; set screen brightness
@ddd8:  jsr     ResetSprites
        jsl     DrawEnterprise
        jsr     _00de2a
        ldx     $2c
        ldy     $2e
        stx     $2e
        sty     $2c
        lda     #$20
        jsr     _00de43
        lda     #$01
        sta     $05
        stz     $04
        jsr     _00de1b
        ldx     $89
        dex
        stx     $89
        bne     @ddca
        stz     $80
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [  ]

_00de04:
@de04:  lda     #$04
        sta     $1704
        lda     #$10
        sta     $b7
        lda     #$0f
        sta     $06fd       ; set airship animation speed
        lda     #$03
        sta     $ac
        lda     #$20
        sta     $ad
        rts

; ------------------------------------------------------------------------------

; [  ]

_00de1b:
@de1b:  lda     #$01        ; enable player control
        sta     $d5
        jsr     CheckPlayerMoveWorld
        jsr     MovePlayer
        lda     #$20
        sta     $ad
        rts

; ------------------------------------------------------------------------------

; [  ]

_00de2a:
@de2a:  lda     $7a
        lsr2
        and     #$1f
        tax
        lda     f:_14fb86,x
        clc
        adc     #$70
        sta     $2c
        stz     $2d
        lda     #$50
        sta     $2e
        stz     $2f
        rts

; ------------------------------------------------------------------------------

; [  ]

_00de43:
@de43:  pha
        ldy     #$01d0
        lda     #$1c
        sta     $91
        lda     #$78
        sta     $8f
        ldx     $2c
        stx     $0c
        ldx     $2e
        stx     $0e
        lda     #$20
        sta     $ad
        pla
        sta     $92
        jsr     _00dfc4
        ldy     #$0190
        jsr     _00e013
        rts

; ------------------------------------------------------------------------------

; [ special effect $16: tanks vs. red wings 1 ]

; this occurs when the player first enters the underground

Special_16:
@de68:  lda     #$20
        sta     $0acf
        lda     #$00
        sta     $0ad0
        sta     $0ad1
        ldx     #$0040
        stx     $0ad2
        lda     #$01
        sta     $0acd
        stz     $0ace
        lda     #$40        ; animation loop count: 64
        sta     $0ad4
        sta     $0ad5
        jsr     _00e075
        ldx     #$00ff
        stx     $f3
        ldx     #0
        stx     $f5
; start of animation loop
@de98:  jsr     WaitFrame
        jsr     ResetSprites
        ldx     $f3
        dex
        stx     $f3
        cpx     #$00c0
        bcs     @debf
        ldx     #$00c0
        stx     $f3
        lda     #$01
        sta     $e3
        jsr     UpdateExplosions
        lda     $7a
        and     #$3f
        bne     @debf
        lda     #$23
        jsr     PlaySfx
@debf:  ldx     #$0070
        stx     $0c
        stx     $0e
        ldy     #$01c0
        lda     #$1c
        sta     $91
        lda     #$78
        sta     $8f
        lda     #$40
        sta     $92
        jsr     _00dfc4
        lda     #$80
        sta     $0e
        ldy     #$0180
        jsr     _00e013
        lda     #$1c
        sta     $91
        lda     #$78
        sta     $8f
        lda     #$60
        sta     $92
        jsr     _00df53
        lda     #$00
        sec
        sbc     $f3
        sta     $ef
        stz     $f0
        stz     $f1
        stz     $f2
        stz     $79
@df00:  lda     $79
        asl
        tay
        jsr     _00df93
        lda     #$20
        sta     $92
        jsr     _00dfc4
        inc     $79
        lda     $79
        cmp     #$04        ;  wait 4 frames
        bne     @df00
        ldx     $0ad2
        beq     @df1e
        jmp     @de98
@df1e:  stz     $e3
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; airship/tank position data
_00df23:
@df23:  .byte   $00,$00,$18,$00,$00,$00,$18,$00  ; airship x positions
_00df2b:
@df2b:  .byte   $40,$00,$60,$00,$80,$00,$a0,$00  ; airship y positions
_00df33:
@df33:  .byte   $f8,$ff,$d0,$ff,$f8,$ff,$d0,$ff  ; tank x positions
        .byte   $20,$00,$32,$00,$44,$00,$56,$00
_00df43:
@df43:  .byte   $50,$00,$70,$00,$90,$00,$c0,$00  ; tank y positions
        .byte   $08,$00,$18,$00,$08,$00,$18,$00

; ------------------------------------------------------------------------------

; [  ]

_00df53:
@df53:  stz     $79
@df55:  lda     $79
        asl
        tay
        longa
        lda     _00df23,y
        clc
        adc     $f3
        sta     $0c
        lda     _00df2b,y
        clc
        adc     $f5
        sta     $0e
        lda     $79
        and     #$00ff
        asl4
        ora     #$0080
        tay
        lda     #0
        shorta
        jsr     _00dfc4
        lda     $0e
        clc
        adc     #$10
        sta     $0e
        jsr     _00e013
        inc     $79
        lda     $79
        cmp     #$04
        bne     @df55
        rts

; ------------------------------------------------------------------------------

; [  ]

_00df93:
@df93:  longa
        lda     _00df33,y
        clc
        adc     $ef
        sta     $0c
        lda     _00df43,y
        clc
        adc     $f1
        sta     $0e
        tya
        and     #$0007
        lsr
        and     #$00ff
        asl4
        clc
        adc     #$0144
        tay
        lda     #0
        shorta
        lda     #$18
        sta     $91
        lda     #$a8
        sta     $8f
        rts

; ------------------------------------------------------------------------------

; [ draw tank sprite ??? ]

_00dfc4:
@dfc4:  lda     $7a
        and     #$02
        asl3
        clc
        adc     $92
        tax
@dfcf:  lda     f:VehicleSpriteTbl,x
        clc
        adc     $0c
        sta     $0300,y
        lda     $0d
        adc     #$00
        and     #$01
        beq     @dfe7
        lda     #$00
        jsl     SetSpriteMSB
@dfe7:  lda     f:VehicleSpriteTbl+1,x
        clc
        adc     $0e
        sec
        sbc     $ad
        clc
        adc     #$08
        sta     $0301,y
        lda     f:VehicleSpriteTbl+2,x
        clc
        adc     $8f
        sta     $0302,y
        lda     f:VehicleSpriteTbl+3,x
        ora     $91
        sta     $0303,y
        jsr     NextSprite
        txa
        and     #$0f
        bne     @dfcf
        rts

; ------------------------------------------------------------------------------

; [ draw airship sprite ??? ]

_00e013:
@e013:  lda     $ad
        cmp     #$20
        beq     @e01f
        lda     $7a
        lsr
        bcc     @e01f
        rts
@e01f:  lda     $ad
        sec
        sbc     #$10
        and     #$fc
        tax
        lda     $0c
        sta     $0350,y
        lda     $0d
        and     #$01
        beq     @e038
        lda     #$14
        jsl     SetSpriteMSB
@e038:  lda     $0e
        sta     $0351,y
        lda     f:_15b8c9,x
        sta     $0352,y
        lda     f:_15b8c9+1,x
        sta     $0353,y
        lda     $0c
        clc
        adc     #$08
        sta     $0354,y
        lda     $0d
        adc     #$00
        and     #$01
        beq     @e061
        lda     #$15
        jsl     SetSpriteMSB
@e061:  lda     $0e
        sta     $0355,y
        lda     f:_15b8c9+2,x
        sta     $0356,y
        lda     f:_15b8c9+3,x
        sta     $0357,y
        rts

; ------------------------------------------------------------------------------

; [  ]

_00e075:
@e075:  stz     $e5
        lda     $0acd
        asl5
        tay
        ldx     #0
@e083:  lda     $0ace
        bne     @e092
        lda     f:MapSpritePal+31*16,x   ; explosion palette
        sta     $0ddb,y
        jmp     @e099
@e092:  lda     f:MapSpritePal+32*16,x
        sta     $0dfb,y
@e099:  iny
        inx
        cpx     #$0010
        bne     @e083
        ldx     #0
@e0a3:  txa
        lsr2
        and     #$03
        eor     #$ff
        sta     $0a6d,x     ; $ff, $fe, $fd, $fc, repeat
        inx4
        cpx     #$0040
        bne     @e0a3
        rts

; ------------------------------------------------------------------------------

; [ update explosion sprites ]

UpdateExplosions:
@e0b7:  jsr     ResetSprites64
        jsr     SetLargeSprite32
        ldx     #0
        stx     $24
@e0c2:  ldx     $24
        lda     $7a
        and     #$07
        bne     @e0cd
        inc     $0a6d,x
@e0cd:  lda     $0a6d,x
        bpl     @e0d5
        jmp     @e13d
@e0d5:  beq     @e0db
        cmp     #$04
        bne     @e132
@e0db:  lda     $7a
        and     #$07
        bne     @e132
        lda     $e5
        bne     @e138
        stz     $0a6d,x
        lda     $c7
        bne     @e115
        lda     $0ad0
        tax
        jsr     Rand
        and     _00e1bc,x
        clc
        adc     $0ad4
        ldx     $24
        sta     $0a6e,x
        lda     $0ad1
        tax
        jsr     Rand
        and     _00e1bc,x
        clc
        adc     $0ad5
        ldx     $24
        sta     $0a6f,x
        jmp     @e132
@e115:  lda     $c7
        dec
        and     #$0f
        asl
        tay
        lda     ExplosionPosTbl,y     ; x position on a circle
        clc
        adc     $0ad4
        sta     $0a6e,x
        lda     ExplosionPosTbl+1,y     ; y position on a circle
        clc
        adc     $0ad5
        sta     $0a6f,x
        inc     $c7
@e132:  jsr     DrawExplosion
        jmp     @e13d
@e138:  lda     #$ff
        sta     $0a6d,x
@e13d:  lda     $24
        clc
        adc     #$04
        sta     $24
        cmp     $0acf
        beq     @e14c
        jmp     @e0c2
@e14c:  lda     $7a
        and     #$07
        bne     @e159
        ldx     $0ad2
        dex
        stx     $0ad2
@e159:  rts

; ------------------------------------------------------------------------------

; [ draw explosion sprite ??? ]

DrawExplosion:
@e15a:  lda     $0a6d,x
        tay
        lda     _00e1b4,y
        tay
        lda     $0a6e,x
        sta     $20
        lda     $0a6f,x
        sta     $21
        lda     $24
        asl2
        tax
        phx
        phy
        plx
        ply
@e175:  lda     $20
        clc
        adc     f:_14f9d6,x
        sta     $0300,y
        lda     f:_14f9d6+1,x
        cmp     #$ff
        beq     @e191
        lda     $21
        clc
        adc     f:_14f9d6+1,x
        jmp     @e193
@e191:  lda     #$f0
@e193:  sta     $0301,y
        lda     f:_14f9d6+2,x
        sta     $0302,y
        lda     $0acd
        asl
        ora     $0ace
        ora     f:_14f9d6+3,x
        sta     $0303,y
        jsr     NextSprite
        txa
        and     #$0f
        bne     @e175
        rts

; ------------------------------------------------------------------------------

_00e1b4:
@e1b4:  .byte   $00,$10,$20,$30,$20,$30,$20,$30

_00e1bc:
@e1bc:  .byte   $7c,$3c,$1c,$0c

; ------------------------------------------------------------------------------

; [ set large sprite flag (32 sprites) ]

SetLargeSprite32:
@e1c0:  ldx     #0
        lda     #%10101010
@e1c5:  sta     $0500,x
        inx
        cpx     #8
        bne     @e1c5
        rts

; ------------------------------------------------------------------------------

; [ set large sprite flag (64 sprites) ]

SetLargeSprite64:
@e1cf:  ldx     #0
        lda     #%10101010
@e1d4:  sta     $0500,x
        inx
        cpx     #16
        bne     @e1d4
        rts

; ------------------------------------------------------------------------------

; [ wait ]

; x: number of frames

WaitSpecial:
@e1de:  stx     $89
@e1e0:  jsr     WaitVblankLong
        ldx     $89
        dex
        stx     $89
        bne     @e1e0
        rts

; ------------------------------------------------------------------------------
