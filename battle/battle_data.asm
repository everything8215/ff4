
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: battle_data.asm                                                      |
; |                                                                            |
; | description: data for battle module                                        |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

; ------------------------------------------------------------------------------

.import RNGTbl
.import ItemClasses, ElementStatus

.export EquipProp, BattleProp, MonsterName, SpellListInit

; ------------------------------------------------------------------------------

.segment "attack_prop"

; 0f/9070
        .include "data/weapon_magic_hits.asm"
        .res $90+WeaponMagicHits-*

; 0f/9100
        .include .sprintf("data/equip_prop_%s.asm", LANG_SUFFIX)

; 0f/9680
        .include "data/item_prop.asm"

; 0f/97a0
        .include .sprintf("data/attack_prop_%s.asm", LANG_SUFFIX)
        .res $0670+AttackProp-*

; ------------------------------------------------------------------------------

.segment "level_up"

.define DK_KNIGHT_INIT_LVL 10
.define KAIN_INIT_LVL 10
.define RYDIA_INIT_LVL 1
.define TELLAH_INIT_LVL 20
.define EDWARD_INIT_LVL 5
.define ROSA_INIT_LVL 10
.define YANG_INIT_LVL 10
.define PALOM_INIT_LVL 10
.define POROM_INIT_LVL 10
.define PALADIN_INIT_LVL 1
.define CID_INIT_LVL 20
.define EDGE_INIT_LVL 25
.define FUSOYA_INIT_LVL 50

; 0f/b500
LevelUpPropPtrs:
        .word   .loword(LevelUpProp_0000)-(DK_KNIGHT_INIT_LVL-1)*5
        .word   .loword(LevelUpProp_0001)-(KAIN_INIT_LVL-1)*5
        .word   .loword(LevelUpProp_0002)-(RYDIA_INIT_LVL-1)*5
        .word   .loword(LevelUpProp_0003)-(TELLAH_INIT_LVL-1)*5
        .word   .loword(LevelUpProp_0004)-(EDWARD_INIT_LVL-1)*5
        .word   .loword(LevelUpProp_0005)-(ROSA_INIT_LVL-1)*5
        .word   .loword(LevelUpProp_0006)-(YANG_INIT_LVL-1)*5
        .word   .loword(LevelUpProp_0007)-(PALOM_INIT_LVL-1)*5
        .word   .loword(LevelUpProp_0008)-(POROM_INIT_LVL-1)*5
        .word   .loword(LevelUpProp_0003)-(TELLAH_INIT_LVL-1)*5
        .word   .loword(LevelUpProp_0009)-(PALADIN_INIT_LVL-1)*5
        .word   .loword(LevelUpProp_0003)-(TELLAH_INIT_LVL-1)*5
        .word   .loword(LevelUpProp_0006)-(YANG_INIT_LVL-1)*5
        .word   .loword(LevelUpProp_000a)-(CID_INIT_LVL-1)*5
        .word   .loword(LevelUpProp_0001)-(KAIN_INIT_LVL-1)*5
        .word   .loword(LevelUpProp_0005)-(ROSA_INIT_LVL-1)*5
        .word   .loword(LevelUpProp_0002)-(RYDIA_INIT_LVL-1)*5
        .word   .loword(LevelUpProp_000b)-(EDGE_INIT_LVL-1)*5
        .word   .loword(LevelUpProp_000c)-(FUSOYA_INIT_LVL-1)*5
        .word   .loword(LevelUpProp_0001)-(KAIN_INIT_LVL-1)*5

; 0f/b528
        .include "data/level_up_prop.asm"

; ------------------------------------------------------------------------------

.segment "spell_list"

; 0f/c700
        .include .sprintf("data/spell_list_learned_%s.asm", LANG_SUFFIX)
        .res $01c0+SpellListLearned-*

; 0f/c8c0
        .include .sprintf("data/spell_list_init_%s.asm", LANG_SUFFIX)

; ------------------------------------------------------------------------------

.segment "battle_data"

; battles with no party update
NoUpdateBattleTbl:
@fd00:  .word   $00eb,$00f5,$00f0,$00f6,$00fa,$01a9,$00fe,$00f3
        .word   $01b3,$01b4,$01b7,$01b8
        .byte   $ff

