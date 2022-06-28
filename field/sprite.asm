
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: sprite.asm                                                           |
; |                                                                            |
; | description: field sprite routines                                         |
; |                                                                            |
; | created: 3/26/2022                                                         |
; +----------------------------------------------------------------------------+

; [ draw player sprite (sub-map) ]

DrawPlayerSub:
@b1e0:  lda     $d3
        beq     @b1e5
        rtl
@b1e5:  phb
        lda     #.bankbyte(*)
        pha
        plb
        lda     $1703
        stz     $4a
        lsr
        ror     $4a
        lsr
        ror     $4a
        sta     $4b
        ldx     $4a
        lda     $1001,x     ; character id
        and     #$1f
        tax
        lda     PlayerPalTbl,x     ; color palette for each character
        asl
        sta     $0710
        lda     $d8
        beq     @b20f
        lda     #$08
        sta     $1705
@b20f:  lda     $1705
        cmp     #$08
        bne     @b220
        lda     $7b
        clc
        adc     #$10
        lsr3
        and     #$03
@b220:  asl4
        sta     $07
        stz     $06
        lda     $1705
        cmp     #$08
        beq     @b24f
        cmp     #$04
        bcs     @b237
        lda     $ab
        beq     @b24f
@b237:  lda     $7b
        and     #$08
        clc
        adc     $07
        sta     $07
        lda     $ab
        and     #$01
        bne     @b24f
        lda     $7b
        and     #$08
        lsr3
        sta     $06
@b24f:  lda     $07
        tax
        ldy     #0
@b255:  lda     PlayerSpritePosTbl,y
        sta     $0470,y
        iny
        lda     PlayerSpritePosTbl,y
        sec
        sbc     $06
        sta     $0470,y
        iny
        lda     PlayerSpriteTiles,x
        sta     $0470,y
        inx
        iny
        lda     PlayerSpriteTiles,x
        and     #$f1
        clc
        adc     $0710
        sta     $0470,y
        inx
        iny
        cpy     #8
        bne     @b255
        ldy     #0
@b284:  lda     PlayerSpritePosTbl+8,y
        sta     $04f0,y
        iny
        lda     PlayerSpritePosTbl+8,y
        sec
        sbc     $06
        sta     $04f0,y
        iny
        lda     PlayerSpriteTiles,x
        sta     $04f0,y
        inx
        iny
        lda     PlayerSpriteTiles,x
        and     #$f1
        clc
        adc     $0710
        sta     $04f0,y
        inx
        iny
        cpy     #8
        bne     @b284
        lda     $a2
        and     #$08
        beq     @b2d6
        lda     $0473
        ora     #$20
        sta     $0473
        lda     $0477
        ora     #$20
        sta     $0477
        lda     $04f3
        and     #$cf
        sta     $04f3
        lda     $04f7
        and     #$cf
        sta     $04f7
@b2d6:  lda     $a2
        and     #$04
        beq     @b2f8
        lda     $a1
        and     #$04
        beq     @b2ea
        lda     $a1
        and     #$03
        and     $d2
        bne     @b2f8
@b2ea:  lda     #$f8
        sta     $0471
        sta     $0475
        sta     $04f1
        sta     $04f5
@b2f8:  plb
        rtl

; ------------------------------------------------------------------------------

; ; color palette for each character (map sprite)
PlayerPalTbl:
@b2fa:  .byte   0,0,1,2,2,2,0,1,1,3,0,1,0,0,0,0,0,0

; ------------------------------------------------------------------------------

; [ draw player sprite (world map) ]

DrawPlayerWorld:
@b30c:  lda     $d3
        beq     @b311
        rtl
@b311:  lda     $ad
        cmp     #$10
        bne     @b31c
        lda     $1704
        beq     @b31d
@b31c:  rtl
@b31d:  phb
        lda     #.bankbyte(*)
        pha
        plb
        lda     $1703
        stz     $4a
        lsr
        ror     $4a
        lsr
        ror     $4a
        sta     $4b
        ldx     $4a
        lda     $1001,x
        and     #$1f
        tax
        lda     PlayerPalTbl,x     ; color palette for each character
        asl
        sta     $0710
        lda     $1705
        asl4
        sta     $07
        stz     $06
        lda     $ab
        beq     @b365
        lda     $7b
        and     #$08
        clc
        adc     $07
        sta     $07
        lda     $ab
        and     #$01
        bne     @b365
        lda     $7b
        and     #$08
        lsr3
        sta     $06
@b365:  lda     $07
        tax
        ldy     #$0000
@b36b:  lda     PlayerSpritePosTbl,y
        sta     $0444,y
        iny
        lda     PlayerSpritePosTbl,y
        sec
        sbc     $06
        sta     $0444,y
        iny
        lda     PlayerSpriteTiles,x
        sta     $0444,y
        inx
        iny
        lda     PlayerSpriteTiles,x
        and     #$f1
        clc
        adc     $0710
        sta     $0444,y
        inx
        iny
        cpy     #$0010
        bne     @b36b
        lda     $a2
        and     #$08
        beq     @b3ad
        lda     $044f
        and     #$cf
        sta     $044f
        lda     $0453
        and     #$cf
        sta     $0453
@b3ad:  plb
        rtl

; ------------------------------------------------------------------------------

; [ set msb of sprite x position ]

SetSpriteMSB:
@b3af:  phx
        phy
        pha
        longa
        tya
        lsr2
        shorta
        sta     $07
        pla
        clc
        adc     $07
        pha
        and     #$03
        tax
        lda     f:SpriteMSBTbl,x
        sta     $07
        pla
        lsr2
        tay
        lda     $0500,y
        ora     $07
        sta     $0500,y
        ply
        plx
        rtl

