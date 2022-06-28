
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: header.asm                                                           |
; |                                                                            |
; | description: snes cartridge header                                         |
; |                                                                            |
; | created: 3/14/2022                                                         |
; +----------------------------------------------------------------------------+

.segment "snes_header"

SnesHeader:
@ffc0:
.if LANG_EN .and BUGFIX_REV1
        .byte   "FINAL FANTASY 2      " ; rom title (U, rev. 1)
.elseif LANG_EN
        .byte   "FINAL FANTASY II     " ; rom title (U)
.elseif EASY_VERSION
        .byte   "FINAL FANTASY 4 EASY " ; rom title (J, easy version)
.else
        .byte   "FINAL FANTASY 4      " ; rom title (J)
.endif
        .byte   $20                     ; LoROM, SlowROM
        .byte   $02                     ; rom + ram + sram
        .byte   $0a                     ; rom size: 16 Mbit
        .byte   $03                     ; sram size: 64 kbit
.if LANG_EN
        .byte   $01                     ; destination: north america
.else
        .byte   $00                     ; destination: japan
.endif
        .byte   $c3                     ; publisher: squaresoft
        .byte   ROM_VERSION             ; revision number (0 or 1)
        .word   0                       ; checksum (calculate later)
        .word   $ffff                   ; inverse checksum

; ------------------------------------------------------------------------------

.segment "vectors"

Vectors:
@ffe0:  .res    10
@ffea:  .addr   JmpNMI
        .res    2
@ffee:  .addr   JmpIRQ
        .res    12
@fffc:  .addr   Reset
        .res    2

; ------------------------------------------------------------------------------
