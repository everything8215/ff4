
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: menu_data.asm                                                        |
; |                                                                            |
; | description: data for menu module                                          |
; |                                                                            |
; | created: 4/7/2022                                                          |
; +----------------------------------------------------------------------------+

.export BattleCmdName, ElementStatus, ItemClasses

; ------------------------------------------------------------------------------

.segment "item_misc"

; 0f/a450
        .include .sprintf("data/item_price_%s.asm", LANG_SUFFIX)

; 0f/a550
        .include "data/item_classes.asm"

; 0f/a590
        .include "data/element_status.asm"

.segment "char_name"

; 0f/a710
        .include .sprintf("text/char_name_%s.asm", LANG_SUFFIX)

; 0f/a764
        .include .sprintf("text/class_name_%s.asm", LANG_SUFFIX)

; 0f/a7b8
        .include .sprintf("text/battle_cmd_name_%s.asm", LANG_SUFFIX)

.segment "menu_data"

; calculate bg tile position
.define bg_pos(left,top) left*2+top*64

; define window
.macro def_window left,top,width,height
        .word   bg_pos left,top
        .byte   width,height
.endmacro

; define positioned text
.macro def_ptxt left,top,text
        .word   bg_pos left,top
        .byte   text
.endmacro

; ------------------------------------------------------------------------------

.if LANG_EN
    ; some text is shifted in the english translation
    EQUIP_PTXT_X = 13
    STATUS_LEVEL_X = 11
    BUY_SELL_X = 3
    LOAD_CONFIRM_X2 = 24
    SAVE_COMPLETE_X = 24
    .if BUGFIX_MISC_MENU
        BUG_TERMINATOR = 1
    .else
        BUG_TERMINATOR = 0
    .endif
    FAT_CHOCO_MSG_X = 7
.else
    EQUIP_PTXT_X = 14
    STATUS_LEVEL_X = 10
    BUY_SELL_X = 4
    LOAD_CONFIRM_X2 = 23
    SAVE_COMPLETE_X = 23
    BUG_TERMINATOR = 1
    FAT_CHOCO_MSG_X = 13
.endif

; ------------------------------------------------------------------------------

; [ name change windows ]

NamePortraitWindow:
@db51:  def_window 7,1,4,4

NamePreviewWindow:
@db55:  def_window 14,1,8,4

NameAlphaWindow:
@db59:  def_window 1,8,5,17

NameLettersWindow:
@db5d:  def_window 7,8,22,17

; ------------------------------------------------------------------------------

; [ main menu windows ]

MainCharWindow:
@db61:  def_window 0,0,22,26

MainGilWindow:
@db65:  def_window 21,23,8,3

MainTimeWindow:
@db69:  def_window 22,19,7,2

MainOptionsWindow:
@db6d:  def_window 22,0,7,17
        def_ptxt 24,1,{ITEM_STR,1}
        def_ptxt 24,3,{MAGIC_STR,1}
        def_ptxt 24,5,{EQUIP_STR,1}
        def_ptxt 24,7,{STATUS_STR,1}
        def_ptxt 24,9,{ORDER_STR,1}
        def_ptxt 24,11,{ROW_STR,1}
        def_ptxt 24,13,{CONFIG_STR,1}
SavePosText:
@dba5:  def_ptxt 24,15,{SAVE_STR,0}

MagicLabelPosText:
@dbab:  def_ptxt 24,3,{MAGIC_STR,0}

CantFightText:
@dbb2:  .byte   CANT_FIGHT_STR,0

; ------------------------------------------------------------------------------

; [ name change text ]

; alphabets for name change menu

NameAlphaTbl:

.if !LANG_EN
; hiragana
@dbba:  .byte   HIRAGANA_ALPHA_STR1
        .byte   HIRAGANA_ALPHA_STR2
        .byte   HIRAGANA_ALPHA_STR3
        .byte   HIRAGANA_ALPHA_STR4
        .byte   HIRAGANA_ALPHA_STR5
        .byte   HIRAGANA_ALPHA_STR6
        .byte   HIRAGANA_ALPHA_STR7
        .byte   HIRAGANA_ALPHA_STR8

