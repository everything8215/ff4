
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: sprite.asm                                                           |
; |                                                                            |
; | description: sprite routines                                               |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

; [ update character palette ]

UpdateCharPalette:
@da73:  phx
        phy
        lda     $47
        tax
        lda     $f0a3,x
        tax
        stx     $1c
        lda     $47
        clc
        adc     #$09
        longa
        asl5
        tay
        lda     $1c
        asl5
        tax
        shorta0
        phy
        lda     $f0ad
        bne     @dab2
        lda     $f283
        bne     @dab2
        lda     #$20
        sta     $1c
@daa5:  lda     f:BattleCharPal,x
        sta     $ed50,y
        inx
        iny
        dec     $1c
        bne     @daa5
@dab2:  ply
        lda     $d7
        beq     @dad9
        lda     $47
        cmp     $1822
        bne     @dad9
        lda     $1813
        and     #$04
        beq     @dad1
        lda     #$ef
        sta     $ed52,y
        lda     #$3d
        sta     $ed53,y
        bra     @dad9
@dad1:  lda     #$00
        sta     $ed52,y
        sta     $ed53,y
@dad9:  ply
        plx
        rts

; ------------------------------------------------------------------------------

; [ update poisoned character palette ]

UpdatePoisonCharPal:
@dadc:  phx
        lda     $47
        clc
        adc     #$09                    ; first character slot is palette 9
        longa
        asl5
        tax
        lda     #$7df6
        sta     $ed56,x
        lda     #$7d30
        sta     $ed58,x
        clr_a
        sta     $ed60,x
        shorta
        plx
        rts

; ------------------------------------------------------------------------------

; [ update character movement ]

UpdateCharMovement:
@dafe:  phx
        lda     $47
        asl2
        tax
        lda     $f015,x
        and     #$c0
        bne     @db13                   ; return if dead or stone
        lda     $47
        tax
        lda     $f2bc,x
        beq     @db15
@db13:  plx
        rts
@db15:  plx
        lda     $efc5,x
        cmp     #$d0
        beq     @db24
        cmp     #$e0
        beq     @db24
        jmp     @db60

; not at default position
@db24:  lda     $f014                   ; row setting
        bne     @db34
        phx
        lda     $47
        tax
        lda     f:CharSpriteDefaultXTbl,x
        plx
        bra     @db3d
@db34:  phx
        lda     $47
        tax
        lda     f:CharSpriteDefaultXTbl+5,x
        plx
@db3d:  cmp     $efc5,x
        beq     @db60

; not at default position
        pha
        lda     $efce,x
        and     #$0f
        sta     $efce,x
        pla
        cmp     #$d0
        bne     @db54

; front row
        lda     #$08
        bra     @dbb2

; back row
@db54:  lda     $efce,x                 ; move backward
        ora     #$20
        sta     $efce,x
        lda     #$08
        bra     @dbb2

; at default position
@db60:  phx
        lda     $47
        tax
        lda     $f0af,x
        beq     @db6c

; attack in progress
        plx
        bra     @db6f

; attack finished, okay to move back
@db6c:  plx
        bra     @dbd9
@db6f:  lda     $efc5,x
        cmp     #$c0
        beq     @dbd9
        pha
        lda     $efce,x
        and     #$0f
        sta     $efce,x
        pla
        stz     $efd1,x
        stz     $efd3,x
        cmp     #$b0
        bne     @db96
        lda     $efce,x                 ; move backward
        ora     #$20
        sta     $efce,x
        lda     #$10
        bra     @dbaf
@db96:  lda     $f014                   ; row setting
        bne     @dba6
        phx
        lda     $47
        tax
        lda     f:CharStepDurTbl,x
        plx
        bra     @dbaf
@dba6:  phx
        lda     $47
        tax
        lda     f:CharStepDurTbl+5,x
        plx
@dbaf:  sec
        sbc     #$08
@dbb2:  sta     $efcf,x
        lda     $f015,y
        and     #$30
        beq     @dbd1
        and     #$20
        beq     @dbc8
        lda     $efce,x                 ; enable toad hop
        ora     #$10
        sta     $efce,x
@dbc8:  lda     $efcf,x
        asl
        sta     $efcf,x
        bra     @dbd9
@dbd1:  lda     $efce,x                 ; move at normal speed
        ora     #$40
        sta     $efce,x
@dbd9:  rts

; ------------------------------------------------------------------------------

; [ update charmed character animation ]

UpdateCharmedCharAnim:
@dbda:  phx
        lda     $47
        tax
        lda     $f2bc,x
        bne     @dbe8
        lda     $f0af,x
        beq     @dbea
@dbe8:  plx
        rts
@dbea:  plx
        lda     $efce,x
        and     #$0f
        sta     $efce,x
        lda     $efc5,x
        cmp     #$b0
        beq     @dc49                   ; branch if already in charmed position
        stz     $efd1,x
        stz     $efd3,x
        cmp     #$c0
        bne     @dc08
        lda     #$08
        bra     @dc21
@dc08:  lda     $f014
        bne     @dc18
        phx
        lda     $47
        tax
        lda     f:CharStepDurTbl,x
        plx
        bra     @dc21
