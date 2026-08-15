---@class ConsoleDevice
---A tiny guest character device backed by the CC:Tweaked terminal for firmware demos.
local ConsoleDevice = {}
ConsoleDevice.__index = ConsoleDevice

function ConsoleDevice.new()
    return setmetatable({ buffer = {} }, ConsoleDevice)
end

function ConsoleDevice:write_byte(value)
    local byte = bit32.band(value, 0xFF)
    write(string.char(byte))
    self.buffer[#self.buffer + 1] = byte
end

function ConsoleDevice:write_string(value)
    write(value)
    for i = 1, #value do
        self.buffer[#self.buffer + 1] = string.byte(value, i)
    end
end

function ConsoleDevice:reset()
    self.buffer = {}
end

return ConsoleDevice
