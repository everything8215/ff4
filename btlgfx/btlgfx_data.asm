
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: btlgfx_data.asm                                                      |
; |                                                                            |
; | description: data for battle graphics module                               |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

.import BattleProp, MonsterName
.import WindowGfx, WindowPal, BattleCmdName

.export ItemName, MagicName
.export MiscBattleGfx, BattleCharGfx, BattleCharPal

; ------------------------------------------------------------------------------

.segment "monster_gfx1"

; 09/8000
        .include "gfx/monster_gfx1.asm"

; ------------------------------------------------------------------------------

.segment "monster_gfx2"

; 0a/8000
        .include "gfx/monster_gfx2.asm"

; ------------------------------------------------------------------------------

.segment "monster_gfx3"

; 0b/8000
        .include "gfx/monster_gfx3.asm"

; ------------------------------------------------------------------------------

.segment "monster_gfx4"

; 0c/8000
        .include "gfx/monster_gfx4.asm"

; ------------------------------------------------------------------------------

.segment "battle_anim_gfx"

; 0c/b6c0
        .include "gfx/anim_gfx.asm"

; 0c/f3c0
        .include "data/anim_tiles.asm"

; ------------------------------------------------------------------------------

.segment "misc_battle_gfx"

; 0c/f9c0
        .include .sprintf("gfx/misc_sprite_gfx_%s.asm", LANG_SUFFIX)

; 0c/ff30
        .include "gfx/shadow_gfx.asm"

; ------------------------------------------------------------------------------

.segment "summon_gfx"

; 0d/87f0
SummonGfxPtrs:
        .addr   MonsterGfx5_0000
        .addr   MonsterGfx5_0001
        .addr   MonsterGfx5_0002
        .addr   MonsterGfx5_0003
        .addr   MonsterGfx5_0004
        .addr   MonsterGfx5_0005
        .addr   MonsterGfx5_0006
        .addr   MonsterGfx5_0007
        .addr   MonsterGfx5_0008
        .addr   MonsterGfx5_0009
        .addr   MonsterGfx5_000a
        .addr   MonsterGfx5_000b
        .addr   MonsterGfx5_000c
        .addr   MonsterGfx5_000e
        .addr   MonsterGfx5_000e
        .addr   MonsterGfx5_000e
        .addr   MonsterGfx5_000d

.align 8
; 0d/8818
        .include "gfx/monster_gfx5.asm"

; ------------------------------------------------------------------------------

.segment "summon_tilemap"

; 0d/f260
SummonTilemapPtrs:
        make_ptr_tbl_rel SummonTilemap, 17, .bankbyte(*)<<16

; 0d/f282
        .include "data/summon_tilemap.asm"

; ------------------------------------------------------------------------------

.segment "summon_frame"

; 0d/f660
SummonFramePtrs:
        make_ptr_tbl_rel SummonFrame, 29, .bankbyte(*)<<16

; 0d/f69a
        .include "data/summon_frame.asm"

; ------------------------------------------------------------------------------

.segment "btlgfx_data1"

; battle message durations (in frames, based on battle message speed)
MsgDurTbl:
@f800:  .word   $0020,$0040,$0060,$0080,$00a0,$00c0

; white/summon pre-magic animation tile id
PreMagicAnimTilesTbl:
@f80c:  .byte   $c0,$c2,$8e,$c2,$c0,$c2,$8e,$c2,$8e,$8c,$8e,$8c,$8e,$8c,$8e,$8c

; white/summon pre-magic animation sprite flags
PreMagicAnimFlagsTbl:
@f81c:  .byte   $3f,$7f,$7f,$ff,$bf,$3f,$3f,$bf,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f

_0df82c:
@f82c:  .byte   $00,$0d,$00,$0d,$00,$0d,$00,$0d,$00,$ed,$00,$ed,$00,$ed,$00,$ed

; battle character sprite offset id for each pose
CharPoseOffsetTbl:
@f83c:  .byte   $00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$00,$00,$04,$04,$04,$04
        .byte   $04,$04,$04,$00,$04,$04,$04,$04,$04,$04,$04,$04,$04,$00,$00,$00
        .byte   $00,$00,$00,$02,$06

; sprite positions for character poses
CharSpriteOffsetTbl:
@f861:  .byte   $00,$00,$00,$30,$08,$00,$00,$30  ; $00: normal (2x3)
        .byte   $00,$08,$00,$30,$08,$08,$00,$30
        .byte   $00,$10,$00,$30,$08,$10,$00,$30
        .byte   $00,$00,$00,$00,$00,$00,$00,$00

        .byte   $08,$00,$00,$70,$00,$00,$00,$70  ; $01: normal, h-flip (2x3)
        .byte   $08,$08,$00,$70,$00,$08,$00,$70
        .byte   $08,$10,$00,$70,$00,$10,$00,$70
        .byte   $00,$00,$00,$00,$00,$00,$00,$00

        .byte   $f8,$08,$00,$30,$00,$08,$00,$30  ; $02: dead (3x2)
        .byte   $08,$08,$00,$30,$f8,$10,$00,$30
        .byte   $00,$10,$00,$30,$08,$10,$00,$30
        .byte   $00,$00,$00,$00,$00,$00,$00,$00

        .byte   $10,$08,$00,$70,$08,$08,$00,$70  ; $03: dead, h-flip (3x2)
        .byte   $00,$08,$00,$70,$10,$10,$00,$70
        .byte   $08,$10,$00,$70,$00,$10,$00,$70
        .byte   $00,$00,$00,$00,$00,$00,$00,$00

        .byte   $04,$00,$00,$30,$0c,$00,$00,$30  ; $04: mini/toad (2x3)
        .byte   $04,$08,$00,$30,$0c,$08,$00,$30
        .byte   $04,$10,$00,$30,$0c,$10,$00,$30
        .byte   $00,$00,$00,$00,$00,$00,$00,$00

        .byte   $04,$00,$00,$70,$fc,$00,$00,$70  ; $05: mini/toad, h-flip (2x3)
        .byte   $04,$08,$00,$70,$fc,$08,$00,$70
        .byte   $04,$10,$00,$70,$fc,$10,$00,$70
        .byte   $00,$00,$00,$00,$00,$00,$00,$00

; $06: special (2x3)
        .byte   $f8,$00,$00,$30,$00,$00,$00,$30,$08,$00,$00,$30
        .byte   $f8,$08,$00,$30,$00,$08,$00,$30,$08,$08,$00,$30
        .byte                   $00,$10,$00,$30,$08,$10,$00,$30

; $07: special, h-flip (2x3)
        .byte   $08,$00,$00,$70,$00,$00,$00,$70,$f8,$00,$00,$70
        .byte   $08,$08,$00,$70,$00,$08,$00,$70,$f8,$08,$00,$70
        .byte                   $00,$10,$00,$70,$f8,$10,$00,$70

