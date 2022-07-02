
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: event.asm                                                            |
; |                                                                            |
; | description: event routines                                                |
; |                                                                            |
; | created: 3/29/2022                                                         |
; +----------------------------------------------------------------------------+

.import ShopMenu_ext, NamingwayMenu_ext2, FatChocoMenu_ext2
.import UpdateEquip_ext

; ------------------------------------------------------------------------------

.pushseg

.segment "event_data1"

EventScriptPtrs:
        make_ptr_tbl_rel EventScript, 256
        .include .sprintf("data/event_script_%s.asm", LANG_SUFFIX)

.segment "event_data2"
        .include .sprintf("data/npc_gfx_id_%s.asm", LANG_SUFFIX)
        .include "data/init_npc_switch.asm"
        .include "data/init_event_switch.asm"

TriggerScriptPtrs:
        make_ptr_tbl_rel TriggerScript, $0100
        .include "data/trigger_script.asm"

.popseg

; ------------------------------------------------------------------------------

; [ execute event ]

; A: event id

ExecEvent:
@e1eb:  stz     $3e
        asl
        rol     $3e
        sta     $3d
        ldx     $3d
        lda     f:EventScriptPtrs,x
        sta     $09d3
        lda     f:EventScriptPtrs+1,x
        sta     $09d4
        lda     #$0f
        sta     $80
@e206:  ldy     #$0000
        lda     #$01
        sta     $0a15
        ldx     $09d3
        lda     f:EventScript,x
        cmp     #$ff
        bne     @e236
        lda     $1703
        stz     $3d
        lsr
        ror     $3d
        lsr
        ror     $3d
        sta     $3e
        ldx     $3d
        lda     $1000,x
        bne     @e231
        jsl     ValidateTopChar
@e231:  lda     #$01
        sta     $e0
        rts
@e236:  cmp     #$eb
        bne     @e25a
        inx
        lda     f:EventScript,x
        sta     $0a15
        inx
        lda     f:EventScript,x
        sta     $07
        inx
@e24a:  lda     f:EventScript,x
        sta     $09d5,y
        inx
        iny
        dec     $07
        bne     @e24a
        jmp     @e28f
@e25a:  cmp     #$db
        bcc     @e28a
        cmp     #$e2
        beq     @e278
        cmp     #$fe
        bne     @e281
        sta     $09d5,y
        inx
        iny
        lda     f:EventScript,x
        sta     $09d5,y
        inx
        iny
        lda     f:EventScript,x
@e278:  sta     $09d5,y
        inx
        iny
        lda     f:EventScript,x
@e281:  sta     $09d5,y
        inx
        iny
        lda     f:EventScript,x
@e28a:  sta     $09d5,y
        inx
        iny
@e28f:  stx     $09d3
        lda     #$ff
        sta     $09d5,y
@e297:  jsr     _00e2a2
        dec     $0a15
        bne     @e297
        jmp     @e206

; ------------------------------------------------------------------------------

; [  ]

_00e2a2:
@e2a2:  ldx     #0
        stx     $b3
        lda     $09d5,x
        sta     $0a16
        cmp     #$d0
        bcc     @e2b4
        jmp     @e340
@e2b4:  ldx     $b3
        lda     $09d5,x
        sta     $0a16
        cmp     #$ff
        bne     @e2c3
        jmp     @e2d8
@e2c3:  cmp     #$c0
        bcs     @e2cd
        jsr     _00e35f
        jmp     @e2d0
@e2cd:  jsr     _00e4a9
@e2d0:  ldx     $b3
        inx
        stx     $b3
        jmp     @e2b4
@e2d8:  jsr     WaitVblankLong
        stz     $d5         ; disable player control
        jsr     ResetSprites
        jsr     UpdateLocalTiles
        lda     $1700
        cmp     #$03
        beq     @e2ff
        jsr     MovePlayer
        jsr     DrawWorldSprites
        lda     $ac
        tax
        lda     $7b
        and     _00e54f,x
        bne     @e2d8
        stz     $ab
        jmp     @e33b
@e2ff:  jsr     MovePlayer
        jsr     MoveNPCs
        jsl     DrawPlayerSub
        jsr     DrawNPCs
        lda     $ab
        beq     @e31c
        lda     $ac
        tax
        lda     $7b
        and     _00e54f,x
        bne     @e2d8
        stz     $ab
@e31c:  ldx     #0
        stx     $3d
        lda     $08fe
        beq     @e33b
        tay
@e327:  ldx     $3d
        lda     $0908,x
        bne     @e2d8
        stz     $090c,x
        lda     $3d
        clc
        adc     #$0f
        sta     $3d
        dey
        bne     @e327
@e33b:  lda     #1        ; enable player control
        sta     $d5
        rts
@e340:  sec
        sbc     #$d0
        stz     $3e
        asl
        rol     $3e
        sta     $3d
        ldx     $3d
        lda     EventCmdTbl,x
        sta     $3d
        lda     EventCmdTbl+1,x
        sta     $3e
        ldx     $b3
        jmp     ($063d)

; ------------------------------------------------------------------------------

; [ wait for vblank ]

WaitVblankEvent:
@e35b:  jsr     WaitVblankLong
        rts

; ------------------------------------------------------------------------------

; [  ]

_00e35f:
@e35f:  sta     $ae
        lsr4
        tay
        lda     #0
@e368:  cpy     #0
        beq     @e374
        dey
        clc
        adc     #$0f
        jmp     @e368
@e374:  tax
        stx     $0a47
        lda     #$40
        sta     $0908,x
        lda     $ae
        and     #$0f
        cmp     #$04
        bcs     @e39d
        inc
        sta     $0902,x
        lda     $cf
        bne     @e394
        lda     $0902,x
        dec
        sta     $0909,x
@e394:  lda     $ea
        bne     @e39a
        inc     $ea
@e39a:  jmp     @e498
@e39d:  cmp     #$08
        bcs     @e3aa
        sec
        sbc     #$04
        sta     $0909,x
        jmp     @e4a5
@e3aa:  cmp     #$08
        bne     @e406
        stz     $0902,x
        lda     $0906,x
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
        adc     $0904,x
        sta     $3d
        lda     $ae
        lsr4
        clc
        adc     #$80
        sta     $06
        lda     $090b,x
        beq     @e3f4
        stz     $090b,x
        phx
        ldx     $3d
        lda     $7f4c00,x
        cmp     $06
        bne     @e3f0
        lda     #$00
        sta     $7f4c00,x
@e3f0:  plx
        jmp     @e4a5
@e3f4:  lda     #$01
        sta     $090b,x
        phx
        ldx     $3d
        lda     $06
        sta     $7f4c00,x
        plx
        jmp     @e4a5
@e406:  cmp     #$09
        bne     @e444
        lda     $0909,x
        and     #$01
        beq     @e421
        lda     $0909,x
        and     #$02
        bne     @e42e
        lda     #$02
        sta     $0902,x
        dec
        sta     $0909,x
@e421:  lda     #$01
        sta     $090c,x
        lda     #$80
        sta     $0908,x
        jmp     @e498
