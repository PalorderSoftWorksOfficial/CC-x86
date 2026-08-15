local Bus={}
Bus.__index=Bus
function Bus.new()
 return setmetatable({ports={}},Bus)
end
function Bus:attach(port,device)
 self.ports[port]=device
end
function Bus:read(port,width)
 local device=self.ports[port]
 if device and device.read then return device:read(width) end
 return 0
end
function Bus:write(port,value,width)
 local device=self.ports[port]
 if device and device.write then device:write(value,width) end
end
return Bus