; battle character sprite tiles for each pose
CharTileTbl:
@f961:  .byte   $00,$01,$02,$03,$04,$05  ; $00: standing
        .byte   $06,$07,$08,$09,$0a,$0b  ; $01: ready
        .byte   $00,$01,$02,$03,$0c,$0d  ; $02: running
        .byte   $0e,$0f,$10,$11,$12,$13  ; $03: kneeling
        .byte   $00,$01,$14,$03,$15,$0d  ; $04: right arm up
        .byte   $00,$01,$16,$17,$18,$19  ; $05: left arm down
        .byte   $00,$1a,$02,$1b,$1c,$1d  ; $06: left arm up
        .byte   $1e,$1f,$20,$21,$22,$23  ; $07: hit
        .byte   $24,$25,$26,$27,$28,$29  ; $08: victory
        .byte   $2a,$2b,$2c,$2d,$2e,$2f  ; $09: dead
        .byte   $39,$3a,$3b,$3c,$3d,$3e  ; $0a: chant 1
        .byte   $39,$3a,$3f,$3c,$3d,$3e  ; $0b: chant 2
        .byte   $ff,$ff,$ff,$ff,$40,$ff  ; $0c: mini, normal
        .byte   $ff,$ff,$ff,$ff,$41,$ff  ; $0d: mini, ready
        .byte   $ff,$ff,$ff,$ff,$42,$ff  ; $0e: mini, running
        .byte   $ff,$ff,$ff,$ff,$43,$ff  ; $0f: mini, kneeling
        .byte   $ff,$ff,$ff,$ff,$44,$ff  ; $10: mini, attacking
        .byte   $ff,$ff,$ff,$ff,$45,$ff  ; $11: mini, hit
        .byte   $ff,$ff,$ff,$ff,$46,$ff  ; $12: mini, victory
        .byte   $ff,$ff,$ff,$ff,$47,$48  ; $13: mini, dead
        .byte   $ff,$ff,$ff,$ff,$49,$ff  ; $14: mini, chant 1
        .byte   $ff,$ff,$ff,$ff,$50,$ff  ; $15: mini, chant 2
        .byte   $ff,$ff,$ff,$ff,$51,$ff  ; $16: toad, normal
        .byte   $ff,$ff,$ff,$ff,$52,$ff  ; $17: toad, ready
        .byte   $ff,$ff,$ff,$ff,$53,$ff  ; $18: toad, running
        .byte   $ff,$ff,$ff,$ff,$54,$ff  ; $19: toad, kneeling
        .byte   $ff,$ff,$ff,$ff,$55,$ff  ; $1a: toad, attacking
        .byte   $ff,$ff,$ff,$ff,$56,$ff  ; $1b: toad, hit
        .byte   $ff,$ff,$ff,$ff,$57,$ff  ; $1c: toad, victory
        .byte   $ff,$ff,$ff,$ff,$58,$59  ; $1d: toad, dead
        .byte   $ff,$ff,$ff,$ff,$ff,$ff  ; $1e: hidden
        .byte   $00,$01,$02,$03,$06,$07  ; $1f: running (golbez/anna)
        .byte   $08,$09,$0a,$0b,$0c,$0d  ; $20: chant 1 (golbez)
        .byte   $08,$09,$0e,$0b,$0c,$0d  ; $21: chant 2 (golbez)
        .byte   $0f,$10,$11,$12,$13,$14  ; $22: casting (golbez)
        .byte   $15,$16,$17,$18,$19,$1a  ; $23: dead (golbez)
        .byte   $30,$31,$32,$33,$34,$35,$37,$38  ; $24: special

LargeSpriteOrTbl:
@fa41:  .byte   $02,$08,$20,$80

LargeSpriteAndTbl:
@fa45:  .byte   $fc,$f3,$cf,$3f

; animation frames for sword/whip hit
SwordWhipHitFrameTbl:
@fa49:  .byte   $20,$20,$00,$01,$02,$03,$04,$20
        .byte   $20,$20,$00,$01,$05,$03,$04,$20
        .byte   $20,$20,$00,$01,$06,$03,$04,$20
        .byte   $20,$20,$07,$08,$09,$0a,$0b,$20
        .byte   $20,$20,$0c,$0d,$0e,$0f,$10,$20
        .byte   $20,$20,$11,$12,$13,$14,$15,$20
        .byte   $20,$20,$16,$17,$18,$19,$1a,$20
        .byte   $20,$20,$1b,$1c,$1d,$1e,$1f,$20

; pointers to weapon hit animation data
WeaponHitFramePtrs:
@fa89:  make_ptr_tbl_abs WeaponHitFrame, 35

; weapon hit animation data

; terminated by $ff
; 2 bytes per sprite
; possible 16 sprites max
;   $00: position offset (xxxxyyyy)
;   $01: tile offset

WeaponHitFrame_0022:
        .byte  $33,$60,$ff

WeaponHitFrame_0000:
        .byte  $50,$00,$41,$01,$51,$02,$32,$03,$42,$04,$ff

WeaponHitFrame_0001:
        .byte  $50,$00,$41,$01,$51,$02,$32,$01,$42,$05,$23,$03,$33,$04,$ff

WeaponHitFrame_0002:
        .byte  $50,$00,$41,$01,$51,$02,$32,$01,$42,$05,$23,$01,$33,$05,$14,$01
        .byte  $24,$05,$05,$03,$15,$04,$ff

WeaponHitFrame_0003:
        .byte  $32,$00,$23,$01,$33,$02,$14,$01,$24,$05,$05,$03,$15,$04,$ff

WeaponHitFrame_0004:
        .byte  $23,$00,$14,$01,$24,$02,$05,$03,$15,$04,$ff

WeaponHitFrame_0005:
        .byte  $50,$00,$41,$01,$51,$02,$22,$0a,$32,$0b,$42,$05,$23,$0c,$33,$0d
        .byte  $14,$01,$24,$05,$05,$03,$15,$04,$ff

WeaponHitFrame_0006:
        .byte  $50,$00,$41,$01,$51,$02,$22,$06,$32,$07,$42,$05,$23,$08,$33,$09
        .byte  $14,$01,$24,$05,$05,$03,$15,$04,$ff

WeaponHitFrame_0007:
        .byte  $21,$00,$31,$01,$ff

WeaponHitFrame_0008:
        .byte  $21,$00,$31,$01,$12,$02,$22,$03,$ff

WeaponHitFrame_0009:
        .byte  $21,$00,$31,$01,$12,$02,$22,$03,$13,$04,$14,$05,$ff

WeaponHitFrame_000a:
        .byte  $12,$02,$22,$03,$13,$04,$14,$05,$24,$06,$ff

WeaponHitFrame_000b:
        .byte  $13,$04,$14,$05,$24,$06,$34,$07,$44,$08,$43,$09,$ff

WeaponHitFrame_000c:
WeaponHitFrame_0011:
        .byte  $40,$00,$50,$01,$41,$02,$51,$03,$ff

WeaponHitFrame_000d:
WeaponHitFrame_0012:
        .byte  $40,$04,$50,$05,$31,$00,$41,$01,$51,$06,$32,$02,$42,$03,$ff

WeaponHitFrame_000e:
WeaponHitFrame_0013:
        .byte  $40,$07,$50,$08,$31,$04,$41,$05,$51,$09,$22,$00,$32,$01,$42,$06
        .byte  $23,$02,$33,$03,$ff

WeaponHitFrame_000f:
WeaponHitFrame_0014:
        .byte  $40,$04,$50,$05,$31,$07,$41,$08,$51,$06,$22,$04,$32,$05,$42,$09
        .byte  $13,$00,$23,$01,$33,$06,$14,$02,$24,$03,$ff

WeaponHitFrame_0010:
WeaponHitFrame_0015:
        .byte  $40,$07,$50,$08,$31,$04,$41,$05,$51,$09,$22,$07,$32,$08,$42,$06
        .byte  $13,$04,$23,$05,$33,$09,$04,$00,$14,$01,$24,$06,$05,$02,$15,$03
        .byte  $ff

WeaponHitFrame_0016:
        .byte  $40,$00,$50,$01,$31,$02,$41,$03,$51,$04,$32,$05,$42,$06,$ff

WeaponHitFrame_0017:
        .byte  $40,$00,$50,$01,$31,$07,$41,$08,$51,$04,$22,$02,$32,$03,$42,$09
        .byte  $23,$05,$33,$06,$ff

WeaponHitFrame_0018:
        .byte  $40,$00,$50,$01,$31,$0a,$41,$0b,$51,$04,$22,$07,$32,$08,$42,$0c
        .byte  $13,$02,$23,$03,$33,$09,$14,$05,$24,$06,$ff

WeaponHitFrame_0019:
        .byte  $40,$00,$50,$01,$31,$07,$41,$08,$51,$04,$22,$0a,$32,$0b,$42,$09
        .byte  $13,$07,$23,$08,$33,$0c,$04,$02,$14,$03,$24,$09,$05,$05,$15,$06
        .byte  $ff

WeaponHitFrame_001a:
        .byte  $13,$00,$23,$01,$04,$02,$14,$03,$24,$04,$05,$05,$15,$06,$ff

WeaponHitFrame_001b:
        .byte  $40,$01,$50,$02,$41,$09,$51,$0a,$ff

WeaponHitFrame_001c:
        .byte  $40,$03,$50,$04,$60,$05,$31,$01,$41,$07,$51,$08,$32,$09,$42,$0a
        .byte  $ff

WeaponHitFrame_001d:
        .byte  $40,$01,$50,$02,$31,$01,$41,$02,$51,$0a,$22,$01,$32,$02,$42,$0a
        .byte  $23,$09,$33,$0a,$ff

WeaponHitFrame_001e:
        .byte  $40,$03,$50,$04,$60,$05,$31,$01,$41,$07,$51,$08,$22,$03,$32,$04
        .byte  $42,$05,$13,$01,$23,$07,$33,$08,$14,$09,$24,$0a,$ff

