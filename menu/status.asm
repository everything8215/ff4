
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: status.asm                                                           |
; |                                                                            |
; | description: character status menu                                         |
; |                                                                            |
; | created: 3/14/2022                                                         |
; +----------------------------------------------------------------------------+

; [ status menu ]

ShowStatusMenu:
@a92f:  inc     $1bc2
        jsr     StatusMenuMain
        stz     $1bc2
        rts

; ------------------------------------------------------------------------------

; [  ]

StatusMenuMain:
@a939:  stz     $1b27
        jsr     SelectChar
        lda     $e8
        bpl     @a944
        rts
@a944:  lda     $e8
        jsr     GetCharPtr
        stx     $60
        lda     ($60)
        and     #$3f
        bne     @a952
        rts
@a952:  jsr     ResetBGScroll
        jsr     SavePal1
        jsr     ResetSprites
        jsr     ClearBG2Tiles
        jsr     ClearBG1Tiles
        jsr     TfrSpritesVblank
        jsr     TfrPal
        lda     #$0c
        sta     $c2
        lda     #$04
        sta     $b1
        sta     $a5
        jsr     SelectBG4
        ldy     #$0270                  ; (19,16)
        lda     #$05                    ; 5 tiles wide
        clc                             ; set tiles to zero
        jsr     ClearText_far          ; hide the next row of text
        ldy     #.loword(MainOptionsWindow)
        ldx     #.loword(StatusPortraitWindow)
        jsr     TransformWindow
        jsr     TfrBG1TilesVblank
        lda     #$30                    ; sprite layer priority: 3
        sta     $c1
        lda     $e8
        ldy     #$0898
        jsr     DrawPortrait
        jsr     SelectBG2
        ldy     #.loword(StatusPortraitWindow)
        jsr     DrawWindow
        ldy     #.loword(StatusLabelPosText)
        jsr     DrawPosText
        jsr     TfrBG2TilesVblank
        jsr     TfrPal
        jsr     TfrSprites
        jsr     SelectBG1
        jsr     DrawStatusWindow
        lda     ($60)
        and     #$3f
        ldy     #$0084
        jsr     DrawCharName
        ldy     #$0088
        ldx     $60
        jsr     DrawStatusIcons
        ldy     #$0002
        lda     ($60),y
        ldy     #$015c
        jsr     DrawNum2
        ldy     #$0014
        lda     ($60),y
        ldy     #$0412
        jsr     DrawNum2
        ldy     #$0015
        lda     ($60),y
        ldy     #$0492
        jsr     DrawNum2
        ldy     #$0016
        lda     ($60),y
        ldy     #$0512
        jsr     DrawNum2
        ldy     #$0017
        lda     ($60),y
        ldy     #$0592
        jsr     DrawNum2
        ldy     #$0018
        lda     ($60),y
        ldy     #$0612
        jsr     DrawNum2
        ldy     #$001b
        lda     ($60),y
        ldy     #$03aa
        jsr     DrawNum2
        ldy     #$0028
        lda     ($60),y
        ldy     #$04aa
        jsr     DrawNum2
        ldy     #$0022
        lda     ($60),y
        ldy     #$05aa
        jsr     DrawNum2
        ldy     #$001c
        lda     ($60),y
        ldy     #$0434
        jsr     DrawNum2
        ldy     #$0029
        lda     ($60),y
        ldy     #$0534
        jsr     DrawNum2
        ldy     #$0023
        lda     ($60),y
        ldy     #$0634
        jsr     DrawNum2
        ldy     #$0037
        lda     ($60),y
        sta     $45
        iny
        lda     ($60),y
        sta     $46
        iny
        lda     ($60),y
        ldx     $45
        ldy     #$0226
        jsr     DrawNum7
        longa
        ldy     #$0007
        lda     ($60),y
        ldy     #$0288
        jsr     _018383
        ldy     #$0009
        lda     ($60),y
        ldy     #$0292
        jsr     _018383
        ldy     #$000b
        lda     ($60),y
        ldy     #$0308
        jsr     _018383
        ldy     #$000d
        lda     ($60),y
        ldy     #$0312
        jsr     _018383
        shorta
        tdc
        xba
        ldy     #$001d
        lda     ($60),y
        ldy     #$03b2
        jsr     DrawNum4
        ldy     #$002a
        lda     ($60),y
        ldy     #$04b2
        jsr     DrawNum4
        ldy     #$0024
        lda     ($60),y
        ldy     #$05b2
        jsr     DrawNum4
        lda     ($60)
        and     #$c0
        lsr3
        sta     $45
        stz     $46
        longa
        lda     #.loword(HandednessText)
        clc
        adc     $45
        tay
        shorta
        ldx     #$0186
        jsr     DrawMenuText
        ldy     #$0001
        lda     ($60),y
        ldy     #$0106
        jsr     DrawClassName
        jsr     DrawStatusWindowSymbols
        ldy     #$0002
        lda     ($60),y
        cmp     #$63
        bne     @aae9
        jmp     @ab70
