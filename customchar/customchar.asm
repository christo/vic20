; VIC-20 Character Redefinition Program
; redefines a number of characters starting from @ and displays them on screen

; uses tass64 assembler

; Memory map reference:
; $1000-$1DFF: BASIC program area (we'll put our program here)
; $1E00-$1FFF: Screen memory (where characters are displayed)
; $9005: Character base register (bits 0-3 determine character set location)
; $9600-$97FF: Default location for custom character set (8K boundary)

.cpu "6502"

NCHARS = ((CHARDATA_END - CHARDATA) / 8)
N_SCR_COLS = 22
N_SCR_ROWS = 21
START_SCR = $1E00

; Basic launcher stub to make it easily runnable
*=$1001        ; BASIC program starts at $1200
        .word END_LINE
        .word 2025                ; line number
        .byte $9E                 ; SYS token
        .text "4109"        ;  str(START)          ; Decimal value of START as string
        .byte $00                 ; eol
END_LINE
        .word $00                 ; End of BASIC program

START   sei                       ; Disable interrupts while we modify memory

        ; Set custom character base address
        ; We'll use $9600 as our custom character set location (pattern buffer)
        lda #$96                  ; High byte of our custom character set location
        lsr                       ; Shift right 4 times to get bits in position 0-3
        lsr
        lsr
        lsr
        sta $9005                 ; Store in VIC character base register

        ; Copy ROM character data to RAM for the characters we want to modify
        ; ROM character set is at $8000, we'll copy characters @ through O (ASCII 64-79)
        ldx #$00                  ; Initialize counter
COPY    lda $8000+64*8,x          ; Load character data from ROM (@ is at position 64, 8 bytes per char)
        sta $9600,x               ; Store in our custom character area
        inx                       ; Increment counter
        cpx 8 * NCHARS            ; nchars * 8 bytes
        bne COPY                  ; Loop until all bytes copied

        ; Modify the character data for each character
        ldx #$00                  ; Reset counter
MODIFY  lda CHARDATA,x            ; Load our custom pattern from data table
        sta $9600,x               ; Store in custom character area
        inx                       ; Increment counter
        cpx 8 * NCHARS            ; nchars * 8 bytes
        bne MODIFY                ; Loop until all bytes modified

        ; Clear the screen
        lda #$20                  ; Space character
        ldx #$00                  ; Start at first char
CLEAR   sta START_SCR,x           ; Store space in screen memory
        inx                       ; Next position
        cpx NCHARS
        bne CLEAR                 ; Loop until screen cleared

        ; Display our custom characters on screen
        ldx #$00                  ; Initialize counter
        ldy #$00                  ; char counter
        lda #64                   ; Start with @ character (ASCII 64)
DISPLAY sta START_SCR+N_SCR_COLS+1,x  ; start on second row, second column
        inx                       ; Next screen position
        inx                       ; skip one
        iny                       ; Next position data
        cpy NCHARS                ; All characters displayed?
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
        .byte %00000000
        .byte %00001000
        .byte %00011000
        .byte %00110000
        .byte %01111110
        .byte %00001100
        .byte %00011000
        .byte %00010000

        ;  - Cross
        .byte %00011000           ;   **
        .byte %00011000           ;   **
        .byte %00011000           ;   **
        .byte %11111111           ;********
        .byte %11111111           ;********
        .byte %00011000           ;   **
        .byte %00011000           ;   **
        .byte %00011000           ;   **

        ;  - Diamond
        .byte %00011000           ;   **
        .byte %00111100           ;  ****
        .byte %01111110           ; ******
        .byte %11111111           ;********
        .byte %11111111           ;********
        .byte %01111110           ; ******
        .byte %00111100           ;  ****
        .byte %00011000           ;   **

        ; Humanoid
        .byte %00011000           ;   **
        .byte %01111110           ; ******
        .byte %01111110           ; ******
        .byte %00111100           ;  ****
        .byte %11111111           ;********
        .byte %00111100           ;  ****
        .byte %01100110           ; **  **
        .byte %11000011           ;**    **

        ;  - Heart
        .byte %01100110           ; **  **
        .byte %11111111           ;********
        .byte %11111111           ;********
        .byte %11111111           ;********
        .byte %01111110           ; ******
        .byte %00111100           ;  ****
        .byte %00011000           ;   **
        .byte %00000000           ;

        ;  - Vertical bars
        .byte %10010010           ;*  *  *
        .byte %10010010           ;*  *  *
        .byte %10010010           ;*  *  *
        .byte %10010010           ;*  *  *
        .byte %10010010           ;*  *  *
        .byte %10010010           ;*  *  *
        .byte %10010010           ;*  *  *
        .byte %10010010           ;*  *  *

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
        .byte %10000001           ;*  **  *
        .byte %10000001           ;* *  * *
        .byte %10000001           ;* *  * *
        .byte %10000001           ;*  **  *
        .byte %01000010           ; *    *
        .byte %00111100           ;  ****
CHARDATA_END

.end
