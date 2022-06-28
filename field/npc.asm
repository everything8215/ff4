
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: npc.asm                                                              |
; |                                                                            |
; | description: npc routines                                                  |
; |                                                                            |
; | created: 3/26/2022                                                         |
; +----------------------------------------------------------------------------+

.pushseg

.segment "npc_data"

; 13/8000
NPCPropPtrs:
        make_ptr_tbl_rel NPCProp, $0180

; 13/8300
        .include .sprintf("data/npc_prop_%s.asm", LANG_SUFFIX)

; 13/9700
.if LANG_EN
.align $0100
        .include "data/dte_table.asm"
.endif

; 13/9800
.align $0100
NPCScriptPtrs:
        make_ptr_tbl_rel NPCScript, $0200

; 13/9c00
        .include .sprintf("data/npc_script_%s.asm", LANG_SUFFIX)

.popseg

; ------------------------------------------------------------------------------

; [ check npcs ]

CheckNPCs:
@ba0a:  lda     $1705       ; facing direction
        sta     $08
        asl
        tay
        bne     @ba21
        lda     $06a4,y
        and     #$20
        beq     @ba21
        lda     #$04
        sta     $08
        jmp     @ba2d
@ba21:  lda     $06a3,y
        and     #$03
        beq     @ba2d
        and     $d2
        bne     @ba2d
        rts
@ba2d:  lda     $08
        tay
        lda     $1706
        clc
        adc     _00bb31,y
        sta     $0c
        lda     $1707
        clc
        adc     _00bb36,y
        sta     $0e
        jsr     CheckNPCMap2
        cmp     #$00
        beq     @ba53
        cmp     #$ff
        beq     @ba53
        jsr     GetNPCPtr
        jmp     @bae3
@ba53:  lda     $08
        tay
        lda     $1706
        clc
        adc     _00bb3b,y
        sta     $0c
        lda     $1707
        clc
        adc     _00bb40,y
        sta     $0e
        jsr     CheckNPCMap2
        cmp     #$00
        beq     @ba82
        cmp     #$ff
        beq     @ba82
        jsr     GetNPCPtr
        cmp     #$ff
        beq     @ba82
        cmp     _00bb59,y
        bne     @ba82
        jmp     @bae3
@ba82:  lda     $08
        tay
        lda     $1706
        clc
        adc     _00bb45,y
        sta     $0c
        lda     $1707
        clc
        adc     _00bb4a,y
        sta     $0e
        jsr     CheckNPCMap2
        cmp     #$00
        beq     @bab1
        cmp     #$ff
        beq     @bab1
        jsr     GetNPCPtr
        cmp     #$ff
        beq     @bab1
        cmp     _00bb5e,y
        bne     @bab1
        jmp     @bae3
@bab1:  lda     $08
        tay
        lda     $1706
        clc
        adc     _00bb4f,y
        sta     $0c
        lda     $1707
        clc
        adc     _00bb54,y
        sta     $0e
        jsr     CheckNPCMap2
        cmp     #$00
        beq     @bae0
        cmp     #$ff
        beq     @bae0
        jsr     GetNPCPtr
        cmp     #$ff
        beq     @bae0
        cmp     _00bb63,y
        bne     @bae0
        jmp     @bae3
@bae0:  jmp     @bb0c
@bae3:  lda     $0909,x     ; save facing direction
        pha
        lda     $0901,x
        and     #$10
        beq     @baf9       ; branch if npc doesn't face player
        lda     $1705
        clc
        adc     #$02        ; face toward player
        and     #$03
        sta     $0909,x
@baf9:  phx
        jsr     DrawNPCs
        plx
        lda     $0907,x
        phx
        jsr     ExecNPCScript
        plx
        pla
        sta     $0909,x     ; restore facing direction
        stz     $ee
@bb0c:  rts

; ------------------------------------------------------------------------------

; [ get npc pointer ]