@aae9:  ldy     #.loword(NextLevelPosText)
        jsr     DrawPosText
        ldy     #$003d
        lda     ($60),y
        sta     $45
        iny
        lda     ($60),y
        sta     $46
        iny
        lda     ($60),y
        sta     $47
        lda     ($60)
        and     #$3f
        dec
        asl
        jsr     Tax16
        longa
        lda     $0fb500,x
        sta     $48
        shorta
        ldy     #$0002
        lda     ($60),y
        cmp     #$45
        bcc     @ab1e
        lda     #$45
@ab1e:  dec
        sta     $43
        longa
        lda     $43
        asl2
        adc     $43
        adc     $48
        adc     #$0002
        tax
        shorta
        lda     $0f0000,x
        lsr5
        sta     $4b
        inx
        longa
        lda     $0f0000,x
        clc
        adc     $45
        sta     $45
        shorta
        lda     $47
        adc     $4b
        sta     $47
        ldy     #$0037
        longa
        lda     $45
        sec
        sbc     ($60),y
        sta     $45
        shorta
        iny2
        lda     $47
        sbc     ($60),y
        sta     $47
        ldy     #$02e6
        lda     $47
        ldx     $45
        jsr     DrawNum7
@ab70:  jsr     OpenWindow
        jsr     RestorePal1
        jsr     ClearBG1Tiles
        jsr     ClearBG2Tiles
        jsr     WaitKeypress
        jsr     CloseWindow
        jsr     TfrBG2TilesVblank
        jsr     TfrPal
        jsr     ResetSprites
        jsr     TfrSpritesVblank
        lda     #$0c
        sta     $c2
        lda     #$84
        sta     $b1
        sta     $a5
        jsr     SelectBG4
        ldx     #.loword(MainOptionsWindow)
        ldy     #.loword(StatusPortraitWindow)
        jsr     TransformWindow
        stz     $1bc2
        jsr     DrawMainMenu
        jsr     DrawAllPortraits
        jsr     TfrSpritesVblank
        jsr     CloseWindow
        jmp     ResetBGScroll

; ------------------------------------------------------------------------------

; [ draw status window ]

DrawStatusWindow:
@abb6:  ldy     #.loword(StatusWindow)
        jsr     DrawWindow
        ldy     #.loword(StatusPosText)
        jsr     DrawPosText

DrawStatusWindowSymbols:
@abc2:  lda     #$c3                    ; ellipsis
        sta     $ba10
        sta     $ba90
        sta     $bb10
        sta     $bb90
        sta     $bc10
        sta     $b9b2
        sta     $ba32
        sta     $bab2
        sta     $bb32
        sta     $bbb2
        sta     $bc32
        lda     #$c6                    ; %
        sta     $ba38
        sta     $bb38
        sta     $bc38
        lda     #$c7                    ; /
        sta     $b890
        sta     $b910
        rts

; ------------------------------------------------------------------------------
