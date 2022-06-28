
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: battle.asm                                                           |
; |                                                                            |
; | description: main battle program                                           |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

.p816

.include "const.inc"
.include "hardware.inc"
.include "macros.inc"
.include "battle_data.asm"

.import ExecBtlGfx_ext
.import ExecSound_ext

.export Battle_ext, Battle_ext2, UpdateEquip_ext

; ------------------------------------------------------------------------------

.segment "battle_prop"

; 0e/8000
        .include .sprintf("data/battle_prop_%s.asm", LANG_SUFFIX)

; ------------------------------------------------------------------------------

.segment "monster_prop"

; 0e/9000
        .include "data/monster_pos.asm"

; 0e/9800
        .include .sprintf("text/monster_name_%s.asm", LANG_SUFFIX)

; 0e/9f00
        .include .sprintf("data/monster_items_%s.asm", LANG_SUFFIX)

; 0e/a000
        .include .sprintf("data/monster_gil_%s.asm", LANG_SUFFIX)

; 0e/a1c0
        .include .sprintf("data/monster_xp_%s.asm", LANG_SUFFIX)

; 0e/a380
        .include "data/monster_stats.asm"

; 0e/a620
        .include .sprintf("data/monster_agility_%s.asm", LANG_SUFFIX)

; 0e/a6a0
MonsterPropPtrs:
        make_ptr_tbl_rel MonsterProp, $e0, .bankbyte(*)<<16

; 0e/a860
        .include .sprintf("data/monster_prop_%s.asm", LANG_SUFFIX)
        .res 230*16-(*-MonsterProp)

; 0e/b6c0
        .include .sprintf("data/ai_action2_%s.asm", LANG_SUFFIX)
        .res $0400-(*-AIAction2)

; 0e/bac0
        .include "data/monster_cursor.asm"
        .res 132*16-(*-MonsterCursor)

; ------------------------------------------------------------------------------

.segment "ai_data"

; 0e/e000
        .include .sprintf("data/ai_cond_hp_%s.asm", LANG_SUFFIX)

; 0e/e030
.align $10
        .include .sprintf("data/ai_script_%s.asm", LANG_SUFFIX)

; 2 bytes of stale data from the japanese version
.if LANG_EN .and BYTE_PERFECT
        .byte   $7d,$ff
.endif

; 0e/e600
.align $0100
        .include "data/ai_cond_script.asm"

; 0e/e700
.align $0100
        .include "data/ai_cond.asm"

; 0e/e900
.align $0100
        .include .sprintf("data/ai_action1_%s.asm", LANG_SUFFIX)

; ------------------------------------------------------------------------------

.segment "battle_code"

Battle_ext:
@8000:  jmp     ExecBattle

Battle_ext2:
@8003:  jmp     ExecBattle

UpdateEquip_ext:
@8006:  jmp     UpdateEquip_far

; ------------------------------------------------------------------------------

; [ execute battle ]

ExecBattle:
@8009:  php
        longai
        phb
        phd
        pha
        phx
        phy
        lda     #0
        shorta
        longi
        jsr     InitBattle
        lda     #0
        sta     f:hINIDISP              ; screen on, zero brightness
        sta     f:hHDMAEN               ; disable hdma
        sta     f:hMDMAEN               ; disable dma
        sta     f:hNMITIMEN             ; disable nmi and irq
        longai
        ply
        plx
        pla
        pld
        plb
        plp
        rtl

; ------------------------------------------------------------------------------

; [ update character equipment (external) ]

; a: character slot

UpdateEquip_far:
@8036:  sta     $7e3975
        php
        longai
        phb
        phd
        pha
        phx
        phy
        sei
        lda     #0
        shorta
        longi
        ldx     #0
        phx
        pld
        lda     #$7e
        pha
        plb
        jsr     UpdateEquip
        longai
        ply
        plx
        pla
        pld
        plb
        plp
        rtl

.a8
.i16

; ------------------------------------------------------------------------------

; [ draw current/max mp ]

; update mp in magic menu every 4th time this subroutine is called

DrawMP:
@805f:  lda     $353e
        eor     #1
        sta     $353e
        bne     @8084
        lda     $353f
        cmp     #$02
        bne     @8075
        lda     #0
        sta     $353f
@8075:  lda     $353f
        bne     @807c
        bra     @8081
@807c:  lda     #$0d        ; battle graphics $0d: draw current/max mp
        jsr     ExecBtlGfx
@8081:  inc     $353f
@8084:  rts

; ------------------------------------------------------------------------------

; [ execute battle graphics ]

ExecBtlGfx:
@8085:  jsl     ExecBtlGfx_ext
        rts

; ------------------------------------------------------------------------------

; [ init battle ]

InitBattle:
@808a:  jsr     InitHWRegs
        ldx     #$00ff
@8090:  lda     f:RNGTbl,x              ; copy rng table to buffer
        sta     $1900,x
        dex
        bpl     @8090
        jsr     InitRAM
        ldx     #$007f
        clr_a
        clc
@80a2:  adc     $0600,x                 ; seed rng with sum of $0600-$067f
        dex
        bpl     @80a2
        sta     $97
        jsr     InitGfxScript
        lda     $1802
        pha
        pha
        and     #$80
        sta     $352c                   ; if set, enable magnetization
        pla
        and     #$40
        sta     $a9
        pla
        and     #$3f
        sta     $1802
        lda     $a9
        beq     @80cb
        lda     #$07                    ; if set, use cave w/ water bg
        sta     $1802