@dc18:  phx
        lda     $47
        tax
        lda     f:CharStepDurTbl+5,x
        plx
@dc21:  sta     $efcf,x
        lda     $f015,y
        and     #$30
        beq     @dc40
        and     #$20
        beq     @dc37
        lda     $efce,x
        ora     #$10
        sta     $efce,x
@dc37:  lda     $efcf,x
        asl
        sta     $efcf,x
        bra     @dc48
@dc40:  lda     $efce,x
        ora     #$40
        sta     $efce,x
@dc48:  rts
@dc49:  lda     $efce,x                 ; h-flip sprite
        ora     #$01
        sta     $efce,x
        rts

; ------------------------------------------------------------------------------

; [ init step back after attack ]

UpdateStepBack:
@dc52:  phx
        lda     $47
        tax
        lda     $f2bc,x
        bne     @dc60
        lda     $f0af,x
        beq     @dc62
@dc60:  plx
        rts
@dc62:  plx
        lda     $f014
        bne     @dc79
        phx
        lda     $47
        tax
        lda     f:CharStepDurTbl,x
        sta     $0e
        lda     f:CharSpriteDefaultXTbl,x
        plx
        bra     @dc88
@dc79:  phx
        lda     $47
        tax
        lda     f:CharStepDurTbl+5,x
        sta     $0e
        lda     f:CharSpriteDefaultXTbl+5,x
        plx
@dc88:  pha
        lda     $efc5,x
        cmp     #$c0
        bne     @dc9e
        lda     $0e
        cmp     #$18
        bne     @dc9c
        lda     #$10
        sta     $0e
        bra     @dc9e
@dc9c:  lsr     $0e
@dc9e:  pla
        cmp     $efc5,x
        beq     @dce4                   ; return if at default position
        stz     $efd1,x
        stz     $efd3,x
        lda     $efce,x
        and     #$0f
        sta     $efce,x
        lda     $0e
        sta     $efcf,x
        lda     $f015,y
        and     #$30
        beq     @dcd3
        and     #$20
        beq     @dcca

; toad
        lda     $efce,x                 ; enable toad hop
        ora     #$10
        sta     $efce,x

; mini
@dcca:  lda     $efcf,x                 ; move twice as far
        asl
        sta     $efcf,x
        bra     @dcdb

; normal
@dcd3:  lda     $efce,x
        ora     #$40                    ; move at normal speed
        sta     $efce,x
@dcdb:  lda     $efce,x
        ora     #$20                    ; move backward
        sta     $efce,x
        rts
@dce4:  lda     $efce,x                 ; don't h-flip sprite
        and     #$fe
        sta     $efce,x
        rts

; ------------------------------------------------------------------------------

; [ draw character status sprites ]

; +X: character id

DrawStatusSprites:
@dced:  phx
        phy
        txa
        asl2
        tay
        lda     f:FirstCharSpriteAboveTbl,x
        longa
        asl2
        sta     $0e
        shorta0
        lda     $f078                   ; status sprite id
        sta     $f08f,x
        asl4
        sta     $10
        lda     $f07b,y
        bne     @dd14
        jmp     @dd96
@dd14:  lda     $f07c,y                 ; increment frame counter
        inc
        sta     $f07c,y
        and     #$07
        bne     @dd26
        lda     $f07d,y                 ; toggle frame
        inc
        sta     $f07d,y
@dd26:  txa
        asl
        tax
        lda     $6cf3,x                 ; use cursor position as base
        sta     $12
        lda     $6cf4,x
        sta     $13
        lda     $f07d,y
        and     #$01
        asl3
        clc
        adc     $10
        tax
        ldy     $0e
        stz     $0e
@dd43:  lda     f:StatusSpriteTbl,x
        clc
        adc     $12
        jsr     BackAttackFlipX
        sta     $0300,y
        inx
        iny
        lda     f:StatusSpriteTbl,x
        clc
        adc     $13
        sta     $0300,y
        inx
        iny
        lda     $f078
        cmp     #$09
        bne     @dd6f                   ; branch if not doom
        phx
        lda     $0e
        tax
        lda     $f079,x                 ; doom numeral tile id
        plx
        bra     @dd73
@dd6f:  lda     f:StatusSpriteTbl,x
@dd73:  sta     $0300,y
        inx
        iny
        lda     $6cc0
        beq     @dd85
        lda     f:StatusSpriteTbl,x
        eor     #$40
        bra     @dd89
@dd85:  lda     f:StatusSpriteTbl,x
@dd89:  sta     $0300,y
        inx
        iny
        inc     $0e
        lda     $0e
        cmp     #2
        bne     @dd43
@dd96:  ply
        plx
        rts

; ------------------------------------------------------------------------------

; [ set sprite tile msb ]

; used for toad and mini

SetCharSpriteTileMSB:
@dd99:  stz     $efc2                   ; use tile $0100 ???
        lda     $efc3
        ora     #$01
        sta     $efc3
        rts

; ------------------------------------------------------------------------------

; [ check if character pose can be updated ??? ]

; set carry if pose is overridden by a status or other effect

