
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: vehicle.asm                                                          |
; |                                                                            |
; | description: vehicle routines                                              |
; |                                                                            |
; | created: 3/26/2022                                                         |
; +----------------------------------------------------------------------------+

.pushseg

; 1e/fee0
.segment "earth_moon"

        .include "gfx/earth_moon_gfx.asm"
        .include "gfx/earth_moon_pal.asm"

.popseg

; ------------------------------------------------------------------------------

; [ board/exit vehicle ]

ChangeVehicle:
@9e3b:  lda     $02
        and     #JOY_A
        beq     @9e45       ; return if A button is not pressed
        lda     $54
        beq     @9e46       ; return if A button is not reset
@9e45:  rts
@9e46:  inc     $54         ; reset A button
        lda     #$3d
        jsr     CheckEventSwitch
        cmp     #0
        bne     @9e5a
        lda     #$30
        jsr     CheckEventSwitch
        cmp     #0
        beq     @9ea5
@9e5a:  lda     $1704       ; falcon and enterprise only
        cmp     #$04
        beq     @9e65
        cmp     #$05
        bne     @9ea5
; overworld -> underground
@9e65:  lda     $1700
        bne     @9e83
        lda     $1706
        cmp     #$69
        bcc     @9ea5
        cmp     #$6c
        bcs     @9ea5
        lda     $1707
        cmp     #$d3
        bcc     @9ea5
        cmp     #$d6
        bcs     @9ea5
        jmp     @9ea0
; underground -> overworld
@9e83:  lda     $1700
        cmp     #$01
        bne     @9ea5
        lda     $1706
        cmp     #$70
        bcc     @9ea5
        cmp     #$73
        bcs     @9ea5
        lda     $1707
        cmp     #$0f
        bcc     @9ea5
        cmp     #$12
        bcs     @9ea5
@9ea0:  lda     #1
        sta     $ce         ; enable overworld/underground switch
        rts
; try to exit vehicle
@9ea5:  lda     $1704
        beq     @9ed5
        cmp     #$01
        bne     @9eb1
        jmp     LandChoco
@9eb1:  cmp     #$02
        bne     @9eb8
        jmp     LandBkChoco
@9eb8:  cmp     #$03
        bne     @9ebf
        jmp     LandHover
@9ebf:  cmp     #$04
        bne     @9ec6
        jmp     LandEnterprise
@9ec6:  cmp     #$05
        bne     @9ecd
        jmp     LandFalcon
@9ecd:  cmp     #$06
        bne     @9ed4
        jmp     WhaleButton
@9ed4:  rts
; try to board vehicle
@9ed5:  stz     $1a02       ; disable tent/save
        lda     $ab
        beq     @9edd       ; branch if not moving
        rts
@9edd:  lda     $1701
        cmp     #$00
        bne     @9ef4
        lda     $170f
        beq     @9ef4       ; branch if chocobo is not visible
        ldx     $1706
        cpx     $1710       ; chocobo position
        bne     @9ef4
        jmp     BoardChoco
@9ef4:  lda     $1701
        cmp     #$00
        bne     @9f0b
        lda     $1712
        beq     @9f0b
        ldx     $1706
        cpx     $1713
        bne     @9f0b
        jmp     BoardBkChoco
@9f0b:  lda     $1701
        cmp     $171b
        bne     @9f23
        lda     $1718
        beq     @9f23
        ldx     $1706
        cpx     $1719
        bne     @9f23
        jmp     BoardHover
@9f23:  lda     $1701
        cmp     $171f
        bne     @9f3b
        lda     $171c
        beq     @9f3b
        ldx     $1706
        cpx     $171d
        bne     @9f3b
        jmp     BoardEnterprise
@9f3b:  lda     $1701
        cmp     $1723
        bne     @9f53
        lda     $1720
        beq     @9f53
        ldx     $1706
        cpx     $1721
        bne     @9f53
        jmp     BoardFalcon
@9f53:  lda     $1701
        cmp     $1727
        bne     @9f6b
        lda     $1724
        beq     @9f6b
        ldx     $1706
        cpx     $1725
        bne     @9f6b
        jmp     EnterWhale
