
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: ppu.asm                                                              |
; |                                                                            |
; | description: ppu transfer and control routines                             |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

; [ clear tilemap buffer ]

ClearTileBuf:
@8a66:  ldx     #0
        longa
        lda     #$0200
@8a6e:  sta     $6cfd,x                 ; tilemap buffer
        inx2
        cpx     #$0800
        bne     @8a6e
        shorta0
        rts

; ------------------------------------------------------------------------------

; [ transfer tilemap buffer to vram ]

TfrTileBuf:
@8a7c:  ldx     #$0800
        stx     $00
        ldx     #$6cfd
        lda     #$7e
        jmp     TfrVRAM5

; ------------------------------------------------------------------------------

; [  ]

_028a89:
@8a89:  lda     $f109
        tax
        lda     $29bd,x
        cmp     #$ff
        bne     @8a95
        rts
@8a95:  lda     $29a5,x
        and     #$f0
        lsr4
        inc2
        sta     $00
        lda     $29a5,x
        and     #$0f
        sta     $01
        lda     $01
        sta     $26
        lda     #$40
        sta     $28
        jsr     Mult8
        lda     $00
        longa
        asl
        clc
        adc     $2a
        adc     #$6cfd
        sta     $04
        shorta0
        lda     $f109
        tax
        lda     $29bd,x
        asl
        tax
        lda     $6cc3,x
        sta     $00
        lda     $6cc4,x
        sta     $01
        lda     $00
        cmp     #$02
        bne     @8af0
        lda     #$04
        sta     $00
        sta     $01
        longa
        lda     $04
        sec
        sbc     #$0002
        sta     $04
        shorta0
@8af0:  lda     $f10a
        asl2
        sta     $06
@8af7:  ldy     #$0001
        lda     $00
        tax
@8afd:  lda     ($04),y
        and     #$e3
        ora     $06
        sta     ($04),y
        iny2
        dex
        bne     @8afd
        longa
        lda     $04
        clc
        adc     #$0040
        sta     $04
        shorta0
        dec     $01
        bne     @8af7
        rts

; ------------------------------------------------------------------------------

; [ init graphics ]

InitGfx:
@8b1c:  jsr     LoadBattleBGGfx
        jsr     LoadBG3MenuGfx
        jsr     LoadBG2MenuGfx
        jsr     LoadMiscSpriteGfx
        jsr     LoadMonsterGfx
        jsr     LoadMiscMonsterGfx
        jsr     LoadMonsterTiles
        ldx     #$0480
        stx     $00
        lda     #$7e
        ldx     #$6cfd
        ldy     #$6000
        jsr     TfrVRAM5
        jmp     UpdateMonsterPos

; ------------------------------------------------------------------------------

; [ load misc. monster graphics ]

LoadMiscMonsterGfx:
@8b44:  ldx     #40                     ; 40 tiles
        stx     $00
        ldx     #.loword(MonsterGfx1)   ; mini, toad, pig, egg
        ldy     #$4290
        lda     #^MonsterGfx1
        jsr     Tfr3bppGfx
        ldx     #2                      ; 2 tiles
        stx     $00
        ldx     #.loword(ShadowGfx)     ; stationary shadows
        ldy     #$4510
        lda     #^ShadowGfx
        jsr     Tfr3bppGfx
        clr_ax
@8b66:  sta     $d9e6,x
        inx
        cpx     #$0100
        bne     @8b66
        ldx     #8                      ; 8 tiles
        stx     $00
        ldy     #.loword(ShadowGfx)     ; animated shadows
        ldx     #$d9e6
        lda     #^ShadowGfx
        jmp     Load3bppGfx

; ------------------------------------------------------------------------------

; [ update monster positions ]

UpdateMonsterPos:
@8b7f:  clr_ax
@8b81:  txa
        asl
        tay
        lda     $f123,x
        cmp     #$ff
        beq     @8bb5                   ; skip if monster isn't present
        phy
        asl
        tay
        lda     $6cc4,y                 ; monster height
        asl2
        sec
        sbc     #$04
        sta     $00
        ply
        lda     $29a5,x                 ; y position
        and     #$0f
        asl3
        clc
        adc     $00
        sta     $6ce4,y                 ; set cursor y position
        lda     $29a5,x                 ; x position
        and     #$f0
        lsr
        clc
        adc     #$08
        sta     $6ce3,y                 ; set cursor x position
        bra     @8bbd
