
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: hardware.asm                                                         |
; |                                                                            |
; | description: system hardware routines                                      |
; |                                                                            |
; | created: 3/27/2022                                                         |
; +----------------------------------------------------------------------------+

; [ init hardware registers ]

InitHWRegs:
@c8df:  lda     #$80
        sta     hINIDISP
        lda     #0
        sta     hNMITIMEN
        lda     #2
        sta     hOBJSEL
        stz     hOAMADDL
        stz     hOAMADDH
        stz     hMOSAIC
        lda     #$19
        sta     hBG1SC
        lda     #$33
        sta     hBG2SC
        lda     #$29
        sta     hBG3SC
        lda     #$00
        sta     hBG12NBA
        lda     #$02
        sta     hBG34NBA
        stz     hBG3HOFS
        stz     hBG3HOFS
        stz     hBG3VOFS
        stz     hBG3VOFS
        lda     #$80
        sta     hVMAINC
        stz     hM7SEL
        stz     hM7A
        lda     #$04
        sta     hM7A
        stz     hM7B
        stz     hM7B
        stz     hM7C
        stz     hM7C
        stz     hM7D
        lda     #$04
        sta     hM7D
        lda     #$80
        sta     hM7X
        sta     hM7X
        sta     hM7Y
        sta     hM7Y
        sta     hCGADD
        lda     #$33
        sta     hW12SEL
        lda     #$00
        sta     hW34SEL
        lda     #$f3
        sta     hWOBJSEL
        lda     #$01
        sta     hWH0
        lda     #$fe
        sta     hWH1
        stz     hWH2
        lda     #$ff
        sta     hWH3
        stz     hWBGLOG
        stz     hWOBJLOG
        lda     #$17
        sta     hTM
        lda     #$11
        sta     hTS
        lda     #$17
        sta     hTMW
        stz     hTSW
        lda     #$e0
        sta     hCOLDATA
        stz     hSETINI
        lda     #$ff
        sta     hWRIO
        stz     hHTIMEL
        stz     hHTIMEH
        stz     hVTIMEL
        stz     hVTIMEH
        stz     hMDMAEN
        stz     hHDMAEN
        rtl

; ------------------------------------------------------------------------------

; [ clear ram ]

ClearRAM:
@c9aa:  ldx     #0
@c9ad:  lda     $1900,x
        cmp     f:RNGTbl,x              ; rng table
        bne     @c9bf
        inx
        cpx     #$0100
        beq     @c9cb
        jmp     @c9ad
; rng table not loaded (hard reset)
@c9bf:  ldx     #$1a00
@c9c2:  stz     a:$0000,x               ; clear menu ram ($1a00-$1a64)
        inx
        cpx     #$1a65
        bne     @c9c2
@c9cb:  ldx     #0
@c9ce:  stz     a:$0000,x               ; clear battle and menu dp ($0000-$01ff)
        inx
        cpx     #$0200
        bne     @c9ce
        ldx     #sprite_ram
@c9da:  stz     a:$0000,x               ; clear ram ($0300-$19ff)
        inx
        cpx     #$0fff                  ; skip frame counter ($0fff)
        bne     @c9da
        inx
@c9e4:  stz     a:$0000,x
        inx
        cpx     #$1a00
        bne     @c9e4
        ldx     #$1a65
@c9f0:  stz     a:$0000,x               ; clear more ram ($1a65-$1dff)
        inx
        cpx     #$1e00
        bne     @c9f0
        ldx     #$2000
        lda     #0
@c9fe:  sta     $7e0000,x               ; clear work ram ($7e2000-$7fffff)
        inx
        bne     @c9fe
@ca05:  sta     $7f0000,x
        inx
        bne     @ca05
        ldx     #0
@ca0f:  lda     f:RNGTbl,x              ; copy rng table to buffer
        sta     $1900,x
        inx
        cpx     #$0100
        bne     @ca0f
        rtl

; ------------------------------------------------------------------------------

; [ reset controller inputs ]

; clears flags that ensure that each input is only processed once

ResetButtons:
@ca1d:  lda     $02         ; A button
        and     #JOY_A
        bne     @ca25
        stz     $54
@ca25:  lda     $02         ; X button
        and     #JOY_X
        bne     @ca2d
        stz     $50
@ca2d:  lda     $02         ; top left button
        and     #JOY_L
        bne     @ca35
        stz     $52
@ca35:  lda     $02         ; top right button
        and     #JOY_R
        bne     @ca3d
        stz     $53
@ca3d:  lda     $03         ; B button
        and     #JOY_B
        bne     @ca45
        stz     $55
@ca45:  lda     $03         ; Y button
        and     #JOY_Y
        bne     @ca4d
        stz     $51
@ca4d:  lda     $03         ; select button
        and     #JOY_SELECT
        bne     @ca55
        stz     $56
@ca55:  lda     $03         ; start button
        and     #JOY_START
        bne     @ca5d
        stz     $57
@ca5d:  rtl

; ------------------------------------------------------------------------------

; [ transfer palettes to ppu ]

TfrPal:
@ca5e:  stz     hMDMAEN
        stz     hCGADD
        lda     #$02
        sta     hDMAP0
        lda     #<hCGDATA
        sta     hDMAB0
        lda     #$00
        sta     hDMAAB0
        ldx     #$0cdb
        stx     hDMAAL0
        ldx     #$0200
        stx     hDMADL0
        lda     #1
        sta     hMDMAEN
        rtl

; ------------------------------------------------------------------------------

; [ transfer data to vram ]

TfrVRAM:
@ca85:  lda     #$80
        sta     hVMAINC
        stz     hMDMAEN
        lda     #$01
        sta     hDMAP0
        lda     #<hVMDATAL
        sta     hDMAB0
        lda     $3c
        sta     hDMAAB0
        ldx     $47
        stx     hVMADDL
        ldx     $3d
        stx     hDMAAL0
        ldx     $45
        stx     hDMADL0
        lda     #1
        sta     hMDMAEN
        rtl

; ------------------------------------------------------------------------------

; [ clear vram ]

ClearVRAM:
@cab1:  lda     #$80
        sta     hVMAINC
        stz     hMDMAEN
        lda     #$09
        sta     hDMAP0
        lda     #<hVMDATAL
        sta     hDMAB0
        ldx     $47
        stx     hVMADDL
        ldx     #$0676
        stx     hDMAAL0
        stz     hDMAAB0
        ldx     $45
        stx     hDMADL0
        lda     #1
        sta     hMDMAEN
        rtl

; ------------------------------------------------------------------------------

; [ transfer sprite data to ppu ]

TfrSprites:
@cadc:  stz     hOAMADDL
        stz     hMDMAEN
        stz     hDMAP0
        lda     #<hOAMDATA
        sta     hDMAB0
        ldx     #$0300
        stx     hDMAAL0
        lda     #$00
        sta     hDMAAB0
        ldx     #$0220
        stx     hDMADL0
        lda     #1
        sta     hMDMAEN
        rtl

; ------------------------------------------------------------------------------
