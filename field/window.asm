
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: window.asm                                                           |
; |                                                                            |
; | description: dialogue window routines                                      |
; |                                                                            |
; | created: 3/26/2022                                                         |
; +----------------------------------------------------------------------------+

.import ItemName

; ------------------------------------------------------------------------------

.pushseg

.segment "map_dlg"

MapDlgPtrs:
        make_ptr_tbl_rel MapDlg, $0180

        .include .sprintf("text/map_dlg_%s.asm", LANG_SUFFIX)

.segment "event_dlg1"
EventDlg1Ptrs:
        make_ptr_tbl_rel EventDlg1, $0200

        .include .sprintf("text/event_dlg1_%s.asm", LANG_SUFFIX)

.segment "event_dlg2"
EventDlg2Ptrs:
        make_ptr_tbl_rel EventDlg2, $0100

        .include .sprintf("text/event_dlg2_%s.asm", LANG_SUFFIX)

; 15/9880 (15/9620 in the english translation)
.segment "map_title"

        .include .sprintf("text/map_title_%s.asm", LANG_SUFFIX)

; in the english translation, 15/9AEF-15/9C77 is stale data carried over
; from the japenese rom
.if LANG_EN .and BYTE_PERFECT
        .byte   $ff,$87,$14,$8c,$ab,$00
        .byte   $cd,$3a,$f0,$c2,$de,$16,$7f,$8c,$ff,$9a,$8f,$00
        .byte   $f3,$bc,$37,$d0,$bd,$bc,$3f,$00
        .byte   $cd,$f6,$d9,$c2,$3f,$f0,$cb,$30,$00
        .byte   $a8,$1e,$8c,$97,$b6,$00
        .byte   $3d,$3a,$ff,$b9,$8e,$8c,$94,$a8,$c9,$00
        .byte   $8f,$16,$ad,$a2,$d1,$d1,$f4,$a2,$8b,$8d,$00
        .byte   $dd,$eb,$f0,$a2,$aa,$b0,$00
        .byte   $13,$b6,$16,$7e,$8c,$a2,$1e,$8c,$91,$9b,$00
        .byte   $a5,$8c,$8b,$b6,$a2,$1e,$8c,$91,$9b,$00
        .byte   $ca,$33,$e8,$f6,$9d,$8c,$a2,$1e,$8c,$91,$9b,$00
        .byte   $37,$f5,$c2,$e5,$a2,$90,$9a,$00,$90,$7f,$1a,$8b,$a7,$8c,$00
        .byte   $13,$b6,$16,$7e,$8c,$95,$b6,$a2,$1e,$8c,$91,$9b,$00
        .byte   $9b,$90,$a2,$99,$a9,$a2,$ad,$8f,$99,$00
        .byte   $d5,$f2,$e5,$a2,$1e,$8c,$91,$9b,$00
        .byte   $9b,$90,$a2,$9a,$8f,$92,$8b,$93,$91,$ff,$43,$81,$00
        .byte   $9b,$90,$a2,$9a,$8f,$92,$8b,$93,$91,$ff,$43,$82,$00
        .byte   $9b,$90,$a2,$9a,$8f,$92,$8b,$93,$91,$ff,$43,$83,$00
        .byte   $9b,$90,$a2,$9a,$8f,$92,$8b,$93,$91,$ff,$43,$84,$00
        .byte   $9b,$90,$a2,$9a,$8f,$92,$8b,$93,$91,$ff,$43,$85,$00
        .byte   $9b,$90,$a2,$9a,$8f,$92,$8b,$93,$91,$ff,$43,$86,$00
        .byte   $9b,$90,$a2,$9a,$8f,$92,$8b,$93,$91,$ff,$43,$87,$00
        .byte   $31,$ea,$d6,$32,$c2,$f6,$00
        .byte   $9b,$90,$a2,$9a,$8f,$a2,$9b,$8c,$b4,$00
        .byte   $31,$f4,$ea,$d6,$00
        .byte   $9a,$8f,$97,$8f,$8b,$a2,$38,$3a,$cb,$f2,$00
        .byte   $3d,$3a,$ff,$b9,$f0,$f1,$e7,$c2,$c4,$c9,$00
        .byte   $8e,$b6,$10,$91,$95,$9b,$00
        .byte   $8f,$a9,$b6,$95,$9b,$00
        .byte   $13,$b6,$16,$7e,$8c,$a2,$a8,$9a,$00
        .byte   $13,$b6,$8f,$8b,$9d,$95,$7f,$8f,$b6,$00
        .byte   $f1,$36,$b8,$ca,$a2,$96,$a8,$8b,$00
        .byte   $90,$7f,$16,$b6,$a2,$91,$20,$00
        .byte   $90,$7f,$16,$b6,$a2,$aa,$a1,$00
        .byte   $90,$7f,$16,$b6,$a2,$a3,$b0,$00
        .byte   $90,$7f,$16,$b6,$9e,$8b,$21,$a2,$9b,$8c,$b4,$00
        .byte   $90,$7f,$16,$b6,$9e,$8b,$21,$ff,$a5,$90,$a0,$92,$00
        .byte   $97,$8b,$11,$7f,$98,$8c,$9a,$00
        .byte   $9b,$90,$a2,$99,$a9,$a2,$1e,$8c,$91,$9b,$00
.endif

.popseg

; ------------------------------------------------------------------------------

; [ open gil window ]

OpenGilWindow:
@ad16:  jsr     WaitVblankLong
        lda     #$80
        sta     hVMAINC
        jsr     InitDMA
        lda     #$01
        sta     $4300
        lda     #.bankbyte(GilWindowTiles1)
        sta     $4304
        ldx     #.loword(GilWindowTiles1)
        stx     $4302
        ldx     #$2892
        stx     hVMADDL
        ldx     #$0018
        stx     $4305
        jsr     ExecDMA
        ldx     #$28b2
        stx     hVMADDL
        stz     hMDMAEN
        ldx     #.loword(GilWindowTiles2)
        stx     $4302
        ldx     #$0018
        stx     $4305
        jsr     ExecDMA
        ldx     #$28d2
        stx     hVMADDL
        stz     hMDMAEN
        ldx     #.loword(GilWindowTiles3)
        stx     $4302
        ldx     #$0018
        stx     $4305
        jsr     ExecDMA
        ldx     #$28f2
        stx     hVMADDL
        stz     hMDMAEN
        ldx     #.loword(GilWindowTiles4)
        stx     $4302
        ldx     #$0018
        stx     $4305
        jsr     ExecDMA
        ldx     #$28d3
        stx     hVMADDL
        stz     $0a
        ldx     #$0000
@ad93:  lda     $0634,x
        cmp     #$80
        bne     @ada8
        cpx     #$0007
        beq     @ada8
        lda     $0a
        bne     @adaa
        lda     #$ff
        jmp     @adad
@ada8:  inc     $0a
@adaa:  lda     $0634,x
@adad:  sta     hVMDATAL
        lda     #$20
        sta     hVMDATAH
        inx
        cpx     #8
        bne     @ad93
        rts

; ------------------------------------------------------------------------------

; [ close gil window ]

CloseGilWindow:
@adbc:  jsr     WaitVblankLong
        lda     #$80
        sta     $2115
        jsr     InitDMA
        lda     #$09
        sta     $4300
        stz     $0676
        ldx     #$0676
        stx     $4302
        ldx     #$2880
        stx     $2116
        ldx     #$0100
        stx     $4305
        jsr     ExecDMA
        rts

; ------------------------------------------------------------------------------

; [ show yes/no selection window ]

