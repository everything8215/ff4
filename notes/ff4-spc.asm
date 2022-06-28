
; +-------------------------------------------------------------------------+
; |                                                                         |
; |                            FINAL FANTASY IV                             |
; |                                                                         |
; +-------------------------------------------------------------------------+
; | file: ff4-spc.asm                                                       |
; |                                                                         |
; | description: sound program disassembly                                  |
; |                                                                         |
; | created: 2/7/2022                                                       |
; |                                                                         |
; | author: everything8215@gmail.com                                        |
; +-------------------------------------------------------------------------+

; --------------------------------------------------------------------------

; [ program start ]

0800: 20        CLRP  
0801: C0        DI    
0802: CD CF     MOV   X, #$CF         ; set stack pointer
0804: BD        MOV   SP, X
0805: E8 00     MOV   A, #$00         ; clear $00-$DF
0807: 5D        MOV   X, A
0808: AF        MOV   (X)+, A
0809: C8 E0     CMP   X, #$E0
080B: D0 FB     BNE   $0808
080D: A2 8A     SET   $8A.5           ; disable echo
080F: 8F 01 7A  MOV   $7A, #$01       ; echo delay: 16ms
0812: 3F 82 10  CALL  $1082           ; set echo delay
0815: E8 00     MOV   A, #$00
0817: 8D 0C     MOV   Y, #$0C         ; main volume left
0819: 3F E9 10  CALL  $10E9           ; set dsp register
081C: 8D 1C     MOV   Y, #$1C         ; main volume right
081E: 3F E9 10  CALL  $10E9           ; set dsp register
0821: 8D 2D     MOV   Y, #$2D         ; pitch modulation
0823: 3F E9 10  CALL  $10E9           ; set dsp register
0826: 8D 3D     MOV   Y, #$3D         ; noise enable
0828: 3F E9 10  CALL  $10E9           ; set dsp register
082B: E8 1E     MOV   A, #$1E
082D: 8D 5D     MOV   Y, #$5D         ; sample pointer
082F: 3F E9 10  CALL  $10E9           ; set dsp register
0832: E8 F0     MOV   A, #$F0         ; clear ports, stop timers
0834: C4 F1     MOV   $F1, A          ; control register
0836: E8 24     MOV   A, #$24         ; 3ms (cycle interval)
0838: C4 FA     MOV   $FA, A          ; set timer 0
083A: E8 80     MOV   A, #$80         ; 16ms (echo delay interval)
083C: C4 FB     MOV   $FB, A          ; set timer 1
083E: E8 03     MOV   A, #$03         ; start timers 0 and 1
0840: C4 F1     MOV   $F1, A
0842: E8 40     MOV   A, #$40
0844: 8D 0C     MOV   Y, #$0C         ; main volume left
0846: 3F E9 10  CALL  $10E9           ; set dsp register
0849: 8D 1C     MOV   Y, #$1C         ; main volume right
084B: 3F E9 10  CALL  $10E9           ; set dsp register
084E: E8 00     MOV   A, #$00
0850: C5 01 02  MOV   $0201, A
0853: E8 00     MOV   A, #$00
0855: C4 02     MOV   $02, A
0857: E8 19     MOV   A, #$19
0859: C4 03     MOV   $03, A
085B: E8 FF     MOV   A, #$FF
085D: C4 37     MOV   $37, A
085F: C4 38     MOV   $38, A
; start of main loop
0861: E3 7B 07  BBS   $7B.7, $086B    ; branch if waiting for echo buffer to clear
0864: E4 8A     MOV   A, $8A
0866: 8D 6C     MOV   Y, #$6C         ; dsp flags
0868: 3F E9 10  CALL  $10E9           ; set dsp register
086B: 69 7A 7B  CMP   $7B, $7A
086E: F0 08     BEQ   $0878           ; branch if echo buffer is sync'd
0870: EB FE     MOV   Y, $FE
0872: F0 FC     BEQ   $0870           ; wait for counter 1
0874: AB 7B     INC   $7B
0876: 2F E9     BRA   $0861
0878: E4 40     MOV   A, $40          ; echo volume
087A: 5C        LSR   A
087B: 8D 2C     MOV   Y, #$2C         ; echo volume left
087D: 3F E9 10  CALL  $10E9           ; set dsp register
0880: 8D 3C     MOV   Y, #$3C         ; echo volume right
0882: 3F E9 10  CALL  $10E9           ; set dsp register
0885: E4 79     MOV   A, $79
0887: 8D 0D     MOV   Y, #$0D         ; echo feedback
0889: 3F E9 10  CALL  $10E9           ; set dsp register
088C: E4 7E     MOV   A, $7E
088E: 8D 4D     MOV   Y, #$4D         ; echo enable
0890: 3F E9 10  CALL  $10E9           ; set dsp register
0893: E4 FD     MOV   A, $FD          ; counter 0
0895: 0D        PUSH  PSW
0896: 3F C2 13  CALL  $13C2           ; check interrupts
0899: 8E        POP   PSW
089A: F0 F7     BEQ   $0893           ; wait for counter 0
089C: E4 89     MOV   A, $89
089E: 8D 5C     MOV   Y, #$5C         ; key off
08A0: 3F E9 10  CALL  $10E9           ; set dsp register
08A3: E4 88     MOV   A, $88
08A5: 8D 4C     MOV   Y, #$4C         ; key on
08A7: 3F E9 10  CALL  $10E9           ; set dsp register
08AA: 8F 00 88  MOV   $88, #$00       ; clear key off and on
08AD: 8F 00 89  MOV   $89, #$00
08B0: FA 43 28  MOV   $28, $43
08B3: 60        CLRC  
08B4: BA 46     MOVW  YA, $46
08B6: F0 31     BEQ   $08E9           ; branch if no volume fade
08B8: 30 0C     BMI   $08C6           ; branch if fading out
; fade to full volume
08BA: 7A 42     ADDW  YA, $42         ; add volume fade rate
08BC: 90 22     BCC   $08E0           ; branch if no overflow
08BE: BA 00     MOVW  YA, $00         ; disable volume fade
08C0: DA 46     MOVW  $46, YA
08C2: 9C        DEC   A               ; set volume to max
08C3: DC        DEC   Y
08C4: 2F 1A     BRA   $08E0
; fade out
08C6: 68 A0     CMP   A, #$A0
08C8: B0 0A     BCS   $08D4           ; branch if fading to half volume
; fade to zero volume
08CA: 7A 42     ADDW  YA, $42
08CC: B0 12     BCS   $08E0
08CE: BA 00     MOVW  YA, $00         ; set song volume rate to zero
08D0: DA 46     MOVW  $46, YA
08D2: 2F 0C     BRA   $08E0
; fade to half volume
08D4: 7A 42     ADDW  YA, $42
08D6: AD 80     CMP   Y, #$80
08D8: B0 06     BCS   $08E0
08DA: BA 00     MOVW  YA, $00         ; set song volume rate to zero
08DC: DA 46     MOVW  $46, YA
08DE: 8D 80     MOV   Y, #$80         ; half volume
08E0: DA 42     MOVW  $42, YA         ; set song volume
08E2: 7E 28     CMP   Y, $28
08E4: F0 03     BEQ   $08E9
08E6: 8F FF 8B  MOV   $8B, #$FF       ; enable dsp volume update in all channels
08E9: 3F EF 08  CALL  $08EF           ; update channels
08EC: 5F 61 08  JMP   $0861

; [ update channels ]

08EF: E4 37     MOV   A, $37
08F1: 60        CLRC  
08F2: 84 38     ADC   A, $38
08F4: C4 38     MOV   $38, A
08F6: 90 6F     BCC   $0967           ; branch if no song tick
08F8: CD 00     MOV   X, #$00
08FA: 8F 01 8D  MOV   $8D, #$01
; start of song channel loop
08FD: F4 03     MOV   A, $03+X
08FF: F0 52     BEQ   $0953           ; branch if channel is inactive
0901: D8 27     MOV   $27, X
0903: 9B 48     DEC   $48+X
0905: D0 03     BNE   $090A
0907: 3F CD 09  CALL  $09CD           ; execute channel script
090A: E4 8D     MOV   A, $8D
090C: 24 78     AND   A, $78
090E: D0 40     BNE   $0950
0910: F5 01 03  MOV   A, $0301+X
0913: F0 22     BEQ   $0937
0915: F4 68     MOV   A, $68+X        ; decrement sustain counter
0917: FB 69     MOV   Y, $69+X
0919: DA 28     MOVW  $28, YA
091B: 1A 28     DECW  $28
091D: BA 28     MOVW  YA, $28
091F: D4 68     MOV   $68+X, A
0921: DB 69     MOV   $69+X, Y
0923: D0 12     BNE   $0937           ; branch if still sustaining note
0925: 7D        MOV   A, X
0926: 9F        XCN   A
0927: 5C        LSR   A
0928: 08 07     OR    A, #$07         ; channel gain
092A: FD        MOV   Y, A
092B: E8 B1     MOV   A, #$B1         ; exponential decay
092D: 3F E9 10  CALL  $10E9           ; set dsp register
0930: DC        DEC   Y
0931: DC        DEC   Y
0932: E8 00     MOV   A, #$00         ; disable adsr
0934: 3F E9 10  CALL  $10E9           ; set dsp register
0937: E8 01     MOV   A, #$01
0939: DE 48 14  CBNE  $48+X, $0950
093C: F4 02     MOV   A, $02+X        ; get channel script pointer
093E: FB 03     MOV   Y, $03+X
0940: DA 22     MOVW  $22, YA
0942: 3F 90 0C  CALL  $0C90           ; get next note
0945: 68 C3     CMP   A, #$C3
0947: 90 04     BCC   $094D           ; branch if a note or tie
0949: 68 D2     CMP   A, #$D2
094B: 90 03     BCC   $0950           ; branch if not a command
094D: 09 8D 89  OR    $89, $8D        ; set key off (rest)
0950: 3F EE 10  CALL  $10EE           ; update channel envelopes
0953: 3D        INC   X
0954: 3D        INC   X
0955: 0B 8D     ASL   $8D
0957: D0 A4     BNE   $08FD
0959: BA 3A     MOVW  YA, $3A
095B: F0 1E     BEQ   $097B
095D: 1A 3A     DECW  $3A
095F: BA 36     MOVW  YA, $36
0961: 7A 3C     ADDW  YA, $3C
0963: DA 36     MOVW  $36, YA
0965: 2F 14     BRA   $097B
0967: CD 00     MOV   X, #$00
0969: 8F 01 8D  MOV   $8D, #$01
096C: F4 03     MOV   A, $03+X
096E: F0 05     BEQ   $0975
0970: D8 27     MOV   $27, X
0972: 3F D0 11  CALL  $11D0           ; update volume and frequency
0975: 3D        INC   X
0976: 3D        INC   X
0977: 0B 8D     ASL   $8D
0979: D0 F1     BNE   $096C
097B: E8 78     MOV   A, #$78         ; sound effect tempo is 120
097D: 60        CLRC  
097E: 84 39     ADC   A, $39
0980: C4 39     MOV   $39, A
0982: 90 34     BCC   $09B8           ; branch if no sound effect tick
0984: CD 1A     MOV   X, #$1A
0986: 8F 20 8D  MOV   $8D, #$20
; start of sound effect channel loop
0989: F4 03     MOV   A, $03+X
098B: F0 25     BEQ   $09B2           ; branch if channel is inactive
098D: D8 27     MOV   $27, X
098F: 9B 48     DEC   $48+X
0991: D0 03     BNE   $0996
0993: 3F CD 09  CALL  $09CD           ; execute channel script
0996: E8 01     MOV   A, #$01
0998: DE 48 14  CBNE  $48+X, $09AF
099B: F4 02     MOV   A, $02+X
099D: FB 03     MOV   Y, $03+X
099F: DA 22     MOVW  $22, YA
09A1: 3F 90 0C  CALL  $0C90           ; get next note
09A4: 68 C3     CMP   A, #$C3
09A6: 90 04     BCC   $09AC
09A8: 68 D2     CMP   A, #$D2
09AA: 90 03     BCC   $09AF
09AC: 09 8D 89  OR    $89, $8D
09AF: 3F 22 11  CALL  $1122           ; update channel envelopes
09B2: 3D        INC   X
09B3: 3D        INC   X
09B4: 0B 8D     ASL   $8D
09B6: D0 D1     BNE   $0989
09B8: CD 1A     MOV   X, #$1A
09BA: 8F 20 8D  MOV   $8D, #$20
09BD: F4 03     MOV   A, $03+X
09BF: F0 05     BEQ   $09C6
09C1: D8 27     MOV   $27, X
09C3: 3F D0 11  CALL  $11D0           ; update volume and frequency
09C6: 3D        INC   X
09C7: 3D        INC   X
09C8: 0B 8D     ASL   $8D
09CA: D0 F1     BNE   $09BD
09CC: 6F        RET   

; [ execute channel script ]

