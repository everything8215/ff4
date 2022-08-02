
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: trigger.asm                                                          |
; |                                                                            |
; | description: trigger routines                                              |
; |                                                                            |
; | created: 3/26/2022                                                         |
; +----------------------------------------------------------------------------+

.import TreasureMenu_ext

; ------------------------------------------------------------------------------

.pushseg

.if LANG_EN
.segment "world_triggers"
.else
.segment "triggers"
.endif

; 15/8000
WorldTriggersPtrs:
        .addr   WorldTriggers1-WorldTriggers
        .addr   WorldTriggers2-WorldTriggers
        .addr   WorldTriggers3-WorldTriggers
WorldTriggers:
        ; make_ptr_tbl_rel WorldTriggers, 3
        .include "data/world_triggers1.asm"
        .include "data/world_triggers2.asm"
        .include "data/world_triggers3.asm"

.segment "triggers"
.align $80

MapTriggersPtrs:
        make_ptr_tbl_rel MapTriggers1, $0100
        make_ptr_tbl_rel MapTriggers2, $80, MapTriggers1

; 15/8200
.if LANG_EN
        .include "data/map_triggers1_en.asm"
        .include "data/map_triggers2_en.asm"

; in the english translation, there is 1 byte of stale data carried over
; from the japanese ROM at 15/961F
.if BYTE_PERFECT
        .byte   $80
.endif

.else
        .include "data/map_triggers1_jp.asm"
        .include "data/map_triggers2_jp.asm"
.endif

.popseg

; ------------------------------------------------------------------------------

; [ do poison damage ]

DoPoisonDmg:
@97b3:  stz     $c2
        lda     $1704
        bne     @97fe
        ldx     #0
@97bd:  lda     $1000,x
        beq     @97e9
        lda     $1003,x
        and     #$01
        beq     @97e9
        inc     $c2
        longa
        lda     $1007,x
        beq     @97e4
        sec
        sbc     #1
        sta     $1007,x
        cmp     #1
        bcs     @97e4
        lda     #1
        sta     $1007,x
@97e4:  lda     #0
        shorta
@97e9:  jsr     NextChar
        cpx     #$0140
        bne     @97bd
        lda     $c2
        beq     @97fe
        lda     $b1
        bne     @97fe
        lda     #$7a
        jsr     PlaySfx
@97fe:  rts

; --------------------------------------------------------------------------

; [ do floor damage ]

DoFloorDmg:
@97ff:  stz     $c1
        lda     $a2
        and     #$01
        beq     @9842
        ldx     #0
@980a:  lda     $1000,x
        beq     @983a
        lda     $1003,x
        bmi     @983a
        lda     $1004,x
        and     #$40
        bne     @983a
        inc     $c1
        longa
        lda     $1007,x
        beq     @9835
        sec
        sbc     #50
        sta     $1007,x
        beq     @982f
        bcs     @9835
@982f:  lda     #1
        sta     $1007,x
@9835:  lda     #0
        shorta
@983a:  jsr     NextChar
        cpx     #$0140
        bne     @980a
@9842:  lda     $c1
        beq     @984b
        lda     #$7b
        jsr     PlaySfx
@984b:  rts

; --------------------------------------------------------------------------

; [ check treasures and npcs ]

CheckTreasureNPC:
@984c:  lda     $b1
        bne     @9876
        lda     $5a
        and     #$0f
        bne     @9876
        lda     $5c
        and     #$0f
        bne     @9876
        lda     $02
        and     #JOY_A
        bne     @9863
        rts
@9863:  lda     $54
        beq     @9868
        rts
@9868:  inc     $54
        lda     $ea                     ; close map name window
        bne     @9870
        inc     $ea
@9870:  jsr     CheckTreasure
        jsr     CheckNPCs
@9876:  rts

; --------------------------------------------------------------------------

; [ check treasures ]

CheckTreasure:
@9877:  lda     $1705                   ; facing direction
        bne     @988e

; up
        lda     $a4
        bpl     @98d2
        lda     $1706
        sta     $0c
        lda     $1707
        dec
        sta     $0e
        jmp     @98d3

