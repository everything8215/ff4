
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: cursor.asm                                                           |
; |                                                                            |
; | description: battle cursor routines                                        |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

; [ update character menu ]

UpdateCharMenu:
@abf4:  lda     $181e                   ; return if vram update is pending
        ora     $181f
        ora     $1820
        beq     @ac00
        rts
@ac00:  lda     $f0b4
        asl
        tax
        lda     f:UpdateCharMenuTbl,x
        sta     $0e
        lda     f:UpdateCharMenuTbl+1,x
        sta     $0f
        stz     $f0b4
        jmp     ($000e)

UpdateCharMenuTbl:
@ac17:  .addr   CharMenuNoUpdate
        .addr   OpenCmdWindow
        .addr   CloseCharMenu

; ------------------------------------------------------------------------------

; [ close character menu ]

CloseCharMenu:
@ac1d:  lda     #$08                    ; close all windows
        sta     $1823

CharMenuNoUpdate:
        rts

; ------------------------------------------------------------------------------

; [ update cursor ]

UpdateCursor:
@ac23:  jsr     UpdateCharMenu
        lda     $f4ac
        beq     @ac33
        dec     $f4ac
        bne     @ac33
        inc     $38da
@ac33:  lda     $181e                   ; return if vram update is pending
        ora     $181f
        ora     $1820
        bne     @ac54
        lda     $1823                   ; cursor type
        asl
        tax
        lda     f:UpdateCursorTbl,x
        sta     a:$000e
        lda     f:UpdateCursorTbl+1,x
        sta     a:$000f
        jmp     ($000e)
@ac54:  rts

; ------------------------------------------------------------------------------

; cursor update jump table
UpdateCursorTbl:
@ac55:  .addr   UpdateCursor_00
        .addr   UpdateCursor_01
        .addr   UpdateCursor_02
        .addr   UpdateCursor_03
        .addr   UpdateCursor_04
        .addr   UpdateCursor_05
        .addr   UpdateCursor_06
        .addr   UpdateCursor_07
        .addr   UpdateCursor_08
        .addr   UpdateCursor_09
        .addr   UpdateCursor_0a
        .addr   UpdateCursor_0b
        .addr   UpdateCursor_0c
        .addr   UpdateCursor_0d
        .addr   UpdateCursor_0e
        .addr   UpdateCursor_0f
        .addr   UpdateCursor_10

; ------------------------------------------------------------------------------

; [ cursor update $0f: character target select ]

UpdateCursor_0f:
@ac77:  jsr     OpenStatusWindow
        lda     #$0c
        sta     $1823
        rts

; ------------------------------------------------------------------------------

; [ cursor update $0d: close inventory ]

UpdateCursor_0d:
@ac80:  jsr     CloseInventoryWindow
        lda     #$01
        sta     $1823
        rts

; ------------------------------------------------------------------------------

; [ cursor update $0e: close status window (magic) ]

UpdateCursor_0e:
@ac89:  jsr     CloseStatusWindow
        lda     #$06
        sta     $1823
        rts

; ------------------------------------------------------------------------------

; [ cursor update $10: close status window (item) ]

UpdateCursor_10:
@ac92:  jsr     CloseStatusWindow
        lda     #$05
        sta     $1823
        rts

; ------------------------------------------------------------------------------

; [ get target index from target mask ]

; used to get target id from target mask
; returns $ff if no targets or multiple targets

GetTargetID:
@ac9b:  ldx     #0
@ac9e:  cmp     f:BitOrTbl,x
        beq     @acad
        inx
        cpx     #8
        bne     @ac9e
        lda     #$ff
        rts
@acad:  txa
        rts

; ------------------------------------------------------------------------------

; [ update target cursors ]

UpdateTargetCursors:
@acaf:  ldx     #$0101                  ; hide all target cursors
        stx     $ef76
        stx     $ef78
        lda     $ef8b
        beq     @ad2d
        lda     #$80
        sta     $ef7a
        sta     $ef7c
        sta     $ef7e
        sta     $ef80
        ldy     #0
        lda     $ef8f
        sta     $0e
        beq     @ad2e                   ; branch if no monster targets

; monster targets
        jsr     GetTargetID
        cmp     #$ff
        beq     @acef                   ; branch if multiple targets
        asl
        tay
        lda     $6ce3,y
        sta     $ef7a
        lda     $6ce4,y
        sta     $ef7b
        clr_a
        sta     $ef76
        rts
@acef:  lda     $1813
        and     #$01                    ; flash every frame
        beq     @ad02
        ldy     #8                      ; show cursors on monster slots 5-8
        lda     $ef8f
        asl4
        sta     $0e
@ad02:  ldx     #0
@ad05:  asl     $0e
        bcc     @ad20                   ; skip if not a target
        clr_a
        sta     $ef76,x
        phx
        txa
        asl
        tax
        lda     $6ce3,y
        sta     $ef7a,x
        lda     $6ce4,y
        sta     $ef7b,x
        plx
        bra     @ad25
@ad20:  lda     #$01
        sta     $ef76,x
@ad25:  iny2
        inx
        cpx     #4
        bne     @ad05
@ad2d:  rts

; character targets
@ad2e:  lda     $ef90
        sta     $0e
        jsr     GetTargetID
        cmp     #$ff
        beq     @ad4d                   ; branch if multiple targets
        asl
        tay
        lda     $6cf3,y
        sta     $ef7a
        lda     $6cf4,y
        sta     $ef7b
        clr_a
        sta     $ef76
        rts
@ad4d:  lda     $1813
        and     #$01
        beq     @ad5f
        ldy     #6                      ; show cursors on character slots 4-5
        lda     $ef90
        asl3
        sta     $0e
@ad5f:  ldx     #0
@ad62:  asl     $0e
        bcc     @ad7d
        clr_a
        sta     $ef76,x
        phx
        txa
        asl
        tax
        lda     $6cf3,y
        sta     $ef7a,x
        lda     $6cf4,y
        sta     $ef7b,x
        plx
        bra     @ad82
@ad7d:  lda     #$01
        sta     $ef76,x
@ad82:  iny2
        inx
        cpx     #3
        bne     @ad62
        rts

; ------------------------------------------------------------------------------

; [ select default target ]

; A: -eas---- targeting flags
;      e: target monsters by default
;      a: can target all
;      s: target selectable

SelectDefaultTarget:
@ad8b:  and     #$f0
        sta     $ef8c
        and     #$40
        beq     @adbe       ; branch if target characters by default

; monster default
@ad94:  lda     $0e
        beq     @ad9d
        ldx     #$f333
        bra     @ada0
@ad9d:  ldx     #$f33b
@ada0:  stx     $0e
        ldy     #0
@ada5:  lda     ($0e),y
        tax
        lda     $f123,x
        cmp     #$ff
        bne     @adb7
        iny                 ; try next monster
        cpy     #8
        bne     @ada5
        bra     @adbe       ; no valid monsters, try characters
@adb7:  lda     ($0e),y
        sta     $ef8d       ; cursor on first valid monster
        bra     @adf9

; character default
@adbe:  lda     #$08        ; cursor on first character
        sta     $ef8d
        ldx     #0
