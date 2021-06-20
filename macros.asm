; SNES Macros

;============================================================================
;LoadPalette - Macro that loads palette information into CGRAM
;----------------------------------------------------------------------------
; In: SRC_ADDR -- 24 bit address of source data,
;     START -- Color # to start on,
;     SIZE -- # of COLORS to copy
;----------------------------------------------------------------------------
; Out: None
;----------------------------------------------------------------------------
; Modifies: A,X
; Requires: mem/A = 8 bit, X/Y = 16 bit
;----------------------------------------------------------------------------
.macro LoadPalette SRC_ADDR, START, SIZE
    lda #START
    sta pal_addr
    lda #^SRC_ADDR    ; Using ^ before the parameter gets its bank.
    ldx #.loword(SRC_ADDR)
    ldy #(SIZE * 2)   ; 2 bytes for every color
    jsr DMAPalette
.endmacro

;============================================================================
; DMAPalette -- Load entire palette using DMA
;----------------------------------------------------------------------------
; In: A:X  -- points to the data
;      Y   -- Size of data
;----------------------------------------------------------------------------
; Out: None
;----------------------------------------------------------------------------
; Modifies: none
;----------------------------------------------------------------------------
DMAPalette:
    phb
    php         ; Preserve Registers

    stx dma_src_L   ; Store data offset into DMA source offset
    sta dma_src_H   ; Store data bank into DMA source bank
    sty dma_size_L   ; Store size of data block

    stz dma_control   ; Set DMA Mode (byte, normal increment)
    lda #$22    ; Set destination register ($2122 = CGRAM Write low byte)
    sta dma_dst_reg
    lda #1    ; Initiate DMA transfer
    sta dma_enable

    plp
    plb
    rts         ; return from subroutine

;============================================================================
; LoadBlockToVRAM -- Macro that simplifies calling LoadVRAM to copy data to VRAM
;----------------------------------------------------------------------------
; In: SRC_ADDR -- 24 bit address of source data
;     DEST -- VRAM address to write to (WORD address!!)
;     SIZE -- number of BYTEs to copy
;----------------------------------------------------------------------------

; Out: None
;----------------------------------------------------------------------------
; Modifies: A, X, Y
;----------------------------------------------------------------------------

;LoadBlockToVRAM SRC_ADDRESS, DEST, SIZE
;   requires:  mem/A = 8 bit, X/Y = 16 bit
.macro LoadBlockToVRAM SRC_ADDR, DEST, SIZE
    lda #V_INC_1
    sta vram_inc       ; Set VRAM transfer mode to word-access, increment by 1

    ldx #DEST       ; DEST
    stx vram_addr       ; $2116: Word address for accessing VRAM.
    
    lda #^SRC_ADDR        ; SRCBANK
    ldx #.loword(SRC_ADDR)         ; SRCOFFSET
    ldy #SIZE         ; SIZE
    
    jsr LoadVRAM
.endmacro

;============================================================================
; LoadVRAM -- Load data into VRAM
;----------------------------------------------------------------------------
; In: A:X  -- points to the data
;     Y     -- Number of bytes to copy (0 to 65535)  (assumes 16-bit index)
;----------------------------------------------------------------------------
; Out: None
;----------------------------------------------------------------------------
; Modifies: none
;----------------------------------------------------------------------------
; Notes:  Assumes VRAM address has been previously set!!
;----------------------------------------------------------------------------
LoadVRAM:
    phb
    php         ; Preserve Registers

    stx dma_src_L   ; Store Data offset into DMA source offset
    sta dma_src_H   ; Store data Bank into DMA source bank
    sty dma_size_L  ; Store size of data block

    lda #1
    sta dma_control   ; Set DMA mode (word, normal increment)
    
    lda #$18    ; Set the destination register $21xx (2118 = VRAM write low byte)
    sta dma_dst_reg
    
    lda #1   ; Initiate DMA transfer (channel 1)
    sta dma_enable

    plp         ; restore registers
    plb
    rts         ; return

.macro A8
	sep #$20
.endmacro

.macro A16
	rep #$20
.endmacro

.macro AXY8
	sep #$30
.endmacro

.macro AXY16
	rep #$30
.endmacro

.macro XY8
	sep #$10
.endmacro

.macro XY16
	rep #$10
.endmacro
