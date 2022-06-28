
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: move.asm                                                             |
; |                                                                            |
; | description: player movement routines                                      |
; |                                                                            |
; | created: 3/26/2022                                                         |
; +----------------------------------------------------------------------------+

; [ move player ]

MovePlayer:
@a871:  lda     $ab
        bne     @a878
        jmp     @a940       ; return if player is not moving
@a878:  lda     $c1
        beq     @a884       ; branch if no floor damage
        lda     $7b
        and     #$08
        bne     @a884
        inc     $c4         ; invert map colors every 8 frames
@a884:  inc     $7b         ; increment party frame counter
        lda     $ac         ; party movement speed
        tax
        lda     $ab
        cmp     #$01
        bne     @a8bc
; up
        lda     $5c         ; bg1 vertical scroll
        sta     $06
        sec
        sbc     PlayerMoveRateTbl,x     ; subtract movement speed
        sta     $5c
        lda     $5d
        sbc     #$00
        and     #$07
        sta     $5d
        lda     $06
        and     #$0f
        sec
        sbc     PlayerMoveRateTbl,x
        bcs     @a8e4
        lda     $06fa       ; map size mask id
        tax
        lda     $1707       ; decrement y position
        dec
        and     MapSizeMask,x     ; size mask
        sta     $1707
        jmp     @a940
; right
@a8bc:  cmp     #$02
        bne     @a8e7
        lda     $5a
        clc
        adc     PlayerMoveRateTbl,x
        sta     $5a
        lda     $5b
        adc     #$00
        and     #$07
        sta     $5b
        lda     $5a
        and     #$0f
        bne     @a940
        lda     $06fa
        tax
        lda     $1706
        inc
        and     MapSizeMask,x
        sta     $1706
@a8e4:  jmp     @a940
; down
@a8e7:  cmp     #$03
        bne     @a912
        lda     $5c
        clc
        adc     PlayerMoveRateTbl,x
        sta     $5c
        lda     $5d
        adc     #$00
        and     #$07
        sta     $5d
        lda     $5c
        and     #$0f
        bne     @a940
        lda     $06fa
        tax
        lda     $1707
        inc
        and     MapSizeMask,x
        sta     $1707
        jmp     @a940
; left
@a912:  cmp     #$04
        bne     @a940
        lda     $5a
        sta     $06
        sec
        sbc     PlayerMoveRateTbl,x
        sta     $5a
        lda     $5b
        sbc     #$00
        and     #$07
        sta     $5b
        lda     $06
        and     #$0f
        sec
        sbc     PlayerMoveRateTbl,x
        bcs     @a940
        lda     $06fa
        tax
        lda     $1706
        dec
        and     MapSizeMask,x
        sta     $1706
@a940:  rts

; ------------------------------------------------------------------------------

; [ check player movement (sub-map) ]

CheckPlayerMoveSub:
@a941:  lda     $d5
        bne     @a948       ; return if player control is disabled
        jmp     @aa3f
@a948:  stz     $c4
        jsr     UpdateLocalTiles
        lda     $b1
        beq     @a959
        lda     $04
        sta     $02
        lda     $05
        sta     $03
@a959:  lda     $a1
        and     #$04
        bne     @a965       ; branch if a on bridge tile
        lda     $a1
        and     #$03
        sta     $d2         ; set current z-level
@a965:  jsr     ClearPlayerNPCMap
        lda     $a1
        and     #$03
        clc
        adc     #$04
        sta     $0a
; right button
        lda     $03
        and     #JOY_RIGHT
        beq     @a98c
        lda     $cf
        bne     @a980
        lda     #$01
        sta     $1705
@a980:  lda     #$02
        sta     $0709
        jsr     CheckTilePass
        cmp     #$00
        beq     @a9e9
; left button
@a98c:  lda     $03
        and     #JOY_LEFT
        beq     @a9a7
        lda     $cf
        bne     @a99b
        lda     #$03
        sta     $1705
