
; +-------------------------------------------------------------------------+
; |                                                                         |
; |                            FINAL FANTASY IV                             |
; |                                                                         |
; +-------------------------------------------------------------------------+
; | file: sound.asm                                                         |
; |                                                                         |
; | description: s-cpu sound routines                                       |
; |                                                                         |
; | created: 4/21/2022                                                      |
; |                                                                         |
; | author: everything8215@gmail.com                                        |
; +-------------------------------------------------------------------------+

.p816

.include "const.inc"
.include "hardware.inc"
.include "macros.inc"

.include "sound_data.asm"

.export InitSound_ext, ExecSound_ext

; ------------------------------------------------------------------------------

.segment "sound_code"

InitSound_ext:
@8000:  jsr     InitSound
        rtl

ExecSound_ext:
@8003:  jsr     ExecSound
        rtl

; ------------------------------------------------------------------------------

; [ init sound/music ]

InitSound:
@8088:  phb
        phd
        php
        longa
        longi
        pha
        phx
        phy
        shorta
        lda     #$04
        pha
        plb
        ldx     #$1e00
        phx
        pld
        shorta
        ldx     #0
@8022:  stz     $1e00,x
        inx
        cpx     #$0200
        bne     @8022
        longa
        lda     #$bbaa
@8030:  cmp     hAPUIO0
        bne     @8030
        shorta
        ldx     #0
        lda     SPCData+1,x
        xba
        lda     SPCData,x
        longa
        tay
        shorta
        inx2
        lda     SPCData,x
        sta     hAPUIO2
        lda     SPCData+1,x
        sta     hAPUIO3
        lda     #$01
        sta     hAPUIO1
        inx2
        lda     #$cc
        sta     hAPUIO0
@8060:  cmp     hAPUIO0
        bne     @8060
        stz     $08
@8067:  lda     SPCData,x
        sta     hAPUIO1
        lda     $08
        sta     hAPUIO0
        inc     $08
@8074:  cmp     hAPUIO0
        bne     @8074
        inx
        dey
        bne     @8067
        inc     $08
        inc     $08
        inc     $08
        longa
        lda     SPCData,x
        inx2
        tay
        beq     @80b0
        shorta
        lda     SPCData,x
        sta     hAPUIO2
        lda     SPCData+1,x
        sta     hAPUIO3
        lda     #$01
        sta     hAPUIO1
        inx2
        lda     $08
        sta     hAPUIO0
@80a7:  cmp     hAPUIO0
        bne     @80a7
        stz     $08
        bra     @8067
@80b0:  shorta
        lda     SPCData,x
        sta     hAPUIO2
        lda     SPCData+1,x
        sta     hAPUIO3
        lda     #$00
        sta     hAPUIO1
        lda     $08
        sta     hAPUIO0
@80c8:  cmp     hAPUIO0
        bne     @80c8
        stz     hAPUIO0
        shorta
        ldx     #0
@80d5:  stz     $40,x
        stz     $60,x
        stz     $80,x
        inx
        cpx     #$0020
        bne     @80d5
        stz     $00
        stz     $01
        stz     $02
        stz     $03
        stz     $04
        stz     $05
        stz     $06
        stz     $07
        ldx     #$3000
        stx     $60
        ldx     #$0800
@80f9:  dex
        bne     @80f9
        longi
        ply
        plx
        longa
        pla
        plp
        pld
        plb
        rts

; ------------------------------------------------------------------------------

; [ execute sound command ]

ExecSound:
@8107:  phb
        phd
        php
        longa
        longi
        pha
        phx
        phy
        shorta
        lda     #$04
        pha
        plb
        ldx     #$1e00
        phx
        pld
        shorta
        lda     $00
        beq     @815a
        cmp     #$01
        bne     @812b
        jsr     PlaySong
        bra     @815a
@812b:  cmp     #$02
        bne     @8134
        jsr     PlayGameSfx
        bra     @815a
@8134:  cmp     #$03
        bne     @813d
        jsr     PlaySong
        bra     @815a
@813d:  cmp     #$04
        bne     @8146
        jsr     PlaySong
        bra     @815a
@8146:  cmp     #$10
        bcc     @8153
        cmp     #$1f
        bcs     @8153
        jsr     PlaySystemSfx
        bra     @815a
@8153:  cmp     #$80
        bcc     @815a
        jsr     ExecInterrupt
@815a:  shorta
        stz     $00
        stz     $01
        stz     $02
        stz     $03
        longi
        ply
        plx
        longa
        pla
        plp
        pld
        plb
        rts

; ------------------------------------------------------------------------------

; [ play song ]

PlaySong:
@816f:  shorta
        sta     $08
        sta     $04
        lda     #$00
        xba
        lda     $01
        cmp     $05
        bne     @817f                   ; branch if song isn't playing
        rts