09CD: 3F 85 0C  CALL  $0C85           ; get next script byte
09D0: 68 D2     CMP   A, #$D2
09D2: 90 05     BCC   $09D9
09D4: 3F 70 0C  CALL  $0C70           ; execute script command
09D7: 2F F4     BRA   $09CD
; note
09D9: 8D 00     MOV   Y, #$00
09DB: CD 0F     MOV   X, #$0F
09DD: 9E        DIV   YA, X
09DE: F8 27     MOV   X, $27
09E0: C4 26     MOV   $26, A
09E2: F6 B1 18  MOV   A, $18B1+Y      ; note duration
09E5: D4 48     MOV   $48+X, A
09E7: C4 28     MOV   $28, A
09E9: 8F 00 29  MOV   $29, #$00
09EC: 78 0C 26  CMP   $26, #$0C
09EF: B0 0A     BCS   $09FB           ; return if a tie
09F1: C8 10     CMP   X, #$10
09F3: B0 46     BCS   $0A3B           ; branch if a sound effect
09F5: E4 8D     MOV   A, $8D
09F7: 24 78     AND   A, $78
09F9: F0 01     BEQ   $09FC           ; branch if no sound effect in this channel
09FB: 6F        RET   
; play note (song channel)
09FC: F4 02     MOV   A, $02+X
09FE: FB 03     MOV   Y, $03+X
0A00: DA 22     MOVW  $22, YA
0A02: 3F 90 0C  CALL  $0C90           ; get next note
0A05: 68 C3     CMP   A, #$C3
0A07: 90 16     BCC   $0A1F           ; branch if not a tie
0A09: 68 D2     CMP   A, #$D2
0A0B: B0 12     BCS   $0A1F
0A0D: CD 0F     MOV   X, #$0F
0A0F: 8D 00     MOV   Y, #$00
0A11: 9E        DIV   YA, X
0A12: F8 27     MOV   X, $27
0A14: F6 B1 18  MOV   A, $18B1+Y      ; tie duration
0A17: 8D 00     MOV   Y, #$00
0A19: 7A 28     ADDW  YA, $28         ; add to note duration
0A1B: DA 28     MOVW  $28, YA
0A1D: 2F E3     BRA   $0A02
0A1F: F5 01 03  MOV   A, $0301+X      ; channel sustain
0A22: D0 04     BNE   $0A28
0A24: BA 28     MOVW  YA, $28         ; if zero, sustain for full note duration
0A26: 2F 0F     BRA   $0A37
0A28: 2D        PUSH  A
0A29: EB 29     MOV   Y, $29
0A2B: CF        MUL   YA
0A2C: DA 2A     MOVW  $2A, YA
0A2E: AE        POP   A
0A2F: EB 28     MOV   Y, $28
0A31: CF        MUL   YA
0A32: DD        MOV   A, Y
0A33: 8D 00     MOV   Y, #$00
0A35: 7A 2A     ADDW  YA, $2A
0A37: D4 68     MOV   $68+X, A        ; set sustain counter
0A39: DB 69     MOV   $69+X, Y
; sound effect channel jumps here
0A3B: 8F 00 2C  MOV   $2C, #$00
0A3E: F5 C0 02  MOV   A, $02C0+X      ; octave
0A41: 8D 0C     MOV   Y, #$0C
0A43: CF        MUL   YA
0A44: 60        CLRC  
0A45: 84 26     ADC   A, $26
0A47: C4 8E     MOV   $8E, A
0A49: 80        SETC  
0A4A: A8 0A     SBC   A, #$0A
0A4C: 10 05     BPL   $0A53
0A4E: 60        CLRC  
0A4F: AB 2C     INC   $2C
0A51: 88 0C     ADC   A, #$0C
0A53: CD 0C     MOV   X, #$0C
0A55: 9E        DIV   YA, X
0A56: F8 27     MOV   X, $27
0A58: C4 2D     MOV   $2D, A
0A5A: DD        MOV   A, Y
0A5B: 1C        ASL   A
0A5C: FD        MOV   Y, A
0A5D: F6 77 18  MOV   A, $1877+Y      ; frequency value
0A60: C4 28     MOV   $28, A
0A62: F6 78 18  MOV   A, $1878+Y
0A65: C4 29     MOV   $29, A
0A67: E4 2C     MOV   A, $2C
0A69: F0 04     BEQ   $0A6F
0A6B: 4B 29     LSR   $29
0A6D: 6B 28     ROR   $28
0A6F: E8 04     MOV   A, #$04
0A71: 64 2D     CMP   A, $2D
0A73: B0 0F     BCS   $0A84
0A75: BC        INC   A
0A76: 0B 28     ASL   $28
0A78: 2B 29     ROL   $29
0A7A: 2E 2D F8  CBNE  $2D, $0A75
0A7D: 2F 08     BRA   $0A87
0A7F: 9C        DEC   A
0A80: 4B 29     LSR   $29
0A82: 6B 28     ROR   $28
0A84: 2E 2D F8  CBNE  $2D, $0A7F
0A87: F5 00 03  MOV   A, $0300+X      ; sample frequency multiplier
0A8A: 0D        PUSH  PSW
0A8B: 2D        PUSH  A
0A8C: EB 29     MOV   Y, $29
0A8E: CF        MUL   YA
0A8F: DA 2A     MOVW  $2A, YA
0A91: AE        POP   A
0A92: EB 28     MOV   Y, $28
0A94: CF        MUL   YA
0A95: DD        MOV   A, Y
0A96: 8D 00     MOV   Y, #$00
0A98: 7A 2A     ADDW  YA, $2A
0A9A: DA 2A     MOVW  $2A, YA
0A9C: 8E        POP   PSW
0A9D: 30 04     BMI   $0AA3
0A9F: 7A 28     ADDW  YA, $28
0AA1: DA 2A     MOVW  $2A, YA
0AA3: E4 2A     MOV   A, $2A
0AA5: D5 A0 02  MOV   $02A0+X, A      ; set frequency
0AA8: E4 2B     MOV   A, $2B
0AAA: D5 A1 02  MOV   $02A1+X, A
0AAD: 8F 0C 30  MOV   $30, #$0C       ; divide by 12
0AB0: 8F 00 31  MOV   $31, #$00
; pitch envelope
0AB3: F5 61 04  MOV   A, $0461+X      ; pitch envelope amplitude
0AB6: D0 03     BNE   $0ABB
0AB8: 5F B0 0B  JMP   $0BB0
0ABB: 0D        PUSH  PSW
0ABC: C8 10     CMP   X, #$10
0ABE: 90 5A     BCC   $0B1A           ; branch if not a sound effect
; sound effect pitch envelope
0AC0: 8E        POP   PSW
0AC1: 10 12     BPL   $0AD5           ; branch if positive amplitude
0AC3: 4B 2B     LSR   $2B
0AC5: 6B 2A     ROR   $2A
0AC7: 60        CLRC  
0AC8: 88 0C     ADC   A, #$0C
0ACA: 90 F7     BCC   $0AC3
0ACC: 2F 0B     BRA   $0AD9
0ACE: 0B 2A     ASL   $2A
0AD0: 2B 2B     ROL   $2B
0AD2: 80        SETC  
0AD3: A8 0C     SBC   A, #$0C
0AD5: 68 0C     CMP   A, #$0C
0AD7: B0 F5     BCS   $0ACE
0AD9: C4 2C     MOV   $2C, A
0ADB: FA 2A 32  MOV   $32, $2A
0ADE: FA 2B 33  MOV   $33, $2B
0AE1: 3F C7 10  CALL  $10C7           ; divide
0AE4: E4 32     MOV   A, $32
0AE6: EB 2C     MOV   Y, $2C
0AE8: CF        MUL   YA
0AE9: DA 28     MOVW  $28, YA
0AEB: E4 33     MOV   A, $33
0AED: EB 2C     MOV   Y, $2C
0AEF: CF        MUL   YA
0AF0: 8D 00     MOV   Y, #$00
0AF2: 7A 28     ADDW  YA, $28
0AF4: 7A 2A     ADDW  YA, $2A
0AF6: DA 28     MOVW  $28, YA
0AF8: F5 A1 02  MOV   A, $02A1+X      ; set initial frequency
0AFB: FD        MOV   Y, A
0AFC: F5 A0 02  MOV   A, $02A0+X
0AFF: 9A 28     SUBW  YA, $28
0B01: DA 28     MOVW  $28, YA
0B03: 10 08     BPL   $0B0D
0B05: 58 FF 28  EOR   $28, #$FF
0B08: 58 FF 29  EOR   $29, #$FF
0B0B: 3A 28     INCW  $28
0B0D: E4 28     MOV   A, $28
0B0F: D5 40 06  MOV   $0640+X, A
0B12: E4 29     MOV   A, $29
0B14: D5 41 06  MOV   $0641+X, A
0B17: 5F 9C 0B  JMP   $0B9C
; song channel pitch envelope
0B1A: 8E        POP   PSW
0B1B: 8F 00 2C  MOV   $2C, #$00
0B1E: 60        CLRC  
0B1F: 84 8E     ADC   A, $8E
0B21: 80        SETC  
0B22: A8 0A     SBC   A, #$0A
0B24: 10 05     BPL   $0B2B
0B26: 60        CLRC  
0B27: AB 2C     INC   $2C
0B29: 88 0C     ADC   A, #$0C
0B2B: CD 0C     MOV   X, #$0C
0B2D: 8D 00     MOV   Y, #$00
0B2F: 9E        DIV   YA, X
0B30: F8 27     MOV   X, $27
0B32: C4 2D     MOV   $2D, A
0B34: DD        MOV   A, Y
0B35: 1C        ASL   A
0B36: FD        MOV   Y, A
0B37: F6 77 18  MOV   A, $1877+Y      ; frequency value
0B3A: C4 28     MOV   $28, A
0B3C: F6 78 18  MOV   A, $1878+Y
0B3F: C4 29     MOV   $29, A
0B41: E4 2C     MOV   A, $2C
0B43: F0 04     BEQ   $0B49
0B45: 4B 29     LSR   $29
0B47: 6B 28     ROR   $28
0B49: E8 04     MOV   A, #$04
0B4B: 64 2D     CMP   A, $2D
0B4D: B0 0F     BCS   $0B5E
0B4F: BC        INC   A
0B50: 0B 28     ASL   $28
0B52: 2B 29     ROL   $29
0B54: 2E 2D F8  CBNE  $2D, $0B4F
0B57: 2F 08     BRA   $0B61
0B59: 9C        DEC   A
0B5A: 4B 29     LSR   $29
0B5C: 6B 28     ROR   $28
0B5E: 2E 2D F8  CBNE  $2D, $0B59
0B61: F5 00 03  MOV   A, $0300+X      ; sample frequency multiplier
0B64: 0D        PUSH  PSW
0B65: 2D        PUSH  A
0B66: EB 29     MOV   Y, $29
0B68: CF        MUL   YA
0B69: DA 2A     MOVW  $2A, YA
0B6B: AE        POP   A
0B6C: EB 28     MOV   Y, $28
0B6E: CF        MUL   YA
0B6F: DD        MOV   A, Y
0B70: 8D 00     MOV   Y, #$00
0B72: 7A 2A     ADDW  YA, $2A
0B74: DA 2A     MOVW  $2A, YA
0B76: 8E        POP   PSW
0B77: 30 04     BMI   $0B7D
0B79: 7A 28     ADDW  YA, $28
0B7B: DA 2A     MOVW  $2A, YA
0B7D: F5 A1 02  MOV   A, $02A1+X      ; set initial frequency
0B80: FD        MOV   Y, A
0B81: F5 A0 02  MOV   A, $02A0+X
0B84: 9A 2A     SUBW  YA, $2A
0B86: DA 2A     MOVW  $2A, YA
0B88: 10 08     BPL   $0B92
0B8A: 58 FF 2A  EOR   $2A, #$FF
0B8D: 58 FF 2B  EOR   $2B, #$FF
0B90: 3A 2A     INCW  $2A
0B92: E4 2A     MOV   A, $2A
0B94: D5 40 06  MOV   $0640+X, A
0B97: E4 2B     MOV   A, $2B
0B99: D5 41 06  MOV   $0641+X, A
0B9C: F5 21 04  MOV   A, $0421+X
0B9F: D5 40 04  MOV   $0440+X, A
0BA2: F5 41 04  MOV   A, $0441+X
0BA5: D5 60 04  MOV   $0460+X, A
0BA8: E8 00     MOV   A, #$00
0BAA: D5 20 06  MOV   $0620+X, A
0BAD: D5 21 06  MOV   $0621+X, A
; vibrato
0BB0: F5 01 04  MOV   A, $0401+X
0BB3: F0 32     BEQ   $0BE7           ; branch if vibrato is disabled
0BB5: F5 A1 02  MOV   A, $02A1+X
0BB8: FD        MOV   Y, A
0BB9: F5 A0 02  MOV   A, $02A0+X
0BBC: DA 32     MOVW  $32, YA
0BBE: 3F C7 10  CALL  $10C7           ; divide
0BC1: BA 32     MOVW  YA, $32
0BC3: D5 C0 05  MOV   $05C0+X, A      ; set vibrato frequency
0BC6: DD        MOV   A, Y
0BC7: D5 C1 05  MOV   $05C1+X, A
0BCA: F5 E1 03  MOV   A, $03E1+X      ; reset vibrato delay counter
0BCD: D5 00 04  MOV   $0400+X, A
0BD0: F5 60 05  MOV   A, $0560+X
0BD3: D5 A0 05  MOV   $05A0+X, A
0BD6: F5 61 05  MOV   A, $0561+X
0BD9: D5 A1 05  MOV   $05A1+X, A
0BDC: F5 01 04  MOV   A, $0401+X
0BDF: D5 20 04  MOV   $0420+X, A
0BE2: E8 01     MOV   A, #$01
0BE4: D5 80 04  MOV   $0480+X, A
0BE7: E8 00     MOV   A, #$00
0BE9: D5 40 05  MOV   $0540+X, A
0BEC: D5 41 05  MOV   $0541+X, A
0BEF: D5 E0 04  MOV   $04E0+X, A
0BF2: D5 E1 04  MOV   $04E1+X, A
0BF5: D5 60 06  MOV   $0660+X, A
0BF8: D5 61 06  MOV   $0661+X, A
0BFB: D5 E0 05  MOV   $05E0+X, A
0BFE: D5 E1 05  MOV   $05E1+X, A
0C01: D5 60 03  MOV   $0360+X, A
0C04: BC        INC   A
0C05: D4 49     MOV   $49+X, A
; tremolo
0C07: F5 C1 03  MOV   A, $03C1+X
0C0A: F0 15     BEQ   $0C21
0C0C: D5 E0 03  MOV   $03E0+X, A      ; reset tremolo delay counter
0C0F: F5 A1 03  MOV   A, $03A1+X
0C12: D5 C0 03  MOV   $03C0+X, A
0C15: F5 00 05  MOV   A, $0500+X
0C18: D5 20 05  MOV   $0520+X, A
0C1B: F5 01 05  MOV   A, $0501+X
0C1E: D5 21 05  MOV   $0521+X, A
; pansweep
0C21: F5 81 03  MOV   A, $0381+X
0C24: F0 16     BEQ   $0C3C
0C26: 5C        LSR   A
0C27: D5 A0 03  MOV   $03A0+X, A
0C2A: F5 61 03  MOV   A, $0361+X      ; reset pansweep delay counter
0C2D: D5 80 03  MOV   $0380+X, A
0C30: F5 A0 04  MOV   A, $04A0+X
0C33: D5 C0 04  MOV   $04C0+X, A
0C36: F5 A1 04  MOV   A, $04A1+X
0C39: D5 C1 04  MOV   $04C1+X, A
0C3C: F5 20 03  MOV   A, $0320+X
0C3F: D5 40 03  MOV   $0340+X, A
0C42: F5 21 03  MOV   A, $0321+X
0C45: D5 41 03  MOV   $0341+X, A
0C48: 09 8D 88  OR    $88, $8D
0C4B: 09 8D 8B  OR    $8B, $8D        ; enable volume and frequency update
0C4E: 09 8D 8C  OR    $8C, $8D
0C51: 7D        MOV   A, X
0C52: 9F        XCN   A
0C53: 5C        LSR   A
0C54: 08 04     OR    A, #$04         ; channel sample
0C56: FD        MOV   Y, A
0C57: F5 C1 02  MOV   A, $02C1+X
0C5A: 3F E9 10  CALL  $10E9           ; set dsp register
0C5D: FC        INC   Y               ; flat adsr envelope
0C5E: E8 FF     MOV   A, #$FF
0C60: 3F E9 10  CALL  $10E9           ; set dsp register
0C63: FC        INC   Y
0C64: E8 E0     MOV   A, #$E0
0C66: 3F E9 10  CALL  $10E9           ; set dsp register
0C69: FC        INC   Y
0C6A: F5 E1 02  MOV   A, $02E1+X      ; gain value
0C6D: 5F E9 10  JMP   $10E9           ; set dsp register