; ------------------------------------------------------------------------------

; sprite x position msb masks
SpriteMSBTbl:
@b3d8:  .byte   $01,$04,$10,$40

; ------------------------------------------------------------------------------

; [ draw chocobo sprite ]

DrawChoco:
@b3dc:  phb
        lda     #.bankbyte(*)
        pha
        plb
        lda     $170f
        beq     @b3f5
        cmp     #$02
        beq     @b419
        lda     $1701
        bne     @b3f5
        lda     $ad
        cmp     #$10
        beq     @b3f8
@b3f5:  jmp     @b4b5
@b3f8:  lda     $1704
        cmp     #$01
        beq     @b426
        lda     $1710
        sta     $0c
        lda     $1711
        sta     $0e
        jsl     CalcVehicleSpritePos
        lda     $d7
        bne     @b414
        jmp     @b4b5
@b414:  lda     #$03
        jmp     @b435
@b419:  lda     $1710
        sta     $0c
        lda     $1711
        sta     $0e
        jmp     @b42e
@b426:  lda     #$70
        sta     $0c
        lda     #$70
        sta     $0e
@b42e:  stz     $0d
        stz     $0f
        lda     $1705
@b435:  asl5
        sta     $07
        lda     $1704
        cmp     #$01
        bne     @b450
        lda     $ab
        beq     @b452
        lda     $7a
        and     #$04
        asl2
        jmp     @b452
@b450:  lda     #$00
@b452:  clc
        adc     $07
        tax
        ldy     #$0000
@b459:  lda     ChocoSpriteTbl,x
        clc
        adc     $0c
        sta     $0490,y
        lda     $0d
        adc     #$00
        and     #$01
        beq     @b470
        lda     #$64
        jsl     SetSpriteMSB
@b470:  lda     ChocoSpriteTbl+1,x
        clc
        adc     $0e
        sta     $0491,y
        lda     ChocoSpriteTbl+2,x
        sta     $0492,y
        lda     ChocoSpriteTbl+3,x
        sta     $0493,y
        inx4
        iny4
        cpy     #$0010
        bne     @b459
        lda     $1704
        cmp     #$01
        bne     @b4a0
        lda     $a2
        and     #$08
        sta     $170e
@b4a0:  lda     $170e
        beq     @b4b5
        lda     $049b
        and     #$cf
        sta     $049b
        lda     $049f
        and     #$cf
        sta     $049f
@b4b5:  plb
        rtl

; ------------------------------------------------------------------------------

; [  ]

_15b4b7:
@b4b7:  sec
        sbc     #2
        tax
        asl2
        tay
        lda     $0c
        sec
        sbc     #4
        bcs     @b4cd
        lda     #$f8
        sta     $04f1,y
        jmp     @b4d8
@b4cd:  sta     $04f0,y
        lda     $0e
        sec
        sbc     #5
        sta     $04f1,y
@b4d8:  lda     $ad
        lsr4
        dec2
        sta     $06
        txa
        asl
        clc
        adc     $06
        adc     #$30
        sta     $04f2,y
        lda     f:_15b4f5,x
        sta     $04f3,y
        plb
        rtl

; ------------------------------------------------------------------------------

_15b4f5:
@b4f5:  .byte   $1a,$18,$18,$1c

; ------------------------------------------------------------------------------

; [ draw black chocobo sprite ]

DrawBkChoco:
@b4f9:  phb
        lda     #.bankbyte(*)
        pha
        plb
        lda     $1712
        beq     @b527
        lda     $1701
        bne     @b527
        lda     $1704
        cmp     #$02
        beq     @b53a
        lda     $ad
        and     #$0f
        bne     @b527
        lda     $1713
        sta     $0c
        lda     $1714
        sta     $0e
        jsl     CalcVehicleSpritePos
        lda     $d7
        bne     @b52a
@b527:  jmp     @b5ed
@b52a:  lda     $ad
        cmp     #$10
        beq     @b535
        lda     #$02
        jmp     _15b4b7
@b535:  lda     #$03
        jmp     @b552
@b53a:  lda     #$00
        jsl     _15b866
        stz     $0d
        stz     $0f
        lda     #$70
        sta     $0c
        lda     #$70
        sec
        sbc     $b5
        sta     $0e
        lda     $1705
@b552:  asl5
        sta     $07
        lda     $1704
        cmp     #$02
        bne     @b569
        lda     $7a
        and     #$04
        asl2
        jmp     @b56b
@b569:  lda     #0
@b56b:  clc
        adc     $07
        tax
        ldy     #0
@b572:  lda     VehicleSpriteTbl,x
        clc
        adc     $0c
        sta     $0414,y
        lda     $0d
        adc     #0
        and     #1
        beq     @b589
        lda     #$45
        jsl     SetSpriteMSB
@b589:  lda     VehicleSpriteTbl+1,x
        clc
        adc     $0e
        sta     $0415,y
        lda     VehicleSpriteTbl+2,x
        clc
        adc     #$90
        sta     $0416,y
        lda     VehicleSpriteTbl+3,x
        clc
        adc     #$1a
        sta     $0417,y
        inx4
        iny4
        cpy     #$0010
        bne     @b572
        lda     $1704
        cmp     #$02
        beq     @b5c3
        lda     #$f8
        sta     $041d
        sta     $0421
        jmp     @b5ed
@b5c3:  lda     $a1
        and     #$08
        beq     @b5ed
        lda     #$70
        sta     $040c
        lda     #$78
        sta     $040d
        lda     #$43
        sta     $040e
        stz     $040f
        lda     #$78
        sta     $0410
        lda     #$78
        sta     $0411
        lda     #$43
        sta     $0412
        stz     $0413
