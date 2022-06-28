
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: order.asm                                                            |
; |                                                                            |
; | description: change party order/row                                        |
; |                                                                            |
; | created: 3/14/2022                                                         |
; +----------------------------------------------------------------------------+

; [ order (main menu) ]

ChangeOrder:
@abf9:  jsr     ChangeOrderMain
        stz     $1bb8
        rts

; ------------------------------------------------------------------------------

; [ order (main menu) ]

ChangeOrderMain:
@ac00:  inc     $1b27
        inc     $1bb8
        inc     $84
@ac08:  jsr     SelectChar
        lda     $e8
        cmp     #$7f
        bne     @ac27       ; branch if didn't press left or right
        lda     #$01
        eor     $16a8
        sta     $16a8
        jsr     DrawMainMenu
        jsr     DrawTimeGil
        jsr     TfrBG3TilesVblank
        jsr     TfrPal
        bra     @ac08
@ac27:  lda     $e8
        bpl     @ac2e       ; branch if didn't cancel
        stz     $e8
        rts
@ac2e:  lda     $e7         ; selected character
        asl3
        sta     $45
        asl2
        adc     $45
        adc     #$14
        sta     $46
        lda     #$04
        sta     $45
        jsr     DrawCursor2
        lda     $e8
        sta     $d9         ; 1st selected character
        stz     $1b27
        jsr     SelectChar
        lda     $e8
        bpl     @ac5a
        stz     $e8
        jsr     HideCursor2
        jmp     HideCursor1
@ac5a:  sta     $da         ; 2nd selected character
        cmp     $d9
        bne     @ac62
        bra     @ac2e       ; loop if same character
@ac62:  lda     $d9
        jsr     GetCharID
        sta     $45
        lda     $da
        jsr     GetCharID
        ora     $45
        bne     @ac75       ; branch if at least one slot is not empty
        jmp     HideCursor2
@ac75:  jsr     LoadCharGfx
        jsr     OrderChangeAnim
        longa
        lda     $da
        and     #$00ff
        asl6
        adc     #$1000
        tax
        phx
        ldy     #$f600      ; swap character properties
        lda     #$003f
        mvn     #$00,#$7e
        ply
        lda     $d9
        and     #$00ff
        asl6
        adc     #$1000
        tax
        phx
        lda     #$003f
        mvn     #$7e,#$7e
        ply
        ldx     #$f600
        lda     #$003f
        mvn     #$7e,#$7e
        shorta
        lda     $d9
        jsr     Tax16
        lda     $16b9,x     ; swap controller for each character
        pha
        txy
        lda     $da
        jsr     Tax16
        lda     $16b9,x
        sta     $16b9,y
        pla
        sta     $16b9,x
        jsl     _1efdd0
        jsr     LoadPortraits
        jsr     HideCursor2
        bra     _ace8

; ------------------------------------------------------------------------------

; [ row (main menu) ]

ChangeRow:
@acde:  lda     #1        ; toggle row setting
        eor     $16a8
        sta     $16a8
        inc     $84
_ace8:  jsr     DrawMainMenu
        jsr     DrawTimeGil
        jsr     TfrBG3TilesVblank
        jmp     TfrPal

; ------------------------------------------------------------------------------

; [  ]

_01acf4:
@acf4:  asl
        jsr     Tax16
        longa
        lda     f:_01ad02,x
        tay
        shorta
        rts

; ------------------------------------------------------------------------------

; character slot sprite y-positions ???
_01ad02:
@ad02:  .word   $601c,$101c,$b01c,$381c,$881c

; ------------------------------------------------------------------------------

; [  ]

_01ad0c:
@ad0c:  jsr     HideCursor2
        jsr     SavePal1
        lda     #$30        ; sprite layer priority: 3
        sta     $c1
        lda     $d9
        sta     $1d
        jsr     _01acf4
        sty     $1f
        sty     $d5
        stz     $1e
        jsr     DrawCharSprite
        lda     $da
        sta     $1d
        jsr     _01acf4
        sty     $1f
        sty     $d7
        stz     $1e
        jsr     DrawCharSprite
        lda     $d9
        jsr     _01adf9
        lda     $da
        jsr     _01adf9
        jsr     TfrSpritesVblank
        jmp     TfrPal

; ------------------------------------------------------------------------------

; [  ]

_01ad46:
@ad46:  lda     $d9
        asl
        sta     $43
        ldx     $43
        lda     $da
        asl
        sta     $43
        ldy     $43
        phb
        phk
        plb
        longa
        lda     _01ad02,x
        sec
        sbc     _01ad02,y
        bcs     @ad7e
        lda     _01ad02,y
        sec
        sbc     _01ad02,x
        plb
        xba
        lsr2
        sta     $1b9c
        lda     #$fc00
        sta     $1b9f
        lda     #$0400
        sta     $1b9d
        bra     @ad91
@ad7e:  plb
        xba
        lsr2
        sta     $1b9c
        lda     #$fc00
        sta     $1b9d
        lda     #$0400
        sta     $1b9f
@ad91:  shorta
        rts

; ------------------------------------------------------------------------------

; [ character order change animation ]

OrderChangeAnim:
@ad94:  jsr     _01ad0c
        ldx     #8
@ad9a:  dec     $d5         ; move sprites out horizontally
        dec     $d5
        dec     $d5
        inc     $d7
        inc     $d7
        inc     $d7
        jsr     DrawOrderSprites
        jsr     TfrSpritesVblank
        dex
        bne     @ad9a
        jsr     _01ad46
@adb2:  longa
        lda     $d5         ; swap sprites vertically
        clc
        adc     $1b9d
        sta     $d5
        lda     $d7
        clc
        adc     $1b9f
        sta     $d7
        shorta
        jsr     DrawOrderSprites
        jsr     TfrSpritesVblank
        dec     $1b9c
        bne     @adb2
        jsr     _01ade8
        lda     $d9
        sta     $1d
        jsr     DrawCharSpriteOrder
        lda     $da
        sta     $1d
        jsr     DrawCharSpriteOrder
        jsr     TfrSpritesVblank
        jmp     RestorePal1

; ------------------------------------------------------------------------------

; [  ]

_01ade8:
@ade8:  ldx     #$0018
@adeb:  dec     $d7         ; move sprites back in
        inc     $d5
        jsr     DrawOrderSprites
        jsr     TfrSpritesVblank
        dex
        bne     @adeb
        rts

; ------------------------------------------------------------------------------

; [  ]

_01adf9:
@adf9:  asl5
        sta     $43
        ldy     $43
        ldx     #$0020
@ae05:  lda     $fe28,y     ; character palette buffer
        sta     $a160,y
        iny
        dex
        bne     @ae05
        rts

; ------------------------------------------------------------------------------

; [ draw character sprites (order change) ]

DrawOrderSprites:
@ae10:  lda     $d9
        sta     $1d
        ldy     $d5
        sty     $1f
        stz     $1e
        jsr     DrawCharSprite
        lda     $da
        sta     $1d
        ldy     $d7
        sty     $1f
        stz     $1e
        jmp     DrawCharSprite

; ------------------------------------------------------------------------------