@9f6b:  rts

; ------------------------------------------------------------------------------

; [ update local tile properties ]

UpdateLocalTiles:
; tile above -> +$a3
@9f6c:  lda     $1706
        sta     $1a
        lda     $1707
        dec
        sta     $1b
        jsr     GetTileProp
        ldx     $1e
        stx     $a3
        lda     $06
        sta     $070c
; tile to the left -> +$a9
        inc     $1b
        dec     $1a
        jsr     GetTileProp
        ldx     $1e
        stx     $a9
        lda     $06
        sta     $070f
; current tile -> +$a1
        inc     $1a
        jsr     GetTileProp
        ldx     $1e
        stx     $a1
        lda     $06
        sta     $070b
; tile to the right -> +$a5
        inc     $1a
        jsr     GetTileProp
        ldx     $1e
        stx     $a5
        lda     $06
        sta     $070d
; tile to below -> +$a7
        inc     $1b
        dec     $1a
        jsr     GetTileProp
        ldx     $1e
        stx     $a7
        lda     $06
        sta     $070e
        rts

; ------------------------------------------------------------------------------

; [ get tile properties ]

;  $06: tile id (out)
;  $1a: x position
;  $1b: y position
; +$1e: tile properties (out)

GetTileProp:
@9fc0:  lda     $1700
        cmp     #3
        beq     @9fce       ; branch if a sub-map
        lda     $1b
        and     #$3f        ; y position mod 64
        jmp     @9ff1
@9fce:  lda     $1a
        bmi     @9fde       ; branch if out-of-bounds left
        cmp     #$20
        bcs     @9fde       ; branch if out-of-bounds right
        lda     $1b
        bmi     @9fde       ; branch if out-of-bounds top
        cmp     #$20
        bcc     @9fef       ; branch if not out-of-bounds bottom
; out-of bounds
@9fde:  lda     $0fdf
        bpl     @9fe9       ; branch if out-of-bounds tiles are passable
        ldx     #$0000
        stx     $1e
        rts
@9fe9:  ldx     #7
        stx     $1e
        rts
; not out of bounds
@9fef:  lda     $1b
@9ff1:  sta     $3e
        lda     $1a
        sta     $3d
        ldx     $3d
        lda     $7f5c71,x   ; bg tilemap
        sta     $06
        sta     $18
        stz     $19
        asl     $18
        rol     $19
        ldx     $18
        lda     $0edb,x     ; tile properties
        sta     $1e
        lda     $0edc,x
        sta     $1f
        rts

; ------------------------------------------------------------------------------

; [ animate 4 frames ]

Animate4:
@a014:  lda     #$03
        sta     $1705
@a019:  jsr     ResetSprites
        jsr     DrawWorldSprites
        jsr     WaitFrame
        lda     $7a
        and     #$03
        bne     @a019
        rts

; ------------------------------------------------------------------------------

; [ animate 8 frames ]

Animate8:
@a029:  lda     #$03
        sta     $1705
@a02e:  jsr     ResetSprites
        jsr     DrawWorldSprites
        jsr     WaitFrame
        lda     $7a
        and     #$07
        bne     @a02e
        rts

; ------------------------------------------------------------------------------

; [ board chocobo ]

BoardChoco:
@a03e:  lda     #$01
        sta     $1704       ; set vehicle
        sta     $ac         ; set movement speed
        jsr     PlayMapSong
        rts

; ------------------------------------------------------------------------------

; [ board black chocobo ]

BoardBkChoco:
@a049:  inc     $1715
        lda     $1715
        cmp     #$01
        bne     @a05f
        lda     $1706
        sta     $1716
        lda     $1707
        sta     $1717
@a05f:  lda     #$02
        sta     $1704
        sta     $ac
        jsr     PlayMapSong

LiftoffBkChoco:
@a069:  stz     $79
        stz     $b5
@a06d:  jsr     Animate4
        inc     $b5
        inc     $79
        lda     $79
        cmp     #$10
        bne     @a06d
        rts

