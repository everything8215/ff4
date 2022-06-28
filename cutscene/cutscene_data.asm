
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: cutscene_data.asm                                                    |
; |                                                                            |
; | description: data for cutscene module                                      |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

.import RNGTbl, WindowGfx, DakutenTbl

; ------------------------------------------------------------------------------

.segment "solar_system_sprite"

; 12/f660
        .include "data/solar_system_sprite.asm"

; ------------------------------------------------------------------------------

.segment "cutscene_gfx"

; 13/d200
        .include "gfx/solar_system_pal.asm"

; 13/d300
        .include "gfx/credits_stars_gfx.asm"

; 13/d510
        .include "gfx/credits_pal.asm"

; ------------------------------------------------------------------------------

.segment "solar_system_gfx"

; 15/cc00
        .include "gfx/solar_system_gfx.asm"

; 15/d840
        .include "gfx/big_moon_gfx.asm"

; ------------------------------------------------------------------------------