@80cb:  lda     $1801
        and     #$80
        sta     $38ef                   ; if set, use moon monster action scripts
        lda     $1801
        and     #$7f
        sta     $1801
        longa
        lda     $1800
        cmp     #$0100
        bcc     @80ec
        sec
        sbc     #0                      ; does nothing ???
        sta     $1800
@80ec:  lda     $1800
        sta     $393d                   ; get pointer to battle properties
        lda     #8
        sta     $393f
        jsr     Mult16
        shorta0
        ldx     $3941
        clr_ay
@8103:  lda     f:BattleProp,x
        sta     $299c,y                 ; load battle properties
        iny
        inx
        cpy     #8
        bne     @8103
        lda     $299c
        sta     $29a4
        and     #$08
        sta     $3581                   ; forced back attack if set
        ldx     #3
        txy
        dey
@8121:  lda     $299c,x                 ; copy monster types
        sta     $29ad,y
        sta     $29b1,y
        dex
        dey
        bpl     @8121
        lda     #$ff                    ; list terminator ???
        sta     $29b0
        sta     $29b4
        clr_ax
        lda     $29a0                   ; monster type counts (2 bits each)
        sta     $ab
@813d:  stz     $29ca,x
        asl     $ab
        rol     $29ca,x
        asl     $ab
        rol     $29ca,x
        inx
        cpx     #3
        bne     @813d
        clr_ax
@8152:  txy
        iny
@8154:  lda     $29ad,x
        cmp     #$ff
        beq     @8178                   ; branch at end of monster type list
        cmp     $29ad,y
        bne     @8172                   ; branch if not same as another type
        clc
        lda     $29ca,x                 ; combine monster counts
        adc     $29ca,y
        sta     $29ca,x
        clr_a
        sta     $29ca,y                 ; remove the duplicate
        dec
        sta     $29ad,y                 ; mark as empty
@8172:  iny
        cpy     #3
        bne     @8154
@8178:  inx
        cpx     #2
        bne     @8152
        lda     #$ff
        ldy     #7
@8183:  sta     $29b5,y                 ; reset monster type in each slot
        sta     $29bd,y
        dey
        bpl     @8183
        iny
        tyx
@818e:  lda     $29ca,x
        sta     $ab
        beq     @81a3
@8195:  txa
        sta     $29b5,y                 ; set monster type in this slot
        sta     $29bd,y
        iny
        dec     $ab
        lda     $ab
        bne     @8195
@81a3:  inx
        cpx     #3
        bne     @818e
        lda     $29a1                   ; get pointer to monster position data
        sta     $df
        lda     #$08
        sta     $e1
        jsr     Mult8
        ldx     $e3
        clr_ay
@81b9:  lda     f:MonsterPos,x          ; load monster position data
        sta     $29a5,y
        inx
        iny
        cpy     #8
        bne     @81b9
        clc
        lda     $29ca                   ; calculate total monster count
        adc     $29cb
        adc     $29cc
        sta     $29cd
        lda     $29ca
        sta     $38f0
        lda     $29cb
        sta     $38f1
        lda     $29cc
        sta     $38f2
        lda     $29a3                   ; get pointer to monster cursor data
        sta     $df
        lda     #$10
        sta     $e1
        jsr     Mult8
        ldx     $e3
        clr_ay
@81f6:  lda     f:MonsterCursor,x       ; load monster cursor data
        sta     $29cf,y
        inx
        iny
        cpy     #$0010
        bne     @81f6
        jsr     InitObjects
        lda     $2282
        cmp     #97
        bcc     @8219                   ; branch if monster level is less than 97
        sec
        sbc     #97
        tax
        lda     f:MonsterRunTbl,x       ; run difficulty
        sta     $38d6
@8219:  lda     $38e5                   ; battle song
        and     #$0c
        lsr2
        cmp     #$03
        beq     @822d                   ; branch if no battle music
        tax
        lda     f:BattleSongTbl,x
        jsl     PlayBattleSong
@822d:  lda     #$03                    ; battle graphics $03: init battle graphics
        jsr     ExecBtlGfx
        jmp     BattleMain

; ------------------------------------------------------------------------------

; [ init ram ]

InitRAM:
@8235:  ldx     #$007f
@8238:  stz     $80,x       ; clear $80-$ff
        dex
        bpl     @8238
        ldx     #$197d
@8240:  stz     $2000,x     ; clear $2000-$397d
        dex
        bpl     @8240
        ldx     #$0007
@8249:  stz     $1804,x     ; clear $1804-$180b
        dex
        bpl     @8249
        ldx     #$0710
        lda     #$80
@8254:  sta     $2c7a,x     ; disable all spells
        dex4
        bpl     @8254
        ldx     #$333f
        lda     #$ff
@8262:  sta     $397f,x     ; clear $397f-$6cbe (monster scripts)
        dex
        bpl     @8262
        ldx     #$0005
@826b:  sta     $3929,x     ; clear battle menu queue
        dex
        bpl     @826b
        ldx     #$0007
@8274:  sta     $35f7,x     ; clear retaliation stack
        dex
        bpl     @8274
        sta     $d0         ; init #$ff
        sta     $357b
        sta     $357c
        sta     $3583
        sta     $355e
        sta     $3601
        sta     $3602
        sta     $38d6
        lda     #$1a
        sta     $3317
        sta     $3333
        sta     $334f
        sta     $336b
        sta     $3387
        inc
        sta     $331b       ; init 0
        sta     $3337
        sta     $3353
        sta     $336f
        sta     $338b
        lda     $16ac
        sta     $3538
        sta     $38ee
        ldx     #$0018
        lda     #$02
@82c0:  sta     $35a4,x     ; set extra doom counter
        stz     $35a5,x
        dex2
        bpl     @82c0
        rts