GetNPCPtr:
@bb0d:  and     #$7f
        tax
        lda     #$00
@bb12:  cpx     #$0000
        beq     @bb1e
        dex
        clc
        adc     #$0f
        jmp     @bb12
@bb1e:  tax
        lda     $0903,x
        ora     $0905,x
        bne     @bb2c
        lda     #$ff
        jmp     @bb30
@bb2c:  lda     $0902,x
        dec
@bb30:  rts

; ------------------------------------------------------------------------------

_00bb31:
@bb31:  .byte   $00,$01,$00,$ff,$00
_00bb36:
@bb36:  .byte   $ff,$00,$01,$00,$fe
_00bb3b:
@bb3b:  .byte   $ff,$01,$01,$ff,$ff
_00bb40:
@bb40:  .byte   $ff,$ff,$01,$01,$fe
_00bb45:
@bb45:  .byte   $01,$01,$ff,$ff,$01
_00bb4a:
@bb4a:  .byte   $ff,$01,$01,$ff,$fe
_00bb4f:
@bb4f:  .byte   $00,$02,$00,$fe,$00
_00bb54:
@bb54:  .byte   $fe,$00,$02,$00,$fe
_00bb59:
@bb59:  .byte   $03,$00,$01,$02,$03
_00bb5e:
@bb5e:  .byte   $01,$02,$03,$00,$01
_00bb63:
@bb63:  .byte   $00,$01,$02,$03,$00

; ------------------------------------------------------------------------------

; [ draw npcs ]

DrawNPCs:
@bb68:  lda     $08fe
        bne     @bb6e
        rts
@bb6e:  ldx     #0
        stx     $af
        stx     $40
        stz     $ae
        ldx     #$0020
        stx     $43
@bb7c:  ldx     $af
        lda     $090b,x
        bne     @bb86
        jmp     @bd16
@bb86:  lda     $0901,x
        and     #$03
        beq     @bbd7
        tay
        lda     $0901,x
        and     #$20
        bne     @bb9d
        ldy     #$0100
        sty     $3d
        jmp     @bc4d
@bb9d:  cpy     #$0001
        bne     @bbb1
        lda     $7a
        and     #$10
        asl2
        sta     $3d
        lda     #$01
        sta     $3e
        jmp     @bc4d
@bbb1:  lda     $0901,x
        lsr6
        tax
        lda     _00bdf6,x
        tax
        lda     $7a
@bbc1:  lsr
        dex
        bne     @bbc1
        ldx     $af
        and     #$0c
        asl2
        and     _00bdfa,y
        sta     $3d
        lda     #$01
        sta     $3e
        jmp     @bc4d
@bbd7:  lda     $090c,x
        and     #$02
        beq     @bbfd
        lda     $08ff,x
        and     #$7f
        lsr4
        tay
        lda     $090c,x
        and     #$01
        bne     @bbf5
        lda     _00bdfe,y
        jmp     @bbf8
@bbf5:  lda     _00be06,y
@bbf8:  stz     $3d
        jmp     @bc41
@bbfd:  lda     $0902,x
        and     #$7f
        bne     @bc10
        lda     $0901,x
        and     #$20
        bne     @bc32
        lda     #$00
        jmp     @bc3a
@bc10:  lda     $08ff,x
        and     #$40
        beq     @bc1c
        lda     #$00
        jmp     @bc3a
@bc1c:  lda     $0908,x
        beq     @bc28
        lda     $08ff,x
        lsr
        jmp     @bc34
@bc28:  lda     $b1
        bne     @bc32
        lda     $08ff,x
        jmp     @bc34
@bc32:  lda     $7a
@bc34:  and     #$10
        lsr4
@bc3a:  sta     $3d
        lda     $0909,x
        and     #$7f
@bc41:  asl
        clc
        adc     $3d
        asl4
        sta     $3d
        stz     $3e
