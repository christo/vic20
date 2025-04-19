; VIC-20 Character Redefinition Program
; This program redefines 16 characters (@ through O) and displays them on screen

; Memory map reference:
; $1000-$1DFF: BASIC program area (we'll put our program here)
; $1E00-$1FFF: Screen memory (where characters are displayed)
; $9005: Character base register (bits 0-3 determine character set location)
; $9600-$97FF: Default location for custom character set (8K boundary)

        *= $1000                  ; Starting address of our program

START   SEI                       ; Disable interrupts while we modify memory

        ; Step 1: Set custom character base address
        ; We'll use $9600 as our custom character set location (pattern buffer)
        LDA #$96                  ; High byte of our custom character set location
        LSR A                     ; Shift right 4 times to get bits in position 0-3
        LSR A
        LSR A
        LSR A
        STA $9005                 ; Store in VIC character base register

        ; Step 2: Copy ROM character data to RAM for the 16 characters we want to modify
        ; ROM character set is at $8000, we'll copy characters @ through O (ASCII 64-79)
        LDX #$00                  ; Initialize counter
COPY    LDA $8000+64*8,X          ; Load character data from ROM (@ is at position 64, 8 bytes per char)
        STA $9600,X               ; Store in our custom character area
        INX                       ; Increment counter
        CPX #128                  ; 16 characters * 8 bytes = 128 bytes to copy
        BNE COPY                  ; Loop until all bytes copied

        ; Step 3: Modify the character data for our 16 characters
        LDX #$00                  ; Reset counter
MODIFY  LDA CHARDATA,X            ; Load our custom pattern from data table
        STA $9600,X               ; Store in custom character area
        INX                       ; Increment counter
        CPX #128                  ; 16 characters * 8 bytes = 128 bytes to modify
        BNE MODIFY                ; Loop until all bytes modified

        ; Step 4: Clear the screen
        LDA #$20                  ; Space character
        LDX #$00                  ; Start at position 0
CLEAR   STA $1E00,X               ; Store space in screen memory
        INX                       ; Next position
        CPX #$F6                  ; VIC-20 screen is 22x23=506 ($F6) positions
        BNE CLEAR                 ; Loop until screen cleared

        ; Step 5: Display our 16 custom characters on screen in a 4x4 grid
        LDX #$00                  ; Initialize counter
        LDY #$00                  ; Screen position counter
DISPLAY LDA #64                   ; Start with @ character (ASCII 64)
        CLC                       ; Clear carry for addition
        ADC POSITIONS,Y           ; Add offset from position table
        STA $1E00+80+11,X         ; Store in center of screen (80=4 rows down, 11=center column)
        INX                       ; Next screen position
        INY                       ; Next position data
        CPY #16                   ; All 16 characters displayed?
        BNE DISPLAY               ; If not, continue

        CLI                       ; Re-enable interrupts
        RTS                       ; Return to BASIC

; Data table for our 16 custom characters (8 bytes per character)
CHARDATA
        ; Character @ (64) - Custom pattern for a smiling face
        .BYTE %00111100           ;  ****
        .BYTE %01000010           ; *    *
        .BYTE %10100101           ;* *  * *
        .BYTE %10000001           ;*      *
        .BYTE %10100101           ;* *  * *
        .BYTE %10011001           ;*  **  *
        .BYTE %01000010           ; *    *
        .BYTE %00111100           ;  ****

        ; Character A (65) - Simple triangle
        .BYTE %00011000           ;   **
        .BYTE %00111100           ;  ****
        .BYTE %01111110           ; ******
        .BYTE %11111111           ;********
        .BYTE %00000000           ;
        .BYTE %00000000           ;
        .BYTE %00000000           ;
        .BYTE %00000000           ;

        ; Character B (66) - Horizontal bars
        .BYTE %11111111           ;********
        .BYTE %00000000           ;
        .BYTE %11111111           ;********
        .BYTE %00000000           ;
        .BYTE %11111111           ;********
        .BYTE %00000000           ;
        .BYTE %11111111           ;********
        .BYTE %00000000           ;

        ; Character C (67) - Checkerboard
        .BYTE %10101010           ;* * * *
        .BYTE %01010101           ; * * * *
        .BYTE %10101010           ;* * * *
        .BYTE %01010101           ; * * * *
        .BYTE %10101010           ;* * * *
        .BYTE %01010101           ; * * * *
        .BYTE %10101010           ;* * * *
        .BYTE %01010101           ; * * * *

        ; Character D (68) - Cross
        .BYTE %00011000           ;   **
        .BYTE %00011000           ;   **
        .BYTE %00011000           ;   **
        .BYTE %11111111           ;********
        .BYTE %11111111           ;********
        .BYTE %00011000           ;   **
        .BYTE %00011000           ;   **
        .BYTE %00011000           ;   **

        ; Character E (69) - Diamond
        .BYTE %00011000           ;   **
        .BYTE %00111100           ;  ****
        .BYTE %01111110           ; ******
        .BYTE %11111111           ;********
        .BYTE %11111111           ;********
        .BYTE %01111110           ; ******
        .BYTE %00111100           ;  ****
        .BYTE %00011000           ;   **

        ; Character F (70) - Star
        .BYTE %00011000           ;   **
        .BYTE %00011000           ;   **
        .BYTE %01111110           ; ******
        .BYTE %00111100           ;  ****
        .BYTE %11111111           ;********
        .BYTE %00111100           ;  ****
        .BYTE %01100110           ; **  **
        .BYTE %11000011           ;**    **

        ; Character G (71) - Heart
        .BYTE %01100110           ; **  **
        .BYTE %11111111           ;********
        .BYTE %11111111           ;********
        .BYTE %11111111           ;********
        .BYTE %01111110           ; ******
        .BYTE %00111100           ;  ****
        .BYTE %00011000           ;   **
        .BYTE %00000000           ;

        ; Character H (72) - Vertical bars
        .BYTE %10010010           ;*  *  *
        .BYTE %10010010           ;*  *  *
        .BYTE %10010010           ;*  *  *
        .BYTE %10010010           ;*  *  *
        .BYTE %10010010           ;*  *  *
        .BYTE %10010010           ;*  *  *
        .BYTE %10010010           ;*  *  *
        .BYTE %10010010           ;*  *  *

        ; Character I (73) - Bordered square
        .BYTE %11111111           ;********
        .BYTE %10000001           ;*      *
        .BYTE %10000001           ;*      *
        .BYTE %10000001           ;*      *
        .BYTE %10000001           ;*      *
        .BYTE %10000001           ;*      *
        .BYTE %10000001           ;*      *
        .BYTE %11111111           ;********

        ; Character J (74) - Four corners
        .BYTE %11000011           ;**    **
        .BYTE %10000001           ;*      *
        .BYTE %00000000           ;
        .BYTE %00000000           ;
        .BYTE %00000000           ;
        .BYTE %00000000           ;
        .BYTE %10000001           ;*      *
        .BYTE %11000011           ;**    **

        ; Character K (75) - Diagonal line (top-left to bottom-right)
        .BYTE %10000000           ;*
        .BYTE %01000000           ; *
        .BYTE %00100000           ;  *
        .BYTE %00010000           ;   *
        .BYTE %00001000           ;    *
        .BYTE %00000100           ;     *
        .BYTE %00000010           ;      *
        .BYTE %00000001           ;       *

        ; Character L (76) - Diagonal line (top-right to bottom-left)
        .BYTE %00000001           ;       *
        .BYTE %00000010           ;      *
        .BYTE %00000100           ;     *
        .BYTE %00001000           ;    *
        .BYTE %00010000           ;   *
        .BYTE %00100000           ;  *
        .BYTE %01000000           ; *
        .BYTE %10000000           ;*

        ; Character M (77) - Arrow up
        .BYTE %00011000           ;   **
        .BYTE %00111100           ;  ****
        .BYTE %01111110           ; ******
        .BYTE %11111111           ;********
        .BYTE %00011000           ;   **
        .BYTE %00011000           ;   **
        .BYTE %00011000           ;   **
        .BYTE %00011000           ;   **

        ; Character N (78) - Arrow down
        .BYTE %00011000           ;   **
        .BYTE %00011000           ;   **
        .BYTE %00011000           ;   **
        .BYTE %00011000           ;   **
        .BYTE %11111111           ;********
        .BYTE %01111110           ; ******
        .BYTE %00111100           ;  ****
        .BYTE %00011000           ;   **

        ; Character O (79) - Circle
        .BYTE %00111100           ;  ****
        .BYTE %01000010           ; *    *
        .BYTE %10000001           ;*      *
        .BYTE %10000001           ;*      *
        .BYTE %10000001           ;*      *
        .BYTE %10000001           ;*      *
        .BYTE %01000010           ; *    *
        .BYTE %00111100           ;  ****

; Position table for 4x4 grid layout (offsets from character @)
POSITIONS
        .BYTE 0, 1, 2, 3          ; First row: @, A, B, C
        .BYTE 22, 23, 24, 25      ; Second row: D, E, F, G (22 = screen width)
        .BYTE 44, 45, 46, 47      ; Third row: H, I, J, K (44 = 2 * screen width)
        .BYTE 66, 67, 68, 69      ; Fourth row: L, M, N, O (66 = 3 * screen width)

; Basic launcher stub to make it easily runnable
*=$1200        ; BASIC program starts at $1200
        .WORD LINK
        .WORD 10
        .BYTE $9E                 ; SYS token
        .TEXT "4096"              ; Decimal value of $1000
        .BYTE $00
LINK    .WORD $00                 ; End of BASIC program

        .END