; ------------------------------------------------------------------------------

; [ get off chocobo ]

LandChoco:
@a07b:  lda     $a1
        and     #$01
        bne     @a082
        rts
@a082:  jsr     FadeOutSongFast
        lda     #$02
        sta     $170f
        lda     #$70        ; set chocobo position
        sta     $1710
        sta     $1711
        lda     #$01        ; facing right
        sta     $1705
        lda     #$02
        sta     $2c
        jsr     Rand
        lsr
        bcc     @a0ad
        lda     #$03
        sta     $1705
        lda     $2c
        eor     #$ff
        inc
        sta     $2c
@a0ad:  lda     #$02
        sta     $2e
        jsr     Rand
        lsr
        bcc     @a0be
        lda     $2e
        eor     #$ff
        inc
        sta     $2e
@a0be:  stz     $1704
; start of frame loop
@a0c1:  jsr     WaitVblankLong
        jsr     Rand
        cmp     #$10
        bcs     @a0d2
        lda     $2e
        eor     #$ff
        inc
        sta     $2e
@a0d2:  lda     $1710
        clc
        adc     $2c
        sta     $1710
        beq     @a103
        cmp     #$f0
        beq     @a103
        lda     $1711
        clc
        adc     $2e
        sta     $1711
        beq     @a103
        cmp     #$f0
        beq     @a103
        lda     #$01
        sta     $1704
        jsl     DrawChoco
        stz     $1704
        jsl     DrawPlayerWorld
        jmp     @a0c1
@a103:  jsr     WaitVblankLong
        jsr     ResetSprites
        stz     $1704
        stz     $170f
        jsr     DrawWorldSprites
        jsr     WaitVblankLong
        stz     $ac
        stz     $7b
        inc     $1a02
        jsr     PlayMapSong
        rts

; ------------------------------------------------------------------------------

; [ land black chocobo ]

LandBkChoco:
@a120:  stz     $79
@a122:  jsr     Animate4
        dec     $b5
        inc     $79
        lda     $79
        cmp     #$10
        bne     @a122
        lda     $a1
        and     #$08
        bne     @a138       ; branch if forest tile (can land)
        jmp     LiftoffBkChoco
@a138:  stz     $1704
        stz     $ac
        stz     $7b
        lda     #$02
        sta     $1705
        ldx     $1706
        stx     $1713
        lda     $1715
        cmp     #$02
        bne     @a157
        stz     $1715
        stz     $1712
@a157:  jsr     PlayMapSong
        inc     $1a02       ; enable tent/save
        rts

; ------------------------------------------------------------------------------

; [ board ship ]

BoardShip:
@a15e:  lda     #$07        ; ship
        sta     $1704
        lda     #1          ; movement speed: 1
        sta     $ac
        rts

; ------------------------------------------------------------------------------

; [ board hovercraft ]

BoardHover:
@a168:  lda     #$03
        sta     $1704
        lda     #1
        sta     $ac
        lda     $1701
        sta     $171b
        lda     #$03
        sta     $1705
        lda     $b1
        beq     @a183       ; branch if didn't just acquire vehicle
        jsr     ShowVehicleSmoke
@a183:  jsr     PlayMapSong
        stz     $79
        stz     $b6
@a18a:  jsr     Animate8
        inc     $b6
        inc     $79
        lda     $79
        cmp     #$04
        bne     @a18a
        rts

; ------------------------------------------------------------------------------

; [ vehicle appearing animation ]

; used for hovercraft, enterprise, and falcon

ShowVehicleSmoke:
@a198:  lda     #$10
        sta     $0acf
        lda     #$03
        sta     $0ad0
        lda     #$03
        sta     $0ad1
        ldx     #$7070
        stx     $0ad4
        ldx     #$0028
        stx     $0ad2
        lda     #$06
        sta     $0acd
        lda     #$02        ; sand explosion palette
        sta     $0ace
        jsr     _00e075
; start of frame loop
@a1c0:  jsr     WaitFrame
        jsr     UpdateExplosions
        ldx     $0ad2
        cpx     #8
        bcs     @a1d5
        lda     #1
        sta     $e5
        jsr     DrawWorldSprites