ShowYesNoWindow:
@ade5:  stz     $dc
@ade7:  jsr     WaitVblankShort
        jsr     InitDlgIRQ
        jsr     TfrYesNoWindow
        inc     $dc
        lda     $dc
        cmp     #$06
        bne     @ade7
        lda     #1
        sta     $54
        stz     $8c
@adfe:  jsr     WaitVblankShort
        jsr     InitDlgIRQ
        jsl     ResetButtons
        lda     $02
        and     #JOY_A
        beq     @ae17
        lda     $54
        bne     @ae17
        inc     $54
        jmp     @ae6e
@ae17:  lda     $03
        and     #JOY_B
        beq     @ae2a
        lda     $55
        bne     @ae2a
        inc     $55
        lda     #$01
        sta     $8c
        jmp     @ae6e
@ae2a:  lda     $01
        and     #$0c
        beq     @adfe
        lda     $8c
        eor     #$01
        sta     $8c
        ldx     #$28c4
        stx     $2116
        lda     $8c
        bne     @ae45
        lda     #$14
        jmp     @ae47
@ae45:  lda     #$ff
@ae47:  sta     $2118
        lda     #$20
        sta     $2119
        ldx     #$2904
        stx     $2116
        lda     $8c
        beq     @ae5e
        lda     #$14
        jmp     @ae60
@ae5e:  lda     #$ff
@ae60:  sta     $2118
        lda     #$20
        sta     $2119
        jsr     MoveCursor
        jmp     @adfe
@ae6e:  jsr     PlayCursorSfx
        lda     $8c
        sta     $db
        dec     $dc
@ae77:  jsr     WaitVblankShort
        jsr     InitDlgIRQ
        jsr     TfrYesNoWindow
        dec     $dc
        bpl     @ae77
        jsr     WaitVblankShort
        jsr     InitDlgIRQ
        lda     $3d
        sec
        sbc     #$20
        sta     $3d
        lda     $3e
        sbc     #$00
        sta     $3e
        jsr     CloseYesNoWindow
        lda     $3d
        sec
        sbc     #$20
        sta     $3d
        lda     $3e
        sbc     #0
        sta     $3e
        jsr     CloseYesNoWindow
        rts

; ------------------------------------------------------------------------------

; [ transfer yes/no window to vram ]

TfrYesNoWindow:
@aeab:  lda     #$80
        sta     $2115
        jsr     InitDMA
        lda     #$01
        sta     $4300
        ldx     #$0010
        stx     $4305
        lda     #^YesNoTilesTop
        sta     $4304
        lda     $dc
        asl4
        clc
        adc     #<YesNoTilesTop
        sta     $3d
        lda     #>YesNoTilesTop
        adc     #$00
        sta     $3e
        ldx     $3d
        stx     $4302
        lda     $dc
        asl5
        clc
        adc     #$82
        sta     $3d
        lda     #$28
        adc     #$00
        sta     $3e
        ldx     $3d
        stx     $2116
        jsr     ExecDMA
        lda     $3d
        clc
        adc     #$20
        sta     $3d
        lda     $3e
        adc     #$00
        sta     $3e
        ldx     $3d
        stx     $2116
        stz     hMDMAEN
        ldx     #.loword(YesNoTilesBtm)
        stx     $4302
        ldx     #$0010
        stx     $4305
        jsr     ExecDMA
        lda     $3d
        clc
        adc     #$20
        sta     $3d
        lda     $3e
        adc     #$00
        sta     $3e
; fallthrough

; ------------------------------------------------------------------------------

; [ close yes/no window (one row) ]

CloseYesNoWindow:
@af24:  lda     #$80
        sta     $2115
        jsr     InitDMA
        lda     #$01
        sta     $4300
        ldx     $3d
        stx     $2116
        ldx     #.loword(YesNoTilesHide)
        stx     $4302
        lda     #.bankbyte(YesNoTilesHide)
        sta     $4304
        ldx     #$0010
        stx     $4305
        jsr     ExecDMA
        rts

; ------------------------------------------------------------------------------

; [ show item selection window ]

ShowItemWindow:
@af4b:  lda     $cc
        bne     @af4b       ; wait for player graphics update
        lda     #$01
        sta     $da
        sta     $eb
        stz     $ba
        stz     $8b
        stz     $8c
        lda     #$70
        sta     $bb
        jsr     InitItemList
        jsr     WaitVblankLong
        jsr     UpdateItemText
@af68:  jsr     WaitVblankLong
@af6b:  lda     $7f
        cmp     #$02
        bne     @af6b       ; wait for 2nd irq
        inc     $da
        lda     $da
        cmp     #$08
        bne     @af68
@af79:  jsr     WaitVblankLong
@af7c:  lda     #$01
        sta     $7d
        lda     $03
        and     #JOY_B
        beq     @af91
        jsr     PlayCursorSfx
        lda     #$ff
        sta     $08fb
        jmp     @b05b
@af91:  lda     $02
        and     #JOY_A
        beq     @afae
        jsr     PlayCursorSfx
        lda     $ba
        clc
        adc     $8c
        asl
        clc
        adc     $8b
        asl
        tax
        lda     $0712,x
        sta     $08fb
        jmp     @b05b
@afae:  lda     $03
        and     #JOY_RIGHT
        beq     @afce
        jsr     MoveCursor
        inc     $e7
        lda     $8b
        inc
        and     #$01
        sta     $8b
        bne     @af79
        lda     $8c
        cmp     #$03
        beq     @b00b
        inc
        sta     $8c
        jmp     @af79
@afce:  lda     $03
        and     #JOY_LEFT
        beq     @afec
        jsr     MoveCursor
        inc     $e7
        lda     $8b
        dec
        and     #$01
        sta     $8b
        beq     @af79
        lda     $8c
        beq     @b041
        dec
        sta     $8c
        jmp     @af79
@afec:  lda     $8c
        cmp     #$03
        bne     @affb
        lda     $03
        and     #JOY_DOWN
        beq     @b024
        jmp     @b00b
@affb:  lda     $01
        and     #$04
        beq     @b024
        inc     $8c
        inc     $e7
        jsr     MoveCursor
        jmp     @af79
@b00b:  lda     $ba
        cmp     #$11
        bne     @b014
        jmp     @af79
@b014:  inc     $e7
        inc     $ba
        jsr     PlayCursorSfx
        jsr     UpdateItemText
        jsr     ScrollItemListDown
        jmp     @af7c
@b024:  lda     $8c
        bne     @b031
        lda     $03
        and     #JOY_UP
        beq     @b058
        jmp     @b041
@b031:  lda     $01
        and     #$08
        beq     @b058
        dec     $8c
        inc     $e7
        jsr     MoveCursor
        jmp     @af79
@b041:  lda     $ba
        bne     @b048
        jmp     @af79
@b048:  inc     $e7
        dec     $ba
        jsr     PlayCursorSfx
        jsr     UpdateItemText
        jsr     ScrollItemListUp
        jmp     @af7c
@b058:  jmp     @af79
@b05b:  jsr     WaitVblankLong
@b05e:  lda     $7f
        cmp     #$02
        bne     @b05e       ; wait for 2nd irq
        dec     $da
        lda     $da
        cmp     #$00
        bne     @b05b
        lda     #$01
        sta     $ec
        stz     $da
        rts

; ------------------------------------------------------------------------------

; [ play cursor sound effect ]

PlayCursorSfx:
@b073:  lda     #$11        ; system sound effect $11
        sta     $1e00
        jsl     ExecSound_ext
        rts

; ------------------------------------------------------------------------------

; [ move cursor ]

