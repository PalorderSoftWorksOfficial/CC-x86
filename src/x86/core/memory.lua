local bit = bit32
local U32 = require("src.x86.util.u32")

---@class Memory
---Provides sparse, little-endian, byte-addressable guest RAM.
local Memory = {}
Memory.__index = Memory

---Creates guest RAM with the supplied byte capacity.
function Memory.new(size)
    return setmetatable({ size = size, bytes = {} }, Memory)
end

function Memory:check(address, length)
    if address < 0 or address + length > self.size then
        error(string.format("guest memory fault at %08X", address))
    end
end

function Memory:read_u8(address)
    self:check(address, 1)
    return self.bytes[address] or 0
end

function Memory:write_u8(address, value)
    self:check(address, 1)
    self.bytes[address] = bit.band(value, 0xFF)
end

function Memory:read_u16(address)
    self:check(address, 2)
    return self:read_u8(address) + bit.lshift(self:read_u8(address + 1), 8)
end

function Memory:write_u16(address, value)
    self:check(address, 2)
    self:write_u8(address, value)
    self:write_u8(address + 1, bit.rshift(value, 8))
end

---Reads one little-endian unsigned 32-bit guest value.
function Memory:read_u32(address)
    self:check(address, 4)
    return U32.normalize(self:read_u8(address) + bit.lshift(self:read_u8(address + 1), 8) + bit.lshift(self:read_u8(address + 2), 16) + bit.lshift(self:read_u8(address + 3), 24))
end

---Writes one little-endian unsigned 32-bit guest value.
function Memory:write_u32(address, value)
    self:check(address, 4)
    value = U32.normalize(value)
    self:write_u8(address, value)
    self:write_u8(address + 1, bit.rshift(value, 8))
    self:write_u8(address + 2, bit.rshift(value, 16))
    self:write_u8(address + 3, bit.rshift(value, 24))
end

---Copies a raw binary string into guest RAM.
function Memory:load(address, data)
    self:check(address, #data)
    for i = 1, #data do self.bytes[address + i - 1] = string.byte(data, i) end
end

function Memory:read_cstring(address, limit)
    local out = {}
    local max = limit or self.size - address
    for i = 0, max - 1 do
        local value = self:read_u8(address + i)
        if value == 0 then break end
        out[#out + 1] = string.char(value)
    end
    return table.concat(out)
end

return Memory