; right
@988e:  lda     $1705
        cmp     #$01
        bne     @98a7
        lda     $a6
        bpl     @98d2
        lda     $1706
        inc
        sta     $0c
        lda     $1707
        sta     $0e
        jmp     @98d3

; down
@98a7:  lda     $1705
        cmp     #$02
        bne     @98c0
        lda     $a8
        bpl     @98d2
        lda     $1706
        sta     $0c
        lda     $1707
        inc
        sta     $0e
        jmp     @98d3

; left
@98c0:  lda     $aa
        bpl     @98d2
        lda     $1706
        dec
        sta     $0c
        lda     $1707
        sta     $0e
        jmp     @98d3
@98d2:  rts
@98d3:  lda     $0711
        bne     @98d9                   ; return if there are no treasures
        rts
@98d9:  jsr     GetTreasurePtr
        ldy     #0
        ldx     $3d
@98e1:  lda     f:MapTriggers1,x         ; pointers to triggers
        cmp     $0c
        bne     @98f4
        lda     f:MapTriggers1+1,x
        cmp     $0e
        bne     @98f4
        jmp     @9901
@98f4:  inx5                            ; next trigger
        iny
        tya
        cmp     $0711
        bne     @98e1
        rts
@9901:  stx     $40
        tya
        clc
        adc     $0fe7                   ; treasure offset
        sta     $08fc
        jsr     SetTreasureSwitch
        cmp     #0
        beq     @9915
        jmp     @99e2
@9915:  lda     $1705
        tax
        lda     $070c,x
        cmp     #$78
        bne     @9949
        lda     $0c
        sta     $3d
        lda     $0e
        sta     $3e
        ldx     $3d
        lda     #$77
        sta     $7f5c71,x
        jsr     GetBG1VRAMPtr
        stx     $06fe
        jsr     GetTreasureTiles
        lda     #$30
        jsr     PlaySfx
        lda     #$01
        sta     $d4
        lda     #1
        sta     $b2
        jmp     @9952
@9949:  lda     #$16
        sta     $b2
        lda     #$37
        jsr     PlaySfx
@9952:  ldx     $40
        lda     f:MapTriggers1+3,x
        sta     $09
        lda     f:MapTriggers1+4,x
        sta     $08
        lda     $09
        and     #$40
        beq     @999b
        lda     $08
        sta     $c6
        lda     $1701
        asl5
        sta     $08
        lda     $09
        and     #$1f
        clc
        adc     $08
        clc
        adc     #$c0
        sta     $1800                   ; set battle id
        lda     #$01
        sta     $1801
        jsr     GetBattleBG
        lda     #1                      ; enable battle
        sta     $85
        lda     #3
        sta     $b2
        jsr     GetDlgPtr1L
        jsr     OpenDlgWindow
        jsr     CloseDlgWindow
        rts
@999b:  lda     $09
        and     #$80
        beq     @99b3
        lda     $08
        sta     $08fb
        jsr     GetDlgPtr1L
        jsr     OpenDlgWindow
        jsr     CloseDlgWindow
        jsr     GiveItem
        rts
@99b3:  inc     $b2
        lda     $08
        and     #$7f
        sta     $18
        stz     $19
        lda     $08
        and     #$80
        bne     @99c9
        ldx     #10
        jmp     @99cc
@99c9:  ldx     #1000
@99cc:  stx     $1a
        jsl     Mult16
        jsr     SetCurrGil
        jsr     GiveGil
        jsr     GetDlgPtr1L
        jsr     OpenDlgWindow
        jsr     CloseDlgWindow
        rts
@99e2:  lda     $1705
        tax
        lda     $070c,x
        cmp     #$77
        bne     @99fa
        lda     #4
        sta     $b2
        jsr     GetDlgPtr1L
        jsr     OpenDlgWindow
        jsr     CloseDlgWindow
@99fa:  rts

; --------------------------------------------------------------------------

; [ give gil ]