@bc4d:  lda     $090d,x
        asl
        sta     $07
        stz     $08
        lda     $090c,x
        and     #$01
        beq     @bc6a
        lda     $08ff,x
        lsr2
        and     #$1f
        tax
        lda     f:NPCJumpYTbl,x   ; y-offset for jumping npcs
        sta     $08
@bc6a:  ldx     $3d
        lda     #$04
        sta     $06
@bc70:  ldy     $af
        lda     $0903,y     ; x-offset
        clc
        adc     f:NPCSpriteTbl,x
        sta     $0c
        stz     $0d
        lda     $0905,y
        clc
        adc     f:NPCSpriteTbl+1,x
        sta     $0e
        stz     $0f
        jsr     _00bdb0
        lda     $d7
        bne     @bcff
        ldy     $40
        lda     $06
        lsr
        bcs     @bcc6
        lda     $18
        sta     $0400,y
        lda     $1a
        sec
        sbc     #$04
        sec
        sbc     $08
        sta     $0401,y
        lda     f:NPCSpriteTbl+2,x
        clc
        adc     $43
        sta     $0402,y
        lda     $44
        adc     #$00
        clc
        adc     f:NPCSpriteTbl+3,x
        and     #$f1
        clc
        adc     $07
        sta     $0403,y
        jmp     @bcff
@bcc6:  lda     $18
        sta     $0480,y
        lda     $1a
        sec
        sbc     #$04
        sec
        sbc     $08
        sta     $0481,y
        lda     f:NPCSpriteTbl+2,x
        clc
        adc     $43
        sta     $0482,y
        lda     $44
        adc     #$00
        clc
        adc     f:NPCSpriteTbl+3,x
        and     #$f1
        clc
        adc     $07
        sta     $0483,y
        ldy     $af
        lda     $090a,y
        beq     @bcff
        ldy     $40
        lda     #$f8
        sta     $0481,y
@bcff:  inx4
        lda     $06
        lsr
        bcc     @bd0f
        lda     $40
        clc
        adc     #$04
        sta     $40
@bd0f:  dec     $06
        beq     @bd16
        jmp     @bc70
@bd16:  lda     $43
        clc
        adc     #$20
        sta     $43
        lda     $44
        adc     #$00
        sta     $44
        lda     $af
        clc
        adc     #$0f
        sta     $af
        inc     $ae
        lda     $ae
        cmp     $08fe
        beq     @bd36
        jmp     @bb7c
@bd36:  lda     $128a
        and     #$40
        beq     @bdaf
        stz     $ae
@bd3f:  lda     $ae
        tax
        lda     f:_14fc96,x
        sta     $0c
        lda     f:_14fca6,x
        sta     $0e
        lda     f:_14fc76,x
        sta     $07
        lda     f:_14fcb6,x
        sta     $08
        lda     $ae
        stz     $3e
        asl
        rol     $3e
        asl
        rol     $3e
        asl
        rol     $3e
        asl
        rol     $3e
        sta     $3d
        ldy     $3d
        lda     $ae
        tax
        lda     f:_14fc86,x
        tax
@bd76:  lda     $0c
        clc
        adc     f:NPCSpriteTbl,x
        sta     $0300,y
        lda     $0e
        clc
        adc     f:NPCSpriteTbl+1,x
        sta     $0301,y
        lda     $07
        clc
        adc     f:NPCSpriteTbl+2,x
        sta     $0302,y
        lda     f:NPCSpriteTbl+3,x
        and     #$f1
        ora     $08
        sta     $0303,y
        jsr     NextSprite
        tya
        and     #$0f
        bne     @bd76
        inc     $ae
        lda     $ae
        cmp     #$10
        bne     @bd3f
@bdaf:  rts

; ------------------------------------------------------------------------------

; [  ]

