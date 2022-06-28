
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: special_anim.asm                                                     |
; |                                                                            |
; | description: routines for special battle animations                        |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

; [ wait one frame ]

WaitFrame_near:
@ee09:  jsl     WaitFrame_far
        rts

; ------------------------------------------------------------------------------

; [ do special animation (far) ]

DoSpecialAnim_far:
@ee0e:  jsr     DoSpecialAnim
        rtl

; ------------------------------------------------------------------------------

; [ do special animation ]

DoSpecialAnim:
@ee12:  sec
        sbc     #$a9
        asl
        tax
        lda     f:SpecialAnimTbl,x
        sta     $00
        lda     f:SpecialAnimTbl+1,x
        sta     $01
        jmp     ($0000)

; ------------------------------------------------------------------------------

; special animation jump table (starts at $a9)
SpecialAnimTbl:
@ee26:  .addr   UnusedSpecialAnim
        .addr   UnusedSpecialAnim
        .addr   SpecialAnim_ab
        .addr   SpecialAnim_ac
        .addr   SpecialAnim_ad
        .addr   UnusedSpecialAnim
        .addr   SpecialAnim_af
        .addr   SpecialAnim_b0
        .addr   SpecialAnim_b1
        .addr   SpecialAnim_b2
        .addr   SpecialAnim_b3
        .addr   SpecialAnim_b4
        .addr   SpecialAnim_b5
        .addr   SpecialAnim_b6
        .addr   SpecialAnim_b7
        .addr   SpecialAnim_b8
        .addr   UnusedSpecialAnim
        .addr   UnusedSpecialAnim
        .addr   SpecialAnim_bb
        .addr   UnusedSpecialAnim
        .addr   UnusedSpecialAnim
        .addr   UnusedSpecialAnim
        .addr   SpecialAnim_bf

; ------------------------------------------------------------------------------

; [ special animation $bf:  ]

SpecialAnim_bf:
@ee54:  jsl     _03f845
        rts

; ------------------------------------------------------------------------------

; [ special animation $af: demon wall moves forward ]

SpecialAnim_af:
@ee59:  lda     $f411
        beq     @ee6b
        dec     $f411
        jsl     _02bedd
        lda     #$31
        jsl     PlaySfx_far
@ee6b:  rts

; ------------------------------------------------------------------------------

; [ special animation $bb: zeromus shakes ]

SpecialAnim_bb:
@ee6c:  lda     #$54
        jsl     PlaySfx_far
        ldx     #$0040
@ee75:  phx
        jsr     WaitFrame_near
        jsl     UpdateShakeMonstersOnly
        plx
        dex
        bne     @ee75
        jsl     DisableShakeBG_far
        clr_a
        jsl     PlaySfx_far
        rts

; ------------------------------------------------------------------------------

; [  ]

_01ee8b:
@ee8b:  lda     #$20
        bra     _ee95

_01ee8f:
@ee8f:  lda     #$80
        bra     _ee95

_01ee93:
@ee93:  lda     #$e0
_ee95:  sta     $ef88
        stz     $f433
        stz     $f435
        stz     $f434
        lda     #$02
        sta     $ef87
        stz     $ef89
        stz     $ef8a
        rts

; ------------------------------------------------------------------------------

; [ flash screen ]

FlashScreenMagenta:
@eead:  lda     #$a0        ; blue + red
        bra     _eec7

FlashScreenCyan:
@eeb1:  lda     #$c0        ; blue + green
        bra     _eec7

FlashScreenYellow:
@eeb5:  lda     #$60        ; red + green
        bra     _eec7

FlashScreenRed:
@eeb9:  lda     #$20        ; red
        bra     _eec7

FlashScreenGreen:
@eebd:  lda     #$40        ; green
        bra     _eec7

FlashScreenBlue:
@eec1:  lda     #$80        ; blue
        bra     _eec7

FlashScreenWhite:
@eec5:  lda     #$e0        ; white
_eec7:  sta     $ef88       ; set flash color components
        lda     #$1f
        sta     $f433
        sta     $f435
        sta     $f434
        lda     #$01
        sta     $ef87
        stz     $ef89
        stz     $ef8a
        rtl

; ------------------------------------------------------------------------------

; [ special animation $ad: change to next boss form ]

