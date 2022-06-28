
; +----------------------------------------------------------------------------+
; |                                                                            |
; |                              FINAL FANTASY IV                              |
; |                                                                            |
; +----------------------------------------------------------------------------+
; | file: monster_death.asm                                                    |
; |                                                                            |
; | description: monster death routines                                        |
; |                                                                            |
; | created: 4/21/2022                                                         |
; +----------------------------------------------------------------------------+

; [ load monster death pal (near) ]

LoadMonsterDeathPal_near:
@e8d8:  jsl     LoadMonsterDeathPal
        rts

; ------------------------------------------------------------------------------

; [  ]

_02e8dd:
@e8dd:  jsl     _03f555
        rts

; ------------------------------------------------------------------------------

; [  ]

_02e8e2:
@e8e2:  jsl     _03f56a
        rts

; ------------------------------------------------------------------------------

; [  ]

_02e8e7:
@e8e7:  tax
        lda     #$ff
        sta     $f123,x
        jsr     _02e8dd
        jsr     LoadMonsterTiles
        jsr     _02e8e2
        jmp     TfrRightMonsterTiles

; ------------------------------------------------------------------------------

; [ battle graphics $10: monster death animations ]

MonsterDeath:
@e8f9:  lda     $f49a
        cmp     #$8c
        bne     @e906
        sta     $f483
        stz     $f49a
@e906:  lda     $f473
        bne     @e91e
        clr_ax
@e90d:  lda     $29b5,x
        cmp     $f123,x
        bne     @e91e
        inx
        cpx     #8
        bne     @e90d
        jmp     @e9a5                   ; return if no monsters died
@e91e:  lda     $38e6
        cmp     #$03
        bne     @e928
        jmp     @e9a5
@e928:  lda     $29a4
        and     #$10
        beq     @e940
        lda     $38e6
        bne     @e940
        jsr     _02c46d
        jsr     _02e8dd
        jsl     _03f418
        bra     @e960
@e940:  jsr     _02e8dd
        jsr     UpdateBG1Tiles
        ldy     $1800
        cpy     #$01b7
        bne     @e969
        lda     $38e6
        bne     @e969
        inc     $f4a1
        jsr     LoadMonsterTiles
        jsr     TfrRightMonsterTiles
        jsl     _03f591
@e960:  jsr     _02e8e2
        clr_a
        jsr     PlaySfx
        bra     @e9a5
@e969:  clr_ax
@e96b:  lda     $29b5,x
        cmp     $f12b,x
        beq     @e981
        phx
        txa
        sta     $f109
        lda     #$07
        sta     $f10a
        jsr     _028a89
        plx
@e981:  inx
        cpx     #8
        bne     @e96b
        jsr     ModifyBG1Tiles_near
        jsr     _02e8e2
        jsr     TfrLeftMonsterTiles
        jsr     LoadMonsterDeathPal_near
        lda     #1
        jsr     SwapMonsterScreen
        jsr     LoadMonsterTiles
        jsr     TfrRightMonsterTiles
        jsr     MonsterDeathAnim
        clr_a
        jsr     SwapMonsterScreen
@e9a5:  stz     $f483
        rts

; ------------------------------------------------------------------------------

; [ monster death animation ]

MonsterDeathAnim:
@e9a9:  lda     $f483
        bne     @e9be
        lda     #$80
        sta     $f485
        lda     $38e6
        tax
        lda     f:MonsterDeathSfxTbl,x
        jsr     PlaySfx
@e9be:  stz     $f483
        jsr     WaitFrame
        clr_ax
@e9c6:  lda     $ee30,x
        sta     $00
        lda     $ee31,x
        sta     $01
        lda     #1
        jsr     DecColor
        lda     $00
        sta     $ee30,x
        lda     $01
        sta     $ee31,x
        inx2
        cpx     #$0020
        bne     @e9c6
        jsl     UpdateMonsterDeathAnim
        inc     $4e
        lda     $4e
        cmp     #$30
        bne     @e9be
        rts

; ------------------------------------------------------------------------------
