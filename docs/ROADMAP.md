# Roadmap

## Phase 1: solid interpreter

- [x] General-purpose registers
- [x] EIP and EFLAGS
- [x] Little-endian memory
- [x] ModR/M and SIB baseline
- [x] Arithmetic and logical 32-bit instructions
- [x] Calls, returns, stack operations, and Jcc
- [x] BIOS interrupt ABI
- [x] Execution profiler and trace output
- [x] Device attachment boundary

## Phase 2: useful 32-bit software

- [ ] Complete byte and word operand support
- [ ] `MOVZX` and `MOVSX`
- [ ] Shift and rotate family
- [ ] `MUL`, `IMUL`, `DIV`, and `IDIV`
- [ ] `PUSHAD`, `POPAD`, `ENTER`, `LEAVE`
- [ ] `SETcc` and `CMOVcc`
- [ ] String instructions and REP prefixes
- [ ] Better instruction metadata and disassembly
- [ ] ELF32 loader

## Phase 3: PC hardware

- [ ] A20 gate model
- [ ] Segment registers
- [ ] GDT and IDT
- [ ] Protected mode
- [ ] Hardware interrupt controller abstraction
- [ ] PIT/clock device
- [ ] UART-like character device
- [ ] Text framebuffer
- [ ] Optional VGA-style framebuffer

## Phase 4: operating-system experiments

- [ ] Tiny boot monitor
- [ ] Educational 32-bit kernel target
- [ ] Minimal libc-like guest support
- [ ] File-backed virtual disk image
- [ ] Guest shell
- [ ] Measurable boot benchmarks

## Phase 5: performance

- [ ] Memory page/block caching
- [ ] Decode cache
- [ ] Hot-opcode dispatch optimizations
- [ ] Optional basic-block translation experiments
- [ ] CC:Tweaked-specific profiling guide

## CloverOS track

The x86 emulator should remain independent of CloverOS, but the two projects should intentionally share demo milestones. CloverOS can provide the friendly CC:Tweaked environment used to install, launch, visualize, and document emulator experiments.