MoveCursor:
@b07d:  jsr     PlayCursorSfx
        lda     #$07
        sta     $89
@b084:  jsr     WaitVblankLong
        dec     $89
        bne     @b084
        rts

; ------------------------------------------------------------------------------

; [ scroll item list up ]

ScrollItemListUp:
@b08c:  lda     #$08
        sta     $07
@b090:  jsr     WaitVblankLong
        dec     $bb
        dec     $bb
        dec     $07
        bne     @b090
        rts

; ------------------------------------------------------------------------------

; [ scroll item list down ]

ScrollItemListDown:
@b09c:  lda     #$08
        sta     $07
@b0a0:  jsr     WaitVblankLong
        inc     $bb
        inc     $bb
        dec     $07
        bne     @b0a0
        rts

; ------------------------------------------------------------------------------

; [ init irq for item selection ]

InitItemWindowIRQ:
@b0ac:  ldx     #$008f
        stx     hVTIMEL
        lda     #$a1
        sta     hNMITIMEN               ; enable nmi and irq
        stz     hBG3HOFS
        stz     hBG3HOFS
        lda     #$88
        sta     hBG3VOFS
        stz     hBG3VOFS
        stz     $7f
        ldx     $08f6
        inx
        stx     $08f6
        rts

; ------------------------------------------------------------------------------

; [ update item selection window (irq) ]

update_item_window_irq:
@b0cf:  lda     $7f
        bne     @b0f8                   ; branch if not 1st irq
; 1st irq
        lda     $da                     ; item selection window height
        asl3
        clc
        adc     #$90
        sta     hVTIMEL
        stz     hVTIMEH
        ldx     #$0008
@b0e4:  dex
        bne     @b0e4
        stz     hBG3HOFS                ; scroll to right screen
        lda     #$01
        sta     hBG3HOFS
        lda     $bb                     ; dialogue window scroll position
        sta     hBG3VOFS
        stz     hBG3VOFS
        rts
; 2nd irq
@b0f8:  ldx     #$0008
@b0fb:  dex
        bne     @b0fb
        stz     hBG3HOFS                ; scroll to left screen
        stz     hBG3HOFS
        lda     $da                     ; item selection window height
        asl3
        eor     #$ff
        clc
        adc     #$89
        sta     hBG3VOFS
        stz     hBG3VOFS
        lda     #$81
        sta     hNMITIMEN               ; enable nmi
        rts

; ------------------------------------------------------------------------------

; [ draw item select cursor ]

DrawItemCursor:
@b11a:  lda     $da         ; item select window height
        cmp     #$08
        beq     @b121       ; return if not fully open
        rts
@b121:  lda     #$80
        sta     hVMAINC
        lda     $e7
        beq     @b13b
        ldx     $8d
        stx     hVMADDL
        stz     $e7
        lda     #$ff        ; hide previous cursor
        sta     hVMDATAL
        lda     #$20
        sta     hVMDATAH
@b13b:  lda     $ba         ; scroll position
        clc
        adc     $8c
        sta     $4b         ; calculate vram address
        stz     $4a
        lsr     $4b
        ror     $4a
        lsr     $4b
        ror     $4a
        lda     $8b
        beq     @b152
        lda     #$0d        ; shift right by 13 for right column
@b152:  clc
        adc     #$23        ; shift down one row and right 3 tiles
        adc     $4a
        sta     $4a
        lda     $4b
        and     #$03
        clc
        adc     #$2c
        sta     $4b
        ldx     $4a
        stx     $8d         ; save vram address
        stx     hVMADDL
        lda     #$14        ; draw cursor tile in vram
        sta     hVMDATAL
        lda     #$20
        sta     hVMDATAH
        rts

; ------------------------------------------------------------------------------

; [ transfer item selection window to vram ]

TfrItemWindow:
.if LANG_EN

@af56:  lda     $e6
        bne     @af5e
        jsr     DrawItemCursor
        rts
@af5e:  stz     $e6
        lda     $ba
        and     #$0f
        sta     $13
        stz     $12
        lsr     $13
        ror     $12
        lsr     $13
        ror     $12
        lda     $12
        clc
        adc     #$04
        sta     $12
        lda     $13
        and     #$03
        clc
        adc     #$2c
        sta     $13
        ldx     #$0774
        stx     $14
        stz     $2115
        jsr     InitDMA
        stz     $4300
        lda     #$04
        sta     $11
@af92:  ldx     #$0844
        stx     $4302
        ldx     $12
        stx     $2116
        ldx     #$001a
        stx     $4305
        jsr     ExecDMA
        lda     $12
        clc
        adc     #$20
        sta     $12
        lda     $13
        adc     #$00
        sta     $13
        stz     hMDMAEN
        ldx     $14
        stx     $4302
        ldx     $12
        stx     $2116
        ldx     #$001a
        stx     $4305
        jsr     ExecDMA
        lda     $12
        clc
        adc     #$20
        sta     $12
        lda     $13
        adc     #$00
        sta     $13
        sec
        sbc     #$30
        bcc     @afe2
        and     #$03
        clc
        adc     #$2c
        sta     $13
@afe2:  lda     $14
        clc
        adc     #$1a
        sta     $14
        lda     $15
        adc     #$00
        sta     $15
        dec     $11
        beq     @aff6
        jmp     @af92
@aff6:  jsr     DrawItemCursor
        rts

.else

@b174:  lda     $e6
        bne     @b17c
        jsr     DrawItemCursor
        rts
@b17c:  stz     $e6
        lda     $ba
        and     #$0f
        sta     $13
        stz     $12
        lsr     $13
        ror     $12
        lsr     $13
        ror     $12
        lda     $12
        clc
        adc     #$04
        sta     $12
        lda     $13
        and     #$03
        clc
        adc     #$2c
        sta     $13
        ldx     #$0774
        stx     $14
        ldx     #$0834
        stx     $16
        stz     $2115
        jsr     InitDMA
        stz     $4300
        lda     #$04
        sta     $11
@b1b5:  ldx     $16
        stx     $4302
        ldx     $12
        stx     $2116
        ldx     #$0018
        stx     $4305
        jsr     ExecDMA
        lda     $12
        clc
        adc     #$20
        sta     $12
        lda     $13
        adc     #$00
        sta     $13
        stz     hMDMAEN
        ldx     $14
        stx     $4302
        ldx     $12
        stx     $2116
        ldx     #$0018
        stx     $4305
        jsr     ExecDMA
        lda     $12
        clc
        adc     #$20
        sta     $12
        lda     $13
        adc     #$00
        sta     $13
        sec
        sbc     #$30
        bcc     @b204
        and     #$03
        clc
        adc     #$2c
        sta     $13
@b204:  lda     $14
        clc
        adc     #$18
        sta     $14
        lda     $15
        adc     #$00
        sta     $15
        lda     $16
        clc
        adc     #$18
        sta     $16
        lda     $17
        adc     #$00
        sta     $17
        dec     $11
        beq     @b225
        jmp     @b1b5
@b225:  jsr     DrawItemCursor
        rts

.endif

; ------------------------------------------------------------------------------

; [ update item selection window text ]

UpdateItemText:
.if LANG_EN

@affa:  ldx     #0
        lda     #$ff
@afff:  sta     $0774,x     ; clear text buffer
        inx
        cpx     #$0180
        bne     @afff
        lda     $ba         ; item selection window scroll position
        asl2
        tax
        stx     $3d
        ldy     #0
        sty     $40
        lda     #8        ; show 8 items on a page, 2 per line
        sta     $07