CheckPoseUpdate:
@dda5:  phx
        lda     $47
        tax
        lda     $f0af,x
        bne     @ddd4                   ; branch if attack in progress
        lda     $f46d,x
        bne     @ddd6                   ; branch if victory animation
        lda     $47
        asl2
        tax
        lda     $f015,x                 ; dead, stone, toad, mini
        and     #$f7                    ; mute, blind, poison
        sta     $0e
        lda     $f016,x                 ; curse, paralyze, sleep, charm
        and     #$b8
        ora     $0e
        sta     $0e
        lda     $f018,x                 ; low hp
        and     #$01
        ora     $0e
        bne     @ddd9
        plx
        sec
        rts
@ddd4:  inc     $64                     ; no run animation with L+R
@ddd6:  plx
        sec
        rts
@ddd9:  plx
        clc
        rts

; ------------------------------------------------------------------------------

; [ update character animation ]

UpdateCharAnim:
@dddc:  phx
        phy
        stz     $64
        lda     $47
        asl2
        tay
        lda     $efcf,x
        bne     @dded
        jmp     @de87

; character is moving
@dded:  inc     $64
        lda     $efce,x
        sta     $0e
        and     #$20
        beq     @de11

; moving back
        lda     $efce,x                 ; h-flip sprite
        ora     #$01
        sta     $efce,x
        lda     $0e
        and     #$40
        bne     @de0d
        jsr     SetCharSpriteTileMSB
        lda     #1                      ; slow speed
        bra     @de28
@de0d:  lda     #2                      ; normal speed
        bra     @de28

; moving forward
@de11:  lda     $efce,x                 ; no h-flip
        and     #$fe
        sta     $efce,x
        lda     $0e
        and     #$40
        bne     @de26
        jsr     SetCharSpriteTileMSB
        lda     #.lobyte(-1)            ; slow speed
        bra     @de28
@de26:  lda     #.lobyte(-2)            ; normal speed
@de28:  sta     $0f
        lda     $efc5,x                 ; add to character x position
        clc
        adc     $0f
        sta     $efc5,x
        lda     $0e
        and     #$10
        beq     @de4d
        lda     $efd1,x
        and     #$07
        phx
        tax
        lda     f:ToadHopTbl,x
        plx
        sta     $efc8,x
        lda     #$03
        sta     $efd2,x
@de4d:  lda     #$03                    ; running
        sta     $efd0,x
        dec     $efcf,x
        phx
        lda     $47
        tax
        lda     $f08f,x
        sta     $f078
        lda     $f094,x
        sta     $f077
        lda     $f099,x
        cmp     #$0e
        beq     @de70
        cmp     #$07
        bne     @de83
@de70:  jsr     CheckPoseUpdate
        bcc     @de83
        lda     $47
        tax
        lda     $f099,x
        beq     @de83
        plx
        sta     $efd0,x
        bra     @de84
@de83:  plx
@de84:  ply
        plx
        rts

; character is not moving
@de87:  jsr     UpdateCharPalette
        stz     $f078
        stz     $efcc,x
        lda     $f396
        bne     @de98
        stz     $efc8,x
@de98:  lda     #$01                    ; normal pose
        sta     $efd0,x
        lda     $f015,y                 ; copy status effects
        sta     $0e
        lda     $f016,y
        sta     $0f
        lda     $f017,y
        sta     $10
        lda     $f018,y
        sta     $11

; dead
        lda     $0e
        and     #$80
        beq     @dec1
        inc     $64
        lda     #$09
        sta     $efd0,x
        jmp     @dfde

; stone
@dec1:  lda     $0e
        and     #$40
        beq     @ded5
        inc     $64
        lda     #$03
        sta     $efcc,x
        inc
        sta     $efd0,x
        jmp     @dfde

; partial petrify
@ded5:  lda     $0f
        and     #$03
        sta     $efcc,x

; poison
        lda     $0e
        and     #$01
        beq     @deea
        jsr     UpdatePoisonCharPal
        lda     #$04
        sta     $efd0,x

; doom
@deea:  lda     $10
        and     #$01
        beq     @df02
        phy
        lda     $47
        tay
        lda     $f0af,y
        bne     @df01
        ply
        jsl     UpdateDoomNum
        jmp     @dfd0
@df01:  ply

; magnetized
@df02:  lda     $10
        and     #$80
        beq     @df13
        lda     #$04
        sta     $efd0,x
        sta     $f078
        jmp     @dfd0

; mute
@df13:  lda     $0e
        and     #$04
        beq     @df26
        lda     #$04
        sta     $efd0,x
        lda     #$01
        sta     $f078
        jmp     @dfd0

; blind
@df26:  lda     $0e
        and     #$02
        beq     @df39
        lda     #$04
        sta     $efd0,x
        lda     #$02
        sta     $f078
        jmp     @dfd0

; curse
@df39:  lda     $0f
        and     #$80
        beq     @df4b
        lda     #$04
        sta     $efd0,x
        asl
        sta     $f078
        jmp     @dfd0

; no effect ???
@df4b:  phy
        lda     $47
        tay
        lda     $f0af,y
        beq     @df58
        ply
        jmp     @df59
@df58:  ply