@817f:  shorta
        sta     $05
        sta     hWRMPYA                 ; multiply by 3
        lda     #3
        sta     hWRMPYB
        lda     .loword(SongScriptPtrsOffset)
        sta     $20
        lda     .loword(SongScriptPtrsOffset)+1
        sta     $21
        lda     .loword(SongScriptPtrsOffset)+2
        sta     $22
        jsr     AddPtrOffset
        lda     $20
        sta     $10
        lda     $21
        sta     $11
        lda     $22
        sta     $12
        lda     $22
        sta     $12
        longa
        lda     $20
        clc
        adc     hRDMPYL
        bcc     @81bc
        inc     $12
        sbc     #$8000
@81bc:  sta     $10
        shorta
        lda     [$10]       ; pointer to song script
        sta     $20
        ldy     $10
        iny
        bne     @81ce
        inc     $12
        ldy     #$8000
@81ce:  sty     $10
        lda     [$10]
        sta     $21
        ldy     $10
        iny
        bne     @81de
        inc     $12
        ldy     #$8000
@81de:  sty     $10
        lda     [$10]
        sta     $22
        jsr     AddPtrOffset
        lda     $20
        sta     $10
        lda     $21
        sta     $11
        lda     $22
        sta     $12
        lda     [$10]       ; song script length
        xba
        ldy     $10
        iny
        bne     @8200
        inc     $12
        ldy     #$8000
@8200:  sty     $10
        lda     [$10]
        xba
        ldy     $10
        iny
        bne     @820f
        inc     $12
        ldy     #$8000
@820f:  sty     $10
        longa
        tax
        shorta
@8216:  lda     [$10]       ; transfer song script to spc
        sta     hAPUIO2
        lda     $08
        sta     hAPUIO0
        ldy     $10
        iny
        bne     @822a
        inc     $12
        ldy     #$8000
@822a:  sty     $10
        inc     $08
        bne     @8232
        inc     $08
@8232:  cmp     hAPUIO0
        bne     @8232
        dex
        bne     @8216
        lda     .loword(SongSamplesOffset)
        sta     $20
        lda     .loword(SongSamplesOffset)+1
        sta     $21
        lda     .loword(SongSamplesOffset)+2
        sta     $22
        jsr     AddPtrOffset
        lda     $20
        sta     $10
        lda     $21
        sta     $11
        lda     $22
        sta     $12
        lda     #$00
        xba
        lda     $01
        longa
        asl5
        clc
        adc     $10
        bcc     @826e
        inc     $12
        sbc     #$8000
@826e:  sta     $10
        ldx     #0
        shorta
@8275:  lda     [$10]       ; samples used
        sta     $c0,x
        sta     $e0,x
        ldy     $10
        iny
        bne     @8285
        inc     $12
        ldy     #$8000
@8285:  sty     $10
        lda     [$10]
        sta     $c1,x
        sta     $e1,x
        ldy     $10
        iny
        bne     @8297
        inc     $12
        ldy     #$8000
@8297:  sty     $10
        lda     #$00
        sta     $a0,x
        sta     $a1,x
        inx2
        cpx     #$0020
        bne     @8275
        ldy     #0
        longa
@82ab:  lda     $1e40,y
        beq     @82cf
        ldx     #0
@82b3:  cmp     $e0,x
        beq     @82c0
        inx2
        cpx     #$0020
        bne     @82b3
        bra     @82c8
@82c0:  sta     $1ea0,y
        lda     #0
        sta     $e0,x
@82c8:  iny2
        cpy     #$0020
        bne     @82ab
@82cf:  lda     #0
        sta     hAPUIO1
        tya
        beq     @8302
        ldx     #0
        lda     #0
        clc
@82df:  adc     $e0,x
        inx2
        cpx     #$0020
        bne     @82df
        tax
        bne     @8319
        shorta
        lda     #$ff        ; no transfer needed
        sta     hAPUIO1
        lda     #$00
        sta     hAPUIO0
@82f7:  cmp     hAPUIO0
        bne     @82f7
        inc
        sta     $08
        jmp     @84ca
@8302:  shorta
        lda     #$11
        sta     hAPUIO1
        lda     #$00
        sta     hAPUIO0
@830e:  cmp     hAPUIO0
        bne     @830e
        inc
        sta     $08
        jmp     @83a3
@8319:  longa
        stz     $08
        ldx     #0
@8320:  lda     $a0,x
        beq     @832e
        inx2
        cpx     #$0020
        bne     @8320
        jmp     @83a3
@832e:  txy
        inx2
@8331:  lda     $a0,x
        bne     @8344
@8335:  inx2
        cpx     #$0020
        bne     @8331
        lda     $1e60,y
        sta     hAPUIO2
        bra     @8390