GiveGil:
@99fb:  lda     $16a0
        clc
        adc     $30
        sta     $16a0
        lda     $16a1
        adc     $31
        sta     $16a1
        lda     $16a2
        adc     $32
        sta     $16a2
        cmp     #$98
        bcc     @9a35
        lda     $16a1
        cmp     #$96
        bcc     @9a35
        lda     $16a0
        cmp     #$7f
        bcc     @9a35
        lda     #$7f
        sta     $16a0
        lda     #$96
        sta     $16a1
        lda     #$98
        sta     $16a2
@9a35:  rts

; --------------------------------------------------------------------------

; [ give item ]

GiveItem:
@9a36:  lda     #$01
        sta     $06
        lda     $08fb
        cmp     #$60
        bcs     @9a49
        cmp     #$54
        bcc     @9a49
        lda     #$0a
        sta     $06
@9a49:  ldy     #0
@9a4c:  lda     $1440,y
        cmp     $08fb
        bne     @9a5b
        lda     $1441,y
        cmp     #$63
        bne     @9ace
@9a5b:  iny2
        cpy     #$0060
        bne     @9a4c
        ldy     #0
@9a65:  lda     $1440,y
        beq     @9ac8
        iny2
        cpy     #$0060
        beq     @9a74
        jmp     @9a65
@9a74:  lda     $08fb
        sta     $1804
        stz     $1805
        stz     $1806
        stz     $1807
        stz     $1808
        stz     $1809
        stz     $180a
        stz     $180b
        lda     #0
        jsr     FadeOut
        jsl     TreasureMenu_ext
        jsr     InitInterrupts
        ldx     #0
@9a9e:  stz     $1804,x
        inx
        cpx     #8
        bne     @9a9e
        jsl     InitHWRegs
        lda     #1
        sta     $c5
        jsr     ReloadSubMap
        jsr     ReloadNPCs
        cli
        lda     #$81                    ; enable nmi
        sta     hNMITIMEN
        jsl     DrawPlayerSub
        jsr     DrawNPCs
        lda     #$00
        jsr     FadeIn
        rts
@9ac8:  lda     $08fb
        sta     $1440,y
@9ace:  lda     $1441,y
        clc
        adc     $06
        cmp     #100
        bcc     @9ae5
        sec
        sbc     #99
        sta     $06
        lda     #99
        sta     $1441,y
        jmp     @9a49
@9ae5:  sta     $1441,y
        rts

; --------------------------------------------------------------------------

; [ get treasure chest tiles ]

GetTreasureTiles:
@9ae9:  longa
        lda     $7f48ee
        sta     $0700
        lda     $7f49ee
        sta     $0702
        lda     $7f4aee
        sta     $0704
        lda     $7f4bee
        sta     $0706
        lda     #$0000
        shorta
        rts

; --------------------------------------------------------------------------

; [ check treasure switch ]

CheckTreasureSwitch:
@9b0d:  jsr     GetTreasureID
        lda     $12a0,x
        sta     $07
@9b15:  lsr     $07
        dey
        bne     @9b15
        lda     #$00
        adc     #$00
        rts

; --------------------------------------------------------------------------

; [ set treasure switch ]

SetTreasureSwitch:
@9b1f:  jsr     GetTreasureID
        lda     #$01
@9b24:  dey
        beq     @9b2b
        asl
        jmp     @9b24
@9b2b:  sta     $06
        lda     $12a0,x
        and     $06
        sta     $07
        bne     @9b3f
        lda     $12a0,x
        clc
        adc     $06
        sta     $12a0,x
@9b3f:  lda     $07
        rts

; --------------------------------------------------------------------------

; [ get treasure switch id ]

GetTreasureID:
@9b42:  lda     $08fc
        lsr3
        tax
        lda     $1701
        beq     @9b53
        txa
        clc
        adc     #$20
        tax
@9b53:  lda     $08fc
        and     #$07
        inc
        tay
        rts

; --------------------------------------------------------------------------

; [ get pointer to treasure properties ]

GetTreasurePtr:
@9b5b:  lda     $1702
        sta     $3d
        stz     $3e
        asl     $3d
        rol     $3e
        lda     $1701
        beq     @9b6f
        inc     $3e
        inc     $3e