_00bdb0:
@bdb0:  phx
        phy
        stz     $d7
        ldx     $af
        longa
        lda     $0904,x
        and     #$00ff
        asl4
        clc
        adc     $0c
        sec
        sbc     $5a
        and     #$03ff
        sta     $18
        cmp     #$0100
        bcs     @bdec
        lda     $0906,x
        and     #$00ff
        asl4
        clc
        adc     $0e
        sec
        sbc     $5c
        and     #$03ff
        sta     $1a
        cmp     #$00f0
        bcc     @bdee
@bdec:  inc     $d7
@bdee:  lda     #0
        shorta
        ply
        plx
        rts

; ------------------------------------------------------------------------------

_00bdf6:
@bdf6:  .byte   $04,$03,$02,$01

_00bdfa:
@bdfa:  .byte   $00,$00,$10,$30

_00bdfe:
@bdfe:  .byte   $03,$00,$01,$02
@be02:  .byte   $03,$00,$01,$02

_00be06:
@be06:  .byte   $02,$02,$03,$00
@be0a:  .byte   $01,$02,$02,$02

; ------------------------------------------------------------------------------

; [ check npc movement ]

CheckMoveNPCs:
@be0e:  lda     $08fe
        bne     @be14       ; return if there are no npcs
        rts
@be14:  stz     $ae
        ldx     #0
        stx     $af
@be1b:  ldx     $af
        lda     $b1
        beq     @be29
        lda     $0908,x
        bne     @be29
        jmp     @bf96
@be29:  lda     $0902,x
        and     #$7f
        bne     @be33
        jmp     @bf66
@be33:  lda     $08ff,x
        and     #$40
        beq     @be3d
        jmp     @bf96
@be3d:  lda     $08ff,x
        and     #$3f
        beq     @be47
        jmp     @bf96
@be47:  stz     $0900,x
        lda     $ee
        beq     @be5b       ; branch if no npc blocking player
        and     #$7f
        cmp     $ae
        bne     @be5b       ; branch if not this npc
        stz     $ee
        lda     #$01
        sta     $0900,x
@be5b:  lda     $0904,x
        sta     $0c
        lda     $0906,x
        sta     $0e
        jsr     _00bfe3
        sta     $06
        lda     $0902,x
        and     #$7f
        sta     $0902,x
        jsr     Rand
        cmp     #$80
        bcc     @be7c
        jmp     @bef8
@be7c:  lda     $0904,x
        sta     $0c
        lda     $0906,x
        sta     $0e
        lda     $0902,x
        lsr
        bcc     @bec2
        jsr     Rand
        lsr
        bcs     @beaa
        inc     $0c
        jsr     _00bfe3
        cmp     $06
        bne     @bef8
        jsr     CheckNPCMap1
        cmp     #$00
        bne     @bef8
        lda     #$02
        sta     $0902,x
        jmp     @bef8
@beaa:  dec     $0c
        jsr     _00bfe3
        cmp     $06
        bne     @bef8
        jsr     CheckNPCMap1
        cmp     #$00
        bne     @bef8
        lda     #$04
        sta     $0902,x
        jmp     @bef8
@bec2:  jsr     Rand
        lsr
        bcs     @bee0
        dec     $0e
        jsr     _00bfe3
        cmp     $06
        bne     @bef8
        jsr     CheckNPCMap1
        cmp     #$00
        bne     @bef8
        lda     #$01
        sta     $0902,x
        jmp     @bef8
@bee0:  inc     $0e
        jsr     _00bfe3
        cmp     $06
        bne     @bef8
        jsr     CheckNPCMap1
        cmp     #$00
        bne     @bef8
        lda     #$03
        sta     $0902,x
        jmp     @bef8
@bef8:  ldx     $af
        lda     $0902,x
        and     #$7f
        tay
        lda     $0904,x
        clc
        adc     _00bfd9,y
        sta     $0c
        lda     $0906,x
        clc
        adc     _00bfde,y
        sta     $0e
        jsr     _00bfe3
        cmp     $06
        bne     @bf20
        jsr     CheckNPCMap1
        cmp     #$00
        beq     @bf66