; [ execute script command ]

0C70: 80        SETC  
0C71: A8 D2     SBC   A, #$D2
0C73: 1C        ASL   A
0C74: FD        MOV   Y, A
0C75: F6 EE 17  MOV   A, $17EE+Y      ; sound command jump table
0C78: 2D        PUSH  A
0C79: F6 ED 17  MOV   A, $17ED+Y
0C7C: 2D        PUSH  A
0C7D: DD        MOV   A, Y
0C7E: 5C        LSR   A
0C7F: FD        MOV   Y, A
0C80: F6 49 18  MOV   A, $1849+Y      ; number of parameter bytes
0C83: F0 0A     BEQ   $0C8F
; fallthrough

; [ get next script byte ]

0C85: E7 02     MOV   A, ($02+X)
0C87: C4 26     MOV   $26, A
0C89: BB 02     INC   $02+X
0C8B: D0 02     BNE   $0C8F
0C8D: BB 03     INC   $03+X
0C8F: 6F        RET   

; [ get next note ]

0C90: 8D 00     MOV   Y, #$00
0C92: F7 22     MOV   A, ($22)+Y
0C94: 3A 22     INCW  $22
0C96: 68 D2     CMP   A, #$D2
0C98: 90 43     BCC   $0CDD           ; branch if a note
0C9A: 68 F1     CMP   A, #$F1
0C9C: F0 3F     BEQ   $0CDD           ; branch if end of script
0C9E: 68 F4     CMP   A, #$F4
0CA0: F0 14     BEQ   $0CB6
0CA2: 68 F0     CMP   A, #$F0
0CA4: F0 1D     BEQ   $0CC3
0CA6: 80        SETC  
0CA7: A8 D2     SBC   A, #$D2
0CA9: FD        MOV   Y, A
0CAA: F6 49 18  MOV   A, $1849+Y      ; number of parameter bytes
0CAD: FD        MOV   Y, A
0CAE: F0 E2     BEQ   $0C92
0CB0: 3A 22     INCW  $22
0CB2: FE FC     DBNZ  Y, $0CB0
0CB4: 2F DC     BRA   $0C92
0CB6: F7 22     MOV   A, ($22)+Y
0CB8: 2D        PUSH  A
0CB9: FC        INC   Y
0CBA: F7 22     MOV   A, ($22)+Y
0CBC: C4 23     MOV   $23, A
0CBE: AE        POP   A
0CBF: C4 22     MOV   $22, A
0CC1: 2F CD     BRA   $0C90
0CC3: F5 81 06  MOV   A, $0681+X
0CC6: FD        MOV   Y, A
0CC7: E8 01     MOV   A, #$01
0CC9: 76 A0 06  CMP   A, $06A0+Y
0CCC: F0 C2     BEQ   $0C90
0CCE: DD        MOV   A, Y
0CCF: 1C        ASL   A
0CD0: FD        MOV   Y, A
0CD1: F6 E0 06  MOV   A, $06E0+Y
0CD4: C4 22     MOV   $22, A
0CD6: F6 E1 06  MOV   A, $06E1+Y
0CD9: C4 23     MOV   $23, A
0CDB: 2F B3     BRA   $0C90
0CDD: 6F        RET   

; [ sound command $DA/$E1/$E2: set octave ]

; $DA: set octave (b1: octave)
; $E1: increment octave
; $E2: decrement octave

0CDE: F5 C0 02  MOV   A, $02C0+X
0CE1: 78 E1 26  CMP   $26, #$E1
0CE4: 90 08     BCC   $0CEE
0CE6: F0 03     BEQ   $0CEB
0CE8: 9C        DEC   A
0CE9: 2F 05     BRA   $0CF0
0CEB: BC        INC   A
0CEC: 2F 02     BRA   $0CF0
0CEE: E4 26     MOV   A, $26
0CF0: D5 C0 02  MOV   $02C0+X, A
0CF3: 6F        RET   

; [ sound command $D2: set tempo ]

; +b1: envelope duration
;  b3: tempo

0CF4: C4 30     MOV   $30, A
0CF6: 3F 85 0C  CALL  $0C85           ; get next script byte
0CF9: C4 31     MOV   $31, A
0CFB: 3F 85 0C  CALL  $0C85           ; get next script byte
0CFE: C8 10     CMP   X, #$10
0D00: B0 F1     BCS   $0CF3           ; return if a sound effect
0D02: BA 30     MOVW  YA, $30
0D04: D0 08     BNE   $0D0E           ; branch if envelope duration is nonzero
0D06: DA 32     MOVW  $32, YA
0D08: E4 26     MOV   A, $26          ; set tempo
0D0A: C4 37     MOV   $37, A
0D0C: 2F 28     BRA   $0D36
0D0E: E4 37     MOV   A, $37
0D10: 64 26     CMP   A, $26
0D12: D0 06     BNE   $0D1A
0D14: BA 00     MOVW  YA, $00
0D16: DA 30     MOVW  $30, YA
0D18: 2F EC     BRA   $0D06
0D1A: 0D        PUSH  PSW
0D1B: 80        SETC  
0D1C: A4 26     SBC   A, $26
0D1E: B0 03     BCS   $0D23
0D20: 48 FF     EOR   A, #$FF
0D22: BC        INC   A
0D23: 8F 00 32  MOV   $32, #$00
0D26: C4 33     MOV   $33, A
0D28: 3F C7 10  CALL  $10C7           ; divide
0D2B: 8E        POP   PSW
0D2C: 90 08     BCC   $0D36
0D2E: 58 FF 32  EOR   $32, #$FF
0D31: 58 FF 33  EOR   $33, #$FF
0D34: 3A 32     INCW  $32
0D36: BA 30     MOVW  YA, $30
0D38: C4 3A     MOV   $3A, A
0D3A: CB 3B     MOV   $3B, Y
0D3C: BA 32     MOVW  YA, $32
0D3E: C4 3C     MOV   $3C, A
0D40: CB 3D     MOV   $3D, Y
0D42: E8 00     MOV   A, #$00
0D44: C4 36     MOV   $36, A
0D46: 6F        RET   

; [ sound command $D3: no effect ]

0D47: 3F 85 0C  CALL  $0C85           ; get next script byte
0D4A: 3F 85 0C  CALL  $0C85           ; get next script byte
0D4D: 6F        RET   

; [ sound command $D4: set echo volume ]

; b1: echo volume

0D4E: C8 10     CMP   X, #$10
0D50: B0 FB     BCS   $0D4D           ; return if a sound effect
0D52: C4 41     MOV   $41, A
0D54: C4 40     MOV   $40, A
0D56: 6F        RET   

; [ sound command $F2: set channel volume ]

; +b1: envelope duration
;  b3: volume

0D57: C4 30     MOV   $30, A
0D59: 3F 85 0C  CALL  $0C85           ; get next script byte
0D5C: C4 31     MOV   $31, A
0D5E: 3F 85 0C  CALL  $0C85           ; get next script byte
0D61: BA 30     MOVW  YA, $30
0D63: D0 09     BNE   $0D6E           ; branch if envelope duration is nonzero
0D65: DA 32     MOVW  $32, YA
0D67: E4 26     MOV   A, $26
0D69: D5 01 02  MOV   $0201+X, A
0D6C: 2F 29     BRA   $0D97
0D6E: F5 01 02  MOV   A, $0201+X
0D71: 64 26     CMP   A, $26
0D73: D0 06     BNE   $0D7B           ; branch if volume needs to change
0D75: BA 00     MOVW  YA, $00
0D77: DA 30     MOVW  $30, YA
0D79: 2F EA     BRA   $0D65
0D7B: 0D        PUSH  PSW
0D7C: 80        SETC  
0D7D: A4 26     SBC   A, $26
0D7F: B0 03     BCS   $0D84
0D81: 48 FF     EOR   A, #$FF
0D83: BC        INC   A
0D84: 8F 00 32  MOV   $32, #$00
0D87: C4 33     MOV   $33, A
0D89: 3F C7 10  CALL  $10C7           ; divide
0D8C: 8E        POP   PSW
0D8D: 90 08     BCC   $0D97
0D8F: 58 FF 32  EOR   $32, #$FF
0D92: 58 FF 33  EOR   $33, #$FF
0D95: 3A 32     INCW  $32
0D97: E4 30     MOV   A, $30
0D99: D5 40 02  MOV   $0240+X, A
0D9C: E4 31     MOV   A, $31
0D9E: D5 41 02  MOV   $0241+X, A
0DA1: E4 32     MOV   A, $32
0DA3: D5 60 02  MOV   $0260+X, A
0DA6: E4 33     MOV   A, $33
0DA8: D5 61 02  MOV   $0261+X, A
0DAB: E8 00     MOV   A, #$00
0DAD: D5 00 02  MOV   $0200+X, A
0DB0: 6F        RET   

; [ sound command $F3: set channel pan ]

; +b1: envelope duration
;  b2: pan

0DB1: C4 30     MOV   $30, A
0DB3: 3F 85 0C  CALL  $0C85           ; get next script byte
0DB6: C4 31     MOV   $31, A
0DB8: 3F 85 0C  CALL  $0C85           ; get next script byte
0DBB: BA 30     MOVW  YA, $30
0DBD: D0 09     BNE   $0DC8
0DBF: DA 32     MOVW  $32, YA
0DC1: E4 26     MOV   A, $26
0DC3: D5 21 02  MOV   $0221+X, A
0DC6: 2F 29     BRA   $0DF1
0DC8: F5 21 02  MOV   A, $0221+X
0DCB: 64 26     CMP   A, $26
0DCD: D0 06     BNE   $0DD5
0DCF: BA 00     MOVW  YA, $00
0DD1: DA 30     MOVW  $30, YA
0DD3: 2F EA     BRA   $0DBF
0DD5: 0D        PUSH  PSW
0DD6: 80        SETC  
0DD7: A4 26     SBC   A, $26
0DD9: B0 03     BCS   $0DDE
0DDB: 48 FF     EOR   A, #$FF
0DDD: BC        INC   A
0DDE: 8F 00 32  MOV   $32, #$00
0DE1: C4 33     MOV   $33, A
0DE3: 3F C7 10  CALL  $10C7           ; divide
0DE6: 8E        POP   PSW
0DE7: 90 08     BCC   $0DF1
0DE9: 58 FF 32  EOR   $32, #$FF
0DEC: 58 FF 33  EOR   $33, #$FF
0DEF: 3A 32     INCW  $32
0DF1: E4 30     MOV   A, $30
0DF3: D5 80 02  MOV   $0280+X, A
0DF6: E4 31     MOV   A, $31
0DF8: D5 81 02  MOV   $0281+X, A
0DFB: E4 32     MOV   A, $32
0DFD: D5 90 02  MOV   $0290+X, A
0E00: E4 33     MOV   A, $33
0E02: D5 91 02  MOV   $0291+X, A
0E05: E8 00     MOV   A, #$00
0E07: D5 20 02  MOV   $0220+X, A
0E0A: 6F        RET   

; [ sound command $D5: set echo feedback/filter ]

; b1: echo feedback
; b2: filter id

0E0B: C4 79     MOV   $79, A          ; echo feedback
0E0D: 3F 82 10  CALL  $1082           ; set echo delay
0E10: 3F 85 0C  CALL  $0C85           ; get next script byte
0E13: 1C        ASL   A
0E14: 1C        ASL   A
0E15: 1C        ASL   A
0E16: FD        MOV   Y, A
0E17: CD 0F     MOV   X, #$0F         ; dsp filter
0E19: F6 91 18  MOV   A, $1891+Y      ; fir filter values
0E1C: D8 F2     MOV   $F2, X
0E1E: C4 F3     MOV   $F3, A
0E20: FC        INC   Y
0E21: 7D        MOV   A, X
0E22: 60        CLRC  
0E23: 88 10     ADC   A, #$10
0E25: 5D        MOV   X, A
0E26: 10 F1     BPL   $0E19
0E28: F8 27     MOV   X, $27
0E2A: 6F        RET   

