---@class Monitor
---Displays guest CPU state for WIP emulator debugging.
local Monitor = {}
Monitor.__index = Monitor

---Creates a monitor attached to a CPU instance.
function Monitor.new(cpu) return setmetatable({ cpu = cpu }, Monitor) end

---Prints register and flag state before an instruction.
function Monitor:step()
    print(self.cpu.registers:dump())
    print("EFLAGS " .. self.cpu.flags:summary())
end

function Monitor:halt()
    print("guest halted")
    print(self.cpu.registers:dump())
    print("EFLAGS " .. self.cpu.flags:summary())
end

return Monitor