@bf20:  lda     $0902,x
        dec
        clc
        adc     #$02
        and     #$03
        inc
        tay
        lda     $0904,x
        clc
        adc     _00bfd9,y
        sta     $0c
        lda     $0906,x
        clc
        adc     _00bfde,y
        sta     $0e
        jsr     _00bfe3
        cmp     $06
        bne     @bf5b
        jsr     CheckNPCMap1
        cmp     #$00
        bne     @bf5b
        lda     $0902,x
        dec
        clc
        adc     #$02
        and     #$03
        inc
        sta     $0902,x
        jmp     @bf66
@bf5b:  lda     $0902,x
        ora     #$80
        sta     $0902,x
        jmp     @bf96
@bf66:  lda     $090b,x
        bne     @bf6e
        jmp     @bf96
@bf6e:  lda     $0904,x
        sta     $0c
        lda     $0906,x
        sta     $0e
        jsr     ClearNPCMap
        lda     $0902,x
        and     #$7f
        tay
        lda     $0904,x
        clc
        adc     _00bfd9,y
        sta     $0c
        lda     $0906,x
        clc
        adc     _00bfde,y
        sta     $0e
        jsr     SetNPCMap
@bf96:  ldx     $af
        lda     $0902,x
        beq     @bfa1
        dec
        sta     $0909,x
@bfa1:  lda     $0904,x
        sta     $3d
        lda     $0906,x
        sta     $3e
        ldx     $3d
        lda     $7f5c71,x
        sta     $3d
        stz     $3e
        asl     $3d
        rol     $3e
        ldx     $3d
        lda     $0edc,x
        ldx     $af
        and     #$08
        sta     $090a,x
        lda     $af
        clc
        adc     #$0f
        sta     $af
        inc     $ae
        lda     $ae
        cmp     $08fe
        beq     @bfd8
        jmp     @be1b
@bfd8:  rts

; ------------------------------------------------------------------------------

_00bfd9:
@bfd9:  .byte   $00,$00,$01,$00,$ff

_00bfde:
@bfde:  .byte   $00,$ff,$00,$01,$00

; ------------------------------------------------------------------------------

; [  ]

_00bfe3:
@bfe3:  phx
        lda     $0c
        bmi     @c008
        sta     $3d
        lda     $0e
        bmi     @c008
        sta     $3e
        ldx     $3d
        lda     $7f5c71,x
        sta     $3d
        stz     $3e
        asl     $3d
        rol     $3e
        ldx     $3d
        lda     $0edb,x
        and     #$83
        jmp     @c00a
@c008:  lda     #$00
@c00a:  plx
        rts

; ------------------------------------------------------------------------------

; [ move npcs ]

MoveNPCs:
@c00c:  lda     $08fe
        bne     @c012       ; return if there are no npcs
        rts
@c012:  stz     $ae
        ldx     #0
        stx     $af
@c019:  ldx     $af
        lda     $b1
        beq     @c027
        lda     $0908,x
        bne     @c03b
        jmp     @c0ec
@c027:  lda     $0902,x
        bpl     @c02f
        jmp     @c0ce
@c02f:  ldx     $af
        lda     $08ff,x
        and     #$40
        beq     @c03b
        jmp     @c0ce
@c03b:  lda     $0902,x
        and     #$7f
        bne     @c045
        jmp     @c0ce
@c045:  lda     $08ff,x
        and     #$03
        beq     @c04f
        jmp     @c0ce
@c04f:  ldx     $af
        lda     $0900,x
        bne     @c064       ; branch if npc is blocking player movement
        lda     $0901,x     ; npc movement speed
        and     #$c0
        lsr6
        jmp     @c066
@c064:  lda     #$02        ; movement speed if blocking player
@c066:  tay
        lda     $0902,x     ; movement direction
        dec
        beq     @c076
        dec
        beq     @c08c
        dec
        beq     @c0a2
        jmp     @c0b8