@b018:  ldx     $3d
        lda     $0712,x     ; inventory for item select dialog
        bne     @b022       ; branch if not empty
        jmp     @b094
@b022:  stz     $19
        asl
        rol     $19
        asl
        rol     $19
        asl
        rol     $19
        clc
        adc     $0712,x     ; item number
        sta     $18
        lda     $19
        adc     #$00
        sta     $19
        ldx     $18         ; pointer to item data
        ldy     $40
        lda     #9        ; 9 letters
        sta     $08
@b041:  lda     f:ItemName,x   ; item names
        sta     $0774,y
        iny
        inx
        dec     $08
        bne     @b041
        ldy     $40
        lda     #$c8        ; ":"
        sta     $077d,y
        ldx     $3d
        lda     $0713,x     ; item quantity
        sta     $30
        stz     $31
        stz     $32
        jsl     HexToDec     ; convert hex to decimal
        ldy     $40
        lda     $3a
        sta     $077e,y     ; tens digit
        lda     $3b
        sta     $077f,y     ; ones digit
        lda     $07
        and     #$01
        bne     @b080       ; branch if on the right side of the window
        lda     $40
        clc
        adc     #$0d
        sta     $40
        jmp     @b087
@b080:  lda     $40
        clc
        adc     #$0d
        sta     $40
@b087:  ldx     $3d         ; next item
        inx2
        stx     $3d
        dec     $07
        beq     @b094
        jmp     @b018
@b094:  lda     #$01        ;
        sta     $e6
        rts

.else

@b229:  ldx     #0
        lda     #$ff
@b22e:  sta     $0774,x
        inx
        cpx     #$0180
        bne     @b22e
        lda     $ba
        asl2
        tax
        stx     $3d
        ldy     #0
        sty     $40
        lda     #8
        sta     $07
@b247:  ldx     $3d
        lda     $0712,x
        bne     @b251
        jmp     @b2ce
@b251:  stz     $19
        asl
        rol     $19
        asl
        rol     $19
        asl
        rol     $19
        clc
        adc     $0712,x
        sta     $18
        lda     $19
        adc     #$00
        sta     $19
        ldx     $18
        inx
        ldy     $40
        lda     #8
        sta     $08
@b271:  lda     f:ItemName,x
        jsr     GetDakuten
        sta     $0774,y
        xba
        sta     $0834,y
        lda     #$00
        xba
        iny
        inx
        dec     $08
        bne     @b271
        ldy     $40
        lda     #$c8
        sta     $077c,y
        ldx     $3d
        lda     $0713,x
        sta     $30
        stz     $31
        stz     $32
        jsl     HexToDec
        ldy     $40
        lda     $3a
        sta     $077d,y
        lda     $3b
        sta     $077e,y
        lda     $07
        and     #$01
        bne     @b2ba
        lda     $40
        clc
        adc     #$0d
        sta     $40
        jmp     @b2c1
@b2ba:  lda     $40
        clc
        adc     #$0b
        sta     $40
@b2c1:  ldx     $3d
        inx2
        stx     $3d
        dec     $07
        beq     @b2ce
        jmp     @b247
@b2ce:  lda     #$01
        sta     $e6
        rts

.endif

; ------------------------------------------------------------------------------

; [ init item list ]

InitItemList:
@b2d3:  ldx     #0
@b2d6:  stz     $0712,x     ; clear item list
        inx
        cpx     #$0060
        bne     @b2d6
        ldx     #0
        ldy     #0
@b2e5:  lda     $1440,x     ; inventory
        cmp     #$ce
        bcc     @b303
        cmp     #$e7
        bcc     @b2f8
        cmp     #$eb
        bcc     @b303
        cmp     #$fe
        bcs     @b303
@b2f8:  sta     $0712,y
        lda     $1441,x
        sta     $0713,y
        iny2
@b303:  inx2
        cpx     #$0060
        bne     @b2e5
        rts

; ------------------------------------------------------------------------------

; [ open dialogue window ]

OpenDlgWindow:
@b30b:  lda     $cc
        bne     @b30b
        lda     #$01        ; close map name window
        sta     $ea
@b313:  jsr     WaitVblankLong
        lda     $ea
        cmp     #$02
        bne     @b313
        ldx     #$0000
        stx     $08f4
        stz     $de
        lda     #$ec
        sta     $bb
        stz     $ba
        jsr     DecodeDlgText
        lda     #$01
        sta     $df
        sta     $eb
@b333:  jsr     WaitVblankLong
@b336:  lda     $7f
        cmp     #$02
        bne     @b336       ; wait for 2nd irq
        inc     $df
        lda     $df
        cmp     #$08
        bne     @b333
@b344:  ldx     $08f4
        beq     @b357
@b349:  cpx     $08f6
        bne     @b349
        ldx     #$0000
        stx     $08f4
        jmp     @b367
@b357:  lda     $de
        cmp     #$02
        beq     @b39d
        lda     $cb
        bne     @b367                   ; branch if auto-scrolling dialogue
        jsr     WaitKeyUp
        jsr     WaitKeyDown
@b367:  lda     $de
        bne     @b39d
        jsr     DecodeDlgText
        lda     #$10
        sta     $07
@b372:  jsr     WaitVblankLong
        lda     $cb
        bne     @b386                   ; branch if auto-scrolling dialogue
        inc     $bb
        inc     $bb
        inc     $bb
        inc     $bb
        dec     $07
        jmp     @b396
@b386:  lda     $7a
        and     #$07
        bne     @b396
        inc     $bb
        lda     $7a
        and     #$1f
        bne     @b396
        dec     $07
@b396:  lda     $07
        bne     @b372
        jmp     @b344
@b39d:  rts

; ------------------------------------------------------------------------------

; [ close dialogue window ]

CloseDlgWindow:
@b39e:  jsr     WaitVblankLong
@b3a1:  lda     $7f
        cmp     #$02
        bne     @b3a1       ; wait for 2nd irq
        dec     $df         ; decrement dialogue window height
        lda     $df
        cmp     #$00
        bne     @b39e
        lda     #$01        ; hide dialogue window
        sta     $ec
        jsr     WaitVblankLong
        stz     $df
        rts

; ------------------------------------------------------------------------------

; [ get pointer to map dialogue (bank 0) ]

GetDlgPtr0:
@b3b9:  lda     $1702
        stz     $3e
        asl
        rol     $3e
        sta     $3d
        lda     $1701
        beq     @b3cc
        inc     $3e
        inc     $3e
@b3cc:  ldx     $3d
        lda     f:MapDlgPtrs,x
        sta     $3d
        lda     f:MapDlgPtrs+1,x
        sta     $3e
        ldx     $3d
        lda     $b2
        beq     @b3fc
        tay
@b3e1:  inx
        lda     f:MapDlg,x   ; find null-terminator
        bne     @b3e1
        lda     f:MapDlg-1,x
        cmp     #$03
        beq     @b3e1
        lda     f:MapDlg-1,x
        cmp     #$04
        beq     @b3e1
        dey
        bne     @b3e1
        inx
@b3fc:  stx     $0772
        stz     $dd
        rts

; ------------------------------------------------------------------------------

; [ get pointer to event dialogue (bank 1 low) ]

GetDlgPtr1L:
@b402:  jsr     GetDlgID
        lda     f:EventDlg1Ptrs,x   ; pointers to event dialogue
        sta     $3d
        lda     f:EventDlg1Ptrs+1,x
        sta     $3e
        ldx     $3d
        stx     $0772
        lda     #1
        sta     $dd
        rts

; ------------------------------------------------------------------------------

; [ get pointer to event dialogue (bank 1 high) ]