@e42e:  lda     #$04
        sta     $0902,x
        dec
        sta     $0909,x
        lda     #$01
        sta     $090c,x
        lda     #$80
        sta     $0908,x
        jmp     @e498
@e444:  cmp     #$0a
        bne     @e458
        stz     $08ff,x
        lda     #$02
        sta     $090c,x
        lda     #$40
        sta     $0908,x
        jmp     @e4a5
@e458:  cmp     #$0b
        bne     @e46c
        stz     $08ff,x
        lda     #$03
        sta     $090c,x
        lda     #$80
        sta     $0908,x
        jmp     @e4a5
@e46c:  cmp     #$0c
        bne     @e478
        lda     #$05
        sta     $0909,x
        jmp     @e4a5
@e478:  cmp     #$0d
        bne     @e484
        lda     #$04
        sta     $0909,x
        jmp     @e4a5
@e484:  cmp     #$0e
        bne     @e490
        lda     #$06
        sta     $0909,x
        jmp     @e4a5
@e490:  lda     #$07
        sta     $0909,x
        jmp     @e4a5
@e498:  lda     $0904,x
        sta     $0c
        lda     $0906,x
        sta     $0e
        jsr     ClearNPCMap
@e4a5:  stz     $08ff,x
        rts

; ------------------------------------------------------------------------------

; [  ]

_00e4a9:
@e4a9:  cmp     #$c4
        bcs     @e4bf
        sec
        sbc     #$c0
        asl
        tay
        lda     _00e547,y
        sta     $04
        lda     _00e547+1,y
        sta     $05
        jmp     @e534
@e4bf:  stz     $04
        stz     $05
        cmp     #$c8
        bcs     @e4d0
        sec
        sbc     #$c4
        sta     $1705
        jmp     @e534
@e4d0:  cmp     #$c8
        bne     @e4db
        lda     #$01
        sta     $d3
        jmp     @e534
@e4db:  cmp     #$c9
        bne     @e4e4
        stz     $d3
        jmp     @e534
@e4e4:  cmp     #$ca
        bne     @e4f0
        lda     #$05
        sta     $1705
        jmp     @e52e
@e4f0:  cmp     #$cb
        bne     @e4fc
        lda     #$04
        sta     $1705
        jmp     @e52e
@e4fc:  cmp     #$cc
        bne     @e508
        lda     #$06
        sta     $1705
        jmp     @e52e
@e508:  cmp     #$cd
        bne     @e514
        lda     #$07
        sta     $1705
        jmp     @e52e
@e514:  cmp     #$ce
        bne     @e521
        lda     $cf
        eor     #$01
        sta     $cf
        jmp     @e52e
@e521:  lda     $d8
        bne     @e52a
        lda     #$01
        jmp     @e52c
@e52a:  lda     #$00
@e52c:  sta     $d8
@e52e:  stz     $ab
        stz     $02
        stz     $03
@e534:  stz     $7b
        lda     $1700
        cmp     #$03
        beq     @e543
        jsr     CheckPlayerMoveWorld
        jmp     @e546
@e543:  jsr     CheckPlayerMoveSub
@e546:  rts

; ------------------------------------------------------------------------------

_00e547:
@e547:  .word   $0800,$0100,$0400,$0200

_00e54f:
@e54f:  .byte   $0f,$07,$03,$01

; ------------------------------------------------------------------------------

; [ get next event script byte ]

GetNextEventByte:
@e553:  inx
        stx     $b3
        lda     $09d5,x
        rts

; ------------------------------------------------------------------------------

; [ find event script terminator ]

FindEventTerminator:
@e55a:  ldx     $09d3       ; event script pointer
        inx
@e55e:  lda     f:EventScript,x   ; event scripts
        cmp     #$ff
        beq     @e56a
        inx
        jmp     @e55e
@e56a:  stx     $09d3
        rts

; ------------------------------------------------------------------------------

EventCmdTbl:
@e56e:  .addr   EventCmd_d0
        .addr   EventCmd_d1
        .addr   EventCmd_d2
        .addr   EventCmd_d3
        .addr   EventCmd_d4
        .addr   EventCmd_d5
        .addr   EventCmd_d6
        .addr   EventCmd_d7
        .addr   EventCmd_d8
        .addr   EventCmd_d9
        .addr   EventCmd_da
        .addr   EventCmd_db
        .addr   EventCmd_dc
        .addr   EventCmd_dd
        .addr   EventCmd_de
        .addr   EventCmd_df
        .addr   EventCmd_e0
        .addr   EventCmd_e1
        .addr   EventCmd_e2
        .addr   EventCmd_e3
        .addr   EventCmd_e4
        .addr   EventCmd_e5
        .addr   EventCmd_e6
        .addr   EventCmd_e7
        .addr   EventCmd_e8
        .addr   EventCmd_e9
        .addr   EventCmd_ea
        .addr   0
        .addr   EventCmd_ec
        .addr   EventCmd_ed
        .addr   EventCmd_ee
        .addr   EventCmd_ef
        .addr   EventCmd_f0
        .addr   EventCmd_f1
        .addr   EventCmd_f2
        .addr   EventCmd_f3
        .addr   EventCmd_f4
        .addr   EventCmd_f5
        .addr   EventCmd_f6
        .addr   EventCmd_f7
        .addr   EventCmd_f8
        .addr   EventCmd_f9
        .addr   EventCmd_fa
        .addr   EventCmd_fb
        .addr   0
        .addr   EventCmd_fd
        .addr   EventCmd_fe

; ------------------------------------------------------------------------------

; [ event command $d9: namingway menu ]

EventCmd_d9:
@e5cc:  jsr     FadeOutMenu
        jsl     NamingwayMenu_ext2
        jsr     FadeInMenu
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $d4: fat chocobo menu ]

EventCmd_d4:
@e5d9:  jsr     FadeOutMenu
        jsl     FatChocoMenu_ext2
        jsr     FadeInMenu
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $ed: shop ]

EventCmd_ed:
@e5e6:  jsr     GetNextEventByte
        sta     $1a00
        tax
        lda     f:ShopTypeTbl,x
        sta     $1a01
        jsr     FadeOutMenu
        jsl     ShopMenu_ext
        jsr     FadeInMenu
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $ea: play song (fade in) ]

EventCmd_ea:
@e601:  jsr     GetNextEventByte
        sta     $1e01
        lda     #$04
        sta     $1e00
        jsl     ExecSound_ext
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $d8: fade out music (slow) ]

EventCmd_d8:
@e613:  jsr     FadeOutSongSlow
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $ec: battle ]

EventCmd_ec:
@e619:  jsr     GetNextEventByte
        sta     $1800
        lda     $1701
        beq     @e626
        lda     #$01
@e626:  sta     $1801
        stz     $e4         ; disable solo character battle
        ldy     #$0000
@e62e:  lda     $1800
        cmp     SoloBattleTbl,y
        bne     @e63e
        lda     $1801
        cmp     SoloBattleTbl+1,y
        beq     @e668       ; branch if solo character battle
