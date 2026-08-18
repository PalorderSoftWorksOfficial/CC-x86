local RegisterFile = require("src.x86.core.registers")
local Flags = require("src.x86.core.flags")
local Memory = require("src.x86.core.memory")
local Decoder = require("src.x86.core.decoder")
local InstructionSet = require("src.x86.cpu.instructions")
local Extensions = require("src.x86.cpu.extensions")
local BIOS = require("src.x86.io.bios")
local Bus = require("src.x86.hardware.bus")
local ConsoleDevice = require("src.x86.hardware.console")
local U32 = require("src.x86.util.u32")
local Profiler = require("src.x86.debug.profiler")
local Tracer = require("src.x86.debug.tracer")

---@class CPU
local CPU = {}
CPU.__index = CPU

function CPU.new(options)
    options = options or {}
    local self = setmetatable({}, CPU)
    self.memory = Memory.new(options.memory_size or 16 * 1024 * 1024)
    self.registers = RegisterFile.new()
    self.flags = Flags.new()
    self.halted = false
    self.cycles = 0
    self.u32 = U32
    self.profiler = options.profiler and Profiler.new() or nil
    self.tracer = Tracer.new(self, options.trace or {})
    self.decoder = Decoder.new(self)
    self.bus = Bus.new()
    self.console = ConsoleDevice.new()
    self.bus:attach("console", self.console)
    self.bus:attach_port(0xE9, self.console)
    self.bios = BIOS.new(self)
    self.instructions = InstructionSet.new(self)
    Extensions.install(self)
    return self
end

function CPU:reset(entry, stack)
    self.registers = RegisterFile.new()
    self.registers:set_eip(entry or 0)
    self.registers:set(4, stack or 0)
    self.registers:set(5, stack or 0)
    self.flags = Flags.new()
    self.halted = false
    self.cycles = 0
    self.bus:reset()
    if self.profiler then
        self.profiler = Profiler.new()
    end
    self.tracer.count = 0
end

function CPU:step()
    if self.halted then
        return false
    end

    local opcode_address = self.registers:get_eip()
    local opcode = self.decoder:fetch_u8()
    if self.profiler then
        self.profiler:record(opcode)
    end
    self.tracer:before(opcode, opcode_address)
    self.instructions:execute(opcode)
    self.cycles = self.cycles + 1
    return true
end

function CPU:run(limit, monitor)
    local max = limit or math.huge
    while not self.halted and self.cycles < max do
        if monitor then
            monitor:step()
        end
        self:step()
    end
    if monitor then
        monitor:halt()
    end
end

return CPU