@b5ed:  plb
        rtl

; ------------------------------------------------------------------------------

; [ draw dwarf tank sprites ]

DrawTank:
@b5ef:  phb
        lda     #.bankbyte(*)
        pha
        plb
        lda     $1701
        cmp     #$01
        bne     @b663
        stz     $0b
@b5fd:  lda     $0b
        tax
        lda     TankXTbl,x
        sta     $0c
        lda     TankYTbl,x
        sta     $0e
        jsl     CalcVehicleSpritePos
        lda     $d7
        beq     @b65b
        ldx     #0
        lda     $0b
        asl4
        tay
@b61c:  lda     VehicleSpriteTbl,x
        clc
        adc     $0c
        sta     $0480,y
        lda     $0d
        adc     #$00
        and     #$01
        beq     @b633
        lda     #$60
        jsl     SetSpriteMSB
@b633:  lda     VehicleSpriteTbl+1,x
        clc
        adc     $0e
        sta     $0481,y
        lda     VehicleSpriteTbl+2,x
        clc
        adc     #$a8
        sta     $0482,y
        lda     VehicleSpriteTbl+3,x
        clc
        adc     #$18
        sta     $0483,y
        inx4
        iny4
        cpx     #$0010
        bne     @b61c
@b65b:  inc     $0b
        lda     $0b
        cmp     #5
        bne     @b5fd
@b663:  plb
        rtl

; ------------------------------------------------------------------------------

; dwarf tank x positions
TankXTbl:
@b665:  .byte   $2e,$2f,$30,$31,$32
; dwarf tank y positions
TankYTbl:
@b66a:  .byte   $13,$14,$13,$14,$13

; ------------------------------------------------------------------------------

; [ draw ship sprite ]

DrawShip:
@b66f:  phb
        lda     #.bankbyte(*)
        pha
        plb
        lda     $1728
        beq     @b697
        lda     $1701
        bne     @b697
        lda     $1704
        cmp     #$07
        beq     @b69f
        lda     $1729
        sta     $0c
        lda     $172a
        sta     $0e
        jsl     CalcVehicleSpritePos
        lda     $d7
        bne     @b69a
@b697:  jmp     @b70d
@b69a:  lda     #$00
        jmp     @b6ae
@b69f:  stz     $0d
        stz     $0f
        lda     #$70
        sta     $0c
        lda     #$70
        sta     $0e
        lda     $1705
@b6ae:  asl5
        sta     $07
        lda     $1704
        cmp     #$07
        bne     @b6c5
        lda     $7a
        and     #$04
        asl2
        jmp     @b6c7
@b6c5:  lda     #$00
@b6c7:  clc
        adc     $07
        tax
        ldy     #0
@b6ce:  lda     VehicleSpriteTbl,x
        clc
        adc     $0c
        sta     $0480,y
        lda     $0d
        adc     #$00
        and     #$01
        beq     @b6e5
        lda     #$60
        jsl     SetSpriteMSB
@b6e5:  lda     VehicleSpriteTbl+1,x
        clc
        adc     $0e
        sta     $0481,y
        lda     VehicleSpriteTbl+2,x
        clc
        adc     #$60
        sta     $0482,y
        lda     VehicleSpriteTbl+3,x
        clc
        adc     #$18
        sta     $0483,y
        inx4
        iny4
        cpy     #$0010
        bne     @b6ce
@b70d:  plb
        rtl

; ------------------------------------------------------------------------------

; [ draw hovercraft sprite ]

DrawHover:
@b70f:  phb
        lda     #.bankbyte(*)
        pha
        plb
        lda     $1718
        beq     @b748
        lda     $1701
        cmp     $171b
        bne     @b748
        lda     $1704
        cmp     #$03
        beq     @b75b
        lda     $06d0
        beq     @b730
        jmp     @b7d6
@b730:  lda     $ad
        and     #$0f
        bne     @b748
        lda     $1719
        sta     $0c
        lda     $171a
        sta     $0e
        jsl     CalcVehicleSpritePos
        lda     $d7
        bne     @b74b
@b748:  jmp     @b814
@b74b:  lda     $ad
        cmp     #$10
        beq     @b756
        lda     #$03
        jmp     _15b4b7
@b756:  lda     #$03
        jmp     @b773
@b75b:  lda     #$00
        jsl     _15b866
        stz     $0d
        stz     $0f
        lda     #$70
        sta     $0c
        lda     #$70
        sec
        sbc     $b6
        sta     $0e
        lda     $1705
@b773:  asl5
        sta     $07
        lda     $1704
        cmp     #$03
        bne     @b78b
        lda     $7a
        and     #$02
        asl3
        jmp     @b78d
@b78b:  lda     #0
@b78d:  clc
        adc     $07
        tax
        ldy     #0
@b794:  lda     VehicleSpriteTbl,x
        clc
        adc     $0c
        sta     $0480,y
        lda     $0d
        adc     #$00
        and     #$01
        beq     @b7ab
        lda     #$60
        jsl     SetSpriteMSB
@b7ab:  lda     VehicleSpriteTbl+1,x
        clc
        adc     $0e
        sta     $0481,y
        lda     VehicleSpriteTbl+2,x
        clc
        adc     #$48
        sta     $0482,y
        lda     VehicleSpriteTbl+3,x
        clc
        adc     #$18
        sta     $0483,y
        inx4
        iny4
        cpy     #$0010
        bne     @b794
        jmp     @b814
@b7d6:  lda     $06f8
        bne     @b7e5
        lda     $1705
        asl4
        jmp     @b7e7
@b7e5:  lda     #$40
@b7e7:  tax
        ldy     #0