@e63e:  iny2
        cpy     #$001a
        bne     @e62e
@e645:  jsr     BattleSub
        lda     $e4
        beq     @e64f       ; branch if not a solo character battle
        jsr     RestorePartyAfterSoloBattle
@e64f:  jsl     InitHWRegs
        jsr     ReloadSubMap
        jsr     WipeIn
        jsl     DrawPlayerSub
        jsr     DrawNPCs
        lda     #$81       ; enable nmi
        sta     hNMITIMEN
        jmp     WaitVblankEvent

; solo character battle
@e668:  tya
        cmp     #$18
        bne     @e66f
        dec2
@e66f:  lsr
        sta     $06
        ora     #$80
        sta     $e4
        ldx     #0
        ldy     #0
@e67c:  lda     $1000,x     ; save character ids
        sta     $0ad6,y
        jsr     NextChar
        iny
        cpy     #5
        bne     @e67c
        lda     $06
        cmp     #$0b
        beq     @e6ed       ; branch if golbez and fusoya
        tay
        ldx     #0

; start of character loop
@e695:  lda     SoloBattleCharTbl,y
        cmp     #$03
        beq     @e6d6       ; branch if rydia
        lda     $1000,x
        and     #$1f
        cmp     SoloBattleCharTbl,y     ; find solo character
        beq     @e6b8
        cpy     #$000b
        bne     @e6b0
        cmp     SoloBattleCharTbl+1,y
        beq     @e6b8
@e6b0:  lda     #$00
        sta     $1000,x     ; hide other characters
        jmp     @e6d3
@e6b8:  jsr     ClearCharStatus
        lda     $1009,x     ; set solo character hp and mp to max
        sta     $1007,x
        lda     $100a,x
        sta     $1008,x
        lda     $100d,x
        sta     $100b,x
        lda     $100e,x
        sta     $100c,x
@e6d3:  jmp     @e6e2
@e6d6:  lda     $1000,x     ; hide rydia
        and     #$1f
        cmp     #$03
        bne     @e6e2
        stz     $1000,x
@e6e2:  jsr     NextChar
        cpx     #$0140
        bne     @e695
        jmp     @e645

; golbez and fusoya
@e6ed:  ldx     #0
@e6f0:  lda     $10c0,x     ; copy characters 4 and 5 to buffer
        sta     $1200,x
        inx
        cpx     #$0080
        bne     @e6f0
        ldx     #0
@e6ff:  stz     $1000,x     ; hide all characters
        jsr     NextChar
        cpx     #$0140
        bne     @e6ff
        ldx     #$00c0
        stx     $3d
        lda     #$0d        ;
        jsr     LoadCharProp
        ldx     #$0100
        stx     $3d
        lda     #$01
        jsr     RestoreCharProp
        ldx     #$0100
        jsr     ClearCharStatus
        lda     $1009,x     ; set hp and mp to max
        sta     $1007,x
        lda     $100a,x
        sta     $1008,x
        lda     $100d,x
        sta     $100b,x
        lda     $100e,x
        sta     $100c,x
        ldx     #$0030
@e73f:  stz     $10c0,x     ; clear equipped items
        inx
        cpx     #$0037
        bne     @e73f
        jmp     @e645

; ------------------------------------------------------------------------------

; [ restore party after solo character battle ]

RestorePartyAfterSoloBattle:
@e74b:  lda     $e4         ; solo character battle id
        and     #$7f
        sta     $e4
        cmp     #$0b
        bne     @e773       ; branch if not golbez and fusoya
        ldx     #0
@e758:  lda     $1100,x     ; save fusoya to buffer
        sta     $1180,x
        inx
        cpx     #$0040
        bne     @e758
        ldx     #0
@e767:  lda     $1200,x     ; restore characters 4 and 5
        sta     $10c0,x
        inx
        cpx     #$0080
        bne     @e767
@e773:  ldx     #0
        ldy     #0
@e779:  lda     $0ad6,y     ; restore character ids
        sta     $1000,x
        tya
        cmp     $e4
        bne     @e787
        jsr     ClearCharStatus
@e787:  jsr     NextChar
        iny
        cpy     #5
        bne     @e779
        rts

; ------------------------------------------------------------------------------

; solo character battles
;   $00: cecil vs. soldiers (kaipo inn)
;   $01:
;   $02:
;   $03: cecil vs. kain (fabul)
;   $04: tellah vs. edward (damcyan)
;   $05: cecil vs. cecil (mt. ordeals)
;   $06: edward vs. water hag (kaipo)
;   $07:
;   $08: tellah vs. golbez (tower of zot)
;   $09: edge vs. rubicant (cave eblana)
;   $0a: rydia vs. golbez (dwarf castle)
;   $0b: fusoya and golbez vs. zemus
;   $0c: fusoya and golbez vs. zeromus

; solo character id
SoloBattleCharTbl:
@e791:  .byte   $03,$03,$03,$01,$04,$0b,$05,$07,$0c,$12,$11,$13,$15

; solo character battles
SoloBattleTbl:
@e79e:  .word   $00f7,$00f8,$00f9,$00f1,$00ee,$00f6,$00ef,$00f0
        .word   $00f3,$00fd,$01a8,$01b3,$01b4

; ------------------------------------------------------------------------------

; [ increment character properties pointer ]

NextChar:
@e7b8:  longa
        txa
        clc
        adc     #$0040
        tax
        lda     #0
        shorta
        rts

; ------------------------------------------------------------------------------

; [ clear status ]

ClearCharStatus:
@e7c6:  stz     $1003,x
        stz     $1004,x
        stz     $1005,x
        stz     $1006,x
        rts

; ------------------------------------------------------------------------------

; [ event command $d7: toggle fast player movement ]

EventCmd_d7:
@e7d3:  lda     $ac
        bne     @e7dc
        inc     $ac
        jmp     WaitVblankEvent
@e7dc:  stz     $ac
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $fa: play song ]

EventCmd_fa:
@e7e1:  jsr     GetNextEventByte
        jsr     PlaySongEvent
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [  ]

PlaySongEvent:
@e7ea:  sta     $1e01
        lda     #$01        ; play song
        sta     $1e00
        jsl     ExecSound_ext
        rts

; ------------------------------------------------------------------------------

; [ event command $fb: play sound effect ]

EventCmd_fb:
@e7f7:  jsr     GetNextEventByte
        jsr     PlaySfx
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $e7: add character to party ]

EventCmd_e7:
@e800:  inx
        stx     $b3
        ldx     #0
        stx     $3d
@e808:  ldx     $3d
        lda     $1000,x
        beq     @e81f       ; find an empty character slot
        lda     $3d
        clc
        adc     #$40
        sta     $3d
        lda     $3e
        adc     #$00
        sta     $3e
        jmp     @e808
@e81f:  ldx     $b3
        lda     $09d5,x
        dec
        tay
        lda     CharRemoveTbl,y     ; character id
        bpl     @e866
