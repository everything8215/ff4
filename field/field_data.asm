
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: field_data.asm                                                       |
; |                                                                            |
; | description: data for field module                                         |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

.export RNGTbl

; ------------------------------------------------------------------------------

.segment "char_prop"

; 0f/a900
        .include "data/char_prop.asm"
        .res $0200+CharProp-*

; 0f/ab00
        .include "data/char_init_equip.asm"

; ------------------------------------------------------------------------------

; 14/8000
.segment "world_data"
        .include "data/world_tileset.asm"
        .include "data/world_tile_pal.asm"
        .include "gfx/world_pal.asm"
        .include "data/world_tile_prop.asm"

; ------------------------------------------------------------------------------

; 14/8e00
.segment "field_data"

        .include .sprintf("data/tile_prop_%s.asm", LANG_SUFFIX)
        .include .sprintf("data/map_tileset_%s.asm", LANG_SUFFIX)
        .include .sprintf("gfx/map_pal_%s.asm", LANG_SUFFIX)

@ee00:  .include "data/rng_tbl.asm"
@ef00:  .include "data/mode7_sine.asm"

; data for drawing vehicle sprites (airship zoom level)
_14f000:
@f000:  .word   $0555,$055b,$0562,$0568,$056e,$0574,$057a,$0580
        .word   $0586,$058c,$0593,$0599,$059f,$05a5,$05ab,$05b1
        .word   $05b7,$05bd,$05c4,$05ca,$05d0,$05d6,$05dc,$05e2
        .word   $05e8,$05ee,$05f5,$05fb,$0601,$0607,$060d,$0613
        .word   $0619,$061f,$0626,$062c,$0632,$0638,$063e,$0644
        .word   $064a,$0650,$0656,$065d,$0663,$0669,$066f,$0675
        .word   $067b,$0681,$0687,$068e,$0694,$069a,$06a0,$06a6
        .word   $06ac,$06b2,$06b8,$06bf,$06c5,$06cb,$06d1,$06d7
        .word   $06dd,$06e3,$06e9,$06f0,$06f6,$06fc,$0702,$0708
        .word   $070e,$0714,$071a,$0721,$0727,$072d,$0733,$0739
        .word   $073f,$0745,$074b,$0752,$0758,$075e,$0764,$076a
        .word   $0770,$0776,$077c,$0782,$0789,$078f,$0795,$079b
        .word   $07a1,$07a7,$07ad,$07b3,$07ba,$07c0,$07c6,$07cc
        .word   $07d2,$07d8,$07de,$07e4,$07eb,$07f1,$07f7,$07fd
        .word   $0803,$0809,$080f,$0815,$081c,$0822,$0828,$082e
        .word   $0834,$083a,$0840,$0846,$084d,$0853,$0859,$085f
        .word   $0865,$086b,$0871,$0877,$087e,$0884,$088a,$0890
        .word   $0896,$089c,$08a2,$08a8,$08ae,$08b5,$08bb,$08c1
        .word   $08c7,$08cd,$08d3,$08d9,$08df,$08e6,$08ec,$08f2
        .word   $08f8,$08fe,$0904,$090a,$0910,$0917,$091d,$0923
        .word   $0929,$092f,$0935,$093b,$0941,$0948,$094e,$0954
        .word   $095a,$0960,$0966,$096c,$0972,$0979,$097f,$0985
        .word   $098b,$0991,$0997,$099d,$09a3,$09aa,$09b0,$09b6
        .word   $09bc,$09c2,$09c8,$09ce,$09d4,$09da,$09e1,$09e7
        .word   $09ed,$09f3,$09f9,$09ff,$0a05,$0a0b,$0a12,$0a18
        .word   $0a1e,$0a24,$0a2a,$0a30,$0a36,$0a3c,$0a43,$0a49
        .word   $0a4f,$0a55,$0a5b,$0a61,$0a67,$0a6d,$0a74,$0a7a
        .word   $0a80,$0a86,$0a8c,$0a92,$0a98,$0a9e,$0aa5,$0aab

