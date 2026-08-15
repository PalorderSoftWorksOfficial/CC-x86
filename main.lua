local Emulator = require("src.x86.core.emulator")

local args = { ... }
local path = args[1]
local debug = false

for i = 2, #args do
    if args[i] == "--debug" then
        debug = true
    end
end

if not path then
    print("CC:X86")
    print("usage: x86 <binary> [--debug]")
    return
end

local emulator = Emulator.new({ debug = debug })
emulator:load_raw(path, 0x00100000)
emulator:run()