; [ sound command $EA: enable echo ]

0E2B: C8 10     CMP   X, #$10
0E2D: 90 05     BCC   $0E34
0E2F: 09 8D 82  OR    $82, $8D
0E32: 2F 03     BRA   $0E37
0E34: 09 8D 81  OR    $81, $8D
0E37: B2 8A     CLR   $8A.5           ; enable echo in dsp flags
0E39: FA 41 40  MOV   $40, $41

; [ update echo enable in dsp ]

0E3C: E4 78     MOV   A, $78
0E3E: 48 FF     EOR   A, #$FF
0E40: 24 81     AND   A, $81
0E42: 04 82     OR    A, $82
0E44: C4 7E     MOV   $7E, A
0E46: 6F        RET   

; [ sound command $EB: disable echo ]

0E47: E4 8D     MOV   A, $8D
0E49: C8 10     CMP   X, #$10
0E4B: 90 05     BCC   $0E52
0E4D: 4E 82 00  TCLR1 $0082
0E50: 2F 03     BRA   $0E55
0E52: 4E 81 00  TCLR1 $0081
0E55: BA 81     MOVW  YA, $81
0E57: D0 04     BNE   $0E5D
0E59: C4 40     MOV   $40, A
0E5B: A2 8A     SET   $8A.5           ; disable echo in dsp flags
0E5D: 2F DD     BRA   $0E3C

; [ sound command $D6: enable pitch envelope ]

; b1: delay (ticks)
; b2: duration (ticks)
; b3: amplitude

0E5F: BC        INC   A
0E60: D5 21 04  MOV   $0421+X, A
0E63: 3F 85 0C  CALL  $0C85           ; get next script byte
0E66: D5 41 04  MOV   $0441+X, A
0E69: C4 30     MOV   $30, A
0E6B: 3F 85 0C  CALL  $0C85           ; get next script byte
0E6E: D5 61 04  MOV   $0461+X, A
0E71: F0 16     BEQ   $0E89
0E73: 8F 00 31  MOV   $31, #$00
0E76: 8F FF 32  MOV   $32, #$FF
0E79: 8F FF 33  MOV   $33, #$FF
0E7C: 3F C7 10  CALL  $10C7           ; divide
0E7F: E4 32     MOV   A, $32
0E81: D5 00 06  MOV   $0600+X, A
0E84: E4 33     MOV   A, $33
0E86: D5 01 06  MOV   $0601+X, A
0E89: 6F        RET   

; [ sound command $E6: disable pitch envelope ]

0E8A: D5 61 04  MOV   $0461+X, A
0E8D: 6F        RET   

; [ sound command $D7: enable tremolo ]

; b1: delay (ticks)
; b2: period
; b3: amplitude

0E8E: BC        INC   A
0E8F: D5 A1 03  MOV   $03A1+X, A
0E92: 3F 85 0C  CALL  $0C85           ; get next script byte
0E95: 5C        LSR   A
0E96: D5 C1 03  MOV   $03C1+X, A
0E99: C4 30     MOV   $30, A
0E9B: 3F 85 0C  CALL  $0C85           ; get next script byte
0E9E: 8F 00 31  MOV   $31, #$00
0EA1: 8F 00 32  MOV   $32, #$00
0EA4: C4 33     MOV   $33, A
0EA6: 3F C7 10  CALL  $10C7           ; divide
0EA9: 58 FF 32  EOR   $32, #$FF
0EAC: 58 FF 33  EOR   $33, #$FF
0EAF: 3A 32     INCW  $32
0EB1: E4 32     MOV   A, $32
0EB3: D5 00 05  MOV   $0500+X, A
0EB6: E4 33     MOV   A, $33
0EB8: D5 01 05  MOV   $0501+X, A
0EBB: 6F        RET   

; [ sound command $E7: disable tremolo ]

0EBC: D5 C1 03  MOV   $03C1+X, A
0EBF: 6F        RET   

; [ sound command $D8: enable vibrato ]

; b1: delay (ticks)
; b2: period
; b3: amplitude

0EC0: BC        INC   A
0EC1: D5 E1 03  MOV   $03E1+X, A
0EC4: 3F 85 0C  CALL  $0C85           ; get next script byte
0EC7: 5C        LSR   A
0EC8: D5 01 04  MOV   $0401+X, A
0ECB: C4 30     MOV   $30, A
0ECD: 3F 85 0C  CALL  $0C85           ; get next script byte
0ED0: 8F 00 31  MOV   $31, #$00
0ED3: 8F 00 32  MOV   $32, #$00
0ED6: C4 33     MOV   $33, A
0ED8: 3F C7 10  CALL  $10C7           ; divide
0EDB: BA 32     MOVW  YA, $32
0EDD: D5 60 05  MOV   $0560+X, A      ; vibrato rate (amplitude / period)
0EE0: DD        MOV   A, Y
0EE1: D5 61 05  MOV   $0561+X, A
0EE4: 6F        RET   

; [ sound command $E8: disable vibrato ]

0EE5: D5 01 04  MOV   $0401+X, A
0EE8: 6F        RET   

; [ sound command $D9: enable pansweep ]

; b1: delay (ticks)
; b2: period
; b3: amplitude

0EE9: BC        INC   A
0EEA: D5 61 03  MOV   $0361+X, A
0EED: 3F 85 0C  CALL  $0C85           ; get next script byte
0EF0: D5 81 03  MOV   $0381+X, A
0EF3: 5C        LSR   A
0EF4: C4 30     MOV   $30, A
0EF6: 3F 85 0C  CALL  $0C85           ; get next script byte
0EF9: 8F 00 31  MOV   $31, #$00
0EFC: 8F 00 32  MOV   $32, #$00
0EFF: C4 33     MOV   $33, A
0F01: 3F C7 10  CALL  $10C7           ; divide
0F04: E4 32     MOV   A, $32
0F06: D5 A0 04  MOV   $04A0+X, A
0F09: E4 33     MOV   A, $33
0F0B: D5 A1 04  MOV   $04A1+X, A
0F0E: 6F        RET   

; [ sound command $E9: disable pansweep ]

0F0F: D5 81 03  MOV   $0381+X, A
0F12: 6F        RET   

; [ sound command $DB: set sample ]

; b1: sample id

0F13: D5 C1 02  MOV   $02C1+X, A      ; set sample id
0F16: FD        MOV   Y, A
0F17: F6 00 FF  MOV   A, $FF00+Y
0F1A: D5 00 03  MOV   $0300+X, A      ; set sample frequency multiplier
0F1D: 6F        RET   

; [ sound command $DC: set note envelope ]

; b1: note envelope id

0F1E: 1C        ASL   A
0F1F: FD        MOV   Y, A
0F20: F6 00 1D  MOV   A, $1D00+Y      ; set pointer to note envelope data
0F23: D5 20 03  MOV   $0320+X, A
0F26: F6 01 1D  MOV   A, $1D01+Y
0F29: D5 21 03  MOV   $0321+X, A
0F2C: 6F        RET   

; [ sound command $DD: set gain ]

; b1: gain value id

0F2D: 28 1F     AND   A, #$1F
0F2F: FD        MOV   Y, A
0F30: F6 C0 18  MOV   A, $18C0+Y      ; gain values
0F33: D5 E1 02  MOV   $02E1+X, A
0F36: 6F        RET   

; [ sound command $DE: set sustain ]

; b1: sustain (0-100)

; *** bug *** 
; a sustain parameter of 100 will result in a sustain rate of 100/255 = 39%

0F37: 68 64     CMP   A, #$64
0F39: F0 0E     BEQ   $0F49           ; *** bug ***
0F3B: 90 04     BCC   $0F41
0F3D: E8 00     MOV   A, #$00         ; any value > 100 results in 100% sustain
0F3F: 2F 08     BRA   $0F49
0F41: FD        MOV   Y, A
0F42: E8 00     MOV   A, #$00
0F44: CD 64     MOV   X, #$64
0F46: 9E        DIV   YA, X
0F47: F8 27     MOV   X, $27
0F49: D5 01 03  MOV   $0301+X, A      ; set sustain
0F4C: 6F        RET   

; [ sound command $DF: set noise clock ]

; b1: noise clock value

0F4D: 28 1F     AND   A, #$1F
0F4F: C8 10     CMP   X, #$10
0F51: 90 06     BCC   $0F59           ; branch if not a sound effect
0F53: 02 87     SET   $87.0
0F55: C4 7D     MOV   $7D, A
0F57: 2F 02     BRA   $0F5B
0F59: C4 7C     MOV   $7C, A
; fallthrough

; [ update noise clock in dsp ]

0F5B: E8 6C     MOV   A, #$6C         ; dsp flags
0F5D: C4 F2     MOV   $F2, A
0F5F: E4 F3     MOV   A, $F3
0F61: 28 E0     AND   A, #$E0
0F63: 13 87 04  BBC   $87.0, $0F6A    ; branch if not a sound effect
0F66: 04 7D     OR    A, $7D
0F68: 2F 02     BRA   $0F6C
0F6A: 04 7C     OR    A, $7C
0F6C: C4 F3     MOV   $F3, A
0F6E: 38 E0 8A  AND   $8A, #$E0
0F71: 28 1F     AND   A, #$1F
0F73: 04 8A     OR    A, $8A
0F75: C4 8A     MOV   $8A, A
0F77: 6F        RET   

; [ sound command $E0: loop start ]

; b1: loop count - 1

0F78: F5 81 06  MOV   A, $0681+X      ; increment loop depth
0F7B: BC        INC   A
0F7C: D5 81 06  MOV   $0681+X, A
0F7F: FD        MOV   Y, A
0F80: E4 26     MOV   A, $26
0F82: F0 01     BEQ   $0F85
0F84: BC        INC   A
0F85: D6 A0 06  MOV   $06A0+Y, A
0F88: E8 00     MOV   A, #$00
0F8A: D6 80 07  MOV   $0780+Y, A      ; clear repeat number
0F8D: DD        MOV   A, Y
0F8E: 1C        ASL   A
0F8F: FD        MOV   Y, A
0F90: F4 02     MOV   A, $02+X
0F92: D6 E0 06  MOV   $06E0+Y, A      ; set loop pointer
0F95: F4 03     MOV   A, $03+X
0F97: D6 E1 06  MOV   $06E1+Y, A
0F9A: 6F        RET   

; [ sound command $F0: loop end ]

0F9B: F5 81 06  MOV   A, $0681+X
0F9E: FD        MOV   Y, A
0F9F: F6 A0 06  MOV   A, $06A0+Y
0FA2: F0 0D     BEQ   $0FB1
0FA4: 9C        DEC   A               ; decrement loop counter
0FA5: D6 A0 06  MOV   $06A0+Y, A
0FA8: D0 07     BNE   $0FB1
0FAA: DC        DEC   Y               ; decrement loop depth
0FAB: DD        MOV   A, Y
0FAC: D5 81 06  MOV   $0681+X, A
0FAF: 2F 0D     BRA   $0FBE
0FB1: DD        MOV   A, Y
0FB2: 1C        ASL   A
0FB3: FD        MOV   Y, A
0FB4: F6 E0 06  MOV   A, $06E0+Y      ; jump to loop pointer
0FB7: D4 02     MOV   $02+X, A
0FB9: F6 E1 06  MOV   A, $06E1+Y
0FBC: D4 03     MOV   $03+X, A
0FBE: 6F        RET   

; [ sound command $F5: volta repeat ]

;  b1: repeat number to jump on
; +b2: script pointer

0FBF: F5 81 06  MOV   A, $0681+X      ; loop depth
0FC2: FD        MOV   Y, A
0FC3: F6 80 07  MOV   A, $0780+Y      ; repeat number
0FC6: BC        INC   A
0FC7: D6 80 07  MOV   $0780+Y, A
0FCA: 64 26     CMP   A, $26
0FCC: F0 06     BEQ   $0FD4
0FCE: 3F 89 0C  CALL  $0C89           ; skip 2 bytes
0FD1: 5F 89 0C  JMP   $0C89
0FD4: F6 A0 06  MOV   A, $06A0+Y
0FD7: F0 0B     BEQ   $0FE4           ; branch if not last loop
0FD9: 9C        DEC   A
0FDA: D6 A0 06  MOV   $06A0+Y, A
0FDD: D0 05     BNE   $0FE4
0FDF: DD        MOV   A, Y
0FE0: 9C        DEC   A               ; decrement repeat depth
0FE1: D5 81 06  MOV   $0681+X, A
0FE4: 3F 85 0C  CALL  $0C85           ; get next script byte
0FE7: FD        MOV   Y, A
0FE8: 3F 85 0C  CALL  $0C85           ; get next script byte
0FEB: DB 02     MOV   $02+X, Y        ; set script pointer
0FED: D4 03     MOV   $03+X, A
0FEF: 6F        RET   

; [ sound command $F6: unused jump ]

0FF0: F5 60 07  MOV   A, $0760+X
0FF3: D4 02     MOV   $02+X, A
0FF5: F5 61 07  MOV   A, $0761+X
0FF8: D4 03     MOV   $03+X, A
0FFA: 6F        RET   

; [ sound command $F4: jump ]

; +b1: jump address

0FFB: FD        MOV   Y, A
0FFC: 3F 85 0C  CALL  $0C85           ; get next script byte
0FFF: DB 02     MOV   $02+X, Y
1001: D4 03     MOV   $03+X, A
1003: 6F        RET   

; [ sound command $E4: no effect ]

1004: 6F        RET   

; [ sound command $E5: no effect ]

1005: 6F        RET   