; ------------------------------------------------------------------------------

; status 1 and 2 that disable each command (30 * 2 bytes)
DisableCmdStatusTbl:
@fd19:  .byte   $00,$00  ; $00: fight
        .byte   $00,$00  ; $01: item
        .byte   $2c,$00  ; $02: white magic          toad, pig, mute
        .byte   $04,$00  ; $03: black magic          mute
        .byte   $2c,$00  ; $04: summon               toad, pig, mute
        .byte   $38,$00  ; $05: dark wave            toad, mini, pig
        .byte   $30,$00  ; $06: jump 1               toad, mini
        .byte   $2c,$00  ; $07: recall               toad, pig, mute
        .byte   $04,$00  ; $08: sing                 mute
        .byte   $00,$00  ; $09: hide
        .byte   $00,$00  ; $0a: salve
        .byte   $00,$00  ; $0b: pray
        .byte   $38,$00  ; $0c: aim                  toad, mini, pig
        .byte   $39,$00  ; $0d: focus 1              toad, mini, poison
        .byte   $38,$40  ; $0e: kick                 toad, mini, pig, float
        .byte   $38,$00  ; $0f: brace                toad, mini, pig
        .byte   $3c,$00  ; $10: twin 1               toad, mini, pig, mute
        .byte   $38,$00  ; $11: bluff                toad, mini, pig
        .byte   $38,$00  ; $12: cry                  toad, mini, pig
        .byte   $30,$00  ; $13: cover                toad, mini
        .byte   $38,$00  ; $14: search (peep)        toad, mini, pig
        .byte   $38,$00  ; $15: airship ???          toad, mini, pig
        .byte   $30,$00  ; $16: throw (dart)         toad, mini
        .byte   $20,$00  ; $17: steal (sneak)        toad
        .byte   $2c,$00  ; $18: ninjutsu             toad, pig, mute
        .byte   $38,$00  ; $19: regen                toad, mini, pig
        .byte   $00,$00  ; $1a: change row
        .byte   $00,$00  ; $1b: defend
        .byte   $00,$00  ; $1c: appear (show)
        .byte   $00,$00  ; $1d: don't cover (off)

; ------------------------------------------------------------------------------

; battle commands for each character class (22 * 5 bytes)
@fd55:  .include .sprintf("data/class_cmd_%s.asm", LANG_SUFFIX)

; ------------------------------------------------------------------------------

; battle command targeting flags -> $3302 (26 * 1 byte)
CmdTargetTbl:
@fdc3:  .byte   $50,$00,$00,$00,$00,$60,$58,$60,$50,$00,$20,$20,$50,$50,$60,$00
        .byte   $60,$00,$60,$18,$58,$60,$50,$50,$00,$28

; ------------------------------------------------------------------------------

; spell lists for each character (see 14/ffa2 for menu)
SpellListTbl:
@fddd:  .byte   $ff,$ff,$ff
        .byte   $ff,$ff,$ff
        .byte   $02,$03,$04
        .byte   $05,$06,$ff
        .byte   $ff,$ff,$ff
        .byte   $07,$ff,$ff
        .byte   $ff,$ff,$ff
        .byte   $ff,$08,$ff
        .byte   $09,$ff,$ff
        .byte   $00,$ff,$ff
        .byte   $ff,$ff,$ff
        .byte   $ff,$03,$04
        .byte   $ff,$0c,$ff
        .byte   $0a,$0b,$ff
        .byte   $0a,$0b,$ff
        .byte   $ff,$ff,$ff

; ------------------------------------------------------------------------------

; battles with auto-battle scripts
AutoBattleTbl:
@fe0d:  .word   $00eb,$00f5,$00ee,$00f0,$00f3,$00fd,$01b3,$01b4

; pointers to auto-battle scripts
AutoBattlePtrs:
@fe1d:  .addr   AutoBattle_0000
        .addr   AutoBattle_0001
        .addr   AutoBattle_0002
        .addr   AutoBattle_0003
        .addr   AutoBattle_0004
        .addr   AutoBattle_0005
        .addr   AutoBattle_0006
        .addr   AutoBattle_0007

