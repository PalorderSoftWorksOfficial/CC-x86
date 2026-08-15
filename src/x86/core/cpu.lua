local RegisterFile = require("src.x86.core.registers")
local Flags = require("src.x86.core.flags")
local Memory = require("src.x86.core.memory")
local Decoder = require("src.x86.core.decoder")
local InstructionSet = require("src.x86.cpu.instructions")
local BIOS = require("src.x86.io.bios")
local U32 = require("src.x86.util.u32")

---@class CPU
---Implements the fetch, decode, execute loop for the guest processor.
local CPU = {}
CPU.__index = CPU

---Creates an x86 CPU with guest RAM and all execution subsystems attached.
function CPU.new(options)
    options = options or {}
    local self = setmetatable({}, CPU)
    self.memory = Memory.new(options.memory_size or 16 * 1024 * 1024)
    self.registers = RegisterFile.new()
    self.flags = Flags.new()
    self.halted = false
    self.cycles = 0
    self.u32 = U32
    self.decoder = Decoder.new(self)
    self.bios = BIOS.new(self)
    self.instructions = InstructionSet.new(self)
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
end

---Executes exactly one guest instruction.
function CPU:step()
    if self.halted then return false end
    local opcode = self.decoder:fetch_u8()
    self.instructions:execute(opcode)
    self.cycles = self.cycles + 1
    return true
end

---Runs guest instructions until HLT or an optional cycle limit.
function CPU:run(limit, monitor)
    local max = limit or math.huge
    while not self.halted and self.cycles < max do
        if monitor then monitor:step() end
        self:step()
    end
    if monitor then monitor:halt() end
end

return CPU