WeaponHitFrame_001f:
        .byte  $40,$01,$50,$02,$31,$01,$41,$02,$51,$0a,$22,$01,$32,$02,$42,$0a
        .byte  $13,$03,$23,$04,$33,$05,$04,$01,$14,$07,$24,$08,$05,$09,$15,$0a
        .byte  $ff

WeaponHitFrame_0020:
        .byte  $ff

WeaponHitFrame_0021:
        .byte  $00,$00,$ff

; battle bg properties (17 * 4 bytes)
@fccb:  .include "data/battle_bg_prop.asm"

_0dfd0f:
@fd0f:  .byte   $00,$04,$08,$0c,$12,$17,$1b,$1f

; pointers to character timer data (for getting doom timer)
CharTimerPtrs:
@fd17:  .byte   $00,$15,$2a,$3f,$54

; final battle ghost character data
;   +$00: 1st character graphics pointer (bank $1a)
;   +$02: 2nd character graphics pointer (bank $1a)
;    $04: 1st character palette
;    $05: 2nd character palette
;    $06: 1st character xy position
;    $07: 2nd character xy position
GhostCharTbl:
@fd1c:  .word   .loword(BattleCharGfx_0010)  ; 0: anna (unused)
        .word   .loword(BattleCharGfx_0010)
        .byte   $0f,$0f,$f6,$f6
        .word   .loword(BattleCharGfx_0004)  ; 1: edward and tellah
        .word   .loword(BattleCharGfx_0003)
        .byte   $04,$03,$c5,$f5
        .word   .loword(BattleCharGfx_0007)  ; 2: palom and porom
        .word   .loword(BattleCharGfx_0008)
        .byte   $07,$08,$c5,$f5
        .word   .loword(BattleCharGfx_0006)  ; 3: yang and cid
        .word   .loword(BattleCharGfx_000a)
        .byte   $06,$0a,$c5,$f5
        .word   .loword(BattleCharGfx_000d)  ; 4: fusoya and golbez
        .word   .loword(BattleCharGfx_000f)
        .byte   $0d,$0e,$c5,$f5
        .word   .loword(BattleCharGfx_0010)  ; 5: anna (kaipo cutscene)
        .word   .loword(BattleCharGfx_0010)
        .byte   $0f,$0f,$b6,$b6

; enemy character weapon sprite data -> $f0ca
;       $00: sprite id
;       $01: tile id
;       $02: x position
;       $03: y position
;       $04: tile flags
;   $05-$07: unused
EnemyCharWeaponTbl:
@fd4c:  .byte   $10,$80,$18,$43,$3f,$00,$00,$00  ; frame 1
        .byte   $10,$80,$38,$50,$7f,$00,$00,$00  ; frame 2

_0dfd5c:
@fd5c:  .byte   $00,$00,$80,$80,$c0,$c0,$e0,$e0,$f0,$f0,$f8,$f8,$fc,$fc,$fe,$fe
        .byte   $ff

; pointers to enemy character pose tiles
EnemyCharTilesPtrs:
@fd6d:  make_ptr_tbl_abs EnemyCharTiles, 14

; enemy character pose tiles
EnemyCharTiles_0000:
        .byte  $01,$00,$ff,$03,$02,$ff,$05,$04,$ff
EnemyCharTiles_0001:
        .byte  $07,$06,$ff,$09,$08,$ff,$0b,$0a,$ff
EnemyCharTiles_0002:
        .byte  $01,$00,$ff,$03,$02,$ff,$0d,$0c,$ff
EnemyCharTiles_0003:
        .byte  $0f,$0e,$ff,$11,$10,$ff,$13,$12,$ff
EnemyCharTiles_0004:
        .byte  $01,$00,$ff,$03,$14,$ff,$0d,$15,$ff
EnemyCharTiles_0005:
        .byte  $01,$00,$ff,$17,$16,$ff,$19,$18,$ff
EnemyCharTiles_0006:
        .byte  $1a,$00,$ff,$1b,$02,$ff,$1d,$1c,$ff
EnemyCharTiles_0007:
        .byte  $1f,$1e,$ff,$21,$20,$ff,$23,$22,$ff
EnemyCharTiles_0008:
        .byte  $25,$24,$ff,$27,$26,$ff,$29,$28,$ff
EnemyCharTiles_0009:
        .byte  $2b,$2a,$ff,$2d,$2c,$ff,$2f,$2e,$ff
EnemyCharTiles_000a:
        .byte  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
EnemyCharTiles_000b:
        .byte  $3a,$39,$ff,$3c,$3b,$ff,$3e,$3d,$ff
EnemyCharTiles_000c:
        .byte  $32,$31,$30,$35,$34,$33,$38,$37,$ff
EnemyCharTiles_000d:
        .byte  $30,$31,$32,$33,$34,$35,$ff,$37,$38

_0dfe07:
@fe07:  .byte   $82,$84,$86,$e0,$82,$84,$86,$e0

_0dfe0f:
@fe0f:  .byte   $e0,$86,$84,$82

_0dfe13:
@fe13:  .byte   $86,$88,$86,$aa
        .byte   $88,$86,$aa,$aa
        .byte   $a4,$8a,$aa,$a4

_0dfe1f:
@fe1f:  .byte   $00,$00,$10,$00,$00,$10,$10,$10,$20,$10,$00,$20,$10,$20,$20,$20
        .byte   $30,$20,$10,$30,$20,$30,$30,$30

_0dfe37:
@fe37:  .byte   $4c,$38,$2c,$20,$10

_0dfe3c:
@fe3c:  .byte   $10,$18,$20,$18,$10

_0dfe41:
@fe41:  .byte   $50,$58,$60,$58,$50

_0dfe46:
@fe46:  .byte   $00,$18,$30,$48,$60,$78

; palette id for each summon
SummonPalTbl:
@fe4c:  .byte   $00,$55,$24,$3f,$cd,$ce,$cf,$d0,$d1,$a1,$d2,$bc,$bd,$c0,$c0,$c0
        .byte   $be

; swap left and right button (xor 3)
SwapLeftRightTbl:
@fe5d:  .byte   $00,$02,$01,$03

; reflect sprite data
ReflectSpriteTbl:
@fe61:  .byte   $00,$f0,$ec,$3d
        .byte   $00,$00,$ec,$bd

; menu hdma properties -> $183F (32 * 6 bytes)

;  +$00: source address
;  +$02: destination address
;   $04: number of rows (8 scanlines per row)
;   $05: 0 = open, 1 = close

MenuHDMAProp:
@fe69:  .addr   $8092,$7f42  ; $00: open character/monster name window
        .byte   10,0
        .addr   $81b2,$8062  ; $01: close character/monster name window
        .byte   10,1
        .addr   $8312,$7f42  ; $02: open command list window
        .byte   10,0
        .addr   $8432,$8062  ; $03: close command list window
        .byte   10,1
        .addr   $81d2,$7f52  ; $04: open inventory/spell list window
        .byte   10,0
        .addr   $82f2,$8072  ; $05: close inventory/spell list window
        .byte   10,1
        .addr   $8452,$7f62  ; $06: open equipment window
        .byte   5,0
        .addr   $84d2,$7fe2  ; $07: close equipment window
        .byte   5,1
        .addr   $84f2,$7bf2  ; $08: open mp cost window
        .byte   8,0
        .addr   $85d2,$7cd2  ; $09: close mp cost window
        .byte   8,1
        .addr   $8872,$7bc2  ; $0a: open defend window (position 1)
        .byte   4,0
        .addr   $88d2,$7c22  ; $0b: close defend window (position 1)
        .byte   4,1
        .addr   $88f2,$7bf2  ; $0c: open defend window (position 2)
        .byte   4,0
        .addr   $8952,$7c52  ; $0d: close defend window (position 2)
        .byte   4,1
        .addr   $8972,$7c22  ; $0e: open defend window (position 3)
        .byte   4,0
        .addr   $89d2,$7c82  ; $0f: close defend window (position 3)
        .byte   4,1
        .addr   $89f2,$7c52  ; $10: open defend window (position 4)
        .byte   4,0
        .addr   $8a52,$7cb2  ; $11: close defend window (position 4)
        .byte   4,1
        .addr   $8a72,$7c82  ; $12: open defend window (position 5)
        .byte   4,0
        .addr   $8ad2,$7ce2  ; $13: close defend window (position 5)
        .byte   4,1
        .addr   $85f2,$7bc2  ; $14: open row window (position 1)
        .byte   4,0
        .addr   $8652,$7c22  ; $15: close row window (position 1)
        .byte   4,1
        .addr   $8672,$7bf2  ; $16: open row window (position 2)
        .byte   4,0
        .addr   $86d2,$7c52  ; $17: close row window (position 2)
        .byte   4,1
        .addr   $86f2,$7c22  ; $18: open row window (position 3)
        .byte   4,0
        .addr   $8752,$7c82  ; $19: close row window (position 3)
        .byte   4,1
        .addr   $8772,$7c52  ; $1a: open row window (position 4)
        .byte   4,0
        .addr   $87d2,$7cb2  ; $1b: close row window (position 4)
        .byte   4,1
        .addr   $87f2,$7c82  ; $1c: open row window (position 5)
        .byte   4,0
        .addr   $8852,$7ce2  ; $1d: close row window (position 5)
        .byte   4,1
        .addr   $8af2,$7f62  ; $1e: open character status window
        .byte   10,0
        .addr   $8c12,$8082  ; $1f: close character status window
        .byte   10,1

