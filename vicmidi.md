# VIC MIDI

## Introduction

The VIC-20 MIDI Cartridge is the result of one of our customers asking “could
we?”.

A group of VIC-20 enthusiasts approached RETRO Innovations about producing
a VIC-20 MIDI design found long ago in a _MAPLIN magazine article.  The original
design centered about a 6850 UART, a no longer-produced Motorola 68XX support
IC, and was minimal in functionality. To update the design for
manufacturability, the 6850 was discarded in favor of a 8250-based UART, and an
on-board ROM was added to the design to support serious musicians who preferred
to run the VIC-20 headless and not bother with a disk drive and/or monitor.

Along the way, the design matured into a more general-purpose communications and
memory expansion cartridge that includes the following features:

* MIDI In, Out, and Through capability
* RS-232 communications support
* 512kB user programmable flash ROM
* 128kB (expandable to 512kB) RAM
* The increase in capability was further enhanced by supporting a flexible memory
  allocation mechanism denoted “Ultimem”. This capability greatly increases the
  utility and configuration options of the on board memory.

## Requirements

Commodore VIC-20
* A MIDI output device (the VIC-MIDI can output MIDI, but it’s primarily designed
  as a MIDI instrument)
* A 5 pin DIN MIDI cable
* VIC-MIDI software (download files `vicmidi` and `vicmidi.prg`. Load and run
  `vicmidi` from drive #8)
* a MIDI file

## Technical Details

* VIC-MIDI supports the Ultimem registers at `$9ff0` (40944)
* The `ST16c450`` UART registers appear at $9800 (38912). 
* Ultimem registers and usage are described on the Ultimem product page.
* The ST16C450 utilizes the industry-standard 8250 register set.
  https://en.wikibooks.org/wiki/Serial_Programming/8250_UART_Programming

The UART implementation is
straightforward, with only 2 specific notes:

* The OPT1 bit (bit 2 of $9804/38916) should be set to 1 to enable the MIDI
  drivers and set to 0 to enable the RS232 drivers.
* The crystal frequency of the UART is 18.432MHz.