@a1d5:  ldx     $0ad2
        cpx     #0
        bne     @a1c0
        rts

; ------------------------------------------------------------------------------

; [ land hovercraft ]

LandHover:
@a1de:  lda     $a1
        and     #$01
        bne     @a1e5
        rts
@a1e5:  stz     $79
@a1e7:  jsr     Animate8
        dec     $b6
        inc     $79
        lda     $79
        cmp     #$04
        bne     @a1e7
        stz     $1704
        stz     $ac
        stz     $7b
        lda     #$02
        sta     $1705
        lda     $1701
        sta     $171b
        ldx     $1706
        stx     $1719
        jsr     PlayMapSong
        inc     $1a02
        rts

; ------------------------------------------------------------------------------

; [ board enterprise ]

BoardEnterprise:
@a213:  lda     $1286
        and     #$04
        beq     @a21b
        rts
@a21b:  lda     #$04        ; set vehicle
        sta     $1704
        lda     #3
        sta     $ac         ; set movement speed
        sta     $1705
        lda     $b1
        beq     @a250       ; branch if didn't just acquire vehicle
        lda     $e1
        beq     @a241
        lda     #$20
        sta     $ad
        lda     #$10
        sta     $b7
        jsl     UpdateZoomPal
        lda     #$0f
        sta     $06fd       ; set airship animation speed
        rts
@a241:  jsr     ShowVehicleSmoke
        lda     #$20
        sta     $79
        lda     #$0f
        sta     $06fd       ; set airship animation speed
        jmp     LiftoffEnterprise
@a250:  jsr     PlayMapSong
        stz     $79

LiftoffEnterprise:
@a255:  stz     $7a
        stz     $b7
@a259:  jsr     Animate4
        lda     $79
        cmp     #$20
        bcs     @a26b
        lsr
        sta     $06fd       ; set airship animation speed
        inc     $79
        jmp     @a259
@a26b:  inc     $b7
        lda     $b7
        clc
        adc     #$10
        sta     $ad
        lda     $b7
        jsl     UpdateZoomPal
        inc     $79
        lda     $79
        cmp     #$30
        bne     @a259
        rts

; ------------------------------------------------------------------------------

; [ board falcon ]

BoardFalcon:
@a283:  lda     #$05
        sta     $1704
        lda     #3
        sta     $ac
        sta     $1705
        lda     $b1
        beq     @a2b8       ; branch if didn't just acquire vehicle
        lda     $e1
        beq     @a2a9
        lda     #$20
        sta     $ad
        lda     #$10
        sta     $b8
        jsl     UpdateZoomPal
        lda     #$0f
        sta     $06fd       ; set airship animation speed
        rts
@a2a9:  jsr     ShowVehicleSmoke
        lda     #$20
        sta     $79
        lda     #$0f
        sta     $06fd       ; set airship animation speed
        jmp     LiftoffFalcon
@a2b8:  jsr     PlayMapSong
        stz     $79

LiftoffFalcon:
@a2bd:  stz     $7a
        stz     $b8
@a2c1:  jsr     Animate4
        lda     $79
        cmp     #$20
        bcs     @a2d3
        lsr
        sta     $06fd       ; set airship animation speed
        inc     $79
        jmp     @a2c1
@a2d3:  inc     $b8
        lda     $b8
        clc
        adc     #$10
        sta     $ad
        lda     $b8
        jsl     UpdateZoomPal
        inc     $79
        lda     $79
        cmp     #$30
        bne     @a2c1
        rts

; ------------------------------------------------------------------------------

; [ enter big whale ]

EnterWhale:
@a2eb:  lda     #$0e
        sta     $1e01
        lda     #$01
        sta     $1e00
        jsl     ExecSound_ext
        lda     #$54
        jsr     ExecTriggerScript
        rts

; ------------------------------------------------------------------------------

; [ board big whale ]

