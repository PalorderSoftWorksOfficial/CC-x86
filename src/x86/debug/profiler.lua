---@class Profiler
---Collects lightweight instruction and opcode execution statistics for emulator tuning.
local Profiler = {}
Profiler.__index = Profiler

function Profiler.new()
    return setmetatable({
        total = 0,
        opcodes = {},
        started = os.epoch and os.epoch("utc") or 0,
    }, Profiler)
end

function Profiler:record(opcode)
    self.total = self.total + 1
    self.opcodes[opcode] = (self.opcodes[opcode] or 0) + 1
end

function Profiler:report(limit)
    local rows = {}
    for opcode, count in pairs(self.opcodes) do
        rows[#rows + 1] = { opcode = opcode, count = count }
    end
    table.sort(rows, function(a, b)
        return a.count > b.count
    end)

    local elapsed = (os.epoch and os.epoch("utc") or 0) - self.started
    local out = {
        string.format("instructions=%d elapsed_ms=%d", self.total, elapsed),
    }

    for i = 1, math.min(limit or 12, #rows) do
        local row = rows[i]
        out[#out + 1] = string.format("%02X %d", row.opcode, row.count)
    end

    return table.concat(out, "\n")
end

return Profiler