; bg scroll hdma tables (3 * 7 bytes)
ScrollHDMATbl:
@ff29:  .byte   $f0,$12,$76,$f0,$d2,$77,$80
        .byte   $f0,$92,$79,$f0,$52,$7b,$80
        .byte   $f0,$12,$7d,$f0,$d2,$7e,$80

; animation frame sizes (16 * 2 bytes)
AnimFrameSizeTbl:
@ff3e:  .byte   $01,$01,$03,$03,$02,$02,$05,$09,$0c,$09,$10,$09,$04,$04,$04,$09
        .byte   $03,$04,$0c,$01,$02,$03,$06,$09,$01,$02,$04,$09,$06,$09,$06,$06

; monster graphics sizes (43 * 2 bytes)
@ff5e:  .include "data/monster_size.asm"

; flying monster y-offsets (16 * 1 byte)
FlyingOffsetTbl:
@ffb4:  .byte   0,0,0,0,1,1,1,2,2,3,3,3,2,2,1,1

; flying monster shadow data (16 * 1 byte)
FlyingShadowTbl:
@ffc4:  .byte   $c0,$c0,$c0,$c0,$80,$80,$80,$40,$40,$00,$00,$00,$40,$40,$80,$80

; pointers to character battle command data in ram
CharCmdPtrs:
@ffd4:  .byte   $00,$1c,$38,$54,$70

; animation speeds
AnimSpeedTbl:
@ffd9:  .byte   $07,$03,$01,$00

; screen shake offsets for animations
AnimShakeTbl:
@ffdd:  .byte   $01,$02,$04,$02,$01,$00,$02,$02

; y-offset for toad hopping
ToadHopTbl:
@ffe5:  .byte   $00,$fb,$f6,$f3,$f0,$f0,$f6,$fa

; amount to darken battle bg palettes (final battle bg goes to black)
DarkenBattleBGTbl:
@ffed:  .byte   $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
        .byte   $1f

; ------------------------------------------------------------------------------

.segment "battle_anim_pal"

; 0e/cb00
        .include "gfx/anim_pal.asm"

; ------------------------------------------------------------------------------

.segment "boss_tilemap"

; 0e/cf00
BossTilemapPtrs:
        make_ptr_tbl_rel BossTilemap, 57, .bankbyte(*)<<16

; 0e/cf72
        .include "data/boss_tilemap.asm"

; ------------------------------------------------------------------------------

.segment "battle_dlg"

; 0e/f200
BattleDlgPtrs:
        make_ptr_tbl_rel BattleDlg, $ba, .bankbyte(*)<<16

; 0e/f374
        .include .sprintf("text/battle_dlg_%s.asm", LANG_SUFFIX)

; ------------------------------------------------------------------------------

.segment "attack_name"

; 0f/8000
        .include .sprintf("text/item_name_%s.asm", LANG_SUFFIX)

; 0f/8900
        .include .sprintf("text/magic_name_%s.asm", LANG_SUFFIX)

; 0f/8ab0
        .include .sprintf("text/attack_name_%s.asm", LANG_SUFFIX)

.segment "attack_anim"

; 0f/9e10
        .include "data/weapon_anim_prop.asm"

; 0f/a050
        .include .sprintf("data/anim_prop_%s.asm", LANG_SUFFIX)

; 0f/a350
        .include "data/attack_sfx.asm"

; ------------------------------------------------------------------------------

.segment "status_name"

; 0f/a858 (0f/b400 in the english translation)
StatusNamePtrs:
        make_ptr_tbl_rel StatusName, 32, .bankbyte(*)<<16

; 0f/a898 (0f/b440 in the english translation)
        .include .sprintf("text/status_name_%s.asm", LANG_SUFFIX)

; ------------------------------------------------------------------------------

; 0f/b200 (0f/b000 in the english translation)
.segment "battle_msg"

BattleMsgPtrs:
        make_ptr_tbl_rel BattleMsg, 59, .bankbyte(*)<<16

; 0f/b276
        .include .sprintf("text/battle_msg_%s.asm", LANG_SUFFIX)

; ------------------------------------------------------------------------------

.segment "monster_gfx_prop"

; 0f/ca00
        .include "data/monster_gfx_prop.asm"

; 0f/ce00
        .include "data/boss_gfx_prop.asm"

; ------------------------------------------------------------------------------

.segment "battle_bg_pal"

; 0f/d200
        .include "gfx/battle_bg_pal.asm"

; ------------------------------------------------------------------------------

.segment "battle_anim"

; 0f/d4e0
        .include "data/item_magic_anim.asm"

; 0f/d5e0
AnimScriptPtrs:
        make_ptr_tbl_rel AnimScript, 79, .bankbyte(*)<<16

; 0f/d67e
        .include "data/anim_script.asm"
        .res $0800+AnimScriptPtrs-*

; 0f/dde0
AnimFramePtrs:
        make_ptr_tbl_rel AnimFrame, 361, .bankbyte(*)<<16

; 0f/e0b2
        .include "data/anim_frame.asm"

; Some of the animation frame pointers point to the beginning of the
; animation script. These frames are not present in the frame data
; so their labels are defined at the beginning of the animation scripts.
; The bugfix moves these labels to the beginning of the frame data.

.ifndef AnimFrame_00bb

.if BUGFIX_ANIM_FRAME_PTRS
        ANIM_FRAME_NULL := AnimFrame
.else
        ANIM_FRAME_NULL := AnimScript
.endif

AnimFrame_00bb := ANIM_FRAME_NULL
AnimFrame_00bc := ANIM_FRAME_NULL
AnimFrame_00e9 := ANIM_FRAME_NULL
AnimFrame_010d := ANIM_FRAME_NULL
AnimFrame_010e := ANIM_FRAME_NULL
AnimFrame_011f := ANIM_FRAME_NULL
AnimFrame_0120 := ANIM_FRAME_NULL
AnimFrame_0121 := ANIM_FRAME_NULL
AnimFrame_0122 := ANIM_FRAME_NULL
AnimFrame_012e := ANIM_FRAME_NULL
AnimFrame_0160 := ANIM_FRAME_NULL
AnimFrame_0161 := ANIM_FRAME_NULL
AnimFrame_0162 := ANIM_FRAME_NULL

.endif

; ------------------------------------------------------------------------------

.segment "btlgfx_data2"

_13f900:
@f900:  .byte   $01,$04,$02,$01,$04,$02,$01,$04,$02

; pointers to sprite data for megaflare animation
MegaflareSpritePtrs:
@f909:  make_ptr_tbl_abs MegaflareSprite, 8

; sprite data for megaflare animation
MegaflareSprite_0000:
        .byte   $10,$10,$84,$3f,$ff

MegaflareSprite_0001:
        .byte   $10,$10,$82,$3f,$ff

MegaflareSprite_0002:
        .byte   $08,$08,$ca,$3f,$18,$08,$ca,$7f,$08,$18,$ca,$bf,$18,$18,$ca,$ff
        .byte   $ff

