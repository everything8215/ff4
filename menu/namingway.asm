
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: namingway.asm                                                        |
; |                                                                            |
; | description: namingway menu routines                                       |
; |                                                                            |
; | created: 4/8/2022                                                          |
; +----------------------------------------------------------------------------+

; [ namingway menu ]

NamingwayMenu:
@ba1a:  phb
        phd
        jsr     SaveDlgGfx_far
        jsr     NamingwayYesNo
        jsr     RestoreDlgGfx_far
        tdc
        sta     f:$001b49
        xba
        pld
        plb
        rts

; ------------------------------------------------------------------------------

; [ namingway menu (change name?) ]

; お名前のご変更で？

NamingwayYesNo:
@ba2e:  jsr     InitMenu
        lda     #$7e
        pha
        plb
        inc     $1b49
        jsr     SelectBG4
        jsr     ClearAllBGTiles
        jsr     ResetSprites
        ldy     #.loword(NamingwayMsgWindow)
        jsr     DrawWindow
        ldy     #.loword(NamingwayChoiceWindow)
        jsr     DrawWindowText
        ldx     #bg_pos 4,6
        ldy     #.loword(NamingwayChoiceText)
        jsr     CopyText
        jsr     LoadCharGfx
        jsr     _0198c9
        jsr     _01badc
        lda     #$ff
        sta     $1b4a
        jsr     TfrBG4Tiles
        jsr     LoadNamingwayGfx
        jsr     TfrSprites
        jsr     TfrPal
        jsr     FadeIn
        stz     $1b48

; start of frame loop
@ba76:  lda     $1b48
        bne     @ba80
        ldx     #$3010
        bra     @ba83
@ba80:  ldx     #$3040
@ba83:  tdc
        ldy     #$0300
        jsr     DrawCursor
        jsr     _01badc
        jsr     TfrSpritesVblank
        jsr     TfrBG4Tiles
        jsr     UpdateCtrlMenu

; A button
        lda     $00
        and     #JOY_A
        beq     @baaa                   ; branch if A button is not pressed
        lda     $1b48
        bne     @baa8
        stz     $00
        stz     $01
        jmp     NameSelectChar
@baa8:  bra     _bac4
@baaa:  lda     $01
        and     #JOY_B
        bne     _bac4                   ; branch if B button is pressed

; left or right button
        lda     $01
        and     #JOY_LEFT|JOY_RIGHT
        beq     @bac1
        inc     $1b48
        lda     $1b48
        and     #$01
        sta     $1b48
@bac1:  jmp     @ba76

; B button
_bac4:  ldy     #.loword(NamingwayMsgWindow)
        jsr     DrawWindow
        ldy     #.loword(NamingwayMsg5PosText)  ; that's better
        jsr     DrawPosText
        jsr     WaitVblank
        jsr     TfrBG4Tiles
        jsr     WaitKeypress
        jmp     FadeOut

; ------------------------------------------------------------------------------

; [  ]

_01badc:
@badc:  jsr     _01d12e
        lda     $1b4a
        bmi     @baf3
        sta     $43
        longa
        lda     $43
        asl
        tax
        shorta
        lda     #$08
        sta     $1b4b,x
@baf3:  ldx     #$2588
        jmp     UpdatePartySpritesNamingway

; ------------------------------------------------------------------------------

; [ namingway menu (change whose name?) ]

; どなた様がご変更なさいますか？

NameSelectChar:
@baf9:  stz     $45
@bafb:  lda     $45
        jsr     GetCharID
        bne     @bb0e
        inc     $45
        lda     $45
        cmp     #$05
        bne     @bafb
        stz     $45
        bra     @bafb
@bb0e:  lda     $45
        sta     $1b4a
        lda     #$01
        sta     $1a73
        ldy     #.loword(NamingwayMsgWindow)
        jsr     DrawWindow
        ldy     #.loword(NamingwayMsg2PosText)  ; change who's name?
        jsr     DrawPosText
        ldy     #.loword(NamingwayPreviewWindow)
        jsr     DrawWindow
.if !EASY_VERSION
; this line was removed in the easy version for some reason
        jsr     WaitVblank
.endif
        jsr     TfrBG4Tiles

; start of frame loop
@bb30:  jsr     _01badc
        lda     $1b4a
        jsr     GetCharPtr
        stx     $60
        lda     ($60)
        ldy     #$0152
        jsr     DrawCharName
        jsr     TfrBG4TilesVblank
        jsr     TfrSprites
        jsr     UpdateCtrlMenu

; right button
        lda     $01
        and     #JOY_RIGHT
        beq     @bb6e
@bb52:  lda     #$01
        sta     $1a73
        lda     $1b4a
        inc
        cmp     #$05
        bne     @bb60
        tdc
@bb60:  sta     $1b4a
        jsr     GetCharPtr
        stx     $45
        lda     ($45)
        and     #$3f
        beq     @bb52

; left button
@bb6e:  lda     $01
        and     #JOY_LEFT
        beq     @bb8f
@bb74:  lda     #$01
        sta     $1a73
        lda     $1b4a
        dec
        bpl     @bb81
        lda     #$04
@bb81:  sta     $1b4a
        jsr     GetCharPtr
        stx     $45
        lda     ($45)
        and     #$3f
        beq     @bb74
@bb8f:  lda     $00
        and     #JOY_A
        beq     @bb98
        jmp     @bba4
@bb98:  lda     $01
        and     #JOY_B
        beq     @bba1
        jmp     _bac4
@bba1:  jmp     @bb30

; A button
@bba4:  lda     $1b4a
        jsr     GetCharID
        dec
        jsr     Tax16
        lda     f:CharNameTbl,x         ; name for each character
        sta     $43
        longa
        lda     $43                     ; multiply by 6
        asl
        sta     $45
        asl
        adc     $45
        adc     #$1500
        tax
        lda     #5
        ldy     #$1b0a                  ; copy name to buffer
        phy
        phx
        mvn     #$7e,#$7e
        shorta
        jsr     NameMenu
        ply
        plx
        longa
        lda     #5
        mvn     #$7e,#$7e
        shorta
        rts

; ------------------------------------------------------------------------------

; [  ]

LoadNamingwayGfx:
@bbdf:  longa
        lda     #$000f
        ldx     #.loword(MapSpritePal)+19*16
        ldy     #$a120
        mvn     #^MapSpritePal,#$7e
        shorta
        ldy     #$f380
        jmp     _01d095

; ------------------------------------------------------------------------------