; ------------------------------------------------------------------------------

; [ init hardware registers ]

InitHWRegs:
@82cb:  lda     #0
        pha
        plb
        sta     hNMITIMEN
        ldx     #0
        phx
        pld
        lda     #$80
        sta     hINIDISP
        lda     #$09
        sta     hBGMODE
        ldx     #$0000
        stx     hOAMADDL
        txa
        sta     hOBJSEL
        lda     #$22
        sta     hBG12NBA
        lda     #$55
        sta     hBG34NBA
        lda     #$63
        sta     hBG1SC
        lda     #$59
        sta     hBG2SC
        lda     #$73
        sta     hBG3SC
        sta     hBG4SC
        lda     #$80
        sta     hVMAINC
        clr_ax
        sta     hMOSAIC
        sta     hBG1HOFS
        sta     hBG1HOFS
        sta     hBG1VOFS
        sta     hBG1VOFS
        sta     hBG2HOFS
        sta     hBG2HOFS
        sta     hBG2VOFS
        sta     hBG2VOFS
        sta     hBG3HOFS
        sta     hBG3HOFS
        sta     hBG3VOFS
        sta     hBG3VOFS
        sta     hBG4HOFS
        sta     hBG4HOFS
        sta     hBG4VOFS
        sta     hBG4VOFS
        sta     hW12SEL
        sta     hW34SEL
        sta     hWOBJSEL
        sta     hWH0
        sta     hWH1
        sta     hWH2
        sta     hWH3
        stx     hWBGLOG
        sta     hTM
        sta     hTS
        sta     hTMW
        sta     hTSW
        sta     hMDMAEN
        sta     hHDMAEN
        sta     hCGADSUB
        sta     hSETINI
        sta     hCGSWSEL
        lda     #$7e
        pha
        plb
        rts

; ------------------------------------------------------------------------------

; [ random (x..a) ]

RandXA:
@8379:  shorti
        stx     $96
        cpx     #$ff
        bne     @8383
        bra     @83b6
@8383:  cmp     #$00
        beq     @83b6
        cmp     $96
        beq     @83b6
        ldx     $97
        sec
        sbc     $96
        cmp     #$ff
        bne     @8399
        lda     $1900,x     ; rng table
        bra     @83b6
@8399:  inc
        sta     $3947
        stz     $3948
        lda     $1900,x     ; rng table
        tax
        stx     $3945
        longi
        jsr     Div16
        shorti
        clc
        lda     $394b
        adc     $96
        inc     $97
@83b6:  longi
        rts

; ------------------------------------------------------------------------------

; [ multiply (16-bit) ]

; +++$3941 = +$393d * +$393f

Mult16:
@83b9:  longa
        ldx     #$0010
        stz     $3941
        stz     $3943
@83c4:  ror     $393f
        bcc     @83d3
        clc
        lda     $393d
        adc     $3943
        sta     $3943
@83d3:  ror     $3943
        ror     $3941
        dex
        bne     @83c4
        shorta0
        rts

; ------------------------------------------------------------------------------

; [ multiply (8-bit) ]

; +$e3 = $df * $e1

Mult8:
@83e0:  stz     $e0
        stz     $e2
        longa
        ldx     #$0010
        stz     $e3
        stz     $394d
@83ee:  ror     $e1
        bcc     @83fb
        clc
        lda     $df
        adc     $394d
        sta     $394d
@83fb:  ror     $394d
        ror     $e3
        dex
        bne     @83ee
        shorta0
        rts

; ------------------------------------------------------------------------------

; [ divide (16-bit) ]

; +$394b = +$3945 / +$3947
; +$3949 = remainder

Div16:
@8407:  longa
        stz     $3949
        stz     $394b
        lda     $3945
        beq     @843f
        lda     $3947
        beq     @843f
        clc
        ldx     #$0010
@841d:  rol     $3945
        rol     $394b
        sec
        lda     $394b
        sbc     $3947
        sta     $394b
        bcs     @8439
        lda     $394b
        adc     $3947
        sta     $394b
        clc
@8439:  rol     $3949
        dex
        bne     @841d
@843f:  shorta0
        rts

; ------------------------------------------------------------------------------

; [ get pointer to null-terminated script ]

;   A: source bank
;  +Y: source address
; $e5: script index

GetScriptPtr:
@8443:  sta     $82
        sty     $80
        clr_ay
        lda     $e5
        beq     @845d
@844d:  lda     [$80],y
        cmp     #$ff        ; find terminator
        bne     @8459
        dec     $e5
        lda     $e5
        beq     @845c
@8459:  iny
        bra     @844d
@845c:  iny
@845d:  rts

; ------------------------------------------------------------------------------

; [ load array item ]

;     a: size
; ++$80: source address
;   $e5: index

LoadArrayItem:
@845e:  sta     $e1
        lda     $e5
        sta     $df
        lda     $e1
        sta     $e5
        jsr     Mult8
        ldy     $e3
        clr_ax
@846f:  lda     [$80],y     ; copy data to buffer
        sta     $289c,x
        iny
        inx
        cpx     $e5
        bne     @846f
        rts

; ------------------------------------------------------------------------------

; [ asl ]

Asl_6:
@847b:  asl
Asl_5:  asl
Asl_4:  asl
Asl_3:  asl
Asl_2:  asl
        asl
        rts

; ------------------------------------------------------------------------------

; [ lsr ]

Lsr_6:
@8482:  lsr
Lsr_5:  lsr
Lsr_4:  lsr
Lsr_3:  lsr
Lsr_2:  lsr
        lsr
        rts

