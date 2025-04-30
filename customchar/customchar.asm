; VIC-20 Character Redefinition Program
; redefines a number of characters starting from @ and displays them on screen

; uses tass64 assembler

; Memory map reference:
; $1000-$1DFF: BASIC program area (we'll put our program here)
; $1E00-$1FFF: Screen memory (where characters are displayed)
; $9005: Character base register (bits 0-3 determine character set location)
; $9600-$97FF: Default location for custom character set (8K boundary)

.cpu "6502"

NCHARS = ((CHARDATA_END - CHARDATA) / 8) ; number of redefined characters
N_SCR_COLS = 22
N_SCR_ROWS = 23
START_SCR = $1E00                 ; 7680 unexpanded
START_COLOUR = $9600              ; 38400 unexpanded
START_BASIC_PRG = $1001           ; 4097 unexpanded
VIC_CHARBASE = $9005              ; 37869
CHARDEF_BASE = $1c00               ; 7168
UPPERCASE_BASE = $8000            ; 32768 upper/graphics chars in ROM
BORDER_COLOUR = $900f             ; 36879

; Basic launcher stub to make it easily runnable
*=START_BASIC_PRG        ; BASIC program starts at $1200
        .word END_LINE
        .word 2025                ; line number
        .byte $9e                 ; SYS token
        .text "4109"        ;  str(START)          ; Decimal value of START as string
        .byte $00                 ; eol
END_LINE
        .word $00                 ; End of BASIC program

START   sei                       ; Disable interrupts while we modify memory
        lda VIC_CHARBASE
        and #$f0
        ora #$0f
        sta VIC_CHARBASE          ; Store in VIC character base register

        ; Clear the screen
        ldx #$ff
CLEAR   lda #$20
        sta START_SCR,x
        sta START_SCR+207,x
        lda #1
        sta START_COLOUR,x
        sta START_COLOUR+207,x
        dex
        bne CLEAR

        ; Copy ROM character data to RAM for characters then modify some of those
        ldx 0             ; number of bytes to copy
CPBYTE  
        lda UPPERCASE_BASE,x
        sta CHARDEF_BASE,x
        lda UPPERCASE_BASE+8*16,x
        sta CHARDEF_BASE+8*16,x
        lda UPPERCASE_BASE+8*32,x
        sta CHARDEF_BASE+8*32,x
        inx
        cpx #8*16
        bne CPBYTE
        
        ; Modify the character data for the redefined characters
        ldx NCHARS * 8                  ; Reset counter
MODIFY  lda CHARDATA,x            ; Load from data table
        sta CHARDEF_BASE,x        ; Store in custom character area
        dex
        bne MODIFY

        ; Display custom characters on screen
        ldx #$00                  ; char code
DISPLAY 
        txa
        sta START_SCR,x
        inx
        cmp #NCHARS                ; All characters displayed?
        bne DISPLAY               ; If not, continue

        cli                       ; Re-enable interrupts
        rts                       ; Return to BASIC

; Data table for our custom characters (8 bytes per character)
CHARDATA
        ; smiley
        .byte %00111100           ;  ****
        .byte %01000010           ; *    *
        .byte %10100101           ;* *  * *
        .byte %10000001           ;*      *
        .byte %10100101           ;* *  * *
        .byte %10011001           ;*  **  *
        .byte %01000010           ; *    *
        .byte %00111100           ;  ****

        ; house
        .byte %00011000           ;   **
        .byte %00111100           ;  ****
        .byte %01111110           ; ******
        .byte %11111111           ;********
        .byte %01000010           ; *    *
        .byte %01001010           ; *  * *
        .byte %01001010           ; *  * *
        .byte %01111110           ; ******

        ;  lightning bolt
        .byte %00000000           ;
        .byte %00001000           ;    *
        .byte %00011000           ;   **
        .byte %00110000           ;  **
        .byte %01111110           ; ******
        .byte %00001100           ;    **
        .byte %00011000           ;   **
        .byte %00010000           ;   *

        ; Cross
        .byte %00011000           ;   **
        .byte %00011000           ;   **
        .byte %00011000           ;   **
        .byte %11111111           ;********
        .byte %11111111           ;********
        .byte %00011000           ;   **
        .byte %00011000           ;   **
        .byte %00011000           ;   **

        .byte %00011000
        .byte %01111110
        .byte %01011010
        .byte %11100111
        .byte %11100111
        .byte %01011010
        .byte %01111110
        .byte %00011000

        ; Humanoid
        .byte %00011000           ;   **
        .byte %00111100           ;  **** 
        .byte %00111100           ;  **** 
        .byte %00011000           ;   ** 
        .byte %11111111           ;********
        .byte %00111100           ;  ****
        .byte %01100110           ; **  **
        .byte %11000011           ;**    **

        .byte %01000010
        .byte %11100111
        .byte %10100101
        .byte %01011010
        .byte %01111110
        .byte %00111100
        .byte %00011000
        .byte %00011000

        .byte %10010010
        .byte %10010010
        .byte %00100100
        .byte %11011010
        .byte %10010010
        .byte %10010010
        .byte %10010010
        .byte %10010010

        ; South West Arrow
        .byte %00000001           ;       *
        .byte %00000010           ;      *
        .byte %00000100           ;     *
        .byte %00001000           ;    *
        .byte %10010000           ;*  *
        .byte %10100000           ;* *
        .byte %11000000           ;**
        .byte %11110000           ;****

        ; South East Arrow
        .byte %10000000           ;*
        .byte %01000000           ; *
        .byte %00100000           ;  *
        .byte %00010000           ;   *
        .byte %00001001           ;    *  *
        .byte %00000101           ;     * *
        .byte %00000011           ;      **
        .byte %00001111           ;    ****

        ; North West Arrow
        .byte %11110000           ;****
        .byte %11000000           ;**
        .byte %10100000           ;* *
        .byte %10010000           ;*  *
        .byte %00001000           ;    *
        .byte %00000100           ;     *
        .byte %00000010           ;      *
        .byte %00000001           ;       *

        ; North East Arrow
        .byte %00001111           ;    ****
        .byte %00000011           ;      **
        .byte %00000101           ;     * *
        .byte %00001001           ;    *  *
        .byte %00010000           ;   *
        .byte %00100000           ;  *
        .byte %01000000           ; *
        .byte %10000000           ;*

        ;  - Arrow up
        .byte %00011000           ;   **
        .byte %00111100           ;  ****
        .byte %01111110           ; ******
        .byte %11111111           ;********
        .byte %00011000           ;   **
        .byte %00011000           ;   **
        .byte %00011000           ;   **
        .byte %00011000           ;   **

        ;  - Arrow down
        .byte %00011000           ;   **
        .byte %00011000           ;   **
        .byte %00011000           ;   **
        .byte %00011000           ;   **
        .byte %11111111           ;********
        .byte %01111110           ; ******
        .byte %00111100           ;  ****
        .byte %00011000           ;   **

        ; Donut
        .byte %00111100           ;  ****
        .byte %01000010           ; *    *
        .byte %10011001           ;*  **  *
        .byte %10100101           ;* *  * *
        .byte %10100101           ;* *  * *
        .byte %10011001           ;*  **  *
        .byte %01000010           ; *    *
        .byte %00111100           ;  ****
CHARDATA_END

.end