@8bb5:  lda     #$ff
        sta     $6ce3,y                 ; no cursor position
        sta     $6ce4,y
@8bbd:  inx
        cpx     #8
        bne     @8b81
        jsr     UpdateAnimPos
        rts

; ------------------------------------------------------------------------------

; [ modify monster tilemap (near) ]

ModifyBG1Tiles_near:
@8bc7:  jsl     ModifyBG1Tiles
        rts

; ------------------------------------------------------------------------------

; [ draw boss monster tilemap ]

DrawBoss:
@8bcc:  sta     $f49e
        sty     $f44f
        sta     $26
        lda     #$05
        sta     $28
        lda     #$20
        sta     $f49d
        jsr     Mult8
        ldx     $2a
        clr_ay
@8be4:  lda     f:BossGfxProp,x
        sta     $efa3,y
        inx
        iny
        cpy     #5
        bne     @8be4
        lda     $efa4
        bpl     @8bfa
        jsr     ClearTileBuf
@8bfa:  lda     $efa6
        and     #$30
        lsr4
        sta     $06
        tax
        lda     $efa5
        sta     $f10d,x
        inx3
        jsr     LoadMonsterPal
        lda     $06
        asl
        tay
        lda     $efa4
        and     #$3f
        asl
        tax
        lda     f:MonsterGfxSize,x
        sta     $00
        sta     $6cc3,y
        lda     f:MonsterGfxSize+1,x
        sta     $01
        sta     $6cc4,y
        phy
        ldy     $f44f
        lda     $efa3
        sta     $29a5,y
        ply
        lda     $efa3
        and     #$f0
        lsr4
        inc2
        sta     $04
        lda     $efa3
        and     #$0f
        sta     $05
        lda     $05
        sta     $26
        lda     #$40
        sta     $28
        jsr     Mult8
        lda     $04
        asl
        longa
        clc
        adc     $2a
        adc     #$6cfd
        sta     $04
        shorta0
        lda     $06
        inc3
        asl2
        sta     $07
        lda     $efa4
        and     #$40
        beq     @8c7b
        inc     $07
@8c7b:  lda     $0a
        tax
        lda     $6cdf,x
        sta     $06
        lda     $efa7
        asl
        tax
        lda     f:BossTilemapPtrs,x     ; pointers to boss tilemaps
        sta     $26
        lda     f:BossTilemapPtrs+1,x
        sta     $27
        lda     #^BossTilemapPtrs
        sta     $28
        clr_ax
        stz     $09
@8c9c:  lda     $00
        sta     $02
        ldy     #0
@8ca3:  jsr     LoadBossTilemap
        sta     ($04),y
        iny
        lda     $07
        and     $0c
        ora     $08
        ora     $2a
        sta     ($04),y
        iny
        dec     $02
        bne     @8ca3
        longa
        lda     $04
        clc
        adc     #$0040
        sta     $04
        shorta0
        lda     $f4a1
        bne     @8cd7
        lda     $f49e
        cmp     #$39
        bne     @8cda
        lda     $01
        cmp     #$04
        bne     @8cda
@8cd7:  stz     $f49d
@8cda:  dec     $01
        bne     @8c9c
        jmp     UpdateMonsterSizes

; ------------------------------------------------------------------------------

; [ load boss tilemap ]

LoadBossTilemap:
@8ce1:  stz     $2a
        lda     $09
        beq     @8cf6
        dec     $09
        lda     #$fe
        sta     $0c
        lda     #$02
        ora     $f49d
        sta     $08
        clr_a
        rts
@8cf6:  phy
        phx
        ply
        lda     [$26],y
        cmp     #$ff
        beq     @8d0a
        cmp     #$fe
        bne     @8d18
        iny
        lda     [$26],y
        dec
        sta     $09
        inx
@8d0a:  lda     #$fe
        sta     $0c
        lda     #$02
        ora     $f49d
        sta     $08
        clr_a
        bra     @8d28
@8d18:  pha
        lda     #$ff
        sta     $0c
        lda     $f49d
        sta     $08
        pla
        clc
        adc     $06
        rol     $2a
@8d28:  inx
        ply
        rts

; ------------------------------------------------------------------------------

; [ update bg1 tilemap (far) ]