@8344:  sta     $1e40,y
        lda     $60,x
        sta     hAPUIO2
        lda     $08
        sta     hAPUIO0
        inc     $08
@8353:  cmp     hAPUIO0
        bne     @8353
        lda     $80,x
        sta     $1e80,y
        clc
        adc     $1e60,y
        sta     $1e62,y
        lda     $1e60,y
        sta     hAPUIO2
        lda     $08
        sta     hAPUIO0
        inc     $08
@8371:  cmp     hAPUIO0
        bne     @8371
        lda     $80,x
        sta     hAPUIO2
        lda     $08
        sta     hAPUIO0
        inc     $08
@8382:  cmp     hAPUIO0
        bne     @8382
        iny2
        lda     #0
        sta     $a0,x
        bra     @8335
@8390:  shorta
        lda     #$22
        sta     hAPUIO1
        lda     $08
        sta     hAPUIO0
        inc     $08
@839e:  cmp     hAPUIO0
        bne     @839e
@83a3:  shorta
        sty     $0a
        lda     .loword(BRRSamplePtrsOffset)
        sta     $20
        lda     .loword(BRRSamplePtrsOffset)+1
        sta     $21
        lda     .loword(BRRSamplePtrsOffset)+2
        sta     $22
        jsr     AddPtrOffset
        lda     $20
        sta     $10
        lda     $21
        sta     $11
        lda     $22
        sta     $12
        ldy     #0

; start of sample transfer loop
@83c8:  longa
        lda     $1ee0,y
        bne     @83d9       ; branch if sample is used
        iny2
        cpy     #$0020
        bcc     @83c8
        jmp     @84b6
@83d9:  iny2
        phy
        sta     $28
        shorta
        sta     hWRMPYA
        lda     #3
        sta     hWRMPYB
        lda     $12
        sta     $15
        longa
        lda     $10
        clc
        adc     hRDMPYL                 ; sample id * 3
        bcc     @83fb
        inc     $15
        sbc     #$8000
@83fb:  sta     $13
        shorta
        lda     [$13]
        sta     $20
        ldy     $13
        iny
        bne     @840d
        inc     $15
        ldy     #$8000
@840d:  sty     $13
        lda     [$13]
        sta     $21
        ldy     $13
        iny
        bne     @841d
        inc     $15
        ldy     #$8000
@841d:  sty     $13
        lda     [$13]
        sta     $22
        jsr     AddPtrOffset
        lda     $20
        sta     $18
        lda     $21
        sta     $19
        lda     $22
        sta     $1a
        lda     [$18]
        xba
        ldy     $18
        iny
        bne     @843f
        inc     $1a
        ldy     #$8000
@843f:  sty     $18
        lda     [$18]
        xba
        ldy     $18
        iny
        bne     @844e
        inc     $1a
        ldy     #$8000
@844e:  sty     $18
        longa
        tax
        ldy     $0a
        sta     $1e80,y
        clc
        adc     $1e60,y
        sta     $1e62,y
        lda     $28
        sta     $1e40,y
        iny2
        sty     $0a
        shorta
@846a:  lda     [$18]       ; transfer sample brr data to spc
        sta     hAPUIO1
        ldy     $18
        iny
        bne     @8479
        inc     $1a
        ldy     #$8000
@8479:  sty     $18
        lda     [$18]
        sta     hAPUIO2
        ldy     $18
        iny
        bne     @848a
        inc     $1a
        ldy     #$8000
@848a:  sty     $18
        lda     [$18]
        sta     hAPUIO3
        ldy     $18
        iny
        bne     @849b
        inc     $1a
        ldy     #$8000
@849b:  sty     $18
        lda     $08
        sta     hAPUIO0
        inc     $08
        bne     @84a8
        inc     $08
@84a8:  cmp     hAPUIO0
        bne     @84a8
        dex3
        bne     @846a
        ply
        jmp     @83c8
@84b6:  ldx     $0a
        longa
        lda     #0
        bra     @84c3
@84bf:  sta     $40,x
        inx2
@84c3:  cpx     #$0020
        bne     @84bf
        stz     $08
@84ca:  shorta
        lda     .loword(SampleLoopStartOffset)
        sta     $20
        lda     .loword(SampleLoopStartOffset)+1
        sta     $21
        lda     .loword(SampleLoopStartOffset)+2
        sta     $22
        jsr     AddPtrOffset
        lda     $20
        sta     $10
        lda     $21
        sta     $11
        lda     $22
        sta     $12
        ldy     #0

; start of sample pointer transfer loop
@84ed:  longa
        lda     $1ec0,y
        bne     @84f7
        jmp     @857c
@84f7:  phy
        ldx     $11
        stx     $19
        ldx     #0
