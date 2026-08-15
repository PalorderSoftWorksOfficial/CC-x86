# CC:X86 BIOS ABI

CC:X86 exposes a deliberately small firmware interface through `INT 0x80`.

This is not a Linux ABI. It exists so tiny guest programs can interact with their CC:Tweaked host without requiring an entire PC firmware stack.

## Calling convention

Place the service number in `EAX` and arguments in the registers documented below.

| EAX | Service | Arguments | Result |
| --- | --- | --- | --- |
| `0` | Get BIOS version | none | `EAX = 0x00010000` |
| `1` | Print signed integer | `EBX` | none |
| `2` | Write character | low byte of `EBX` | none |
| `3` | Print C string | `EBX = guest address` | none |
| `4` | Get UTC milliseconds | none | `EAX = os.epoch("utc")` |
| `6` | Halt guest | none | CPU halts |

Example guest sequence for writing `A`:

```asm
mov eax, 2
mov ebx, 65
int 80h
```