; paralyze
@df59:  lda     $0f
        and     #$20
        beq     @df6c
        inc     $64
        lda     #$04
        sta     $efd0,x
        sta     $f078
        jmp     @dfd0

; sleep
@df6c:  lda     $0f
        and     #$10
        beq     @df80
        inc     $64
        lda     #$04
        sta     $efd0,x
        inc
        sta     $f078
        jmp     @dfd0

; charm
@df80:  lda     $0f
        and     #$08
        beq     @df90
        inc     $64
        lda     #$07
        sta     $f078
        jmp     @dfd0

; float
@df90:  lda     $0f
        and     #$40
        beq     @dfc1
        lda     $352d
        bne     @dfc1
        lda     $64
        bne     @dfc1
        phx
        lda     #4                      ; oscillation amplitude is 4 pixels
        sta     $1e
        lda     $47
        asl2
        clc
        adc     $1813
        asl3
        jsr     GetFloatOffset
        plx
        clc
        adc     #$f8
        sta     $efc8,x                 ; set y offset
        lda     #$06
        sta     $f078
        jmp     @dfd0

; low hp
@dfc1:  lda     $11
        and     #$01
        beq     @dfd0
        lda     #$04
        sta     $efd0,x
        dec
        sta     $f078

@dfd0:  lda     $0f
        and     #$08
        beq     @dfdb

; charm
        jsr     UpdateCharmedCharAnim
        bra     @dfde

@dfdb:  jsr     UpdateStepBack
@dfde:  jsr     UpdateCharSpritesheet
        jsr     UpdateCharMovement
        jsr     CheckPoseUpdate
        bcc     @dff9
        phx
        lda     $47
        tax
        lda     $f099,x
        beq     @dff8
        plx
        sta     $efd0,x
        bra     @dff9
@dff8:  plx
@dff9:  lda     $352d
        beq     @e011
        lda     $64
        bne     @e011
        lda     $47
        tay
        lda     $29c5,y
        cmp     #$ff
        beq     @e011
        lda     #$03                    ; running animation
        sta     $efd0,x
@e011:  ply
        plx
        rts

; ------------------------------------------------------------------------------

; [ get floating sprite y offset (far) ]

GetFloatOffset_far:
@e014:  jsr     GetFloatOffset
        rtl

; ------------------------------------------------------------------------------

; [ get floating sprite y offset ]

; multiply $1e by sin(A)

GetFloatOffset:
@e018:  tax
        lda     f:AnimSineTbl,x
        bpl     @e02f
        eor     #$ff
        sta     $1c
        jsr     MultHW
        lda     $21
        eor     #$ff
        inc
        bpl     @e038
@e02d:  sec
        rts
@e02f:  sta     $1c
        jsr     MultHW
        lda     $21
        bmi     @e02d
@e038:  clc
        rts

; ------------------------------------------------------------------------------

; [ update character spritesheet ]

UpdateCharSpritesheet:
@e03a:  lda     $f015,y
        and     #$30
        beq     @e053
        and     #$20
        beq     @e049
        lda     #$20                    ; use toad spritesheet
        bra     @e04b
@e049:  lda     #$10                    ; use mini spritesheet
@e04b:  sta     $f077
        jsr     SetCharSpriteTileMSB
        bra     @e07e
@e053:  lda     $f015,y
        and     #$08
        beq     @e05e
        lda     #$40
        bra     @e075
@e05e:  phy
        tya
        lsr2
        tay
        lda     $f235,y
        cmp     #$0f
        bcc     @e07a
        ply
        cmp     #$0f
        bne     @e073
        lda     #$30
        bra     @e075
@e073:  lda     #$30                    ; use golbez/anna spritesheet
@e075:  sta     $f077
        bra     @e07e
@e07a:  ply
        stz     $f077                   ; use normal spritesheet
@e07e:  phx
        lda     $47
        tax
        lda     $f077
        sta     $f094,x
        plx
        rts

; ------------------------------------------------------------------------------

; [ load character graphics (init) ]

InitCharGfx:
@e08a:  ldx     #0
        stx     $0a
@e08f:  phx
        lda     $29c5,x
        cmp     #$ff
        beq     @e0dc
        phx
        jsr     GetObjPtr
        lda     $2003,x
        and     #$08
        beq     @e0a6
        lda     #$0e
        bra     @e0ab
@e0a6:  lda     $2001,x
        and     #$1f
@e0ab:  plx
        sta     $f235,x
        cmp     #$0f
        bcc     @e0b9
        jsr     GetExtraCharGfxPtr
        jmp     @e0c4
@e0b9:  tax
        stx     $26
        ldx     #$0800
        stx     $28
        jsr     Mult16
@e0c4:  longa
        lda     $2a
        clc
        adc     #.loword(BattleCharGfx)
        tax
        lda     #$0800
        sta     $00
        ldy     $0a
        shorta0
        lda     #^BattleCharGfx
        jsr     TfrVRAM5
@e0dc:  longa
        lda     $0a
        clc
        adc     #$0400
        sta     $0a
        shorta0
        plx
        inx
        cpx     #5
        bne     @e08f
        rts

; ------------------------------------------------------------------------------

; [ get pointer to golbez/anna graphics ]

