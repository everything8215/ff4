
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: name.asm                                                             |
; |                                                                            |
; | description: name change menu routines                                     |
; |                                                                            |
; | created: 4/7/2022                                                          |
; +----------------------------------------------------------------------------+

; number of alphabets
.if LANG_EN
        NUM_ALPHA = 1
.else
        NUM_ALPHA = 3
.endif

; ------------------------------------------------------------------------------

; [ name change menu ]

NameMenu:
@9b61:  lda     f:$001b49
        bne     @9b8c                   ; branch if not stand-alone name change
        jsr     InitMenu
        jsr     LoadPortraits
        jsr     SelectBG4
        ldy     #.loword(NamePortraitWindow)
        jsr     DrawWindow
        ldy     #.loword(NamePreviewWindow)
        jsr     DrawWindow
        ldy     #$1040
        lda     #$30                    ; sprite layer priority: 3
        sta     $01c1
        lda     $1b18
        jsr     DrawPortrait
        bra     @9b92
@9b8c:  ldy     #.loword(NamingwayPreviewWindow)
        jsr     DrawWindow
@9b92:  ldy     #.loword(NameLettersWindow)
        jsr     DrawWindow
        jsr     SelectBG3
        ldy     #.loword(NameAlphaWindow)
        jsr     DrawWindow
        jsr     DrawAlphaNames
        longa
        lda     #$0800
        ldx     #$d600
        ldy     #$b600
        mvn     #$7e,#$7e
        shorta
        jsr     SelectBG4
        lda     $1b49
        beq     @9bc2
        ldy     #.loword(NamingwayPreviewWindow)
        jsr     DrawWindow
@9bc2:  lda     #$7e
        pha
        plb
        ldx     #$1b00
        lda     #$0a
@9bcb:  stz     a:$0000,x
        dec
        bne     @9bcb
        stz     $1b08
        ldx     #$1b0a
        ldy     #$0006
@9bda:  lda     a:$0000,x
        sta     a:$0007,x
        inx
        cmp     #$ff
        beq     @9be8
        inc     $1b08
@9be8:  dey
        bne     @9bda
        dec     $1b08
        lda     $1b08
        sta     $1b09
        jsr     InitNameLetters
        jsr     DrawNameInput
        lda     #NUM_ALPHA
        sta     $1b06
        jsr     TfrBG4TilesVblank
        jsr     TfrBG1TilesVblank
        jsr     TfrBG3TilesVblank
        lda     #$19
        sta     f:hTM
        ldx     #$fffc
        stx     $90
        stx     $9c
        jsr     UpdateScrollRegs_far
        jsr     TfrSprites
        jsr     FadeIn
        stz     $1bba
        jmp     AlphaSelect

; ------------------------------------------------------------------------------

; [ name input ]

NameInputSwitch:
@9c24:  jsr     SwitchToName

NameInput:
@9c27:  jsr     TfrNameLetters
        lda     $1b06
        asl
        sta     $45
        stz     $46
        ldx     $45
        longa
        lda     f:NameAlphaTblPtrs,x
        clc
        adc     #.loword(NameAlphaTbl)
        sta     $5a
        lda     #$0001                  ; bank 01
        sta     $5c
        shorta
        lda     $1b06
        sta     $45
        asl
        sta     $45
        stz     $46
        longa
        lda     $45
        clc
        adc     #$1b00
        sta     $5d
        inc
        sta     $60
        shorta
@9c60:  jsr     DrawNameInput
        lda     ($5d)
        sta     $45
        stz     $46
        ldx     $45
        lda     f:NameCursorX,x
        sta     $48
        lda     ($60)
        asl4
        clc
        adc     #$50
        sta     $49
        ldx     $48
        ldy     #$0300
        jsr     DrawCursor
        jsr     DrawNameChangeSprites
        jsr     TfrSpritesVblank
        jsr     TfrBG4Tiles
        jsr     UpdateCtrlMenu
.if !LANG_EN
; X button
        lda     $00
        and     #$40
        beq     @9ca8
        lda     $1b06
        cmp     #$02
        bne     @9ca2
        lda     #$ff
        sta     $1b06
@9ca2:  jsr     NextAlpha
        jmp     NameInput
.endif
; up button
@9ca8:  lda     $01
        bit     #JOY_UP
        beq     @9cbc
@9cae:  lda     ($60)
        dec
        bpl     @9cb5
        lda     #$07
@9cb5:  sta     ($60)
        jsr     GetAlphaLetter
        beq     @9cae