MegaflareSprite_0003:
        .byte   $00,$00,$8c,$3f,$10,$00,$8e,$3f,$20,$00,$8c,$7f,$00,$10,$ac,$3f
        .byte   $10,$10,$ae,$3f,$20,$10,$ac,$7f,$00,$20,$8c,$bf,$10,$20,$8e,$bf
        .byte   $20,$20,$8c,$ff,$ff

MegaflareSprite_0004:
        .byte   $08,$08,$c0,$3f,$18,$08,$c2,$3f,$08,$18,$a8,$3f,$18,$18,$aa,$3f
        .byte   $ff

MegaflareSprite_0005:
        .byte   $08,$08,$c2,$7f,$18,$08,$c0,$7f,$08,$18,$aa,$7f,$18,$18,$a8,$7f
        .byte   $ff

MegaflareSprite_0006:
        .byte   $08,$08,$aa,$ff,$18,$08,$a8,$ff,$08,$18,$c2,$ff,$18,$18,$c0,$ff
        .byte   $ff

MegaflareSprite_0007:
        .byte   $08,$08,$a8,$bf,$18,$08,$aa,$bf,$08,$18,$c0,$bf,$18,$18,$c2,$bf
        .byte   $ff

; monster death hdma data
MonsterDeathHDMATbl:
@f99d:  .word   $0101,$0202,$0404,$0808,$1010,$2120,$4240,$8480
        .word   $0801,$1002,$2104,$4208,$8410,$0821,$1142,$2284
        .word   $4408,$8910,$1221,$2542,$4a84,$9508,$2b11,$5622
        .word   $ad44,$5b89,$b712,$6f25,$de4a,$bd95,$7b2b,$f756
        .word   $efad,$df5b,$beb7,$7d6f,$fbde,$f7bd,$ef7b,$dff7
        .word   $bfef,$7fdf,$ffbe,$fe7d,$fdfb,$fbf7,$f7ef,$efdf
        .word   $dfbf,$bf7f,$7fff,$fffe,$fffd,$fffb,$fff7,$ffef
        .word   $ffdf,$ffbf,$ff7f,$ffff,$ffff,$ffff,$ffff,$ffff
        .word   $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff
        .word   $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff
        .word   $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff
        .word   $ffff,$ffff,$ffff,$ffff,$ffff,$ffff

; summon sprite position data (17 * 4 bytes)
;   $00: x position
;   $01: y position
;   $02: width (in 16x16 tiles)
;   $03: height

SummonSpritePosTbl:
@fa59:  .byte   $c8,$44,$02,$02
        .byte   $c8,$44,$02,$02
        .byte   $c0,$44,$03,$02
        .byte   $c0,$3c,$03,$03
        .byte   $c8,$44,$02,$02
        .byte   $c0,$3c,$03,$03
        .byte   $c0,$3c,$03,$03
        .byte   $b8,$3c,$04,$03
        .byte   $c0,$30,$03,$04
        .byte   $b0,$3c,$05,$04
        .byte   $d0,$2a,$01,$05
        .byte   $b8,$2c,$04,$05
        .byte   $b8,$2c,$03,$05
        .byte   $b8,$2c,$04,$05
        .byte   $b8,$2c,$04,$05
        .byte   $b8,$2c,$04,$05
        .byte   $a8,$30,$05,$04

_13fa9d:
@fa9d:  .byte   $00,$00,$00,$00
        .byte   $01,$01,$01,$01
        .byte   $02,$02,$02,$02
        .byte   $03,$03,$03,$03
        .byte   $04,$05,$04,$05
        .byte   $06,$07,$06,$07
        .byte   $08,$09,$08,$09
        .byte   $0a,$0b,$0a,$0b
        .byte   $0c,$0d,$0c,$0d
        .byte   $0e,$0f,$0e,$0f
        .byte   $10,$11,$12,$12
        .byte   $13,$14,$15,$15
        .byte   $16,$17,$16,$17
        .byte   $18,$19,$1a,$18
        .byte   $19,$1a,$18,$19
        .byte   $1a,$18,$19,$1a
        .byte   $1b,$1c,$1b,$1c

; character status sprite data
; 2 frames per status, 2 sprites per frame, 4 bytes per sprite
StatusSpriteTbl:
@fae1:  .byte   $00,$00,$ff,$01,$00,$00,$ff,$01,$00,$00,$ff,$01,$00,$00,$ff,$01
        .byte   $08,$f8,$60,$3d,$10,$f8,$61,$3d,$00,$00,$ff,$01,$00,$00,$ff,$01
        .byte   $10,$00,$62,$3d,$18,$00,$63,$3d,$10,$00,$64,$3d,$18,$00,$65,$3d
        .byte   $10,$f8,$6c,$3d,$18,$f8,$6c,$7d,$10,$f8,$6d,$3d,$18,$f8,$6d,$7d
        .byte   $08,$00,$66,$3d,$08,$08,$67,$3d,$20,$00,$66,$7d,$20,$08,$67,$7d
        .byte   $10,$08,$68,$3d,$10,$08,$68,$3d,$10,$08,$69,$3d,$10,$08,$69,$3d
        .byte   $10,$10,$7c,$3d,$18,$10,$7c,$7d,$10,$10,$7c,$3d,$18,$10,$7c,$7d
        .byte   $10,$f0,$6a,$3d,$18,$f0,$6b,$3d,$10,$f0,$6b,$fd,$18,$f0,$6a,$fd
        .byte   $18,$f8,$6e,$3d,$20,$f8,$6f,$3d,$18,$f8,$6f,$7d,$20,$f8,$6e,$7d
        .byte   $10,$f8,$00,$3d,$18,$f8,$00,$3d,$10,$f8,$00,$3d,$18,$f8,$00,$3d

; character animated pose table
CharAnimPoseTbl:
@fb81:  .byte   $1e,$1e,$1e,$1e  ; normal spritesheet ($00)
        .byte   $00,$00,$00,$00
        .byte   $01,$01,$01,$01
        .byte   $00,$02,$00,$02
        .byte   $03,$03,$03,$03
        .byte   $04,$04,$02,$02
        .byte   $06,$06,$05,$05
        .byte   $07,$07,$07,$07
        .byte   $00,$08,$00,$08
        .byte   $09,$09,$09,$09
        .byte   $0a,$0b,$0a,$0b
        .byte   $0a,$0a,$0a,$0a
        .byte   $08,$08,$08,$08
        .byte   $04,$04,$04,$04
        .byte   $24,$24,$24,$24
        .byte   $24,$24,$24,$24

        .byte   $00,$00,$00,$00  ; mini spritesheet ($10)
        .byte   $0c,$0c,$0c,$0c
        .byte   $0d,$0d,$0d,$0d
        .byte   $0e,$0c,$0e,$0c
        .byte   $0f,$0f,$0f,$0f
        .byte   $10,$10,$0e,$0e
        .byte   $10,$10,$0e,$0e
        .byte   $11,$11,$11,$11
        .byte   $0c,$12,$0c,$12
        .byte   $13,$13,$13,$13
        .byte   $14,$15,$14,$15
        .byte   $14,$14,$14,$14
        .byte   $0c,$0c,$0c,$0c
        .byte   $10,$10,$10,$10
        .byte   $0c,$0c,$0c,$0c
        .byte   $0c,$0c,$0c,$0c

        .byte   $00,$00,$00,$00  ; toad spritesheet ($20)
        .byte   $16,$16,$16,$16
        .byte   $17,$17,$17,$17
        .byte   $16,$18,$16,$18
        .byte   $19,$19,$19,$19
        .byte   $1a,$1a,$18,$18
        .byte   $1a,$1a,$18,$18
        .byte   $1b,$1b,$1b,$1b
        .byte   $16,$1c,$16,$1c
        .byte   $1d,$1d,$1d,$1d
        .byte   $16,$16,$16,$16
        .byte   $16,$16,$16,$16
        .byte   $16,$16,$16,$16
        .byte   $1a,$1a,$1a,$1a
        .byte   $16,$16,$16,$16
        .byte   $16,$16,$16,$16

        .byte   $00,$00,$00,$00  ; golbez/anna spritesheet ($30)
        .byte   $00,$00,$00,$00
        .byte   $00,$00,$00,$00
        .byte   $00,$1f,$00,$1f
        .byte   $00,$00,$00,$00
        .byte   $00,$00,$00,$00
        .byte   $00,$00,$00,$00
        .byte   $1f,$1f,$1f,$1f
        .byte   $00,$22,$00,$22
        .byte   $23,$23,$23,$23
        .byte   $20,$21,$20,$21
        .byte   $20,$20,$20,$20
        .byte   $22,$22,$22,$22
        .byte   $00,$00,$00,$00
        .byte   $00,$00,$00,$00
        .byte   $00,$00,$00,$00

        .byte   $00,$00,$00,$00  ; pig spritesheet ($40)
        .byte   $00,$00,$00,$00
        .byte   $01,$01,$01,$01
        .byte   $00,$02,$00,$02
        .byte   $03,$03,$03,$03
        .byte   $04,$04,$02,$02
        .byte   $06,$06,$05,$05
        .byte   $07,$07,$07,$07
        .byte   $00,$08,$00,$08
        .byte   $09,$09,$09,$09
        .byte   $01,$01,$01,$01
        .byte   $00,$08,$00,$08
        .byte   $08,$08,$08,$08
        .byte   $04,$04,$04,$04
        .byte   $08,$08,$08,$08
        .byte   $08,$08,$08,$08
        .byte   $08,$08,$08,$08