GetExtraCharGfxPtr:
@e0f1:  sec
        sbc     #$0f
        asl
        tax
        lda     f:ExtraCharGfxPtrs,x
        sta     $2a
        lda     f:ExtraCharGfxPtrs+1,x
        sta     $2b
        rts

; ------------------------------------------------------------------------------

; [ get pointer to character/monster properties (far) ]

GetObjPtr_far:
@e103:  jsr     GetObjPtr
        rtl

; ------------------------------------------------------------------------------

; [ get pointer to character/monster properties ]

GetObjPtr:
@e107:  longa
        txa
        asl7
        tax
        shorta0
        rts

; ------------------------------------------------------------------------------

; [ init character sprites ]

InitCharSprites:
@e116:  lda     $16a8                   ; get row setting
        sta     $f014
        lda     $6cc0
        beq     @e129
        lda     $f014                   ; toggle row for back attack
        eor     #1
        sta     $f014
@e129:  ldx     #0
@e12c:  phx
        stx     $00
        txa
        sta     $47
        asl4
        tay
        lda     f:FirstCharSpriteBelowTbl,x
        sta     $efc9,y
        phx
        lda     $29c5,x
        cmp     #$ff
        bne     @e149                   ; skip if character slot is empty
        clr_a
        bra     @e178
@e149:  jsr     GetObjPtr
        lda     $1801
        beq     @e173
        lda     $1800
        cmp     #$b6
        bne     @e173

; battle $01b6 (golbez and shadow dragon)
        lda     $2001,x
        and     #$0f
        cmp     #$0b
        bne     @e173                   ; branch if not rydia
        lda     $2005,x
        ora     #$82
        sta     $2005,x                 ; set magnetized and jump status ???
        ldx     $00
        lda     #1
        sta     $f2c1,x                 ; hide name and hp
        clr_a
        bra     @e178

@e173:  lda     $2000,x
        and     #$3f
@e178:  plx
        sta     $efc4,y
        clr_a
        sta     $efc7,y
        sta     $efc8,y
        sta     $efcc,y
        sta     $efce,y
        sta     $efcf,y
        sta     $efd1,y
        lda     $1900,y                 ; rng table
        sta     $efd3,y
        lda     #$01
        sta     $efd0,y
        lda     #$01
        sta     $efcd,y
        lda     $f014
        bne     @e1aa
        lda     f:CharSpriteDefaultXTbl,x
        bra     @e1ae
@e1aa:  lda     f:CharSpriteDefaultXTbl+5,x
@e1ae:  pha
        phy
        lda     $47
        asl2
        tay
        lda     $f015,y
        and     #$c0
        beq     @e1c0                   ; branch if not dead or stone
        ply
        pla
        bra     @e1c4
@e1c0:  ply
        pla
        lda     #$f0
@e1c4:  sta     $efc5,y
        lda     f:CharSpriteDefaultYTbl,x
        sta     $efc6,y
        jsr     InitCharEntry
        txa
        asl
        tax
        lda     f:CharSpriteTileOffsetTbl,x
        sta     $efca,y
        lda     f:CharSpriteTileOffsetTbl+1,x
        sta     $efcb,y
        plx
        inx
        cpx     #5
        beq     @e1ec
        jmp     @e12c
@e1ec:  rts

; ------------------------------------------------------------------------------

; [ init character entry animation ]

InitCharEntry:
@e1ed:  phx
        phy
        sty     $00
        ldx     $00
        lda     $47
        tay
        clr_a
        sta     $f08f,y
        lda     $47
        asl2
        tay
        lda     $f015,y
        and     #$c0
        bne     @e246
        lda     $f014                   ; row setting
        bne     @e216
        phx
        lda     $47
        tax
        lda     f:CharEntryDurTbl,x
        plx
        bra     @e21f
@e216:  phx
        lda     $47
        tax
        lda     f:CharEntryDurTbl+5,x
        plx
@e21f:  sta     $efcf,x
        lda     $f015,y
        and     #$30
        beq     @e23e
        and     #$20
        beq     @e235
        lda     $efce,x
        ora     #$10
        sta     $efce,x
@e235:  lda     $efcf,x                 ; toad and mini move twice as far
        asl
        sta     $efcf,x
        bra     @e246
@e23e:  lda     $efce,x
        ora     #$40
        sta     $efce,x
@e246:  jsr     UpdateCharSpritesheet
        ply
        plx
        rts

; ------------------------------------------------------------------------------

; [ update character sprites ]

UpdateCharSprites:
@e24c:  lda     #$f0
        ldx     #$0160
@e251:  sta     $0300,x                 ; hide sprites 88-127 (8 per char)
        inx
        cpx     #$0200
        bne     @e251
        ldx     #$0016
        clr_a
@e25e:  sta     $0500,x                 ; use small sprites
        inx
        cpx     #$0020
        bne     @e25e
        lda     $f320                   ; return if character sprites are hidden
        beq     @e26d
        rts
@e26d:  ldx     #0

; start of character loop
@e270:  phx
        txa
        stz     $f4a8
        sta     $47
        asl
        tay
        asl3
        tax
        lda     $efca,x
        sta     $efc2
        lda     $efcb,x
        sta     $efc3
        lda     #$07
        sta     $efd2,x
        jsr     UpdateCharAnim
        lda     $efcf,x
        beq     @e299
        inc     $f4a8