; katakana
@dc0a:  .byte   KATAKANA_ALPHA_STR1
        .byte   KATAKANA_ALPHA_STR2
        .byte   KATAKANA_ALPHA_STR3
        .byte   KATAKANA_ALPHA_STR4
        .byte   KATAKANA_ALPHA_STR5
        .byte   KATAKANA_ALPHA_STR6
        .byte   KATAKANA_ALPHA_STR7
        .byte   KATAKANA_ALPHA_STR8
.endif

; latin
@dc5a:  .byte   LATIN_ALPHA_STR1
        .byte   LATIN_ALPHA_STR2
        .byte   LATIN_ALPHA_STR3
        .byte   LATIN_ALPHA_STR4
        .byte   LATIN_ALPHA_STR5
        .byte   LATIN_ALPHA_STR6
        .byte   LATIN_ALPHA_STR7
        .byte   LATIN_ALPHA_STR8

AlphaCursorYTbl:
.if LANG_EN
@d8cc:  .byte   $4d,$bd
.else
@dcaa:  .byte   $4d,$5d,$6d,$bd
.endif

NameAlphaPosText:
.if LANG_EN
@d8ce:  def_ptxt 3,9,{ABC_STR,1}
.else
@dcae:  def_ptxt 3,9,{HIRAGANA_STR,1}
        def_ptxt 3,11,{KATAKANA_STR,1}
        def_ptxt 3,13,{ABC_STR,1}
.endif
        def_ptxt 3,23,{END_STR,0}

NameAlphaTblPtrs:
@dcc8:  .word   0,80,160

; ------------------------------------------------------------------------------

; [ item menu windows ]

InventoryWindow:
@dcce:  def_window 1,0,27,48

ItemLabelWindowRight:
@dcd2:  def_window 22,0,7,3

ItemDescWindow:
@dcd6:  def_window 9,0,19,3

ItemMsgWindow:
@dcda:  def_window 8,10,13,2


ItemUnnecessaryPosText:
.if LANG_EN
@dcde:  def_ptxt 12,11,{UNNECESSARY_STR,0}
.else
@dcde:  def_ptxt 9,11,{UNNECESSARY_STR,0}
.endif

ItemDoesntWorkPosText:
@dcee:  def_ptxt 9,11,{DOESNT_WORK_STR,0}

ItemLabelWindowLeft:
@dcfc:  def_window 1,0,7,3

ItemLabelPosText:
@dd00:  def_ptxt 3,1,{ITEM_STR,0}

; *** this is unused ***
RecoverHPPosText:
@dd07:  def_ptxt 10,1,{RECOVER_HP_STR,0}

ItemWhomPosText:
@dd14:  def_ptxt 10,1,{ITEM_WHOM_STR,0}

CantUseHerePosText:
@dd20:  def_ptxt 10,1,{CANT_USE_HERE_STR,0}

NothingHerePosText:
@dd2d:  def_ptxt 10,1,{NOTHING_HERE_STR,0}

; character select windows for item use
ItemCharSelectWindowLeft:
@dd38:  def_window 1,5,14,21

ItemCharSelectWindowRight:
@dd3c:  def_window 14,5,14,21

; ------------------------------------------------------------------------------

; [ magic menu windows and text ]

CantUseMagicWindow:
@dd40:  def_window 8,8,10,3
@dd44:  def_ptxt 9,9,{CANT_USE_MAGIC_STR,0}

MagicListWindow:
@dd51:  def_window 1,8,28,17

Char1MagicWindow:
@dd55:  def_window 1,0,19,7

Char2MagicWindow:
@dd59:  def_window 1,5,19,7