; down button
@9cbc:  lda     $01
        bit     #JOY_DOWN
        beq     @9cd1
@9cc2:  lda     ($60)
        inc
        cmp     #$08
        bcc     @9cca
        tdc
@9cca:  sta     ($60)
        jsr     GetAlphaLetter
        beq     @9cc2
; left button
@9cd1:  lda     $01
        bit     #JOY_LEFT
        beq     @9ce9
        lda     ($5d)
        dec
        bpl     @9ce2
@9cdc:  stz     $1b07
        jmp     AlphaSelectSwitch
@9ce2:  sta     ($5d)
        jsr     GetAlphaLetter
        beq     @9cdc
; right button
@9ce9:  lda     $01
        bit     #JOY_RIGHT
        beq     @9d0a
        lda     ($5d)
        inc
        cmp     #$0a
        bcc     @9cfc
@9cf6:  stz     $1b07
        jmp     AlphaSelectSwitch
@9cfc:  sta     ($5d)
        jsr     GetAlphaLetter
        bne     @9d0a
        lda     ($5d)
        dec
        sta     ($5d)
        bra     @9cf6
; A button
@9d0a:  lda     $00
        bit     #JOY_A
        beq     @9d2c
        lda     $1b08
        inc
        cmp     #$06
        bcs     @9d2c
        sta     $1b08
        jsr     GetAlphaLetter
        pha
        lda     $1b08
        sta     $45
        stz     $46
        ldy     $45
        pla
        sta     $1b0a,y                 ; set letter
; B button
@9d2c:  lda     $01
        bit     #JOY_B
        beq     @9d47
        lda     $1b08
        bmi     @9d4a
        dec
        sta     $1b08
        inc
        sta     $45
        stz     $46
        ldy     $45
        lda     #$ff
        sta     $1b0a,y                 ; clear letter
@9d47:  jmp     @9c60
@9d4a:  jsr     RevertName
        jmp     @9c60

; ------------------------------------------------------------------------------

; [ alphabet select ]

AlphaSelectSwitch:
@9d50:  jsr     SwitchToAlpha

AlphaSelect:
@9d53:  jsr     TfrNameLetters
@9d56:  lda     $1b06
        jsr     Tax16
        lda     f:AlphaCursorYTbl,x
        sta     $46
        lda     #$0c
        sta     $45
        jsr     DrawCursor1
        jsr     DrawNameChangeSprites
        jsr     TfrSpritesVblank
        jsr     UpdateCtrlMenu
; A button
        lda     $00
        and     #JOY_A
        beq     @9da6
        lda     $1b06
        cmp     #NUM_ALPHA
        bne     @9d96
        lda     $1b08
        bmi     @9d87
        jmp     FadeOut
@9d87:  jsr     RevertName
        jsr     DrawNameInput
        jsr     TfrBG4TilesVblank
        jsr     WaitKeypress
        jmp     FadeOut
@9d96:  lda     $1bba
        bne     @9d9e
        jsr     ResetNameInput
@9d9e:  lda     #$01
        sta     $1b07
        jmp     NameInputSwitch
; up button
@9da6:  lda     $01
        bit     #JOY_UP
        beq     @9dbd
        lda     $1b06
        dec
        sta     $1b06
        bpl     @9db7
        lda     #NUM_ALPHA              ; go to last alphabet
@9db7:  sta     $1b06
        jsr     TfrNameLetters
; down button
@9dbd:  lda     $01
        bit     #JOY_DOWN
        beq     @9dc6
        jsr     NextAlpha
; left or right button
@9dc6:  lda     $01
        bit     #JOY_LEFT|JOY_RIGHT
        beq     @9d56
        lda     $1bba
        bne     @9dd4
        jsr     ResetNameInput
@9dd4:  lda     $1b06
        cmp     #NUM_ALPHA
        bcc     @9dde
        jmp     @9d56
@9dde:  lda     #$01
        sta     $1b07
        jmp     NameInputSwitch

; ------------------------------------------------------------------------------

; [ transfer letters to ppu ]

TfrNameLetters:
@9de6:  jsr     DrawNameLetters
        jsr     TfrBG4TilesVblank
        jmp     UpdateCtrlMenu

; ------------------------------------------------------------------------------

; [ revert to previous name ]

RevertName:
@9def:  lda     $1b09
        sta     $1b08
        ldx     #$1b0a
        ldy     #6
@9dfb:  lda     a:$0007,x
        sta     a:$0000,x
        inx
        dey
        bne     @9dfb
        rts

; ------------------------------------------------------------------------------

; [ draw alphabet letters ]