BoardWhale:
@a2ff:  lda     #$06
        sta     $1704
        lda     #3
        sta     $ac
        lda     $e1
        beq     @a31f
        lda     #$30
        sta     $ad
        lda     #$20
        sta     $b9
        lsr
        jsl     UpdateZoomPal
        lda     #$0f
        sta     $06fd       ; set airship animation speed
        rts
@a31f:  jsr     PlayMapSong
        stz     $79

LiftoffWhale:
@a324:  stz     $7a
        stz     $b9
@a328:  jsr     Animate4
        lda     $79
        cmp     #$20
        bcs     @a33a
        lsr
        sta     $06fd       ; set airship animation speed
        inc     $79
        jmp     @a328
@a33a:  inc     $b9
        inc     $b9
        lda     $b9
        clc
        adc     #$10
        sta     $ad
        lda     $b9
        lsr
        jsl     UpdateZoomPal
        inc     $79
        lda     $79
        cmp     #$30
        bne     @a328
        lda     $06c3
        bne     @a35a                   ; branch if travelling to/from moon
        rts
@a35a:  stz     $06c3
        lda     $1700
        beq     EarthToMoon
        jmp     MoonToEarth

; travel from earth to moon
EarthToMoon:
@a365:  ldx     $1706
        stx     $1708
        jsr     _00a407
        ldx     #$ff98
        stx     $5a
        jsr     _00a531
        jsr     _00a465
        ldx     #$0198
        stx     $5a
        jsr     _00a531
        jsr     _00a4ef
        lda     #$02
        sta     $1700
        sta     $1727
        lda     #$01
        sta     $1701
        ldx     $170c
        stx     $1706
        jsr     LoadMoon
        lda     #$10
        jsl     UpdateZoomPal
        lda     #$81
        sta     $4200       ; enable nmi
        lda     #$30
        sta     $ad
        jsr     _00a437
        ldx     #$0000
        stx     $172c
        rts

; travel from moon to earth
MoonToEarth:
@a3b3:  ldx     $1706
        stx     $170c
        jsr     _00a407
        ldx     #$0198
        stx     $5a
        jsr     _00a542
        jsr     _00a465
        ldx     #$ff98
        stx     $5a
        jsr     _00a542
        jsr     _00a4ef
        lda     #$80
        sta     $2100       ; screen off
        stz     $4200       ; disable nmi and irq
        lda     #$00
        sta     $1700
        sta     $1701
        sta     $1727
        ldx     $1708
        stx     $1706
        jsr     LoadOverworld
        lda     #$10
        jsl     UpdateZoomPal
        lda     #$81
        sta     $4200       ; enable nmi
        lda     #$30
        sta     $ad
        jsr     _00a437
        ldx     #$0000
        stx     $172c
        rts

; ------------------------------------------------------------------------------

; [  ]

_00a407:
@a407:  jsr     _00a450
        lda     #$80
        sta     $2100       ; screen off
        stz     $4200       ; disable nmi
        stz     hHDMAEN
        lda     #$32
        sta     $76
        ldx     #$0000
        stx     $47
        ldx     #$8000
        stx     $45
        jsl     ClearVRAM
        lda     #$02
        sta     $1700
        jsl     TfrWorldGfx
        jsr     LoadEarthMoonGfx
        jsr     _00a5ac
        rts

; ------------------------------------------------------------------------------

; [  ]

_00a437:
@a437:  stz     $79
        lda     #$04
        sta     $a1
@a43d:  jsr     _00a51a
        jsr     DrawWorldSprites
        jsr     WaitVblankShort
        jsr     _00a527
        inc     $79
        cmp     #$28
        bne     @a43d
        rts

; ------------------------------------------------------------------------------

; [  ]

_00a450:
@a450:  lda     #$28
        sta     $79
@a454:  jsr     _00a51a
        jsr     DrawWorldSprites
        jsr     WaitVblankShort
        jsr     _00a527
        dec     $79
        bne     @a454
        rts

; ------------------------------------------------------------------------------

; [  ]

_00a465:
@a465:  jsr     DrawStars
        ldx     #$ff98
        stx     $5c
        stz     $70
        stz     $71
        stz     $72
        stz     $73
        lda     #$81
        sta     $4200       ; enable nmi
        lda     #$0f
        sta     $2100       ; screen on, full brightness
        lda     #$00
        sta     $79
