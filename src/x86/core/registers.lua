local U32 = require("src.x86.util.u32")

---@class RegisterFile
---Stores the eight IA-32 general-purpose registers and EIP.
local RegisterFile = {}
RegisterFile.__index = RegisterFile

RegisterFile.NAMES = {
    [1] = "EAX", [2] = "ECX", [3] = "EDX", [4] = "EBX",
    [5] = "ESP", [6] = "EBP", [7] = "ESI", [8] = "EDI",
}

---Creates a new register file with all registers cleared.
function RegisterFile.new()
    return setmetatable({ values = {0,0,0,0,0,0,0,0}, eip = 0 }, RegisterFile)
end

---Returns a general-purpose register by x86 register index.
function RegisterFile:get(index)
    return self.values[index + 1]
end

---Writes a normalized 32-bit value into a general-purpose register.
function RegisterFile:set(index, value)
    self.values[index + 1] = U32.normalize(value)
end

function RegisterFile:get_eip() return self.eip end
function RegisterFile:set_eip(value) self.eip = U32.normalize(value) end
function RegisterFile:add_eip(value) self.eip = U32.add32(self.eip, value) end

---Decrements ESP and writes a 32-bit value to guest memory.
function RegisterFile:push_value(value, memory)
    self:set(4, U32.sub32(self:get(4), 4))
    memory:write_u32(self:get(4), value)
end

---Reads a 32-bit stack value and increments ESP.
function RegisterFile:pop_value(memory)
    local value = memory:read_u32(self:get(4))
    self:set(4, U32.add32(self:get(4), 4))
    return value
end

function RegisterFile:dump()
    local out = {}
    for i = 0, 7 do
        out[#out + 1] = string.format("%-3s=%08X", RegisterFile.NAMES[i + 1], self:get(i))
    end
    out[#out + 1] = string.format("EIP=%08X", self.eip)
    return table.concat(out, " ")
end

return RegisterFile