GetDlgPtr1H:
@EventDlg1HPtrs = EventDlg1Ptrs+512

@b41b:  jsr     GetDlgID
        lda     f:@EventDlg1HPtrs,x
        sta     $3d
        lda     f:@EventDlg1HPtrs+1,x
        sta     $3e
        ldx     $3d
        stx     $0772
        lda     #1
        sta     $dd
        rts

; ------------------------------------------------------------------------------

; [ get pointer to event dialogue (bank 2) ]

GetDlgPtr2:
@b434:  jsr     GetDlgID
        lda     f:EventDlg2Ptrs,x
        sta     $3d
        lda     f:EventDlg2Ptrs+1,x
        sta     $3e
        ldx     $3d
        stx     $0772
        lda     #2
        sta     $dd
        rts

; ------------------------------------------------------------------------------

; [ get dialogue id ]

GetDlgID:
@b44d:  lda     $b2
        stz     $3e
        asl
        rol     $3e
        sta     $3d
        ldx     $3d
        rts

; ------------------------------------------------------------------------------

; [ decode dialogue text (one line) ]

DecodeDlgText:
.if LANG_EN

@b21f:  ldy     #0
        sty     $3d
_b224:  jsr     GetByte
        cmp     #$00
        bne     @b22e       ; branch if not null-terminator
        jmp     TextCmd_00
@b22e:  cmp     #$01
        bne     @b235       ; branch if not end of page
        jmp     TextCmd_01
@b235:  cmp     #$02
        bne     @b23c
        jmp     TextCmd_02
@b23c:  cmp     #$03
        bne     @b243
        jmp     TextCmd_03
@b243:  cmp     #$04
        bne     @b24a
        jmp     TextCmd_04
@b24a:  cmp     #$05
        bne     @b251
        jmp     TextCmd_05
@b251:  cmp     #$06
        bne     @b258
        jmp     TextCmd_06
@b258:  cmp     #$07
        bne     @b25f
        jmp     TextCmd_07
@b25f:  cmp     #$08
        bne     @b266
        jmp     TextCmd_08
@b266:  cmp     #$09
        bne     @b26d
        jmp     TextCmd_09
@b26d:  cmp     #$ff
        beq     @b280       ; branch if a space
        cmp     #$8a
        bcc     @b280       ; branch if not dte
        cmp     #$c0
        bcc     @b27d       ; branch if not punctuation
        cmp     #$ca
        bcc     @b280       ; branch if not dte
@b27d:  jmp     DecodeDTE
; single letter/symbol/space
@b280:  sta     $0774,y     ; dialog text buffer
        ldy     $3d
        iny
        sty     $3d
_b288:  ldx     $0772
        inx
        stx     $0772
        ldy     $3d
        cpy     #$0068
        beq     _b299
        jmp     _b224
_b299:  jsr     GetByte
        cmp     #0
        bne     @b2a4
        lda     #1
        sta     $de
@b2a4:  lda     #1
        sta     $ed
        ldx     #0
        lda     #$ff
@b2ad:  sta     $0844,x
        inx
        cpx     #$0034
        bne     @b2ad
        rts

GetNextByte:
@b2b7:  ldx     $0772
        inx
        stx     $0772

GetByte:
@b2be:  ldx     $0772
        lda     $dd         ; dialog bank number
        bne     @b2cc
        lda     f:MapDlg,x   ; map dialogue (bank 0)
        jmp     @b2db
@b2cc:  cmp     #$01
        bne     @b2d7
        lda     f:EventDlg1,x   ; event dialogue (bank 1)
        jmp     @b2db
@b2d7:  lda     f:EventDlg2,x   ; event dialogue (bank 2)
@b2db:  rts
; dte ($8a-$bf and $ca-$fd)

DecodeDTE:
@b2dc:  sec
        sbc     #$80
        asl
        tax
        lda     f:DTETbl,x   ; first letter
        sta     $0774,y
        iny
        lda     f:DTETbl+1,x   ; second letter
        sta     $0774,y
        iny
        sty     $3d
        jmp     _b288

; $03: play song
TextCmd_03:
@b2f6:  jsr     GetNextByte
        sta     $1e01
        lda     #1
        sta     $1e00
        jsl     ExecSound_ext
        jmp     _b288

; $04: character name
TextCmd_04:
@b308:  jsr     GetNextByte
        asl
        sta     $18
        asl
        clc
        adc     $18
        sta     $18
        stz     $19
        ldx     $18
        ldy     $3d
        stz     $07
@b31c:  lda     $1500,x     ; character names
        cmp     #$ff
        beq     @b333       ; break if a space
        sta     $0774,y
        iny
        inx
        inc     $07
        lda     $07
        cmp     #6        ; 6 letters max
        beq     @b333
        jmp     @b31c
@b333:  sty     $3d
        jmp     _b288

; $07: item name
TextCmd_07:
@b338:  lda     $08fb       ; item index
        stz     $19
        asl
        rol     $19
        asl
        rol     $19
        asl
        rol     $19
        clc
        adc     $08fb
        sta     $18
        lda     $19
        adc     #0
        sta     $19
        ldx     $18
        ldy     $3d
        lda     #9        ; 9 bytes max
        sta     $07
@b35a:  lda     f:ItemName,x   ; item names
        cmp     #$ff
        beq     @b36d       ; break if a space
        sta     $0774,y
        iny
        sty     $3d         ; text buffer pointer
        inx
        dec     $07
        bne     @b35a
@b36d:  jmp     _b288

; $08: gil amount
TextCmd_08:
@b370:  lda     $08f8       ; gil amount
        sta     $30
        lda     $08f9
        sta     $31
        lda     $08fa
        sta     $32
        jsl     HexToDec
        ldx     #0
@b386:  lda     $36,x       ; digit
        cmp     #$80
        bne     @b395       ; branch if not zero
        inx
        cpx     #5
        beq     @b395
        jmp     @b386
@b395:  lda     $36,x       ; copy digits, ignore leading zeroes
        sta     $0774,y
        iny
        inx
        cpx     #6
        bne     @b395
        sty     $3d         ; text buffer pointer
        jmp     _b288

; $05: pause
TextCmd_05:
@b3a6:  jsr     GetNextByte
        stz     $19
        asl
        rol     $19
        asl
        rol     $19
        asl
        rol     $19
        sta     $18
        ldx     $18
        stx     $08f4       ; dialog pause duration
        ldx     #0
        stx     $08f6       ; clear dialog pause counter
        jmp     _b288

; $02: spaces
TextCmd_02:
@b3c4:  jsr     GetNextByte
        sta     $07         ; number of spaces
        ldy     $3d
        lda     #$ff
@b3cd:  sta     $0774,y
        iny
        cpy     #$0068
        beq     @b3da
        dec     $07
        bne     @b3cd
@b3da:  sty     $3d         ; text buffer pointer
        jmp     _b288

; $09: empty line
TextCmd_09:
@b3df:  lda     #$ff
        sta     $0774,y     ; fill the rest of the line with spaces
        iny
        tya
        cmp     #$1a
        beq     @b3f9
        cmp     #$34
        beq     @b3f9
        cmp     #$4e
        beq     @b3f9
        cmp     #$68
        beq     @b3f9
        jmp     @b3df
@b3f9:  sty     $3d         ; text buffer pointer
        jmp     _b288

; $01: next line
TextCmd_01:
@b3fe:  lda     #$ff
        sta     $0774,y     ; fill the rest of the line with spaces
        tya
        beq     @b41a
        cmp     #$1a
        beq     @b41a
        cmp     #$34
        beq     @b41a
        cmp     #$4e
        beq     @b41a
        cmp     #$68
        beq     @b41a
        iny
        jmp     @b3fe