; h-scroll values for shaking monster frame transition
ShakeMonsterTbl:
@fcc5:  .word   $fffe,$ffff,$fffe,$fffd,$ffff,$0000,$fffe,$fffd

; ------------------------------------------------------------------------------

.segment "btlgfx_data3"

.export DakutenTbl

; 16/ed80
        .include "gfx/battle_bg_top_tiles.asm"

; 16/f880
        .include "gfx/battle_bg_btm_tiles.asm"

; dakuten table (battle)
; 2 bytes each, dakuten then kana
DakutenTbl:
@fa40:  .byte                                                           $c0,$cc
        .byte   $c0,$8f,$c0,$90,$c0,$91,$c0,$92,$c0,$93,$c0,$94,$c0,$95,$c0,$96
        .byte   $c0,$97,$c0,$98,$c0,$99,$c0,$9a,$c0,$9b,$c0,$9c,$c0,$9d,$c0,$a3
        .byte   $c0,$a4,$c0,$a5,$c0,$a6,$c0,$a7,$c1,$a3,$c1,$a4,$c1,$a5,$c1,$a6
        .byte   $c1,$a7,$c0,$cf,$c0,$d0,$c0,$d1,$c0,$d2,$c0,$d3,$c0,$d4,$c0,$d5
        .byte   $c0,$d6,$c0,$d7,$c0,$d8,$c0,$d9,$c0,$da,$c0,$db,$c0,$dc,$c0,$dd
        .byte   $c0,$e3,$c0,$e4,$c0,$e5,$c0,$e6,$c0,$e7,$c1,$e3,$c1,$e4,$c1,$e5
        .byte   $c1,$e6,$c1,$e7

_16faa6:
@faa6:  .byte   $00,$09,$12,$1b,$24,$2d,$36,$3f,$48

_16faaf:
@faaf:  .byte   $00,$01,$01,$01,$01,$02,$02,$02,$02
        .byte   $00,$00,$00,$00,$01,$01,$01,$01,$02
        .byte   $00,$00,$00,$00,$01,$02,$02,$02,$02
        .byte   $01,$02,$02,$02,$02,$00,$00,$00,$00
        .byte   $01,$01,$01,$01,$02,$02,$02,$02,$00
        .byte   $01,$01,$01,$01,$02,$00,$00,$00,$00
        .byte   $02,$00,$00,$00,$00,$01,$01,$01,$01
        .byte   $02,$02,$02,$02,$00,$00,$00,$00,$01
        .byte   $02,$02,$02,$02,$00,$01,$01,$01,$01

_16fb00:
@fb00:  .byte   $00,$12,$24,$00,$12,$24,$00,$12,$24

_16fb09:
@fb09:  .byte   $08,$08,$f0,$00,$f0,$00,$00,$00,$00,$00,$e0,$f0,$10,$e0,$f0,$f0,$f0,$f0
        .byte   $00,$00,$00,$00,$e0,$10,$10,$00,$f0,$f0,$f0,$f0,$00,$f0,$00,$f0,$e8,$e8
        .byte   $00,$00,$00,$00,$e0,$10,$10,$00,$f8,$f8,$e0,$f0,$10,$e0,$f0,$f0,$f0,$f0

; name for each character (see 01/8457 for menu)
CharNameTbl:
@fb3f:  .byte   $00,$01,$02,$03,$04,$05,$06,$07,$08,$03,$00,$03,$06,$09,$01,$05
        .byte   $02,$0a,$0b,$01,$0c,$0d,$0e,$0f

; weapon frame data tile offset
WeaponTileOffsetTbl:
@fb57:  .byte   $98,$98,$98,$a6,$b0,$ba,$c4,$d0,$64,$68,$6c,$70,$74,$78,$7c,$80
        .byte   $84,$88,$8c,$90,$94,$0c

; weapon graphics offset
WeaponGfxOffset:
@fb6d:  .byte   $00,$04,$08,$0c,$10,$14,$18,$1c,$20,$24,$28,$2c,$30,$34,$38,$3c
        .byte   $40,$44,$48,$4c,$50,$54,$58,$5c,$60,$64

; menu tiles used in bg2 battle menu
;       $DB: little "m"
;       $DC: little "p"
;       $DD: ／
;   $DE-$E1: しょうひ (consumed)
;       $E2: Ｍ
;       $E3: Ｐ
;   $E4-$E7: チェンシ (change row)
;       $E8: (dakuten)
;   $E9-$EC: ほうきょ (defend)
;       $ED: ０
;       $EE: １
;       $EF: ２
;       $F0: ３
;       $F1: ４
;       $F2: ５
;       $F3: ６
;       $F4: ７
;       $F5: ８
;       $F6: ９
;       $F7: top-left border
;       $F8: top-center border
;       $F9: top-right border
;       $FA: mid-left border
;       $FB: mid-right border
;       $FC: bottom-left border
;       $FD: bottom-center border
;       $FE: bottom-right border
;       $FF: blank

BG2MenuTiles:
.if LANG_EN
@fb87:  .byte                                               $76,$78,$c7,$4f,$60
        .byte   $60,$5f,$4e,$51,$51,$5c,$6d,$74,$44,$63,$69,$62,$60,$80,$81,$82
        .byte   $83,$84,$85,$86,$87,$88,$89,$16,$17,$18,$fa,$fb,$fc,$fd,$fe,$ff
.else
@fb87:  .byte                                               $76,$78,$c7,$95,$7f
        .byte   $8c,$a4,$4e,$51,$da,$ba,$f6,$d5,$c0,$a7,$8c,$90,$7f,$80,$81,$82
        .byte   $83,$84,$85,$86,$87,$88,$89,$16,$17,$18,$fa,$fb,$fc,$fd,$fe,$ff
.endif

; number of tiles for boss graphics
BossTileCountTbl:
@fbac:  .word   $00ff,$0000,$0000,$0000
        .word   $00ff,$00ff,$0000,$0000
        .word   $007f,$007f,$007f,$007f
        .word   $00ff,$007f,$007f,$0000
        .word   $007f,$007f,$00ff,$0000
        .word   $007f,$00ff,$007f,$0000

; monster graphics vram locations for each mold
MonsterVRAMPtrs:
@fbdc:  .word   $2000,$0000,$0000,$0000
        .word   $2000,$3000,$0000,$0000
        .word   $2000,$2800,$3000,$3800
        .word   $2000,$3000,$3800,$0000
        .word   $2000,$2800,$3000,$0000
        .word   $2000,$2800,$3800,$0000

; monster palette, msb for tilemap
MonsterTileFlags:
@fc0c:  .byte   $2c,$20,$20,$20
        .byte   $2c,$31,$20,$20
        .byte   $2c,$30,$35,$39
        .byte   $2c,$31,$35,$20
        .byte   $2c,$30,$35,$20
        .byte   $2c,$30,$35,$20

; monster lo byte of tilemap
MonsterTileLoByteTbl:
@fc24:  .byte   $00,$00,$00,$00
        .byte   $00,$00,$00,$00
        .byte   $00,$80,$00,$80
        .byte   $00,$00,$80,$00
        .byte   $00,$80,$00,$00
        .byte   $00,$80,$80,$00