UpdateBG1Tiles_far:
@8d2b:  jsr     UpdateBG1Tiles
        rtl

; ------------------------------------------------------------------------------

; [ load monster tilemap ]

LoadMonsterTiles:
@8d2f:  jsr     UpdateBG1Tiles
        jmp     ModifyBG1Tiles_near

; ------------------------------------------------------------------------------

; [ update bg1 tilemap ]

UpdateBG1Tiles:
@8d35:  jsr     ClearTileBuf
        lda     $f473
        bne     @8da1
        clr_ax

; start of monster loop
@8d3f:  phx
        txa
        sta     $02
        lda     $29b5,x
        cmp     #$ff
        beq     @8d9a
        sta     $0a
        tax
        lda     $29b1,x
        jsr     GetMonsterGfxPropPtr
        lda     f:MonsterGfxProp,x
        bpl     @8d72

; boss graphics
        lda     $02
        tay
        lda     $f2b4,y
        cmp     #$ff
        bne     @8d6c
        lda     f:MonsterGfxProp,x
        and     #$3f
        sta     $f2b4,y
@8d6c:  jsr     DrawBoss
        jmp     @8d9a

; normal monster graphics
@8d72:  lda     $0a
        tax
        asl
        tay
        lda     $6cc3,y
        sta     $00
        lda     $6cc4,y
        sta     $01
        plx
        phx
        lda     $29a5,x
        and     #$0f
        sta     $05
        lda     $29a5,x
        and     #$f0
        lsr4
        inc2
        sta     $04
        jsr     DrawMonster

; next monster
@8d9a:  plx
        inx
        cpx     #8
        bne     @8d3f
@8da1:  jsl     DrawGhostChars
        jmp     UpdateMonsterSizes

; ------------------------------------------------------------------------------

; [ draw monster tilemap ]

DrawMonster:
@8da8:  lda     $02
        sta     $26
        lda     #$80
        sta     $28
        jsr     Mult8
        ldx     $2a
        lda     $2285,x
        and     #$20
        bne     @8dc5
        lda     $2283,x
        and     #$38
        beq     @8e1a
        sta     $06
@8dc5:  lda     $00
        lsr
        dec
        clc
        adc     $04
        sta     $04
        lda     $01
        lsr
        dec
        clc
        adc     $05
        sta     $05
        lda     #$02
        sta     $00
        sta     $01
        lda     #$3a
        sta     $07
        lda     $2285,x
        and     #$20
        beq     @8df6
        dec     $04
        dec     $05
        lda     #$04
        sta     $00
        sta     $01
        lda     #$41
        bra     @8e16
@8df6:  lda     $06
        and     #$20
        beq     @8e00
        lda     #$2d
        bra     @8e16
@8e00:  lda     $06
        and     #$10
        bne     @8e14
        dec     $04
        dec     $05
        lda     #$04
        sta     $00
        sta     $01
        lda     #$31
        bra     @8e16
@8e14:  lda     #$29
@8e16:  sta     $06
        bra     @8e3c
@8e1a:  lda     $0a
        tax
        lda     $6cdb,x
        sta     $07
        lda     $6cdf,x
        sta     $06
        lda     $ed4e
        and     #$10
        beq     @8e3c
        jsr     GetMonsterTileBufPtr
        lda     $07
        eor     #$40
        sta     $07
        jsl     DrawEnemyChar
        rts
@8e3c:  jsr     GetMonsterTileBufPtr
@8e3f:  lda     $00
        tax
        clr_ay
        longa
@8e46:  lda     $06
        sta     ($04),y
        iny2
        inc     $06
        dex
        bne     @8e46
        lda     $04
        clc
        adc     #$0040
        sta     $04
        shorta0
        dec     $01
        bne     @8e3f
        longa
        lda     $04
        clc
        adc     #$0040
        sta     $04
        shorta0
        lda     $ed4e
        and     #$40
        beq     @8ea4       ; branch if monsters are not flying
        clr_ay
        lda     #$51
        sta     ($04),y
        iny
        lda     #$3a
        sta     ($04),y
        lda     $00
        dec
        asl
        tay
        lda     #$51
        sta     ($04),y
        iny
        lda     #$7a
        sta     ($04),y
        dec     $00
        dec     $00
        beq     @8ea4
        ldy     #$0002