; restore character
        jsr     RestoreCharProp
        ldy     $3d
        lda     $1000,y
        and     #$e0
        ldx     $b3
        ora     $09d5,x
        sta     $1000,y
        and     #$1f
        cmp     #$11
        bne     @e848       ; branch if not adult rydia
        lda     #$0b        ; change graphics to adult rydia
        sta     $1001,y
@e848:  lda     $1009,y     ; set hp and mp to max
        sta     $1007,y
        lda     $100a,y
        sta     $1008,y
        lda     $100d,y
        sta     $100b,y
        lda     $100e,y
        sta     $100c,y
        jsr     InitCharEquip
        jmp     @e869
; load character
@e866:  jsr     LoadCharProp
@e869:  jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ restore character properties ]

RestoreCharProp:
@e86c:  and     #$7f
        longa
        asl6
        sta     $40
        lda     #0
        shorta
        lda     #$40
        sta     $07
        ldy     $3d
        ldx     $40
@e885:  lda     $1140,x
        sta     $1000,y
        stz     $1140,x
        inx
        iny
        dec     $07
        bne     @e885
        rts

; ------------------------------------------------------------------------------

; [ load character properties ]

LoadCharProp:
@e895:  longa
        asl5
        sta     $40
        lda     #0
        shorta
        lda     #$14
        sta     $07
        ldx     $40
        ldy     $3d
@e8ab:  lda     f:CharProp,x   ; character properties
        sta     $1000,y
        inx
        iny
        dec     $07
        bne     @e8ab
        lda     #$03
        sta     $07
        ldx     $40
        ldy     $3d
@e8c0:  lda     f:CharProp+$14,x
        sta     $102d,y
        inx
        iny
        dec     $07
        bne     @e8c0
        lda     #$09
        sta     $07
        ldx     $40
        ldy     $3d
@e8d5:  lda     f:CharProp+$17,x
        sta     $1037,y
        inx
        iny
        dec     $07
        bne     @e8d5
        jsr     InitCharEquip
        rts

; ------------------------------------------------------------------------------

; [ init cecil's equipment ]

InitMainCharEquip:
@e8e6:  lda     #0
        jmp     _e8f6

InitCharEquip:
@e8eb:  ldx     $b3
        lda     $09d5,x
        dec
        cmp     #$0b
        bne     _e8f6       ; return if adult rydia
        rts
_e8f6:  sta     $07         ; multiply by 7
        asl3
        sec
        sbc     $07
        tax
        lda     #$07
        sta     $07
        ldy     $3d
@e905:  lda     f:CharInitEquip,x   ; initial character equipment
        sta     $1030,y
        inx
        iny
        dec     $07
        bne     @e905
        lsr     $3e
        ror     $3d
        lda     $3d
        lsr5
        jsl     UpdateEquip_ext
        rts

; ------------------------------------------------------------------------------

; characters to add (restore saved character if msb set)
CharRemoveTbl:
@e922:  .byte   $00,$01,$02,$03,$04,$05,$06,$07,$08,$81,$09,$81,$83,$0a,$80,$82
        .byte   $84,$0b,$0c,$80,$0d

; ------------------------------------------------------------------------------

; [ event command $e8: remove character from party ]

EventCmd_e8:
@e937:  inx
        stx     $b3
        ldy     #$0000
        sty     $3d
@e93f:  ldy     $3d
        lda     $1000,y
        and     #$1f
        cmp     $09d5,x
        beq     @e962
        lda     $3d
        clc
        adc     #$40
        sta     $3d
        lda     $3e
        adc     #$00
        sta     $3e
        ldy     $3d
        cpy     #$0140
        bne     @e93f
        jmp     WaitVblankEvent
@e962:  lda     $09d5,x
        dec
        tax
        lda     CharAddTbl,x
        bmi     @e99d
        longa
        asl6
        sta     $40
        lda     #$0000
        shorta
        lda     #$40
        sta     $07
        ldx     $3d
        ldy     $40
@e983:  lda     $1000,x
        sta     $1140,y
        inx
        iny
        dec     $07
        bne     @e983
        ldx     $40
        stz     $1143,x
        stz     $1144,x
        stz     $1145,x
        stz     $1146,x
@e99d:  ldx     $3d
        stz     $1000,x
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; characters to remove (don't save if msb set)
CharAddTbl:
@e9a5:  .byte   $80,$00,$04,$01,$80,$02,$03,$80,$80,$01,$80,$80,$80,$01,$00,$80
        .byte   $80,$80,$01,$80

; ------------------------------------------------------------------------------

; [ event command $f9:  ]

EventCmd_f9:
@e9b9:  inx
        stx     $b3
        lda     $81
        bne     @e9c9
        lda     $09d5,x
        jsr     _00e9cf
        jmp     WaitVblankEvent
@e9c9:  jsr     _00ea14
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [  ]

_00e9cf:
@e9cf:  pha
        pha
        and     #$e0
        sta     $06
        pla
        and     #$0f
        asl
        sec
        adc     $06
        sta     $83
        pla
        and     #$10
        beq     @e9e5
        lda     #$07
@e9e5:  sta     $82
        stz     $79
        stz     $81
@e9eb:  jsr     WaitFrame
        stz     $212d
        lda     #$83
        sta     $2131
        lda     $83
        and     #$e0
        ora     $81
        sta     $2132
        inc     $79
        lda     $79
        and     $82
        bne     @e9eb
        inc     $81
        lda     $83
        and     #$1f
        cmp     $81
        bne     @e9eb
        dec     $81
        rts

; ------------------------------------------------------------------------------

; [  ]

_00ea14:
@ea14:  stz     $79
@ea16:  jsr     WaitFrame
        lda     $83
        and     #$e0
        ora     $81
        sta     $2132
        inc     $79
        lda     $79
        and     $82
        bne     @ea16
        dec     $81
        bpl     @ea16
        stz     $81
        lda     #$11
        sta     $212d
        lda     $0fe4
        lsr
        bcc     @ea48
        lda     #$02
        sta     $2130
        lda     #$43
        sta     $2131
        jmp     @ea4b
@ea48:  stz     $2131
@ea4b:  rts

; ------------------------------------------------------------------------------

; [ event command $da: fade in/out ]

EventCmd_da:
@ea4c:  lda     $80
        bne     @ea58
        lda     #$07
        jsr     FadeIn
        jmp     WaitVblankEvent
@ea58:  lda     #$07
        jsr     FadeOut
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $e2: give spell ]

EventCmd_e2:
@ea60:  inx
        lda     $09d5,x
        longa
        asl3
        sta     $18
        asl
        clc
        adc     $18
        tay
        lda     #$0000
        shorta
@ea75:  lda     $1560,y
        beq     @ea7e
        iny
        jmp     @ea75
@ea7e:  jsr     GetNextEventByte
        sta     $1560,y
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $de: restore hp ]

EventCmd_de:
@ea87:  jsr     GetNextEventByte
        cmp     #$fe
        beq     @eac7
        sta     $18
        stz     $19
        lda     #$0a
        sta     $1a
        stz     $1b
        jsl     Mult16
        ldx     #0
@ea9f:  lda     $1003,x
        bmi     @eabc
        longa
        lda     $1007,x
        clc
        adc     $30
        cmp     $1009,x
        bcc     @eab4
        lda     $1009,x