Char3MagicWindow:
@dd5d:  def_window 1,10,19,7

Char4MagicWindow:
@dd61:  def_window 1,15,19,7

Char5MagicWindow:
@dd65:  def_window 1,20,19,7

; magic type window (black, white, etc.)
MagicTypeWindow:
@dd69:  def_window 22,2,7,7

; magic target window (character blocks)
MagicTargetWindow:
@dd6d:  def_window 8,0,21,26

; use on whom window
MagicWhomWindow:
@dd71:  def_window 1,8,7,3

; magic name and mp needed (for target select)
MagicNameWindow:
@dd75:  def_window 1,0,7,7

MPNeededPosText:
.if LANG_EN
@dd79:  def_ptxt 2,4,{MP_NEEDED_STR,0}
.else
@dd79:  def_ptxt 3,4,{MP_NEEDED_STR,0}
.endif

MagicWhomPosText:
@dd82:  def_ptxt 3,10,{MAGIC_WHOM_STR,0}

; ------------------------------------------------------------------------------

; [ equip menu windows and text ]

CharEquipWindowTbl:
@dd8b:  .addr   Char1EquipWindow
        .addr   Char2EquipWindow
        .addr   Char3EquipWindow
        .addr   Char4EquipWindow
        .addr   Char5EquipWindow

Char1EquipWindow:
@dd95:  def_window 1,0,27,11

Char2EquipWindow:
@dd99:  def_window 1,5,27,11

Char3EquipWindow:
@dd9d:  def_window 1,10,27,11

Char4EquipWindow:
@dda1:  def_window 1,15,27,11

Char5EquipWindow:
@dda5:  def_window 1,20,27,11

EquipWindow:
@dda9:  def_window 1,0,27,11
@ddad:  def_ptxt EQUIP_PTXT_X,1,{EQUIP_SLOT1_STR,1}
@ddb3:  def_ptxt EQUIP_PTXT_X,3,{EQUIP_SLOT2_STR,1}
@ddba:  def_ptxt EQUIP_PTXT_X,5,{EQUIP_SLOT3_STR,1}
@ddc0:  def_ptxt EQUIP_PTXT_X,7,{EQUIP_SLOT4_STR,1}
@ddc6:  def_ptxt EQUIP_PTXT_X,9,{EQUIP_SLOT5_STR,0}

; "もちものがいっぱいです" (inventory full) *** this is unused ***
@ddcb:  def_ptxt 4,5,{INVENTORY_FULL_STR,0}

; item must be equipped with both hands
EquipTwoHandWindow:
@ddd9:  def_window 9,14,11,6
@dddd:  def_ptxt 10,15,{EQUIP_2HAND_STR1,BUG_TERMINATOR}
@ddea:  def_ptxt 12,17,{EQUIP_2HAND_STR2,BUG_TERMINATOR}
@ddf3:  def_ptxt 10,19,{EQUIP_2HAND_STR3,0}

; ------------------------------------------------------------------------------

; [ status menu windows and text ]

StatusWindow:
@de01:  def_window 0,1,29,24

StatusPortraitWindow:
@de05:  def_window 18,6,11,4

StatusLabelPosText:
@de09:  def_ptxt 24,7,{STATUS_STR,0}

StatusPosText:
@de11:  def_ptxt STATUS_LEVEL_X,4,{STATUS_LEVEL_STR,1}
        def_ptxt 17,6,{EXP_STR,1}
        def_ptxt 3,8,{HP_STR,1}
        def_ptxt 3,10,{MP_STR,1}
        def_ptxt 2,13,{ABILITY_STR,1}
        def_ptxt 3,15,{STRENGTH_STR,1}
        def_ptxt 3,17,{AGILITY_STR,1}
        def_ptxt 3,19,{STAMINA_STR,1}
        def_ptxt 3,21,{INTELLECT_STR,1}
        def_ptxt 3,23,{SPIRIT_STR,1}
        def_ptxt 13,13,{ATTACK_STR,1}
        def_ptxt 13,15,{HIT_RATE_STR,1}
        def_ptxt 13,17,{DEFENSE_STR,1}
        def_ptxt 13,19,{EVADE_STR,1}
        def_ptxt 13,21,{MAG_DEF_STR,1}
        def_ptxt 13,23,{MAG_EVADE_STR,1}
        def_ptxt 23,13,{MULT_STR,1}
        def_ptxt 23,17,{MULT_STR,1}
        def_ptxt 23,21,{MULT_STR,0}

