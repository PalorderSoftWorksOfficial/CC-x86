---@class Bus
local Bus = {}
Bus.__index = Bus

function Bus.new()
    return setmetatable({ devices = {}, ports = {} }, Bus)
end

function Bus:attach(name, device)
    if self.devices[name] then
        error("device already attached: " .. name)
    end
    self.devices[name] = device
end

function Bus:get(name)
    return self.devices[name]
end

function Bus:attach_port(port, device)
    if self.ports[port] then
        error(string.format("port already attached: %02X", port))
    end
    self.ports[port] = device
end

function Bus:read(port, width)
    local device = self.ports[port]
    if not device then
        error(string.format("unmapped I/O read port %04X", port))
    end
    if device.read then
        return device:read(width)
    end
    if width == 8 and device.read_byte then
        return device:read_byte()
    end
    error(string.format("device at port %04X cannot read %d-bit values", port, width))
end

function Bus:write(port, value, width)
    local device = self.ports[port]
    if not device then
        error(string.format("unmapped I/O write port %04X", port))
    end
    if device.write then
        return device:write(value, width)
    end
    if width == 8 and device.write_byte then
        return device:write_byte(value)
    end
    error(string.format("device at port %04X cannot write %d-bit values", port, width))
end

function Bus:reset()
    for _, device in pairs(self.devices) do
        if device.reset then
            device:reset()
        end
    end
    for _, device in pairs(self.ports) do
        if device.reset then
            device:reset()
        end
    end
end

return Bus
