# Hardware and Guest ABI

CC:X86 exposes a small virtual machine interface in addition to the CPU instruction set.

## Port I/O

Port `0xE9` is a debug terminal output port. Writing `AL`, `AX`, or `EAX` sends the low byte or value to the host terminal device.

The bus is intentionally isolated from the CPU core so future devices can be added without changing instruction semantics.

## Software Interrupts

`INT 0x80` is the current firmware gateway.

| EAX | Meaning | Input |
| --- | --- | --- |
| 1 | Print signed value | EBX |
| 2 | Print byte | BL |
| 3 | Print string | EBX = guest address |
| 6 | Halt | none |

These services are CC:X86 firmware services. They are not Linux ABI compatibility promises.

## CPUID

`CPUID` leaf `0` identifies the emulator as `CCX86-PALORD`.

`CPUID` leaf `0x40000000` identifies the virtual machine layer as `CLOVEROS-X86`.

That custom leaf is intended to let a future CloverOS x86 bootstrap identify the virtual hardware before using higher-level firmware calls.

## Timestamp Counter

`RDTSC` exposes the host millisecond clock through EDX:EAX.

This is a convenient timing source for experiments and profiling. It is not cycle-accurate emulation.

## Design Principle

Virtual hardware belongs behind explicit interfaces. The emulator should be able to replace the terminal, clock, disks, serial ports, and future graphics devices without rewriting the instruction decoder.
