# CC:X86

A WIP 32-bit x86 emulator written entirely in Lua for CC:Tweaked.

The project is intentionally split into small modules so the CPU, memory system, instruction decoder, firmware, virtual hardware, loaders, and debugging tools can evolve independently.

## The goal

CC:X86 is being built as a real small-machine project rather than a giant opcode table. The long-term target is an IA-32 compatible virtual machine capable of booting real 32-bit software inside CC:Tweaked.

The first serious guest target is a small operating-system environment that can eventually become a CloverOS x86 port or a dedicated CloverOS laboratory image.

## Requirements

- CC:Tweaked
- A ComputerCraft computer or advanced computer
- A binary containing supported 32-bit x86 instructions

CC:X86 targets the Lua environment supplied by CC:Tweaked. It uses `bit32` for integer bit operations and CC:Tweaked's filesystem APIs for loading guest programs.

## Install

Copy the repository into the computer's filesystem. The project can be placed at `/ccx86`.

## Run

Run a raw binary with:

```text
x86 examples/add.bin
```

Debug execution:

```text
x86 examples/add.bin --debug
```

The binary is loaded at `0x00100000`. Execution starts there and the initial stack pointer is `0x00700000`.

## Architecture

| Module | Responsibility |
| --- | --- |
| `RegisterFile` | IA-32 general-purpose registers and EIP |
| `Flags` | EFLAGS state and arithmetic helpers |
| `Memory` | Sparse byte-addressable guest RAM |
| `Decoder` | Opcode, ModR/M and SIB decoding |
| `CPU` | Fetch/decode/execute loop |
| `InstructionSet` | Core opcode handlers |
| `Extensions` | Experimental and rapidly growing instruction groups |
| `Bus` | Guest port I/O routing |
| `Terminal` | Host terminal device on port `0xE9` |
| `BIOS` | Emulator-specific `int 0x80` services |
| `RawLoader` | Flat binary loading |
| `Monitor` | Debug output |
| `Emulator` | Top-level runtime coordination |

## Current instructions

The WIP core includes NOP, HLT, MOV immediate/register/memory forms, arithmetic and logical instructions, CMP, TEST, INC, DEC, PUSH, POP, CALL, RET, JMP, short and near conditional branches, LEA, software interrupts, flag-control instructions, initial IMUL, MOVZX, CPUID, RDTSC, and port I/O.

The implementation is deliberately incomplete. Unsupported instructions fail loudly with the opcode and instruction pointer instead of silently producing incorrect guest state.

## Virtual hardware

Port `0xE9` is a terminal/debug port. This makes tiny guest programs easy to write and gives future operating-system work a deterministic serial-style output path.

`CPUID 0x40000000` identifies the virtual machine as `CLOVEROS-X86`. This is reserved for future CloverOS x86 integration and is intentionally independent from the normal x86 instruction semantics.

See `docs/HARDWARE.md` for the current guest ABI.

## CloverOS

CloverOS and CC:X86 are companion projects.

CloverOS is the user-facing operating-system environment for CC:Tweaked.

CC:X86 is the low-level CPU, firmware, memory, virtual-device, and debugger laboratory.

The intended direction is to let CloverOS gain an x86 execution target while keeping CC:X86 useful as a standalone emulator project for experimenting with CPUs and virtual hardware.

CloverOS repository: `PalorderSoftWorksOfficial/CloverOS`

## Development

The project uses small modules and explicit interfaces so contributors can work on one subsystem without rewriting the emulator.

Tests are separated by subsystem. The GitHub Actions workflow performs Lua 5.2 syntax checks and executes the emulator regression suite.

## Roadmap

1. Finish ModR/M and SIB edge cases.
2. Complete byte and word register operations.
3. Expand the 80386 integer instruction set.
4. Add REP-prefixed string operations.
5. Add descriptor tables and protected mode.
6. Add interrupt and exception delivery.
7. Add paging.
8. Add disk devices and BIOS boot services.
9. Add ELF32 loading.
10. Build a conformance suite from real assembled instruction sequences.
11. Build a tiny bootable 32-bit guest image.
12. Prototype a CloverOS x86 boot environment.

## Status

WIP. Correctness, observability, and extensibility come before raw emulation speed.