@9b6f:  ldx     $3d
        lda     f:MapTriggersPtrs,x
        sta     $3d
        lda     f:MapTriggersPtrs+1,x
        sta     $3e
        rts

; --------------------------------------------------------------------------

; [ init map treasures ]

InitTreasures:
@9b7e:  lda     $0711
        bne     @9b84                   ; return if there are no treasures
        rts
@9b84:  jsr     GetTreasurePtr
        ldy     #0
@9b8a:  ldx     $3d
        tya
        clc
        adc     $0fe7                   ; treasure offset
        sta     $08fc
        phy
        jsr     CheckTreasureSwitch
        ply
        cmp     #0
        beq     @9bbb
        ldx     $3d
        lda     f:MapTriggers1,x
        sta     $18
        lda     f:MapTriggers1+1,x
        sta     $19
        ldx     $18
        lda     $7f5c71,x
        cmp     #$78
        bne     @9bbb
        lda     #$77
        sta     $7f5c71,x
@9bbb:  ldx     $3d
        inx5
        stx     $3d
        iny
        tya
        cmp     $0711
        beq     @9bce
        jmp     @9b8a
@9bce:  rts

; --------------------------------------------------------------------------

; [ check triggers (sub-map) ]

CheckTriggerSub:
@9bcf:  stz     $cd
        lda     $ab
        bne     @9bd7
        stz     $7b
@9bd7:  lda     $ac
        tax
        lda     $7b
        and     TriggerRateTbl,x        ; trigger check frequency
        beq     @9be4
        stz     $d5                     ; disable player control
        rts
@9be4:  lda     #$01                    ; enable player control
        sta     $d5
        jsr     UpdateLocalTiles
        lda     $a1
        and     #$08
        sta     $1a02
        lda     $1706
        bmi     @9c04
        cmp     #$20
        bcs     @9c04
        lda     $1707
        bmi     @9c04
        cmp     #$20
        bcc     @9c07
@9c04:  inc     $d1
        rts
@9c07:  lda     $a2
        bmi     @9c1c
        lda     $a2
        and     #$10
        bne     @9c1c
        lda     $a1
        and     #$08
        bne     @9c1c
        lda     #$01
        sta     $d6
        rts
@9c1c:  lda     $d6
        bne     @9c21
        rts
@9c21:  stz     $d6
        lda     $a1
        and     #$08
        beq     @9c35
        lda     #$01
        sta     $b1
        lda     #$76
        jsr     ExecEvent
        stz     $b1
        rts
@9c35:  lda     $a2
        bmi     @9c3c
        inc     $d1
        rts
@9c3c:  lda     $1702
        sta     $3d
        stz     $3e
        asl     $3d
        rol     $3e
        lda     $1701
        beq     @9c50
        inc     $3e
        inc     $3e
@9c50:  ldx     $3d
        lda     f:MapTriggersPtrs,x     ; pointers to sub-map triggers
        sta     $3d
        lda     f:MapTriggersPtrs+1,x
        sta     $3e
        ldx     $3d
@9c60:  lda     f:MapTriggers1,x
        cmp     $1706
        bne     @9c72
        lda     f:MapTriggers1+1,x
        cmp     $1707
        beq     @9c7a
@9c72:  inx5
        jmp     @9c60
@9c7a:  lda     f:MapTriggers1+2,x
        cmp     #$ff
        bne     @9c8a
        lda     f:MapTriggers1+3,x
        jsr     ExecTriggerScript
        rts
@9c8a:  jsr     PushMapStack
        lda     f:MapTriggers1+2,x
        cmp     #$fb
        bcs     @9cc2
        sta     $1702
        lda     f:MapTriggers1+3,x
        and     #$3f
        sta     $1706
        lda     f:MapTriggers1+3,x
        and     #$c0
        lsr6
        sta     $1705
        lda     f:MapTriggers1+4,x
        sta     $1707
        jsr     WipeOut
        lda     #$03
        sta     $1700
        inc     $cd
        rts