; [ sound command $EC: enable noise ]

1006: C8 10     CMP   X, #$10
1008: 90 05     BCC   $100F           ; branch if not a sound effect
100A: 09 8D 84  OR    $84, $8D
100D: 2F 03     BRA   $1012
100F: 09 8D 83  OR    $83, $8D
; fallthrough

; [ update noise enable in dsp ]

1012: E4 78     MOV   A, $78
1014: 48 FF     EOR   A, #$FF
1016: 24 83     AND   A, $83
1018: 04 84     OR    A, $84
101A: 8D 3D     MOV   Y, #$3D         ; enable noise
101C: 5F E9 10  JMP   $10E9           ; set dsp register

; [ sound command $ED: disable noise ]

101F: E4 8D     MOV   A, $8D
1021: C8 10     CMP   X, #$10
1023: 90 09     BCC   $102E           ; branch if not a sound effect
1025: 4E 84 00  TCLR1 $0084
1028: D0 E8     BNE   $1012
102A: 12 87     CLR   $87.0
102C: 2F E4     BRA   $1012
102E: 4E 83 00  TCLR1 $0083
1031: 2F DF     BRA   $1012

; [ sound command $EE: enable pitch modulation ]

1033: C8 10     CMP   X, #$10
1035: 90 05     BCC   $103C           ; branch if not a sound effect
1037: 09 8D 86  OR    $86, $8D
103A: 2F 03     BRA   $103F
103C: 09 8D 85  OR    $85, $8D
; fallthrough

; [ update pitch modulation in dsp ]

103F: E4 78     MOV   A, $78
1041: 48 FF     EOR   A, #$FF
1043: 24 85     AND   A, $85
1045: 04 86     OR    A, $86
1047: 8D 2D     MOV   Y, #$2D         ; pitch modulation
1049: 5F E9 10  JMP   $10E9           ; set dsp register

; [ sound command $EF: disable pitch modulation ]

104C: E4 8D     MOV   A, $8D
104E: C8 10     CMP   X, #$10
1050: 90 05     BCC   $1057           ; branch if not a sound effect
1052: 4E 86 00  TCLR1 $0086
1055: 2F E8     BRA   $103F
1057: 4E 85 00  TCLR1 $0085
105A: 2F E3     BRA   $103F

; [ sound command $E3: no effect ]

105C: 6F        RET   

; [ sound command $F1: end of script ]

105D: AE        POP   A
105E: AE        POP   A
105F: E8 00     MOV   A, #$00
1061: D4 02     MOV   $02+X, A
1063: D4 03     MOV   $03+X, A
1065: C8 10     CMP   X, #$10
1067: 90 18     BCC   $1081           ; return if not a sound effect
1069: E4 8D     MOV   A, $8D
106B: 4E 91 00  TCLR1 $0091           ; disable system sound effect
106E: 4E 78 00  TCLR1 $0078           ; disable game sound effect
1071: D0 02     BNE   $1075
1073: 12 7C     CLR   $7C.0
1075: 3F 47 0E  CALL  $0E47           ; disable echo
1078: 3F 1F 10  CALL  $101F           ; disable noise
107B: 3F 5B 0F  CALL  $0F5B           ; update noise clock in dsp
107E: 5F 4C 10  JMP   $104C
1081: 6F        RET   

; [ set echo delay ]

1082: E8 7D     MOV   A, #$7D         ; echo delay
1084: C4 F2     MOV   $F2, A
1086: E4 F3     MOV   A, $F3
1088: 64 7A     CMP   A, $7A
108A: F0 29     BEQ   $10B5
108C: 8F F0 7B  MOV   $7B, #$F0       ; reset echo buffer sync counter
108F: E4 8A     MOV   A, $8A
1091: 08 20     OR    A, #$20
1093: 8D 6C     MOV   Y, #$6C         ; dsp flags
1095: 3F E9 10  CALL  $10E9           ; set dsp register
1098: E8 00     MOV   A, #$00
109A: 8D 4D     MOV   Y, #$4D         ; echo enable
109C: 3F E9 10  CALL  $10E9           ; set dsp register
109F: 8D 0D     MOV   Y, #$0D         ; echo feedback
10A1: 3F E9 10  CALL  $10E9           ; set dsp register
10A4: 8D 2C     MOV   Y, #$2C         ; echo volume left
10A6: 3F E9 10  CALL  $10E9           ; set dsp register
10A9: 8D 3C     MOV   Y, #$3C         ; echo volume right
10AB: 3F E9 10  CALL  $10E9           ; set dsp register
10AE: E4 7A     MOV   A, $7A
10B0: 8D 7D     MOV   Y, #$7D         ; echo delay
10B2: 3F E9 10  CALL  $10E9           ; set dsp register
10B5: E4 7A     MOV   A, $7A
10B7: 1C        ASL   A
10B8: 1C        ASL   A
10B9: 1C        ASL   A
10BA: 48 FF     EOR   A, #$FF
10BC: 80        SETC  
10BD: 88 F8     ADC   A, #$F8
10BF: 8D 6D     MOV   Y, #$6D         ; echo buffer pointer
10C1: 3F E9 10  CALL  $10E9           ; set dsp register
10C4: E4 FE     MOV   A, $FE
10C6: 6F        RET   

; [ divide (16-bit) ]

; +$32 = +$32 / +$30, R -> +$34

10C7: CD 00     MOV   X, #$00
10C9: D8 34     MOV   $34, X
10CB: D8 35     MOV   $35, X
10CD: 0B 32     ASL   $32
10CF: 2B 33     ROL   $33
10D1: 2B 34     ROL   $34
10D3: 2B 35     ROL   $35
10D5: BA 34     MOVW  YA, $34
10D7: 5A 30     CMPW  YA, $30
10D9: 90 06     BCC   $10E1
10DB: 02 32     SET   $32.0
10DD: 9A 30     SUBW  YA, $30
10DF: DA 34     MOVW  $34, YA
10E1: 3D        INC   X
10E2: C8 10     CMP   X, #$10
10E4: D0 E7     BNE   $10CD
10E6: F8 27     MOV   X, $27
10E8: 6F        RET   

; [ set dsp register ]

10E9: CB F2     MOV   $F2, Y
10EB: C4 F3     MOV   $F3, A
10ED: 6F        RET   

; [ update channel envelopes ]

; once per tick (tempo-dependent), sound effects skip pan envelope

; pan envelope
10EE: F5 81 02  MOV   A, $0281+X      ; decrement pan envelope counter
10F1: FD        MOV   Y, A
10F2: F5 80 02  MOV   A, $0280+X
10F5: DA 28     MOVW  $28, YA
10F7: BA 28     MOVW  YA, $28
10F9: F0 27     BEQ   $1122
10FB: 1A 28     DECW  $28
10FD: BA 28     MOVW  YA, $28
10FF: D5 80 02  MOV   $0280+X, A
1102: DD        MOV   A, Y
1103: D5 81 02  MOV   $0281+X, A
1106: F5 91 02  MOV   A, $0291+X      ; pan envelope rate
1109: FD        MOV   Y, A
110A: F5 90 02  MOV   A, $0290+X
110D: DA 28     MOVW  $28, YA
110F: F5 21 02  MOV   A, $0221+X
1112: FD        MOV   Y, A
1113: F5 20 02  MOV   A, $0220+X
1116: 7A 28     ADDW  YA, $28
1118: D5 20 02  MOV   $0220+X, A      ; set pan
111B: DD        MOV   A, Y
111C: D5 21 02  MOV   $0221+X, A
111F: 09 8D 8B  OR    $8B, $8D        ; enable volume update in dsp
; volume envelope
1122: F5 41 02  MOV   A, $0241+X      ; decrement volume envelope counter
1125: FD        MOV   Y, A
1126: F5 40 02  MOV   A, $0240+X
1129: DA 28     MOVW  $28, YA
112B: BA 28     MOVW  YA, $28
112D: F0 27     BEQ   $1156
112F: 1A 28     DECW  $28
1131: BA 28     MOVW  YA, $28
1133: D5 40 02  MOV   $0240+X, A
1136: DD        MOV   A, Y
1137: D5 41 02  MOV   $0241+X, A
113A: F5 61 02  MOV   A, $0261+X      ; volume envelope rate
113D: FD        MOV   Y, A
113E: F5 60 02  MOV   A, $0260+X
1141: DA 28     MOVW  $28, YA
1143: F5 01 02  MOV   A, $0201+X
1146: FD        MOV   Y, A
1147: F5 00 02  MOV   A, $0200+X
114A: 7A 28     ADDW  YA, $28
114C: D5 00 02  MOV   $0200+X, A      ; set volume
114F: DD        MOV   A, Y
1150: D5 01 02  MOV   $0201+X, A
1153: 09 8D 8B  OR    $8B, $8D        ; enable volume update in dsp
; pitch envelope
1156: F5 61 04  MOV   A, $0461+X
1159: F0 5A     BEQ   $11B5
115B: F5 40 04  MOV   A, $0440+X      ; decrement pitch envelope delay counter
115E: F0 06     BEQ   $1166
1160: 9C        DEC   A
1161: D5 40 04  MOV   $0440+X, A
1164: 2F 4F     BRA   $11B5
1166: F5 60 04  MOV   A, $0460+X
1169: F0 4A     BEQ   $11B5
116B: 9C        DEC   A
116C: D5 60 04  MOV   $0460+X, A
116F: F5 01 06  MOV   A, $0601+X
1172: FD        MOV   Y, A
1173: F5 00 06  MOV   A, $0600+X
1176: DA 28     MOVW  $28, YA
1178: F5 21 06  MOV   A, $0621+X
117B: FD        MOV   Y, A
117C: F5 20 06  MOV   A, $0620+X
117F: 7A 28     ADDW  YA, $28
1181: D5 20 06  MOV   $0620+X, A
1184: DD        MOV   A, Y
1185: D5 21 06  MOV   $0621+X, A
1188: 6D        PUSH  Y
1189: F5 41 06  MOV   A, $0641+X
118C: CF        MUL   YA
118D: DA 28     MOVW  $28, YA
118F: EE        POP   Y
1190: F5 40 06  MOV   A, $0640+X
1193: CF        MUL   YA
1194: DD        MOV   A, Y
1195: 8D 00     MOV   Y, #$00
1197: 7A 28     ADDW  YA, $28
1199: DA 28     MOVW  $28, YA
119B: F5 61 04  MOV   A, $0461+X
119E: 10 08     BPL   $11A8
11A0: 58 FF 28  EOR   $28, #$FF
11A3: 58 FF 29  EOR   $29, #$FF
11A6: 3A 28     INCW  $28
11A8: E4 28     MOV   A, $28
11AA: D5 60 06  MOV   $0660+X, A
11AD: E4 29     MOV   A, $29
11AF: D5 61 06  MOV   $0661+X, A
11B2: 09 8D 8C  OR    $8C, $8D        ; enable frequency update in dsp
; tremolo, pansweep, vibrato delay
11B5: F5 C0 03  MOV   A, $03C0+X
11B8: F0 04     BEQ   $11BE
11BA: 9C        DEC   A               ; decrement tremolo delay
11BB: D5 C0 03  MOV   $03C0+X, A
11BE: F5 80 03  MOV   A, $0380+X 
11C1: F0 04     BEQ   $11C7
11C3: 9C        DEC   A               ; decrement pansweep delay
11C4: D5 80 03  MOV   $0380+X, A
11C7: F5 00 04  MOV   A, $0400+X
11CA: F0 04     BEQ   $11D0
11CC: 9C        DEC   A               ; decrement vibrato delay
11CD: D5 00 04  MOV   $0400+X, A
; fallthrough

; [ update volume and frequency ]

; once per cycle (tempo-independent)