@adc6:  lda     f:_16fc4c,x
        tay
        lda     $f2bc,y
        bne     @addc       ; branch if character can't be selected
        lda     $f2c1,y
        bne     @addc       ; branch if character name and hp hidden
        lda     $29c5,y
        cmp     #$ff
        bne     @adf9
@addc:  inc     $ef8d       ; try next character
        inx
        cpx     #5
        bne     @adc6
        ldx     #0
@ade8:  lda     $f123,x
        cmp     #$ff
        bne     @adf6
        inx
        cpx     #8
        bne     @ade8
        rts
@adf6:  jmp     @ad94
@adf9:  lda     $ef8c
        and     #$20
        beq     @ae04       ; branch if can't target all
        lda     #$01
        bra     @ae05
@ae04:  clr_a
@ae05:  sta     $ef8e
        stz     $ef8b
        stz     $ef8f
        stz     $ef90
        lda     $ef8c
        and     #$70
        cmp     #$60
        beq     @ae23
        cmp     #$20
        bne     @ae28

; $20: target all characters
        lda     #$0d
        jmp     @ae25

; $60: target all monsters
@ae23:  lda     #$ff
@ae25:  sta     $ef8d
@ae28:  rts

; ------------------------------------------------------------------------------

; [ update target cursor ]

MoveTargetCursor:
@ae29:  lda     $6cc0
        beq     @ae41                   ; branch if not back attack
        lda     $38
        and     #$03
        tax
        lda     f:SwapLeftRightTbl,x
        sta     $1c
        lda     $38
        and     #$fc
        ora     $1c
        bra     @ae43
@ae41:  lda     $38
@ae43:  sta     $1c
        and     #$0f                    ; mask direction buttons
        asl
        tax
        lda     f:MoveTargetCursorTbl,x
        sta     $12
        lda     f:MoveTargetCursorTbl+1,x
        sta     $13
        stz     $14
        jmp     @ae5a
@ae5a:  jmp     ($0012)

; ------------------------------------------------------------------------------

; direction button jump table for target cursor (----udlr)
MoveTargetCursorTbl:
@ae5d:  .addr   MoveTargetCursorNone
        .addr   MoveTargetCursorBack
        .addr   MoveTargetCursorForward
        .addr   MoveTargetCursorNone
        .addr   MoveTargetCursorDown
        .addr   MoveTargetCursor_05
        .addr   MoveTargetCursor_06
        .addr   MoveTargetCursorDown
        .addr   MoveTargetCursorUp
        .addr   MoveTargetCursor_09
        .addr   MoveTargetCursor_0a
        .addr   MoveTargetCursorUp
        .addr   MoveTargetCursorNone
        .addr   MoveTargetCursorBack
        .addr   MoveTargetCursorForward
        .addr   MoveTargetCursorNone

; ------------------------------------------------------------------------------

; [ no cursor direction ]

MoveTargetCursorNone:
@ae7d:  rts

; ------------------------------------------------------------------------------

; [ move cursor down ]

MoveTargetCursorDown:
@ae7e:  lda     $ef8d
        cmp     #$ff
        beq     @aef3       ; return if all monsters are selected
        cmp     #$0d
        beq     @aef3       ; return if all characters are selected
        lda     $ef8d
        sta     $0e         ; save previous selection
        cmp     #$08
        bcc     @aebd       ; branch if a single monster is selected
@ae92:  lda     $0e
        asl
        tax
        lda     $29cf,x     ; character cursor data
        and     #$0f
        cmp     #$0f
        bne     @aea0       ; branch if not the lowest target
        rts
@aea0:  sta     $0e
        sec
        sbc     #$08
        tax
        lda     $f2bc,x
        bne     @ae92
        lda     $f2c1,x
        bne     @ae92
        lda     $29c5,x
        cmp     #$ff
        beq     @ae92
        lda     $0e
        sta     $ef8d       ; set new single character target
        rts
@aebd:  lda     $0e
        asl
        tax
        lda     $29cf,x     ; monster cursor data
        and     #$0f
        cmp     #$0f
        bne     @aee4       ; branch if not the lowest target
        ldx     #$0000
@aecd:  lda     $f34b,x
        tay
        lda     $f123,y
        cmp     #$ff
        bne     @aedf
        inx
        cpx     #8
        bne     @aecd
        rts
@aedf:  tya
        sta     $ef8d
        rts
@aee4:  sta     $0e
        tax
        lda     $f123,x
        cmp     #$ff
        beq     @aebd
        lda     $0e
        sta     $ef8d       ; set new single monster target
@aef3:  rts

; ------------------------------------------------------------------------------

; [ move cursor up ]

MoveTargetCursorUp:
@aef4:  lda     $ef8d
        cmp     #$ff
        beq     @af71
        cmp     #$0d
        beq     @af71
        lda     $ef8d
        sta     $0e
        cmp     #$08
        bcc     @af37
@af08:  lda     $0e
        asl
        tax
        lda     $29cf,x
        and     #$f0
        cmp     #$f0
        bne     @af16
        rts
@af16:  lsr4
        sta     $0e
        sec
        sbc     #$08
        tax
        lda     $f2bc,x
        bne     @af08
        lda     $f2c1,x
        bne     @af08
        lda     $29c5,x
        cmp     #$ff
        beq     @af08
        lda     $0e
        sta     $ef8d
        rts
@af37:  lda     $0e
        asl
        tax
        lda     $29cf,x
        and     #$f0
        cmp     #$f0
        bne     @af5e
        ldx     #0
@af47:  lda     $f343,x
        tay
        lda     $f123,y
        cmp     #$ff
        bne     @af59
        inx
        cpx     #8
        bne     @af47
        rts
@af59:  tya
        sta     $ef8d
        rts
@af5e:  lsr4
        sta     $0e
        tax
        lda     $f123,x
        cmp     #$ff
        beq     @af37
        lda     $0e
        sta     $ef8d
@af71:  rts

; ------------------------------------------------------------------------------

; [ move cursor left (forward) ]

MoveTargetCursorForward:
@af72:  lda     $ef8d
        cmp     #$ff
        beq     @afdf
        lda     $ef8d
        sta     $0e
        cmp     #$08
        bcc     @afaf
        cmp     #$0d
        bne     @af8d
        lda     $f331
        sta     $ef8d
        rts
@af8d:  ldx     #0
@af90:  lda     $f333,x
        tay
        lda     $f123,y
        cmp     #$ff
        bne     @afa8
        inx
        cpx     #8
        bne     @af90
        lda     $38                     ; force cancel button
        ora     #$80
        sta     $38
        rts
@afa8:  lda     $f333,x
        sta     $ef8d
        rts
@afaf:  lda     $0e
        asl
        tax
        lda     $29d0,x
        and     #$f0
        cmp     #$f0
        bne     @afcc
        lda     $ef8e
        beq     @afdf
        lda     $0e
        sta     $f332
        lda     #$ff
        sta     $ef8d
        rts
@afcc:  lsr4
        sta     $0e
        tax
        lda     $f123,x
        cmp     #$ff
        beq     @afaf
        lda     $0e
        sta     $ef8d
@afdf:  rts

; ------------------------------------------------------------------------------

; [ move cursor right (backward) ]

MoveTargetCursorBack:
@afe0:  lda     $ef8d
        cmp     #$13
        beq     @b04f
        cmp     #$ff
        bne     @b00d
        ldx     #0