@eab4:  sta     $1007,x
        lda     #0
        shorta
@eabc:  jsr     NextChar
        cpx     #$0140
        bne     @ea9f
        jmp     WaitVblankEvent
@eac7:  ldx     #0
@eaca:  lda     $1003,x
        bmi     @eadc
        longa
        lda     $1009,x
        sta     $1007,x
        lda     #0
        shorta
@eadc:  jsr     NextChar
        cpx     #$0140
        bne     @eaca
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $df: restore mp ]

EventCmd_df:
@eae7:  jsr     GetNextEventByte
        cmp     #$fe
        beq     @eb27
        sta     $18
        stz     $19
        lda     #$0a
        sta     $1a
        stz     $1b
        jsl     Mult16
        ldx     #0
@eaff:  lda     $1003,x
        bmi     @eb1c
        longa
        lda     $100b,x
        clc
        adc     $30
        cmp     $100d,x
        bcc     @eb14
        lda     $100d,x
@eb14:  sta     $100b,x
        lda     #0
        shorta
@eb1c:  jsr     NextChar
        cpx     #$0140
        bne     @eaff
        jmp     WaitVblankEvent
@eb27:  ldx     #0
@eb2a:  lda     $1003,x
        bmi     @eb3c
        longa
        lda     $100d,x
        sta     $100b,x
        lda     #0
        shorta
@eb3c:  jsr     NextChar
        cpx     #$0140
        bne     @eb2a
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $e0: give item ]

EventCmd_e0:
@eb47:  jsr     GetNextEventByte
        sta     $08fb
        jsr     GiveItem
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $e1: take item ]

EventCmd_e1:
@eb53:  jsr     GetNextEventByte
        sta     $06
        ldy     #0
@eb5b:  lda     $1440,y
        cmp     $06
        beq     @eb87
        iny2
        cpy     #$0060
        bne     @eb5b
        ldx     #0
@eb6c:  lda     $1033,x
        cmp     $06
        beq     @eb7e
        jsr     NextChar
        cpx     #$0140
        bne     @eb6c
        jmp     WaitVblankEvent
@eb7e:  stz     $1033,x
        stz     $1034,x
        jmp     WaitVblankEvent
@eb87:  lda     #$00
        sta     $1440,y
        sta     $1441,y
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $db: toggle status ]

EventCmd_db:
@eb92:  jsr     GetNextEventByte
        sta     $06
        ldx     #0
@eb9a:  lda     $1003,x
        eor     $06
        sta     $1003,x
        jsr     NextChar
        cpx     #$0140
        bne     @eb9a
        lda     #$01
        sta     $cc
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $e3: clear status ]

EventCmd_e3:
@ebb1:  jsr     GetNextEventByte
        sta     $06
        ldx     #0
@ebb9:  lda     $1003,x
        and     $06
        sta     $1003,x
        jsr     NextChar
        cpx     #$0140
        bne     @ebb9
        lda     #$01
        sta     $cc
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $e4: set status ]

EventCmd_e4:
@ebd0:  jsr     GetNextEventByte
        sta     $06
        ldx     #0
@ebd8:  lda     $1003,x
        ora     $06
        sta     $1003,x
        jsr     NextChar
        cpx     #$0140
        bne     @ebd8
        lda     #$01
        sta     $cc
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $e5: give gp ]

EventCmd_e5:
@ebef:  jsr     GetNextEventByte
        sta     $18
        stz     $19
        lda     #100
        sta     $1a
        stz     $1b
        jsl     Mult16
        jsr     GiveGil
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $e6: take gp ]

EventCmd_e6:
@ec06:  jsr     GetNextEventByte
        sta     $18
        stz     $19
        lda     #100
        sta     $1a
        stz     $1b
        jsl     Mult16
        lda     $16a0
        sec
        sbc     $30
        sta     $16a0
        lda     $16a1
        sbc     $31
        sta     $16a1
        lda     $16a2
        sbc     $32
        sta     $16a2
        bcs     @ec3b
        stz     $16a0
        stz     $16a1
        stz     $16a2
@ec3b:  jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $dd: set player graphic ]

EventCmd_dd:
@ec3e:  jsr     GetNextEventByte
        sta     $06
        ldx     #0
        ldy     #0
@ec49:  lda     $1000,y
        and     #$1f
        cmp     $06
        beq     @ec63
        longa
        tya
        clc
        adc     #$0040
        tay
        lda     #0
        shorta
        inx
        jmp     @ec49
@ec63:  txa
        sta     $1703
        lda     #1
        sta     $cc
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $dc: inn ]

EventCmd_dc:
@ec6e:  jsr     GetNextEventByte
        asl
        tax
        lda     InnGilTbl,x     ; gp amount
        sta     $08f8
        lda     InnGilTbl+1,x
        sta     $08f9
        stz     $08fa
        lda     #$1a        ; inn welcome message
        sta     $b2
        jsr     GetDlgPtr1L
        jsr     OpenDlgWindow
        jsr     GetCurrGil
        jsl     HexToDec
        jsr     SetCurrGil
        jsr     OpenGilWindow
        jsr     ShowYesNoWindow
        jsr     CloseGilWindow
        jsr     CloseDlgWindow
        jsr     WaitVblankShort
        jsr     HideDlgWindow
        lda     $db
        beq     @ecbf
        lda     #$1b        ; また　おこしください。 (please come again)
        sta     $b2
        jsr     GetDlgPtr1L
        jsr     OpenDlgWindow
        jsr     CloseDlgWindow
        jsr     HideDlgWindow
        jmp     @ecf3
@ecbf:  jsr     GetCurrGil
        ldx     $b3
        lda     $09d5,x
        asl
        tax
        lda     $16a0
        sec
        sbc     InnGilTbl,x
        sta     $30
        lda     $16a1
        sbc     InnGilTbl+1,x
        sta     $31
        lda     $16a2
        sbc     #$00
        sta     $32
        bcs     @ecf9
        lda     #$19        ; おきゃくさん　おかねが　たりませんよ。 (not enough money)
        sta     $b2
        jsr     GetDlgPtr1L
        jsr     OpenDlgWindow
        jsr     CloseDlgWindow
        jsr     HideDlgWindow
@ecf3:  jsr     FindEventTerminator
        jmp     WaitVblankEvent
@ecf9:  lda     $30
        sta     $16a0
        lda     $31
        sta     $16a1
        lda     $32
        sta     $16a2
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; inn prices
InnGilTbl:
@ed0b:  .word   50,100,200,400,500,600,700,300,1200

; ------------------------------------------------------------------------------

; [ set current gil ]

SetCurrGil:
@ed1d:  lda     $30
        sta     $08f8
        lda     $31
        sta     $08f9
        lda     $32
        sta     $08fa
        rts

; ------------------------------------------------------------------------------

; [ get current gp ]

GetCurrGil:
@ed2d:  lda     $16a0       ; current gp
        sta     $30
        lda     $16a1
        sta     $31
        lda     $16a2
        sta     $32
        rts

