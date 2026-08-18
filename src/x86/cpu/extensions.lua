local bit=bit32
local U32=require("src.x86.util.u32")
local Register8=require("src.x86.core.register8")
local Extensions={}
local function mul32(a,b)
 local a0=bit.band(a,65535)
 local a1=bit.rshift(a,16)
 local b0=bit.band(b,65535)
 local b1=bit.rshift(b,16)
 return U32.normalize(a0*b0+(a1*b0+a0*b1)*65536)
end
local function imul_overflow(a,b)
 local sa=U32.to_signed(a)
 local sb=U32.to_signed(b)
 if sa==0 or sb==0 then return false end
 local aa=sa<0 and -sa or sa
 local ab=sb<0 and -sb or sb
 local limit=(sa<0)==(sb<0) and 2147483647 or 2147483648
 return aa>math.floor(limit/ab)
end
local function word(value)
 return bit.band(value,65535)
end
local function dword(value)
 return U32.normalize(value)
end
local function vendor(cpu,text)
 local function p(i)
  return string.byte(text,i)+string.byte(text,i+1)*256+string.byte(text,i+2)*65536+string.byte(text,i+3)*16777216
 end
 cpu.registers:set(1,p(1))
 cpu.registers:set(3,p(5))
 cpu.registers:set(2,p(9))
end
local function cpuid(cpu)
 local leaf=cpu.registers:get(0)
 if leaf==0 then
  cpu.registers:set(0,1)
  vendor(cpu,"CCX8 6-PA LORD")
 elseif leaf==1 then
  cpu.registers:set(0,0x00000300)
  cpu.registers:set(1,0)
  cpu.registers:set(2,0)
  cpu.registers:set(3,1)
 elseif leaf==0x40000000 then
  cpu.registers:set(0,0x40000001)
  vendor(cpu,"CLOVEROS-X86")
 elseif leaf==0x40000001 then
  cpu.registers:set(0,1)
  cpu.registers:set(1,0)
  cpu.registers:set(2,0)
  cpu.registers:set(3,0)
 else
  cpu.registers:set(0,0)
  cpu.registers:set(1,0)
  cpu.registers:set(2,0)
  cpu.registers:set(3,0)
 end
end
function Extensions.install(cpu)
 local h=cpu.instructions.handlers
 for opcode=0x40,0x47 do
  h[opcode]=function(c)
   local i=opcode-0x40
   local old=c.registers:get(i)
   local carry=c.flags:has(c.flags.CF)
   local result=U32.add32(old,1)
   c.registers:set(i,result)
   c.flags:add(old,1,result)
   c.flags:set(c.flags.CF,carry)
  end
 end
 for opcode=0x48,0x4F do
  h[opcode]=function(c)
   local i=opcode-0x48
   local old=c.registers:get(i)
   local carry=c.flags:has(c.flags.CF)
   local result=U32.sub32(old,1)
   c.registers:set(i,result)
   c.flags:sub(old,1,result)
   c.flags:set(c.flags.CF,carry)
  end
 end
 h[0x8D]=function(c)
  local m=c.decoder:decode_modrm()
  if m.mode==3 then error("LEA requires memory addressing") end
  c.registers:set(m.reg,c.decoder:resolve_address(m))
 end
 h[0x0F]=function(c)
  local sub=c.decoder:fetch_u8()
  if sub>=0x80 and sub<=0x8F then
   local displacement=c.decoder:fetch_i32()
   if c.flags:condition(sub-0x80) then c.registers:set_eip(U32.add32(c.registers:get_eip(),displacement)) end
  elseif sub==0xAF then
   local m=c.decoder:decode_modrm()
   local a=c.decoder:resolve_address(m)
   local left=c.registers:get(m.reg)
   local right=c.decoder:read_rm32(m,a)
   local result=mul32(left,right)
   local overflow=imul_overflow(left,right)
   c.registers:set(m.reg,result)
   c.flags:set(c.flags.CF,overflow)
   c.flags:set(c.flags.OF,overflow)
  elseif sub==0xB6 then
   local m=c.decoder:decode_modrm()
   local a=c.decoder:resolve_address(m)
   c.registers:set(m.reg,c.decoder:read_rm8(m,a))
  elseif sub==0xB7 then
   local m=c.decoder:decode_modrm()
   local a=c.decoder:resolve_address(m)
   c.registers:set(m.reg,c.decoder:read_rm16(m,a))
  elseif sub==0xA2 then
   cpuid(c)
  elseif sub==0x31 then
   local time=os.epoch("utc")
   c.registers:set(0,dword(time))
   c.registers:set(2,math.floor(time/4294967296))
  else
   error(string.format("unsupported 0F opcode %02X at EIP=%08X",sub,c.registers:get_eip()-2))
  end
 end
 h[0xE4]=function(c)
  local port=c.decoder:fetch_u8()
  c.registers:set(0,Register8.get(c.registers,0))
  Register8.set(c.registers,0,c.bus:read(port,8))
 end
 h[0xE5]=function(c)
  local port=c.decoder:fetch_u8()
  c.registers:set(0,c.bus:read(port,32))
 end
 h[0xE6]=function(c)
  local port=c.decoder:fetch_u8()
  c.bus:write(port,Register8.get(c.registers,0),8)
 end
 h[0xE7]=function(c)
  local port=c.decoder:fetch_u8()
  c.bus:write(port,c.registers:get(0),32)
 end
 h[0xEC]=function(c)
  local port=word(c.registers:get(2))
  Register8.set(c.registers,0,c.bus:read(port,8))
 end
 h[0xED]=function(c)
  local port=word(c.registers:get(2))
  c.registers:set(0,c.bus:read(port,32))
 end
 h[0xEE]=function(c)
  local port=word(c.registers:get(2))
  c.bus:write(port,Register8.get(c.registers,0),8)
 end
 h[0xEF]=function(c)
  local port=word(c.registers:get(2))
  c.bus:write(port,c.registers:get(0),32)
 end
end
return Extensions