@e299:  lda     $efc4,x
        bne     @e2a1
        stz     $f078
@e2a1:  lda     $f43b
        beq     @e2a9
        sta     $efd2,x
@e2a9:  lda     $efc8,x
        sta     $10
        lda     $efc5,x                 ; set x position
        clc
        adc     $efc7,x
        sta     $efbb
        sec
        sbc     #$10
        sta     $6cf3,y                 ; set cursor x position
        phy
        tya
        asl
        tay
        lda     $f015,y
        and     #$c7
        bne     @e2e6
        lda     $f016,y
        bmi     @e2e6
        and     #$40
        beq     @e2e6
        phy
        lda     $47
        tay
        lda     $f0af,y
        beq     @e2e1
        ply
        stz     $10
        jmp     @e2e6
@e2e1:  ply
        lda     #$f8
        sta     $10
@e2e6:  lda     $f018,y
        and     #$0c
        beq     @e306                   ; branch if no image status
        lsr2
        ora     #$01
        sta     $0e
        phx
        lda     $efd1,x
        and     $0e
        tax
        lda     f:CharImageXTbl,x
        clc
        adc     $efbb
        sta     $efbb
        plx
@e306:  ply
        lda     $efc6,x                 ; set y position
        clc
        adc     $efc8,x
        sta     $efbc
        lda     $efc6,x
        clc
        adc     $10
        adc     #$08
        sta     $6cf4,y                 ; set cursor y position
        lda     $efc9,x
        sta     $efc0
        phx
        lda     $efcc,x                 ; petrify amount
        asl2
        tax
        tya
        clc
        adc     #$02                    ; char palette is 1 + char id
        sta     $0e
        and     f:PartialPetrifyPalMask,x
        sta     $efbd                   ; palette for top row of sprites
        lda     $0e
        and     f:PartialPetrifyPalMask+1,x
        sta     $efbe                   ; palette for middle row of sprites
        lda     $0e
        and     f:PartialPetrifyPalMask+2,x
        sta     $efbf                   ; palette for bottom row of sprites
        lda     $47
        tax
        lda     $f0bc,x
        beq     @e353
        sta     $efc0
@e353:  plx
        lda     $efce,x
        and     #$01
        sta     $efc1
        lda     $352d
        beq     @e36a
        lda     $64
        bne     @e36a
        lda     #1
        sta     $efc1                   ; h-flip sprites
@e36a:  lda     $efcd,x
        beq     @e37a
        lda     $efd1,x
        and     $efd2,x
        bne     @e37a
        inc     $efd3,x
@e37a:  inc     $efd1,x
        lda     $efd3,x
        and     #$03
        sta     $0e
        stz     $0f
        lda     $efc4,x
        bne     @e38f
        lda     #$1e
        bra     @e3d0
@e38f:  phx
        lda     $47
        asl2
        tax
        lda     $f015,x
        and     #$30
        bne     @e3b4                   ; branch if toad or mini
        lda     $f015,x
        and     #$08
        beq     @e3b4                   ; branch if not pig

; pig
        lda     $47
        tax
        lda     #$40                    ; use pig spritesheet
        sta     $f077
        sta     $f094,x
        plx
        lda     $efd0,x
        bra     @e3ba

; toad or mini, or not pig
@e3b4:  plx
        lda     $efd0,x
        beq     @e3cb
@e3ba:  clc
        adc     $f077                   ; add spritesheet offset
        longa
        asl2
        clc
        adc     $0e                     ; add pose counter (0..3)
        tax
        shorta0
        bra     @e3cc
@e3cb:  tax
@e3cc:  lda     f:CharAnimPoseTbl,x
@e3d0:  sta     $efba
        plx
        lda     $f316,x
        ora     $f31b,x
        beq     @e3e8                   ; branch if not using cover
        lda     $f316,x
        sta     $efbb
        lda     $f31b,x
        sta     $efbc
@e3e8:  jsr     DrawCharSprites
        lda     $efba
        cmp     #$24
        beq     @e412
        lda     $f44b
        ora     $f4a8
        ora     $f424
        ora     $f0bc,x                 ; weapon sprite
        ora     $f0af,x
        ora     $f2bc,x
        bne     @e412                   ; don't show status sprites
        lda     $352d
        beq     @e40f
        lda     $64
        beq     @e412
@e40f:  jsr     DrawStatusSprites
@e412:  inx
        cpx     #5
        beq     @e41b
        jmp     @e270
@e41b:  rts

; ------------------------------------------------------------------------------

; [ draw character sprite ]

; this draws the 6 (or 8) sprites that make up a character

DrawCharSprites:
@e41c:  phx
        lda     $f424
        beq     @e42e                   ; branch if using dead pose for all chars
        lda     $efba
        cmp     #$1e
        beq     @e42e                   ; branch if hidden pose
        lda     #$09                    ; dead pose
        sta     $efba