11D0: 9B 49     DEC   $49+X
11D2: D0 42     BNE   $1216
11D4: E8 02     MOV   A, #$02         ; update every 2 cycles
11D6: D4 49     MOV   $49+X, A
11D8: F5 40 03  MOV   A, $0340+X
11DB: C4 22     MOV   $22, A
11DD: F5 41 03  MOV   A, $0341+X
11E0: F0 34     BEQ   $1216
11E2: C4 23     MOV   $23, A
11E4: 8D 00     MOV   Y, #$00
11E6: F7 22     MOV   A, ($22)+Y
11E8: D0 1A     BNE   $1204
11EA: D5 41 03  MOV   $0341+X, A
11ED: C8 10     CMP   X, #$10
11EF: B0 06     BCS   $11F7           ; branch if a sound effect
11F1: E4 8D     MOV   A, $8D
11F3: 24 78     AND   A, $78
11F5: D0 1F     BNE   $1216           ; branch if sound effect active
11F7: 7D        MOV   A, X
11F8: 9F        XCN   A
11F9: 5C        LSR   A
11FA: 08 05     OR    A, #$05         ; disable adsr
11FC: C4 F2     MOV   $F2, A
11FE: E8 00     MOV   A, #$00
1200: C4 F3     MOV   $F3, A
1202: 2F 12     BRA   $1216
1204: D5 60 03  MOV   $0360+X, A      ; set note envelope value
1207: 3A 22     INCW  $22
1209: E4 22     MOV   A, $22
120B: D5 40 03  MOV   $0340+X, A      ; increment note envelope counter
120E: E4 23     MOV   A, $23
1210: D5 41 03  MOV   $0341+X, A
1213: 09 8D 8B  OR    $8B, $8D
; tremolo
1216: F5 C1 03  MOV   A, $03C1+X      ; tremolo period
1219: F0 47     BEQ   $1262
121B: F5 C0 03  MOV   A, $03C0+X      ; tremolo delay
121E: D0 42     BNE   $1262
1220: F5 20 05  MOV   A, $0520+X      ; tremolo rate
1223: C4 28     MOV   $28, A
1225: F5 21 05  MOV   A, $0521+X
1228: C4 29     MOV   $29, A
122A: F5 E0 03  MOV   A, $03E0+X      ; tremolo period counter
122D: D0 1C     BNE   $124B
122F: BA 28     MOVW  YA, $28
1231: 48 FF     EOR   A, #$FF         ; invert tremolo rate
1233: C4 2A     MOV   $2A, A
1235: DD        MOV   A, Y
1236: 48 FF     EOR   A, #$FF
1238: C4 2B     MOV   $2B, A
123A: 3A 2A     INCW  $2A
123C: E4 2A     MOV   A, $2A
123E: D5 20 05  MOV   $0520+X, A
1241: E4 2B     MOV   A, $2B
1243: D5 21 05  MOV   $0521+X, A
1246: F5 C1 03  MOV   A, $03C1+X      ; reset tremolo period counter
1249: 2F 01     BRA   $124C
124B: 9C        DEC   A               ; decrement tremolo period counter
124C: D5 E0 03  MOV   $03E0+X, A
124F: F5 41 05  MOV   A, $0541+X      ; add rate to tremolo value
1252: FD        MOV   Y, A
1253: F5 40 05  MOV   A, $0540+X
1256: 7A 28     ADDW  YA, $28
1258: D5 40 05  MOV   $0540+X, A
125B: DD        MOV   A, Y
125C: D5 41 05  MOV   $0541+X, A
125F: 09 8D 8B  OR    $8B, $8D
; pansweep
1262: F5 81 03  MOV   A, $0381+X
1265: F0 47     BEQ   $12AE
1267: F5 80 03  MOV   A, $0380+X
126A: D0 42     BNE   $12AE
126C: F5 C0 04  MOV   A, $04C0+X
126F: C4 28     MOV   $28, A
1271: F5 C1 04  MOV   A, $04C1+X
1274: C4 29     MOV   $29, A
1276: F5 A0 03  MOV   A, $03A0+X
1279: D0 1C     BNE   $1297
127B: BA 28     MOVW  YA, $28
127D: 48 FF     EOR   A, #$FF
127F: C4 2A     MOV   $2A, A
1281: DD        MOV   A, Y
1282: 48 FF     EOR   A, #$FF
1284: C4 2B     MOV   $2B, A
1286: 3A 2A     INCW  $2A
1288: E4 2A     MOV   A, $2A
128A: D5 C0 04  MOV   $04C0+X, A
128D: E4 2B     MOV   A, $2B
128F: D5 C1 04  MOV   $04C1+X, A
1292: F5 81 03  MOV   A, $0381+X
1295: 2F 01     BRA   $1298
1297: 9C        DEC   A
1298: D5 A0 03  MOV   $03A0+X, A
129B: F5 E1 04  MOV   A, $04E1+X
129E: FD        MOV   Y, A
129F: F5 E0 04  MOV   A, $04E0+X
12A2: 7A 28     ADDW  YA, $28
12A4: D5 E0 04  MOV   $04E0+X, A
12A7: DD        MOV   A, Y
12A8: D5 E1 04  MOV   $04E1+X, A
12AB: 09 8D 8B  OR    $8B, $8D
; vibrato
12AE: F5 01 04  MOV   A, $0401+X      ; vibrato period
12B1: F0 76     BEQ   $1329
12B3: F5 00 04  MOV   A, $0400+X      ; vibrato delay counter
12B6: D0 71     BNE   $1329
12B8: F5 A0 05  MOV   A, $05A0+X      ; current vibrato amplitude
12BB: C4 28     MOV   $28, A
12BD: F5 A1 05  MOV   A, $05A1+X
12C0: C4 29     MOV   $29, A
12C2: F5 20 04  MOV   A, $0420+X      ; vibrato period counter
12C5: D0 41     BNE   $1308
12C7: BA 28     MOVW  YA, $28
12C9: F0 0A     BEQ   $12D5           ; branch if amplitude is already zero
12CB: E8 00     MOV   A, #$00         ; set vibrato amplitude to zero
12CD: D5 A0 05  MOV   $05A0+X, A
12D0: D5 A1 05  MOV   $05A1+X, A
12D3: 2F 2E     BRA   $1303
12D5: F5 80 04  MOV   A, $0480+X      ; increment vibrato envelope
12D8: 68 08     CMP   A, #$08         ; envelope lasts 8 periods
12DA: F0 04     BEQ   $12E0
12DC: BC        INC   A
12DD: D5 80 04  MOV   $0480+X, A
12E0: FD        MOV   Y, A
12E1: F5 01 04  MOV   A, $0401+X
12E4: CF        MUL   YA
12E5: CD 08     MOV   X, #$08
12E7: 9E        DIV   YA, X
12E8: F8 27     MOV   X, $27
12EA: FD        MOV   Y, A
12EB: 2D        PUSH  A
12EC: F5 60 05  MOV   A, $0560+X      ; vibrato rate * envelope
12EF: CF        MUL   YA
12F0: DA 2A     MOVW  $2A, YA
12F2: EE        POP   Y
12F3: F5 61 05  MOV   A, $0561+X
12F6: CF        MUL   YA
12F7: FD        MOV   Y, A
12F8: E8 00     MOV   A, #$00
12FA: 7A 2A     ADDW  YA, $2A         ; set current vibrato amplitude
12FC: D5 A0 05  MOV   $05A0+X, A
12FF: DD        MOV   A, Y
1300: D5 A1 05  MOV   $05A1+X, A
1303: F5 01 04  MOV   A, $0401+X      ; reset vibrato period counter
1306: 2F 01     BRA   $1309
1308: 9C        DEC   A               ; decrement vibrato period counter
1309: D5 20 04  MOV   $0420+X, A
130C: EB 29     MOV   Y, $29
130E: F5 C1 05  MOV   A, $05C1+X
1311: CF        MUL   YA
1312: DA 2A     MOVW  $2A, YA
1314: EB 29     MOV   Y, $29
1316: F5 C0 05  MOV   A, $05C0+X
1319: CF        MUL   YA
131A: DD        MOV   A, Y
131B: 8D 00     MOV   Y, #$00
131D: 7A 2A     ADDW  YA, $2A
131F: D5 E0 05  MOV   $05E0+X, A
1322: DD        MOV   A, Y
1323: D5 E1 05  MOV   $05E1+X, A
1326: 09 8D 8C  OR    $8C, $8D        ; enable frequency update
; volume update
1329: C8 10     CMP   X, #$10
132B: B0 0F     BCS   $133C           ; branch if a sound effect
132D: E4 8D     MOV   A, $8D
132F: 24 78     AND   A, $78
1331: F0 09     BEQ   $133C           ; branch if sound effect not active
1333: E4 8D     MOV   A, $8D
1335: 4E 8B 00  TCLR1 $008B           ; disable volume and frequency update
1338: 4E 8C 00  TCLR1 $008C
133B: 6F        RET   
133C: E4 8D     MOV   A, $8D
133E: 24 8B     AND   A, $8B
1340: F0 44     BEQ   $1386           ; branch if no volume update needed
1342: 4E 8B 00  TCLR1 $008B
1345: 7D        MOV   A, X
1346: 9F        XCN   A
1347: 5C        LSR   A
1348: C4 28     MOV   $28, A          ; channel's dsp volume register
134A: F5 01 02  MOV   A, $0201+X      ; volume
134D: FD        MOV   Y, A
134E: F5 60 03  MOV   A, $0360+X      ; note envelope
1351: CF        MUL   YA
1352: F5 41 05  MOV   A, $0541+X      ; tremolo
1355: F0 01     BEQ   $1358
1357: CF        MUL   YA
1358: C8 10     CMP   X, #$10
135A: B0 03     BCS   $135F           ; branch if a sound effect
135C: E4 43     MOV   A, $43
135E: CF        MUL   YA
135F: E8 48     MOV   A, #$48         ; volume is normalized to #$48
1361: CF        MUL   YA
1362: CB 29     MOV   $29, Y
1364: F5 21 02  MOV   A, $0221+X      ; pan value
1367: 60        CLRC  
1368: 95 E1 04  ADC   A, $04E1+X      ; pansweep
136B: 13 90 02  BBC   $90.0, $1370    ; branch if not mono output
136E: E8 80     MOV   A, #$80
1370: C4 2A     MOV   $2A, A
1372: 48 FF     EOR   A, #$FF         ; left volume
1374: CF        MUL   YA
1375: E4 28     MOV   A, $28
1377: C4 F2     MOV   $F2, A          ; set channel volume
1379: CB F3     MOV   $F3, Y
137B: AB 28     INC   $28
137D: 23 28 06  BBS   $28.1, $1386
1380: EB 2A     MOV   Y, $2A
1382: E4 29     MOV   A, $29          ; right volume
1384: 2F EE     BRA   $1374
; frequency update
1386: E4 8D     MOV   A, $8D
1388: 24 8C     AND   A, $8C
138A: F0 35     BEQ   $13C1           ; branch if no frequency update needed
138C: 4E 8C 00  TCLR1 $008C
138F: 7D        MOV   A, X
1390: 9F        XCN   A
1391: 5C        LSR   A
1392: BC        INC   A
1393: BC        INC   A
1394: C4 2A     MOV   $2A, A          ; channel's dsp pitch register
1396: F5 A0 02  MOV   A, $02A0+X      ; frequency
1399: C4 28     MOV   $28, A
139B: F5 A1 02  MOV   A, $02A1+X
139E: C4 29     MOV   $29, A
13A0: F5 61 06  MOV   A, $0661+X      ; pitch envelope
13A3: FD        MOV   Y, A
13A4: F5 60 06  MOV   A, $0660+X
13A7: 7A 28     ADDW  YA, $28
13A9: DA 28     MOVW  $28, YA
13AB: F5 E1 05  MOV   A, $05E1+X      ; vibrato
13AE: FD        MOV   Y, A
13AF: F5 E0 05  MOV   A, $05E0+X
13B2: 7A 28     ADDW  YA, $28
13B4: F8 2A     MOV   X, $2A
13B6: D8 F2     MOV   $F2, X          ; pitch low
13B8: C4 F3     MOV   $F3, A
13BA: 3D        INC   X
13BB: D8 F2     MOV   $F2, X          ; pitch high
13BD: CB F3     MOV   $F3, Y
13BF: F8 27     MOV   X, $27
13C1: 6F        RET   

; [ check interrupts ]

13C2: F8 F4     MOV   X, $F4
13C4: D8 8F     MOV   $8F, X
13C6: F0 67     BEQ   $142F
13C8: C8 01     CMP   X, #$01
13CA: D0 03     BNE   $13CF
13CC: 5F 32 14  JMP   $1432
13CF: C8 02     CMP   X, #$02
13D1: D0 03     BNE   $13D6
13D3: 5F AD 15  JMP   $15AD
13D6: C8 03     CMP   X, #$03
13D8: F0 F2     BEQ   $13CC
13DA: C8 04     CMP   X, #$04
13DC: F0 EE     BEQ   $13CC
13DE: C8 10     CMP   X, #$10
13E0: 90 07     BCC   $13E9
13E2: C8 20     CMP   X, #$20
13E4: B0 03     BCS   $13E9
13E6: 5F 53 16  JMP   $1653
13E9: C8 80     CMP   X, #$80
13EB: D0 03     BNE   $13F0
13ED: 5F D7 16  JMP   $16D7
13F0: C8 85     CMP   X, #$85
13F2: D0 03     BNE   $13F7
13F4: 5F E9 16  JMP   $16E9
13F7: C8 86     CMP   X, #$86
13F9: D0 03     BNE   $13FE
13FB: 5F F9 16  JMP   $16F9
13FE: C8 87     CMP   X, #$87
1400: D0 03     BNE   $1405
1402: 5F 09 17  JMP   $1709
1405: C8 88     CMP   X, #$88
1407: D0 03     BNE   $140C
1409: 5F 29 17  JMP   $1729
140C: C8 89     CMP   X, #$89
140E: D0 03     BNE   $1413
1410: 5F 5B 17  JMP   $175B
1413: C8 8A     CMP   X, #$8A
1415: D0 03     BNE   $141A
1417: 5F 42 17  JMP   $1742
141A: C8 8B     CMP   X, #$8B
141C: D0 03     BNE   $1421
141E: 5F 19 17  JMP   $1719
1421: C8 90     CMP   X, #$90
1423: D0 03     BNE   $1428
1425: 5F 6B 17  JMP   $176B
1428: C8 FF     CMP   X, #$FF
142A: D0 03     BNE   $142F
142C: 5F 82 17  JMP   $1782
142F: D8 F4     MOV   $F4, X          ; acknowledge interrupt
1431: 6F        RET   

; [ interrupt $01/$03/$04: play song ]

; $01/$03: full volume
; $04: fade in