; data for drawing vehicle sprites (big whale zoom level)
_14f1c0:
@f1c0:  .word   $0400,$0405,$0409,$040e,$0412,$0417,$041c,$0420
        .word   $0425,$0429,$042e,$0433,$0437,$043c,$0440,$0445
        .word   $0449,$044e,$0453,$0457,$045c,$0460,$0465,$046a
        .word   $046e,$0473,$0477,$047c,$0481,$0485,$048a,$048e
        .word   $0493,$0498,$049c,$04a1,$04a5,$04aa,$04ae,$04b3
        .word   $04b8,$04bc,$04c1,$04c5,$04ca,$04cf,$04d3,$04d8
        .word   $04dc,$04e1,$04e6,$04ea,$04ef,$04f3,$04f8,$04fd
        .word   $0501,$0506,$050a,$050f,$0514,$0518,$051d,$0521
        .word   $0526,$052a,$052f,$0534,$0538,$053d,$0541,$0546
        .word   $054b,$054f,$0554,$0558,$055d,$0562,$0566,$056b
        .word   $056f,$0574,$0579,$057d,$0582,$0586,$058b,$058f
        .word   $0594,$0599,$059d,$05a2,$05a6,$05ab,$05b0,$05b4
        .word   $05b9,$05bd,$05c2,$05c7,$05cb,$05d0,$05d4,$05d9
        .word   $05de,$05e2,$05e7,$05eb,$05f0,$05f5,$05f9,$05fe
        .word   $0602,$0607,$060b,$0610,$0615,$0619,$061e,$0622
        .word   $0627,$062c,$0630,$0635,$0639,$063e,$0643,$0647
        .word   $064c,$0650,$0655,$065a,$065e,$0663,$0667,$066c
        .word   $0671,$0675,$067a,$067e,$0683,$0687,$068c,$0691
        .word   $0695,$069a,$069e,$06a3,$06a8,$06ac,$06b1,$06b5
        .word   $06ba,$06bf,$06c3,$06c8,$06cc,$06d1,$06d6,$06da
        .word   $06df,$06e3,$06e8,$06ec,$06f1,$06f6,$06fa,$06ff
        .word   $0703,$0708,$070d,$0711,$0716,$071a,$071f,$0724
        .word   $0728,$072d,$0731,$0736,$073b,$073f,$0744,$0748
        .word   $074d,$0752,$0756,$075b,$075f,$0764,$0768,$076d
        .word   $0772,$0776,$077b,$077f,$0784,$0789,$078d,$0792
        .word   $0796,$079b,$07a0,$07a4,$07a9,$07ad,$07b2,$07b7
        .word   $07bb,$07c0,$07c4,$07c9,$07cd,$07d2,$07d7,$07db
        .word   $07e0,$07e4,$07e9,$07ee,$07f2,$07f7,$07fb,$0800

_14f380:
@f380:  .byte   $00,$03,$07,$0a,$0f,$13,$17,$1b,$20,$25,$2a,$2f,$34,$39,$3e,$44
@f390:  .byte   $4a,$50,$56,$5d,$64,$6b,$72,$7a,$82,$8b,$94,$9d,$a8,$b3,$bf,$cc
@f3a0:  .byte   $da

_14f3a1:
@f3a1:  .byte   $00,$02,$04,$06,$09,$0c,$0f,$12,$16,$19,$1c,$1f,$23,$27,$2a,$2d
@f3b1:  .byte   $31,$35,$39,$3d,$41,$46,$4a,$4f,$54,$59,$5e,$63,$68,$6d,$73,$79
@f3c1:  .byte   $7f,$86,$8c,$93,$9a,$a2,$aa,$b2,$bb,$c4,$cd,$d8,$e4

