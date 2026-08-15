# Developer tools

## Assembler

Build a small flat binary entirely inside CC:Tweaked:

```text
asm examples/hello.asm /tmp/hello.bin
```

The assembler currently targets a small subset of the instruction set. Unsupported syntax is rejected instead of generating guessed machine code.

## Debugger

Start the interactive debugger:

```text
debugger examples/add.bin
```

Commands:

- `s` steps one instruction.
- `c 1000` continues for up to 1000 instructions.
- `r` prints registers and flags.
- `m 0x1000 64` prints guest memory.
- `q` exits.

## Trace

Print every executed opcode and the primary register state:

```text
trace examples/add.bin 100
```

## Profile

Count executed opcodes:

```text
profile examples/add.bin 100000
```

## Bug reports

A useful emulator issue should include the smallest guest program, the expected state, the actual state, register values, instruction bytes, and the CC:X86 commit. This is enough to turn most compatibility bugs into regression tests.