NextLevelPosText:
@de98:  def_ptxt 17,9,{NEXT_LEVEL_STR,0}

; ------------------------------------------------------------------------------

; [ shop menu windows and text ]

ShopGilWindow:
@dea6:  def_window 17,4,11,3

ShopChoiceWindow:
@deaa:  def_window 1,4,15,3

ShopTypeWindow:
@deae:  def_window 1,0,6,2

ShopMsgWindow:
@deb2:  def_window 8,0,20,2

ShopListWindow:
@deb6:  def_window 1,8,20,17

ShopCharWindow:
@deba:  def_window 22,8,7,11

ShopTypeTextTbl:
@debe:  .byte   WEAPON_SHOP_STR
        .byte   ARMOR_SHOP_STR
        .byte   ITEM_SHOP_STR

ShopWelcomePosText:
@decd:  def_ptxt 10,1,{SHOP_WELCOME_STR,1}
@dee2:  def_ptxt BUY_SELL_X,5,{BUY_SELL_STR,0}

ShopWhichPosText:
@def1:  def_ptxt 10,1,{SHOP_WHICH_ITEM_STR,1}

ShopQtyPosText:
@deff:  def_ptxt 3,5,{SHOP_QTY_STR,0}

GilPosText:
@df0a:  def_ptxt 27,5,{GIL_STR,0}

ShopInventoryFullPosText:
@df0f:  def_window 1,10,20,4
@df13:  def_ptxt 2,11,{SHOP_INVENTORY_FULL_STR1,1}
@df2a:  def_ptxt 2,13,{SHOP_INVENTORY_FULL_STR2,0}

ShopNotEnoughGilPosText:
@df3b:  def_window 5,10,16,4
@df3f:  def_ptxt 6,11,{NOT_ENOUGH_GIL_STR1,1}
@df52:  def_ptxt 6,13,{NOT_ENOUGH_GIL_STR2,0}

ThankYouWindow:
@df61:  def_window 5,10,11,2
@df65:  def_ptxt 6,11,{THANK_YOU_STR,0}

SellWindow:
.if LANG_EN
@db9a:  def_window 9,10,11,11
@db9e:  def_ptxt 12,15,{SELL_STR1,1}
@dba8:  def_ptxt 18,17,{SELL_STR2,1}
@dbae:  def_ptxt 12,13,{SELL_STR3,1}
@dbb2:  def_ptxt 12,19,{SELL_STR4,0}
.else
@df73:  def_window 9,10,11,13
@df78:  def_ptxt 13,13,{SELL_STR1,1}
@df7e:  def_ptxt 18,15,{SELL_STR2,1}
@df84:  def_ptxt 10,17,{SELL_STR3,1}
@df92:  def_ptxt 11,19,{SELL_STR4,1}
@df9d:  def_ptxt 12,21,{SELL_STR5,0}
.endif

; *** this message doesn't have a position header, so it doesn't display ***
SellMsgPosText:
.if BUGFIX_MISC_MENU
@dfa7:  def_ptxt 10,1,{SELL_MSG_STR,0}
.else
@dfa7:  .byte   SELL_MSG_STR,0
.endif

ExpendText:
@dfba:  .byte   EXPEND_STR,0

; ------------------------------------------------------------------------------

; [ game load menu windows and text ]