; ------------------------------------------------------------------------------

; [ set current character/monster ]

; A: character/monster id

SelectObj:
@8489:  sta     $352f
        sta     $df
        lda     #$80
        sta     $e1
        jsr     Mult8
        ldx     $e3
        stx     $a6         ; pointer to character/monster properties
        lda     $352f
        sta     $df
        lda     #$15
        sta     $e1
        jsr     Mult8
        ldx     $e3
        stx     $3530       ; pointer to timers
        lda     $352f
        sta     $df
        lda     #$37
        sta     $e1
        jsr     Mult8
        ldx     $e3
        stx     $3532       ; pointer to equipped item data
        lda     $352f
        sta     $df
        lda     #$1c
        sta     $e1
        jsr     Mult8
        ldx     $e3
        stx     $3534       ; pointer to battle commands
        lda     $352f
        tax
        stx     $393d
        ldx     #$0120
        stx     $393f
        jsr     Mult16
        ldx     $3941
        stx     $3536       ; pointer to spell list
        rts

; ------------------------------------------------------------------------------

; [ add (16-bit) ]

; +++$395a = +$3956 + +$3958

Add16:
@84e3:  longa
        clc
        lda     $3956
        adc     $3958
        sta     $395a
        lda     #0
        adc     #0
        sta     $395c
        shorta0
        rts

; ------------------------------------------------------------------------------

; [ subtract (16-bit) ]

; +$3962 = +$395e + +$3960

; unused

Sub16:
@84fc:  longa
        sec
        lda     $395e
        sbc     $3960
        sta     $3962
        shorta0
        rts

; ------------------------------------------------------------------------------

; [ count bits ]

CountBits:
@850c:  ldx     #0
        ldy     #8
@8512:  asl
        bcc     @8516
        inx
@8516:  dey
        bne     @8512
        rts

; ------------------------------------------------------------------------------

; [ copy attacker/target properties from buffer ]

; used for magic, other commands modify attacker/target properties directly

CopyObj:
@851a:  lda     $3553
        bne     @853c       ; branch if self-target
        lda     $cd
        bpl     @8528
        and     #$7f
        clc
        adc     #5
@8528:  jsr     SelectObj
        ldx     $a6
        clr_ay
@852f:  lda     $2680,y
        sta     $2000,x
        inx
        iny
        cpy     #$0080
        bne     @852f
@853c:  lda     $ce
        bpl     @8545
        and     #$7f
        clc
        adc     #5
@8545:  jsr     SelectObj
        ldx     $a6
        clr_ay
@854c:  lda     $2700,y
        sta     $2000,x
        inx
        iny
        cpy     #$0080
        bne     @854c
        rts

; ------------------------------------------------------------------------------

; [ clear bit ]

ClearBit:
@855a:  and     f:BitAndTbl,x
        rts

; ------------------------------------------------------------------------------

; [ set bit ]

SetBit:
@855f:  ora     f:BitOrTbl,x
        rts

; ------------------------------------------------------------------------------

; [ test bit ]

CheckBit:
@8564:  and     f:BitOrTbl,x
        rts

; ------------------------------------------------------------------------------

; [ get pointer to timer data ]

; a: timer id * 3

GetTimerPtr:
@8569:  clc
        adc     $3530                   ; add $2a04
        sta     $3598
        lda     $3531
        adc     #0
        sta     $3599
        rts

; ------------------------------------------------------------------------------

; [ choose a random monster ]

RandMonster:
@8579:  ldx     #0
        lda     #7
        jsr     RandXA
        rts

; ------------------------------------------------------------------------------

; [ choose a random character ]

RandChar:
@8582:  ldx     #0
        lda     #4
        jsr     RandXA
        rts

; ------------------------------------------------------------------------------

; [ random (0..98) ]

Rand99:
@858b:  clr_ax
        lda     #98
        jsr     RandXA
        rts

; ------------------------------------------------------------------------------

; [ random (0..255) ]

Rand:
@8593:  clr_ax
        lda     #$ff
        jsr     RandXA
        rts

; ------------------------------------------------------------------------------

; [ add message to graphics script ($33c2) ]

AddMsg1:
@859b:  lda     #$f8        ; display text
        sta     $33c2
        lda     #$03        ; battle message
        sta     $33c3
        rts

; ------------------------------------------------------------------------------

; [ add message to graphics script ($33c6) ]

AddMsg2:
@85a6:  lda     #$f8        ; display text
        sta     $33c6
        lda     #$03        ; battle message
        sta     $33c7
        rts

; ------------------------------------------------------------------------------

; [ add message to graphics script ($33c8) ]

AddMsg3:
@85b1:  lda     #$f8        ; display text
        sta     $33c8
        lda     #$03        ; battle message
        sta     $33c9
        rts

; ------------------------------------------------------------------------------

; [ increment character/monster pointer ]

; x += $80

NextObj:
@85bc:  longa
        txa
        clc
        adc     #$0080
        tax
        shorta0
        rts

; ------------------------------------------------------------------------------

; [ set timer ]

;    a: timer id
; +$d4: timer duration

SetTimer:
@85c8:  jsr     GetTimerPtr
        ldx     $3598
        lda     $d4                     ; timer duration
        sta     $2a04,x
        lda     $d5
        sta     $2a05,x
        rts

; ------------------------------------------------------------------------------

; [ battle main ]

BattleMain:
@85d9:  lda     $16ac                   ; battle speed
        tax
        lda     f:BattleSpeedTbl,x
        inc
        sta     $3538
        stz     $38e6
