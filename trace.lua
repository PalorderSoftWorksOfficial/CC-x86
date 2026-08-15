local Emulator=require("src.x86.core.emulator")
local args={...}
local path=args[1]
local limit=tonumber(args[2]) or 1000
if not path then
 print("usage: trace <binary> [instruction-limit]")
 return
end
local emulator=Emulator.new()
emulator:load_raw(path,0x00100000)
local cpu=emulator.cpu
for _=1,limit do
 if cpu.halted then break end
 local eip=cpu.registers:get_eip()
 cpu:step()
 print(string.format("%08X %02X EAX=%08X ECX=%08X EDX=%08X EBX=%08X",eip,cpu.last_opcode or 0,cpu.registers:get(0),cpu.registers:get(1),cpu.registers:get(2),cpu.registers:get(3)))
end
print(string.format("cycles=%d eip=%08X halted=%s",cpu.cycles,cpu.registers:get_eip(),tostring(cpu.halted)))