; airship zoom data
AirshipZoomTbl:
@f3ce:  .byte   $80,$7f,$7e,$7e,$7d,$7c,$7c,$7b,$7a,$7a,$79,$78,$78,$77,$76,$76
        .byte   $75,$75,$74,$73,$73,$72,$71,$71,$70,$70,$6f,$6e,$6e,$6d,$6d,$6c
        .byte   $6b,$6b,$6a,$6a,$69,$69,$68,$67,$67,$66,$66,$65,$65,$64,$64,$63
        .byte   $63,$62,$61,$61,$60,$60,$5f,$5f,$5e,$5e,$5d,$5d,$5c,$5c,$5b,$5b
        .byte   $5a,$5a,$59,$59,$58,$58,$57,$57,$56,$56,$55,$55,$54,$54,$53,$53
        .byte   $52,$52,$52,$51,$51,$50,$50,$4f,$4f,$4e,$4e,$4d,$4d,$4d,$4c,$4c
        .byte   $4b,$4b,$4a,$4a,$4a,$49,$49,$48,$48,$47,$47,$47,$46,$46,$45,$45
        .byte   $45,$44,$44,$43,$43,$42,$42,$42,$41,$41,$41,$40,$40,$3f,$3f,$3f
        .byte   $3e,$3e,$3d,$3d,$3d,$3c,$3c,$3c,$3b,$3b,$3a,$3a,$3a,$39,$39,$39
        .byte   $38,$38,$38,$37,$37,$37,$36,$36,$35,$35,$35,$34,$34,$34,$33,$33
        .byte   $33,$32,$32,$32,$31,$31,$31,$30,$30,$30,$2f,$2f,$2f,$2e,$2e,$2e
        .byte   $2e,$2d,$2d,$2d,$2c,$2c,$2c,$2b,$2b,$2b,$2a,$2a,$2a,$29,$29,$29
        .byte   $29,$28,$28,$28,$27,$27,$27,$26,$26,$26,$26,$25,$25,$25,$24,$24
        .byte   $24,$24,$23,$23,$23,$22,$22,$22,$22,$21,$21,$21,$21,$20,$20,$20

; big whale zoom data
WhaleZoomTbl:
@f4ae:  .byte   $c0,$bf,$be,$bd,$bc,$bb,$ba,$b9,$b8,$b7,$b6,$b6,$b5,$b4,$b3,$b2
        .byte   $b1,$b0,$af,$af,$ae,$ad,$ac,$ab,$aa,$aa,$a9,$a8,$a7,$a6,$a5,$a5
        .byte   $a4,$a3,$a2,$a1,$a1,$a0,$9f,$9e,$9e,$9d,$9c,$9b,$9b,$9a,$99,$98
        .byte   $98,$97,$96,$95,$95,$94,$93,$93,$92,$91,$90,$90,$8f,$8e,$8e,$8d
        .byte   $8c,$8c,$8b,$8a,$8a,$89,$88,$88,$87,$86,$86,$85,$85,$84,$83,$83
        .byte   $82,$81,$81,$80,$80,$7f,$7e,$7e,$7d,$7d,$7c,$7b,$7b,$7a,$7a,$79
        .byte   $78,$78,$77,$77,$76,$76,$75,$74,$74,$73,$73,$72,$72,$71,$71,$70
        .byte   $70,$6f,$6e,$6e,$6d,$6d,$6c,$6c,$6b,$6b,$6a,$6a,$69,$69,$68,$68
        .byte   $67,$67,$66,$66,$65,$65,$64,$64,$63,$63,$62,$62,$61,$61,$60,$60
        .byte   $5f,$5f,$5f,$5e,$5e,$5d,$5d,$5c,$5c,$5b,$5b,$5a,$5a,$5a,$59,$59
        .byte   $58,$58,$57,$57,$56,$56,$56,$55,$55,$54,$54,$53,$53,$53,$52,$52
        .byte   $51,$51,$51,$50,$50,$4f,$4f,$4f,$4e,$4e,$4d,$4d,$4d,$4c,$4c,$4b
        .byte   $4b,$4b,$4a,$4a,$49,$49,$49,$48,$48,$48,$47,$47,$46,$46,$46,$45
        .byte   $45,$45,$44,$44,$44,$43,$43,$42,$42,$42,$41,$41,$41,$40,$40,$40

