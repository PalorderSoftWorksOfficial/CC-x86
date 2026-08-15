local bit = bit32
local U32 = require("src.x86.util.u32")

---@class BIOS
---Provides the intentionally small firmware ABI exposed through INT 0x80.
local BIOS = {}
BIOS.__index = BIOS
BIOS.VERSION = 0x00010000

function BIOS.new(cpu)
    return setmetatable({ cpu = cpu }, BIOS)
end

---Handles one guest software interrupt. This is not a Linux syscall ABI.
function BIOS:interrupt(number)
    if number ~= 0x80 then
        error(string.format("unsupported interrupt %02X", number))
    end

    local eax = self.cpu.registers:get(0)
    local ebx = self.cpu.registers:get(3)

    if eax == 0 then
        self.cpu.registers:set(0, BIOS.VERSION)
    elseif eax == 1 then
        print(U32.to_signed(ebx))
    elseif eax == 2 then
        write(string.char(bit.band(ebx, 0xFF)))
    elseif eax == 3 then
        print(self.cpu.memory:read_cstring(ebx, 4096))
    elseif eax == 4 then
        self.cpu.registers:set(0, os.epoch("utc"))
    elseif eax == 6 then
        self.cpu.halted = true
    else
        error(string.format("unsupported BIOS call EAX=%08X", eax))
    end
end

return BIOS
