local CPU = require("src.x86.core.cpu")
local Flags = require("src.x86.core.flags")

local function run(bytes, setup, verify)
    local cpu = CPU.new({ memory_size = 0x10000 })
    cpu.memory:load(0x1000, string.char(table.unpack(bytes)))
    cpu:reset(0x1000, 0x7000)
    if setup then
        setup(cpu)
    end
    cpu:run(64)
    verify(cpu)
end

run({
    0xB8, 0xFF, 0xFF, 0xFF, 0xFF,
    0x40,
    0xF4,
}, function(cpu)
    cpu.flags:set(Flags.CF, true)
end, function(cpu)
    assert(cpu.registers:get(0) == 0)
    assert(cpu.flags:has(Flags.CF), "INC must preserve CF")
    assert(cpu.flags:has(Flags.ZF), "INC wraparound must set ZF")
end)

run({
    0xB8, 0x00, 0x00, 0x00, 0x00,
    0x48,
    0xF4,
}, function(cpu)
    cpu.flags:set(Flags.CF, true)
end, function(cpu)
    assert(cpu.registers:get(0) == 0xFFFFFFFF)
    assert(cpu.flags:has(Flags.CF), "DEC must preserve CF")
    assert(cpu.flags:has(Flags.SF), "DEC from zero must set SF")
end)

run({
    0xB8, 0x00, 0x00, 0x00, 0x40,
    0x0F, 0xA2,
    0xF4,
}, nil, function(cpu)
    assert(cpu.registers:get(0) == 0x40000001)
    assert(cpu.registers:get(1) == 0x564F4C43)
    assert(cpu.registers:get(2) == 0x3638582D)
    assert(cpu.registers:get(3) == 0x534F5245)
end)

run({
    0xB8, 0x00, 0x00, 0x00, 0x40,
    0x0F, 0xA2,
    0xF4,
}, nil, function(cpu)
    assert(cpu.registers:get(1) == 0x564F4C43, "CPUID must identify CLOV")
    assert(cpu.registers:get(3) == 0x534F5245, "CPUID must identify EROS")
    assert(cpu.registers:get(2) == 0x3638582D, "CPUID must identify -X86")
end)

print("CC:X86 conformance tests passed")