@afee:  lda     $f33b,x
        tay
        lda     $f123,y
        cmp     #$ff
        bne     @b006
        inx
        cpx     #8
        bne     @afee
        lda     $38                     ; force cancel button
        ora     #$80
        sta     $38
        rts
@b006:  lda     $f33b,x
        sta     $ef8d
        rts
@b00d:  lda     $ef8d
        sta     $0e
        cmp     #$08
        bcc     @b02b
        cmp     #$0d
        bne     @b01b
        rts
@b01b:  lda     $ef8e
        beq     @b02a
        lda     $0e
        sta     $f331
        lda     #$0d
        sta     $ef8d
@b02a:  rts
@b02b:  lda     $0e
        asl
        tax
        lda     $29d0,x
        and     #$0f
        cmp     #$0f
        bne     @b040
        lda     #$0a
        sta     $ef8d
        jmp     MoveTargetCursorDown
@b040:  sta     $0e
        tax
        lda     $f123,x
        cmp     #$ff
        beq     @b02b
        lda     $0e
        sta     $ef8d
@b04f:  rts

; ------------------------------------------------------------------------------

; [ move cursor forward + up or down ]

MoveTargetCursor_06:
MoveTargetCursor_0a:
@b050:  jmp     MoveTargetCursorForward

; ------------------------------------------------------------------------------

; [ move cursor backward + up or down ]

MoveTargetCursor_05:
MoveTargetCursor_09:
@b053:  jmp     MoveTargetCursorBack

; ------------------------------------------------------------------------------

; [ cursor update $04, $07, $0c: target select ]

UpdateCursor_04:
UpdateCursor_07:
UpdateCursor_0c:
@b056:  jsr     CursorMoveSfx
        lda     $ef8c
        and     #$70
        bne     @b07c
        lda     $1822
        tax
        lda     f:BitOrTbl,x
        sta     $ef90
        stz     $ef8f
        ldx     $ef8f
        stx     $da
        stz     $ef8b
        lda     #$08
        sta     $1823
        rts
@b07c:  lda     #1
        sta     $ef8b
        lda     $ef8c
        and     #$10
        beq     @b08b
        jsr     MoveTargetCursor
@b08b:  lda     $ef8d
        cmp     #$ff
        beq     @b0f1
        cmp     #$08
        bcc     @b0f1
        cmp     #$0d
        beq     @b0c2
        sec
        sbc     #$08
        tax
        lda     $f2bc,x
        bne     @b0af
        lda     $f2c1,x
        bne     @b0af
        lda     $29c5,x
        cmp     #$ff
        bne     @b0b5
@b0af:  lda     $38                     ; force cancel button
        ora     #$80
        sta     $38
@b0b5:  lda     f:BitOrTbl,x
        sta     $ef90
        stz     $ef8f
        jmp     @b135
@b0c2:  ldx     #0
        stx     $0e
@b0c7:  lda     $f2bc,x
        bne     @b0e0
        lda     $f2c1,x
        bne     @b0e0
        lda     $29c5,x
        cmp     #$ff
        beq     @b0e0
        lda     f:BitOrTbl,x
        ora     $0e
        sta     $0e
@b0e0:  inx
        cpx     #5
        bne     @b0c7
        lda     $0e
        sta     $ef90
        stz     $ef8f
        jmp     @b135
@b0f1:  lda     $ef8d
        cmp     #$ff
        beq     @b113
        tax
        lda     $f123,x
        cmp     #$ff
        bne     @b106
        lda     $38                     ; force cancel button
        ora     #$80
        sta     $38
@b106:  lda     f:BitOrTbl,x
        sta     $ef8f
        stz     $ef90
        jmp     @b135
@b113:  ldx     #0
        stx     $0e
@b118:  lda     $f123,x
        cmp     #$ff
        beq     @b127
        lda     f:BitOrTbl,x
        ora     $0e
        sta     $0e
@b127:  inx
        cpx     #8
        bne     @b118
        lda     $0e
        sta     $ef8f
        stz     $ef90

; A button
@b135:  lda     $37
        bpl     @b150
        jsr     CancelConfirmSfx
        ldx     $ef8f
        stx     $da
        stz     $ef8b
        jsr     HideMenuCursorBoth
        jsr     HideAllTargetCursors
        lda     #$08
        sta     $1823
        rts

; B button
@b150:  lda     $38
        bpl     @b166
        jsr     CancelConfirmSfx
        jsr     HideMenuCursorBoth
        jsr     HideAllTargetCursors
        stz     $ef8b
        lda     $ef91                   ; restore previous cursor type
        sta     $1823
@b166:  rts

; ------------------------------------------------------------------------------

; [ cursor update $09: open mp cost window ]

UpdateCursor_09:
@b167:  jsr     OpenMPWindow
        lda     #$06
        sta     $1823
        rts

; ------------------------------------------------------------------------------

; [ cursor update $0a: close spell list ]

UpdateCursor_0a:
@b170:  lda     $4a
        and     #$40
        beq     @b17b
        jsr     CloseSummonMagicWindow
        bra     @b189
@b17b:  lda     $4a
        and     #$20
        beq     @b186
        jsr     CloseBlackMagicWindow
        bra     @b189
@b186:  jsr     CloseWhiteMagicWindow
@b189:  lda     #$01
        sta     $1823
        rts

; ------------------------------------------------------------------------------

; [ cursor update $08: close menu ]

UpdateCursor_08:
@b18f:  stz     $ef8b
        jsr     HideMenuCursorBoth
        jsr     HideAllTargetCursors
        jsr     HideListArrowBoth
        lda     $4d
        and     #$80
        beq     @b1a4
        jmp     CloseStatusWindow
@b1a4:  lda     $4c
        beq     @b1ab
        jmp     CloseRowWindow
@b1ab:  lda     $4b
        beq     @b1b2
        jmp     CloseDefendWindow
@b1b2:  lda     $4a
        and     #$80
        beq     @b1bb
        jmp     CloseMPWindow
@b1bb:  lda     $4a
        and     #$40
        beq     @b1c4
        jmp     CloseSummonMagicWindow
@b1c4:  lda     $4a
        and     #$20
        beq     @b1cd
        jmp     CloseBlackMagicWindow
@b1cd:  lda     $4a
        and     #$10
        beq     @b1d6
        jmp     CloseWhiteMagicWindow
@b1d6:  lda     $4a
        and     #$08
        beq     @b1df
        jmp     CloseEquipWindow
@b1df:  lda     $4a
        and     #$04
        beq     @b1e8
        jmp     CloseInventoryWindow
@b1e8:  lda     $4a
        and     #$02
        beq     @b1f1
        jmp     CloseCmdWindow
@b1f1:  sta     $1823
        sta     $d7
        lda     $f0ae
        bne     @b20d
        lda     $1822
        tay
        lda     $f2b1
        tax
        lda     f:CmdReadyPoseTbl,x
        sta     $f099,y
        sta     $f09e,y
@b20d:  rts

; ------------------------------------------------------------------------------

; [ check if item can be equipped (equip menu) ]

; set carry if item can be equipped

