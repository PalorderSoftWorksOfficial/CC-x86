local CPU = require("src.x86.core.cpu")
local RawLoader = require("src.x86.loader.raw")
local Monitor = require("src.x86.io.monitor")

---@class Emulator
---High-level CC:Tweaked launcher wrapper around the x86 CPU.
local Emulator = {}
Emulator.__index = Emulator

---Creates a complete emulator with CPU, loader, and optional debugging.
function Emulator.new(options)
    options = options or {}
    local self = setmetatable({}, Emulator)
    self.cpu = CPU.new(options)
    self.loader = RawLoader.new(self.cpu.memory)
    self.debug = options.debug or false
    return self
end

---Loads a flat binary into guest RAM and sets the initial entry point.
function Emulator:load_raw(path, address)
    local entry = address or 0x00100000
    local size = self.loader:load(path, entry)
    self.cpu:reset(entry, 0x00700000)
    if self.debug then print(string.format("loaded %d bytes at %08X", size, entry)) end
    return size
end

---Runs the loaded guest program.
function Emulator:run()
    local monitor = self.debug and Monitor.new(self.cpu) or nil
    self.cpu:run(nil, monitor)
end

return Emulator