SaveSlotWindow:
@dfc1:  def_window 0,0,29,5

NewGameWindow:
@dfc5:  def_window 0,0,16,2

NewGamePosText:
@dfc9:  def_ptxt 3,1,{NEW_GAME_STR,0}

; *** unused (carried over from ff3j-style load menu) ***
LoadBattleSpeedPosText:
@dfd2:  def_ptxt 20,1,{BATTLE_SPEED_STR,0}

LoadMsgWindow:
@dfdc:  def_window 22,0,7,8

LoadTimeWindow:
@dfe0:  def_window 22,16,7,5

LoadGilWindow:
@dfe4:  def_window 22,23,7,3

LoadConfirmPosText:
@dfe8:  def_ptxt 23,1,{LOAD_CONFIRM_STR1,1}
@dff1:  def_ptxt LOAD_CONFIRM_X2,3,{LOAD_CONFIRM_STR2,0}

LoadYesNoPosText:
@dffa:  def_ptxt 25,5,{YES_STR,1}
@dfff:  def_ptxt 25,7,{NO_STR,0}

TimePosText:
@e005:  def_ptxt 23,17,{TIME_STR,0}

LoadEmptyPosText:
@e00c:  def_ptxt 8,2,{EMPTY_STR,0}

; ------------------------------------------------------------------------------

; [ game save menu windows and text ]

SaveLabelPosText:
@e014:  def_ptxt 3,1,{SAVE_STR,0}

SaveCancelledPosText:
@e01a:  def_ptxt 3,1,{SAVE_CANCELLED_STR,0}

SaveCompletePosText:
@e02b:  def_ptxt SAVE_COMPLETE_X,11,{SAVE_COMPLETE_STR,0}

SaveConfirmPosText:
@e035:  def_ptxt 23,1,{SAVE_CONFIRM_STR1,BUG_TERMINATOR}
@e03f:  def_ptxt 23,3,{SAVE_CONFIRM_STR2,0}

.if BUGFIX_MISC_MENU
        SAVE_CANCEL_MSG_X = 23
.else
        SAVE_CANCEL_MSG_X = 25
.endif

SaveCancelMsgPosText:
@e048:  def_ptxt SAVE_CANCEL_MSG_X,11,{SAVE_CANCEL_MSG_STR,0}

SaveMsgWindow:
@e050:  def_window 22,10,7,2

; ------------------------------------------------------------------------------

; [ namingway menu windows and text ]

NamingwayChoiceWindow:
@e054:  def_window 1,5,13,1

NamingwayMsg1PosText:
@e058:  def_ptxt 7,1,{NAMINGWAY_MSG1_STR,0}

NamingwayMsg2PosText:
@e072:  def_ptxt 7,1,{NAMINGWAY_MSG2_STR,0}

; *** unused ***
NamingwayMsg3PosText:
@e089:  def_ptxt 7,1,{NAMINGWAY_MSG3_STR,0}

; *** unused ***
NamingwayMsg4PosText:
@e09c:  def_ptxt 7,1,{NAMINGWAY_MSG4_STR,0}

NamingwayChoiceText:
@e0ac:  .byte   NAMINGWAY_CHOICE_STR,0

NamingwayMsg5PosText:
@e0b7:  def_ptxt 7,1,{NAMINGWAY_MSG5_STR,0}

NamingwayMsgWindow:
@e0cc:  def_window 6,0,23,2

NamingwayPreviewWindow:
@e0d0:  def_window 8,4,6,2

; ------------------------------------------------------------------------------

; [ fat chocobo menu windows and text ]

FatChocoMsgWindow:
@e0d4:  def_window 6,1,20,2

FatChocoListWindow:
@e0d8:  def_window 1,10,27,15

FatChocoChoiceWindow:
@e0dc:  def_window 2,6,12,2