CheckInventoryToEquip:
@b20e:  lda     $ef96
        and     #$01
        eor     #$01
        tax
        lda     $0e,x
        sta     $0e
        lda     $ef96
        and     #$01
        tay
        jsr     GetEquipPtr
        lda     $ef95
        asl2
        tay
        lda     $321b,y
.if BUGFIX_ITEM_DUP
        beq     @b26c
.else
        beq     @b233                   ; branch if inventory slot is empty
.endif
        lda     $321a,y
        bmi     @b286                   ; branch if item is disabled
@b233:  lda     $32db,x
        beq     @b23d                   ; branch if equipment slot is empty
        lda     $32da,x
        bmi     @b286                   ; branch if equipment is disabled
@b23d:  lda     $32db,x
        cmp     $321b,y
        beq     @b272                   ; branch if items are the same
        lda     $321c,y
        cmp     #1
        beq     @b26c
        lda     $0e
        and     #$08
        beq     @b259
        lda     $321c,y
        cmp     #21
        bcc     @b26c
@b259:  lda     $32db,x
        beq     @b288
        lda     $181d
        cmp     #$ff
        beq     @b286
        lda     #$02
        sta     $181c
        sec
        rts

; entire inventory stack -> empty equipment slot
@b26c:  clr_a
        sta     $181c
        sec
        rts

; same item equipped and in inventory (only works for arrows)
@b272:  lda     $0e
        and     #$08
        beq     @b286                   ; fail if not arrows
        lda     $32dc,y
        cmp     #20
        beq     @b286
        lda     #$03
        sta     $181c
        sec
        rts

; can't equip
@b286:  clc
        rts

; overfull inventory slot -> empty equipment slot
@b288:  lda     #$04
        sta     $181c
        sec
        rts

; ------------------------------------------------------------------------------

; [ check if item can be equipped (inventory) ]

CheckEquipToInventory:
@b28f:  lda     $ef95
        and     #$01
        eor     #$01
        tax
        lda     $0e,x
        sta     $0e
        lda     $ef95
        and     #$01
        jsr     GetEquipPtr
        lda     $ef96
        asl2
        tay
        lda     $321b,y
        beq     @b2ee
        lda     $321a,y
        bmi     @b2ec
        lda     $32db,x
        beq     @b2bd
        lda     $32da,x
        bmi     @b2ec
@b2bd:  lda     $32db,x
        cmp     $321b,y
        beq     @b2f4
        lda     $321c,y
        cmp     #1
        beq     @b2ee
        lda     $0e
        and     #$08
        beq     @b2d9
        lda     $321c,y
        cmp     #21
        bcc     @b2ee
@b2d9:  lda     $32db,x
        beq     @b2fb
        lda     $181d
        cmp     #$ff
        beq     @b2ec
        lda     #$02
        sta     $181c
        sec
        rts
@b2ec:  clc
        rts

; equipment slot -> empty inventory slot
@b2ee:  clr_a
        sta     $181c
        sec
        rts

; equipment slot -> inventory slot with same item
@b2f4:  lda     #$01
        sta     $181c
        sec
        rts

; inventory item -> empty equipment slot
@b2fb:  lda     #$04
        sta     $181c
        sec
        rts

; ------------------------------------------------------------------------------

; [ cursor update $0b: equip window ]

UpdateCursor_0b:
@b302:  jsr     CursorMoveSfx
        lda     $38
        and     #$0f
        cmp     #$04
        beq     @b32f
        cmp     #$02
        bne     @b31b

; left button
        lda     $5f
        beq     @b33e
        dec     $5f
        dec     $63
        bra     @b341

; right button
@b31b:  cmp     #$01
        bne     @b33e
        lda     $5f
        cmp     #$01
        beq     @b32b
        inc     $5f
        inc     $63
        bra     @b341
@b32b:  dec     $5f
        dec     $63

; down button (close equip menu)
@b32f:  jsr     HideMenuCursor1
        jsr     CheckCursorEquipClose
        jsr     CloseEquipWindow
        lda     #$05
        sta     $1823
        rts
@b33e:  stz     $f416
@b341:  lda     $5f
        tax
        lda     f:InventoryCursorXTbl,x
        tax
        stx     $ef6b                   ; set menu cursor 1 x position
        lda     #$ac
        tax
        stx     $ef6d
        jsr     ShowMenuCursor1

; A button
        lda     $37
        bmi     @b35c
        jmp     @b45f
@b35c:  jsr     CancelConfirmSfx
        lda     $ef94
        bne     @b389

; select item
        inc     $ef94
        lda     $63
        ora     #$80
        sta     $ef95
        ldx     $ef6b
        inx4
        stx     $ef6f                   ; set menu cursor 2 x position
        ldx     $ef6d
        stx     $ef71
        jsr     ShowMenuCursor2
        lda     $ef9a
        bne     @b389
        jmp     @b485
@b389:  lda     $63
        ora     #$80
        sta     $ef96
        cmp     $ef95
        bne     @b3e4

; use item
        lda     $63
        jsr     GetEquipPtr
        lda     $32db,x
        sta     $dc
        lda     $ef9a
        beq     @b3b0
        lda     $32da,x
        and     #$04
        beq     @b3b5
        lda     $32da,x
        bra     @b3c1
@b3b0:  lda     $32da,x
        bpl     @b3c1
@b3b5:  jsr     HideMenuCursor2
        stz     $ef94
        jsr     ErrorSfx
        jmp     @b485
@b3c1:  stz     $0e
        jsr     SelectDefaultTarget
        lda     #$10
        ora     $ef9a
        sta     $d8
        lda     $63
        sta     $d9
        lda     #$0b
        sta     $ef91
        lda     #$0c
        sta     $1823
        stz     $ef94
        jsr     HideMenuCursorBoth
        jmp     @b485

; swap items
@b3e4:  lda     $ef95
        bpl     @b3f5
        jsr     HideMenuCursor2
        stz     $ef94
        jsr     ErrorSfx
        jmp     @b485
@b3f5:  lda     $ef96
        and     #$01
        tay
        lda     $ef95
        and     #$7f
        asl2
        tax
        lda     $321b,x
        sta     $2894,y
        lda     $ef96
        and     #$01
        eor     #$01
        tay
        jsr     GetEquipPtr
        lda     $32db,x
        sta     $2894,y
        jsr     ValidateEquip_near
        lda     $2893
        bne     @b454
        jsr     CheckInventoryToEquip
        bcc     @b454
        lda     $1822
        sta     $1819
        lda     $ef95
        and     #$7f
        sta     $181b
        lda     $ef96
        and     #$7f
        sta     $181a
        lda     #$09
        sta     $1821
        lda     #$09                    ; equipped items
        sta     $181e
        lda     #$07                    ; inventory
        sta     $181f
        jsr     HideMenuCursor2
        stz     $ef94
        bra     @b485
@b454:  jsr     HideMenuCursor2
        stz     $ef94
        jsr     ErrorSfx
        bra     @b485

; B button
@b45f:  lda     $38
        bpl     @b485
        jsr     CancelConfirmSfx
        lda     $ef94
        beq     @b473
        stz     $ef94
        jsr     HideMenuCursor2
        bra     @b485
@b473:  jsr     HideMenuCursor1
        jsr     HideListArrowBoth
        ldx     $61
        stx     $5f
        jsr     CloseEquipWindow
        lda     #$0d
        sta     $1823