@b7eb:  lda     HoverSpriteTbl,x
        sta     $0480,y
        lda     HoverSpriteTbl+1,x
        clc
        adc     $06f8
        sta     $0481,y
        lda     HoverSpriteTbl+2,x
        sta     $0482,y
        lda     HoverSpriteTbl+3,x
        sta     $0483,y
        inx4
        iny4
        cpy     #$0010
        bne     @b7eb
@b814:  plb
        rtl

; ------------------------------------------------------------------------------

; ??? hovercraft sprite data
HoverSpriteTbl:
@b816:  .byte   $70,$6a,$c0,$2a
        .byte   $78,$6a,$c1,$2a
        .byte   $70,$72,$c2,$2a
        .byte   $78,$72,$c3,$2a

        .byte   $70,$6a,$c4,$2a
        .byte   $78,$6a,$c5,$2a
        .byte   $70,$72,$c6,$2a
        .byte   $78,$72,$c7,$2a

        .byte   $70,$6a,$c8,$2a
        .byte   $78,$6a,$c9,$2a
        .byte   $70,$72,$ca,$2a
        .byte   $78,$72,$cb,$2a

        .byte   $70,$6a,$cc,$2a
        .byte   $78,$6a,$cd,$2a
        .byte   $70,$72,$ce,$2a
        .byte   $78,$72,$cf,$2a

        .byte   $70,$6a,$2a,$2b
        .byte   $78,$6a,$2b,$2b
        .byte   $70,$72,$2c,$2b
        .byte   $78,$72,$2d,$2b

; ------------------------------------------------------------------------------

; [  ]

_15b866:
@b866:  cmp     #$10
        bcc     @b86c
        lda     #$10
@b86c:  and     #$fc
        tax
        cmp     #$10
        beq     @b879
        lda     $7a         ; animation frame counter
        and     #$01
        bne     @b8c8
@b879:  lda     $c8
        bne     @b8c8
        lda     $a1
        and     #$08
        bne     @b889
        lda     $a1
        and     #$04
        bne     @b88e
@b889:  lda     #$fe
        jmp     @b890
@b88e:  lda     #$00
@b890:  sta     $06
        lda     #$70
        sta     $04c0
        lda     #$78
        clc
        adc     $06
        sta     $04c1
        lda     f:_15b8c9,x
        sta     $04c2
        lda     f:_15b8c9+1,x
        sta     $04c3
        lda     #$78
        sta     $04c4
        lda     #$78
        clc
        adc     $06
        sta     $04c5
        lda     f:_15b8c9+2,x
        sta     $04c6
        lda     f:_15b8c9+3,x
        sta     $04c7
@b8c8:  rtl

; ------------------------------------------------------------------------------

_15b8c9:
@b8c9:  .byte   $3b,$28,$3b,$68,$3a,$28,$3a,$68,$39,$28,$39,$68,$38,$28,$38,$68
        .byte   $38,$28,$38,$68

; ------------------------------------------------------------------------------

; [ draw enterprise sprite ]

DrawEnterprise:
@b8dd:  phb
        lda     #.bankbyte(*)
        pha
        plb
        lda     $1704
        cmp     #$04
        beq     @b921
        lda     $171c
        beq     @b90e
        lda     $1701
        cmp     $171f
        bne     @b90e
        lda     $ad
        and     #$0f
        bne     @b90e
        lda     $171d
        sta     $0c
        lda     $171e
        sta     $0e
        jsl     CalcVehicleSpritePos
        lda     $d7
        bne     @b911
@b90e:  jmp     @b9ca
@b911:  lda     $ad
        cmp     #$10
        beq     @b91c
        lda     #$04
        jmp     _15b4b7
@b91c:  lda     #$03
        jmp     @b939
@b921:  lda     $b7
        jsl     _15b866
        lda     #$70
        sta     $0c
        lda     #$70
        sec
        sbc     $b7
        sta     $0e
        stz     $0d
        stz     $0f
        lda     $1705
@b939:  asl5
        sta     $07
        lda     $1704
        cmp     #$04
        bne     @b957
        lda     $06fd       ; set airship animation speed
        tax
        lda     $7a
        and     AirshipAnimMask,x
        bne     @b957
        lda     #$10
        jmp     @b959
@b957:  lda     #$00
@b959:  clc
        adc     $07
        tax
        ldy     #0
@b960:  lda     VehicleSpriteTbl,x
        clc
        adc     $0c
        sta     $046c,y
        lda     $0d
        adc     #$00
        and     #$01
        beq     @b977
        lda     #$5b
        jsl     SetSpriteMSB
@b977:  lda     VehicleSpriteTbl+1,x
        clc
        adc     $0e
        sta     $046d,y
        lda     VehicleSpriteTbl+2,x
        clc
        adc     #$78
        sta     $046e,y
        lda     VehicleSpriteTbl+3,x
        clc
        adc     #$18
        sta     $046f,y
        inx4
        iny4
        cpy     #$0010
        bne     @b960
        lda     $1704
        cmp     #$04
        bne     @b9ca
        lda     $ad
        cmp     #$20
        bne     @b9ca
        lda     $b7
        cmp     #$10
        bne     @b9ca
        lda     #$74
        sta     $047c
        lda     $06f8
        clc
        adc     #$68
        sta     $047d
        lda     #$2e
        sta     $047e
        lda     #$21
        sta     $047f
@b9ca:  plb
        rtl

; ------------------------------------------------------------------------------

; [ draw falcon sprite ]

DrawFalcon:
@b9cc:  phb
        lda     #.bankbyte(*)
        pha
        plb
        lda     $1704
        cmp     #$05
        beq     @ba10
        lda     $1720
        beq     @b9fd
        lda     $1701
        cmp     $1723
        bne     @b9fd
        lda     $ad
        and     #$0f
        bne     @b9fd                   ; don't draw if zooming
        lda     $1721
        sta     $0c
        lda     $1722
        sta     $0e
        jsl     CalcVehicleSpritePos
        lda     $d7
        bne     @ba00
