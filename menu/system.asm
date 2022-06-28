
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: system.asm                                                           |
; |                                                                            |
; | description: system routines                                               |
; |                                                                            |
; | created: 3/15/2022                                                         |
; +----------------------------------------------------------------------------+

.segment "menu_code3"

InitCtrl_ext2:
@fd00:  jmp   InitCtrl

UpdateCtrl_ext:
@fd03:  jmp   UpdateCtrl

ClearText_ext:
@fd06:  jmp   ClearText

UpdateWindowColor_ext:
@fd09:  jmp   UpdateWindowColor

UpdateScrollRegs_ext:
@fd0c:  jmp   UpdateScrollRegs

SaveDlgGfx_ext:
@fd0f:  jmp   SaveDlgGfx

; ------------------------------------------------------------------------------

; [ update controller ]

UpdateCtrl:
@fd12:  phb
        phx
        phy
        phd
        lda     #0
        pha
        plb
        ldx     #menu_dp
        phx
        pld
@fd1f:  lda     hHVBJOY       ; wait for hardware to read controller data
        and     #$01
        bne     @fd1f
        stz     $ec
        ldy     #hSTDCNTRL1L
        ldx     #4
        lda     #4
@fd30:  pha
        phy
        jsr     ReadCtrl
        ply
        pla
        inx
        iny
        dec
        bne     @fd30
        lda     $1a64       ; controller setting (default or custom)
        and     #1
        asl2
        sta     $1d
        asl
        adc     $1d
        asl
        sta     $43
        ldx     $43         ; 0 or 24
        longa
        lda     $04         ; controller 1 buttons
        phx
        ldy     #12
        sta     $1d
        lda     #0
@fd5a:  asl     $1d
        bcc     @fd62
        ora     f:$001a05,x   ; apply button mapping
@fd62:  inx2
        dey
        bne     @fd5a
        plx
        sta     $1f
        lda     $08         ; controller 2 buttons
        ldy     #12
        sta     $1d
        lda     #0
@fd74:  asl     $1d
        bcc     @fd7c
        ora     f:$001a05,x   ; apply button mapping
@fd7c:  inx2
        dey
        bne     @fd74
        pld
        sta     $02         ; set mapped controller 2 buttons
        lda     f:$00011f
        sta     $00         ; set mapped controller 1 buttons
        shorta
        ply
        plx
        plb
        rtl

; ------------------------------------------------------------------------------

; [ read controller register ]

; +Y: controller hardware register address
; +X: dp offset for this register

ReadCtrl:
@fd90:  lda     $16b8                   ; multi-controller flag
        and     $40                     ; in-battle flag
        beq     @fdb4                   ; branch unless both flags are set
        lda     f:$001822               ; selected character
        sta     $43
        phy
        ldy     $43
        lda     $16b9,y                 ; controller for this character (0 or 2)
        ply
        sta     $43
        longa
        tya
        clc
        adc     $43
        tay
        shorta
        lda     a:$0000,y
        bra     @fdba
@fdb4:  lda     a:$0000,y               ; combine input from both controllers
        ora     a:$0002,y
@fdba:  beq     @fdc0                   ; branch if no buttons pressed
        cmp     $04,x
        beq     @fdc9                   ; branch if no changes
@fdc0:  sta     $04,x
        sta     $00,x
        lda     #$18                    ; set first repeat counter
        sta     $08,x
        rts
; buttons held (unchanged from previous frame)
@fdc9:  dec     $08,x                   ; decrement repeat counter
        beq     @fdd0
        stz     $00,x
        rts
@fdd0:  lda     #$03                    ; set multi-repeat counter
        sta     $08,x
        lda     $04,x
        sta     $00,x
        rts

; ------------------------------------------------------------------------------

; [ init controller ]

InitCtrl:
@fdd9:  phb
        phd
        ldx     #menu_dp
        phx
        pld
        longa
        lda     #$0017      ; load default button mapping
        ldx     #.loword(BtnDefault)
        ldy     #$1a05
        mvn     #^BtnDefault,#$7e
        lda     #$0017
        ldx     #.loword(BtnDefault)
        ldy     #$1a1d
        mvn     #^BtnDefault,#$7e
        shorta
        lda     $16a9
        sta     $1a64
        lda     $1a3a
        asl
        sta     $43
        ldx     $43
        longa
        stz     $1a2d       ; clear A, B, X, Y, and select buttons
        stz     $1a1d
        stz     $1a2f
        stz     $1a1f
        stz     $1a21
        lda     f:BtnAction,x   ; set action for L button
        sta     $1a31
        shorta
        lda     $1a3b
        asl
        sta     $43
        longa
        ldx     $43
        lda     f:BtnAction,x   ; set action for start button
        sta     $1a23
        shorta
        lda     $1a37
        ldx     #$0080      ; confirm
        jsr     SetBtnMap
        lda     $1a38
        ldx     #$8000      ; cancel
        jsr     SetBtnMap
        lda     $1a39
        ldx     #$0040      ; menu
        jsr     SetBtnMap
        lda     #$ff
        sta     $04
        sta     $05
        lda     $dd         ; repeat rate
        sta     $08
        sta     $09
        pld
        plb
        tdc
        xba
        rtl

; ------------------------------------------------------------------------------

; [ set button mapping ]

