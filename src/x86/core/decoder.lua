local U32 = require("src.x86.util.u32")

---@class Decoder
---Fetches instruction bytes and resolves IA-32 ModR/M and SIB addressing.
local Decoder = {}
Decoder.__index = Decoder

function Decoder.new(cpu)
    return setmetatable({ cpu = cpu }, Decoder)
end

function Decoder:fetch_u8()
    local value = self.cpu.memory:read_u8(self.cpu.registers:get_eip())
    self.cpu.registers:add_eip(1)
    return value
end

function Decoder:fetch_u16()
    local value = self.cpu.memory:read_u16(self.cpu.registers:get_eip())
    self.cpu.registers:add_eip(2)
    return value
end

function Decoder:fetch_u32()
    local value = self.cpu.memory:read_u32(self.cpu.registers:get_eip())
    self.cpu.registers:add_eip(4)
    return value
end

function Decoder:fetch_i8()
    return U32.sign_extend8(self:fetch_u8())
end

function Decoder:fetch_i16()
    return U32.sign_extend16(self:fetch_u16())
end

function Decoder:fetch_i32()
    return U32.to_signed(self:fetch_u32())
end

---Decodes a ModR/M byte and any displacement belonging to it.
function Decoder:decode_modrm()
    local value = self:fetch_u8()
    local mode = bit32.rshift(value, 6)
    local reg = bit32.band(bit32.rshift(value, 3), 7)
    local rm = bit32.band(value, 7)
    local displacement = 0

    if mode == 0 and rm == 5 then
        displacement = self:fetch_u32()
    elseif mode == 1 then
        displacement = self:fetch_i8()
    elseif mode == 2 then
        displacement = self:fetch_u32()
    end

    return {
        mode = mode,
        reg = reg,
        rm = rm,
        displacement = displacement,
    }
end

---Resolves 32-bit protected-mode addressing, including the SIB special cases.
function Decoder:resolve_address(modrm)
    if modrm.mode == 3 then
        return nil
    end

    if modrm.rm == 4 then
        local sib = self:fetch_u8()
        local scale = 2 ^ bit32.rshift(sib, 6)
        local index = bit32.band(bit32.rshift(sib, 3), 7)
        local base = bit32.band(sib, 7)
        local address = 0

        if index ~= 4 then
            address = address + self.cpu.registers:get(index) * scale
        end

        if base == 5 and modrm.mode == 0 then
            address = address + self:fetch_u32()
        else
            address = address + self.cpu.registers:get(base)
        end

        return U32.normalize(address + modrm.displacement)
    end

    if modrm.rm == 5 and modrm.mode == 0 then
        return U32.normalize(modrm.displacement)
    end

    return U32.normalize(self.cpu.registers:get(modrm.rm) + modrm.displacement)
end

function Decoder:read_rm32(modrm, address)
    if modrm.mode == 3 then
        return self.cpu.registers:get(modrm.rm)
    end
    return self.cpu.memory:read_u32(address)
end

function Decoder:write_rm32(modrm, address, value)
    if modrm.mode == 3 then
        self.cpu.registers:set(modrm.rm, value)
    else
        self.cpu.memory:write_u32(address, value)
    end
end

return Decoder