; auto-battle scripts
;   00: use magic
;   01: use item
;   C0+: use command
;   FF: end of script (loop to beginning)

; 0: 1st intro battle
AutoBattle_0000:
@fe2d:  .byte   $01,$c0                 ; use item: fire bomb
@fe2f:  .byte   $ff                     ; end of script

; 1: 2nd intro battle
AutoBattle_0001:
@fe30:  .byte   $01,$c2                 ; use item: lit-bolt
@fe32:  .byte   $ff                     ; end of script

; 2: cecil vs. mirror
AutoBattle_0002:
@fe33:  .byte   $c0,$00                 ; use command: fight
@fe35:  .byte   $ff                     ; end of script

; 3: yang
AutoBattle_0003:
@fe36:  .byte   $ce,$00                 ; use command: kick
@fe38:  .byte   $c0,$00                 ; use command: fight
@fe3a:  .byte   $ff                     ; end of script

; 4: tellah vs. golbez
AutoBattle_0004:
@fe3b:  .byte   $00,$26                 ; use magic: virus
@fe3d:  .byte   $00,$1f                 ; use magic: fire 3
@fe3f:  .byte   $00,$25                 ; use magic: lit 3
@fe41:  .byte   $00,$22                 ; use magic: ice 3
@fe43:  .byte   $00,$2f                 ; use magic: meteo
@fe45:  .byte   $ff                     ; end of script

; 5: edge vs. rubicante
AutoBattle_0005:
@fe46:  .byte   $c0,$00                 ; use command: fight
@fe48:  .byte   $00,$42                 ; use magic: flame
@fe4a:  .byte   $ff                     ; end of script

; 6: 1st fusoya and golbez vs. zemus
AutoBattle_0006:
@fe4b:  .byte   $00,$07                 ; use magic: slow
@fe4d:  .byte   $00,$01                 ; use magic: hold
@fe4f:  .byte   $00,$0b                 ; use magic: holy
@fe51:  .byte   $00,$0b                 ; use magic: holy
@fe53:  .byte   $ff                     ; end of script
; golbez
@fe54:  .byte   $00,$1f                 ; use magic: fire 3
@fe56:  .byte   $00,$22                 ; use magic: ice 3
@fe58:  .byte   $00,$25                 ; use magic: lit 3
@fe5a:  .byte   $d0,$00                 ; use command: twin
@fe5c:  .byte   $ff                     ; end of script

; 7: 2nd fusoya and golbez vs. zemus
AutoBattle_0007:
@fe5d:  .byte   $00,$2f                 ; use magic: meteo
@fe5f:  .byte   $00,$0c                 ; use magic: dispel
@fe61:  .byte   $ff                     ; end of script
; golbez
@fe62:  .byte   $00,$2f                 ; use magic: meteo
@fe64:  .byte   $01,$c8                 ; use item: crystal
@fe66:  .byte   $ff                     ; end of script

; ------------------------------------------------------------------------------

; battles with no victory fanfare
NoFanfareTbl:
@fe67:  .word   $00dc,$00dd,$00e1,$00e7,$01a7,$01af,$01b6
        .byte   $ff

; ------------------------------------------------------------------------------

; battles with no victory animation
NoWinAnimTbl:
@fe76:  .word   $00eb,$00f5,$00f0,$00fa,$01a9,$00fe,$00f3,$01b4,$01b7
        .byte   $ff

; ------------------------------------------------------------------------------

; action delay for each command (35 * 1 bytes)

; if msb set, delay is turn duration * x, otherwise delay is turn duration / x
CmdDelayTbl:
.if LANG_EN .and BUGFIX_REV1
@fe89:  .byte   $00,$00,$00,$00,$00,$02,$01,$01,$00,$00,$04,$02,$04,$00,$02,$00
        .byte   $00,$00,$00,$00,$00,$00,$04,$00,$00,$00,$00,$00,$00,$00,$00,$01
        .byte   $02,$00,$8a