FatChocoChoicePosText:
.if !LANG_EN
@e0e0:  def_ptxt 7,2,{FAT_CHOCO_NAME_STR,1}
.endif
@e0e9:  def_ptxt 4,7,{FAT_CHOCO_CHOICE_STR,0}

FatChocoMsg1PosText:
@e0f6:  def_ptxt FAT_CHOCO_MSG_X,2,{FAT_CHOCO_MSG1_STR,0}

FatChocoMsg2PosText:
@e107:  def_ptxt FAT_CHOCO_MSG_X,2,{FAT_CHOCO_MSG2_STR,0}

FatChocoMsg3PosText:
@e118:  def_ptxt FAT_CHOCO_MSG_X,2,{FAT_CHOCO_MSG3_STR,0}

FatChocoMsg4PosText:
@e129:  def_ptxt FAT_CHOCO_MSG_X,2,{FAT_CHOCO_MSG4_STR,0}

FatChocoMsg5PosText:
@e13a:  def_ptxt FAT_CHOCO_MSG_X,2,{FAT_CHOCO_MSG5_STR,0}

FatChocoMsg6PosText:
@e14b:  def_ptxt FAT_CHOCO_MSG_X,2,{FAT_CHOCO_MSG6_STR,0}

; ------------------------------------------------------------------------------

; [ config menu windows and text ]

.if LANG_EN
ConfigLabelWindow:
@dd47:  def_window 9,1,10,2
ConfigLabelPosText:
@dd4b:  def_ptxt 10,2,{CUSTOMIZER_STR,0}
.else
ConfigLabelWindow:
@e15c:  def_window 10,1,7,2
ConfigLabelPosText:
@e160:  def_ptxt 12,2,{CONFIG_STR,0}
.endif

ConfigMainWindow:
@e168:  def_window 2,4,24,20

.if SIMPLE_CONFIG

@dd5c:  def_ptxt 15,6,{FAST_STR,1}
@dd63:  def_ptxt 22,6,{SLOW_STR,1}
@dd6a:  def_ptxt 15,10,{FAST_STR,1}
@dd71:  def_ptxt 22,10,{SLOW_STR,1}
@dd78:  def_ptxt 5,5,{BATTLE_SPEED_STR,1}
@dd88:  def_ptxt 5,9,{BATTLE_MSG_STR,1}
@dd98:  def_ptxt 5,17,{WINDOW_COLOR_STR,1}
@dda7:  def_ptxt 5,14,{SOUND_STR,1}
@ddaf:  def_ptxt 15,14,{STEREO_MONO_STR,0}
BtnMapWindow: ; *** unused ***
@ddbd:  def_window 0,7,28,12

.else

@e16c:  def_ptxt 5,5,{BATTLE_MODE_STR,1}
@e175:  def_ptxt 15,5,{WAIT_ACTIVE_STR,1}
@e184:  def_ptxt 5,7,{BATTLE_SPEED_STR,1}
@e18e:  def_ptxt 5,9,{BATTLE_MSG_STR,1}
@e19a:  def_ptxt 5,19,{WINDOW_COLOR_STR,1}
@e1a4:  def_ptxt 15,13,{NORMAL_CUSTOM_STR,1}
@e1b2:  def_ptxt 5,17,{CURSOR_POS_STR,1}
@e1bb:  def_ptxt 15,17,{RESET_MEMORY_STR,1}
@e1c8:  def_ptxt 5,11,{SOUND_STR,1}
@e1df:  def_ptxt 15,11,{STEREO_MONO_STR,1}
@e1dd:  def_ptxt 15,8,{FAST_STR,1}
@e1e3:  def_ptxt 23,8,{SLOW_STR,1}
@e1e9:  def_ptxt 15,15,{SINGLE_MULTI_STR,1}
MultiCtrlPtxt:
@e1f6:  def_ptxt 5,13,{MULTI_CTRL_STR,0}

BtnMapWindow:
@e200:  def_window 0,7,28,12