DrawNameLetters:
.if LANG_EN
InitNameLetters:
@9df4:  ldx     $41
.else
@9e06:  lda     $1b06
        beq     _9e12
        dec
        beq     _9e16
        dec
        beq     _9e1b
        rts

InitNameLetters:
_9e12:  ldx     $41                     ; first alphabet
        bra     _9e1e
_9e16:  ldx     #$0050                  ; second alphabet
        bra     _9e1e
_9e1b:  ldx     #$00a0                  ; third alphabet
.endif
_9e1e:  ldy     #$c852
        lda     #$08
        sta     $45
@9e25:  lda     #$02
        sta     $4b
@9e29:  lda     #$05
        sta     $48
@9e2d:  lda     f:NameAlphaTbl,x
        inx
        cmp     #$00
        beq     @9e3b
        jsr     GetDakuten
        bra     @9e44
@9e3b:  dec
        sta     a:$0000,y               ; copy to buffer
        sta     a:$0040,y
        bra     @9e4b
@9e44:  sta     a:$0000,y               ; dakuten
        xba
        sta     a:$0040,y               ; kana
@9e4b:  iny4
        dec     $48
        bne     @9e2d
        iny2
        dec     $4b
        bne     @9e29
        longa
        tya
        clc
        adc     #$0054
        tay
        shorta
        dec     $45
        bne     @9e25
        rts

; ------------------------------------------------------------------------------

; [ draw alphabet names ]

DrawAlphaNames:
@9e68:  ldy     #.loword(NameAlphaPosText)
        jmp     DrawPosText

; ------------------------------------------------------------------------------

; [ get selected letter ]

GetAlphaLetter:
@9e6e:  phy
        ldy     $41                     ; zero
        lda     ($60)
        asl                             ; multiply by 10
        sta     $45
        asl2
        clc
        adc     $45
        adc     ($5d)
        sta     $45
        stz     $46
        ldy     $45
        lda     [$5a],y                 ; get letter
        ply
        cmp     #$00
        rts

; ------------------------------------------------------------------------------

; [ draw the current name input ]

DrawNameInput:
@9e89:  phx
        phy
        lda     $1b49
        beq     @9e95
        ldy     #$0152                  ; text position (stand-alone)
        bra     @9e98
@9e95:  ldy     #$00e0                  ; text position (namingway)
@9e98:  ldx     #$1b0a
        lda     #6                      ; copy 6 letters
        sta     $45
@9e9f:  lda     a:$0000,x
        inx
        jsr     GetDakuten
        sta     $c600,y     ; dakuten
        xba
        sta     $c640,y     ; kana
        iny2
        dec     $45
        bne     @9e9f
        ply
        plx
        rts

; ------------------------------------------------------------------------------

; [ draw namingway and character sprites ]

DrawNameChangeSprites:
@9eb6:  lda     $1b49
        bne     @9ebc                   ; return if not namingway
        rts
@9ebc:  jmp     _01badc

; ------------------------------------------------------------------------------

; [ switch to alphabet select ]

SwitchToAlpha:
@9ebf:  ldx     #4
@9ec2:  inc     $9c
        jsr     UpdateScrollRegsVblank
        dex
        bne     @9ec2
        ldx     $9c
        stx     $90
        lda     #$19
        sta     f:hTM
        ldx     #4
@9ed7:  dec     $90
        jsr     UpdateScrollRegsVblank
        dex
        bne     @9ed7
        rts

; ------------------------------------------------------------------------------

; [ switch to name input ]

SwitchToName:
@9ee0:  ldx     #4
@9ee3:  inc     $90
        jsr     UpdateScrollRegsVblank
        dex
        bne     @9ee3
        ldx     $90
        stx     $9c
        lda     #$1c
        sta     f:hTM
        ldx     #4
@9ef8:  dec     $9c
        jsr     UpdateScrollRegsVblank
        dex
        bne     @9ef8
        rts

; ------------------------------------------------------------------------------

; [ go to next alphabet ]

NextAlpha:
@9f01:  lda     $1b06
        inc
        sta     $1b06
        cmp     #NUM_ALPHA+1
        bcc     @9f0d
        tdc
@9f0d:  sta     $1b06
        jmp     TfrNameLetters

; ------------------------------------------------------------------------------

; [  ]

ResetNameInput:
@9f13:  lda     #$ff
        sta     $1b08
        sta     $1bba
        ldx     $41         ; zero
@9f1d:  sta     $1b0a,x
        inx
        cpx     #6
        bne     @9f1d
        rts

; ------------------------------------------------------------------------------