@a99b:  lda     #$04
        sta     $0709
        jsr     CheckTilePass
        cmp     #$00
        beq     @a9e9
; down button
@a9a7:  lda     $03
        and     #JOY_DOWN
        beq     @a9c2
        lda     $cf
        bne     @a9b6
        lda     #$02
        sta     $1705
@a9b6:  lda     #$03
        sta     $0709
        jsr     CheckTilePass
        cmp     #$00
        beq     @a9e9
; up button
@a9c2:  lda     $03
        and     #JOY_UP
        beq     @a9dd
        lda     $cf
        bne     @a9d1
        lda     #$00
        sta     $1705
@a9d1:  lda     #$01
        sta     $0709
        jsr     CheckTilePass
        cmp     #$00
        beq     @a9e9
@a9dd:  stz     $ab
        jsr     SetPlayerNPCMap
        lda     $b1
        bne     @a9ff
        jmp     @aa3f
@a9e9:  lda     $e0
        bne     @aa02
        lda     $0709
        sta     $ab
        jsr     SetPlayerNPCMap
        lda     $ea         ; close map name window
        bne     @a9fb
        inc     $ea
@a9fb:  lda     $b1
        beq     @aa02
@a9ff:  jmp     @aa36
@aa02:  lda     $ab
        lsr
        bcc     @aa36
        cmp     #$00
        bne     @aa22
        lda     $070c
        cmp     #$70        ; closed door 1
        beq     @aa16
        cmp     #$71        ; closed door 2
        bne     @aa36
@aa16:  lda     $1707
        dec
        sta     $0e
        jsr     OpenDoor
        jmp     @aa36
@aa22:  lda     $070e
        cmp     #$70        ; closed door 1
        beq     @aa2d
        cmp     #$71        ; closed door 2
        bne     @aa36
@aa2d:  lda     $1707
        inc
        sta     $0e
        jsr     OpenDoor
@aa36:  jsr     DoPoisonDmg
        jsr     DoFloorDmg
        jsr     UpdateScrollSub
@aa3f:  rts

; ------------------------------------------------------------------------------

; [ open door ]

OpenDoor:
@aa40:  lda     $1706
        sta     $0c
        jsr     GetBG1VRAMPtr
        stx     $06fe
        jsr     GetDoorTiles
        lda     #$45
        jsr     PlaySfx
        lda     #$01
        sta     $d4         ; enable vram map update
        rts

; ------------------------------------------------------------------------------

; [ check tile passability ]

; $0a: z-level
; return 0 if passable, 1 if not

CheckTilePass:
@aa58:  lda     $b1
        beq     @aa5f       ; return 0 if an event is running
        lda     #$00
        rts
@aa5f:  jsr     CheckNPCBlock
        cmp     #$00
        bne     @aa91
        lda     $0709
        asl
        tay
        lda     $a1
        and     #$04
        beq     @aa7d       ; branch if not on a bridge tile
        lda     $06a1,y
        and     #$03
        and     $d2
        beq     @aa87       ; branch if z-level doesn't match
        lda     #$00
        rts
@aa7d:  lda     $06a1,y
        and     $0a
        beq     @aa91
        lda     #$00
        rts
@aa87:  lda     $06a1,y
        and     #$04
        beq     @aa91
        lda     #$00
        rts
@aa91:  lda     #$01
        rts

; ------------------------------------------------------------------------------

; [ check if blocked by npc ]

CheckNPCBlock:
@aa94:  lda     $0709       ; moving direction
        tay
        asl
        tax
        lda     $a1,x
        and     #$04
        beq     @aaa9       ; branch if not moving to a bridge tile
        lda     $d2
        cmp     #$01
        beq     @aaa9       ; branch if not on lower z-level
        lda     #$00
        rts
@aaa9:  phx
        lda     $1706       ; x position
        clc
        adc     XMoveTbl,y
        sta     $0c
        cmp     #$20
        bcs     @aad4
        lda     $1707       ; y position
        clc
        adc     YMoveTbl,y
        sta     $0e
        cmp     #$20
        bcs     @aad4       ; branch if out of bounds
        jsr     GetNPCMapPtr
        ldx     $3d
        lda     $7f4c00,x
        bpl     @aad4       ; branch if tile is empty
        sta     $ee
        jmp     @aad6
