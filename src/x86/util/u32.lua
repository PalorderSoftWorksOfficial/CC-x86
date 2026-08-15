local bit = bit32

---@class U32
---Provides explicit 32-bit unsigned and signed arithmetic helpers.
local U32 = {}

---Normalizes a Lua number to the emulator's 32-bit unsigned range.
function U32.normalize(value)
    return bit.band(value, 0xFFFFFFFF)
end

---Converts a 32-bit unsigned value to a signed IA-32 integer.
function U32.to_signed(value)
    value = U32.normalize(value)
    if value >= 0x80000000 then
        return value - 0x100000000
    end
    return value
end

function U32.sign_bit(value)
    return bit.band(value, 0x80000000) ~= 0
end

function U32.sign_extend8(value)
    if value >= 0x80 then return value - 0x100 end
    return value
end

function U32.sign_extend16(value)
    if value >= 0x8000 then return value - 0x10000 end
    return value
end

function U32.add32(a, b)
    return U32.normalize(a + b)
end

function U32.sub32(a, b)
    return U32.normalize(a - b)
end

return U32