@e42e:  lda     #6
        sta     $1e
        lda     $efba                   ; sprite frame id
        sta     $1c
        tax
        jsr     MultHW
        lda     f:CharPoseOffsetTbl,x   ; sprite position id for each pose
        clc
        adc     $efc1
        sta     $1c
        lda     #$20
        sta     $1e
        ldx     $20
        stx     $0e
        jsr     MultHW
        lda     $efba
        cmp     #$24
        bne     @e46d                   ; branch if not pose $24 (special)
        lda     $efbd
        sta     $efbe
        sta     $efbf
        lda     #8                      ; draw 8 tiles
        sta     $22
        lda     $efc0                   ; use previous 2 sprites
        sec
        sbc     #2
        jmp     @e474
@e46d:  lda     #6                      ; draw 6 tiles
        sta     $22
        lda     $efc0
@e474:  longa
        asl2
        tay
        shorta0
        ldx     $efbb
        stx     $12
        ldx     $20
        stz     $16

; start of sprite loop
@e485:  lda     $efc2
        sta     $14
        lda     $efc3
        sta     $15
        lda     $16
        lsr
        cmp     #$03
        bcc     @e498                   ; branch if not special pose tile 6 or 7
        lda     #$02
@e498:  phx
        tax
        lda     $efbd,x                 ; palette
        ora     $15
        sta     $15
        ldx     $0e
        lda     f:CharTileTbl,x         ; character sprite tile id
        cmp     #$ff
        bne     @e4b3
        sta     $14
        lda     #$01
        sta     $15
        bra     @e4b8
@e4b3:  clc
        adc     $14
        sta     $14
@e4b8:  inx
        stx     $0e
        plx
        lda     f:CharSpriteOffsetTbl,x ; x position
        clc
        adc     $12
        jsr     BackAttackFlipX
        sta     $0300,y
        inx
        iny
        lda     f:CharSpriteOffsetTbl,x ; y position
        clc
        adc     $13
        sta     $0300,y
        inx
        iny
        lda     $6cc0
        beq     @e4e9

; h-flip
        longa
        lda     f:CharSpriteOffsetTbl,x ; flags
        ora     $14                     ; tile id
        eor     #$4000                  ; toggle h-flip
        bra     @e4f1

; no h-flip
@e4e9:  longa
        lda     f:CharSpriteOffsetTbl,x
        ora     $14
@e4f1:  sta     $0300,y
        shorta0
        inx
        iny
        inx
        iny
        inc     $16
        lda     $16
        cmp     $22
        bne     @e485
        plx
        rts

; ------------------------------------------------------------------------------

; [ draw damage numeral sprites ]

DrawDmgNumerals:
@e505:  lda     $f107
        beq     @e51a       ; return if damage numerals are disabled
        jsr     ResetAnimSpritesSmall
        inc     $f108
        lda     $f108
        cmp     #$2a
        bne     @e51d
        stz     $f107       ; disable damage numerals animation
@e51a:  jmp     @e5d8
@e51d:  ldy     #0
        ldx     #0
        stx     $10

; start of character/monster loop
@e525:  stz     $14
        lda     $f0fa,y
        beq     @e535                   ; branch if no damage numerals
        cmp     #$ff
        beq     @e533                   ; branch if miss
        jmp     @e5c2
@e533:  inc     $14
@e535:  lda     $f0d3,y                 ; x position
        sec
        sbc     #$10
        sta     $12
        phx
        lda     $f0e0,y                 ; y position
        sec
        sbc     #$08
        sta     $0e
        phy
        ldy     #0
        lda     $f108
        tax
        lda     $14
        bne     @e567                   ; branch if miss
@e552:  lda     f:DmgNumeralBounceTbl,x
        clc
        adc     $0e
        sta     a:$0013,y
        inx3                            ; successive digits are delayed by 3 frames
        iny
        cpy     #5
        bne     @e552
        bra     @e57c
@e567:  lda     $f108
        tax
        lda     f:DmgNumeralBounceTbl,x
        clc
        adc     $0e                     ; miss tiles bounce together
        sta     $13
        sta     $14
        sta     $15
        sta     $16
        sta     $17
@e57c:  lda     #5                      ; loop through 5 digits
        sta     $0e
        ply
        plx
        lda     $6cc0
        beq     @e590                   ; branch if not back attack
        lda     $12
        eor     #$ff
        sec
        sbc     #$20
        sta     $12

; start of digit loop
@e590:  lda     $12
        sta     $0340,x                 ; set sprite x position
        clc
        adc     #$08
        sta     $12
        inx
        phx
        lda     $0e
        dec
        tax
        lda     $13,x
        plx
        sta     $0340,x                 ; set sprite y position
        inx
        phx
        ldx     $10
        inx
        stx     $10
        lda     $dbe6,x                 ; set sprite tile id
        plx
        sta     $0340,x
        inx
        lda     $f0ed,y
        sta     $0340,x                 ; set sprite flags
        inx
        dec     $0e
        bne     @e590
        bra     @e5cf
@e5c2:  longa                           ; skip character/monster
        lda     $10
        clc
        adc     #5
        sta     $10
        shorta0
@e5cf:  iny                             ; next character/monster
        cpy     #13
        beq     @e5d8
        jmp     @e525
@e5d8:  rts

; ------------------------------------------------------------------------------