SetBtnMap:
@fe63:  phx
        sta     $43
        ldx     $43
        lda     f:BtnMapTbl,x
        sta     $43
        ldx     $43
        longa
        pla
        sta     $1a05,x
        shorta
        rts

; ------------------------------------------------------------------------------

; button mapping choices (A, B, X, Y, select)
BtnMapTbl:
@fe79:  .byte   $28,$18,$2a,$1a,$1c

; l and start button actions (none, confirm, cancel, menu)
BtnAction:
@fe7e:  .word   $0000,$0080,$8000,$0040

; default button mapping
BtnDefault:
@fe86:  .word   $8000,$4000,$8000,$0000,$0800,$0400,$0200,$0100
        .word   $0080,$0040,$0000,$0010

; ------------------------------------------------------------------------------

; [ clear text ]

; +y: tilemap offset
;  a: width
; set tiles to zero if carry clear, $ff if carry set

ClearText:
@fe9e:  stz     $1f
        bcs     @fea4
        dec     $1f
@fea4:  pha
        sta     $1d
        sta     $1e
        longa
        tya
        clc
        adc     $29
        tay
        shorta
        phy
        lda     $1f
@feb5:  sta     a:$0000,y
        iny2
        dec     $1d
        bne     @feb5
        ply
        longa
        tya
        clc
        adc     #$0040      ; next line
        tay
        shorta
        lda     $1f
@fecb:  sta     a:$0000,y
        iny2
        dec     $1e
        bne     @fecb
        pla
        rtl

; ------------------------------------------------------------------------------

; [ update window color ]

UpdateWindowColor:
@fed6:  ldx     $16aa       ; window color
        stx     $a002
        stx     $a00a
        stx     $a012
        stx     $a01a
        stx     $a042
        stx     $a04a
        stx     $a052
        stx     $a05a
        stx     $a082
        stx     $a08a
        stx     $a092
        stx     $a09a
        stx     $a0c2
        stx     $a0ca
        stx     $a0d2
        stx     $a0da
        rtl

; ------------------------------------------------------------------------------

; [ update bg scroll registers ]

UpdateScrollRegs:
@ff0a:  pha
        phb
        tdc
        pha
        plb
        lda     $8a
        sta     hBG2HOFS
        lda     $8b
        sta     hBG2HOFS
        lda     $8d
        sta     hBG2VOFS
        lda     $8e
        sta     hBG2VOFS
        lda     $90
        sta     hBG1HOFS
        lda     $91
        sta     hBG1HOFS
        lda     $93
        sta     hBG1VOFS
        lda     $94
        sta     hBG1VOFS
        lda     $96
        sta     hBG4HOFS
        lda     $97
        sta     hBG4HOFS
        lda     $99
        sta     hBG4VOFS
        lda     $9a
        sta     hBG4VOFS
        lda     $9c
        sta     hBG3HOFS
        lda     $9d
        sta     hBG3HOFS
        lda     $9f
        sta     hBG3VOFS
        lda     $a0
        sta     hBG3VOFS
        plb
        pla
        rtl

; ------------------------------------------------------------------------------

; [ save dialogue window graphics (bg3) ]

SaveDlgGfx:
@ff62:  phb
        tdc
        pha
        plb
        lda     #$80
        sta     $2100       ; screen off
        sta     $88
        lda     #$80
        sta     $2115
        ldx     #$2000      ; ppu $2000
        stx     $2116
        ldx     $2139       ; read "dummy" value
        lda     #$81        ; single address, auto-increment
        sta     $4300
        lda     #$39        ; source: $2139 (vram data read)
        sta     $4301
        ldx     #$e600      ; destination: $7ee600
        stx     $4302
        lda     #$7e
        sta     $4304
        ldx     #$1000      ; size: $1000
        stx     $4305
        lda     #$01
        sta     $420b
        plb
        rtl

; ------------------------------------------------------------------------------

; character display order
CharOrderTbl:
@ff9d:  .byte   1,3,0,4,2

; spell lists for each character (see 13/fddd for battle)
SpellListTbl:
@ffa2:  .byte   $ff,$ff,$ff
        .byte   $ff,$ff,$ff
        .byte   $02,$03,$04
        .byte   $05,$06,$ff
        .byte   $ff,$ff,$ff
        .byte   $07,$ff,$ff
        .byte   $ff,$ff,$ff
        .byte   $ff,$08,$ff
        .byte   $09,$ff,$ff
        .byte   $00,$ff,$ff
        .byte   $ff,$ff,$ff
        .byte   $ff,$03,$04
        .byte   $ff,$0c,$ff
        .byte   $0a,$0b,$ff

; name change letter cursor x positions
NameCursorX:
@ffcc:  .byte   $38,$48,$58,$68,$78,$90,$a0,$b0,$c0,$d0

; ------------------------------------------------------------------------------

; [ restore dialogue window graphics (bg3) ]

RestoreDlgGfx_ext:
@ffd6:  lda     #$00
        pha
        plb
        ldx     #$2000
        stx     $011d
        ldx     #$e600
        stx     $011f
        lda     #$7e
        sta     $0121
        ldx     #$1000
        stx     $0122
        rtl

; ------------------------------------------------------------------------------

; multi-target flag for white magic (starts at cure1)
MagicMultiTarget:
@fff2:  .byte   1,1,1,1,0,0,0,1,0,0,1,1,1,1

; ------------------------------------------------------------------------------