; ------------------------------------------------------------------------------

; [ event command $e9: pause ]

EventCmd_e9:
@ed3d:  jsr     GetNextEventByte
        sta     $89
        stz     $8a
        asl     $89         ; multiply by 8
        rol     $8a
        asl     $89
        rol     $8a
        asl     $89
        rol     $8a
@ed50:  jsr     WaitVblankLong
        lda     $1700
        cmp     #$03
        beq     @ed60
        jsr     DrawWorldSprites
        jmp     @ed67
@ed60:  jsl     DrawPlayerSub
        jsr     DrawNPCs
@ed67:  ldx     $89
        dex
        stx     $89
        bne     @ed50
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $f8: show dialogue (yes/no) ]

EventCmd_f8:
@ed71:  jsr     GetNextEventByte
        sta     $b2
        jsr     GetDlgPtr1H
        jsr     OpenDlgWindow
        jsr     ShowYesNoWindow
        jsr     CloseDlgWindow
        jsr     WaitVblankShort
        jsr     HideDlgWindow
        lda     $db
        beq     @ed93
        jsr     FindEventTerminator
        inx
        stx     $09d3
@ed93:  jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $f7: select item ]

EventCmd_f7:
@ed96:  inx
        stx     $b3
        jsr     ShowItemWindow
        jsr     WaitVblankShort
        jsr     HideDlgWindow
        lda     $08fb
        cmp     #$ff
        beq     @edc0
        ldx     $b3
        lda     $09d5,x
        cmp     $08fb
        beq     @edc6
        lda     #$14
        sta     $b2
        jsr     GetDlgPtr1L
        jsr     OpenDlgWindow
        jsr     CloseDlgWindow
@edc0:  jsr     FindEventTerminator
        jmp     WaitVblankEvent
@edc6:  cmp     #$ec
        beq     @edea
        cmp     #$fe
        bcs     @edd2
        cmp     #$ed
        bcs     @edea
@edd2:  ldx     #0
@edd5:  lda     $1440,x
        cmp     $08fb
        beq     @ede2
        inx2
        jmp     @edd5
@ede2:  dec     $1441,x
        bne     @edea
        stz     $1440,x
@edea:  jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $d6:  ]

EventCmd_d6:
@eded:  jsr     WaitVblankShort
        jsr     _00edf6
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [  ]

_00edf6:
@edf6:  jsr     Rand
        cmp     #$80
        bcs     @ee1b
        lda     $5c
        clc
        adc     #$08
        sta     $210e
        lda     $5d
        adc     #$00
        sta     $210e
        lda     $60
        clc
        adc     #$08
        sta     $2110
        lda     $61
        adc     #$00
        sta     $2110
@ee1b:  rts

; ------------------------------------------------------------------------------

; [ event command $d0: shake screen ]

EventCmd_d0:
@ee1c:  lda     $e3
        eor     #$01
        sta     $e3
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $d1: flash screen ]

EventCmd_d1:
@ee25:  lda     #$02
        sta     $79
@ee29:  inc     $c4
        jsr     WaitVblankShort
        dec     $79
        bne     @ee29
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ transfer inverted palette to ppu ]

TfrInvertPal:
@ee35:  stz     $420b
        stz     $2121
        lda     #$02
        sta     $4300
        lda     #$22
        sta     $4301
        lda     #$00
        sta     $4304
        ldx     #$0bdb
        stx     $4302
        ldx     #$0100
        stx     $4305
        lda     #$01
        sta     $420b
        rts

; ------------------------------------------------------------------------------

; [ event command $d2: mosaic screen ]

EventCmd_d2:
@ee5c:  stz     $79
@ee5e:  jsr     WaitVblankShort
        lda     $79
        lsr
        tax
        lda     f:EventMosaicTbl,x
        sta     $2106
        inc     $79
        lda     $79
        cmp     #$40
        bne     @ee5e
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $d3:  ]

EventCmd_d3:
@ee77:  lda     $1700
        beq     @ee7f
        jmp     @ee85
@ee7f:  jsr     EarthToMoon
        jmp     @ee88
@ee85:  jsr     MoonToEarth
@ee88:  stz     $79
        stz     $7a
        stz     $7b
        lda     #$81
        sta     $4200       ; enable nmi
        jsr     WaitVblankShort
        lda     #$0f
        sta     $2100       ; screen on, full brightness
        cli
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ $d5: open secret door ]

EventCmd_d5:
@ee9f:  lda     $1706
        sec
        sbc     #$07
        sta     $3d
        lda     $1707
        sec
        sbc     #$07
        bpl     @eeb9
        clc
        adc     #$0f
        sta     $07
        stz     $3e
        jmp     @eec1
@eeb9:  and     #$1f
        sta     $3e
        lda     #$0f
        sta     $07
@eec1:  ldx     $3d
        ldy     #$0010
@eec6:  lda     $7f5c71,x
        cmp     #$60
        beq     @eee1
        inx
        dey
        bne     @eec6
        inc     $3e
        lda     $3e
        cmp     #$20
        bcs     @eede
        dec     $07
        bne     @eec1
@eede:  jmp     @ef42
@eee1:  stx     $3d
        lda     #$64
        sta     $7f5c71,x
        inc
        sta     $7f5c72,x
        inc
        sta     $7f5d71,x
        inc
        sta     $7f5d72,x
        jsr     DrawSecretDoor
        ldx     #0
        ldy     #0
@ef01:  longa
        lda     $7f48c8,x
        sta     $0a27,y
        lda     $7f49c8,x
        sta     $0a29,y
        lda     $7f4ac8,x
        sta     $0a2f,y
        lda     $7f4bc8,x
        sta     $0a31,y
        lda     #0
        shorta
        inx2
        tya
        and     #$07
        beq     @ef30
        tya
        clc
        adc     #8
        tay
@ef30:  iny4
        cpx     #8
        bne     @ef01
        lda     #1        ; enable vram transfer
        sta     $e2
        lda     #$31
        jsr     PlaySfx
@ef42:  jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ draw secret door ]

DrawSecretDoor:
@ef45:  lda     $3d
        sta     $0c
        lda     $3e
        sta     $0e
        jsr     GetBG1VRAMPtr
        stx     $0a17
        stx     $0a1b
        lda     $0a17
        clc
        adc     #$20
        sta     $0a1b
        inc     $0c
        jsr     GetBG1VRAMPtr
        stx     $0a19
        stx     $0a1d
        lda     $0a19
        clc
        adc     #$20
        sta     $0a1d
        inc     $0e
        jsr     GetBG1VRAMPtr
        stx     $0a21
        stx     $0a25
        lda     $0a21
        clc
        adc     #$20
        sta     $0a25
        dec     $0c
        jsr     GetBG1VRAMPtr
        stx     $0a1f
        stx     $0a23
        lda     $0a1f
        clc
        adc     #$20
        sta     $0a23
        rts

; ------------------------------------------------------------------------------

; [ transfer secret door tilemap to vram ]

TfrSecretDoor:
@ef9c:  lda     $e2
        bne     @efa1       ; return if no secret door update needed
        rts