1432: E8 00     MOV   A, #$00
1434: C4 88     MOV   $88, A          ; clear key on
1436: C4 78     MOV   $78, A          ; disable all sound effects
1438: C4 91     MOV   $91, A
143A: FD        MOV   Y, A
143B: DA 81     MOVW  $81, YA         ; disable echo in all channels
143D: DA 83     MOVW  $83, YA         ; disable noise in all channels
143F: C4 87     MOV   $87, A
1441: DA 85     MOVW  $85, YA         ; disable pitch mod. in all channels
1443: C4 7E     MOV   $7E, A
1445: C4 7F     MOV   $7F, A
1447: C4 80     MOV   $80, A
1449: C4 79     MOV   $79, A
144B: C4 40     MOV   $40, A          ; set echo volume to zero
144D: C4 41     MOV   $41, A
144F: 9C        DEC   A
1450: C4 89     MOV   $89, A          ; set key off in all channels
1452: E8 FF     MOV   A, #$FF
1454: 8D 5C     MOV   Y, #$5C         ; key off
1456: 3F E9 10  CALL  $10E9           ; set dsp register
1459: 8F 00 F5  MOV   $F5, #$00       ; clear port 1
145C: 8F 00 22  MOV   $22, #$00       ; $2000 (song script)
145F: 8F 20 23  MOV   $23, #$20
1462: 8D 00     MOV   Y, #$00
1464: E4 F6     MOV   A, $F6          ; transfer 1 byte at a time
1466: D7 22     MOV   ($22)+Y, A
1468: 3A 22     INCW  $22
146A: D8 F4     MOV   $F4, X          ; wait for response
146C: 3E F4     CMP   X, $F4
146E: F0 FC     BEQ   $146C
1470: F8 F4     MOV   X, $F4
1472: D0 F0     BNE   $1464
1474: E4 F5     MOV   A, $F5
1476: F0 1A     BEQ   $1492
1478: 10 0A     BPL   $1484
; $FF: no transfer needed
147A: D8 F4     MOV   $F4, X
147C: 3E F4     CMP   X, $F4
147E: F0 FC     BEQ   $147C
1480: F8 F4     MOV   X, $F4
1482: 2F 78     BRA   $14FC
; $11: transfer all samples
1484: 68 22     CMP   A, #$22
1486: F0 42     BEQ   $14CA
1488: D8 F4     MOV   $F4, X
148A: 3E F4     CMP   X, $F4
148C: F0 FC     BEQ   $148A
148E: F8 F4     MOV   X, $F4
1490: 2F 46     BRA   $14D8
; 0: move samples
1492: E4 F5     MOV   A, $F5
1494: D0 34     BNE   $14CA           ; branch if done moving samples
1496: BA F6     MOVW  YA, $F6         ; sample source
1498: DA 24     MOVW  $24, YA
149A: D8 F4     MOV   $F4, X
149C: 3E F4     CMP   X, $F4
149E: F0 FC     BEQ   $149C
14A0: BA F6     MOVW  YA, $F6         ; sample destination
14A2: DA 22     MOVW  $22, YA
14A4: F8 F4     MOV   X, $F4
14A6: D8 F4     MOV   $F4, X
14A8: 3E F4     CMP   X, $F4
14AA: F0 FC     BEQ   $14A8
14AC: BA F6     MOVW  YA, $F6         ; sample size
14AE: DA 28     MOVW  $28, YA
14B0: F8 F4     MOV   X, $F4
14B2: D8 F4     MOV   $F4, X
14B4: 3E F4     CMP   X, $F4
14B6: F0 FC     BEQ   $14B4
14B8: F8 F4     MOV   X, $F4
14BA: 8D 00     MOV   Y, #$00
14BC: F7 24     MOV   A, ($24)+Y
14BE: D7 22     MOV   ($22)+Y, A
14C0: 3A 24     INCW  $24
14C2: 3A 22     INCW  $22
14C4: 1A 28     DECW  $28
14C6: D0 F4     BNE   $14BC
14C8: 2F C8     BRA   $1492
; $22: next sample
14CA: BA F6     MOVW  YA, $F6         ; sample destination
14CC: DA 22     MOVW  $22, YA
14CE: D8 F4     MOV   $F4, X
14D0: 3E F4     CMP   X, $F4
14D2: F0 FC     BEQ   $14D0
14D4: F8 F4     MOV   X, $F4
14D6: 2F 06     BRA   $14DE
14D8: 8F 00 22  MOV   $22, #$00       ; $3000 (sample brr data)
14DB: 8F 30 23  MOV   $23, #$30
14DE: 8D 00     MOV   Y, #$00
14E0: E4 F5     MOV   A, $F5          ; transfer 3 bytes at a time
14E2: D7 22     MOV   ($22)+Y, A
14E4: 3A 22     INCW  $22
14E6: E4 F6     MOV   A, $F6
14E8: D7 22     MOV   ($22)+Y, A
14EA: 3A 22     INCW  $22
14EC: E4 F7     MOV   A, $F7
14EE: D7 22     MOV   ($22)+Y, A
14F0: 3A 22     INCW  $22
14F2: D8 F4     MOV   $F4, X
14F4: 3E F4     CMP   X, $F4
14F6: F0 FC     BEQ   $14F4
14F8: F8 F4     MOV   X, $F4
14FA: D0 E4     BNE   $14E0
14FC: 8F 00 22  MOV   $22, #$00       ; $1F00 (pointers to samples)
14FF: 8F 1F 23  MOV   $23, #$1F
1502: E4 F6     MOV   A, $F6          ; transfer 2 bytes at a time
1504: D7 22     MOV   ($22)+Y, A
1506: 3A 22     INCW  $22
1508: E4 F7     MOV   A, $F7
150A: D7 22     MOV   ($22)+Y, A
150C: 3A 22     INCW  $22
150E: D8 F4     MOV   $F4, X
1510: 3E F4     CMP   X, $F4
1512: F0 FC     BEQ   $1510
1514: F8 F4     MOV   X, $F4
1516: D0 EA     BNE   $1502
1518: 8F 40 22  MOV   $22, #$40       ; $FF40 (sample frequency multipliers)
151B: 8F FF 23  MOV   $23, #$FF
151E: E4 F6     MOV   A, $F6
1520: D7 22     MOV   ($22)+Y, A      ; transfer 1 byte at a time
1522: 3A 22     INCW  $22
1524: D8 F4     MOV   $F4, X
1526: 3E F4     CMP   X, $F4
1528: F0 FC     BEQ   $1526
152A: F8 F4     MOV   X, $F4
152C: D0 F0     BNE   $151E
152E: D8 F4     MOV   $F4, X
1530: 8D 01     MOV   Y, #$01
1532: CB 8D     MOV   $8D, Y
1534: CD 00     MOV   X, #$00
1536: F5 00 20  MOV   A, $2000+X      ; set channel script pointers
1539: D4 02     MOV   $02+X, A
153B: F5 01 20  MOV   A, $2001+X
153E: D4 03     MOV   $03+X, A
1540: F0 0A     BEQ   $154C           ; branch if channel is unused
1542: DB 48     MOV   $48+X, Y        ; set channel tick counter to 1
1544: 7D        MOV   A, X
1545: 1C        ASL   A
1546: 9C        DEC   A
1547: D5 81 06  MOV   $0681+X, A      ; set loop depth
154A: E8 00     MOV   A, #$00
154C: D5 61 04  MOV   $0461+X, A
154F: D5 01 04  MOV   $0401+X, A
1552: D5 C1 03  MOV   $03C1+X, A
1555: D5 81 03  MOV   $0381+X, A
1558: D5 40 02  MOV   $0240+X, A
155B: D5 41 02  MOV   $0241+X, A
155E: D5 80 02  MOV   $0280+X, A
1561: D5 81 02  MOV   $0281+X, A
1564: 3D        INC   X               ; next channel
1565: 3D        INC   X
1566: 0B 8D     ASL   $8D
1568: D0 CC     BNE   $1536
156A: E8 00     MOV   A, #$00         ; clear sound effect script pointers
156C: D4 03     MOV   $03+X, A
156E: 3D        INC   X
156F: 3D        INC   X
1570: C8 20     CMP   X, #$20
1572: D0 F8     BNE   $156C
1574: 78 04 8F  CMP   $8F, #$04
1577: F0 0E     BEQ   $1587
1579: 8F FF 42  MOV   $42, #$FF       ; full volume
157C: 8F FF 43  MOV   $43, #$FF
157F: 8F 00 46  MOV   $46, #$00
1582: 8F 00 47  MOV   $47, #$00
1585: 2F 0C     BRA   $1593
1587: 8F 00 42  MOV   $42, #$00       ; zero volume
158A: 8F 00 43  MOV   $43, #$00
158D: 8F 70 46  MOV   $46, #$70       ; fade in
1590: 8F 00 47  MOV   $47, #$00
1593: 8F 01 37  MOV   $37, #$01
1596: 8F FF 38  MOV   $38, #$FF
1599: E8 FF     MOV   A, #$FF
159B: 8D 5C     MOV   Y, #$5C         ; key off
159D: 3F E9 10  CALL  $10E9           ; set dsp register
15A0: 8F 05 7A  MOV   $7A, #$05       ; echo delay: 80ms
15A3: 3F 12 10  CALL  $1012           ; update noise enable in dsp
15A6: 3F 5B 0F  CALL  $0F5B           ; update noise clock in dsp
15A9: 3F 3F 10  CALL  $103F           ; update pitch modulation in dsp
15AC: 6F        RET   

; [ interrupt $02: play game sound effect ]

15AD: D8 F4     MOV   $F4, X
15AF: 3E F4     CMP   X, $F4
15B1: F0 FC     BEQ   $15AF
15B3: 8F 00 F4  MOV   $F4, #$00
15B6: E4 F6     MOV   A, $F6
15B8: C5 3D 02  MOV   $023D, A
15BB: C5 3F 02  MOV   $023F, A
15BE: 8F 00 22  MOV   $22, #$00       ; $FD00 (pointers to game sound effects)
15C1: 8F FD 23  MOV   $23, #$FD
15C4: E4 F5     MOV   A, $F5          ; sound effect id
15C6: 8D 04     MOV   Y, #$04
15C8: CF        MUL   YA
15C9: 7A 22     ADDW  YA, $22
15CB: DA 22     MOVW  $22, YA
15CD: E8 C0     MOV   A, #$C0         ; channel 6 and 7
15CF: 8D 5C     MOV   Y, #$5C         ; key off
15D1: 3F E9 10  CALL  $10E9           ; set dsp register
15D4: 4E 91 00  TCLR1 $0091           ; disable system sound effect
15D7: CD 1C     MOV   X, #$1C         ; channel 6
15D9: 8F 40 8D  MOV   $8D, #$40
15DC: 8D 00     MOV   Y, #$00
15DE: CB 78     MOV   $78, Y
15E0: F7 22     MOV   A, ($22)+Y      ; load 1st channel script pointer
15E2: C4 28     MOV   $28, A
15E4: FC        INC   Y
15E5: F7 22     MOV   A, ($22)+Y
15E7: C4 29     MOV   $29, A
15E9: FC        INC   Y
15EA: 6D        PUSH  Y
15EB: F7 22     MOV   A, ($22)+Y      ; load 2nd channel script pointer
15ED: 2D        PUSH  A
15EE: FC        INC   Y
15EF: F7 22     MOV   A, ($22)+Y
15F1: FD        MOV   Y, A
15F2: AE        POP   A
15F3: 5A 28     CMPW  YA, $28
15F5: EE        POP   Y
15F6: F0 04     BEQ   $15FC           ; branch if both script pointers are equal
15F8: E4 29     MOV   A, $29
15FA: D0 08     BNE   $1604
; channel is not used
15FC: E8 00     MOV   A, #$00
15FE: D4 02     MOV   $02+X, A
1600: D4 03     MOV   $03+X, A
1602: 2F 23     BRA   $1627
; channel is used
1604: E4 28     MOV   A, $28          ; set script pointer
1606: D4 02     MOV   $02+X, A
1608: E4 29     MOV   A, $29
160A: D4 03     MOV   $03+X, A
160C: 09 8D 78  OR    $78, $8D        ; sound effect channel active
160F: E8 01     MOV   A, #$01
1611: D4 48     MOV   $48+X, A        ; set tick counter
1613: 7D        MOV   A, X
1614: 1C        ASL   A
1615: 9C        DEC   A
1616: D5 81 06  MOV   $0681+X, A
1619: E8 00     MOV   A, #$00
161B: D5 61 04  MOV   $0461+X, A
161E: D5 01 04  MOV   $0401+X, A
1621: D5 C1 03  MOV   $03C1+X, A
1624: D5 81 03  MOV   $0381+X, A
1627: 3D        INC   X               ; next channel
1628: 3D        INC   X
1629: 0B 8D     ASL   $8D
162B: D0 B3     BNE   $15E0
162D: E4 78     MOV   A, $78
162F: 09 91 78  OR    $78, $91
1632: 4E 88 00  TCLR1 $0088          ; clear key on
1635: E8 C0     MOV   A, #$C0
1637: 4E 82 00  TCLR1 $0082
163A: 4E 84 00  TCLR1 $0084
163D: 4E 86 00  TCLR1 $0086          ; disable pitch modulation
1640: 8F 00 87  MOV   $87, #$00
1643: 3F 3C 0E  CALL  $0E3C           ; update echo enable in dsp
1646: 3F 12 10  CALL  $1012           ; update noise enable in dsp
1649: 3F 3F 10  CALL  $103F           ; update pitch modulation in dsp
164C: 3F 5B 0F  CALL  $0F5B           ; update noise clock in dsp
164F: 8F 88 39  MOV   $39, #$88
1652: 6F        RET   

; [ interrupt $10-$1F: play system sound effect ]