; ??? sprite data (3 * 6*4 bytes)
_14f58e:
@f58e:  .byte   $00,$00,$38,$15
        .byte   $10,$00,$3a,$15
        .byte   $00,$10,$3c,$15
        .byte   $10,$10,$3e,$15
        .byte   $00,$20,$50,$15
        .byte   $10,$20,$52,$15

@f5a6:  .byte   $00,$00,$3a,$55
        .byte   $10,$00,$38,$55
        .byte   $00,$10,$3e,$55
        .byte   $10,$10,$3c,$55
        .byte   $00,$20,$52,$55
        .byte   $10,$20,$50,$55

@f5be:  .byte   $00,$00,$54,$15
        .byte   $10,$00,$56,$15
        .byte   $00,$10,$58,$15
        .byte   $10,$10,$5a,$15
        .byte   $00,$20,$5c,$15
        .byte   $10,$20,$5e,$15

; whirlpool sprite data
WhirlpoolSpriteTbl:
@f5d6:  .byte   $a0,$15,$a2,$15,$a8,$15,$aa,$15,$a4,$15,$a6,$15,$ac,$15,$ae,$15
        .byte   $ae,$d5,$ac,$d5,$a6,$d5,$a4,$d5,$aa,$d5,$a8,$d5,$a2,$d5,$a0,$d5

; gp window tile data
GilWindowTiles1:
@f5f6:  .byte   $16,$20,$17,$20,$17,$20,$17,$20,$17,$20,$17,$20,$17,$20,$17,$20
        .byte   $17,$20,$17,$20,$17,$20,$18,$20

GilWindowTiles2:
@f60e:  .byte   $19,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20
.if LANG_EN
        .byte   $ff,$20,$ff,$20,$ff,$20,$1a,$20
.else
        .byte   $ff,$20,$c0,$20,$ff,$20,$1a,$20  ; dakuten for "gil"
.endif

GilWindowTiles3:
@f626:  .byte   $19,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20
.if LANG_EN
        .byte   $ff,$20,$48,$20,$51,$20,$1a,$20  ; "GP"
.else
        .byte   $ff,$20,$d0,$20,$f2,$20,$1a,$20  ; "gil"
.endif

GilWindowTiles4:
@f63e:  .byte   $1b,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20
        .byte   $1c,$20,$1c,$20,$1c,$20,$1d,$20

; yes/no window tile data
YesNoTilesTop:
@f656:  .byte   $16,$20,$17,$20,$17,$20,$17,$20,$17,$20,$17,$20,$17,$20,$18,$20
        .byte   $19,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$1a,$20
.if LANG_EN
        .byte   $19,$20,$ff,$20,$14,$20,$5a,$20,$60,$20,$6e,$20,$ff,$20,$1a,$20
        .byte   $19,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$1a,$20
        .byte   $19,$20,$ff,$20,$ff,$20,$4f,$20,$6a,$20,$ff,$20,$ff,$20,$1a,$20
.else
        .byte   $19,$20,$ff,$20,$14,$20,$a3,$20,$8b,$20,$ff,$20,$ff,$20,$1a,$20
        .byte   $19,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$1a,$20
        .byte   $19,$20,$ff,$20,$ff,$20,$8b,$20,$8b,$20,$8d,$20,$ff,$20,$1a,$20
.endif
        .byte   $19,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$1a,$20

YesNoTilesBtm:
@f6b6:  .byte   $1b,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1d,$20