; up
@c076:  lda     $0905,x     ; decrease y offset
        sec
        sbc     _00c117,y
        pha
        and     #$0f
        sta     $0905,x
        pla
        bpl     @c089
        dec     $0906,x
@c089:  jmp     @c0ce
; right
@c08c:  lda     $0903,x     ; increase x offset
        clc
        adc     _00c117,y
        and     #$0f
        sta     $0903,x
        cmp     #$00
        bne     @c09f
        inc     $0904,x
@c09f:  jmp     @c0ce
; down
@c0a2:  lda     $0905,x     ; increase y offset
        clc
        adc     _00c117,y
        and     #$0f
        sta     $0905,x
        cmp     #$00
        bne     @c0b5
        inc     $0906,x
@c0b5:  jmp     @c0ce
; left
@c0b8:  lda     $0903,x     ; decrease x offset
        sec
        sbc     _00c117,y
        pha
        and     #$0f
        sta     $0903,x
        pla
        bpl     @c0cb
        dec     $0904,x
@c0cb:  jmp     @c0ce
@c0ce:  lda     $0900,x
        bne     @c0df       ; branch if npc is blocking player movement
        lda     $0901,x
        lsr6
        jmp     @c0e1
@c0df:  lda     #$02
@c0e1:  tay
        lda     $08ff,x
        clc
        adc     _00c11b,y
        sta     $08ff,x
@c0ec:  lda     $b1
        beq     @c100
        lda     $0908,x
        beq     @c100
        cmp     $08ff,x
        bne     @c100
        stz     $0908,x
        stz     $0902,x     ; stop moving
@c100:  lda     $af         ; next npc
        clc
        adc     #$0f
        sta     $af
        inc     $ae
        lda     $ae
        cmp     $08fe
        beq     @c113
        jmp     @c019
@c113:  inc     $08fd
        rts

; ------------------------------------------------------------------------------

; constants for npc movement speeds
_00c117:
@c117:  .byte   1,1,1,2

_00c11b:
@c11b:  .byte   1,2,4,8

; ------------------------------------------------------------------------------

; [ reload npcs ]

ReloadNPCs:
@c11f:  stz     $ae
        ldx     $09d1
        stx     $09cf
@c127:  lda     f:NPCProp,x
        jsr     LoadNPCGfx
        ldx     $09cf
        inx4
        stx     $09cf
        inc     $ae
        lda     $ae
        cmp     #12
        bne     @c127
        rts

; ------------------------------------------------------------------------------

; [ init npcs ]

InitNPCs:
@c141:  stz     $08fd
        jsr     ResetNPCMap
        lda     $0fde
        stz     $3e
        asl
        rol     $3e
        sta     $3d
        lda     $0fe5
        bmi     @c15b
        lda     $1701
        beq     @c15f
@c15b:  inc     $3e
        inc     $3e
@c15f:  ldx     $3d
        lda     f:NPCPropPtrs,x
        sta     $3d
        lda     f:NPCPropPtrs+1,x
        sta     $3e
        ldx     $3d
        stx     $09cf
        stx     $09d1
        stz     $08fe
        ldx     $09cf
@c17b:  lda     f:NPCProp,x
        beq     @c18b
        inc     $08fe
        inx4
        jmp     @c17b
@c18b:  lda     $08fe
        bne     @c191
        rts
@c191:  stz     $ae
        ldx     #0
        stx     $af
@c198:  ldx     $09cf
        lda     f:NPCProp,x
        jsr     LoadNPCGfx
        lda     $06
        cmp     #$2e
        bcs     @c1ad
        lda     #$00
        jmp     @c1c1
@c1ad:  cmp     #$30
        bcs     @c1b6
        lda     #$03
        jmp     @c1c1
@c1b6:  cmp     #$46
        bcs     @c1bf
        lda     #$02
        jmp     @c1c1
