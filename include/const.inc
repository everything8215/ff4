
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: const.inc                                                            |
; |                                                                            |
; | description: global constant definitions                                   |
; |                                                                            |
; | created: 9/28/2020                                                         |
; |                                                                            |
; | author: everything8215@gmail.com                                           |
; +----------------------------------------------------------------------------+

.list off  ; disable listing

; define a config constant if it's not already defined
.macro def_config _const, _value
        .ifndef _const
        _const = _value
        .endif
.endmacro

def_config BUGFIX_ANIM_FRAME_PTRS,0
def_config BUGFIX_ITEM_DUP,0
def_config BUGFIX_MISC_MENU,0
def_config BUGFIX_REV1,0
def_config BUGFIX_SYLPH_EFFECT,0
def_config BUGFIX_WORLD_BATTLE,0
def_config BYTE_PERFECT,1
def_config DEBUG,0
def_config EASY_VERSION,0
def_config LANG_EN,0
def_config NO_RAND_BATTLES,0
def_config ROM_VERSION,0
def_config SIMPLE_CONFIG,0
def_config SKIP_INTRO,0

.if LANG_EN
.define LANG_SUFFIX "en"
.else
.define LANG_SUFFIX "jp"
.endif

.list on