@9cc2:  phx
        jsr     FadeOutSongFast
        jsr     WipeOut
        plx
        lda     f:MapTriggers1+2,x
        sec
        sbc     #$fb
        sta     $1700
        lda     f:MapTriggers1+3,x
        sta     $1706
        lda     f:MapTriggers1+4,x
        sta     $1707
        inc     $cd
        ldx     #$0000
        stx     $172c
        rts

; --------------------------------------------------------------------------

; [ push map to stack ]

PushMapStack:
@9ceb:  phx
        ldx     $172c
        lda     $1700
        cmp     #$03
        bne     @9d0f
        lda     $1702
        sta     $172e,x
        lda     $1705
        asl6
        clc
        adc     $1706
        sta     $172f,x
        jmp     @9d1e
@9d0f:  lda     $1700
        clc
        adc     #$fb
        sta     $172e,x
        lda     $1706
        sta     $172f,x
@9d1e:  lda     $1707
        sta     $1730,x
        inx3
        cpx     #$00c0
        bcc     @9d2f
        ldx     #0
@9d2f:  stx     $172c
        plx
        rts

; --------------------------------------------------------------------------

; [ check triggers (world map) ]

CheckTriggerWorld:
@9d34:  stz     $cd
        lda     $ab
        bne     @9d3c
        stz     $7b
@9d3c:  lda     $ac
        tax
        lda     $7b
        and     TriggerRateTbl,x        ; check if between tiles
        beq     @9d49
        stz     $d5                     ; disable player control
        rts
@9d49:  lda     #1                      ; enable player control
        sta     $d5
        jsr     UpdateLocalTiles
        stz     $1a02
        lda     $1704
        bne     @9d5b
        inc     $1a02
@9d5b:  lda     $1704
        cmp     #$04
        bne     @9d81
        lda     $06b7
        cmp     #$10
        bne     @9d81
        lda     $1700
        cmp     #$00
        bne     @9d75
        lda     #$2d
        jmp     @9dd0
@9d75:  lda     $1700
        cmp     #$01
        bne     @9d81
        lda     #$2f
        jmp     @9dd0
@9d81:  lda     $a2
        bmi     @9d8a
        lda     #$01
        sta     $d6
        rts
@9d8a:  lda     $1704
        beq     @9d90
        rts
@9d90:  lda     $d6
        bne     @9d95
        rts
@9d95:  stz     $d6
        lda     $1700
        asl
        tax
        lda     f:WorldTriggersPtrs,x
        sta     $3d
        lda     f:WorldTriggersPtrs+1,x
        sta     $3e
        ldx     $3d
@9daa:  lda     f:WorldTriggers,x       ; check x position
        cmp     $1706
        bne     @9dbc
        lda     f:WorldTriggers+1,x     ; check y position
        cmp     $1707
        beq     @9dc4
@9dbc:  inx5
        jmp     @9daa

; player position matches trigger position
@9dc4:  lda     f:WorldTriggers+2,x
        cmp     #$ff
        bne     @9dd4                   ; branch not an event
        lda     f:WorldTriggers+3,x
@9dd0:  jsr     ExecTriggerScript
        rts
@9dd4:  phx
        ldx     $172c                   ; push current world map to stack
        lda     $1700
        beq     @9ddf
        lda     #$01
@9ddf:  sta     $1701
        lda     $1700
        clc
        adc     #$fb
        sta     $172e,x
        lda     f:$001706
        sta     $172f,x
        lda     $1707
        sta     $1730,x
        inx3
        cpx     #$00c0
        bcc     @9e03
        ldx     #0
@9e03:  stx     $172c
        plx
        lda     f:WorldTriggers+2,x     ; set destination map id
        sta     $1702
        lda     f:WorldTriggers+3,x     ; set x position
        and     #$3f
        sta     $1706
        lda     f:WorldTriggers+4,x     ; set y position
        sta     $1707
        lda     f:WorldTriggers+3,x     ; set facing direction
        and     #$c0
        lsr6
        sta     $1705
        jsr     FadeOutSongFast
        jsr     WipeOut
        inc     $cd
        lda     #3
        sta     $1700
        rts

; --------------------------------------------------------------------------