SpecialAnim_ad:
@eee1:  jsr     SpecialAnim_ab
        jsl     UpdateBG1Tiles_far
        jsl     ModifyBG1Tiles
        lda     #$59
        jsl     PlaySfx_far
        lda     #$02
        jsl     BossTransition_far
        rts

; ------------------------------------------------------------------------------

; [ special animation $ab/$ac:  ]

SpecialAnim_ab:
SpecialAnim_ac:
@eef9:  clr_ax
        dec
@eefc:  sta     $f2b4,x
        inx
        cpx     #$0008
        bne     @eefc
        rts

; ------------------------------------------------------------------------------

; [ unused special animation ]

UnusedSpecialAnim:
@ef06:  rts

; ------------------------------------------------------------------------------

; [ find adult rydia ]

FindRydia:
@ef07:  clr_ay
@ef09:  tya
        tax
        jsl     GetObjPtr_far
        lda     $2001,x
        and     #$0f
        cmp     #$0b
        beq     @ef20       ; branch if adult rydia
        iny
        cpy     #5
        bne     @ef09
        clr_ay
@ef20:  rts

; ------------------------------------------------------------------------------

; [ special animation $b1:  ]

SpecialAnim_b1:
@ef21:  jsr     LoadMistVsGolbezProp
        lda     a:$0048
        pha
        lda     $f475
        sta     a:$0048
        jsl     HideAnim_far
        jsr     FindRydia
        clr_a
        sta     $f2c1,y
        lda     $2000,x
        pha
        tya
        asl4
        tax
        pla
        sta     $efc4,x
        jsl     AppearAnim_far
        pla
        sta     a:$0048
        jsr     RestoreAttackProp
        rts

; ------------------------------------------------------------------------------

; [ special animation $b0: mist dragon vs. golbez ]

SpecialAnim_b0:
@ef53:  jsr     FindRydia
        clr_a
        sta     $2003,x     ; clear status
        sta     $2004,x
        sta     $2005,x
        sta     $2006,x
        tya
        sta     $f475
        inc     $f474       ; enable mist dragon vs. golbez
        rts

; ------------------------------------------------------------------------------

; [ load mist dragon vs. golbez attack properties ]

LoadMistVsGolbezProp:
@ef6b:  clr_ax
@ef6d:  lda     $34c2,x     ; save attack properties
        sta     $f476,x
        lda     f:MistVsGolbezProp,x
        sta     $34c2,x
        inx
        cpx     #8
        bne     @ef6d
        rts

; ------------------------------------------------------------------------------

; [ restore attack properties ]

RestoreAttackProp:
@ef81:  clr_ax
@ef83:  lda     $f476,x
        sta     $34c2,x
        inx
        cpx     #8
        bne     @ef83
        rts

; ------------------------------------------------------------------------------

; [ show mist dragon vs. golbez ]

ShowMistVsGolbez:
@ef90:  lda     #$c4        ; summon
        sta     $33c2
        lda     #$56        ; mist dragon
        sta     $33c3
        lda     #$ff        ; script terminator
        sta     $33c4
        jsr     LoadMistVsGolbezProp
        inc     $f474       ; this is unnecessary, it's already nonzero
        lda     $f475       ; adult rydia
        sta     $34c3       ; set attacker id
        jsl     ExecGfxScript_far
        jsr     RestoreAttackProp
        rtl

; ------------------------------------------------------------------------------

; attack properties for mist dragon vs. golbez and shadow -> $34c2-$34c9
;   (target monsters 0 and 1)
MistVsGolbezProp:
@efb3:  .byte   $00,$00,$80,$c0,$00,$00,$00,$00

; ------------------------------------------------------------------------------

; [ special animation $b8:  ]

SpecialAnim_b8:
@efbb:  stz     $f44c
        stz     $f41a
        jmp     _01efcb

; ------------------------------------------------------------------------------

; [ show ghost character ??? ]

_01efc4:
@efc4:  jsr     _01efcb
        inc     $f41a
        rts

; ------------------------------------------------------------------------------

; [  ]

_01efcb:
@efcb:  jsl     UpdateBG1Tiles_far
        jsl     ModifyBG1Tiles
        stz     $38e6
        jsl     _02cc3c
        rts

; ------------------------------------------------------------------------------

; [ special animation $b2:  ]

SpecialAnim_b2:
@efdb:  inc     $f473
        jmp     SpecialAnim_b8

; ------------------------------------------------------------------------------

