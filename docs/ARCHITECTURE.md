# Architecture

## RegisterFile
Owns EAX, ECX, EDX, EBX, ESP, EBP, ESI, EDI and EIP, plus guest stack operations.

## Flags
Owns EFLAGS and calculates arithmetic flags and Jcc conditions.

## Memory
Provides sparse byte-addressable little-endian guest RAM.

## Decoder
Fetches instruction data and resolves IA-32 ModR/M and SIB operands.

## InstructionSet
Maps opcodes to instruction handlers and is the primary expansion point.

## CPU
Connects registers, flags, memory, decoder, instruction handlers, and BIOS.

## BIOS
Provides the small emulator-specific INT 80h host interface.

## RawLoader
Loads flat binaries through the CC:Tweaked filesystem API.

## Monitor
Displays guest state during debug runs.

## Emulator
Coordinates loading and execution for the launcher.