YesNoTilesHide:
@f6c6:  .byte   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

; dialogue window tile data

.if LANG_EN

DlgTilesTop:
@f6d6:  .byte   $00,$20,$16,$20,$17,$20,$17,$20,$17,$20,$17,$20,$17,$20,$17,$20
        .byte   $17,$20,$17,$20,$17,$20,$17,$20,$17,$20,$17,$20,$17,$20,$17,$20
        .byte   $17,$20,$17,$20,$17,$20,$17,$20,$17,$20,$17,$20,$17,$20,$17,$20
        .byte   $17,$20,$17,$20,$17,$20,$17,$20,$17,$20,$17,$20,$18,$20,$00,$20

DlgTilesMid:
@f716:  .byte   $00,$20,$1b,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20
        .byte   $1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20
        .byte   $1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20
        .byte   $1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1d,$20,$00,$20

DlgTilesBtm:
@f756:  .byte   $00,$20,$19,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20
        .byte   $ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20
        .byte   $ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20
        .byte   $ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$1a,$20,$00,$20

.else

DlgTilesTop:
@f6d6:  .byte   $00,$20,$00,$20,$16,$20,$17,$20,$17,$20,$17,$20,$17,$20,$17,$20
        .byte   $17,$20,$17,$20,$17,$20,$17,$20,$17,$20,$17,$20,$17,$20,$17,$20
        .byte   $17,$20,$17,$20,$17,$20,$17,$20,$17,$20,$17,$20,$17,$20,$17,$20
        .byte   $17,$20,$17,$20,$17,$20,$17,$20,$17,$20,$18,$20,$00,$20,$00,$20

DlgTilesMid:
@f716:  .byte   $00,$20,$00,$20,$1b,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20
        .byte   $1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20
        .byte   $1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20
        .byte   $1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1d,$20,$00,$20,$00,$20

DlgTilesBtm:
@f756:  .byte   $00,$20,$00,$20,$19,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20
        .byte   $ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20
        .byte   $ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20
        .byte   $ff,$20,$ff,$20,$ff,$20,$ff,$20,$ff,$20,$1a,$20,$00,$20,$00,$20

.endif

; map title window tile data
MapTitleTilesTop:
@f796:  .byte   $16,$20,$17,$20,$17,$20,$17,$20,$17,$20,$17,$20,$17,$20,$17,$20
        .byte   $17,$20,$17,$20,$17,$20,$17,$20,$17,$20,$17,$20,$17,$20,$18,$20

MapTitleTilesBtm:
@f7b6:  .byte   $1b,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20
        .byte   $1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1c,$20,$1d,$20

; tower/giant flashing light colors
TowerAnimBlueLight:
@f7d6:  .word   $76c0,$5a00,$3d60,$1ca0,$1ca0,$3d60,$5a00,$76c0  ; blue light

TowerAnimRedLight:
@f7e6:  .word   $0007,$0007,$000d,$0014,$001b,$001b,$0014,$000d  ; red light

TowerAnimYellowLight:
@f7f6:  .word   $018f,$0256,$033d,$033d,$0256,$018f,$00c7,$00c7  ; yellow light

; has no effect
TowerNoEffectTbl:
@f806:  .word   $01f7,$0112,$008e,$000b,$0007,$0005,$0002,$0000
        .word   $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

; tower/giant flashing blue shifted palette
TowerAnimBluePal:
@f826:  .word   $7fff,$7b91,$76c0,$6620,$5940,$44a0,$2800,$0000
        .word   $0000,$2800,$44a0,$5940,$6620,$76c0,$7b91,$7fff