; menu list arrow sprite data
ListArrowTbl:
@fc3c:  .byte   $ec,$90,$4f,$b1
        .byte   $ec,$98,$4e,$b1
        .byte   $ec,$cc,$4e,$31
        .byte   $ec,$d4,$4f,$31

_16fc4c:
@fc4c:  .byte   0,1,2,3,4

; command list cursor y positions
CmdCursorYTbl:
@fc51:  .byte   $98,$a4,$b0,$bc,$c8

; spell list cursor x positions
MagicListCursorXTbl:
@fc56:  .byte   $04,$3c,$74

; inventory cursor x positions
InventoryCursorXTbl:
@fc59:  .byte   $0c,$7c

; spell list/inventory cursor y positions
ListCursorYTbl:
@fc5b:  .byte   $9c,$a8,$b4,$c0,$cc

; ready pose for each command
CmdReadyPoseTbl:
@fc60:  .byte   $02,$02,$0a,$0a,$0a,$0b,$02,$02,$02,$02,$02,$0b,$02,$0b,$02,$02
        .byte   $00,$02,$02,$02,$0b,$02,$02,$02,$0a,$0b,$08,$02,$01,$02

; bit masks
BitOrTbl:
@fc7e:  .byte   $80,$40,$20,$10,$08,$04,$02,$01

; pointers to golbez/anna graphics
ExtraCharGfxPtrs:
@fc86:  .word   BattleCharGfx_000f - BattleCharGfx
        .word   BattleCharGfx_0010 - BattleCharGfx

; damage numeral y-offsets (for bouncing)
DmgNumeralBounceTbl:
@fc8a:  .byte   $00,$00,$00,$00,$00,$fd,$fa,$f7,$f4,$f2,$f1,$f1,$f0,$f0,$f0,$f1
        .byte   $f1,$f2,$f4,$f7,$fa,$fd,$00,$fe,$fc,$fc,$fb,$fb,$fb,$fc,$fc,$fe
        .byte   $ff,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00

; animation sprite tile id
_16fccb:
@fccb:  .byte   $80,$82,$84,$86,$88,$8a,$8c,$8e
        .byte   $a0,$a2,$a4,$a6,$a8,$aa,$ac,$ae
        .byte   $c0,$c2,$c4,$c6,$c8,$ca,$cc,$ce
        .byte   $e0,$e2,$e4,$e6,$e8,$ea,$ec,$ee

; graphics id for pre-magic animation
PreMagicGfxTbl:
@fceb:  .byte   $11,$03,$0f

; movement duration for stepping forward/back
CharStepDurTbl:
@fcee:  .byte   $10,$10,$10,$18,$18
        .byte   $18,$18,$18,$10,$10

; movement duration for character entry
CharEntryDurTbl:
@fcf8:  .byte   $10,$10,$10,$08,$08
        .byte   $08,$08,$08,$10,$10

; image status sprite x offsets
CharImageXTbl:
@fd02:  .byte   $00,$08,$00,$10

; character sprite tile offsets
CharSpriteTileOffsetTbl:
@fd06:  .word   $0000,$0040,$0080,$00c0,$0100

; first sprite to use for left-handed attack (char below weapon)
FirstCharSpriteBelowTbl:
@fd10:  .byte   $6a,$7a,$5a,$72,$62

; first sprite to use for right-handed attack (char above weapon)
; or first sprite to use for status sprites
FirstCharSpriteAboveTbl:
@fd15:  .byte   $68,$78,$58,$70,$60

; character sprite default y positions
CharSpriteDefaultYTbl:
@fd1a:  .byte   $4c,$24,$74,$38,$60

; character sprite default x positions
CharSpriteDefaultXTbl:
@fd1f:  .byte   $d0,$d0,$d0,$e0,$e0
        .byte   $e0,$e0,$e0,$d0,$d0

; partial petrify mask for setting palette id to zero
PartialPetrifyPalMask:
@fd29:  .byte   $ff,$ff,$ff,$00
        .byte   $ff,$ff,$00,$00
        .byte   $ff,$00,$00,$00
        .byte   $00,$00,$00,$00

; weapon sprite y-offset for throw ???
_16fd39:
@fd39:  .byte   $01,$ff,$01,$ff
        .byte   $01,$ff,$01,$ff
        .byte   $01,$ff,$01,$ff
        .byte   $01,$ff,$01,$ff

; ぜんぶ (all)
TargetAllText:
@fd49:  .byte   $18,$b6,$21,$00

; ミス (miss) *** unused ***
MissText:
@fd4c:  .byte   $e9,$d6,$00

_16fd50:
@fd50:  .byte   $80,$00,$00,$3f
        .byte   $82,$00,$00,$bf

; weapon sprite data
;   $00: tile id
;   $01: x offset
;   $02: y offset
;   $03: tile flags

WeaponSpriteTbl:
@fd58:  .byte   $80,$10,$f8,$7f  ; arm back
        .byte   $80,$f0,$00,$3f  ; arm forward
        .byte   $80,$f0,$f8,$3f  ; arm back (charmed)
        .byte   $80,$10,$00,$7f  ; arm forward (charmed)

_16fd68:
@fd68:  .byte   $80,$80,$82,$82

; throw tile flags ???
_16fd6c:
@fd6c:  .byte   $3f,$7f,$7f,$3f

; boomerang tile flags ???
_16fd70:
@fd70:  .byte   $3f,$3f,$3f,$3f

; battle messages that wait for keypress
WaitMsgKeypressTbl:
@FD74:  .byte   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
        .byte   1,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0
        .byte   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

; pointers to battle bg graphics (+$1C0000)
BattleBGGfxPtrs:
@fdb4:  make_ptr_tbl_rel BattleBGGfx, 17, .bankbyte(BattleBGGfx)<<16

; menu tilemap vram transfer data (init)
;  +$00 source
;  +$02 destination (vram)
;  +$04 size
MenuInitVRAMTfrTbl:
@fdd6:  .word   $be66,$7000,$0340       ; 0: main window (13 rows)
        .word   $c1a6,$71a0,$0340       ; 1: battle command window (13 rows)
        .word   $c4e6,$7400,$0400       ; 2: inventory 1 (16 rows)
        .word   $c8e6,$7600,$0400       ; 3: inventory 2 (16 rows)
        .word   $cce6,$7c00,$04c0       ; 4: inventory 3 (19 rows)
        .word   $d1a6,$7800,$01c0       ; 5: equipped items (7 rows)
        .word   $d366,$5e60,$0340       ; 6: mp cost, row, defend (bg2, 13 rows)
        .word   $d6a6,$7980,$0340       ; 7: status window (13 rows)
        .word   $dbe6,$7e80,$0100       ; 8: pause window (4 rows)

; menu tilemap vram transfer data (update)
;  +$00 source
;  +$02 destination (vram)
;  +$04 size
MenuUpdateVRAMTfrTbl:
@fe0c:  .word   $bea6,$7020,$0280       ; 0: main window (10 rows)
        .word   $c1e6,$71c0,$0280       ; 1: battle command window (10 rows)
        .word   $c526,$7420,$0400       ; 2: spell list (16 rows)
        .word   $c4e6,$7400,$0400       ; 3: inventory 1 (16 rows)
        .word   $c8e6,$7600,$0400       ; 4: inventory 2 (16 rows)
        .word   $cce6,$7c00,$0440       ; 5: inventory 3 (17 rows)
        .word   $d366,$5e60,$0140       ; 6: mp cost (bg2, 5 rows)
        .word   $d1a6,$7800,$01c0       ; 7: equipped items (7 rows)
        .word   $d6e6,$79a0,$0280       ; 8: status window (10 rows)

; main menu text update data
;   $00: width
;   $01: height
;  +$02: text buffer
;  +$04: tilemap buffer
MenuTextUpdateTbl:
@fe42:  .byte   $14,$08                 ; 0: monster names
        .addr   $bb1e,$beaa
        .byte   $0c,$0a                 ; 1: character names
        .addr   $b966,$bec2
        .byte   $12,$0a                 ; 2: character hp
        .addr   $b9de,$bed0
        .byte   $0a,$0a                 ; 3: battle commands
        .addr   $8cb2,$c1f4

; menu window data -> $EF56 (13 * 6 bytes)
;   $00: x position
;   $01: y position
;   $02: width
;   $03: height

.if LANG_EN
.define DEF_WINDOW $00,$09,$08,$04
.define ROW_WINDOW $18,$09,$08,$04
.else
.define DEF_WINDOW $00,$09,$06,$04
.define ROW_WINDOW $1a,$09,$06,$04
.endif

