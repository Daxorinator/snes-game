; ==============
;   DIRECTIVES
; ==============
.p816 ; Tell assembler that we're working with 65816
.smart ; Tell assembler to automatically adjust register size depending on REP changes, e.g macros like A8, AXY16, etc.

; ============
;   INCLUDES
; ============
.include "defines.asm"
.include "macros.asm"
.include "init.asm"
.include "header.asm"

; ========
;   CODE
; ========

.segment "CODE"

main:
.a16
.i16

    phk
    plb ; Setup for FastROM

    A8  ; Set A to 8-bit
    XY16; Set X/Y to 16-bit

    LoadPalette BG_Palette, 0, 128

    LoadBlockToVRAM Tiles, $2118, (End_Tiles - Tiles)

    LoadBlockToVRAM Tilemap, $6000, $700
    
    lda #1 ; Mode 1, tilesize 8x8
    sta bg_size_mode

    stz bg12_tiles ; tiles for BG 1+2 at VRAM addr $0000

    lda #$60 ; BG1 is at VRAM addr $6000
    sta tilemap1 ; $2107

    lda #BG1_ON ; $01 = only BG1 is active
    sta main_screen ; $212c

    ; Turn on the screen by storing full brightness to screen register
    lda #FULL_BRIGHT ; Equiv to $0f
    sta fb_bright ; Equiv to $2100

GameLoop:
    jmp GameLoop

.segment "RODATA1"

BG_Palette:
    .incbin "assets/red-bg/red-bg.pal" ; 32 Bytes

Tiles:
    .incbin "assets/red-bg/red-bg.chr" ; 4bpp tileset
End_Tiles:

Tilemap:
    .incbin "assets/red-bg/red-bg.map" ; $700 bytes