@85e8:  lda     #$02                    ; battle graphics $02: wait one frame
        jsr     ExecBtlGfx
        lda     $38d9
        ora     $38da
        bne     @85e8                   ; branch if paused or wait mode
        dec     $3538
        lda     $3538
        bne     @85e8
        lda     $38d7
        bne     @8609                   ; branch if first strike
        lda     $3581
        and     #$08
        beq     @8638                   ; branch if not back attack
@8609:  lda     $3581
        and     #$08
        beq     @8614                   ; branch if not back attack
        lda     #$04                    ; バックアタックだ！ (back attack)
        bra     @861f
@8614:  lda     $38d7
        bmi     @861d                   ; branch if surprised
        lda     #$02                    ; せんせいこうげきの　チャンス！ (first strike)
        bra     @861f
@861d:  lda     #$03                    ; ふいうちだ！ (surprised)
@861f:  sta     $34ca                   ; add to battle message buffer
        lda     #$ff
        sta     $34cb
        sta     $33c4
        jsr     AddMsg1
        lda     #$05                    ; battle graphics $05: graphics script
        jsr     ExecBtlGfx
        stz     $38d7                   ; clear first strike and surprise
        stz     $3581                   ; clear back attack
@8638:  lda     $2282
        cmp     #$63
        bne     @8649                   ; branch if not level 99 monster
        lda     $352d
        bne     @8649                   ; branch if l and r buttons are pressed
        lda     #$0f
        sta     $38d6                   ; reset run counter to 15
@8649:  jsr     DecTimers
        lda     $3601
        cmp     #$ff
        bne     @8659                   ; branch if no graphics script
        jsr     DrawMP
        jsr     SapRegenEffect
@8659:  jsr     CheckBattleEnd
        lda     $a8
        bne     EndBattle
        lda     $3601
        cmp     #$ff
        bne     @866d                   ; branch if no graphics script
        jsr     ForceCharActions
        jsr     UpdateMenu
@866d:  jsr     GetPendingAction
        lda     $d1
        beq     @8684                   ; branch if no pending action
        jsr     InitAction
        jsr     DoAction
        lda     $352e
        cmp     #$02
        bne     @8684                   ; branch if not an attack
        jsr     DoRetal
@8684:  jmp     @85d9

; ------------------------------------------------------------------------------

; [ do action ]

DoAction:
@8687:  lda     $352e       ; action type
        asl
        tax
        lda     f:ActionTbl,x   ; action type jump table
        sta     $80
        lda     f:ActionTbl+1,x
        sta     $81
        lda     #^ActionTbl
        sta     $82
        jml     [$0080]

; ------------------------------------------------------------------------------

; [ end battle ]

EndBattle:
@869f:  jsl     ValidateDeadCharHP
        lda     #$85        ; sound command $85: fade out music (slow)
        sta     $35f3
        lda     $d7
        beq     @86b1       ; branch if menu is not open
        lda     #$01        ; battle graphics $01: close menu
        jsr     ExecBtlGfx
@86b1:  lda     $a8
        sta     $1803
        and     #$60
        bne     @870f       ; branch if victory or ran away
        lda     $a8
        and     #$04
        beq     @86ce

; fade out
        lda     #$15        ; battle graphics $15:
        jsr     ExecBtlGfx
        jsr     ClearWinStatus
        jsr     RestoreCharProp
        jmp     @8766

; defeat
@86ce:  lda     $38e5
        and     #$0c
        cmp     #$0c
        beq     @86dc
        lda     #$8b        ; sound command $8b: fade out music
        sta     $35f3
@86dc:  lda     #$0c        ; battle graphics $0c: draw hp text
        jsr     ExecBtlGfx
        lda     #$02        ; battle graphics $02: wait one frame
        jsr     ExecBtlGfx
        lda     #$15        ; battle graphics $15:
        jsr     ExecBtlGfx
        jsr     AddMsg1
        lda     #$24        ; パーティは　ぜんめつした‥‥‥‥ (party defeated)
        sta     $34ca
        lda     #$ff
        sta     $34cb
        sta     $33c4
        stz     $359a
        lda     #$40
        sta     $34c2
        lda     $388b
        bne     @870d
        lda     #$05        ; battle graphics $05: graphics script
        jsr     ExecBtlGfx
@870d:  bra     @8766

; ran away
@870f:  and     #$40
        beq     @8728
        lda     #$13        ; battle graphics $13: party runs away
        jsr     ExecBtlGfx
        jsr     ClearWinStatus
        jsr     RestoreCharProp
        lda     $38f3
        bne     @8766
        jsr     DropGil
        bra     @8766

; victory
@8728:  jsr     CheckFanfare
        lda     $a9
        bne     @8738
        lda     $38e5
        and     #$0c
        cmp     #$0c
        beq     @8740       ; branch if no battle music
@8738:  lda     #$08        ; victory fanfare
        sta     $38be
        inc     $38bd
@8740:  jsr     ClearWinStatus
        lda     #$02        ; battle graphics $02: wait one frame
        jsr     ExecBtlGfx
        jsr     CheckWinAnim
        lda     $a9
        bne     @8754
        lda     #$12        ; battle graphics $12: victory animation
        jsr     ExecBtlGfx
@8754:  jsr     RestoreCharProp
        lda     $a8
        and     #$10
        beq     @8766
        jsr     WinUpdate
        jsr     ClearWinStatus
        jsr     RestoreCharProp
@8766:  clr_ax
@8768:  dex
        bne     @8768
        stz     $ab
        ldx     $1800
        cpx     #$01c0
        bcc     @8777
        inc     $ab
