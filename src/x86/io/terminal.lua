local bit=bit32
local Terminal={}
Terminal.__index=Terminal
function Terminal.new(host)
 return setmetatable({host=host or term},Terminal)
end
function Terminal:read(width)
 return 0
end
function Terminal:write(value,width)
 if self.host and self.host.write then self.host.write(string.char(bit.band(value,255))) end
end
return Terminal
