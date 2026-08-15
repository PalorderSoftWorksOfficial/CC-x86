local bit=bit32
local Register8={}
function Register8.get(registers,index)
 local value=registers:get(index%8)
 if index<4 then return bit.band(value,255) end
 return bit.band(bit.rshift(value,8),255)
end
function Register8.set(registers,index,value)
 local old=registers:get(index%8)
 value=bit.band(value,255)
 if index<4 then
  registers:set(index,bit.bor(bit.band(old,0xFFFFFF00),value))
 else
  registers:set(index-4,bit.bor(bit.band(old,0xFFFF00FF),bit.lshift(value,8)))
 end
end
return Register8