@b485:  rts

; ------------------------------------------------------------------------------

; [ validate character equipment (near) ]

ValidateEquip_near:
@b486:  jsl     ValidateEquip
        rts

; ------------------------------------------------------------------------------

; [ get pointer to character equipment data ]

; A: 0 = right hand, 1 = left hand

GetEquipPtr:
@b48b:  and     #$7f
        asl2
        sta     $10
        lda     $1822                   ; selected character
        asl3
        clc
        adc     $10
        tax
        rts

; ------------------------------------------------------------------------------

; [ show or hide menu cursor 2 when the equipment menu is closed ]

CheckCursorEquipClose:
@b49c:  lda     $ef94
        beq     @b4b4
        lda     $ef95
        bmi     @b4b1
        cmp     #$0a
        bcs     @b4ad
        jmp     ShowMenuCursor2
@b4ad:  inc     $ef6a
        rts
@b4b1:  jmp     HideMenuCursor2
@b4b4:  rts

; ------------------------------------------------------------------------------

; [ show or hide menu cursor 2 when the equipment menu is open ]

CheckCursorEquipOpen:
@b4b5:  lda     $ef94
        beq     @b4cd
        lda     $ef95
        bmi     @b4c7                   ; branch if an equipped item is selected
        cmp     #$0a
        bcs     @b4ca
        cmp     #$06
        bcc     @b4ca
@b4c7:  jmp     ShowMenuCursor2
@b4ca:  inc     $ef6a                   ; hide cursor 2
@b4cd:  rts

; ------------------------------------------------------------------------------

; [ cursor update $05: inventory ]

UpdateCursor_05:
@b4ce:  jsr     CursorMoveSfx
        lda     $38
        and     #$0f

; up button
        cmp     #$08
        bne     @b511
@b4d9:  lda     $ef85                   ; branch if not at top
        bne     @b4f3
@b4de:  jsr     HideListArrowUp
        jsr     CheckCursorEquipOpen
        jsr     OpenEquipWindow
        lda     #$0b
        sta     $1823
        rts
@b4ed:  inc     $5f
        inc     $63
        bra     @b4de
@b4f3:  lda     $60
        bne     @b506
        jsr     ScrollListUp
        dec     $ef86
        dec     $ef85
        dec     $63
        dec     $63
        bra     @b579
@b506:  dec     $60
        dec     $63
        dec     $63
        dec     $ef85
        bra     @b579

; down button
@b511:  cmp     #$04
        bne     @b541
@b515:  lda     $ef85
        cmp     #$17
        bne     @b521
        stz     $f416
        bra     @b579
@b521:  lda     $60
        cmp     #$04
        bne     @b536
        jsr     ScrollListDown
        inc     $ef86
        inc     $ef85
        inc     $63
        inc     $63
        bra     @b579
@b536:  inc     $60
        inc     $63
        inc     $63
        inc     $ef85
        bra     @b579

; left button
@b541:  cmp     #$02
        bne     @b55a
        lda     $63
        beq     @b4ed
        lda     $5f
        bne     @b554
        inc     $5f
        inc     $63
        jmp     @b4d9
@b554:  dec     $5f
        dec     $63
        bra     @b579

; right button
@b55a:  cmp     #$01
        bne     @b579
        lda     $63
        cmp     #$2f
        bne     @b569
        stz     $f416
        bra     @b579
@b569:  lda     $5f
        cmp     #$01
        bne     @b575
        dec     $5f
        dec     $63
        bra     @b515
@b575:  inc     $5f
        inc     $63
@b579:  jsr     ShowListArrowBoth
        lda     $ef86
        cmp     #$13
        bne     @b586
        jsr     HideListArrowDown
@b586:  lda     $5f
        tax
        lda     f:InventoryCursorXTbl,x
        tax
        stx     $ef6b                   ; set menu cursor 1 x position
        lda     $60
        tax
        lda     f:ListCursorYTbl,x
        tax
        stx     $ef6d                   ; set menu cursor 1 y position
        jsr     ShowMenuCursor1

; A button
        lda     $37
        bmi     @b5a6
        jmp     @b6ca
@b5a6:  jsr     CancelConfirmSfx
        lda     $ef94
        bne     @b5d1

; select item
        inc     $ef94
        lda     $63
        sta     $ef95
        ldx     $ef6b
        inx4
        stx     $ef6f                   ; set menu cursor 2 x position
        ldx     $ef6d
        stx     $ef71                   ; set menu cursor 2 y position
        jsr     ShowMenuCursor2
        lda     $ef9a
        bne     @b5d1
        jmp     @b6f0

; select target
@b5d1:  lda     $63
        sta     $ef96
        jsr     HideMenuCursor2
        stz     $ef94
        lda     $ef95
        cmp     $ef96
        bne     @b646                   ; branch if not the same item
        lda     $63
        asl2
        tax
        lda     $321b,x
        sta     $dc
        lda     $ef9a
        beq     @b601                   ; branch if not using throw
        lda     $321a,x
        and     #$04
        beq     @b60d                   ; branch if item can't be thrown
        lda     $321a,x
        ora     #$40
        bra     @b616
@b601:  lda     $321b,x
        cmp     #$b0
        bcc     @b60d                   ; branch if item is equipment
        lda     $321a,x
        bpl     @b616                   ; branch if item is not disabled
@b60d:  jsr     ErrorSfx
        stz     $ef94
        jmp     @b6f0

; item can be used
@b616:  pha
        stz     $0e
        jsr     SelectDefaultTarget
        lda     #$40
        ora     $ef9a
        sta     $d8
        lda     $63
        sta     $d9
        jsr     HideMenuCursor1
        pla
        and     #$40
        beq     @b638                   ; branch if character target
        lda     #$05
        sta     $ef91
        lda     #$0c                    ; target select
        bra     @b63f
@b638:  lda     #$10
        sta     $ef91
        lda     #$0f
@b63f:  sta     $1823
        rts
        jmp     @b6f0                   ; *** never used ***

; swap items in inventory
@b646:  lda     $ef95
        bpl     @b6b2
        lda     $ef95
        and     #$01
        tay
        lda     $ef96
        and     #$7f
        asl2
        tax
        lda     $321b,x
        sta     $2894,y
        lda     $ef95
        and     #$01
        eor     #$01
        tay
        jsr     GetEquipPtr
        lda     $32db,x
        sta     $2894,y
        jsr     ValidateEquip_near
        lda     $2893
        bne     @b6aa
        jsr     CheckEquipToInventory
        bcc     @b6aa
        lda     $1822
        sta     $1819
        lda     $ef96
        and     #$7f
        sta     $181b
        lda     $ef95
        and     #$7f
        sta     $181a
        lda     #$09
        sta     $1821
        lda     #$09                    ; equipped items
        sta     $181e
        lda     #$07                    ; inventory
        sta     $181f
        stz     $ef94
        jsr     HideMenuCursor2
        bra     @b6f0
@b6aa:  stz     $ef94
        jsr     ErrorSfx
        bra     @b6f0
@b6b2:  lda     $ef95
        sta     $181a
        lda     $ef96
        sta     $181b
        lda     #$08
        sta     $1821
        lda     #$07                    ; inventory
        sta     $181e
        bra     @b6f0

