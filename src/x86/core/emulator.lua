local CPU = require("src.x86.core.cpu")
local RawLoader = require("src.x86.loader.raw")
local Elf32Loader = require("src.x86.loader.elf32")
local Monitor = require("src.x86.io.monitor")

---@class Emulator
---Coordinates the guest CPU, memory image loaders, debugger, and runtime configuration.
local Emulator = {}
Emulator.__index = Emulator

function Emulator.new(options)
    options = options or {}
    local self = setmetatable({}, Emulator)
    self.cpu = CPU.new(options)
    self.raw_loader = RawLoader.new(self.cpu.memory)
    self.elf_loader = Elf32Loader.new(self.cpu.memory)
    self.debug = options.debug or false
    return self
end

---Loads a flat binary image and establishes a conventional CC:X86 stack.
function Emulator:load_raw(path, address)
    local entry = address or 0x00100000
    local size = self.raw_loader:load(path, entry)
    self.cpu:reset(entry, self.cpu.memory.size - 0x1000)
    if self.debug then
        print(string.format("loaded %d bytes at %08X", size, entry))
    end
    return entry, size
end

---Loads an ELF32 i386 image using its PT_LOAD segments and entry point.
function Emulator:load_elf(path)
    local entry, segments = self.elf_loader:load(path)
    self.cpu:reset(entry, self.cpu.memory.size - 0x1000)
    if self.debug then
        print(string.format("loaded ELF32 entry=%08X segments=%d", entry, #segments))
        for index, segment in ipairs(segments) do
            print(string.format("  #%d %08X file=%d mem=%d", index, segment.address, segment.file_size, segment.memory_size))
        end
    end
    return entry, segments
end

function Emulator:run(limit)
    local monitor = self.debug and Monitor.new(self.cpu) or nil
    self.cpu:run(limit, monitor)
    if self.cpu.profiler then
        print(self.cpu.profiler:report())
    end
end

return Emulator