@b9fd:  jmp     @bb12
@ba00:  lda     $ad
        cmp     #$10
        beq     @ba0b
        lda     #$05
        jmp     _15b4b7
@ba0b:  lda     #$03
        jmp     @ba28
@ba10:  lda     $b8
        jsl     _15b866
        lda     #$70
        sta     $0c
        lda     #$70
        sec
        sbc     $b8
        sta     $0e
        stz     $0d
        stz     $0f
        lda     $1705
@ba28:  asl5
        sta     $07
        lda     $1704
        cmp     #$05
        bne     @ba46
        lda     $06fd       ; set airship animation speed
        tax
        lda     $7a
        and     AirshipAnimMask,x
        bne     @ba46
        lda     #$10
        jmp     @ba48
@ba46:  lda     #$00
@ba48:  clc
        adc     $07
        tax
        ldy     #0
@ba4f:  lda     VehicleSpriteTbl,x
        clc
        adc     $0c
        sta     $0458,y
        lda     $0d
        adc     #$00
        and     #$01
        beq     @ba66
        lda     #$56
        jsl     SetSpriteMSB
@ba66:  lda     VehicleSpriteTbl+1,x
        clc
        adc     $0e
        sta     $0459,y
        lda     VehicleSpriteTbl+2,x
        clc
        adc     #$d8
        sta     $045a,y
        lda     VehicleSpriteTbl+3,x
        clc
        adc     #$1c
        sta     $045b,y
        inx4
        iny4
        cpy     #$0010
        bne     @ba4f
        lda     $1287
        and     #$20
        beq     @bb12
        lda     $1704
        cmp     #$05
        beq     @baa5
        lda     $ad
        cmp     #$10
        beq     @baab
        jmp     @bb12
@baa5:  lda     $1705
        jmp     @baad
@baab:  lda     #$03
@baad:  sta     $07
        tax
        lda     f:_15bb14,x
        tay
        lda     $07
        asl3
        sta     $07
        lda     $1704
        cmp     #5
        bne     @bad3
        lda     $06fd       ; set airship animation speed
        tax
        lda     $7a         ; animation frame counter
        and     AirshipAnimMask,x
        beq     @bad3
        lda     #$04
        jmp     @bad5
@bad3:  lda     #$00
@bad5:  clc
        adc     $07
        tax
        lda     $0c
        sec
        sbc     #$08
        sta     $0c
        lda     $0d
        sbc     #$00
        sta     $0d
        lda     $0c
        clc
        adc     _15bb18,x
        sta     $0454,y
        lda     $0d
        adc     #$00
        and     #$01
        beq     @bafd
        lda     #$55
        jsl     SetSpriteMSB
@bafd:  lda     $0e
        clc
        adc     _15bb18+1,x
        sta     $0455,y
        lda     _15bb18+2,x
        sta     $0456,y
        lda     _15bb18+3,x
        sta     $0457,y
@bb12:  plb
        rtl

; ------------------------------------------------------------------------------


_15bb14:
@bb14:  .byte   $14,$00,$00,$00

; ??? falcon sprite data
_15bb18:
@bb18:  .byte   $0c,$fc,$f4,$3c
        .byte   $0c,$fc,$f5,$3c
        .byte   $18,$08,$f0,$7c
        .byte   $18,$08,$f1,$7c
        .byte   $0d,$0d,$f2,$3c
        .byte   $0d,$0d,$f3,$3c
        .byte   $00,$08,$f0,$3c
        .byte   $00,$08,$f1,$3c

; ------------------------------------------------------------------------------

; [ unused ]

_15bb38:
@bb38:  rtl

; ------------------------------------------------------------------------------

; [  ]

_15bb39:
@bb39:  phb
        lda     #.bankbyte(*)
        pha
        plb
        lda     $c8
        bne     @bb68
        lda     $7a
        and     #$01
        bne     @bb68
        lda     $b9
        sec
        sbc     #$10
        cmp     #$10
        bne     @bb52
        dec
@bb52:  and     #$0c
        asl3
        tax
        ldy     #0
@bb5b:  lda     _15bb6a,x
        sta     $04c0,y
        inx
        iny
        cpy     #$0020
        bne     @bb5b
@bb68:  plb
        rtl

; ------------------------------------------------------------------------------

_15bb6a:
@bb6a:  .byte   $68,$72,$42,$28
        .byte   $70,$72,$43,$28
        .byte   $78,$72,$43,$68
        .byte   $80,$72,$42,$68
        .byte   $68,$7a,$42,$a8
        .byte   $70,$7a,$43,$a8
        .byte   $78,$7a,$43,$e8
        .byte   $80,$7a,$42,$e8

        .byte   $68,$72,$40,$28
        .byte   $70,$72,$41,$28
        .byte   $78,$72,$41,$68
        .byte   $80,$72,$40,$68
        .byte   $68,$7a,$40,$a8
        .byte   $70,$7a,$41,$a8
        .byte   $78,$7a,$41,$e8
        .byte   $80,$7a,$40,$e8

        .byte   $68,$72,$3e,$28
        .byte   $70,$72,$3f,$28
        .byte   $78,$72,$3f,$68
        .byte   $80,$72,$3e,$68
        .byte   $68,$7a,$3e,$a8
        .byte   $70,$7a,$3f,$a8
        .byte   $78,$7a,$3f,$e8
        .byte   $80,$7a,$3e,$e8

        .byte   $68,$72,$3c,$28
        .byte   $70,$72,$3d,$28
        .byte   $78,$72,$3d,$68
        .byte   $80,$72,$3c,$68
        .byte   $68,$7a,$3c,$a8
        .byte   $70,$7a,$3d,$a8
        .byte   $78,$7a,$3d,$e8
        .byte   $80,$7a,$3c,$e8