@8777:  ldx     #7
@877a:  lda     $1804,x     ; items gained from battle
        ora     $ab
        sta     $ab
        dex
        bpl     @877a
        inx
@8785:  dex
        bne     @8785
        lda     $38e5
        and     #$0c
        cmp     #$0c
        beq     @87ab       ; branch if no battle music
        lda     $ab
        bne     @87ab       ; branch if any items were gained
        lda     $1800
        cmp     #$b7
        bne     @87a1
        lda     $1801
        bne     @87ab       ; branch if battle $01b7 (zeromus)
@87a1:  lda     $35f3       ; sound command (either $85 or $8b)
        sta     $1e00
        jsl     ExecSound_ext
@87ab:  lda     #$ff
        sta     $a9
        lda     #$10        ; screen brightness counter
        sta     $aa
@87b3:  inc     $a9         ; increment mosaic counter
        dec     $aa         ; decrement screen brightness
        lda     $aa
        beq     @87d1
        lda     $a9
        jsr     Asl_3
        ora     #$03        ; affect bg1 and bg2
        sta     $6cc2
        lda     $aa
        sta     $6cc1
        lda     #$02        ; battle graphics $02: wait one frame
        jsr     ExecBtlGfx
        bra     @87b3
@87d1:  lda     #$00
        sta     f:hMOSAIC     ; clear mosaic register
        rts

; ------------------------------------------------------------------------------

; [ check if victory fanfare is disabled ]

CheckFanfare:
@87d8:  ldx     #.loword(NoFanfareTbl)
        stx     $ab
        lda     #^NoFanfareTbl
        sta     $ad
        jmp     CheckBattleList

; ------------------------------------------------------------------------------

; [ find battle id in list ]

CheckBattleList:
@87e4:  stz     $a9
        clr_ay
@87e8:  lda     [$ab],y
        cmp     #$ff
        beq     @8802
        cmp     $1800
        bne     @87fe
        iny
        lda     [$ab],y
        cmp     $1801
        bne     @87ff
        inc     $a9
        rts
@87fe:  iny
@87ff:  iny
        bra     @87e8
@8802:  rts

; ------------------------------------------------------------------------------

; [ check if victory animation is disabled ]

CheckWinAnim:
@8803:  ldx     #.loword(NoWinAnimTbl)
        stx     $ab
        lda     #^NoWinAnimTbl
        sta     $ad
        jmp     CheckBattleList

; ------------------------------------------------------------------------------

; [ clear status for victory animation ]

ClearWinStatus:
@880f:  clr_axy
@8812:  lda     $2003,x
        sta     $38bf,y     ; save status 1
        and     #$f8        ; clear mute, darkness, and poison
        sta     $2003,x
        lda     $2004,x
        sta     $38c0,y     ; save status 2
        and     #$40        ; clear all but float
        sta     $2004,x
        stz     $2005,x     ; clear status 3
        lda     $2006,x
        sta     $38c1,y     ; save status 4
        stz     $2006,x     ; clear status 4
        jsr     NextObj
        iny3
        cpy     #15
        bne     @8812
        rts

; ------------------------------------------------------------------------------

; [ drop gil from running away ]

DropGil:
@8840:  jsr     Rand99
        cmp     #50                     ; 50% chance to drop gil
        bcs     @884a
        jmp     @8920
@884a:  ldy     #0
        sty     $ab
        sty     $289c
        sty     $289e
@8855:  ldy     $ab
        lda     $3588,y
        tax
        stx     $a9
        asl     $a9
        rol     $aa
        ldx     $a9
        lda     f:MonsterGil,x
        sta     $393d
        lda     f:MonsterGil+1,x
        sta     $393e
        lda     $38f0,y
        tax
        stx     $393f
        jsr     Mult16
        clc
        lda     $3941
        adc     $289c
        sta     $289c
        lda     $3942
        adc     $289d
        sta     $289d
        lda     $3943
        adc     $289e
        sta     $289e
        inc     $ab
        lda     $ab
        cmp     #$03
        bne     @8855
        lsr     $289e
        ror     $289d
        ror     $289c
        lsr     $289e
        ror     $289d
        ror     $289c
        lda     $289c
        ora     $289d
        beq     @8920
        lda     $16a0
        ora     $16a1
        ora     $16a2
        beq     @8920
        lda     $16a0
        sta     $a9
        lda     $16a1
        sta     $aa
        sec
        lda     $16a0
        sbc     $289c
        sta     $16a0
        lda     $16a1
        sbc     $289d
        sta     $16a1
        lda     $16a2
        sbc     $289e
        sta     $16a2
        bcs     @88ff
        lda     $a9
        sta     $289c
        lda     $aa
        sta     $289d
        stz     $16a0
        stz     $16a1
        stz     $16a2
@88ff:  lda     $289c
        sta     $359a
        lda     $289d
        sta     $359b
        stz     $359c
        lda     #$37
        sta     $34ca
        jsr     AddMsg1
        lda     #$ff
        sta     $34cc
        lda     #$05        ; battle graphics $05: graphics script
        jsr     ExecBtlGfx
@8920:  rts

; ------------------------------------------------------------------------------

; action type jump table
ActionTbl:
@8921:  .addr   GetCharAttack
        .addr   GetMonsterAttack
        .addr   DoAttack
        .addr   DoTimerEffect

; ------------------------------------------------------------------------------

.include "init.asm"

; ------------------------------------------------------------------------------

; [ decrement timers ]

DecTimers:
@9677:  stz     $38ee       ; this has no effect
        lda     $38ee
        beq     @9685       ; always branch
        dec     $38ee
        jmp     @9740
