local Emulator=require("src.x86.core.emulator")
local args={...}
local path=args[1]
if not path then
 print("usage: debugger <binary>")
 return
end
local emulator=Emulator.new({debug=false})
emulator:load_raw(path,0x00100000)
local cpu=emulator.cpu
local names={"EAX","ECX","EDX","EBX","ESP","EBP","ESI","EDI"}
local function registers()
 for i=0,7 do print(string.format("%-3s %08X",names[i+1],cpu.registers:get(i))) end
 print(string.format("EIP %08X",cpu.registers:get_eip()))
 print(cpu.flags:summary())
end
local function memory(address,length)
 for i=0,length-1,16 do
  local line={}
  for j=0,15 do
   if i+j<length then line[#line+1]=string.format("%02X",cpu.memory:read_u8(address+i+j)) end
  end
  print(string.format("%08X %s",address+i,table.concat(line," ")))
 end
end
local function step()
 local eip=cpu.registers:get_eip()
 cpu:step()
 print(string.format("%08X  %02X",eip,cpu.last_opcode or 0))
end
print("CC:X86 debugger")
print("commands: s, c [count], r, m <address> [length], q")
while not cpu.halted do
 write("dbg> ")
 local line=read()
 local command,rest=line:match("^(%S+)%s*(.*)$")
 if command=="q" then break
 elseif command=="s" then step()
 elseif command=="r" then registers()
 elseif command=="m" then
  local a,l=rest:match("^(%S+)%s*(%S*)$")
  local address=tonumber(a,0)
  local length=tonumber(l,0x40)
  if address then memory(address,length) else print("usage: m <address> [length]") end
 elseif command=="c" then
  local count=tonumber(rest,10) or 1000
  for _=1,count do
   if cpu.halted then break end
   cpu:step()
  end
  registers()
 else
  print("commands: s, c [count], r, m <address> [length], q")
 end
end
print("halted at",string.format("%08X",cpu.registers:get_eip()))
