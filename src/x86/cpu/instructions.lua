local bit = bit32
local U32 = require("src.x86.util.u32")

---@class InstructionSet
---Contains the implemented x86 opcode handlers and defines the main CPU expansion point.
local InstructionSet = {}
InstructionSet.__index = InstructionSet

function InstructionSet.new(cpu)
    local self = setmetatable({ cpu = cpu }, InstructionSet)
    self.handlers = {}
    self:register()
    return self
end

function InstructionSet:register()
    local h = self.handlers
    h[0x90] = function() end
    h[0xF4] = function(cpu) cpu.halted = true end

    for opcode = 0xB8, 0xBF do
        h[opcode] = function(cpu, op)
            cpu.registers:set(op - 0xB8, cpu.decoder:fetch_u32())
        end
    end

    for opcode = 0x50, 0x57 do
        h[opcode] = function(cpu, op)
            cpu.registers:push_value(cpu.registers:get(op - 0x50), cpu.memory)
        end
    end

    for opcode = 0x58, 0x5F do
        h[opcode] = function(cpu, op)
            cpu.registers:set(op - 0x58, cpu.registers:pop_value(cpu.memory))
        end
    end

    for opcode = 0x40, 0x47 do
        h[opcode] = function(cpu, op)
            local index = op - 0x40
            local old = cpu.registers:get(index)
            local result = U32.add32(old, 1)
            cpu.registers:set(index, result)
            cpu.flags:increment(old, result)
        end
    end

    for opcode = 0x48, 0x4F do
        h[opcode] = function(cpu, op)
            local index = op - 0x48
            local old = cpu.registers:get(index)
            local result = U32.sub32(old, 1)
            cpu.registers:set(index, result)
            cpu.flags:decrement(old, result)
        end
    end

    h[0x68] = function(cpu)
        cpu.registers:push_value(cpu.decoder:fetch_u32(), cpu.memory)
    end

    h[0x6A] = function(cpu)
        cpu.registers:push_value(cpu.decoder:fetch_i8(), cpu.memory)
    end

    h[0x89] = function(cpu)
        local m = cpu.decoder:decode_modrm()
        local a = cpu.decoder:resolve_address(m)
        cpu.decoder:write_rm32(m, a, cpu.registers:get(m.reg))
    end

    h[0x8B] = function(cpu)
        local m = cpu.decoder:decode_modrm()
        local a = cpu.decoder:resolve_address(m)
        cpu.registers:set(m.reg, cpu.decoder:read_rm32(m, a))
    end

    h[0x8D] = function(cpu)
        local m = cpu.decoder:decode_modrm()
        if m.mode == 3 then error("invalid LEA register operand") end
        cpu.registers:set(m.reg, cpu.decoder:resolve_address(m))
    end

    h[0xC7] = function(cpu)
        local m = cpu.decoder:decode_modrm()
        if m.reg ~= 0 then error("unsupported C7 /" .. m.reg) end
        local a = cpu.decoder:resolve_address(m)
        cpu.decoder:write_rm32(m, a, cpu.decoder:fetch_u32())
    end

    local arithmetic = {
        [0x01] = function(cpu, a, b) return cpu.u32.add32(a, b) end,
        [0x29] = function(cpu, a, b) return cpu.u32.sub32(a, b) end,
        [0x31] = function(_, a, b) return bit.bxor(a, b) end,
    }

    for opcode, operation in pairs(arithmetic) do
        h[opcode] = function(cpu)
            local m = cpu.decoder:decode_modrm()
            local a = cpu.decoder:resolve_address(m)
            local left = cpu.decoder:read_rm32(m, a)
            local right = cpu.registers:get(m.reg)
            local result = operation(cpu, left, right)
            cpu.decoder:write_rm32(m, a, result)
            if opcode == 0x31 then
                cpu.flags:logical(result)
            elseif opcode == 0x01 then
                cpu.flags:add(left, right, result)
            else
                cpu.flags:sub(left, right, result)
            end
        end
    end

    h[0x03] = function(cpu)
        local m = cpu.decoder:decode_modrm()
        local a = cpu.decoder:resolve_address(m)
        local left = cpu.registers:get(m.reg)
        local right = cpu.decoder:read_rm32(m, a)
        local result = U32.add32(left, right)
        cpu.registers:set(m.reg, result)
        cpu.flags:add(left, right, result)
    end

    h[0x2B] = function(cpu)
        local m = cpu.decoder:decode_modrm()
        local a = cpu.decoder:resolve_address(m)
        local left = cpu.registers:get(m.reg)
        local right = cpu.decoder:read_rm32(m, a)
        local result = U32.sub32(left, right)
        cpu.registers:set(m.reg, result)
        cpu.flags:sub(left, right, result)
    end

    h[0x33] = function(cpu)
        local m = cpu.decoder:decode_modrm()
        local a = cpu.decoder:resolve_address(m)
        local result = bit.bxor(cpu.registers:get(m.reg), cpu.decoder:read_rm32(m, a))
        cpu.registers:set(m.reg, result)
        cpu.flags:logical(result)
    end

    h[0x39] = function(cpu)
        local m = cpu.decoder:decode_modrm()
        local a = cpu.decoder:resolve_address(m)
        local left = cpu.decoder:read_rm32(m, a)
        local right = cpu.registers:get(m.reg)
        cpu.flags:sub(left, right, U32.sub32(left, right))
    end

    h[0x3B] = function(cpu)
        local m = cpu.decoder:decode_modrm()
        local a = cpu.decoder:resolve_address(m)
        local left = cpu.registers:get(m.reg)
        local right = cpu.decoder:read_rm32(m, a)
        cpu.flags:sub(left, right, U32.sub32(left, right))
    end

    h[0x85] = function(cpu)
        local m = cpu.decoder:decode_modrm()
        local a = cpu.decoder:resolve_address(m)
        cpu.flags:logical(bit.band(cpu.registers:get(m.reg), cpu.decoder:read_rm32(m, a)))
    end

    h[0x05] = function(cpu)
        local old = cpu.registers:get(0)
        local value = cpu.decoder:fetch_u32()
        local result = U32.add32(old, value)
        cpu.registers:set(0, result)
        cpu.flags:add(old, value, result)
    end

    h[0x2D] = function(cpu)
        local old = cpu.registers:get(0)
        local value = cpu.decoder:fetch_u32()
        local result = U32.sub32(old, value)
        cpu.registers:set(0, result)
        cpu.flags:sub(old, value, result)
    end

    h[0x35] = function(cpu)
        local result = bit.bxor(cpu.registers:get(0), cpu.decoder:fetch_u32())
        cpu.registers:set(0, result)
        cpu.flags:logical(result)
    end

    h[0x25] = function(cpu)
        local result = bit.band(cpu.registers:get(0), cpu.decoder:fetch_u32())
        cpu.registers:set(0, result)
        cpu.flags:logical(result)
    end

    h[0x0D] = function(cpu)
        local result = bit.bor(cpu.registers:get(0), cpu.decoder:fetch_u32())
        cpu.registers:set(0, result)
        cpu.flags:logical(result)
    end

    h[0xE8] = function(cpu)
        local displacement = cpu.decoder:fetch_i32()
        cpu.registers:push_value(cpu.registers:get_eip(), cpu.memory)
        cpu.registers:set_eip(U32.add32(cpu.registers:get_eip(), displacement))
    end

    h[0xE9] = function(cpu)
        cpu.registers:set_eip(U32.add32(cpu.registers:get_eip(), cpu.decoder:fetch_i32()))
    end

    h[0xEB] = function(cpu)
        cpu.registers:set_eip(U32.add32(cpu.registers:get_eip(), cpu.decoder:fetch_i8()))
    end

    h[0xC3] = function(cpu)
        cpu.registers:set_eip(cpu.registers:pop_value(cpu.memory))
    end

    h[0xC2] = function(cpu)
        local n = cpu.decoder:fetch_u16()
        cpu.registers:set_eip(cpu.registers:pop_value(cpu.memory))
        cpu.registers:set(4, U32.add32(cpu.registers:get(4), n))
    end

    for opcode = 0x70, 0x7F do
        h[opcode] = function(cpu, op)
            local displacement = cpu.decoder:fetch_i8()
            if cpu.flags:condition(op - 0x70) then
                cpu.registers:set_eip(U32.add32(cpu.registers:get_eip(), displacement))
            end
        end
    end

    for opcode = 0x80, 0x8F do
        h[opcode] = function(cpu, op)
            local displacement = cpu.decoder:fetch_i32()
            if cpu.flags:condition(op - 0x80) then
                cpu.registers:set_eip(U32.add32(cpu.registers:get_eip(), displacement))
            end
        end
    end

    h[0xA1] = function(cpu)
        cpu.registers:set(0, cpu.memory:read_u32(cpu.decoder:fetch_u32()))
    end

    h[0xA3] = function(cpu)
        cpu.memory:write_u32(cpu.decoder:fetch_u32(), cpu.registers:get(0))
    end

    h[0xCD] = function(cpu)
        cpu.bios:interrupt(cpu.decoder:fetch_u8())
    end

    h[0xFA] = function(cpu) cpu.flags:set(cpu.flags.IF, false) end
    h[0xFB] = function(cpu) cpu.flags:set(cpu.flags.IF, true) end
    h[0xFC] = function(cpu) cpu.flags:set(cpu.flags.DF, false) end
    h[0xFD] = function(cpu) cpu.flags:set(cpu.flags.DF, true) end

    h[0x0F] = function(cpu)
        local extended = cpu.decoder:fetch_u8()

        if extended == 0xAF then
            local m = cpu.decoder:decode_modrm()
            local a = cpu.decoder:resolve_address(m)
            local left = cpu.registers:get(m.reg)
            local right = cpu.decoder:read_rm32(m, a)
            cpu.registers:set(m.reg, U32.normalize(left * right))
            return
        end

        if extended >= 0x80 and extended <= 0x8F then
            local displacement = cpu.decoder:fetch_i32()
            if cpu.flags:condition(extended - 0x80) then
                cpu.registers:set_eip(U32.add32(cpu.registers:get_eip(), displacement))
            end
            return
        end

        error(string.format("unsupported 0F opcode %02X at EIP=%08X", extended, cpu.registers:get_eip() - 2))
    end
end

function InstructionSet:execute(opcode)
    local handler = self.handlers[opcode]
    if not handler then
        error(string.format("unsupported opcode %02X at EIP=%08X", opcode, self.cpu.registers:get_eip() - 1))
    end
    handler(self.cpu, opcode)
end

return InstructionSet