@9685:  lda     $16ac       ; reset battle speed counter (no effect)
        sta     $38ee
        longa
        clr_axy

; start of character/monster loop
@9690:  lda     $3601
        cmp     #$ffff
        beq     @96a2
        sta     $80
        tya
        lsr
        cmp     $80
        beq     @96a2
        bra     @96ce
@96a2:  lda     $29ea,y     ; get enabled timers (in hi byte, $29eb)
        sta     $2896

; stop timer
        asl     $2896
        bcc     @96d6       ; branch if stop timer is disabled
        shorta0
        lda     $2a06,x
        and     #$01
        longa
        bne     @96d6
        dec     $2a04,x     ; decrement stop timer
        lda     $2a04,x
        bne     @96ce
        shorta0
        lda     $2a06,x     ; stop timer expired
        ora     #$01
        sta     $2a06,x
        longa
@96ce:  txa
        clc
        adc     #$0015      ; skip all other timers
        tax
        bra     @9733

; not stopped
@96d6:  inx3                ; next timer
        lda     #6          ; loop through 6 timers
        sta     $289a
@96df:  asl     $2896
        bcc     @9728       ; branch if timer is disabled
        shorta0
        lda     $2a06,x
        and     #$81
        longa
        bne     @9728       ; branch if timer already expired
        lda     $289a
        cmp     #1
        bne     @970e       ; branch if not doom timer
        phx
        tya
        asl
        tax
        dec     $35a4,x     ; decrement extra doom counter
        lda     $35a4,x
        beq     @9707       ; branch if extra doom counter expired
        plx
        bra     @9728
@9707:  lda     #2          ; reset to 2
        sta     $35a4,x
        plx
@970e:  lda     $2a04,x
        beq     @971b       ; branch if timer expired
        dec     $2a04,x     ; decrement counter
        lda     $2a04,x
        bne     @9728
@971b:  shorta0
        lda     $2a06,x     ; mark timer as expired
        ora     #$81
        sta     $2a06,x
        longa
@9728:  inx3                ; next timer
        dec     $289a
        lda     $289a
        bne     @96df
@9733:  iny2                ; next character/monster
        cpy     #$001a
        beq     @973d
        jmp     @9690
@973d:  shorta0
@9740:  rts

; ------------------------------------------------------------------------------

; [ check for pending action ]

; the action order starts after the previous attacker id, and continues
; sequentially until all characters/monsters have been checked.

GetPendingAction:
@9741:  stz     $d1         ; disable pending action
        stz     $00
        lda     $38f6       ; character/monster with priority for next action
        sta     $a9
@974a:  lda     $3601
        cmp     #$ff
        beq     @9755
        cmp     $a9
        bne     @9775
@9755:  stz     $ad
        stz     $ae
        lda     $a9
        asl
        tax
        lda     $29eb,x     ; enabled timers
        sta     $ab
@9762:  asl     $ab
        bcc     @976d
        jsr     CheckTimer
        lda     $d1
        bne     @9787       ; return if timer expired
@976d:  inc     $ad         ; next timer
        lda     $ad
        cmp     #$07
        bne     @9762
@9775:  inc     $a9         ; next character/monster
        lda     $a9
        cmp     #$0d
        bne     @977f
        stz     $a9
@977f:  inc     $00
        lda     $00
        cmp     #$0d
        bne     @974a
@9787:  rts

; ------------------------------------------------------------------------------

; [ check if timer expired ]

CheckTimer:
@9788:  lda     $a9
        sta     $d2
        jsr     SelectObj
        lda     $ad
        sta     $d3
        asl
        clc
        adc     $ad
        sta     $af
        lda     $af
        jsr     GetTimerPtr
        ldx     $3598
        lda     $2a04,x
        ora     $2a05,x
        bne     @97b2
        lda     $2a06,x
        and     #$01
        beq     @97b2
        inc     $d1         ; enable pending action
@97b2:  rts

; ------------------------------------------------------------------------------

; [ init action ]

InitAction:
@97b3:  lda     $d2         ; acting character/monster
        sta     $38f6
        jsr     SelectObj
        inc     $38f6       ; next character/monster has action priority
        lda     $38f6
        cmp     #$0d
        bne     @97c8
        stz     $38f6
@97c8:  lda     $d3
        asl
        clc
        adc     $d3
        sta     $a9
        lda     $a9
        jsr     GetTimerPtr
        ldx     $3598
        lda     $2a06,x
        and     #$7e
        bne     @97ed       ; branch if action or timer effect
        lda     $d2
        cmp     #$05
        bcc     @97e9
        lda     #$01        ; 1: choose monster action
        bra     @97f7
@97e9:  lda     #$00        ; 2: choose character action
        bra     @97f7
@97ed:  and     #$08
        beq     @97f5
        lda     #$02        ; 3: do attack
        bra     @97f7
@97f5:  lda     #$03        ; 4: do timer effect
@97f7:  sta     $352e       ; set action type
        stz     $d1
        rts

; ------------------------------------------------------------------------------

.include "equip.asm"
.include "timer_dur.asm"

; ------------------------------------------------------------------------------

; [ check if battle is over ]

CheckBattleEnd:
@a015:  lda     a:$00a8
        bne     @a07d
        ldx     #4
        stx     $a9
@a01f:  ldx     $a9
        lda     $3540,x
        bne     @a039
        lda     $a9
        jsr     SelectObj
        ldx     $a6
        lda     $2003,x
        and     #$c0
        bne     @a039
        lda     $2005,x
        bpl     @a051
@a039:  dec     $a9
        lda     $a9
        bpl     @a01f
        lda     $38e5
        and     #$02
        beq     @a04a
        lda     #$08
        bra     @a04c