; [ special animation $b3: summon anna (edward in kaipo cutscene) ]

SpecialAnim_b3:
@efe1:  jsr     @efe4
@efe4:  inc     $f44c
        lda     $f41a
        bne     @eff1
        lda     #$05
        jsr     LoadGhostCharGfx
@eff1:  jmp     _01efc4

; ------------------------------------------------------------------------------

; [ special animation $b4: summon edward and tellah ]

SpecialAnim_b4:
@eff4:  inc     $f44c
        lda     #$01
        jsr     LoadGhostCharGfx
        inc     $f41a
        jmp     _01efc4

; ------------------------------------------------------------------------------

; [ special animation $b5: summon palom and porom ]

SpecialAnim_b5:
@f002:  inc     $f44c
        lda     #$02
        jsr     LoadGhostCharGfx
        inc     $f41a
        jmp     _01efc4

; ------------------------------------------------------------------------------

; [ special animation $b6: summon yang and cid ]

SpecialAnim_b6:
@f010:  inc     $f44c
        lda     #$03
        jsr     LoadGhostCharGfx
        inc     $f41a
        jmp     _01efc4

; ------------------------------------------------------------------------------

; [ special animation $b7: summon fusoya and golbez ]

SpecialAnim_b7:
@f01e:  inc     $38f7
        inc     $f44c
        lda     #$04
        jsr     LoadGhostCharGfx
        inc     $f41a
        jmp     _01efc4

; ------------------------------------------------------------------------------

; [ draw ghost characters ]

DrawGhostChars:
@f02f:  lda     $f44c
        beq     @f057
        lda     $f41a
        beq     @f048

; show 2nd ghost character
        lda     $f422                   ; 2nd ghost character xy position
        jsr     GetGhostCharTilePtr
        lda     #$76
        sta     $02
        lda     #$88
        jsr     SetGhostCharTiles

; show 1st ghost character
@f048:  lda     $f421                   ; 1st ghost character xy position
        jsr     GetGhostCharTilePtr
        lda     #$72
        sta     $02
        lda     #$80
        jsr     SetGhostCharTiles
@f057:  rtl

; ------------------------------------------------------------------------------

; [ get pointer to ghost character tilemap ]

GetGhostCharTilePtr:
@f058:  pha
        and     #$0f
        sta     $26
        lda     #$40
        sta     $28
        jsl     Mult8_far
        pla
        lsr4
        clc
        adc     #$06
        longa
        asl
        clc
        adc     $2a
        clc
        adc     #$6cfd
        tax
        shorta0
        rts

; ------------------------------------------------------------------------------

; [ set ghost character tilemap ]

SetGhostCharTiles:
@f07c:  stx     $00
        ldy     #$0000
        jsr     SetGhostCharTileRow
        ldy     #$0040
        jsr     SetGhostCharTileRow
        ldy     #$0080
        jmp     SetGhostCharTileRow

; ------------------------------------------------------------------------------

; [ set one row of ghost character tiles (2 tiles) ]

SetGhostCharTileRow:
@f090:  pha
        inc
        sta     ($00),y
        iny
        lda     $02
        sta     ($00),y
        iny
        pla
        pha
        sta     ($00),y
        iny
        lda     $02
        sta     ($00),y
        pla
        inc2
        rts

; ------------------------------------------------------------------------------

; [ load ghost character graphics (from final battle) ]

; A: ghost characters id
;      0: anna
;      1: edward and tellah
;      2: palom and porom
;      3: yang and cid
;      4: fusoya and golbez
;      5: anna (edward in kaipo)

LoadGhostCharGfx:
@f0a7:  asl3
        tax
        clr_ay
@f0ad:  lda     f:GhostCharTbl,x
        sta     $f41b,y
        inx
        iny
        cpy     #8
        bne     @f0ad
        ldx     #$0100
        stx     $00
        ldx     $f41b
        ldy     #$4800
        lda     #^BattleCharGfx
        jsl     ExecTfr_far
        ldx     #$0100
        stx     $00
        ldx     $f41d
        ldy     #$4880
        lda     #$1a
        jsl     ExecTfr_far
        lda     $f41f
        ldx     #$0004
        jsl     LoadCharPal_far
        lda     $f420
        ldx     #$0005
        jsl     LoadCharPal_far
        rts

; ------------------------------------------------------------------------------