BtnMapPosText:
@e204:  def_ptxt 11,2,{CUSTOMIZER_STR,1}
@e20d:  def_ptxt 3,8,{CONFIRM_STR,1}
@e214:  def_ptxt 3,10,{CANCEL_STR,1}
@e21b:  def_ptxt 3,12,{MENU_STR,1}
@e222:  def_ptxt 3,14,{L_BUTTON_STR,1}
@e22a:  def_ptxt 3,16,{START_STR,1}
@e232:  def_ptxt 3,18,{END_STR,0}

BtnList1Text:
@e238:  .byte BTN_LIST1_STR,0
BtnList2Text:
@e24c:  .byte BTN_LIST2_STR,0

.endif

; alternate multi-controller window *** unused ***
; see https://tcrf.net/File:Ffiv_25thguide_mockups3.png
@e25f:  def_window 1,8,27,6

MultiCtrlWindow:
@e263:  def_window 5,7,20,11
.if !SIMPLE_CONFIG
@e267:  def_ptxt 11,2,{CTRL_SELECT_STR,0}
.endif

; ------------------------------------------------------------------------------

; [ treasure menu windows and text ]

TreasureChoiceWindow:
@e271:  def_window 8,0,20,2

TreasureItemsWindow:
@e275:  def_window 1,3,27,10

TreasureLabelWindow:
.if LANG_EN
@e279:  def_window 1,0,8,2
@e27d:  def_ptxt 2,1,{TREASURE_STR,1}
.else
@e279:  def_window 1,0,6,2
@e27d:  def_ptxt 3,1,{TREASURE_STR,1}
.endif
@e284:  def_ptxt 25,1,{TREASURE_EXIT_STR,1}
TreasureTakeAllPosText:
.if LANG_EN
@e28a:  def_ptxt 13,1,{TREASURE_TAKE_ALL_STR,0}
.else
@e28a:  def_ptxt 11,1,{TREASURE_TAKE_ALL_STR,0}
.endif

TreasureExchangePosText:
.if LANG_EN
@e295:  def_ptxt 13,1,{TREASURE_EXCHANGE_STR,0}
.else
@e295:  def_ptxt 11,1,{TREASURE_EXCHANGE_STR,0}
.endif

TreasureWarningWindow:
@e2a0:  def_window 8,10,11,4
; "じゅうようなアイテムが" (there are important items left)
; "のこっていますよ"
.if LANG_EN .and (!BUGFIX_MISC_MENU)
; this was left untranslated
@e2a4:  def_ptxt 9,11,{$16,$7e,$8c,$af,$8c,$9e,$ca,$cb,$dc,$ea,$10,1}
@e2b2:  def_ptxt 10,13,{$a2,$93,$7c,$9c,$8b,$a8,$96,$af,0}
.else
@e2a4:  def_ptxt 9,11,{TREASURE_WARNING_STR1,1}
@e2b2:  def_ptxt 10,13,{TREASURE_WARNING_STR2,0}
.endif

; ------------------------------------------------------------------------------

; [ misc. menu text ]

; summon item message
SummonMsgWindow:
@e2bd:  def_window 12,9,7,6
SummonMsgPosText:
.if LANG_EN
@de1e:  def_ptxt 13,12,{SUMMON_MSG_STR,0}
.else
@e2c1:  def_ptxt 19,10,{SUMMON_MSG_STR1,1}
@e2c5:  def_ptxt 14,14,{SUMMON_MSG_STR2,0}
.endif

; battle speed numerals
BattleNumText:
@e2cd:  .byte   BATTLE_NUM_STR,0

; character handedness (8 bytes each)
HandednessText:
@e2d9:  .byte   HANDEDNESS1_STR
@e2e1:  .byte   HANDEDNESS2_STR
@e2e9:  .byte   HANDEDNESS3_STR
@e2f1:  .byte   HANDEDNESS4_STR

; ------------------------------------------------------------------------------
