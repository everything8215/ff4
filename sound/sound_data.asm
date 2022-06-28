
.segment "sound_data"

; 04/c000
SoundData:

SongScriptPtrsOffset:
        .faraddr SongScriptPtrs - SoundData

BRRSamplePtrsOffset:
        .faraddr BRRSamplePtrs - SoundData

SongSamplesOffset:
        .faraddr SongSamples - SoundData

SampleLoopStartOffset:
        .faraddr SampleLoopStart - SoundData

SampleFreqMultOffset:
        .faraddr SampleFreqMult - SoundData

; 04/c00f
        .include "data/song_sample.asm"

; 04/c8cf
        .include "data/sample_loop_start.asm"

; 04/c92b
        .include "data/sample_freq_mult.asm"

; 04/c942
BRRSamplePtrs:
        .faraddr 0
        make_ptr_tbl_far BRRSample, 22, SoundData
        .faraddr 0

; 04/c98a
        .include "data/brr_sample.asm"

; 06/f21d
SongScriptPtrs:
        make_ptr_tbl_far SongScript, 70, SoundData

; 06/f2ef
        .include "data/song_script.asm"