@8e96:  lda     #$52
        sta     ($04),y
        iny
        lda     #$3a
        sta     ($04),y
        iny
        dec     $00
        bne     @8e96
@8ea4:  rts

; ------------------------------------------------------------------------------

; [ get pointer to monster tilemap ]

GetMonsterTileBufPtr:
@8ea5:  lda     $05
        sta     $26
        lda     #$40
        sta     $28
        jsr     Mult8
        lda     $04
        asl
        longa
        clc
        adc     $2a
        adc     #$6cfd
        sta     $04
        shorta0
        rts

; ------------------------------------------------------------------------------

; [ get pointer to monster graphics properties ]

GetMonsterGfxPropPtr:
@8ec1:  longa                           ; multiply by 4
        asl2
        tax
        shorta0
        rts

; ------------------------------------------------------------------------------

; [ load monster graphics ]

LoadMonsterGfx:
@8eca:  lda     $29a4
        and     #$07
        asl2
        pha
        asl
        tax
        clr_ay
@8ed6:  lda     f:MonsterVRAMPtrs,x
        sta     $6ccb,y
        lda     f:BossTileCountTbl,x
        sta     $6cd3,y
        inx
        iny
        cpy     #8
        bne     @8ed6
        clr_ay
        pla
        tax
@8eef:  lda     f:MonsterTileFlags,x
        sta     $6cdb,y
        lda     f:MonsterTileLoByteTbl,x
        sta     $6cdf,y
        iny
        inx
        cpy     #4
        bne     @8eef
        clr_ax

; start of monster loop
@8f06:  phx
        stx     $0a
        lda     $29ad,x                 ; monster id
        cmp     #$ff
        bne     @8f13                   ; branch if valid
        jmp     @904d
@8f13:  jsr     GetMonsterGfxPropPtr
        lda     f:MonsterGfxProp,x
        sta     $00
        lda     f:MonsterGfxProp+1,x
        sta     $02
        lda     f:MonsterGfxProp+2,x
        sta     $04
        lda     f:MonsterGfxProp+3,x
        sta     $05
        lda     $00
        and     #$40
        beq     @8f8a                   ; branch if not an enemy character

; enemy character graphics
        lda     #$02
        sta     $06
        lda     #$03
        sta     $07
        lda     $0a
        asl
        tay
        lda     $06
        sta     $6cc3,y
        lda     $07
        sta     $6cc4,y
        lda     $00
        pha
        ldx     $0a
        lda     $02
        sta     $f10d,x
        inx3
        jsr     LoadCharPal
        pla
        and     #$3f
        tax
        stx     $26
        ldx     #$0800
        stx     $28
        jsr     Mult16
        longa
        lda     $2a
        clc
        adc     #.loword(BattleCharGfx)
        tax
        lda     #$0800
        sta     $00
        shorta0
        phx
        lda     $0a
        asl
        tax
        ldy     $6ccb,x
        lda     #^BattleCharGfx
        plx
        jsr     TfrVRAM5
        jmp     @904d

; boss graphics
@8f8a:  lda     $00
        bpl     @8fd7                   ; branch if not a boss
        lda     $00
        and     #$3f
        sta     $26
        lda     #$05
        sta     $28
        jsr     Mult8
        ldx     $2a
        lda     $0a
        asl
        tay
        lda     f:BossGfxProp+1,x
        and     #$3f
        asl
        tax
        lda     f:MonsterGfxSize,x
        sta     $06
        sta     $6cc3,y
        lda     f:MonsterGfxSize+1,x
        sta     $07
        sta     $6cc4,y
        ldx     $2a
        lda     f:BossGfxProp+2,x
        ldx     $0a
        sta     $f10d,x
        inx3
        jsr     LoadMonsterPal
        lda     $0a
        asl
        tax
        lda     $6cd3,x
        tax
        jmp     @9007

; monster graphics
@8fd7:  and     #$3f
        asl
        tax
        lda     f:MonsterGfxSize,x
        sta     $06
        lda     f:MonsterGfxSize+1,x
        sta     $07
        lda     $0a
        asl
        tay
        lda     $06
        sta     $6cc3,y                 ; width
        lda     $07
        sta     $6cc4,y                 ; height
        ldx     $0a
        lda     $02
        sta     $f10d,x
        inx3
        jsr     LoadMonsterPal
        jsr     CalcMonsterSize
        ldx     $2a
