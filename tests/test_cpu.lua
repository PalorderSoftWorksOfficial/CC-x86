local CPU = require("src.x86.core.cpu")

local function load_bytes(cpu, address, bytes)
    cpu.memory:load(address, string.char(table.unpack(bytes)))
    cpu:reset(address, 0x7000)
end

local cpu = CPU.new({ memory_size = 0x10000 })
load_bytes(cpu, 0x1000, {
    0xB8, 0x05, 0x00, 0x00, 0x00,
    0xBB, 0x07, 0x00, 0x00, 0x00,
    0x01, 0xD8,
    0xF4,
})
cpu:run()
assert(cpu.registers:get(0) == 12, "EAX should contain 12")
assert(cpu.halted, "CPU should halt")
print("CC:X86 CPU tests passed")
