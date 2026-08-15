---@class Bus
---Keeps emulated hardware behind a small attach-and-lookup boundary.
local Bus = {}
Bus.__index = Bus

function Bus.new()
    return setmetatable({ devices = {} }, Bus)
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

function Bus:reset()
    for _, device in pairs(self.devices) do
        if device.reset then
            device:reset()
        end
    end
end

return Bus