@9007:  stx     $00                     ; number of tiles
        stx     $2a
        lda     $0a
        asl
        tax
        ldy     $6ccb,x                 ; vram address
        lda     $05
        and     #$70                    ; graphics bank
        lsr4
        clc
        adc     #^MonsterGfx1
        pha
        longa
        lda     $2a
        asl5
        sta     $2a
        lda     $04
        and     #$0fff
        asl3
        clc
        adc     #$8000
        tax
        shorta0
        lda     $05
        bmi     @9049                   ; branch if 3bpp graphics
        phx
        ldx     $2a
        stx     $00
        plx
        pla
        jsr     TfrVRAM5
        bra     @904d
@9049:  pla
        jsr     Tfr3bppGfx
@904d:  plx                             ; next monster
        inx
        cpx     #3
        beq     @9057
        jmp     @8f06
@9057:  rts

; ------------------------------------------------------------------------------

; [ calculate monster size (number of tiles) ]

CalcMonsterSize:
@9058:  lda     $06                     ; multiply height * width
        sta     $26
        lda     $07
        sta     $28
        jmp     Mult8

; ------------------------------------------------------------------------------

; [ load misc. sprite graphics ]

LoadMiscSpriteGfx:
@9063:  ldx     #$0050
        stx     $00
        ldx     #.loword(MiscBattleGfx)
        ldy     #$1400
        lda     #^MiscBattleGfx
        jmp     Tfr3bppGfx

; ------------------------------------------------------------------------------

; [ load menu graphics (bg2) ]

LoadBG2MenuGfx:
@9073:  ldx     #$4db0
        ldy     #$04a0
        jsr     ClearVRAM
        ldx     #$4db0
        stx     $04
        clr_ax
@9083:  ldy     $04
        lda     f:BG2MenuTiles,x
        jsr     TfrBG2MenuTile
        longa
        lda     $04
        clc
        adc     #$0010
        sta     $04
        shorta0
        inx
        cpx     #$0025
        bne     @9083
        rts

; ------------------------------------------------------------------------------

; [ transfer bg2 menu tile to vram ]

TfrBG2MenuTile:
@90a0:  phx
        sta     $26
        lda     #$10
        sta     $28
        jsr     Mult8
        longa
        lda     $2a
        clc
        adc     #.loword(WindowGfx)
        tax
        lda     #$0010
        sta     $00
        shorta0
        lda     #^WindowGfx
        jsr     TfrVRAM5
        plx
        rts

; ------------------------------------------------------------------------------

; [ init color palettes ]

InitPal:
@90c2:  clr_ax
@90c4:  lda     f:WindowPal,x               ; menu window palette
        sta     $ed50,x
        lda     f:AnimPal,x
        sta     $ee50,x
        inx
        cpx     #$0020
        bne     @90c4
        ldx     $16aa
        stx     $ed52
        stx     $ed5a
        stx     $ed62
        stx     $ed6a
        lda     #$02
        ldx     #$000e
        jsr     LoadAnimPal
        lda     #$03
        ldx     #$0006
        jsr     LoadAnimPal
        jsl     LoadBattleBGPal
        lda     #0
        jsr     UpdateCharPalID_near
        ldx     #$0009
        jsr     LoadCharPal
        lda     #1
        jsr     UpdateCharPalID_near
        ldx     #$000a
        jsr     LoadCharPal
        lda     #2
        jsr     UpdateCharPalID_near
        ldx     #$000b
        jsr     LoadCharPal
        lda     #3
        jsr     UpdateCharPalID_near
        ldx     #$000c
        jsr     LoadCharPal
        lda     #4
        jsr     UpdateCharPalID_near
        ldx     #$000d
        jmp     LoadCharPal

; ------------------------------------------------------------------------------

; [ update character palette id (near) ]

UpdateCharPalID_near:
@9132:  jsl     UpdateCharPalID
        rts

; ------------------------------------------------------------------------------

; [ load menu graphics (bg3) ]

LoadBG3MenuGfx:
@9137:  ldx     #$1000
        stx     $00
        lda     #^WindowGfx
        ldx     #.loword(WindowGfx)
        ldy     #$5000
        jsr     TfrVRAM5
        ldx     #$5000
        ldy     #$0010
        jmp     ClearVRAM

; ------------------------------------------------------------------------------

; [ load monster palette ]

