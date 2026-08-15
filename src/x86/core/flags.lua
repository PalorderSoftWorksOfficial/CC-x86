local bit = bit32

---@class Flags
---Models EFLAGS and x86 arithmetic condition helpers.
local Flags = {}
Flags.__index = Flags
Flags.CF, Flags.PF, Flags.AF, Flags.ZF = 0x001, 0x004, 0x010, 0x040
Flags.SF, Flags.IF, Flags.DF, Flags.OF = 0x080, 0x200, 0x400, 0x800

local function parity8(value)
    local count = 0
    value = bit.band(value, 0xFF)
    for _ = 1, 8 do
        count = count + bit.band(value, 1)
        value = bit.rshift(value, 1)
    end
    return count % 2 == 0
end

---Creates EFLAGS with architectural reserved bit 1 set.
function Flags.new()
    return setmetatable({ value = 0x00000002 }, Flags)
end

function Flags:has(mask) return bit.band(self.value, mask) ~= 0 end

function Flags:set(mask, enabled)
    if enabled then self.value = bit.bor(self.value, mask) else self.value = bit.band(self.value, bit.bnot(mask)) end
end

---Updates flags for a logical operation.
function Flags:logical(result)
    self:set(self.CF, false)
    self:set(self.OF, false)
    self:set(self.ZF, result == 0)
    self:set(self.SF, bit.band(result, 0x80000000) ~= 0)
    self:set(self.PF, parity8(result))
end

---Updates flags for a 32-bit addition.
function Flags:add(a, b, result)
    self:set(self.CF, result < a)
    self:set(self.ZF, result == 0)
    self:set(self.SF, bit.band(result, 0x80000000) ~= 0)
    self:set(self.PF, parity8(result))
    self:set(self.OF, bit.band(bit.bnot(bit.bxor(a, b)), bit.bxor(a, result), 0x80000000) ~= 0)
end

---Updates flags for a 32-bit subtraction or comparison.
function Flags:sub(a, b, result)
    self:set(self.CF, a < b)
    self:set(self.ZF, result == 0)
    self:set(self.SF, bit.band(result, 0x80000000) ~= 0)
    self:set(self.PF, parity8(result))
    self:set(self.OF, bit.band(bit.bxor(a, b), bit.bxor(a, result), 0x80000000) ~= 0)
end

---Evaluates one of the sixteen x86 Jcc condition codes.
function Flags:condition(code)
    if code == 0 then return self:has(self.OF)
    elseif code == 1 then return not self:has(self.OF)
    elseif code == 2 then return self:has(self.CF)
    elseif code == 3 then return not self:has(self.CF)
    elseif code == 4 then return self:has(self.ZF)
    elseif code == 5 then return not self:has(self.ZF)
    elseif code == 6 then return self:has(self.CF) or self:has(self.ZF)
    elseif code == 7 then return not self:has(self.CF) and not self:has(self.ZF)
    elseif code == 8 then return self:has(self.SF)
    elseif code == 9 then return not self:has(self.SF)
    elseif code == 10 then return self:has(self.PF)
    elseif code == 11 then return not self:has(self.PF)
    elseif code == 12 then return self:has(self.SF) ~= self:has(self.OF)
    elseif code == 13 then return self:has(self.SF) == self:has(self.OF)
    elseif code == 14 then return self:has(self.ZF) or self:has(self.SF) ~= self:has(self.OF)
    elseif code == 15 then return not self:has(self.ZF) and self:has(self.SF) == self:has(self.OF)
    end
    return false
end

function Flags:summary()
    return string.format("%08X CF=%d PF=%d ZF=%d SF=%d IF=%d DF=%d OF=%d", self.value, self:has(self.CF) and 1 or 0, self:has(self.PF) and 1 or 0, self:has(self.ZF) and 1 or 0, self:has(self.SF) and 1 or 0, self:has(self.IF) and 1 or 0, self:has(self.DF) and 1 or 0, self:has(self.OF) and 1 or 0)
end

return Flags