NPCSpriteTbl:
@f846:  .byte   $00,$01,$04,$2c,$00,$09,$06,$2c,$08,$01,$05,$2c,$08,$09,$07,$2c
        .byte   $00,$01,$04,$2c,$00,$09,$07,$6c,$08,$01,$05,$2c,$08,$09,$06,$6c
        .byte   $00,$01,$09,$6c,$00,$09,$0b,$6c,$08,$01,$08,$6c,$08,$09,$0a,$6c
        .byte   $00,$00,$0d,$6c,$00,$08,$0f,$6c,$08,$00,$0c,$6c,$08,$08,$0e,$6c
        .byte   $00,$01,$00,$2c,$00,$09,$02,$2c,$08,$01,$01,$2c,$08,$09,$03,$2c
        .byte   $00,$01,$00,$2c,$00,$09,$03,$6c,$08,$01,$01,$2c,$08,$09,$02,$6c
        .byte   $00,$01,$08,$2c,$00,$09,$0a,$2c,$08,$01,$09,$2c,$08,$09,$0b,$2c
        .byte   $00,$00,$0c,$2c,$00,$08,$0e,$2c,$08,$00,$0d,$2c,$08,$08,$0f,$2c
        .byte   $00,$00,$14,$2c,$08,$00,$15,$2c,$00,$08,$16,$2c,$08,$08,$17,$2c
        .byte   $00,$00,$18,$2c,$08,$00,$19,$2c,$00,$08,$1a,$2c,$08,$08,$1b,$2c
        .byte   $00,$00,$18,$2c,$08,$00,$19,$2c,$00,$08,$1a,$2c,$08,$08,$1b,$2c
        .byte   $00,$00,$18,$2c,$08,$00,$19,$2c,$00,$08,$1a,$2c,$08,$08,$1b,$2c
        .byte   $00,$00,$10,$2c,$08,$00,$11,$2c,$00,$08,$12,$2c,$08,$08,$13,$2c
        .byte   $00,$00,$10,$2c,$08,$00,$11,$2c,$00,$08,$12,$2c,$08,$08,$13,$2c
        .byte   $00,$00,$1c,$2c,$08,$00,$1d,$2c,$00,$08,$1e,$2c,$08,$08,$1f,$2c
        .byte   $00,$00,$1c,$2c,$08,$00,$1d,$2c,$00,$08,$1e,$2c,$08,$08,$1f,$2c
        .byte   $00,$01,$00,$2c,$00,$09,$02,$2c,$08,$01,$01,$2c,$08,$09,$03,$2c
        .byte   $00,$01,$04,$2c,$00,$09,$06,$2c,$08,$01,$05,$2c,$08,$09,$07,$2c
        .byte   $00,$01,$08,$2c,$00,$09,$0a,$2c,$08,$01,$09,$2c,$08,$09,$0b,$2c
        .byte   $00,$01,$0c,$2c,$00,$09,$0e,$2c,$08,$01,$0d,$2c,$08,$09,$0f,$2c
        .byte   $00,$01,$01,$6c,$00,$09,$03,$6c,$08,$01,$00,$6c,$08,$09,$02,$6c

; prophecy color palette
ProphecyPal:
@f996:  .word   $4000,$4000,$4000,$4000,$4000,$4000,$4000,$4000
        .word   $4000,$4000,$4000,$4000,$4000,$4000,$4000,$4000
        .word   $4000,$4400,$4800,$4c00,$5000,$5400,$5800,$5c00
        .word   $6000,$6400,$6800,$6c00,$7000,$7400,$7800,$7c00

; ??? sprite data
_14f9d6:
@f9d6:  .byte   $f8,$f8,$c8,$31,$00,$ff,$c8,$71,$f0,$ff,$c8,$b1,$00,$ff,$c8,$f1
        .byte   $f8,$f8,$ca,$31,$00,$ff,$ca,$71,$f0,$ff,$ca,$b1,$00,$ff,$ca,$f1
        .byte   $f0,$f0,$cc,$31,$00,$f0,$ce,$31,$f0,$00,$cc,$b1,$00,$00,$ce,$b1
        .byte   $f0,$f0,$e0,$31,$00,$f0,$e2,$31,$f0,$00,$e0,$b1,$00,$00,$e2,$b1

