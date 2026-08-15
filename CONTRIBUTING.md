# Contributing to CC:X86

CC:X86 is intentionally modular. A good contribution should leave the next contributor with a smaller problem than the one they started with.

## Good first contributions

- add one missing integer opcode
- add one instruction-level regression test
- improve ModR/M or SIB decoding
- add a profiler metric
- document one x86 semantic detail
- add a small firmware example

## CPU changes

Keep instruction semantics in `src/x86/cpu/instructions.lua` unless the feature is better represented as a separate subsystem. Keep numeric edge cases in `src/x86/util/u32.lua` and EFLAGS semantics in `src/x86/core/flags.lua`.

Every new instruction should have a minimal test or a reproducible guest program.

## CC:Tweaked compatibility

Do not use desktop-only Lua APIs such as `io`, native Lua 5.3 operators, or filesystem assumptions that do not exist in CC:Tweaked. The emulator targets the Lua environment exposed by CC:Tweaked.

## Pull requests

Explain the x86 behavior being implemented, include a small test, and state any architectural limitations.