@b41a:  sty     $3d         ; text buffer pointer
        jmp     _b288

; $00: null-terminator
TextCmd_00:
@b41f:  lda     #$ff
@b421:  sta     $0774,y
        iny
        cpy     #$00d0
        bne     @b421
        lda     #$01        ; wait for keypress
        sta     $de
        jmp     _b299

; $06: terminator (don't wait for keypress)
TextCmd_06:
@b431:  lda     #$ff
@b433:  sta     $0774,y
        iny
        cpy     #$00d0
        bne     @b433
        lda     #$02        ; close immediately
        sta     $de
        jmp     _b299

.else

@b459:  ldy     #0
        sty     $3d
_b45e:  jsr     GetByte       ; get dialogue byte
        cmp     #0
        bne     @b468
        jmp     TextCmd_00
@b468:  cmp     #1
        bne     @b46f
        jmp     TextCmd_01
@b46f:  cmp     #2
        bne     @b476
        jmp     TextCmd_02
@b476:  cmp     #3
        bne     @b47d
        jmp     TextCmd_03
@b47d:  cmp     #4
        bne     @b484
        jmp     TextCmd_04
@b484:  cmp     #5
        bne     @b48b
        jmp     TextCmd_05
@b48b:  cmp     #6
        bne     @b492
        jmp     TextCmd_06
@b492:  cmp     #7
        bne     @b499
        jmp     TextCmd_07
@b499:  cmp     #8
        bne     @b4a0
        jmp     TextCmd_08
@b4a0:  cmp     #$c3
        bne     @b4a7
        jmp     DrawEllipsis
; text character
@b4a7:  jsr     GetDakuten
        sta     $0774,y
        xba
        sta     $0834,y
        lda     #0
        xba
        ldy     $3d
        iny
        sty     $3d
_b4b9:  ldx     $0772       ; increment dialogue pointer
        inx
        stx     $0772
        ldy     $3d
        cpy     #$0060
        beq     _b4ca
        jmp     _b45e
_b4ca:  jsr     GetByte       ; get dialogue byte
        cmp     #0
        bne     @b4d5
        lda     #1        ; close after keypress
        sta     $de
@b4d5:  lda     #1        ; need dialogue text tilemap update in vram
        sta     $ed
        rts

; get next dialogue byte
GetNextByte:
@b4da:  ldx     $0772       ; increment dialogue pointer
        inx
        stx     $0772

; get dialogue byte
GetByte:
@b4e1:  ldx     $0772
        lda     $dd
        bne     @b4ef
        lda     f:MapDlg,x   ; map dialogue (bank 0)
        jmp     @b4fe
@b4ef:  cmp     #1
        bne     @b4fa
        lda     f:EventDlg1,x   ; event dialogue (bank 1)
        jmp     @b4fe
@b4fa:  lda     f:EventDlg2,x   ; event dialogue (bank 2)
@b4fe:  rts

; $c3: ellipsis
DrawEllipsis:
@b4ff:  xba
        lda     #$ff
        xba
        sta     $0774,y     ; repeat twice
        sta     $0775,y
        xba
        sta     $0834,y
        sta     $0835,y
        lda     #0
        xba
        ldy     $3d
        iny2
        sty     $3d
        jmp     _b4b9

; 3: play song
TextCmd_03:
@b51c:  jsr     GetNextByte
        sta     $1e01
        lda     #1
        sta     $1e00
        jsl     ExecSound_ext
        jmp     _b4b9

; 4: character name
TextCmd_04:
@b52e:  jsr     GetNextByte
        asl
        sta     $18
        asl
        clc
        adc     $18
        sta     $18
        stz     $19
        ldx     $18
        ldy     $3d
        stz     $07
@b542:  lda     $1500,x
        cmp     #$ff
        beq     @b563
        jsr     GetDakuten
        sta     $0774,y
        xba
        sta     $0834,y
        lda     #$00
        xba
        iny
        inx
        inc     $07
        lda     $07
        cmp     #6
        beq     @b563
        jmp     @b542
@b563:  sty     $3d
        jmp     _b4b9

; 7: item name
TextCmd_07:
@b568:  lda     $08fb
        stz     $19
        asl
        rol     $19
        asl
        rol     $19
        asl
        rol     $19
        clc
        adc     $08fb
        sta     $18
        lda     $19
        adc     #0
        sta     $19
        ldx     $18
        inx
        ldy     $3d
        lda     #8
        sta     $07
@b58b:  lda     f:ItemName,x
        cmp     #$ff
        beq     @b5a8
        jsr     GetDakuten
        sta     $0774,y
        xba
        sta     $0834,y
        lda     #0
        xba
        iny
        sty     $3d
        inx
        dec     $07
        bne     @b58b
@b5a8:  jmp     _b4b9

; 8: gil
TextCmd_08:
@b5ab:  lda     $08f8
        sta     $30
        lda     $08f9
        sta     $31
        lda     $08fa
        sta     $32
        jsl     HexToDec
        ldx     #0
@b5c1:  lda     $36,x
        cmp     #$80
        bne     @b5d0
        inx
        cpx     #5
        beq     @b5d0
        jmp     @b5c1
@b5d0:  lda     $36,x
        sta     $0774,y
        lda     #$ff
        sta     $0834,y
        iny
        inx
        cpx     #6
        bne     @b5d0
        sty     $3d
        jmp     _b4b9

; 5: wait
TextCmd_05:
@b5e6:  jsr     GetNextByte       ; get next dialogue byte
        stz     $19
        asl
        rol     $19
        asl
        rol     $19
        asl
        rol     $19
        sta     $18
        ldx     $18
        stx     $08f4
        ldx     #0
        stx     $08f6
        jmp     _b4b9

; 2: tab
TextCmd_02:
@b604:  jsr     GetNextByte       ; get next dialogue byte
        sta     $07
        ldy     $3d
        lda     #$ff
@b60d:  sta     $0774,y
        sta     $0834,y
        iny
        cpy     #$0060
        beq     @b61d
        dec     $07
        bne     @b60d
@b61d:  sty     $3d
        jmp     _b4b9

; 1: newline
TextCmd_01:
@b622:  lda     #$ff
@b624:  sta     $0774,y
        sta     $0834,y
        iny
        cpy     #$0018
        beq     @b63f
        cpy     #$0030
        beq     @b63f
        cpy     #$0048
        beq     @b63f
        cpy     #$0060
        bne     @b624
@b63f:  sty     $3d
        jmp     _b4b9

; 0: end of text
TextCmd_00:
@b644:  lda     #$ff
@b646:  sta     $0774,y
        sta     $0834,y
        iny
        cpy     #$00c0
        bne     @b646
        lda     #1        ; wait for keypress
        sta     $de
        jmp     _b4ca

; 6: end of text (don't wait for keypress)
TextCmd_06:
@b659:  lda     #$ff
@b65b:  sta     $0774,y
        sta     $0834,y
        iny
        cpy     #$00c0
        bne     @b65b
        lda     #2        ; don't wait for keypress
        sta     $de
        jmp     _b4ca

.endif

; ------------------------------------------------------------------------------

.if !LANG_EN

; [ get dakuten ]

GetDakuten:
@b66e:  cmp     #$42
        bcs     @b686
        phx
        sec
        sbc     #$0f
        asl
        tax
        lda     f:DakutenTbl,x   ; kana
        xba
        lda     f:DakutenTbl+1,x   ; dakuten
        xba
        plx
        jmp     @b68a
@b686:  xba
        lda     #$ff
        xba
@b68a:  rts

; ------------------------------------------------------------------------------

; dakuten table (field)
; 2 bytes each, kana then dakuten

DakutenTbl:
@b68b:  .byte                                                           $cc,$c0
        .byte   $8f,$c0,$90,$c0,$91,$c0,$92,$c0,$93,$c0,$94,$c0,$95,$c0,$96,$c0
        .byte   $97,$c0,$98,$c0,$99,$c0,$9a,$c0,$9b,$c0,$9c,$c0,$9d,$c0,$a3,$c0
        .byte   $a4,$c0,$a5,$c0,$a6,$c0,$a7,$c0,$a3,$c1,$a4,$c1,$a5,$c1,$a6,$c1
        .byte   $a7,$c1,$cf,$c0,$d0,$c0,$d1,$c0,$d2,$c0,$d3,$c0,$d4,$c0,$d5,$c0
        .byte   $d6,$c0,$d7,$c0,$d8,$c0,$d9,$c0,$da,$c0,$db,$c0,$dc,$c0,$dd,$c0
        .byte   $e3,$c0,$e4,$c0,$e5,$c0,$e6,$c0,$e7,$c0,$e3,$c1,$e4,$c1,$e5,$c1
        .byte   $e6,$c1,$e7,$c1

.endif

; ------------------------------------------------------------------------------

; [ init irq for dialogue window ]

InitDlgIRQ:
@b6f1:  ldx     #$0013
        stx     hVTIMEL
        lda     #$a1
        sta     hNMITIMEN               ; enable nmi and irq
        stz     hBG3HOFS
        stz     hBG3HOFS
        lda     #$03
        sta     hBG3VOFS
        stz     hBG3VOFS
        stz     $7f
        ldx     $08f6
        inx
        stx     $08f6
        rts

; ------------------------------------------------------------------------------

; [ update dialogue window (irq) ]

update_dlg_irq:
@b714:  lda     $7f
        bne     @b73d
; 1st irq
        lda     $df                     ; dialogue window height
        asl3
        clc
        adc     #$14
        sta     hVTIMEL                 ; set irq scanline
        stz     hVTIMEH
        ldx     #8
@b729:  dex
        bne     @b729
        stz     hBG3HOFS                ; scroll to right screen
        lda     #1
        sta     hBG3HOFS
        lda     $bb                     ; dialogue window scroll position
        sta     hBG3VOFS                ; bg3 v-scroll
        stz     hBG3VOFS
        rts
; 2nd irq
@b73d:  ldx     #8                      ; wait a few cycles
@b740:  dex
        bne     @b740
        stz     hBG3HOFS                ; scroll to left screen
        stz     hBG3HOFS
        lda     $df                     ; dialogue window height
        asl3
        eor     #$ff
        clc
        adc     #5
        sta     hBG3VOFS                ; bg3 v-scroll
        stz     hBG3VOFS
        lda     #$81
        sta     hNMITIMEN               ; enable nmi (disable irq)
        rts

; ------------------------------------------------------------------------------

; [ transfer dialogue window to vram ]

TfrDlgWindow:
@b75f:  lda     $cb
        beq     @b764                   ; return if auto-scrolling dialogue
        rts
@b764:  lda     $eb
        bne     @b769
        rts
@b769:  stz     $eb
        lda     #$80
        sta     $2115
        jsr     InitDMA
        lda     #$01
        sta     $4300
        ldx     #$2840
        stx     $2116
        ldx     #.loword(DlgTilesTop)
        stx     $4302
        lda     #.bankbyte(DlgTilesTop)
        sta     $4304
        ldx     #$0040
        stx     $4305
        jsr     ExecDMA
        ldx     #$2860
        stx     $2116
        stz     hMDMAEN
        ldx     #.loword(DlgTilesMid)
        stx     $4302
        ldx     #$0040
        stx     $4305
        jsr     ExecDMA
        ldy     #$0020
        ldx     #$2c00
        stx     $2116
@b7b3:  stz     hMDMAEN
        ldx     #.loword(DlgTilesBtm)
        stx     $4302
        ldx     #$0040
        stx     $4305
        jsr     ExecDMA
        dey
        bne     @b7b3
        rts

; ------------------------------------------------------------------------------

; [ hide dialogue window ]

HideDlgWindow:
@b7c9:  lda     $ec
        bne     @b7ce
        rts
@b7ce:  stz     $ec
        lda     #$80
        sta     $2115
        jsr     InitDMA
        lda     #$09
        sta     $4300
        ldx     #$2840
        stx     $2116
        stz     $10
        ldx     #$0610
        stx     $4302
        ldx     #$0040
        stx     $4305
        jsr     ExecDMA
        ldx     #$2860
        stx     $2116
        stz     hMDMAEN
        ldx     #$0610
        stx     $4302
        ldx     #$0040
        stx     $4305
        jsr     ExecDMA
        rts

; ------------------------------------------------------------------------------

; [ transfer dialogue text to vram ]

TfrDlgText:
.if LANG_EN


@b55f:  lda     $ed
        bne     @b564
        rts
@b564:  stz     $ed
        lda     $ba
        and     #$03
        sta     $13
        lda     #$03
        sta     $12
        lda     $13
        clc
        adc     #$2c
        sta     $13
        ldx     #$0774
        stx     $14
        stz     $2115
        jsr     InitDMA
        stz     $4300
        lda     #$04
        sta     $11
@b589:  ldx     #$0844      ; source = $000844
        stx     $4302
        ldx     $12
        stx     $2116
        ldx     #$001a      ; size = $001a
        stx     $4305
        jsr     ExecDMA
        lda     $12
        clc
        adc     #$20
        sta     $12
        lda     $13
        adc     #$00
        sta     $13
        stz     hMDMAEN
        ldx     $14
        stx     $4302
        ldx     $12
        stx     $2116
        ldx     #$001a
        stx     $4305
        jsr     ExecDMA
        lda     $12
        clc
        adc     #$20
        sta     $12
        lda     $13
        adc     #$00
        cmp     #$30
        bne     @b5d1
        lda     #$2c
@b5d1:  sta     $13
        lda     $14
        clc
        adc     #$1a
        sta     $14
        lda     $15
        adc     #$00
        sta     $15
        dec     $11
        beq     @b5e7
        jmp     @b589
@b5e7:  inc     $ba
        rts

.else

@b80d:  lda     $ed
        bne     @b812
        rts
@b812:  stz     $ed
        lda     $ba
        and     #$03
        sta     $13
        lda     #$04
        sta     $12
        lda     $13
        clc
        adc     #$2c
        sta     $13
        ldx     #$0774
        stx     $14
        ldx     #$0834
        stx     $16
        stz     $2115
        jsr     InitDMA
        stz     $4300
        lda     #$04
        sta     $11
@b83c:  ldx     $16
        stx     $4302
        ldx     $12
        stx     $2116
        ldx     #$0018
        stx     $4305
        jsr     ExecDMA
        lda     $12
        clc
        adc     #$20
        sta     $12
        lda     $13
        adc     #$00
        sta     $13
        stz     hMDMAEN
        ldx     $14
        stx     $4302
        ldx     $12
        stx     $2116
        ldx     #$0018
        stx     $4305
        jsr     ExecDMA
        lda     $12
        clc
        adc     #$20
        sta     $12
        lda     $13
        adc     #$00
        cmp     #$30
        bne     @b883
        lda     #$2c
@b883:  sta     $13
        lda     $14
        clc
        adc     #$18
        sta     $14
        lda     $15
        adc     #$00
        sta     $15
        lda     $16
        clc
        adc     #$18
        sta     $16
        lda     $17
        adc     #$00
        sta     $17
        dec     $11
        beq     @b8a6
        jmp     @b83c
@b8a6:  inc     $ba
        rts

.endif
; ------------------------------------------------------------------------------

; [ hide map title window ]

HideMapTitle:
@b8a9:  lda     $ea
        cmp     #$01
        beq     @b8b0
        rts
@b8b0:  inc     $ea
        lda     #$80
        sta     hVMAINC
        jsr     InitDMA
        lda     #$09
        sta     $4300       ; fixed address
        ldx     #$2840
        stx     hVMADDL
        stz     $10         ; fixed value
        ldx     #$0610
        stx     $4302
        ldx     #$0100      ; clear $0100 bytes
        stx     $4305
        jsr     ExecDMA
        rts

; ------------------------------------------------------------------------------

; [ load map title ]

LoadMapTitle:
.if LANG_EN

@b618:  lda     $c5
        beq     @b61f
        stz     $c5
        rts
@b61f:  lda     $d1
        beq     @b624       ; return if loading previous map
        rts
@b624:  ldx     #0
        lda     $0fe6       ; map name
        bpl     @b62d
        rts
@b62d:  tay
        beq     @b63c
@b630:  lda     f:MapTitle,x   ; map titles
        inx
        cmp     #0
        bne     @b630
        dey
        bne     @b630
@b63c:  stx     $3d         ; +$3d = pointer to map
        stz     $07
@b640:  lda     f:MapTitle,x
        inx
        inc     $07         ; $07 = length of string
        cmp     #0
        bne     @b640       ; branch if not null terminator
        dec     $07
        lda     #$16
        sec
        sbc     $07
        lsr
        sta     $06         ; $06 = ($16 - length of string) / 2
        ldx     #0
        lda     #$ff
@b65a:  sta     $0774,x
        sta     $078a,x
        inx
        cpx     #$0016
        bne     @b65a
        ldx     $3d
        lda     $06
        tay
@b66b:  lda     f:MapTitle,x
        inx
        sta     $0774,y
        iny
        dec     $07
        bne     @b66b
        lda     #1        ; show map name window
        sta     $e9
        rts

.else

@b8d7:  lda     $c5
        beq     @b8de
        stz     $c5
        rts
@b8de:  lda     $d1
        beq     @b8e3
        rts
@b8e3:  ldx     #0
        lda     $0fe6
        bpl     @b8ec
        rts
@b8ec:  tay
        beq     @b8fb
@b8ef:  lda     f:MapTitle,x
        inx
        cmp     #$00
        bne     @b8ef
        dey
        bne     @b8ef
@b8fb:  stx     $3d
        stz     $07
@b8ff:  lda     f:MapTitle,x
        inx
        inc     $07
        cmp     #$00
        bne     @b8ff
        dec     $07
        lda     #$0c
        sec
        sbc     $07
        lsr
        sta     $06
        ldx     #0
        lda     #$ff
@b919:  sta     $0774,x
        sta     $0780,x
        inx
        cpx     #$000c
        bne     @b919
        ldx     $3d
        lda     $06
        tay
@b92a:  lda     f:MapTitle,x
        inx
        jsr     GetDakuten
        sta     $0774,y
        xba
        sta     $0780,y
        iny
        lda     #0
        xba
        dec     $07
        bne     @b92a
        lda     #1
        sta     $e9
        rts

.endif

; ------------------------------------------------------------------------------

; [ transfer map title window to vram ]

TfrMapTitle:
.if LANG_EN

@b67d:  lda     $e9
        bne     @b682       ; return if map name window is not shown
        rts
@b682:  stz     $e9
        stz     $2112
        stz     $2112
        lda     #$80
        sta     $2115
        ldx     #$2843
        stx     $2116
        lda     #$16        ; top left corner ($16)
        sta     $2118
        lda     #$20
        sta     $2119
        ldx     #$0000
@b6a2:  lda     #$17        ; top border ($17)
        sta     $2118
        lda     #$20
        sta     $2119
        inx
        cpx     #$0018
        bne     @b6a2
        lda     #$18        ; top right corner ($18)
        sta     $2118
        lda     #$20
        sta     $2119
        ldx     #$2863
        stx     $2116
        ldx     #$2019      ; left border ($19)
        stx     $2118
        ldx     #$20ff
        stx     $2118
        ldx     #$0000
@b6d1:  lda     #$ff        ; spaces ($ff)
        sta     $2118
        lda     #$20
        sta     $2119
        inx
        cpx     #$0016
        bne     @b6d1
        ldx     #$20ff
        stx     $2118
        ldx     #$201a      ; right border ($1a)
        stx     $2118
        ldx     #$2883
        stx     $2116
        ldx     #$2019      ; left border ($19)
        stx     $2118
        ldx     #$20ff      ; space ($ff)
        stx     $2118
        ldx     #$0000
@b702:  lda     $0774,x     ; map name letters
        sta     $2118
        lda     #$20
        sta     $2119
        inx
        cpx     #$0016
        bne     @b702
        ldx     #$20ff      ; space ($ff)
        stx     $2118
        ldx     #$201a      ; right border($1a)
        stx     $2118
        lda     #$80
        sta     $2115
        ldx     #$28a3
        stx     $2116
        lda     #$1b        ; bottom left corner ($1b)
        sta     $2118
        lda     #$20
        sta     $2119
        ldx     #$0000
@b737:  lda     #$1c        ; bottom border ($1c)
        sta     $2118
        lda     #$20
        sta     $2119
        inx
        cpx     #$0018
        bne     @b737
        lda     #$1d        ; bottom right corner ($1d)
        sta     $2118
        lda     #$20
        sta     $2119
        rts

.else

@b946:  lda     $e9
        bne     @b94b
        rts
@b94b:  stz     $e9
        stz     $2112
        stz     $2112
        lda     #$80
        sta     $2115
        ldx     #$2848
        stx     $2116
        ldx     #$0000
@b961:  lda     f:MapTitleTilesTop,x
        sta     $2118
        inx
        lda     f:MapTitleTilesTop,x
        sta     $2119
        inx
        cpx     #$0020
        bne     @b961
        ldx     #$2868
        stx     $2116
        ldx     #$2019
        stx     $2118
        ldx     #$20ff
        stx     $2118
        ldx     #$0000
@b98b:  lda     $0780,x
        sta     $2118
        lda     #$20
        sta     $2119
        inx
        cpx     #$000c
        bne     @b98b
        ldx     #$2876
        stx     $2116
        ldx     #$20ff
        stx     $2118
        ldx     #$201a
        stx     $2118
        ldx     #$2888
        stx     $2116
        ldx     #$2019
        stx     $2118
        ldx     #$20ff
        stx     $2118
        ldx     #$0000
@b9c3:  lda     $0774,x
        sta     $2118
        lda     #$20
        sta     $2119
        inx
        cpx     #$000c
        bne     @b9c3
        ldx     #$2896
        stx     $2116
        ldx     #$20ff
        stx     $2118
        ldx     #$201a
        stx     $2118
        lda     #$80
        sta     $2115
        ldx     #$28a8
        stx     $2116
        ldx     #0
@b9f4:  lda     f:MapTitleTilesBtm,x
        sta     $2118
        inx
        lda     f:MapTitleTilesBtm,x
        sta     $2119
        inx
        cpx     #$0020
        bne     @b9f4
        rts

.endif
; --------------------------------------------------------------------------