@efa1:  stz     $e2
        lda     #$80
        sta     $2115
        ldx     $0a17
        stx     $2116
        ldx     $0a27
        stx     $2118
        ldx     $0a29
        stx     $2118
        ldx     $0a19
        stx     $2116
        ldx     $0a2b
        stx     $2118
        ldx     $0a2d
        stx     $2118
        ldx     $0a1b
        stx     $2116
        ldx     $0a2f
        stx     $2118
        ldx     $0a31
        stx     $2118
        ldx     $0a1d
        stx     $2116
        ldx     $0a33
        stx     $2118
        ldx     $0a35
        stx     $2118
        ldx     $0a1f
        stx     $2116
        ldx     $0a37
        stx     $2118
        ldx     $0a39
        stx     $2118
        ldx     $0a21
        stx     $2116
        ldx     $0a3b
        stx     $2118
        ldx     $0a3d
        stx     $2118
        ldx     $0a23
        stx     $2116
        ldx     $0a3f
        stx     $2118
        ldx     $0a41
        stx     $2118
        ldx     $0a25
        stx     $2116
        ldx     $0a43
        stx     $2118
        ldx     $0a45
        stx     $2118
        rts

; ------------------------------------------------------------------------------

; [ event command $fe: load map ]

EventCmd_fe:
@f039:  lda     $09d6,x
        cmp     #$fb
        bcs     @f087
        jsr     PushMapStack
        stz     $1704
        lda     $09d6,x
        sta     $1702
        lda     $09d7,x
        and     #$3f
        sta     $1706
        lda     $09d7,x
        and     #$c0
        lsr6
        sta     $1705
        lda     $09d8,x
        sta     $1707
        lda     $09d9,x
        and     #$20
        beq     @f073
        lda     #$01
        sta     $ca
@f073:  lda     $09d9,x
        bmi     @f07d
        lda     #$00
        jmp     @f07f
@f07d:  lda     #$01
@f07f:  sta     $1701
        lda     #$03
        jmp     @f0c4
@f087:  sec
        sbc     #$fb
        pha
        lda     $09d7,x
        sta     $1706
        lda     $09d8,x
        sta     $1707
        lda     $09d9,x
        and     #$40
        sta     $e1
        lda     $09d9,x
        and     #$20
        beq     @f0a9
        lda     #$01
        sta     $ca
@f0a9:  lda     $09d9,x
        and     #$1f
        dec
        bne     @f0bd
        lda     $172f
        sta     $1706
        lda     $1730
        sta     $1707
@f0bd:  ldx     #0
        stx     $172c
        pla
@f0c4:  jsr     _00f167
        lda     $1700
        cmp     #$03
        beq     @f14d
        ldx     $b3
        lda     $09d9,x     ; vehicle id
; no vehicle
        and     #$1f
        bne     @f0e1
        stz     $1704       ; no vehicle
        stz     $ac
        stz     $7b
        jmp     @f14d
; chocobo
@f0e1:  dec
        bne     @f0ef
        lda     #$01
        sta     $170f
        jsr     BoardChoco
        jmp     @f14d
; black chocobo
@f0ef:  dec
        bne     @f100
        lda     #$01
        sta     $1712
        stz     $1715
        jsr     BoardBkChoco
        jmp     @f14d
; hovercraft
@f100:  dec
        bne     @f10e
        lda     #$01
        sta     $1718
        jsr     BoardHover
        jmp     @f14d
; enterprise
@f10e:  dec
        bne     @f11c
        lda     #$01
        sta     $171c
        jsr     BoardEnterprise
        jmp     @f14d
; falcon
@f11c:  dec
        bne     @f12a
        lda     #$01
        sta     $1720
        jsr     BoardFalcon
        jmp     @f14d
; big whale
@f12a:  dec
        bne     @f138
        lda     #$01
        sta     $1724       ; make big whale visible
        jsr     BoardWhale
        jmp     @f14d
; ship
@f138:  lda     #$01
        sta     $1728
        ldx     $b3
        lda     $09d9,x     ; facing direction
        and     #$18
        lsr3
        sta     $1705
        jsr     BoardShip
@f14d:  stz     $79
        stz     $7a
        stz     $7b
        lda     #$81
        sta     $4200       ; enable nmi
        jsr     WaitFrame
        cli
        ldx     $b3
        inx4
        stx     $b3
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [  ]

_00f167:
@f167:  pha
        lda     $ca
        bne     @f172
        jsr     WipeOut
        jmp     @f17b
@f172:  lda     $80
        beq     @f17b
        lda     #$00
        jsr     FadeOut
@f17b:  pla
        sta     $1700
        bne     @f187
        jsr     LoadOverworld
        jmp     @f19e
@f187:  cmp     #$01
        bne     @f191
        jsr     LoadUnderground
        jmp     @f19e
@f191:  cmp     #$02
        bne     @f19b
        jsr     LoadMoon
        jmp     @f19e
@f19b:  jsr     LoadSubMap
@f19e:  lda     $ca
        bne     @f1a8
        jsr     WipeIn
        jmp     @f1aa
@f1a8:  inc     $ca
@f1aa:  lda     #$81
        sta     $4200       ; enable nmi
        rts

; ------------------------------------------------------------------------------

; [ event command $ef: display map dialogue (bank 0) ]

EventCmd_ef:
@f1b0:  jsr     GetNextEventByte
        sta     $b2
        jsr     GetDlgPtr0
        jsr     OpenDlgWindow
        jsr     CloseDlgWindow
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $ee: display npc dialogue (bank 0) ]

EventCmd_ee:
@f1c1:  jsr     GetNextEventByte
        tax
        lda     $0a49,x     ; npc dialogue id
        sta     $b2
        jsr     GetDlgPtr0
        jsr     OpenDlgWindow
        jsr     CloseDlgWindow
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $f0: display event dialogue (bank 1 low) ]

EventCmd_f0:
@f1d6:  jsr     GetNextEventByte
        sta     $b2
        jsr     GetDlgPtr1L
        jsr     OpenDlgWindow
        jsr     CloseDlgWindow
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $f1: display event dialogue (bank 1 high) ]

EventCmd_f1:
@f1e7:  jsr     GetNextEventByte
        sta     $b2
        jsr     GetDlgPtr1H
        jsr     OpenDlgWindow
        jsr     CloseDlgWindow
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $f6: display event dialogue (bank 2) ]

EventCmd_f6:
@f1f8:  jsr     GetNextEventByte
        sta     $b2
        jsr     GetDlgPtr2
        jsr     OpenDlgWindow
        jsr     CloseDlgWindow
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $f2: set event switch ]

EventCmd_f2:
@f209:  jsr     GetNextEventByte
        jsr     SetEventSwitch
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $f3: clear event switch ]

EventCmd_f3:
@f212:  jsr     GetNextEventByte
        jsr     ClearEventSwitch
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $f4: set npc switch ]

EventCmd_f4:
@f21b:  jsr     GetNextEventByte
        jsr     SetNPCSwitch
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ event command $f5: clear npc switch ]

