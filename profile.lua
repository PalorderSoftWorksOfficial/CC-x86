local Emulator=require("src.x86.core.emulator")
local args={...}
local path=args[1]
local limit=tonumber(args[2]) or 100000
if not path then
 print("usage: profile <binary> [instruction-limit]")
 return
end
local emulator=Emulator.new()
emulator:load_raw(path,0x00100000)
local cpu=emulator.cpu
local counts={}
for _=1,limit do
 if cpu.halted then break end
 cpu:step()
 local opcode=cpu.last_opcode or 0
 counts[opcode]=(counts[opcode] or 0)+1
end
local list={}
for opcode,count in pairs(counts) do list[#list+1]={opcode=opcode,count=count} end
table.sort(list,function(a,b)return a.count>b.count end)
print("opcode count")
for i=1,math.min(20,#list) do
 print(string.format("%02X %d",list[i].opcode,list[i].count))
end
print(string.format("cycles=%d halted=%s",cpu.cycles,tostring(cpu.halted)))
