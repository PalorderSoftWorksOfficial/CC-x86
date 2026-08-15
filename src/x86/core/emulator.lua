local CPU = require("src.x86.core.cpu")
local RawLoader = require("src.x86.loader.raw")
local Monitor = require("src.x86.io.monitor")

---@class Emulator
---Coordinates the guest CPU, loader, debugger, and runtime configuration.
local Emulator = {}
Emulator.__index = Emulator

function Emulator.new(options)
    options = options or {}
    local self = setmetatable({}, Emulator)
    self.cpu = CPU.new(options)
    self.loader = RawLoader.new(self.cpu.memory)
    self.debug = options.debug or false
    return self
end

function Emulator:load_raw(path, address)
    local entry = address or 0x00100000
    local size = self.loader:load(path, entry)
    self.cpu:reset(entry, self.cpu.memory.size - 0x1000)
    if self.debug then
        print(string.format("loaded %d bytes at %08X", size, entry))
    end
    return size
end

function Emulator:run(limit)
    local monitor = self.debug and Monitor.new(self.cpu) or nil
    self.cpu:run(limit, monitor)
    if self.cpu.profiler then
        print(self.cpu.profiler:report())
    end
end

return Emulator
