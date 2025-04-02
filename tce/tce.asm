// assembler syntax: kick assembler

    * = $1001 "basic stub then machine code"
    .word nextLine
    .word 2025
    .byte $9e
    .text "4110"
    .byte 0
nextLine:
    .byte 0,0,0
entry:
    ldx #0
loop:
    lda hello, x
    beq end
    jsr $ffd2
    inx
    jmp loop
end:
    rts

hello:
    .text "HELLO WORLD"
    .byte 0