; ------------------------------------------------------------------------------

; [ draw big whale sprite (zoomed out) ]

DrawWhaleZoom:
@bbea:  lda     $0e
        sec
        sbc     #$08
        sta     $0e
        ldx     #0
@bbf4:  lda     _15bc1f,x
        clc
        adc     $0c
        bcs     @bc14
        sta     $04e0,x
        lda     _15bc1f+1,x
        clc
        adc     $0e
        sta     $04e1,x
        lda     _15bc1f+2,x
        sta     $04e2,x
        lda     _15bc1f+3,x
        sta     $04e3,x
@bc14:  inx4
        cpx     #$0010
        bne     @bbf4
        plb
        rtl

; ------------------------------------------------------------------------------

_15bc1f:
@bc1f:  .byte   $00,$00,$44,$3e
        .byte   $08,$00,$45,$3e
        .byte   $00,$08,$46,$3e
        .byte   $08,$08,$47,$3e

; ------------------------------------------------------------------------------

; [ draw big whale sprite ]

DrawWhale:
@bc2f:  phb
        lda     #.bankbyte(*)
        pha
        plb
        lda     $1704
        cmp     #$06
        bne     @bc3e       ; branch if player is not in big whale
        jmp     @bcd3
@bc3e:  lda     $1724
        beq     @bcc2
        lda     $1701
        cmp     $1727
        bne     @bcc2
        lda     $ad
        and     #$0f
        bne     @bcc2
        lda     $1725
        dec
        sta     $0c
        lda     $1726
        dec
        sta     $0e
        lda     $1700
        cmp     #$02
        bne     @bcba
        lda     $1725
        sta     $0c
        lda     $1726
        sta     $0e
        lda     $1706
        cmp     #$08
        bcs     @bc83
        lda     $0c
        cmp     #$30
        bcc     @bc92
        sec
        sbc     #$40
        sta     $0c
        jmp     @bc92
@bc83:  cmp     #$38
        bcc     @bc92
        lda     $0c
        cmp     #$10
        bcs     @bc92
        clc
        adc     #$40
        sta     $0c
@bc92:  lda     $1707
        cmp     #$08
        bcs     @bca7
        lda     $0e
        cmp     #$30
        bcc     @bcb6
        sec
        sbc     #$40
        sta     $0e
        jmp     @bcb6
@bca7:  cmp     #$38
        bcc     @bcb6
        lda     $0e
        cmp     #$10
        bcs     @bcb6
        clc
        adc     #$40
        sta     $0e
@bcb6:  dec     $0c
        dec     $0e
@bcba:  jsl     CalcVehicleSpritePos
        lda     $d7
        bne     @bcc5
@bcc2:  jmp     @bd95
@bcc5:  lda     $ad
        cmp     #$10
        beq     @bcce
        jmp     DrawWhaleZoom
@bcce:  lda     #$03
        jmp     @bcff
@bcd3:  lda     $b9
        cmp     #$10
        bcs     @bce0
        jsl     _15bb39
        jmp     @bced
@bce0:  sec
        sbc     #$10
        cmp     #$10
        bcc     @bce9
        lda     #$10
@bce9:  jsl     _15b866
@bced:  lda     #$60
        sta     $0c
        lda     #$60
        sec
        sbc     $b9
        sta     $0e
        stz     $0d
        stz     $0f
        lda     $1705       ; player facing direction
@bcff:  asl5
        sta     $07
        lda     $07
        tax
        stx     $40
        ldy     #0
        sty     $43
@bd10:  ldx     $43
        lda     WhaleSpritePos,x
        clc
        adc     $0c
        sta     $0424,y
        lda     $0d
        adc     #$00
        and     #$01
        beq     @bd29
        lda     #$49
        jsl     SetSpriteMSB
@bd29:  lda     WhaleSpritePos+1,x
        clc
        adc     $0e
        sta     $0425,y
        ldx     $40
        lda     WhaleSpriteTiles,x
        sta     $0426,y
        lda     WhaleSpriteTiles+1,x
        sta     $0427,y
        inc     $40
        inc     $40
        inc     $43
        inc     $43
        iny4
        cpy     #$0020
        bne     @bd10
        ldy     #0
@bd54:  ldx     $43
        lda     WhaleSpritePos,x     ; x position
        clc
        adc     $0c
        sta     $04a0,y
        lda     $0d
        adc     #$00
        and     #$01
        beq     @bd6d
        lda     #$68
        jsl     SetSpriteMSB
@bd6d:  lda     WhaleSpritePos+1,x     ; y position
        clc
        adc     $0e
        sta     $04a1,y
        ldx     $40
        lda     WhaleSpriteTiles,x
        sta     $04a2,y
        lda     WhaleSpriteTiles+1,x
        sta     $04a3,y
        inc     $40
        inc     $40
        inc     $43
        inc     $43
        iny4
        cpy     #$0020
        bne     @bd54
@bd95:  plb
        rtl

; ------------------------------------------------------------------------------

; big whale sprite xy positions
WhaleSpritePos:
@bd97:  .byte   $08,$fd
        .byte   $10,$fd
        .byte   $18,$fd
        .byte   $20,$fd
        .byte   $08,$05
        .byte   $10,$05
        .byte   $18,$05
        .byte   $20,$05
        .byte   $08,$0d
        .byte   $10,$0d
        .byte   $18,$0d
        .byte   $20,$0d
        .byte   $08,$15
        .byte   $10,$15
        .byte   $18,$15
        .byte   $20,$15