@c1bf:  lda     #$01
@c1c1:  sta     $07
        ldx     $09cf
        ldy     $af
        lda     f:NPCProp+3,x
        sta     $0901,y
        and     #$03
        sta     $0909,y
        inc
        sta     $0902,y
        lda     $0901,y
        and     #$fc
        ora     $07
        sta     $0901,y
        lda     $06
        cmp     #$0e
        bcs     @c1f0
        tax
        lda     f:PlayerPalTbl,x   ; color palette for each character
        jmp     @c1fb
@c1f0:  lda     f:NPCProp+3,x
        and     #$0c
        lsr2
        clc
        adc     #$04
@c1fb:  sta     $090d,y
        ldx     $09cf
        lda     f:NPCProp,x
        sta     $0907,y
        lda     f:NPCProp+1,x
        bmi     @c213
        lda     #$00
        sta     $0902,y
@c213:  lda     f:NPCProp+1,x
        and     #$3f
        sta     $0904,y
        sta     $0c
        lda     f:NPCProp+2,x
        sta     $0906,y
        sta     $0e
        lda     $0907,y
        jsr     CheckNPCSwitch
        sta     $090b,y
        cmp     #$00
        beq     @c237
        jsr     SetNPCMap
@c237:  lda     #$00
        sta     $08ff,y
        sta     $0903,y
        sta     $0905,y
        sta     $0900,y
        sta     $0908,y
        sta     $090c,y
        lda     $0904,y
        sta     $3d
        lda     $0906,y
        sta     $3e
        ldx     $3d
        lda     $7f5c71,x
        sta     $3d
        stz     $3e
        asl     $3d
        rol     $3e
        ldx     $3d
        lda     $0edc,x
        ldx     $af
        and     #$08
        sta     $090a,x
        ldx     $09cf
        inx4
        stx     $09cf
        lda     $af
        clc
        adc     #$0f
        sta     $af
        inc     $ae
        lda     $ae
        cmp     $08fe
        beq     @c28c
        jmp     @c198
@c28c:  lda     #$0c
        sta     $ae
        lda     #$18
        jsr     LoadSpriteGfx
        lda     #$1b
        inc     $ae
        jsr     LoadSpriteGfx
        lda     #$1c
        inc     $ae
        jsr     LoadSpriteGfx
        lda     $0fe1
        and     #$0f
        ldy     #0
        jsr     LoadNPCPal
        lda     $0fe1
        lsr4
        ldy     #$0040
        jsr     LoadNPCPal
        rts

; ------------------------------------------------------------------------------

; [ load npc palette ]

LoadNPCPal:
@c2bc:  sta     $3e
        stz     $3d
        lsr     $3e
        ror     $3d
        lsr     $3e
        ror     $3d
        lsr     $3e
        ror     $3d
        ldx     $3d
@c2ce:  lda     f:MapSpritePal+13*16,x
        sta     $0e5b,y
        inx
        iny
        tya
        and     #$0f
        bne     @c2ce
@c2dc:  lda     #$00
        sta     $0e5b,y
        iny
        tya
        and     #$0f
        bne     @c2dc
        tya
        and     #$3f
        bne     @c2ce
        rts

; ------------------------------------------------------------------------------

; [ reset npc map ]

ResetNPCMap:
@c2ed:  ldx     #0
        lda     #0
@c2f2:  sta     $7f4c00,x
        inx
        cpx     #$0400
        bne     @c2f2
        rts

; ------------------------------------------------------------------------------

; [ clear npc map position ]

ClearNPCMap:
@c2fd:  phx
        jsr     GetNPCMapPtr
        ldx     $3d
        lda     #0
        sta     $7f4c00,x
        plx
        rts

; ------------------------------------------------------------------------------

; [ check npc map ]

; return 0 if no npc present or 1 if out of bounds

CheckNPCMap1:
@c30b:  phx
        lda     $0c         ; x position
        cmp     #$20
        bcs     @c324
        lda     $0e         ; y position
        cmp     #$20
        bcs     @c324
        jsr     GetNPCMapPtr
        ldx     $3d
        lda     $7f4c00,x
        jmp     @c326