LavaAnimPal:
@fa16:  .word   $63ff,$4bff,$2f9f,$2f3f,$265f,$150e,$0095,$0c0e
        .word   $5bff,$3f9f,$337f,$2aff,$1a1e,$150e,$0074,$0c0e
        .word   $53ff,$335f,$2b1f,$2abf,$11bc,$150e,$0074,$080e
        .word   $4bff,$277f,$26ff,$267f,$095b,$150e,$0053,$080e

; prologue sprite data
PrologueSpriteTbl:
@fa56:  .byte   $40,$68,$00,$30
        .byte   $48,$68,$01,$30
        .byte   $40,$70,$02,$30
        .byte   $48,$70,$03,$30

EventMosaicTbl:
@fa66:  .byte   $0f,$1f,$2f,$3f,$4f,$5f,$6f,$7f,$8f,$9f,$af,$bf,$cf,$df,$ef,$ff
        .byte   $ef,$df,$cf,$bf,$af,$9f,$8f,$7f,$6f,$5f,$4f,$3f,$2f,$1f,$0f,$0f

; tunnel to underground y-offset for airship sprite
TunnelYTbl:
@fa86:  .byte   $10,$11,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1b,$1c,$1e,$1f,$21
        .byte   $23,$24,$26,$28,$2a,$2d,$2f,$31,$33,$36,$38,$3b,$3e,$40,$43,$46
        .byte   $49,$4c,$4f,$53,$56,$59,$5d,$60,$64,$68,$6b,$6f,$73,$77,$7b,$7f

; tunnel to underground rotation angles
TunnelRotTbl:
@fab6:  .byte   $01,$02,$04,$06,$09,$0c,$10,$14,$19,$1e,$23,$29,$30,$36,$3e,$45
        .byte   $4e,$56,$5f,$69,$73,$7d,$88,$94,$9f,$ac,$b8,$c6,$d3,$e1,$f0,$ff

; ??? sprite data (moon to earth)
_14fad6:
@fad6:  .byte   $70,$70,$00,$00,$78,$70,$01,$00,$70,$78,$02,$00,$78,$78,$03,$00

; ??? sprite data (earth to moon)
_14fae6:
@fae6:  .byte   $70,$70,$04,$00,$78,$70,$05,$00,$70,$78,$06,$00,$78,$78,$07,$00

; y-offsets for big whale liftoff
WhaleLiftoffYTbl:
@faf6:  .byte   $20,$21,$21,$22,$23,$24,$25,$26,$28,$29,$2b,$2c,$2e,$30,$32,$34
        .byte   $36,$38,$3a,$3d,$3f,$42,$44,$47,$4a,$4d,$50,$53,$57,$5a,$5e,$61
        .byte   $65,$69,$6c,$70,$75,$79,$7d,$81

; scanlines for screen wipe
WipeScanlineTbl:
@fb1e:  .byte   $7f,$6e,$7e,$6e,$7e,$6e,$7d,$6d,$7c,$6c,$7b,$6b,$79,$6a,$77,$68
        .byte   $75,$66,$72,$64,$70,$61,$6c,$5f,$69,$5c,$66,$59,$62,$55,$5e,$52
        .byte   $59,$4e,$55,$4a,$50,$46,$4b,$42,$46,$3d,$41,$39,$3b,$34,$36,$2f
        .byte   $30,$2a,$2a,$25,$24,$20,$1e,$1a,$18,$15,$12,$10,$0c,$0a,$06,$05

; world map battle effect zoom values
BattleZoomTbl:
@fb5e:  .byte   $10,$11,$12,$13,$14,$15,$16,$15,$14,$13,$12,$11,$10,$11,$12,$13
        .byte   $14,$15,$16,$15,$14,$13,$12,$11,$10,$0F,$0E,$0D,$0C,$0B,$0A,$08
        .byte   $07,$06,$05,$04,$03,$02,$01,$00