; B button
@b6ca:  lda     $38
        bpl     @b6f0
        jsr     CancelConfirmSfx
        lda     $ef94
        beq     @b6de
        stz     $ef94
        jsr     HideMenuCursor2
        bra     @b6f0
@b6de:  jsr     HideMenuCursor1
        jsr     HideListArrowBoth
        ldx     $61
        stx     $5f
        jsr     CloseInventoryWindow
        lda     #$01
        sta     $1823
@b6f0:  rts

; ------------------------------------------------------------------------------

; [ cursor update $06: spell select ]

UpdateCursor_06:
@b6f1:  jsr     CursorMoveSfx
        lda     $38
        and     #$0f

; up button
        cmp     #$08
        bne     @b724
@b6fc:  lda     $ef85
        beq     @b746
        lda     $60
        bne     @b716
        jsr     ScrollListUp
        dec     $ef86
        dec     $ef85
        dec     $63
        dec     $63
        dec     $63
        bra     @b744
@b716:  dec     $60
        dec     $63
        dec     $63
        dec     $63
        dec     $ef85
        jmp     @b793

; down button
@b724:  cmp     #$04
        bne     @b758
@b728:  lda     $ef85
        cmp     #$07
        beq     @b746
        lda     $60
        cmp     #$04
        bne     @b74b
        jsr     ScrollListDown
        inc     $ef86
        inc     $ef85
        inc     $63
        inc     $63
        inc     $63
@b744:  bra     @b793
@b746:  stz     $f416
        bra     @b793
@b74b:  inc     $60
        inc     $63
        inc     $63
        inc     $63
        inc     $ef85
        bra     @b793

; left button
@b758:  cmp     #$02
        bne     @b775
        lda     $63
        beq     @b746
        lda     $5f
        bne     @b76f
        inc     $5f
        inc     $5f
        inc     $63
        inc     $63
        jmp     @b6fc
@b76f:  dec     $5f
        dec     $63
        bra     @b793

; right button
@b775:  cmp     #$01
        bne     @b793
        lda     $63
        cmp     #$17
        beq     @b746
        lda     $5f
        cmp     #$02
        bne     @b78f
        dec     $5f
        dec     $5f
        dec     $63
        dec     $63
        bra     @b728
@b78f:  inc     $5f
        inc     $63

@b793:  jsr     ShowListArrowBoth
        lda     $ef86
        bne     @b79e
        jsr     HideListArrowUp
@b79e:  lda     $ef86
        cmp     #$03
        bne     @b7a8
        jsr     HideListArrowDown
@b7a8:  jsr     UpdateMPCost
        lda     $5f
        tax
        lda     f:MagicListCursorXTbl,x
        tax
        stx     $ef6b       ; set menu cursor 1 x position
        lda     $60
        tax
        lda     f:ListCursorYTbl,x
        tax
        stx     $ef6d
        jsr     ShowMenuCursor1

; A button
        lda     $37
        bpl     @b810
        jsr     CancelConfirmSfx
        jsr     GetMagicListPtr
        lda     $2c7a,x
        bpl     @b7d8                   ; branch if spell enabled
        jsr     ErrorSfx
        bra     @b810
@b7d8:  jsr     HideMenuCursor1
        lda     $2c7b,x                 ; spell id
        sta     $dc
        lda     $2c7a,x
        pha
        stz     $0e
        jsr     SelectDefaultTarget
        lda     #$20
        sta     $d8
        lda     $ef93
        lsr2
        clc
        adc     $63
        sta     $d9
        pla
        and     #$40
        beq     @b805                   ; branch if character target
        lda     #$06
        sta     $ef91
        lda     #$0c
        bra     @b80c
@b805:  lda     #$0e
        sta     $ef91
        lda     #$0f
@b80c:  sta     $1823
        rts

; B button
@b810:  lda     $38
        bpl     @b82c
        jsr     CancelConfirmSfx
        jsr     HideMenuCursor1
        jsr     HideListArrowBoth
        ldx     $61
        stx     $5f
        stz     $1838
        jsr     CloseMPWindow
        lda     #$0a
        sta     $1823
@b82c:  rts

; ------------------------------------------------------------------------------

; spell list offsets
MagicListOffsets:
@b82d:  .word   $0000,$0120,$0240,$0360,$0480

; ------------------------------------------------------------------------------

; [ get pointer to character spell list ]

GetMagicListPtr:
@b837:  lda     $1822                   ; selected character
        asl
        tax
        lda     f:MagicListOffsets,x
        sta     $0e
        lda     f:MagicListOffsets+1,x
        sta     $0f
        lda     $0e
        clc
        adc     $ef93                   ; add offset for spell type
        sta     $0e
        lda     $0f
        adc     #0
        sta     $0f
        lda     $63
        asl2
        clc
        adc     $0e
        sta     $0e
        lda     $0f
        adc     #0
        sta     $0f
        ldx     $0e
        rts

; ------------------------------------------------------------------------------

; [ update mp cost in menu ]

UpdateMPCost:
@b868:  jsr     GetMagicListPtr
        lda     $2c7d,x     ; mp cost
        tax
        stx     $1c
        ldx     #100      ; 100s digit
        stx     $1e
        jsr     DivHW
        lda     $20
        clc
        adc     #$ed
        sta     $1839
        ldx     $22
        stx     $1c
        ldx     #10      ; 10s digit
        stx     $1e
        jsr     DivHW
        lda     $20
        clc
        adc     #$ed
        sta     $183b
        lda     $22
        clc
        adc     #$ed
        sta     $183d      ; 1s digit
        inc     $1838      ; enable transfer to vram
        rts

; ------------------------------------------------------------------------------

; [ cursor update $00: no cursor ]

UpdateCursor_00:
@b8a1:  rts

; ------------------------------------------------------------------------------

; [ clear targets ]

; used if row or defend command is used

ClearTargets:
@b8a2:  ldx     #0
        stx     $ef8f
        stx     $da
        stz     $ef8b
        rts

; ------------------------------------------------------------------------------

; [ cursor update $03: change row ]

UpdateCursor_03:
@b8ae:  lda     $37
        bpl     @b8c3

; A button
        lda     #$1a
        sta     $f2b1
        jsr     ClearTargets
        lda     #$08
        sta     $1823
        jsr     CancelConfirmSfx
        rts

; B button
@b8c3:  lda     $38
        bpl     @b8d8
        jsr     CursorMoveSfx2
        bra     @b8cf

; shoulder R button
@b8cc:  jsr     CancelConfirmSfx
@b8cf:  jsr     CloseRowWindow
        lda     #$01
        sta     $1823
        rts
@b8d8:  and     #$01
        bne     @b8cc
        rts

; ------------------------------------------------------------------------------

; [ cursor update $02: defend ]

UpdateCursor_02:
@b8dd:  lda     $37
        bpl     @b8f2

; A button
        lda     #$1b
        sta     $f2b1
        jsr     ClearTargets
        lda     #$08
        sta     $1823
        jsr     CancelConfirmSfx
        rts

; B button
@b8f2:  lda     $38
        bpl     @b907
        jsr     CancelConfirmSfx
        bra     @b8fe