@a483:  jsr     WaitVblankShort
        stz     hHDMAEN
        lda     $79
        lsr2
        clc
        adc     #$09
        sta     $6e
        stz     $6f
        jsr     UpdateMode7Regs
        lda     $79
        and     #$07
        bne     @a4aa
        lda     $5c
        sec
        sbc     #$01
        sta     $5c
        lda     $5d
        sbc     #$00
        sta     $5d
@a4aa:  jsr     _00a527
        jsr     DrawStars
        inc     $79
        lda     $79
        cmp     #$60
        bne     @a483
        lda     #$5f
        sta     $79
@a4bc:  jsr     WaitVblankShort
        stz     hHDMAEN
        lda     $79
        lsr2
        clc
        adc     #$09
        sta     $6e
        stz     $6f
        jsr     UpdateMode7Regs
        lda     $79
        and     #$07
        bne     @a4e3
        lda     $5c
        sec
        sbc     #$01
        sta     $5c
        lda     $5d
        sbc     #$00
        sta     $5d
@a4e3:  jsr     DrawStars
        dec     $79
        lda     $79
        cmp     #$ff
        bne     @a4bc
        rts

; ------------------------------------------------------------------------------

; [  ]

_00a4ef:
@a4ef:  ldx     #$ff98
        stx     $5c
        lda     #$df
        sta     $79
@a4f8:  jsr     WaitVblankShort
        stz     hHDMAEN
        lda     $79
        sta     $6e
        stz     $6f
        asl     $6e
        rol     $6f
        jsr     UpdateMode7Regs
        jsr     _00a527
        jsr     DrawStars
        dec     $79
        lda     $79
        cmp     #$ff
        bne     @a4f8
        rts

; ------------------------------------------------------------------------------

; [ get y-offset for big whale liftoff ]

_00a51a:
@a51a:  lda     #$28
        sec
        sbc     $79
        tax
        lda     f:WhaleLiftoffYTbl,x
        sta     $b9
        rts

; ------------------------------------------------------------------------------

; [  ]

_00a527:
@a527:  lda     $79
        cmp     #$10
        bcs     @a530
        sta     hINIDISP
@a530:  rts

; ------------------------------------------------------------------------------

; [  ]

_00a531:
@a531:  ldx     #0
@a534:  lda     f:_14fae6,x
        sta     $0300,x
        inx
        cpx     #$0010
        bne     @a534
        rts

; ------------------------------------------------------------------------------

; [  ]

_00a542:
@a542:  ldx     #0
@a545:  lda     f:_14fad6,x
        sta     $0300,x
        inx
        cpx     #$0010
        bne     @a545
        rts

; ------------------------------------------------------------------------------

; [ load earth/moon graphics (telescope/big whale) ]

LoadEarthMoonGfx:
@a553:  ldx     #$4000
        stx     $47
        ldx     #$0100
        stx     $45
        lda     #.bankbyte(EarthMoonGfx)        ; 1e/fee0 (moon sprite graphics)
        sta     $3c
        ldx     #.loword(EarthMoonGfx)
        stx     $3d
        jsl     TfrVRAM
        ldx     #0
@a56d:  lda     f:EarthMoonPal,x   ; moon sprite palette
        sta     $0cdb,x
        sta     $0ddb,x
        inx
        cpx     #$0020
        bne     @a56d
        rts

; ------------------------------------------------------------------------------

; [ draw star sprites ]

DrawStars:
@a57e:  ldy     #$0010
        ldx     #$0000
@a584:  jsr     Rand
        sta     $0300,y
        jsr     Rand
        sta     $0301,y
        lda     #$2f
        sta     $0302,y
        jsr     Rand
        and     #$07
        asl
        ora     #$01
        sta     $0303,y
        inx2
        iny4
        cpy     #$0200
        bne     @a584
        rts

; ------------------------------------------------------------------------------

; [  ]