; big whale sprite tile id and flags
WhaleSpriteTiles:
; up
@bdb7:  .byte   $0a,$2f
        .byte   $0b,$2f
        .byte   $0c,$2f
        .byte   $0a,$6f
        .byte   $0e,$2f
        .byte   $0f,$2f
        .byte   $10,$2f
        .byte   $0e,$6f
        .byte   $12,$2f
        .byte   $13,$2f
        .byte   $14,$2f
        .byte   $12,$6f
        .byte   $16,$2f
        .byte   $17,$2f
        .byte   $18,$2f
        .byte   $19,$2f
; right
@bdd7:  .byte   $1d,$6f
        .byte   $0d,$6f
        .byte   $1b,$6f
        .byte   $1a,$6f
        .byte   $21,$6f
        .byte   $20,$6f
        .byte   $1f,$6f
        .byte   $1e,$6f
        .byte   $25,$6f
        .byte   $24,$6f
        .byte   $23,$6f
        .byte   $22,$6f
        .byte   $0d,$6f
        .byte   $28,$6f
        .byte   $27,$6f
        .byte   $26,$6f
; down
@bdf7:  .byte   $fa,$2e
        .byte   $fb,$2e
        .byte   $fc,$2e
        .byte   $fa,$6e
        .byte   $fe,$2e
        .byte   $ff,$2e
        .byte   $00,$2f
        .byte   $0d,$6f
        .byte   $02,$2f
        .byte   $03,$2f
        .byte   $04,$2f
        .byte   $02,$6f
        .byte   $06,$2f
        .byte   $07,$2f
        .byte   $08,$2f
        .byte   $06,$6f
; left
@be17:  .byte   $1a,$2f
        .byte   $1b,$2f
        .byte   $0d,$2f
        .byte   $1d,$2f
        .byte   $1e,$2f
        .byte   $1f,$2f
        .byte   $20,$2f
        .byte   $21,$2f
        .byte   $22,$2f
        .byte   $23,$2f
        .byte   $24,$2f
        .byte   $25,$2f
        .byte   $26,$2f
        .byte   $27,$2f
        .byte   $28,$2f
        .byte   $0d,$2f

; airship animation speed frame masks
AirshipAnimMask:
@be37:  .byte   $10,$10,$10,$08,$08,$08,$08,$04,$08,$04,$04,$04,$02,$02,$02,$02

; ------------------------------------------------------------------------------

; [ calculate vehicle sprite position ]

CalcVehicleSpritePos:
@be47:  phb
        lda     #.bankbyte(*)
        pha
        plb
        stz     $d7
        lda     $ad
        lsr4
        dec
        tay
        lda     $0c
        clc
        adc     ZoomVehicleTbl,y
        sec
        sbc     $1706
        cmp     ZoomVehicleTbl+3,y
        bcc     @be68
        jmp     @bfa6
@be68:  sta     $0c
        cpy     #0
        bne     @be8c
        dec2
        asl4
        rol     $0d
        sta     $0c
        lda     $5a
        and     #$0f
        sta     $06
        lda     $0c
        sec
        sbc     $06
        sta     $0c
        lda     $0d
        sbc     #$00
        sta     $0d
@be8c:  lda     $0e
        clc
        adc     ZoomVehicleTbl+6,y
        sec
        sbc     $1707
        cmp     ZoomVehicleTbl+9,y
        bcc     @be9e
        jmp     @bfa6
@be9e:  sta     $0e
        cpy     #0
        bne     @beb9
        dec
        asl4
        sta     $0e
        lda     $5c
        and     #$0f
        sta     $06
        lda     $0e
        sec
        sbc     $06
        sta     $0e
@beb9:  cpy     #0
        bne     @bec1
        jmp     @bfa4
@bec1:  stz     $0a
        cpy     #2
        beq     @bf28
        lda     $5c
        and     #$0f
        bne     @bed8
        lda     $0e
        tax
        lda     f:_14f380,x
        jmp     @bef0
@bed8:  lda     $0e
        bne     @bedf
        jmp     @bfa6
@bedf:  dec
        tax
        lda     f:_14f380+1,x
        sec
        sbc     f:_14f380,x
        lsr
        clc
        adc     f:_14f380,x
@bef0:  sta     $0e
        sta     $18
        stz     $19
        asl     $18
        rol     $19
        ldx     $18
        lda     f:_14f000,x
        sta     $18
        lda     f:_14f000+1,x
        sta     $19
        lda     $5a
        and     #$08
        lsr3
        sta     $1a
        lda     $0c
        asl
        sec
        sbc     $1a
        sec
        sbc     #$26
        bpl     @bf21
        inc     $0a
        eor     #$ff
        inc
@bf21:  sta     $1a
        stz     $1b
        jmp     @bf85
@bf28:  lda     $5c
        and     #$0f
        bne     @bf38
        lda     $0e
        tax
        lda     f:_14f3a1,x            ; airship zoom level
        jmp     @bf50
@bf38:  lda     $0e
        bne     @bf3f
        jmp     @bfa6
@bf3f:  dec
        tax
        lda     f:_14f3a1+1,x
        sec
        sbc     f:_14f3a1,x
        lsr
        clc
        adc     f:_14f3a1,x
@bf50:  sta     $0e
        sta     $18
        stz     $19
        asl     $18
        rol     $19
        ldx     $18
        lda     f:_14f1c0,x            ; big whale zoom level
        sta     $18
        lda     f:_14f1c0+1,x
        sta     $19
        lda     $5a
        and     #$08
        lsr3
        sta     $1a
        lda     $0c
        asl
        sec
        sbc     $1a
        sec
        sbc     #$40
        bpl     @bf81
        inc     $0a
        eor     #$ff
        inc