_14fb86:
@fb86:  .byte   $00,$03,$06,$09,$0b,$0d,$0f,$10,$10,$10,$0f,$0d,$0b,$09,$06,$03
        .byte   $00,$fd,$fa,$f7,$f5,$f3,$f1,$f0,$f0,$f0,$f1,$f3,$f5,$f7,$fa,$fd

ShopTypeTbl:
@fba6:  .byte   0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1
        .byte   1,1,2,2,2,2,0,1,2,2,0,1,0,1,2,2

; cave of monsters animated palette
MonsterCaveAnimPal:
@fbc6:  .word   $00d0,$00ae,$008c,$006a,$0048,$006a,$008c,$00ae
        .word   $004c,$004a,$0048,$0026,$0024,$0026,$0028,$004a
        .word   $000a,$0008,$0006,$0004,$0002,$0004,$0006,$0008
        .word   $0154,$0132,$0110,$00ee,$00cc,$00ee,$0110,$0132

; sylvan cave animated palette
SylvanCaveAnimPal:
@fc06:  .word   $26a0,$2280,$1e40,$2200,$15c0,$1a00,$1e40,$2280
        .word   $19c0,$1580,$1140,$0d00,$08c0,$0d00,$1140,$1580
        .word   $0ce0,$0cc0,$08a0,$0880,$0460,$0480,$08a0,$08c0
        .word   $26a0,$2280,$1e40,$2200,$15c0,$1a00,$1e40,$2280

; destroyed damcyan castle tiles
DestroyedDamcyanTiles:
@fc46:  .byte   $ad,$ae,$af,$cb
        .byte   $bc,$bd,$be,$db
        .byte   $e8,$e9,$ea,$bf
        .byte   $f8,$f9,$fa,$fb

_14fc56:
@fc56:  .byte   $40,$40,$a0,$a0,$30,$80,$80,$20,$c0,$b0,$20,$20,$a0,$80,$80,$30

; cave animated water data (offset of row to shift each frame)
; 0, 9, 2, 11, 4, 13, 6, 15, 8, 1, 10, 3, 12, 5, 14, 7
CaveWaterTbl:
@fc66:  .byte   $00,$21,$02,$23,$04,$25,$06,$27,$20,$01,$22,$03,$24,$05,$26,$07

_14fc76:
@fc76:  .byte   $a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$c0,$c0,$c0,$e0,$e0,$e0

_14fc86:
@fc86:  .byte   $40,$40,$40,$40,$20,$20,$20,$60,$60,$60,$20,$20,$20,$60,$60,$60

_14fc96:
@fc96:  .byte   $40,$a0,$30,$b0,$20,$20,$20,$c0,$c0,$c0,$10,$10,$10,$d0,$d0,$d0

_14fca6:
@fca6:  .byte   $2d,$2d,$3d,$3d,$5d,$6d,$7d,$5d,$6d,$7d,$5d,$6d,$7d,$5d,$6d,$7d

_14fcb6:
@fcb6:  .byte   $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$0b,$0b,$0b,$09,$09,$09

; y-offset for npc jumping
NPCJumpYTbl:
@fcc6:  .byte   $00,$03,$06,$08,$0b,$0d,$0f,$11,$13,$14,$15,$17,$17,$18,$19,$19
        .byte   $19,$19,$19,$18,$17,$17,$15,$14,$13,$11,$0f,$0d,$0b,$08,$06,$03

; title screen sprite palette
TitleSpritePal:
@fce6:  .word   $7fff,$739c,$6318,$5294,$4210,$318c,$2108,$1084

; ------------------------------------------------------------------------------

; 1c/8000
.segment "world_sprite_gfx"
        .include "gfx/vehicle_gfx.asm"
        .include "gfx/world_sprite_gfx.asm"

; ------------------------------------------------------------------------------