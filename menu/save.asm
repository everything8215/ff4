
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: save.asm                                                             |
; |                                                                            |
; | description: save game to sram slot                                        |
; |                                                                            |
; | created: 3/14/2022                                                         |
; +----------------------------------------------------------------------------+

; [ save menu ]

ShowSaveMenu:
@cb86:  lda     $1a02       ; check if save is enabled
        bne     @cb8e
        jmp     ErrorSfx
@cb8e:  jsr     FadeOut
        jsr     ClearAllBGTiles
        jsr     ResetSprites
        jsr     ResetBGScroll
        jsr     TfrSprites
        tdc
        jsr     CalcChecksum
        stx     $17fc
        jsr     _01cc38
        jsr     _0196de
        jsr     SelectBG2
        ldy     #.loword(SaveLabelPosText)
        jsr     DrawPosText
        jsr     TfrAllBGTiles
        jsr     ResetSprites
        lda     #$01
        sta     $1b9a
        jsr     _0199b8
        lda     #$01
        sta     $1b47
        lda     $1a3c
        bne     @cbd0
        lda     #$01
        sta     $1a3c
@cbd0:  jsr     _01977f
        jsr     LoadCharGfx
        jsr     _0198c9
        jsr     SelectSaveSlot
        bcc     @cc12
        jsr     ConfirmSaveSlot
        bcc     @cc2d
        lda     $1a3c
        dec
        bmi     @cc01
        asl3
        sta     $46
        stz     $45
        ldy     $45
        ldx     #$f600
        phb
        longa
        lda     #$07ff
        mvn     #$7e,#$70
        shorta
        plb
@cc01:  jsr     CureSfx
        jsr     SelectBG2
        ldy     #.loword(SaveMsgWindow)
        jsr     DrawWindow
        ldy     #.loword(SaveCompletePosText)
        bra     @cc15
@cc12:  ldy     #.loword(SaveCancelledPosText)
@cc15:  jsr     DrawPosText
        jsr     _01cc4e
        jsr     TfrBG2TilesVblank
        jsr     WaitKeypress
        jsr     FadeOut
        jsr     UpdateWindowColor_far
        jsr     TfrPal
        jmp     FadeInMainMenu
@cc2d:
.if BUGFIX_MISC_MENU
        jsr     SelectBG2
.endif
        ldy     #.loword(SaveMsgWindow)
        jsr     DrawWindow
        ldy     #.loword(SaveCancelMsgPosText)
        bra     @cc15

; ------------------------------------------------------------------------------

; [  ]

_01cc38:
@cc38:  lda     #$01
        sta     $17fb
        longa
        lda     #$07ff
        ldx     #$1000
        ldy     #$f600
        mvn     #$7e,#$7e
        shorta
        rts

; ------------------------------------------------------------------------------

; [  ]

_01cc4e:
@cc4e:  longa
        lda     #$07ff
        ldx     #$f600
        ldy     #$1000
        mvn     #$7e,#$7e
        shorta
        rts

; ------------------------------------------------------------------------------

; [ calculate save slot checksum ]

CalcChecksum:
@cc5f:  sta     $4e
        asl
        adc     $4e
        jsr     Tax16
        lda     f:SaveSlotTbl,x
        sta     $4e
        longa
        lda     f:SaveSlotTbl+1,x
        sta     $4f
        lda     $41         ; zero
        ldy     #$07fa
        clc
@cc7b:  adc     [$4e]
        inc     $4e
        dey
        bne     @cc7b
        tax
        shorta
        rts

; ------------------------------------------------------------------------------

; pointers to save slot data (5 * 3 bytes)
SaveSlotTbl:
@cc86:  .faraddr  $7e1000  ; 0: ram
        .faraddr  $700000  ; 1: sram slot 1
        .faraddr  $700800  ; 2: sram slot 2
        .faraddr  $701000  ; 3: sram slot 3
        .faraddr  $701800  ; 4: sram slot 4

; ------------------------------------------------------------------------------
