local Flags = require("src.x86.core.flags")

local flags = Flags.new()
flags:add(0xFFFFFFFF, 1, 0)
assert(flags:has(flags.CF), "addition should set CF")
assert(flags:has(flags.ZF), "addition should set ZF")

flags = Flags.new()
flags:sub(0, 1, 0xFFFFFFFF)
assert(flags:has(flags.CF), "subtraction should set CF")
assert(not flags:has(flags.ZF), "subtraction should clear ZF")

flags = Flags.new()
flags:set(flags.CF, true)
flags:increment(0xFFFFFFFF, 0)
assert(flags:has(flags.CF), "INC must preserve CF")

print("CC:X86 flag tests passed")