LoadMonsterPal:
@9150:  sta     $26
        lda     #$10
        sta     $28
        jsr     Mult8
        longa
        txa
        asl5
        tay
        shorta0
        lda     #$20
        sta     $00
        ldx     $2a
@916b:  lda     f:MonsterPal,x
        sta     $ed50,y
        inx
        iny
        dec     $00
        bne     @916b
        rts

; ------------------------------------------------------------------------------

; [ load animation palette ]

;  A: animation palette id
; +X: ppu palette id

LoadAnimPal:
@9179:  sta     $26
        lda     #$10
        sta     $28
        jsr     Mult8
        longa
        txa
        asl5
        tay
        shorta0
        lda     #$10
        sta     $00
        ldx     $2a
@9194:  lda     f:AnimPal,x
        sta     $ed50,y
        sta     $ed60,y
        inx
        iny
        dec     $00
        bne     @9194
        rts

; ------------------------------------------------------------------------------

; [ load character palette (far) ]

LoadCharPal_far:
@91a5:  jsr     LoadCharPal
        rtl

; ------------------------------------------------------------------------------

; [ load character palette ]

LoadCharPal:
@91a9:  sta     $26
        lda     #$20
        sta     $28
        jsr     Mult8
        longa
        txa
        asl5
        tay
        shorta0
        ldx     $2a
        lda     #$20
        sta     $00
@91c4:  lda     f:BattleCharPal,x       ; battle char palettes
        sta     $ed50,y
        inx
        iny
        dec     $00
        bne     @91c4
        rts

; ------------------------------------------------------------------------------

; [ load battle bg graphics ]

LoadBattleBGGfx:
@91d2:  lda     $1802       ; battle bg id
        and     #$1f
        asl
        tax
        longa
        lda     #$0028
        sta     $00
        lda     f:BattleBGGfxPtrs,x
        tax
        shorta0
        lda     #$1c
        ldy     #$4010
        jsr     Tfr3bppGfx
        jsl     LoadBattleBGTiles
        ldx     #$0480      ; 18 rows
        stx     $00
        lda     #$7e
        ldx     #$6cfd
        ldy     #$5800
        jsr     TfrVRAM5
        lda     $6cc0
        pha
        lda     #$ff
        sta     $6cc0
        jsl     FlipTiles
        pla
        sta     $6cc0
        ldx     #$0480
        stx     $00
        lda     #$7e
        ldx     #$6cfd
        ldy     #$5c00
        jmp     TfrVRAM5

; ------------------------------------------------------------------------------

; [ transfer summon graphics to vram (4 tiles per frame) ]

TfrPartialSummonGfx:
@9225:  lda     $f35c
        beq     @923d
        stz     $f35c
        ldx     #$0020                  ; 1 tile
        stx     $0e
        ldx     $f360
        ldy     $f362
        lda     #$7e
        jsr     TfrVRAM4
@923d:  lda     $f35d
        beq     @9255
        stz     $f35d
        ldx     #$0020
        stx     $0e
        ldx     $f364
        ldy     $f366
        lda     #$7e
        jsr     TfrVRAM4
@9255:  lda     $f35e
        beq     @926d
        stz     $f35e
        ldx     #$0020
        stx     $0e
        ldx     $f368
        ldy     $f36a
        lda     #$7e
        jsr     TfrVRAM4
@926d:  lda     $f35f
        beq     @9285
        stz     $f35f
        ldx     #$0020
        stx     $0e
        ldx     $f36c
        ldy     $f36e
        lda     #$7e
        jsr     TfrVRAM4
@9285:  rts

; ------------------------------------------------------------------------------

; [ transfer animation graphics to vram ]

TfrAnimGfx:
@9286:  lda     $f35c
        ora     $f35d
        ora     $f35e
        ora     $f35f
        beq     @9297
        jmp     TfrPartialSummonGfx
@9297:  lda     $efa8
        beq     @92b0
        stz     $efa8
        ldx     $efad
        stx     $0e
        ldx     $efa9
        ldy     $efab
        lda     $efaf
        jsr     TfrVRAM4
@92b0:  lda     $efb1
        beq     @92c9
        stz     $efb1
        ldx     $efb6
        stx     $0e
        ldx     $efb2
        ldy     $efb4
        lda     $efb8
        jsr     TfrVRAM4
@92c9:  rts

; ------------------------------------------------------------------------------