.elseif LANG_EN
@fe89:  .byte   $00,$00,$00,$00,$00,$02,$01,$01,$00,$00,$04,$02,$04,$00,$81,$00
        .byte   $00,$00,$00,$00,$00,$00,$04,$00,$00,$00,$00,$00,$00,$00,$00,$82
        .byte   $81,$00,$8a
.else
@fe89:  .byte   $00,$00,$00,$00,$00,$02,$01,$01,$00,$00,$04,$02,$04,$00,$81,$00
        .byte   $00,$00,$00,$00,$00,$00,$04,$00,$00,$00,$00,$00,$00,$00,$00,$82
        .byte   $83,$00,$8a
.endif

; ------------------------------------------------------------------------------

; equipment stat modifiers (8 * 2 bytes)
;   0: modifier for stats with bit set
;   1: modifier for stats with bit clear
EquipStatTbl:
@feac:  .byte   $03,$00  ; +3/+0
        .byte   $05,$00  ; +5/+0
        .byte   $0a,$00  ; +10/+0
        .byte   $0f,$00  ; +15/+0
        .byte   $05,$fb  ; +5/-5
        .byte   $0a,$f6  ; +10/-10
        .byte   $0f,$f1  ; +15/-15
        .byte   $05,$f6  ; +5/-10

; ------------------------------------------------------------------------------

; attacks with no name display (192 * 1 bit)

; $73: じげんのひずみ (dimensional distortion/zeromus shakes)
; $76: のろいのうた (curse song)
; $7b: あんこくかいき (dark regression/vanish)
; $7e: おうじょのうた (princess song/dancing)
; $8e: no effect
; $8f: あんこくかいき (dark regression/vanish)
; $93: じゅばくかいじょ (remove curse/heal)
; $a9: make monsters invincible
; $aa: make monsters un-invincible
; $ad: change to next form
; $ae: end battle
; $af: graphics only
; $b0-$bf: special animations
NoNameAttackTbl:
@febc:  .byte   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$12,$12
        .byte   $00,$03,$10,$00,$00,$67,$ff,$ff

; ------------------------------------------------------------------------------

; attacks with no monster flash (192 * 1 bit)

; $73: disrupt
; $77: hold gas
; $7b: vanish
; $7d: black hole
; $7e: dancing
; $81: magnet
; $83: hatch
; $87: big bang
; $8c: alert
; $8d: call
; $8f: vanish
; $95: globe199
; $ad: change to next form

NoMonsterFlashTbl:
@fed4:  .byte   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$11,$16
        .byte   $51,$0d,$04,$00,$00,$04,$00,$00

; ------------------------------------------------------------------------------

; summon book attacks (single random target if msb set)
SummonBookTbl:
@feec:  .byte   $d1,$52,$53,$54,$55,$56,$d7,$58,$59,$5d

; ------------------------------------------------------------------------------

; inverted bit masks
BitAndTbl:
@fef6:  .byte   $7f,$bf,$df,$ef,$f7,$fb,$fd,$fe

; ------------------------------------------------------------------------------

; bit masks
BitOrTbl:
@fefe:  .byte   $80,$40,$20,$10,$08,$04,$02,$01

; ------------------------------------------------------------------------------

; battle speed constants
BattleSpeedTbl:
@ff06:  .byte   0,1,3,5,7,10

; ------------------------------------------------------------------------------

; battle songs
BattleSongTbl:
@ff0c:  .byte   $27,$1a,$0b

; ------------------------------------------------------------------------------

; monster run difficulty (based on monster level)
;   97: リルマーダー (lil' murderer/tricker)
;       ぎんりゅう (ging-ryu)
;       まじんへい (red giant)
;       きんりゅう (king-ryu)
;   98: ゼムスブレス (zemus' breath)
;       ゼムスマインド (zemus' mind)
;       はくりゅう (blue dragon)
;   99: フェイズ (phase/evil mask)
;       アーリマン (ahriman/fatal eye)
;       ルナザウルス (lunar saurus)
;       ダークバハムート (dark bahamut/wyvern)
;       レッドドラゴン (red dragon)
;       ベヒーモス (behemoth)
MonsterRunTbl:
@ff0f:  .byte   3,7,10

; ------------------------------------------------------------------------------
