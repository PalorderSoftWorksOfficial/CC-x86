local bit=bit32
local U32=require("src.x86.util.u32")
local BIOS={}
BIOS.__index=BIOS
function BIOS.new(cpu)
 return setmetatable({cpu=cpu},BIOS)
end
function BIOS:interrupt(number)
 if number==0x80 then
  local eax=self.cpu.registers:get(0)
  local ebx=self.cpu.registers:get(3)
  if eax==1 then
   print(U32.to_signed(ebx))
  elseif eax==2 then
   write(string.char(bit.band(ebx,255)))
  elseif eax==3 then
   print(self.cpu.memory:read_cstring(ebx))
  elseif eax==4 then
   local time=os.epoch("utc")
   self.cpu.registers:set(0,U32.normalize(time))
   self.cpu.registers:set(2,math.floor(time/4294967296))
  elseif eax==6 then
   self.cpu.halted=true
  else
   error(string.format("unsupported CC:X86 BIOS call EAX=%08X",eax))
  end
 elseif number==0x10 then
  local eax=self.cpu.registers:get(0)
  local ah=bit.band(bit.rshift(eax,8),255)
  if ah==0x0E then
   write(string.char(bit.band(eax,255)))
  elseif ah==0x00 then
   self.cpu.registers:set(0,0)
  else
   error(string.format("unsupported BIOS video function AH=%02X",ah))
  end
 else
  error(string.format("unsupported BIOS interrupt %02X",number))
 end
end
return BIOS