@a04a:  lda     #$80
@a04c:  sta     $a8
        jmp     @a0f6
@a051:  lda     $29cd
        bne     @a07e       ; branch if any monsters remain

; no monsters remaining
        lda     #$30
        sta     $a8
        clr_ax
@a05c:  lda     f:NoUpdateBattleTbl,x   ; battles with no party update
        cmp     #$ff
        beq     @a07d
        cmp     $1800
        bne     @a079
        lda     f:NoUpdateBattleTbl+1,x
        cmp     $1801
        bne     @a079
        lda     $a8         ; disable party update after battle
        and     #$ef
        sta     $a8
        rts
@a079:  inx2
        bra     @a05c
@a07d:  rts

; monsters remaining
@a07e:  lda     $388b
        bne     @a0f6       ; return if auto-battle
        lda     $38d3
        bne     @a08d       ; return if used escape
        lda     $352d
        beq     @a0f6       ; return if l and r buttons are not pressed
@a08d:  lda     $38d6
        cmp     #$ff
        beq     @a0f6
        lda     $38d6
        beq     @a0a3
        lda     $38f3
        bne     @a0a3       ; branch if used escape ???
        dec     $38d6
        bra     @a0f6
@a0a3:  lda     $38e5
        and     #$01
        bne     @a0de       ; branch if can't run
        clr_ax
        stx     $a9
@a0ae:  ldx     $a9
        lda     $3540,x     ; branch if character slot is empty
        bne     @a0d6
        lda     $a9
        jsr     SelectObj
        ldx     $a6
        lda     $2003,x
        and     #$c0
        bne     @a0d6       ; branch if character is dead or stone
        lda     $2004,x
        and     #$30
        bne     @a0d6       ; branch if paralyzed or asleep
        lda     $2005,x
        and     #$c2
        bne     @a0d6       ; branch if magnetized, stopped, or jumping
        lda     #$40
        sta     $a8         ; ran away
        rts
@a0d6:  inc     $a9
        lda     $a9
        cmp     #$05
        bne     @a0ae
@a0de:  stz     $352d
        jsr     AddMsg1
        lda     #$ff
        sta     $33c4
        lda     #$22
        sta     $34ca
        lda     #$05        ; battle graphics $05: graphics script
        jsr     ExecBtlGfx
        jsr     InitGfxScript
@a0f6:  rts

; ------------------------------------------------------------------------------

.include "char.asm"
.include "timer.asm"
.include "attack.asm"
.include "ai.asm"
.include "ai_cond.asm"
.include "retal.asm"
.include "fight.asm"
.include "damage.asm"
.include "magic.asm"
.include "cmd.asm"
.include "win.asm"

; ------------------------------------------------------------------------------

.segment "battle_code2"

; ------------------------------------------------------------------------------

; [ play battle song ]

PlayBattleSong:
@ff12:  sta     $a9
        stz     $1e00
        stz     $1e01
        stz     $1e05
@ff1d:  lda     $a9
        sta     $1e01
        lda     #$01
        sta     $1e00
        jsl     ExecSound_ext
        lda     $1e05
        cmp     $a9
        bne     @ff1d
        lda     $1e04
        cmp     #$01
        bne     @ff1d
        rtl

; ------------------------------------------------------------------------------

; [ validate dead character hp ]

; set all dead characters' hp to zero

ValidateDeadCharHP:
@ff3a:  clr_axy
@ff3d:  lda     $3540,y
        bne     @ff4d       ; branch if not present
        lda     $2003,x
        bpl     @ff4d       ; branch if not dead
        stz     $2007,x     ; set hp to zero
        stz     $2008,x
@ff4d:  longa
        txa
        clc
        adc     #$0080
        tax
        shorta0
        iny
        cpy     #5
        bne     @ff3d
        rtl

; ------------------------------------------------------------------------------

; [ divide experience points ]

DivXP:
@ff5f:  ldx     $ab
        phx
        ldx     #$000f
@ff65:  stz     $a9,x
        dex
        bpl     @ff65
        plx
        stx     $ad
        ldx     $3591
        stx     $a9
        lda     $3593
        sta     $ab
        longa
        clc
        ldx     #$0020
@ff7d:  rol     $a9
        rol     $ab
        rol     $b5
        rol     $b7
        sec
        lda     $b5
        sbc     $ad
        sta     $b5
        lda     $b7
        sbc     $af
        sta     $b7
        bcs     @ffa1
        lda     $b5
        adc     $ad
        sta     $b5
        lda     $b7
        adc     $af
        sta     $b7
        clc
@ffa1:  rol     $b1
        rol     $b3
        dex
        bne     @ff7d
        lda     $b1
        sta     $ad
        lda     $b3
        sta     $af
        shorta0
        rtl

; ------------------------------------------------------------------------------

; [ disable regen based on fusoya's status ]

CheckRegen:
@ffb4:  ldy     #5
        clr_ax
@ffb9:  lda     $2000,x
        and     #$1f
        cmp     #$13
        bne     @ffd7       ; branch if not fusoya
        lda     $2003,x
        and     #$c0
        bne     @ffd0       ; branch if dead or stone
        lda     $2004,x
        and     #$3c
        beq     @ffe5       ; paralyze, sleep, charm, berserk
@ffd0:  lda     #$ff
        sta     $357c       ; disable regen
        bra     @ffe5
@ffd7:  longa
        txa
        clc
        adc     #$0080
        tax
        shorta0
        dey
        bne     @ffb9
@ffe5:  rtl

; ------------------------------------------------------------------------------