@aad4:  lda     #$00
@aad6:  plx
        rts

; ------------------------------------------------------------------------------

; [ set player position in npc map ]

SetPlayerNPCMap:
@aad8:  lda     $ab
        asl
        tay
        lda     $06a1,y
        and     #$04
        beq     @aaec       ; branch if not a bridge tile
        lda     $06a1,y
        and     #$03
        and     $d2
        beq     @ab08
@aaec:  lda     $ab
        tay
        lda     $1706
        clc
        adc     XMoveTbl,y
        sta     $0c
        lda     $1707
        clc
        adc     YMoveTbl,y
        sta     $0e
        lda     #$ff        ; player is $ff in npc map
        sta     $ae
        jsr     SetNPCMap
@ab08:  rts

; ------------------------------------------------------------------------------

; x offset for each movement direction
XMoveTbl:
@ab09:  .byte   $00,$00,$01,$00,$ff

; y offset for each movement direction
YMoveTbl:
@ab0e:  .byte   $00,$ff,$00,$01,$00

; ------------------------------------------------------------------------------

; [ clear player position in npc map ]

ClearPlayerNPCMap:
@ab13:  lda     $a1
        and     #$04
        beq     @ab21       ; branch if not on a bridge tile
        lda     $a1
        and     #$03
        and     $d2
        beq     @ab2e
@ab21:  lda     $1706
        sta     $0c
        lda     $1707
        sta     $0e
        jsr     ClearNPCMap
@ab2e:  rts

; ------------------------------------------------------------------------------

; [ get bg1 tilemap vram address ]

GetBG1VRAMPtr:
@ab2f:  lda     $0e
        and     #$0f
        sta     $19
        stz     $18
        lsr     $19
        ror     $18
        lsr     $19
        ror     $18
        lda     $0c
        and     #$0f
        asl
        clc
        adc     $18
        sta     $18
        lda     $19
        clc
        adc     #$18
        sta     $19
        lda     $0c
        and     #$10
        beq     @ab5d
        lda     $19
        clc
        adc     #$04
        sta     $19
@ab5d:  ldx     $18
        rts

; ------------------------------------------------------------------------------

; [ get open door tiles ]

GetDoorTiles:
@ab60:  longa
        lda     $7f48de
        sta     $0700
        lda     $7f49de
        sta     $0702
        lda     $7f4ade
        sta     $0704
        lda     $7f4bde
        sta     $0706
        lda     #0
        shorta
        rts

; ------------------------------------------------------------------------------

; [ check player movement (world map) ]

CheckPlayerMoveWorld:
@ab84:  lda     $d5
        bne     @ab89       ; return if player control is disabled
        rts
@ab89:  jsr     UpdateLocalTiles
        lda     $b1
        beq     @ab98
        lda     $04
        sta     $02
        lda     $05
        sta     $03
@ab98:  lda     $a1
        and     #$41
        sta     $d2
        lda     $1715
        cmp     #$02
        bne     @abe5
        lda     $1706
        sec
        sbc     $1716
        beq     @abc2
        bpl     @abb9
        lda     #$01
        sta     $1705
        inc
        jmp     @ac6b
@abb9:  lda     #$03
        sta     $1705
        inc
        jmp     @ac6b
@abc2:  lda     $1707
        sec
        sbc     $1717
        beq     @abdf
        bpl     @abd6
        lda     #$02
        sta     $1705
        inc
        jmp     @ac6b
@abd6:  lda     #$00
        sta     $1705
        inc
        jmp     @ac6b
@abdf:  lda     #$80
        sta     $02
        stz     $54
@abe5:  jsr     ChangeVehicle
        lda     $03
        and     #$0f
        beq     @ac65
        and     #JOY_RIGHT
        beq     @abf7
        lda     #$01
        jmp     @ac0f