_00a5ac:
@a5ac:  lda     #$70
        sta     $07
        stz     $2115
        ldx     #$0000
        stx     $3d
@a5b8:  ldx     $3d
        stx     $2116
@a5bd:  lda     $07
        sta     $2118
        inc     $07
        lda     $07
        and     #$03
        bne     @a5bd
        lda     $3d
        clc
        adc     #$80
        sta     $3d
        lda     $3e
        adc     #$00
        sta     $3e
        cmp     #$02
        bne     @a5b8
        lda     #$80
        sta     $07
        stz     $2115
        ldx     #$0040
        stx     $3d
@a5e7:  ldx     $3d
        stx     $2116
@a5ec:  lda     $07
        sta     $2118
        inc     $07
        lda     $07
        and     #$03
        bne     @a5ec
        lda     $3d
        clc
        adc     #$80
        sta     $3d
        lda     $3e
        adc     #$00
        sta     $3e
        cmp     #$02
        bne     @a5e7
        rts

; ------------------------------------------------------------------------------

; [ land enterprise / pick up hovercraft ]

; in enterprise, pressed A button

LandEnterprise:
@a60b:  lda $06d0
        bne     @a630       ; branch if holding hovercraft
        lda     #$36
        jsr     CheckEventSwitch
        cmp     #$00
        bne     @a61c
        jmp     @a65a
; try to pick up hovercraft
@a61c:  lda     $171f
        cmp     $171b
        bne     @a65a
        ldx     $1719
        cpx     $1706
        bne     @a65a
        jsr     GrabHover
        rts
; try to drop hovercraft
@a630:  lda     $1723
        cmp     $1701
        bne     @a640
        ldx     $1706
        cpx     $1721
        beq     @a659
@a640:  lda     $1727
        cmp     $1701
        bne     @a650
        ldx     $1706
        cpx     $1725
        beq     @a659
@a650:  lda     $a1
        and     #$10
        beq     @a659
        jsr     DropHover
@a659:  rts
; try to land
@a65a:  lda     #$30
        sta     $79
        stz     $7a
; start of frame loop
@a660:  jsr     Animate4
        lda     $79
        cmp     #$21
        bcs     @a6ce       ; branch if descending
; on ground
        lda     $a2
        and     #$10
        bne     @a672       ; branch if airship can land
        jmp     LiftoffEnterprise
@a672:  ldx     $1719       ; can't land on hovercraft
        cpx     $1706
        bne     @a67d
        jmp     LiftoffEnterprise
@a67d:  lda     $1723       ; can't land on falcon
        cmp     $171f
        bne     @a690
        ldx     $1721
        cpx     $1706
        bne     @a690
        jmp     LiftoffEnterprise
@a690:  lda     $1727       ; can't land on big whale
        cmp     $171f
        bne     @a6a3
        ldx     $1725
        cpx     $1706
        bne     @a6a3
        jmp     LiftoffEnterprise
@a6a3:  lda     $79
        lsr
        sta     $06fd       ; set airship animation speed
        dec     $79
        dec     $79
        bne     @a660
        stz     $1704
        stz     $ac
        stz     $7b
        lda     #$02
        sta     $1705
        ldx     $1706
        stx     $171d
        lda     $1701
        sta     $171f
        jsr     PlayMapSong
        inc     $1a02       ; enable tent/save
        rts
; descending
@a6ce:  dec     $b7
        lda     $b7
        clc
        adc     #$10
        sta     $ad
        lda     $b7
        jsl     UpdateZoomPal
        dec     $79
        jmp     @a660

; ------------------------------------------------------------------------------

; hook positions
HookYTbl:
@a6e2:  .byte   0,1,2,3,4,5,6,7,7,6,5,4,3,2,1,0

; ------------------------------------------------------------------------------

; [ drop hovercraft ]

DropHover:
@a6f2:  lda     #$03
        sta     $1705
        stz     $7a
        stz     $79
@a6fb:  jsr     ResetSprites
        jsr     DrawWorldSprites
        lda     $79
        lsr2
        tax
        lda     HookYTbl,x
        sta     $06f8
        jsr     WaitFrame
        inc     $79
        lda     $79
        cmp     #$20
        bne     @a726
        stz     $06d0
        lda     $1701       ; set hovercraft world and position
        sta     $171b
        ldx     $1706
        stx     $1719