; shoulder L button
@b8fb:  jsr     CursorMoveSfx2
@b8fe:  jsr     CloseDefendWindow
        lda     #$01
        sta     $1823
        rts
@b907:  and     #$02
        bne     @b8fb
        rts

; ------------------------------------------------------------------------------

; [ play cursor sound effect ]

CursorMoveSfx:
@b90c:  lda     $38
        and     #$0f
        bne     CursorMoveSfx2
        rts

CursorMoveSfx2:
@b913:  lda     #$14        ; system sound effect $14
        sta     $f416
        rts

; ------------------------------------------------------------------------------

; [ play error sound effect ]

ErrorSfx:
@b919:  lda     #$12        ; system sound effect $12
        sta     $f416
        rts

; ------------------------------------------------------------------------------

; [ play cancel/confirm sound effect ]

CancelConfirmSfx:
@b91f:  lda     #$13        ; system sound effect $13
        sta     $f416
        rts

; ------------------------------------------------------------------------------

; [ cursor update $01: command list ]

UpdateCursor_01:
@b925:  jsr     CursorMoveSfx
        lda     $38
        and     #$0f

; up button
        cmp     #$08
        bne     @b944
@b930:  lda     $60
        bne     @b938
        lda     #$05
        sta     $60
@b938:  dec     $60
        jsr     GetCmdPtr
        lda     $3302,x
        bmi     @b930
        bra     @b988

; down button
@b944:  cmp     #$04
        bne     @b956
@b948:  lda     $60
        cmp     #$04
        bne     @b952
        stz     $60
        bra     @b954
@b952:  inc     $60
@b954:  bra     @b988

; left button
@b956:  cmp     #$02
        bne     @b96f
        lda     #$80
        sta     $d8
        lda     #$05
        sta     $d9
        jsr     OpenRowWindow
        lda     #$03
        sta     $1823
        lda     #$0c
        jmp     UpdateCmdCursor

; right button
@b96f:  cmp     #$01
        bne     @b988
        lda     #$80
        sta     $d8
        lda     #$06
        sta     $d9
        jsr     OpenDefendWindow
        lda     #$02
        sta     $1823
        lda     #$4c
        jmp     UpdateCmdCursor

; command list
@b988:  jsr     GetCmdPtr
        lda     $3302,x
        bmi     @b948
        lda     #$28
        jsr     UpdateCmdCursor

; A button
        lda     $37
        bpl     @b9df
        ldx     $5f
        stx     $61
        jsr     HideMenuCursor1
        jsr     GetCmdPtr
        jsr     CancelConfirmSfx
        lda     $3303,x
        sta     $dc
        sta     $f2b1
        lda     $3302,x     ; command targeting flags
        phx
        pha
        lda     #$01
        sta     $0e
        pla
        jsr     SelectDefaultTarget
        plx
        lda     $3303,x     ; command id
        cmp     #$16        ; throw
        beq     @b9e0
        cmp     #$18        ; ninjutsu
        beq     BlackMenuCmd
        cmp     #$05
        bcc     @b9ce
        jmp     OtherMenuCmd
@b9ce:  asl
        tax
        lda     f:MenuCmdTbl,x
        sta     $0e
        lda     f:MenuCmdTbl+1,x
        sta     $0f
        jmp     ($000e)
@b9df:  rts

; throw (dart)
@b9e0:  lda     #$08
        sta     $ef9a
        jmp     ThrowMenuCmd

; ------------------------------------------------------------------------------

; jump table for selected battle commands
MenuCmdTbl:
@b9e8:  .addr   FightMenuCmd
        .addr   ItemMenuCmd
        .addr   WhiteMenuCmd
        .addr   BlackMenuCmd
        .addr   SummonMenuCmd
        .addr   OtherMenuCmd

; ------------------------------------------------------------------------------

; [ menu command 0: fight ]

FightMenuCmd:
@b9f4:  lda     #$80
        sta     $d8
        lda     $60
        sta     $d9
        lda     #$01
        sta     $ef91
        lda     #$04
        sta     $1823
        rts

; ------------------------------------------------------------------------------

; [ menu command 1: item ]

ItemMenuCmd:
@ba07:  stz     $ef9a

; throw
ThrowMenuCmd:
@ba0a:  lda     #$05
        sta     $1823
        stz     $ef94
        stz     $ef97
        stz     $ef98
        stz     $ef99
        jmp     OpenInventoryWindow

; ------------------------------------------------------------------------------

; [ menu command 2: white magic ]

WhiteMenuCmd:
@ba1e:  lda     #$00
        sta     $ef93
        lda     #$09
        sta     $1823
        jmp     OpenWhiteMagicWindow

; ------------------------------------------------------------------------------

; [ menu command 3: black magic/ninja ]

BlackMenuCmd:
@ba2b:  lda     #$60
        sta     $ef93
        lda     #$09
        sta     $1823
        jmp     OpenBlackMagicWindow

; ------------------------------------------------------------------------------

; [ menu command 4: summon ]

SummonMenuCmd:
@ba38:  lda     #$c0
        sta     $ef93
        lda     #$09
        sta     $1823
        jmp     OpenSummonMagicWindow

; ------------------------------------------------------------------------------

; [ all other menu commands ]

OtherMenuCmd:
@ba45:  lda     #$80
        sta     $d8
        lda     $60
        sta     $d9
        lda     #$01
        sta     $ef91
        lda     #$07
        sta     $1823
        rts

; ------------------------------------------------------------------------------

; [ update command list cursor ]

; A: cursor x position

UpdateCmdCursor:
@ba58:  sta     $ef6b                   ; set menu cursor 1 x position
        lda     $60
        tax
        lda     f:CmdCursorYTbl,x
        tax
        stx     $ef6d                   ; set menu cursor 1 y position
        jmp     ShowMenuCursor1

; ------------------------------------------------------------------------------

; [ open/close row/defend window ]

OpenDefendWindow:
@ba69:  lda     $60
        jmp     _ba86

CloseDefendWindow:
@ba6e:  lda     $60
        clc
        adc     #$05
        jmp     _ba86

OpenRowWindow:
@ba76:  lda     $60
        clc
        adc     #$0a
        jmp     _ba86

CloseRowWindow:
@ba7e:  lda     $60
        clc
        adc     #$0f
        jmp     _ba86

_ba86:  asl
        tax
        lda     f:DefendRowWindowTbl,x
        sta     $0e
        lda     f:DefendRowWindowTbl+1,x
        sta     $0f
        jmp     ($000e)

; ------------------------------------------------------------------------------

DefendRowWindowTbl:
@ba97:  .addr   OpenDefendWindow1
        .addr   OpenDefendWindow2
        .addr   OpenDefendWindow3
        .addr   OpenDefendWindow4
        .addr   OpenDefendWindow5
        .addr   CloseDefendWindow1
        .addr   CloseDefendWindow2
        .addr   CloseDefendWindow3
        .addr   CloseDefendWindow4
        .addr   CloseDefendWindow5
        .addr   OpenRowWindow1
        .addr   OpenRowWindow2
        .addr   OpenRowWindow3
        .addr   OpenRowWindow4
        .addr   OpenRowWindow5
        .addr   CloseRowWindow1
        .addr   CloseRowWindow2
        .addr   CloseRowWindow3
        .addr   CloseRowWindow4
        .addr   CloseRowWindow5