; [ draw weapon sprite ]

DrawWeaponSprite:
@e5d9:  lda     $f0c9
        beq     @e62f                   ; return if weapon sprite not shown
        lda     $f0ca                   ; sprite id
        sta     $0e
        lsr2
        tay
        lda     $0e
        and     #$03
        tax
        lda     f:LargeSpriteOrTbl,x
        sta     $10
        lda     f:LargeSpriteAndTbl,x
        sta     $11
        lda     $0500,y
        and     $11
        ora     $10
        sta     $0500,y
        lda     $0e
        longa
        asl2
        tax
        shorta0
        lda     $f0cd                   ; y position
        sta     $0301,x
        lda     $f0cb                   ; tile id
        sta     $0302,x
        lda     $6cc0
        beq     @e630

; h-flip
        lda     $f0cc                   ; x position
        eor     #$ff
        sec
        sbc     #$10
        sta     $0300,x
        lda     $f0ce                   ; tile flags
        eor     #$40
        sta     $0303,x
@e62f:  rts

; no h-flip
@e630:  lda     $f0cc
        sta     $0300,x
        lda     $f0ce
        sta     $0303,x
        rts

; ------------------------------------------------------------------------------

; [ draw weapon hit sprites ]

DrawWeaponHit:
@e63d:  lda     $f0c1                   ; return if hit sprite update is disabled
        bne     @e643
        rts
@e643:  stz     $f0c1                   ; disable hit sprite update
        lda     $f0c7
        bne     @e650

; $00: small sprites
        jsr     ResetAnimSpritesSmall
        bra     @e660

; $ff: large sprites
@e650:  cmp     #$ff
        beq     @e660
        cmp     #$fe
        beq     @e65d
        jsr     ResetAnimSpritesLarge
        bra     @e660

; $fe: harp attack
@e65d:  jsr     CopyHarpSpriteFlags
@e660:  lda     $f0c3
        asl
        tax
        lda     f:WeaponHitFramePtrs,x
        sta     $14
        lda     f:WeaponHitFramePtrs+1,x
        sta     $15
        lda     #^WeaponHitFramePtrs
        sta     $16
        lda     $f0c4                   ; x position
        sec
        sbc     #$18
        sta     $0e
        lda     $f0c5                   ; y position
        sec
        sbc     #$18
        sta     $10
        lda     $f0c6                   ; tile offset
        sta     $12
        lda     $f0c2                   ; first sprite id
        longa
        asl2
        tax
        shorta0
        ldy     #0
@e698:  lda     [$14],y
        cmp     #$ff
        beq     @e6df                   ; return if terminator
        pha
        and     #$f0                    ; x offset
        lsr
        clc
        adc     $0e
        jsr     BackAttackFlipX
        sta     $0300,x
        inx
        pla
        and     #$0f                    ; y offset
        asl3
        clc
        adc     $10
        sta     $0300,x
        inx
        iny
        lda     [$14],y                 ; tile id
        clc
        adc     $12
        sta     $0300,x
        inx
        iny
        lda     $6cc0
        beq     @e6d5

; h-flip
        lda     $f0c8                   ; tile flags
        eor     #$40
        sta     $0300,x
        inx
        jmp     @e698

; no h-flip
@e6d5:  lda     $f0c8
        sta     $0300,x
        inx
        jmp     @e698
@e6df:  rts

; ------------------------------------------------------------------------------

; [ copy sprite flags for harp attack sprites ]

CopyHarpSpriteFlags:
@e6e0:  ldx     #$0020
@e6e3:  lda     $033f,x
        sta     $0343,x
        dex
        bne     @e6e3
        rts

; ------------------------------------------------------------------------------

; [ reset animation sprites ]

ResetAnimSprites:
@e6ed:  ldx     #$0040
        lda     #$f0
@e6f2:  sta     $0300,x                 ; reset sprites 16-88
        inx
        cpx     #$0160
        bne     @e6f2
        stz     $f42b
        rts

; ------------------------------------------------------------------------------

; [ reset animation sprites, use 8x8 sprites (far) ]

ResetAnimSpritesSmall_far:
@e6ff:  jsr     ResetAnimSpritesSmall
        rtl

; ------------------------------------------------------------------------------

; [ reset animation sprites, use 16x16 sprites (far) ]

ResetAnimSpritesLarge_far:
@e703:  jsr     ResetAnimSpritesLarge
        rtl

; ------------------------------------------------------------------------------

; [ reset animation sprites, use 16x16 sprites ]

ResetAnimSpritesLarge:
@e707:  phx
        ldx     #0
        lda     #$aa                    ; use large sprites
        inc     $f42b
@e710:  sta     $0504,x
        inx
        cpx     #$0012
        bne     @e710
        jsr     ResetAnimSprites
        plx
        rts

; ------------------------------------------------------------------------------

; [ reset animation sprites, use 8x8 sprites ]

ResetAnimSpritesSmall:
@e71e:  phx
        clr_ax
        inc     $f42b
@e724:  sta     $0504,x                 ; use small sprites
        inx
        cpx     #$0012
        bne     @e724
        jsr     ResetAnimSprites
        plx
        rts

; ------------------------------------------------------------------------------