@84ff:  cmp     $40,x
        beq     @8507
        inx2
        bra     @84ff
@8507:  asl2
        clc
        adc     $10
        bcc     @8513
        inc     $1a
        sbc     #$8000
@8513:  sta     $18
        shorta
        lda     [$18]       ; sample start (always zero)
        xba
        ldy     $18
        iny
        bne     @8524
        inc     $1a
        ldy     #$8000
@8524:  sty     $18
        lda     [$18]
        xba
        ldy     $18
        iny
        bne     @8533
        inc     $1a
        ldy     #$8000
@8533:  sty     $18
        longa
        clc
        adc     $60,x       ; add to sample offset
        sta     hAPUIO2       ; transfer sample pointers to spc
        lda     $08
        sta     hAPUIO0
        inc     $08
@8544:  cmp     hAPUIO0
        bne     @8544
        shorta
        lda     [$18]       ; loop start
        xba
        ldy     $18
        iny
        bne     @8558
        inc     $1a
        ldy     #$8000
@8558:  sty     $18
        lda     [$18]
        xba
        longa
        clc
        adc     $60,x
        sta     hAPUIO2
        lda     $08
        sta     hAPUIO0
        inc     $08
@856c:  cmp     hAPUIO0
        bne     @856c
        ply
        iny2
        cpy     #$0020
        beq     @857c
        jmp     @84ed
@857c:  stz     $08
        shorta
        lda     .loword(SampleFreqMultOffset)
        sta     $20
        lda     .loword(SampleFreqMultOffset)+1
        sta     $21
        lda     .loword(SampleFreqMultOffset)+2
        sta     $22
        jsr     AddPtrOffset
        lda     $20
        sta     $10
        lda     $21
        sta     $11
        lda     $22
        sta     $12
        ldx     #0
        longa

; start of frequency multiplier transfer loop
@85a3:  lda     $11
        sta     $19
        lda     $1ec0,x
        beq     @85d0
        clc
        adc     $10
        bcc     @85b6
        inc     $1a
        sbc     #$8000
@85b6:  sta     $18
        lda     [$18]       ; transfer sample frequency multipliers to spc
        sta     hAPUIO2
        lda     $08
        sta     hAPUIO0
        inc     $08
@85c4:  cmp     hAPUIO0
        bne     @85c4
        inx2
        cpx     #$0020
        bne     @85a3
@85d0:  lda     $08
        sta     hAPUIO0
@85d5:  cmp     hAPUIO0
        bne     @85d5
        lda     #0
        sta     hAPUIO0
        rts

; ------------------------------------------------------------------------------

; [ play game sound effect ]

PlayGameSfx:
@85e1:  shorta
        lda     $03
        sta     hAPUIO3
        lda     $02
        sta     hAPUIO2
        lda     $01
        sta     hAPUIO1
        lda     $00
        sta     hAPUIO0
@85f7:  cmp     hAPUIO0
        bne     @85f7
        stz     hAPUIO0
        stz     $00
        stz     $01
        stz     $02
        stz     $03
        rts

; ------------------------------------------------------------------------------

; [ play system sound effect ]

PlaySystemSfx:
@8608:  shorta
        sta     hAPUIO0
@860d:  cmp     hAPUIO0
        bne     @860d
        stz     hAPUIO0
        stz     $00
        stz     $01
        stz     $02
        stz     $03
        rts

; ------------------------------------------------------------------------------

; [ sound interrupt ]

ExecInterrupt:
@861e:  shorta
        lda     $01
        sta     hAPUIO1
        lda     $02
        sta     hAPUIO2
        lda     $03
        sta     hAPUIO3
        lda     $00
        sta     hAPUIO0
@8634:  cmp     hAPUIO0
        bne     @8634
        stz     hAPUIO0
        stz     hAPUIO1
        stz     hAPUIO2
        stz     hAPUIO3
        stz     $00
        stz     $01
        stz     $02
        stz     $03
        rts

; ------------------------------------------------------------------------------

; [ add pointer offset ]

AddPtrOffset:
@864e:  php
        longa
        lda     $21
        cmp     #$0040
        bcs     @865d
        adc     #SoundData>>8
        bra     @867f
@865d:  cmp     #$00c0
        bcs     @8667
        adc     #(SoundData>>8)+$80
        bra     @867f
@8667:  cmp     #$0140
        bcs     @8671
        adc     #(SoundData>>8)+$100
        bra     @867f
@8671:  cmp     #$01c0
        bcs     @867b
        adc     #(SoundData>>8)+$180
        bra     @867f
@867b:  clc
        adc     #(SoundData>>8)+$200
@867f:  sta     $21
        plp
        rts

; ------------------------------------------------------------------------------

        .include "data/spc_data.asm"

; ------------------------------------------------------------------------------