@bf81:  sta     $1a
        stz     $1b
@bf85:  jsl     Mult16
        lsr     $32
        ror     $31
        lda     $0a
        bne     @bf9b
        lda     $31
        clc
        adc     #$78
        bcs     @bfa6
        jmp     @bfa2
@bf9b:  lda     #$78
        sec
        sbc     $31
        bcc     @bfa6
@bfa2:  sta     $0c
@bfa4:  inc     $d7                     ; sprite is off-screen
@bfa6:  plb
        rtl

; ------------------------------------------------------------------------------

ZoomVehicleTbl:
@bfa8:  .byte   $09,$13,$20
        .byte   $13,$2c,$42
        .byte   $08,$17,$1f
        .byte   $10,$21,$2c

VehicleSpriteTbl:
@bfb4:  .byte   $00,$00,$08,$20
        .byte   $08,$00,$09,$20
        .byte   $00,$08,$0a,$20
        .byte   $08,$08,$0b,$20

        .byte   $00,$00,$0c,$20
        .byte   $08,$00,$0d,$20
        .byte   $00,$08,$0e,$20
        .byte   $08,$08,$0f,$20

        .byte   $00,$00,$11,$60
        .byte   $08,$00,$10,$60
        .byte   $00,$08,$13,$60
        .byte   $08,$08,$12,$60

        .byte   $00,$00,$15,$60
        .byte   $08,$00,$14,$60
        .byte   $00,$08,$17,$60
        .byte   $08,$08,$16,$60

        .byte   $00,$00,$00,$20
        .byte   $08,$00,$01,$20
        .byte   $00,$08,$02,$20
        .byte   $08,$08,$03,$20

        .byte   $00,$00,$04,$20
        .byte   $08,$00,$05,$20
        .byte   $00,$08,$06,$20
        .byte   $08,$08,$07,$20

        .byte   $00,$00,$10,$20
        .byte   $08,$00,$11,$20
        .byte   $00,$08,$12,$20
        .byte   $08,$08,$13,$20

        .byte   $00,$00,$14,$20
        .byte   $08,$00,$15,$20
        .byte   $00,$08,$16,$20
        .byte   $08,$08,$17,$20

ChocoSpriteTbl:
@c034:  .byte   $00,$00,$24,$38
        .byte   $08,$00,$25,$38
        .byte   $00,$08,$26,$38
        .byte   $08,$08,$27,$38

        .byte   $00,$00,$25,$78
        .byte   $08,$00,$24,$78
        .byte   $00,$08,$27,$78
        .byte   $08,$08,$26,$78

        .byte   $00,$00,$29,$78
        .byte   $08,$00,$28,$78
        .byte   $00,$08,$2b,$78
        .byte   $08,$08,$2a,$78

        .byte   $00,$00,$2d,$78
        .byte   $08,$00,$2c,$78
        .byte   $00,$08,$2f,$78
        .byte   $08,$08,$2e,$78

        .byte   $00,$00,$20,$38
        .byte   $08,$00,$21,$38
        .byte   $00,$08,$22,$38
        .byte   $08,$08,$23,$38

        .byte   $00,$00,$21,$78
        .byte   $08,$00,$20,$78
        .byte   $00,$08,$23,$78
        .byte   $08,$08,$22,$78

        .byte   $00,$00,$28,$38
        .byte   $08,$00,$29,$38
        .byte   $00,$08,$2a,$38
        .byte   $08,$08,$2b,$38

        .byte   $00,$00,$2c,$38
        .byte   $08,$00,$2d,$38
        .byte   $00,$08,$2e,$38
        .byte   $08,$08,$2f,$38

PlayerSpritePosTbl:
@c0b4:  .byte   $70,$6d,$00,$00
        .byte   $78,$6d,$00,$00
@c0bc:  .byte   $70,$75,$00,$00
        .byte   $78,$75,$00,$00

PlayerSpriteTiles:
@c0c4:  .byte   $04,$20,$05,$20,$06,$20,$07,$20
        .byte   $04,$20,$05,$20,$07,$60,$06,$60
        .byte   $09,$60,$08,$60,$0b,$60,$0a,$60
        .byte   $0d,$60,$0c,$60,$0f,$60,$0e,$60
        .byte   $00,$20,$01,$20,$02,$20,$03,$20
        .byte   $00,$20,$01,$20,$03,$60,$02,$60
        .byte   $08,$20,$09,$20,$0a,$20,$0b,$20
        .byte   $0c,$20,$0d,$20,$0e,$20,$0f,$20
        .byte   $14,$20,$15,$20,$16,$20,$17,$20
        .byte   $18,$20,$19,$20,$1a,$20,$1b,$20
        .byte   $18,$20,$19,$20,$1a,$20,$1b,$20
        .byte   $18,$20,$19,$20,$1a,$20,$1b,$20
        .byte   $10,$20,$11,$20,$12,$20,$13,$20
        .byte   $10,$20,$11,$20,$12,$20,$13,$20
        .byte   $1c,$20,$1d,$20,$1e,$20,$1f,$20
        .byte   $1c,$20,$1d,$20,$1e,$20,$1f,$20

; ------------------------------------------------------------------------------

; [  ]

_15c144:
@c144:
        lda     $128a       ; check event switch $56
        and     #$40
        bne     @c162
        ldx     #$5a00
        stx     $4c
        ldx     #$0600
        stx     $4e
        ldx     #$9e00      ; 1c/9e00
        stx     $4a
        lda     #$1c
        sta     $49
        jsl     Tfr3bppGfx
@c162:  rtl

; ------------------------------------------------------------------------------