@abf7:  lda     $03
        and     #JOY_LEFT
        beq     @ac02
        lda     #$03
        jmp     @ac0f
@ac02:  lda     $03
        and     #JOY_DOWN
        beq     @ac0d
        lda     #$02
        jmp     @ac0f
@ac0d:  lda     #$00
@ac0f:  sta     $1705
        inc
        sta     $0709
        asl
        tax
        lda     $b1
        bne     @ac68
        lda     $1700
        cmp     #$01
        bne     @ac46
        lda     $1704
        cmp     #$05
        bne     @ac36
        lda     $1287
        and     #$02
        beq     @ac46
        lda     #$01
        jmp     @ac4b
@ac36:  cmp     #$04
        bne     @ac46
        lda     $1281
        and     #$04
        beq     @ac46
        lda     #$01
        jmp     @ac4b
@ac46:  lda     $1704
        beq     @ac56
@ac4b:  tay
        lda     $a1,x
        and     VehiclePassBit,y   ; check vehicle passability
        beq     @ac65
        jmp     @ac5e
@ac56:  lda     $a1,x
        and     #$41                  ; check passability (no vehicle)
        and     $d2
        beq     @ac65
@ac5e:  jsr     CheckVehicleBlock
        lda     $0a
        beq     @ac68       ; branch if not blocked
@ac65:  stz     $ab
        rts
@ac68:  lda     $0709
@ac6b:  sta     $ab
        jsr     DoPoisonDmg
        lda     $1707
        sta     $070a
        jsr     DecodeWorldTilemap
        jsr     UpdateScrollWorld
        rts

; ------------------------------------------------------------------------------

; [ check if blocked by vehicle ]

; $0A: 1 if blocked, 0 if not blocked (out)

CheckVehicleBlock:
@ac7d:  lda     $0709       ; player movement direction
        tax
        lda     $1706
        clc
        adc     XMoveTbl,x
        sta     $0c
        lda     $1707
        clc
        adc     YMoveTbl,x
        sta     $0e
        stz     $0a
        lda     $1704
        bne     @ac9b       ; return if not in a vehicle
        rts
; chocobo
@ac9b:  cmp     #$01
        bne     @acb0
        lda     $0c
        cmp     $1719
        bne     @acb0
        lda     $0e
        cmp     $171a
        bne     @acb0
        inc     $0a         ; can't travel over hovercraft
        rts
; hovercraft
@acb0:  lda     $1704
        cmp     #$02
        beq     @ad03
        cmp     #$04
        bcs     @ad03
        lda     $1715
        bne     @acd1
        lda     $0c
        cmp     $1713       ; can't travel over black chocobo
        bne     @acd1
        lda     $0e
        cmp     $1714
        bne     @acd1
        inc     $0a
        rts
; enterprise
@acd1:  lda     $0c
        cmp     $171d       ; can't travel over enterprise
        bne     @ace2
        lda     $0e
        cmp     $171e
        bne     @ace2
        inc     $0a
        rts
; falcon
@ace2:  lda     $0c
        cmp     $1721       ; can't travel over falcon
        bne     @acf3
        lda     $0e
        cmp     $1722
        bne     @acf3
        inc     $0a
        rts
; big whale
@acf3:  lda     $0c
        cmp     $1725       ; can't travel over big whale
        bne     @ad03
        lda     $0e
        cmp     $1726
        bne     @ad03
        inc     $0a
@ad03:  rts

; ------------------------------------------------------------------------------

; bit mask for vehicle passability
VehiclePassBit:
@ad04:  .byte   $01,$02,$04,$10,$20,$20,$80

; world map size masks
MapSizeMask:
@ad0b:  .byte   $FF,$7F,$3F

; trigger check frequency for each movement speed
TriggerRateTbl:
@ad0e:  .byte   $0F,$07,$03,$01

; player movement speeds (pixels per frame)
PlayerMoveRateTbl:
@ad12:  .byte   $01,$02,$04,$08

; ------------------------------------------------------------------------------
