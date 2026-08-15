local OpcodeMetadata = require("src.x86.cpu.opcodes")

---@class Tracer
---Produces compact opcode-aware execution traces for debugging guest programs.
local Tracer = {}
Tracer.__index = Tracer

function Tracer.new(cpu, options)
    options = options or {}
    return setmetatable({
        cpu = cpu,
        enabled = options.enabled or false,
        limit = options.limit or math.huge,
        count = 0,
    }, Tracer)
end

function Tracer:before(opcode, address)
    if not self.enabled or self.count >= self.limit then
        return
    end
    print(string.format("%08X  %02X  %-18s %s", address, opcode, OpcodeMetadata.name(opcode), self.cpu.registers:dump()))
    self.count = self.count + 1
end

return Tracer