EventCmd_f5:
@f224:  jsr     GetNextEventByte
        jsr     ClearNPCSwitch
        jmp     WaitVblankEvent

; ------------------------------------------------------------------------------

; [ execute trigger script ]

ExecTriggerScript:
@f22d:  stz     $3e
        asl
        rol     $3e
        sta     $3d
        ldx     $3d
        lda     f:TriggerScriptPtrs+2,x
        sta     $40
        lda     f:TriggerScriptPtrs+3,x
        sta     $41
        ldx     $40
        dex
@f245:  lda     f:TriggerScript,x
        cmp     #$ff
        beq     @f251
        dex
        jmp     @f245
@f251:  inx
        stx     $0a6b
        ldx     $3d
        lda     f:TriggerScriptPtrs,x
        sta     $be
        lda     f:TriggerScriptPtrs+1,x
        sta     $bf
@f263:  ldx     $be
        lda     f:TriggerScript,x
        cmp     #$ff
        bne     @f270
        jmp     @f2b3
@f270:  cmp     #$fe
        bne     @f287
        ldx     $be
        inx
        stx     $be
        lda     f:TriggerScript,x
        jsr     CheckEventSwitch
        cmp     #0
        beq     @f296
        jmp     @f28e
@f287:  jsr     CheckEventSwitch
        cmp     #0
        bne     @f296
@f28e:  ldx     $be
        inx
        stx     $be
        jmp     @f263
@f296:  ldx     $be
@f298:  inx
        lda     f:TriggerScript,x
        cmp     #$ff
        bne     @f298
        inx
        stx     $be
        ldx     $be
        cpx     $0a6b
        beq     @f2b3
        ldx     $be
        inx
        stx     $be
        jmp     @f263
@f2b3:  lda     #1
        sta     $b1
        stz     $ab
        ldx     $be
        lda     f:TriggerScript+1,x
        beq     @f2c4
        jsr     ExecEvent
@f2c4:  stz     $b1
        rts

; ------------------------------------------------------------------------------

; [ execute npc script ]

ExecNPCScript:
@f2c7:  stz     $3e
        asl
        rol     $3e
        sta     $3d
        lda     $0fe5
        bmi     @f2d8
        lda     $1701
        beq     @f2dc
@f2d8:  inc     $3e
        inc     $3e
@f2dc:  ldx     $3d
        lda     f:NPCScriptPtrs+2,x
        sta     $40
        lda     f:NPCScriptPtrs+3,x
        sta     $41
        ldx     $40
        dex
@f2ed:  lda     f:NPCScript,x
        cmp     #$ff
        beq     @f2f9
        dex
        jmp     @f2ed
@f2f9:  inx
        stx     $0a69
        inx
        ldy     #0
@f301:  cpx     $40
        beq     @f311
        lda     f:NPCScript,x
        sta     $0a49,y
        iny
        inx
        jmp     @f301
@f311:  ldx     $3d
        lda     f:NPCScriptPtrs,x
        sta     $bc
        lda     f:NPCScriptPtrs+1,x
        sta     $bd
@f31f:  ldx     $bc
        lda     f:NPCScript,x
        cmp     #$ff
        bne     @f32c
        jmp     @f364
@f32c:  cmp     #$fe
        bne     @f343
        ldx     $bc
        inx
        stx     $bc
        lda     f:NPCScript,x
        jsr     CheckEventSwitch
        cmp     #0
        beq     @f352
        jmp     @f34a
@f343:  jsr     CheckEventSwitch
        cmp     #0
        bne     @f352
@f34a:  ldx     $bc
        inx
        stx     $bc
        jmp     @f31f
@f352:  jsr     GetNPCScriptByte
        ldx     $bc
        cpx     $0a69
        beq     @f364
        ldx     $bc
        inx
        stx     $bc
        jmp     @f31f
@f364:  lda     #1
        sta     $b1
        stz     $ab
        ldx     $bc
        lda     f:NPCScript+1,x
        beq     @f375
        jsr     ExecEvent
@f375:  stz     $b1
        rts

; ------------------------------------------------------------------------------

; [ get next byte of npc script ]

GetNPCScriptByte:
@f378:  ldx     $bc
@f37a:  inx
        lda     f:NPCScript,x
        cmp     #$ff
        bne     @f37a
        inx
        stx     $bc
        rts

; ------------------------------------------------------------------------------

; [ clear event switch ]

ClearEventSwitch:
@f387:  jsr     GetEventSwitchOffset
        lda     #$fe
@f38c:  cpy     #0
        beq     @f397
        sec
        rol
        dey
        jmp     @f38c
@f397:  ldx     $3d
        and     $1280,x
        sta     $1280,x
        rts

; ------------------------------------------------------------------------------

; [ clear npc switch ]

ClearNPCSwitch:
@f3a0:  jsr     GetNPCSwitchOffset
        lda     #$fe
@f3a5:  cpy     #0
        beq     @f3b0
        sec
        rol
        dey
        jmp     @f3a5
@f3b0:  ldx     $3d
        and     f:$0012e0,x
        sta     f:$0012e0,x
        rts

; ------------------------------------------------------------------------------

; [ set event switch ]

SetEventSwitch:
@f3bb:  jsr     GetEventSwitchOffset
        lda     #$01
@f3c0:  cpy     #0
        beq     @f3ca
        asl
        dey
        jmp     @f3c0
@f3ca:  ldx     $3d
        ora     $1280,x
        sta     $1280,x
        rts

; ------------------------------------------------------------------------------

; [ set npc switch ]

SetNPCSwitch:
@f3d3:  jsr     GetNPCSwitchOffset
        lda     #1
@f3d8:  cpy     #0
        beq     @f3e2
        asl
        dey
        jmp     @f3d8
@f3e2:  ldx     $3d
        ora     f:$0012e0,x
        sta     f:$0012e0,x
        rts

; ------------------------------------------------------------------------------

; [ check event switch ]

; a: event bit index

CheckEventSwitch:
@f3ed:  phx
        jsr     GetEventSwitchOffset
        ldx     $3d
        lda     $1280,x
@f3f6:  cpy     #0
        beq     @f400
        lsr
        dey
        jmp     @f3f6
@f400:  lsr
        lda     #0
        adc     #0
        plx
        rts

; ------------------------------------------------------------------------------

; [ get event switch offset ]

;    a: switch id
;    y: bit index (out)
; +$3d: byte offset (out)

GetEventSwitchOffset:
@f407:  pha
        lsr3
        sta     $3d
        stz     $3e
        pla
        and     #$07
        tay
        rts

; ------------------------------------------------------------------------------

; [ get npc switch offset ]

;    a: switch id
;    y: bit index (out)
; +$3d: byte offset (out)

GetNPCSwitchOffset:
@f414:  pha
        lsr3
        sta     $3d
        stz     $3e
        lda     $0fe5
        bmi     @f426
        lda     $1701
        beq     @f42d
@f426:  lda     $3d
        clc
        adc     #$20
        sta     $3d
@f42d:  pla
        and     #$07
        tay
        rts

; ------------------------------------------------------------------------------
