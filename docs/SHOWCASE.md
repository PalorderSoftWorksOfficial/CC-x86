# CC:X86 showcase direction

The project is most interesting when the emulator is visibly doing something that would normally require a real computer.

## Demo ladder

1. Run tiny hand-written machine code.
2. Assemble guest programs directly inside CC:Tweaked.
3. Show register and memory debugging from an interactive terminal.
4. Run a guest program that identifies the virtual machine with CPUID.
5. Add disk and boot-sector support.
6. Boot a tiny 32-bit diagnostic operating system.
7. Boot an experimental CloverOS x86 environment.
8. Add enough hardware to run increasingly interesting real software.

## What contributors can work on

The emulator is deliberately divided into CPU, instruction decoding, memory, firmware, devices, loaders, debugging, and tests. A contributor can add one instruction family, one device, one loader, or one regression suite without needing to understand every subsystem.

## Public demo principle

Every major architectural milestone should have a tiny guest program that demonstrates it. The repository should make it possible to reproduce the demo from a clean CC:Tweaked computer.

## CloverOS connection

CloverOS is the long-term guest operating-system experiment. CC:X86 remains useful independently as a CPU and virtual hardware laboratory.

That separation means improving the emulator improves the possible CloverOS targets, while improving CloverOS creates concrete requirements that can drive realistic emulator development.