MenuWindowTbl:
@fe5a:  .byte   $01,$00,$0c,$0d         ; 0: monster names
        .addr   $c1a6
        .byte   $0d,$00,$12,$0d         ; 1: character names and hp
        .addr   $c1a6
        .byte   $06,$00,$07,$0d         ; 2: battle commands
        .addr   $c1a6
        .byte   $01,$00,$0c,$0d         ; 3: monster names
        .addr   $be66
        .byte   $0d,$00,$12,$0d         ; 4: character names and hp
        .addr   $be66
        .byte   $01,$00,$1e,$33         ; 5: inventory
        .addr   $c4e6
        .byte   $01,$00,$1e,$07         ; 6: equipped items
        .addr   $d1a6
        .byte   $16,$00,$09,$08         ; 7: mp cost
        .addr   $d366
        .byte   DEF_WINDOW              ; 8: defend
        .addr   $d366
        .byte   ROW_WINDOW              ; 9: row
        .addr   $d366
        .byte   $01,$00,$13,$0d         ; a: character names and hp
        .addr   $d6a6
        .byte   $14,$00,$0b,$0d         ; b: status
        .addr   $d6a6
        .byte   $0c,$00,$09,$03         ; c: pause
        .addr   $dbe6

; pause window text
PauseText:
@fea8:  .byte   $51,$42,$56,$54,$46     ; "PAUSE"

; pointers to battle command text buffers
CmdTextBufPtrs:
@fead:  .addr   $8cb2,$8d16,$8d7a,$8dde,$8e42

; pointers to battle command data
CmdDataPtrs:
@feb7:  .addr   $3302,$331e,$333a,$3356,$3372

; pointers to equipped item text buffer
EquipTextBufPtrs:
@fec1:  .addr   $bc86,$bce6,$bd46,$bda6,$be06

; pointers to equipped item data
EquipDataPtrs:
@fecb:  .addr   $32da,$32e2,$32ea,$32f2,$32fa

; right/left hand text (4 * 20 bytes)

; 0: no main hand
; 1: left handed
; 2: right handed
; 3: ambidextrous

.if !LANG_EN
RLHandText:
@fed5:  .byte   $ff,$c0,$ff,$c0,$ff,$a9,$90,$8c,$9c,$ff  ; みぎうで (right hand)
        .byte   $ff,$c0,$ff,$ff,$c0,$a4,$99,$b1,$8c,$9c  ; ひだりうで (left hand)
        .byte   $ff,$c0,$ff,$c0,$ff,$a9,$90,$8c,$9c,$ff  ; みぎうで (right hand)
        .byte   $ff,$ff,$ff,$c0,$ff,$90,$90,$8c,$9c,$ff  ; ききうで (main hand)
        .byte   $ff,$ff,$ff,$c0,$ff,$90,$90,$8c,$9c,$ff  ; ききうで (main hand)
        .byte   $ff,$c0,$ff,$ff,$c0,$a4,$99,$b1,$8c,$9c  ; ひだりうで (left hand)
        .byte   $ff,$ff,$ff,$c0,$ff,$90,$90,$8c,$9c,$ff  ; ききうで (main hand)
        .byte   $ff,$ff,$ff,$c0,$ff,$90,$90,$8c,$9c,$ff  ; ききうで (main hand)
.endif

; pointers to right/left hand text buffers
RLHandTextBufPtrs:
@ff25:  .addr   $bbbe,$bbe6,$bc0e,$bc36,$bc5e

; pointers to spell list text buffers
MagicListTextPtrs:
@ff2f:  .addr   $97a6,$9e66,$a526,$abe6,$b2a6

; pointers to spell lists
MagicListPtrs:
@ff39:  .addr   $2c7a,$2d9a,$2eba,$2fda,$30fa

.if LANG_EN
RLHandText:
@fef3:  .byte   $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
        .byte   $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
        .byte   $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
        .byte   $ff,$ff,$ff,$ff,$ff,$4d,$49,$5c,$69,$5f
        .byte   $ff,$ff,$ff,$ff,$ff,$53,$49,$5c,$69,$5f
        .byte   $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
        .byte   $ff,$ff,$ff,$ff,$ff,$53,$49,$5c,$69,$5f
        .byte   $ff,$ff,$ff,$ff,$ff,$4d,$49,$5c,$69,$5f
.endif

; battle menu text buffer data
MenuTextBufTbl:
@ff43:  .addr   $74fd,$bb1e             ; monster names
        .byte   $0a,$00
        .addr   $74fd,$b966             ; character names
        .byte   $06,$00
        .addr   $74fd,$b9de             ; character hp
        .byte   $09,$00
        .addr   $74fd,$ba92             ; character mp
        .byte   $07,$02

; pointers to battle menu text
MenuTextPtrs:
@ff5b:  .addr   MenuText_0000
        .addr   MenuText_0001
        .addr   MenuText_0002
        .addr   MenuText_0003

; battle menu text

; 0: monster names and counts
MenuText_0000:
@ff63:  .byte   $0c,$00,$ff,$0d,$00,$01
        .byte   $0c,$01,$ff,$0d,$01,$01
        .byte   $0c,$02,$ff,$0d,$02,$01
        .byte   $0c,$03,$ff,$0d,$03,$01

; 1: character names
MenuText_0001:
@ff7b:  .byte   $02,$01,$01
        .byte   $02,$03,$01
        .byte   $02,$00,$01
        .byte   $02,$04,$01
        .byte   $02,$02,$01

; 2: character current/max hp
MenuText_0002:
@ff8a:  .byte   $08,$01,$c7,$08,$02,$01
        .byte   $0a,$01,$c7,$0a,$02,$01
        .byte   $07,$01,$c7,$07,$02,$01
        .byte   $0b,$01,$c7,$0b,$02,$01
        .byte   $09,$01,$c7,$09,$02,$01

; 3: character current/max mp
MenuText_0003:
@ffa8:  .byte   $07,$03,$dd,$07,$04,$01
        .byte   $08,$03,$dd,$08,$04,$01
        .byte   $09,$03,$dd,$09,$04,$01
        .byte   $0a,$03,$dd,$0a,$04,$01
        .byte   $0b,$03,$dd,$0b,$04,$00

; animation palette swap data (16 * 2 bytes)
PalSwapTbl:
@ffc6:  .byte   $00,$00
        .byte   $09,$08
        .byte   $08,$0a
        .byte   $08,$0b
        .byte   $09,$0b
        .byte   $0a,$0b
        .byte   $0f,$08
        .byte   $0c,$0c
        .byte   $0c,$0a
        .byte   $13,$13
        .byte   $08,$08
        .byte   $08,$16
        .byte   $05,$06
        .byte   $05,$0e
        .byte   $08,$14
        .byte   $09,$12

; tile id and sprite flags for firaga animation
FiragaAnimTilesTbl:
@ffe6:  .word   $3fe8,$3fe6,$bfe6,$bfe6

; initial vertical radius for firaga animation
FiragaYRadiusTbl:
@ffee:  .byte   $30,$18,$20,$28

; initial horizontal radius for firaga animation
FiragaXRadiusTbl:
@fff2:  .byte   $0c,$02,$10,$08

_16fff6:
@fff6:  .word   $0000,$0018,$0010,$0000

; ------------------------------------------------------------------------------

.segment "battle_char_gfx"

; 1a/8000
        .include "gfx/battle_char_gfx.asm"

; ------------------------------------------------------------------------------

.segment "battle_bg_gfx"

; 1c/a800
        .include "gfx/battle_bg_gfx.asm"

; unused partial tile at the end of this block of graphics
.if BYTE_PERFECT
        .byte   $ff,$00,$81,$00,$81,$00,$99,$00,$99,$00,$81,$00,$81,$00,$ff,$00
.endif

.segment "weapon_gfx"

; 1c/d900
        .include "gfx/weapon_gfx.asm"

; ------------------------------------------------------------------------------

.segment "monster_pal"

; 1c/ee00
        .include "gfx/monster_pal.asm"

; ------------------------------------------------------------------------------

.segment "battle_char_pal"

; 1c/fd00
        .include "gfx/battle_char_pal.asm"

; 1c/ff00
        .include "data/anim_sine.asm"

; ------------------------------------------------------------------------------
