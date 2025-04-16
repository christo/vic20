// assembler syntax: kick assembler

// kernel routines
.const CHROUT = $ffd2

// register locations
.const VICCR5 = $9005
.const CHR_CLEARSCREEN = 147
.const CHR_NEWLINE = $0d
.const NEW_TOP_BASIC_PAGE = 22 // 22*256 = 5632 ($1600)
.const NEW_TOP_BASIC_ADDR = NEW_TOP_BASIC_PAGE * $100
.const VECTOR_BASIC_TOP_PAGE = $38 // 56
.const VECTOR_SCREEN_TOP_PAGE = $288
.const nChars = endCharsToRedefine - charsToRedefine

.macro clearScreen() {
    lda #CHR_CLEARSCREEN
    jsr CHROUT
}

    * = $1001 "basic stub then machine code"
    .word nextLine
    .word 2025
    .byte $9e
    .text "4110"
    .byte 0
nextLine:
    .byte 0,0,0
entry:
    clearScreen()
    //jsr defineChars
    jsr printChars
    lda $30 + nChars // petscii number if < 10
    jsr CHROUT
infinite:
    jmp infinite
    rts

printChars:
    ldx #0
loop:
    lda mesg, x
    beq endPrintChars
    jsr CHROUT
    inx
    jmp loop
endPrintChars:
    rts

mesg:
    .text "G'DAY"
    .byte CHR_NEWLINE
    .text "COMRADE SUBSCRIBERS"
    .byte 0
mesg2:
    .text "@ABCDEFGHIJKLMNO"
    .byte 0




defineChars:
    // lower basic memory
    sei // disable interrupts
    lda NEW_TOP_BASIC_PAGE
    sta VECTOR_BASIC_TOP_PAGE
    lda NEW_TOP_BASIC_PAGE
    sta VECTOR_SCREEN_TOP_PAGE
    cli // enable interrupts
    rts

charsToRedefine:
    // TODO put the bytes of the chars to redefine here
    //   need 17 chars, use petscii graphics chars
endCharsToRedefine:

// char data, 8 bytes each
tce0: .byte  $FF,$19,$19,$19,$19,$19,$19,$19
tce1: .byte  $80,$80,$80,$FB,$9B,$9B,$9B,$9B
tce2: .byte  $00,$00,$00,$E0,$20,$E0,$00,$F0
tce3: .byte  $7D,$E5,$C1,$C1,$C1,$C1,$E1,$7F
tce4: .byte  $80,$80,$80,$A6,$A6,$A6,$A6,$BE
tce5: .byte  $03,$03,$03,$FB,$CB,$FB,$C3,$FF
tce6: .byte  $00,$00,$00,$7D,$65,$7D,$60,$7F
tce7: .byte  $00,$00,$00,$F7,$86,$F7,$30,$FF
tce8: .byte  $00,$00,$00,$C0,$00,$C0,$C0,$C0
tce9: .byte  $FE,$C0,$C0,$FD,$C1,$C1,$C1,$FF
tce10: .byte  $00,$00,$00,$F7,$94,$94,$94,$97
tce11: .byte  $00,$18,$00,$DB,$DB,$DB,$DB,$DB
tce12: .byte  $00,$00,$00,$EF,$2C,$2F,$2C,$2F
tce13: .byte  $00,$00,$00,$BE,$B2,$BE,$30,$FF
tce14: .byte  $00,$00,$00,$F8,$C8,$C0,$C0,$C0
tce15: .byte  $60,$E0,$60,$E0,$00,$00,$00,$00
tce16: .byte  $00,$03,$02,$03,$00,$00,$00,$00


