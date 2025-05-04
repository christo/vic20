; VIC-20 hello world machine code

; uses tass64 assembler

.cpu "6502"

CHROUT = $ffd2
START_BASIC_PRG = $1001

; Basic launcher stub to make it easily runnable
*=START_BASIC_PRG
        .word END_LINE
        .word 2025                ; line number
        .byte $9e                 ; SYS token
        .text "4109"              ; Decimal value of START as string
        .byte $00                 ; eol
END_LINE
        .word $00                 ; End of BASIC program

START   
        ldx #0
LOOP
        lda MESSAGE,x
        beq END
        jsr CHROUT
        inx
        jmp LOOP

END     jmp END  ; infinite loop

MESSAGE
        .text "hello world"
        .byte 0
