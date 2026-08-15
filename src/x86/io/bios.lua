local bit = bit32
local U32 = require("src.x86.util.u32")

---@class BIOS
---Provides the emulator's deliberately small host interrupt interface.
local BIOS = {}
BIOS.__index = BIOS

---Creates a BIOS service layer bound to the CPU.
function BIOS.new(cpu) return setmetatable({ cpu = cpu }, BIOS) end

---Handles a guest software interrupt number.
function BIOS:interrupt(number)
    if number ~= 0x80 then error(string.format("unsupported interrupt %02X", number)) end
    local eax = self.cpu.registers:get(0)
    local ebx = self.cpu.registers:get(3)
    if eax == 1 then print(U32.to_signed(eax))
    elseif eax == 2 then write(string.char(bit.band(ebx, 0xFF)))
    elseif eax == 3 then print(self.cpu.memory:read_cstring(ebx))
    elseif eax == 6 then self.cpu.halted = true
    else error(string.format("unsupported BIOS call EAX=%08X", eax)) end
end

return BIOS
