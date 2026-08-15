# CC:X86

A WIP 32-bit x86 emulator written entirely in Lua for CC:Tweaked.

The project is intentionally split into small modules so the CPU, memory system, instruction decoder, BIOS layer, loaders, and debugging tools can evolve independently.

## Requirements

- CC:Tweaked
- A ComputerCraft computer or advanced computer
- A binary containing supported 32-bit x86 instructions
- A sufficiently large computer filesystem for the binary and emulator sources

CC:X86 targets the Lua environment supplied by CC:Tweaked. It uses `bit32` instead of Lua 5.3 native bitwise operators and uses CC:Tweaked's `fs` API for file access.

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
| `InstructionSet` | Opcode handlers |
| `RawLoader` | Flat binary loading |
| `BIOS` | Emulator-specific `int 0x80` services |
| `Monitor` | Debug output |
| `Emulator` | Top-level runtime coordination |

## Current instructions

The WIP core currently includes NOP, HLT, MOV r32/immediates and r/m32 forms, ADD, SUB, XOR, AND, OR, CMP, TEST, INC, DEC, PUSH, POP, CALL, RET, JMP, short Jcc, INT, and flag-control instructions.

## BIOS services

`INT 0x80` uses `EAX` as the service number:

| EAX | Service |
| --- | --- |
| `1` | Print signed EAX |
| `2` | Write the low byte of EBX |
| `3` | Print a zero-terminated string at EBX |
| `6` | Halt the guest |

These are emulator-specific services, not Linux ABI compatibility.

## Development

Every class has editor-friendly documentation comments describing its responsibility, construction, guest-visible behavior, and important x86 semantics. Unsupported instructions fail loudly with the current EIP and opcode.

## Roadmap

1. Complete ModR/M and SIB addressing.
2. Finish byte and word register operations.
3. Expand the 80386 integer instruction set.
4. Add string instructions and REP prefixes.
5. Add segmentation and protected mode.
6. Add descriptor tables and interrupt delivery.
7. Add paging.
8. Add ELF32 loading.
9. Expand firmware services.
10. Build an instruction conformance suite.

## Status

WIP. Correctness and extensibility come before performance.
