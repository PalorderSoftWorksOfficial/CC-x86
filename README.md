# CC:X86

A WIP 32-bit x86 emulator written entirely in Lua for CC:Tweaked.

CC:X86 is deliberately built as a real emulator project instead of a single compressed script. CPU state, instruction decoding, firmware, debugging, tests, and future devices have separate modules so contributors can work on one layer without rewriting the rest.

## Why this project exists

The interesting goal is to make a real 32-bit machine exist inside a CC:Tweaked computer and then use it for increasingly ambitious systems experiments.

The long-term targets are:

- a useful IA-32 interpreter
- an inspectable firmware ABI
- virtual hardware and a text/framebuffer device model
- a tiny guest boot monitor
- an educational 32-bit operating-system target
- measurable performance work

## CC:Tweaked

CC:X86 is designed for the Lua environment exposed by CC:Tweaked. It uses `bit32` and the CC:Tweaked `fs` API rather than desktop-only Lua facilities.

## Install

Copy the repository into the computer filesystem. `/ccx86` is a convenient location.

## Run

```text
x86 examples/add.bin
```

Useful development modes:

```text
x86 examples/add.bin --debug
x86 examples/add.bin --trace
x86 examples/add.bin --trace --trace-limit=64
x86 examples/add.bin --profile
x86 examples/add.bin --memory=32
```

Raw binaries are loaded at `0x00100000`. The stack is initialized near the end of configured guest RAM.

## Architecture

| Module | Responsibility |
| --- | --- |
| `RegisterFile` | IA-32 general-purpose registers, EIP, and guest stack helpers |
| `Flags` | EFLAGS state and arithmetic/condition semantics |
| `Memory` | Sparse little-endian byte-addressable guest RAM |
| `Decoder` | Opcode immediates plus ModR/M and SIB decoding |
| `CPU` | Fetch/decode/execute loop |
| `InstructionSet` | x86 instruction semantics and opcode expansion point |
| `OpcodeMetadata` | Human-readable names for tracing |
| `RawLoader` | Flat binary loading through CC:Tweaked `fs` |
| `BIOS` | Emulator-specific `INT 0x80` services |
| `Profiler` | Opcode frequency and execution statistics |
| `Tracer` | Compact execution trace |
| `Bus` | Boundary for future emulated hardware |
| `ConsoleDevice` | Terminal-backed character device |
| `Monitor` | Human-readable CPU state display |
| `Emulator` | Top-level runtime coordination |

## Current instructions

The WIP core currently includes NOP, HLT, MOV immediate/register/memory forms, LEA, ADD, SUB, XOR, AND, OR, CMP, TEST, INC, DEC, PUSH, POP, CALL, RET, JMP, short and near Jcc, INT, CLI, STI, CLD, STD, and a small `0F` extension set including `IMUL`.

Coverage is intentionally incomplete. Unsupported instructions fail loudly with the opcode and guest EIP so they can become focused contribution tasks.

## BIOS services

`INT 0x80` uses `EAX` as the service number. See [`docs/BIOS.md`](docs/BIOS.md).

| EAX | Service |
| --- | --- |
| `0` | Get CC:X86 BIOS version |
| `1` | Print signed integer from EBX |
| `2` | Write low byte of EBX |
| `3` | Print a zero-terminated guest string from EBX |
| `4` | Get UTC milliseconds |
| `6` | Halt the guest |

These are emulator firmware services, not Linux syscall compatibility.

## Testing

The repository includes small guest-level and CPU-level regressions. CI compiles every Lua file with Lua 5.2 and runs `tests/run.lua`.

For local CC:Tweaked testing:

```text
lua tests/run.lua
```

## CloverOS

CloverOS is the companion CC:Tweaked operating-system project from PalorderSoftWorksOfficial. CC:X86 is the low-level CPU/hardware laboratory; CloverOS is the user-facing environment that can install, launch, visualize, and showcase those experiments.

- CloverOS: https://github.com/PalorderSoftWorksOfficial/CloverOS
- CC:X86: https://github.com/PalorderSoftWorksOfficial/CC-x86
- CloverOS installer: `wget run https://endpoint.palorderhosting.net/netinstall.lua`

The projects are intentionally independent: CC:X86 remains useful without CloverOS, while CloverOS can adopt emulator demos without embedding the CPU implementation into the OS.

## Contributor workflow

Read [`CONTRIBUTING.md`](CONTRIBUTING.md), [`docs/MAINTAINERS.md`](docs/MAINTAINERS.md), and [`docs/ROADMAP.md`](docs/ROADMAP.md). A good first change is one missing opcode plus one regression test.

## Demo direction

The project is aiming for demos that are easy to reproduce inside Minecraft: tiny firmware programs, a visible CPU trace, an instruction profiler, virtual devices, and eventually a real 32-bit hobby OS running under the emulator. See [`docs/DEMO_IDEAS.md`](docs/DEMO_IDEAS.md) and [`docs/REDDIT_PITCH.md`](docs/REDDIT_PITCH.md).

## Status

WIP. Correctness and extensibility come before performance. The roadmap explicitly includes decode caching and optional translation/JIT experiments after the ISA and device model are substantially complete.