; ------------------------------------------------------------------------------

; [ get pointer to character battle command data ]

GetCmdPtr:
@babf:  lda     $1822
        tax
        lda     f:CharCmdPtrs,x
        sta     $0e
        lda     $60
        asl2
        clc
        adc     $0e
        tax
        rts

; ------------------------------------------------------------------------------

; [ draw menu list arrows ]

DrawListArrows:
@bad2:  ldx     #0
@bad5:  lda     f:ListArrowTbl,x
        sta     $0318,x                 ; sprites 6-9
        inx
        cpx     #$0010
        bne     @bad5
        lda     $ef83                   ; up arrow
        beq     @baee
        lda     $0501
        ora     #$50                    ; set msb to hide sprites
        bra     @baf3
@baee:  lda     $0501
        and     #$0f
@baf3:  sta     $0501
        lda     $ef84                   ; down arrow
        beq     @bb02
        lda     $0502
        ora     #$05
        bra     @bb07
@bb02:  lda     $0502
        and     #$f0
@bb07:  sta     $0502
        rts

; ------------------------------------------------------------------------------

; [ flip x-position for back attack ]

BackAttackFlipX:
@bb0b:  pha
        lda     $6cc0
        beq     @bb18
        pla
        eor     #$ff
        sec
        sbc     #$08
        rts
@bb18:  pla
        rts

; ------------------------------------------------------------------------------

; [ flip cursor x position for back attack ]

FlipTargetCursorX:
@bb1a:  pha
        lda     $6cc0
        beq     @bb27
        pla
        eor     #$ff
        sec
        sbc     #$10
        rts
@bb27:  pla
        rts

; ------------------------------------------------------------------------------

; [ draw target cursor sprites ]

DrawTargetCursors:
@bb29:  lda     $6cc0
        beq     @bb35       ; branch if not a back attack
        ldx     #$714a      ; tile id and flags (h-flip)
        stx     $0e
        bra     @bb3a
@bb35:  ldx     #$314a      ; tile id and flags
        stx     $0e
@bb3a:  lda     $ef7a       ; cursor 1
        jsr     FlipTargetCursorX
        sta     $0308
        lda     $ef7b
        sta     $0309
        ldx     $0e
        stx     $030a
        lda     $ef7c       ; cursor 2
        jsr     FlipTargetCursorX
        sta     $030c
        lda     $ef7d
        sta     $030d
        ldx     $0e
        stx     $030e
        lda     $ef7e       ; cursor 3
        jsr     FlipTargetCursorX
        sta     $0310
        lda     $ef7f
        sta     $0311
        ldx     $0e
        stx     $0312
        lda     $ef80       ; cursor 4
        jsr     FlipTargetCursorX
        sta     $0314
        lda     RestoreAttackProp
        sta     $0315
        ldx     $0e
        stx     $0316
        lda     $ef76       ; set x position msb and large sprite flag
        beq     @bb96
        lda     $0500
        ora     #$10
        bra     @bb9d
@bb96:  lda     $0500
        and     #$cf
        ora     #$20
@bb9d:  sta     $0500
        lda     $ef77
        beq     @bbac
        lda     $0500
        ora     #$40
        bra     @bbb3
@bbac:  lda     $0500
        and     #$3f
        ora     #$80
@bbb3:  sta     $0500
        lda     $ef78
        beq     @bbc2
        lda     $0501
        ora     #$01
        bra     @bbc9
@bbc2:  lda     $0501
        and     #$fc
        ora     #$02
@bbc9:  sta     $0501
        lda     $ef79
        beq     @bbd8
        lda     $0501
        ora     #$04
        bra     @bbdf
@bbd8:  lda     $0501
        and     #$f3
        ora     #$08
@bbdf:  sta     $0501
        rts

; ------------------------------------------------------------------------------

; [ draw menu cursor sprite ]

DrawMenuCursors:
@bbe3:  lda     $ef6b       ; menu cursor 1 (sprite 0)
        sta     $0300
        lda     $ef6d
        sta     $0301
        lda     $ef6f       ; menu cursor 2 (sprite 1)
        sta     $0304
        lda     $ef71
        sta     $0305
        ldx     #$314a      ; tile id and flags
        stx     $0302
        stx     $0306
        lda     $ef69       ; set x position msb to hide cursor
        ora     $ef6e
        beq     @bc13
        lda     $0500
        ora     #$03
        bra     @bc1a
@bc13:  lda     $0500
        and     #$fc
        ora     #$02
@bc1a:  sta     $0500
        lda     $ef6a
        ora     $ef72
        beq     @bc2f
        lda     $0500
        ora     #$0c
        sta     $0500
        bra     @bc36
@bc2f:  lda     $0500
        and     #$f3
        ora     #$08
@bc36:  sta     $0500
        rts

; ------------------------------------------------------------------------------

; [ show menu list up arrow ]

; unused

ShowListArrowUp:
@bc3a:  stz     $ef83
        rts

; ------------------------------------------------------------------------------

; [ show menu list down arrow ]

; unused

ShowListArrowDown:
@bc3e:  stz     $ef84
        rts

; ------------------------------------------------------------------------------

; [ hide menu list up arrow ]

HideListArrowUp:
@bc42:  lda     #1
        sta     $ef83
        rts

; ------------------------------------------------------------------------------

; [ hide menu list down arrow ]

HideListArrowDown:
@bc48:  lda     #1
        sta     $ef84
        rts

; ------------------------------------------------------------------------------

; [ hide both menu list arrows ]

HideListArrowBoth:
@bc4e:  lda     #1
        sta     $ef83
        sta     $ef84
        rts

; ------------------------------------------------------------------------------

; [ show both menu list arrows ]

ShowListArrowBoth:
@bc57:  stz     $ef83
        stz     $ef84
        rts

; ------------------------------------------------------------------------------

; [ hide menu cursor 1 ]

HideMenuCursor1:
@bc5e:  lda     #1
        sta     $ef69
        rts

; ------------------------------------------------------------------------------

; [ show menu cursor 1 ]

ShowMenuCursor1:
@bc64:  stz     $ef69
        rts

; ------------------------------------------------------------------------------

; [ show menu cursor 2 ]

ShowMenuCursor2:
@bc68:  stz     $ef6a
        stz     $ef73
        rts

; ------------------------------------------------------------------------------

; [ hide menu cursor 2 ]

HideMenuCursor2:
@bc6f:  lda     #1
        sta     $ef6a
        sta     $ef73
        rts

; ------------------------------------------------------------------------------

; [ show both menu cursors ]

; unused

ShowMenuCursorBoth:
@bc78:  stz     $ef69
        stz     $ef6a
        stz     $ef73
        rts

; ------------------------------------------------------------------------------

; [ hide both menu cursors ]

HideMenuCursorBoth:
@bc82:  lda     #1
        sta     $ef69
        sta     $ef6a
        sta     $ef73
        rts

; ------------------------------------------------------------------------------

; [ hide all target cursors ]

HideAllTargetCursors:
@bc8e:  lda     #1
        sta     $ef76
        sta     $ef77
        sta     $ef78
        sta     $ef79
        rts

; ------------------------------------------------------------------------------
