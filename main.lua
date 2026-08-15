local Emulator = require("src.x86.core.emulator")

local args = { ... }
local path = args[1]
local format = "raw"
local options = {
    debug = false,
    profiler = false,
    memory_size = 16 * 1024 * 1024,
    trace = { enabled = false, limit = 256 },
}

for i = 2, #args do
    local argument = args[i]
    if argument == "--elf" then
        format = "elf"
    elseif argument == "--raw" then
        format = "raw"
    elseif argument == "--debug" then
        options.debug = true
    elseif argument == "--profile" then
        options.profiler = true
    elseif argument == "--trace" then
        options.trace.enabled = true
    elseif argument:match("^--trace%-limit=") then
        options.trace.limit = tonumber(argument:match("^--trace%-limit=(%d+)$")) or options.trace.limit
    elseif argument:match("^--memory=") then
        local megabytes = tonumber(argument:match("^--memory=(%d+)$"))
        if megabytes then options.memory_size = megabytes * 1024 * 1024 end
    else
        error("unknown option: " .. argument)
    end
end

if not path then
    print("CC:X86")
    print("usage: x86 <binary> [--raw|--elf] [--debug] [--trace] [--trace-limit=N] [--profile] [--memory=N]")
    return
end

local emulator = Emulator.new(options)
if format == "elf" then
    emulator:load_elf(path)
else
    emulator:load_raw(path, 0x00100000)
end
emulator:run()