@c324:  lda     #$01        ; return 1 if out of bounds
@c326:  plx
        rts

; ------------------------------------------------------------------------------

; [ check npc map ]

; return 0 if out of bounds or no npc present

CheckNPCMap2:
@c328:  phx
        lda     $0c         ; x position
        cmp     #$20
        bcs     @c341
        lda     $0e         ; y position
        cmp     #$20
        bcs     @c341
        jsr     GetNPCMapPtr
        ldx     $3d
        lda     $7f4c00,x
        jmp     @c343
@c341:  lda     #$00        ; return 0 if out of bounds
@c343:  plx
        rts

; ------------------------------------------------------------------------------

; [ set npc map position ]

SetNPCMap:
@c345:  phx
        jsr     GetNPCMapPtr
        ldx     $3d
        lda     $ae
        ora     #$80
        sta     $7f4c00,x
        plx
        rts

; ------------------------------------------------------------------------------

; [ get pointer to npc map ]

GetNPCMapPtr:
@c355:  lda     $0e
        sta     $3e
        stz     $3d
        lsr     $3e
        ror     $3d
        lsr     $3e
        ror     $3d
        lsr     $3e
        ror     $3d
        lda     $3d
        clc
        adc     $0c
        sta     $3d
        rts

; ------------------------------------------------------------------------------

; [ load npc graphics ]

LoadNPCGfx:
@c36f:  sta     $3d
        stz     $3e
        lda     $0fe5
        bmi     @c37d
        lda     $1701
        beq     @c37f
@c37d:  inc     $3e
@c37f:  ldx     $3d
        lda     f:NPCGfxID,x
        sta     $06
        jsr     LoadSpriteGfx
        rts

; ------------------------------------------------------------------------------

; [ load sprite graphics ]

LoadSpriteGfx:
@c38b:  cmp     #$11
        bcs     @c398
        asl3
        ldx     #0
        jmp     @c3bb
@c398:  cmp     #$30
        bcs     @c3a7
        sec
        sbc     #$11
        asl2
        ldx     #$3300
        jmp     @c3bb
@c3a7:  cmp     #$46
        bcs     @c3b5
        sec
        sbc     #$30
        asl
        ldx     #$6180
        jmp     @c3bb
@c3b5:  sec
        sbc     #$46
        ldx     #$7200
@c3bb:  longa
        xba
        lsr2
        sta     $4a
        lsr
        clc
        adc     $4a
        sta     $4a
        txa
        clc
        adc     $4a
        clc
        adc     #$8000
        sta     $4a
        lda     #0
        shorta
        lda     $ae
        asl
        clc
        adc     #$42
        sta     $4d
        stz     $4c
        ldx     #$0200
        stx     $4e
        lda     #.bankbyte(MapSpriteGfx)
        sta     $49
        jsl     Tfr3bppGfx
        rts

; ------------------------------------------------------------------------------

; [ check npc switch ]

CheckNPCSwitch:
@c3ef:  phy
        pha
        and     #$07
        sta     $07
        pla
        lsr3
        sta     $3d
        lda     $0fe5
        bmi     @c405
        lda     $1701
        beq     @c40c
@c405:  lda     $3d
        clc
        adc     #$20
        sta     $3d
@c40c:  stz     $3e
        lda     $07
        tay
        ldx     $3d
        lda     f:$0012e0,x   ; npc switches
@c417:  cpy     #0
        beq     @c421
        lsr
        dey
        jmp     @c417
@c421:  lsr
        lda     #0
        adc     #0
        ply
        rts

; ------------------------------------------------------------------------------

; [ random (0..255) ]

Rand:
@c428:  phx
        lda     $78
        tax
        lda     f:RNGTbl,x   ; rng table
        inc     $78
        plx
        rts

; ------------------------------------------------------------------------------