1653: D8 F4     MOV   $F4, X
1655: 3E F4     CMP   X, $F4
1657: F0 FC     BEQ   $1655
1659: 8F 00 F4  MOV   $F4, #$00
165C: 7D        MOV   A, X
165D: 28 0F     AND   A, #$0F
165F: 1C        ASL   A
1660: FD        MOV   Y, A
1661: E3 91 09  BBS   $91.7, $166D    ; branch if another system sound effect in progress
1664: C3 91 10  BBS   $91.6, $1677
1667: A3 91 14  BBS   $91.5, $167E
166A: E3 78 07  BBS   $78.7, $1674    ; branch if a game sound effect in channel 7
; play in channel 7
166D: CD 1E     MOV   X, #$1E
166F: 8F 80 8D  MOV   $8D, #$80
1672: 2F 0F     BRA   $1683
; play in channel 6
1674: C3 78 07  BBS   $78.6, $167E
1677: CD 1C     MOV   X, #$1C
1679: 8F 40 8D  MOV   $8D, #$40
167C: 2F 05     BRA   $1683
; play in channel 5
167E: CD 1A     MOV   X, #$1A
1680: 8F 20 8D  MOV   $8D, #$20
1683: F6 E0 18  MOV   A, $18E0+Y      ; pointers to system sound effects
1686: D4 02     MOV   $02+X, A
1688: F6 E1 18  MOV   A, $18E1+Y
168B: D4 03     MOV   $03+X, A
168D: F0 47     BEQ   $16D6
168F: E4 8D     MOV   A, $8D
1691: 8D 5C     MOV   Y, #$5C
1693: 3F E9 10  CALL  $10E9           ; set dsp register
1696: 4E 88 00  TCLR1 $0088
1699: E8 80     MOV   A, #$80
169B: D5 21 02  MOV   $0221+X, A
169E: E8 01     MOV   A, #$01
16A0: D4 48     MOV   $48+X, A
16A2: 7D        MOV   A, X
16A3: 1C        ASL   A
16A4: 9C        DEC   A
16A5: D5 81 06  MOV   $0681+X, A
16A8: E8 00     MOV   A, #$00
16AA: D5 61 04  MOV   $0461+X, A
16AD: D5 01 04  MOV   $0401+X, A
16B0: D5 C1 03  MOV   $03C1+X, A
16B3: D5 81 03  MOV   $0381+X, A
16B6: D5 00 02  MOV   $0200+X, A
16B9: D5 20 02  MOV   $0220+X, A
16BC: 09 8D 78  OR    $78, $8D        ; enable sound effect
16BF: 09 8D 91  OR    $91, $8D        ; enable system sound effect
16C2: E4 8D     MOV   A, $8D
16C4: 4E 82 00  TCLR1 $0082
16C7: 4E 84 00  TCLR1 $0084
16CA: 4E 86 00  TCLR1 $0086
16CD: 3F 3C 0E  CALL  $0E3C           ; update echo enable in dsp
16D0: 3F 12 10  CALL  $1012           ; update noise enable in dsp
16D3: 3F 3F 10  CALL  $103F           ; update pitch modulation in dsp
16D6: 6F        RET   

; [ interrupt $80: set sound effect pan ]

16D7: E4 F5     MOV   A, $F5
16D9: C5 3D 02  MOV   $023D, A
16DC: C5 3F 02  MOV   $023F, A
16DF: D8 F4     MOV   $F4, X
16E1: 3E F4     CMP   X, $F4
16E3: F0 FC     BEQ   $16E1
16E5: 8F 00 F4  MOV   $F4, #$00
16E8: 6F        RET   

; [ interrupt $85: fade out (slow) ]

16E9: D8 F4     MOV   $F4, X
16EB: 3E F4     CMP   X, $F4
16ED: F0 FC     BEQ   $16EB
16EF: 8F 00 F4  MOV   $F4, #$00
16F2: 8F 90 46  MOV   $46, #$90
16F5: 8F FF 47  MOV   $47, #$FF
16F8: 6F        RET   

; [ interrupt $86: fade out (fast) ]

16F9: D8 F4     MOV   $F4, X
16FB: 3E F4     CMP   X, $F4
16FD: F0 FC     BEQ   $16FB
16FF: 8F 00 F4  MOV   $F4, #$00
1702: 8F 00 46  MOV   $46, #$00
1705: 8F FE 47  MOV   $47, #$FE
1708: 6F        RET   

; [ interrupt $87: fade to half volume ]

1709: D8 F4     MOV   $F4, X
170B: 3E F4     CMP   X, $F4
170D: F0 FC     BEQ   $170B
170F: 8F 00 F4  MOV   $F4, #$00
1712: 8F C8 46  MOV   $46, #$C8
1715: 8F FF 47  MOV   $47, #$FF
1718: 6F        RET   

; [ interrupt $8B: fade out ]

1719: D8 F4     MOV   $F4, X
171B: 3E F4     CMP   X, $F4
171D: F0 FC     BEQ   $171B
171F: 8F 00 F4  MOV   $F4, #$00
1722: 8F 46 46  MOV   $46, #$46
1725: 8F FF 47  MOV   $47, #$FF
1728: 6F        RET   

; [ interrupt $88: full volume ]

1729: D8 F4     MOV   $F4, X
172B: 3E F4     CMP   X, $F4
172D: F0 FC     BEQ   $172B
172F: 8F 00 F4  MOV   $F4, #$00
1732: 8F 00 46  MOV   $46, #$00
1735: 8F 00 47  MOV   $47, #$00
1738: 8F FF 42  MOV   $42, #$FF
173B: 8F FF 43  MOV   $43, #$FF
173E: 8F FF 8B  MOV   $8B, #$FF
1741: 6F        RET   

; [ interrupt $8A: quarter volume ]

1742: D8 F4     MOV   $F4, X
1744: 3E F4     CMP   X, $F4
1746: F0 FC     BEQ   $1744
1748: 8F 00 F4  MOV   $F4, #$00
174B: 8F 00 46  MOV   $46, #$00
174E: 8F 00 47  MOV   $47, #$00
1751: 8F 00 42  MOV   $42, #$00
1754: 8F 40 43  MOV   $43, #$40
1757: 8F FF 8B  MOV   $8B, #$FF
175A: 6F        RET   

; [ interrupt $89: fade in ]

175B: D8 F4     MOV   $F4, X
175D: 3E F4     CMP   X, $F4
175F: F0 FC     BEQ   $175D
1761: 8F 00 F4  MOV   $F4, #$00
1764: 8F 38 46  MOV   $46, #$38
1767: 8F 00 47  MOV   $47, #$00
176A: 6F        RET   

; [ interrupt $90: set/clear mono ]

176B: E4 F5     MOV   A, $F5
176D: D0 04     BNE   $1773
176F: 12 90     CLR   $90.0
1771: 2F 02     BRA   $1775
1773: 02 90     SET   $90.0
1775: D8 F4     MOV   $F4, X
1777: 3E F4     CMP   X, $F4
1779: F0 FC     BEQ   $1777
177B: 8F 00 F4  MOV   $F4, #$00
177E: 8F FF 8B  MOV   $8B, #$FF
1781: 6F        RET   

; [ interrupt $FF: reset ]

1782: E8 FF     MOV   A, #$FF
1784: 8D 5C     MOV   Y, #$5C         ; key off
1786: 3F E9 10  CALL  $10E9           ; set dsp register
1789: 8F AA F4  MOV   $F4, #$AA
178C: 8F BB F5  MOV   $F5, #$BB
178F: 3E F4     CMP   X, $F4
1791: F0 FC     BEQ   $178F
1793: F8 F4     MOV   X, $F4
1795: C8 CC     CMP   X, #$CC
1797: D0 FA     BNE   $1793
1799: D8 F4     MOV   $F4, X
179B: F8 F4     MOV   X, $F4
179D: D0 FC     BNE   $179B
179F: D8 28     MOV   $28, X
17A1: AB 28     INC   $28
17A3: D8 F4     MOV   $F4, X
17A5: 3E F4     CMP   X, $F4
17A7: F0 FC     BEQ   $17A5
17A9: F8 F4     MOV   X, $F4
17AB: 3E 28     CMP   X, $28
17AD: F0 F2     BEQ   $17A1
17AF: E4 F5     MOV   A, $F5
17B1: D8 F4     MOV   $F4, X
17B3: D0 E6     BNE   $179B
17B5: 3E F4     CMP   X, $F4
17B7: F0 FC     BEQ   $17B5
17B9: C4 F4     MOV   $F4, A
17BB: C4 F5     MOV   $F5, A
17BD: E8 00     MOV   A, #$00
17BF: C4 88     MOV   $88, A
17C1: C4 78     MOV   $78, A
17C3: FD        MOV   Y, A
17C4: DA 81     MOVW  $81, YA
17C6: DA 83     MOVW  $83, YA
17C8: DA 85     MOVW  $85, YA
17CA: C4 7E     MOV   $7E, A
17CC: C4 7F     MOV   $7F, A
17CE: C4 80     MOV   $80, A
17D0: C4 79     MOV   $79, A
17D2: C4 40     MOV   $40, A
17D4: C4 41     MOV   $41, A
17D6: 5D        MOV   X, A
17D7: D4 02     MOV   $02+X, A        ; clear all script pointers
17D9: 3D        INC   X
17DA: C8 20     CMP   X, #$20
17DC: D0 F9     BNE   $17D7
17DE: 9C        DEC   A
17DF: C4 89     MOV   $89, A
17E1: 8F 01 7A  MOV   $7A, #$01       ; echo delay: 16ms
17E4: 3F 12 10  CALL  $1012           ; update noise enable in dsp
17E7: 3F 3F 10  CALL  $103F           ; update pitch modulation in dsp
17EA: 5F 82 10  JMP   $1082           ; set echo delay

; --------------------------------------------------------------------------

; sound command jump table
17ED:           0CF4 0D47 0D4E 0E0B 0E5F 0E8E  ; $D2
17F9: 0EC0 0EE9 0CDE 0F13 0F1E 0F2D 0F37 0F4D
1809: 0F78 0CDE 0CDE 105C 1004 1005 0E8A 0EBC  ; $E0
1819: 0EE5 0F0F 0E2B 0E47 1006 101F 1033 104C
1829: 0F9B 105D 0D57 0DB1 0FFB 0FBF 0FF0 105D  ; $F0
1839: 105D 105D 105D 105D 105D 105D 105D 105D

; number of parameter bytes for sound commands
1849:       03 03 01 02 03 03 03 03 01 01 01 01 01 01  ; $D2
1857: 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ; $E0
1867: 00 00 03 03 02 03 00 00 00 00 00 00 00 00 00 00  ; $F0

; frequency values
1877: 0879 08FA 0983 0A14 0AAD 0B50 0BFC 0CB2
1887: 0D74 0E41 0F1A 1000 10F3

; fir filter values
1891: 7F 00 00 00 00 00 00 00
1899: 0C 21 2B 2B 13 FE F3 F9
18A1: 58 BF DB F0 FE 07 0C 0C
18A9: 34 33 00 D9 E5 01 FC EB

; note durations
18B1: C0 90 60 48 40 30 24 20 18 10 0C 08 06 04 03

; gain values
18C0: A0 A1 A2 A3 A4 A5 A6 A7 A8 A9 AA AB AC AD AE AF
18D0: B0 B1 B2 B3 B4 B5 B6 B7 B8 B9 BA BB BC BD BE BF

; pointers to system sound effects
18E0: 1900 1912 1924 1938 194A 0000 0000 0000
18F0: 195C 1983 0000 0000 0000 0000 0000 0000

; system sound effects

; $10: 
1900: F2 00 00 78  ; volume: 120
1904: DC 0D        ; note envelope: 13
1906: DB 05        ; sample: 5
1908: DD 00        ; gain: 0
190A: D6 00 06 0C  ; pitch envelope: duration = 6, amplitude = 12
190E: DA 06        ; octave: 6
1910: 74           ; G 16th note triplet
1911: F1           ; end of channel

; $11: cursor
1912: F2 00 00 78  ; volume: 120
1916: DC 0D        ; note envelope: 13
1918: DB 05        ; sample: 5
191A: DD 00        ; gain: 0
191C: D6 00 06 0C  ; pitch envelope: duration = 6, amplitude = 12
1920: DA 06        ; octave: 6
1922: A1           ; Bb 16th note triplet
1923: F1           ; end of channel

; $12: error
1924: F2 00 00 FF  ; volume: 255
1928: DC 0D        ; note envelope: 13
192A: DD 00        ; gain: 0
192C: DA 04        ; octave: 4
192E: E0 03        ; loop start (3 times)
1930: DB 04        ; sample: 4
1932: 3B           ; Eb 64th note
1933: DB 03        ; sample: 3
1935: 3B           ; Eb 64th note
1936: F0           ; loop end
1937: F1           ; end of channel

; $13: move cursor ??? (load)
1938: F2 00 00 C8  ; volume: 200
193C: DC 0D        ; note envelope: 13
193E: DB 05        ; sample: 5
1940: DD 00        ; gain: 0
1942: D6 00 06 0C  ; pitch envelope: duration = 6, amplitude = 12
1946: DA 06        ; octave: 6
1948: 74           ; G 16th note triplet
1949: F1           ; end of channel

; $14: confirm ??? (loud)
194A: F2 00 00 C8  ; volume: 200
194E: DC 0D        ; note envelope: 13
1950: DB 05        ; sample: 5
1952: DD 00        ; gain: 0
1954: D6 00 06 0C  ; pitch envelope: duration = 6, amplitude = 12
1958: DA 06        ; octave: 6
195A: A1           ; Bb 16th note triplet
195B: F1           ; end of channel

; $18:
195C: F2 00 00 E6  ; volume: 230
1960: D8 00 0C FF  ; enable vibrato
1964: DC 09        ; note envelope: 9
1966: DB 03        ; sample: 3
1968: DD 08        ; gain: 8
196A: DA 05        ; octave: 5
196C: 92           ; A 16th note triplet
196D: E1           ; increment octave
196E: F2 00 00 BE  ; volume: 190
1972: 47           ; E 16th note triplet
1976: F2 00 00 A0  ; volume: 160
1977: 47           ; E 16th note triplet
1978: F2 00 00 82  ; volume: 130
197C: 47           ; E 16th note triplet
197D: F2 00 00 64  ; volume: 100
1981: 47           ; E 16th note triplet
1982: F1           ; end of channel

; $19:
1983: F2 00 00 E6  ; volume: 230
1987: D8 00 0C FF  ; enable vibrato
198B: DC 09        ; note envelope: 9
198D: DB 03        ; sample: 3
198F: DD 08        ; gain: 8
1991: DA 05        ; octave: 5
1993: 47           ; E 16th note triplet
1994: F2 00 00 BE  ; volume: 190
1998: B0           ; B 16th note triplet
1999: F2 00 00 A0  ; volume: 160
199D: B0           ; B 16th note triplet
199E: F2 00 00 82  ; volume: 130
19A2: B0           ; B 16th note triplet
19A3: F2 00 00 64  ; volume: 100
19A7: B0           ; B 16th note triplet
19A8: F1           ; end of channel

; --------------------------------------------------------------------------