@a726:  lda     $79
        cmp     #$40
        bne     @a6fb
        rts

; ------------------------------------------------------------------------------

; [ pick up hovercraft with hook ]

GrabHover:
@a72d:  lda     #$03
        sta     $1705
        stz     $7a
        stz     $79
@a736:  jsr     ResetSprites
        jsr     DrawWorldSprites
        lda     $79
        lsr2
        tax
        lda     HookYTbl,x
        sta     $06f8
        jsr     WaitFrame
        inc     $79
        lda     $79
        cmp     #$20
        bne     @a755
        inc     $06d0
@a755:  cmp     #$40
        bne     @a736
        rts

; ------------------------------------------------------------------------------

; [ land falcon ]

; in falcon, pressed A button

LandFalcon:
@a75a:  lda     #$30
        sta     $79
        stz     $7a
@a760:  jsr     Animate4
        lda     $79
        cmp     #$21
        bcs     @a7ce
        lda     $a2
        and     #$10
        bne     @a772       ; branch if airship can land
        jmp     LiftoffFalcon
@a772:  ldx     $1719
        cpx     $1706
        bne     @a77d
        jmp     LiftoffFalcon
@a77d:  lda     $171f
        cmp     $1723
        bne     @a790
        ldx     $171d
        cpx     $1706
        bne     @a790
        jmp     LiftoffFalcon
@a790:  lda     $1727
        cmp     $1723
        bne     @a7a3
        ldx     $1725
        cpx     $1706
        bne     @a7a3
        jmp     LiftoffFalcon
@a7a3:  lda     $79
        lsr
        sta     $06fd       ; set airship animation speed
        dec     $79
        dec     $79
        bne     @a760
        stz     $1704
        stz     $ac
        stz     $7b
        lda     #$02
        sta     $1705
        ldx     $1706
        stx     $1721
        lda     $1701
        sta     $1723
        jsr     PlayMapSong
        inc     $1a02
        rts
@a7ce:  dec     $b8
        lda     $b8
        clc
        adc     #$10
        sta     $ad
        lda     $b8
        jsl     UpdateZoomPal
        dec     $79
        jmp     @a760

; ------------------------------------------------------------------------------

; [  ]

; in big whale, pressed A button

WhaleButton:
@a7e2:  lda     #$2f
        sta     $79
        stz     $7a
@a7e8:  jsr     Animate4
        lda     $79
        cmp     #$20
        bcs     @a85a
        lda     $a2
        and     #$10
        bne     @a7fa       ; branch if airship can land
        jmp     LiftoffWhale
@a7fa:  ldx     $1719
        cpx     $1706
        bne     @a805       ; can't land on hovercraft
        jmp     LiftoffWhale
@a805:  lda     $171f
        cmp     $1727
        bne     @a818       ; can't land on big whale
        ldx     $171d
        cpx     $1706
        bne     @a818
        jmp     LiftoffWhale
@a818:  lda     $1723
        cmp     $1727
        bne     @a82b       ; can't land on falcon
        ldx     $1721
        cpx     $1706
        bne     @a82b
        jmp     LiftoffWhale
@a82b:  lda     $79
        lsr
        sta     $06fd       ; set airship animation speed
        dec     $79
        bne     @a7e8
        stz     $1704
        stz     $ac
        stz     $7b
        lda     #$02
        sta     $1705
        lda     $1700
        sta     $1727
        ldx     $1706
        stx     $1725
        lda     $b1
        bne     @a856       ; branch if just acquired vehicle
        lda     #$52
        jsr     ExecTriggerScript
@a856:  inc     $1a02
        rts
@a85a:  dec     $b9
        dec     $b9
        lda     $b9
        clc
        adc     #$10
        sta     $ad
        lda     $b9
        lsr
        jsl     UpdateZoomPal
        dec     $79
        jmp     @a7e8

; ------------------------------------------------------------------------------
