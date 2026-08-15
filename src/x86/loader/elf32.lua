local U32 = require("src.x86.util.u32")

---@class Elf32Loader
---Loads little-endian 32-bit Intel ELF executables into guest memory.
local Elf32Loader = {}
Elf32Loader.__index = Elf32Loader

local PT_LOAD = 1
local EM_386 = 3

local function byte(data, offset)
    return string.byte(data, offset + 1) or 0
end

local function u16(data, offset)
    return byte(data, offset) + bit32.lshift(byte(data, offset + 1), 8)
end

local function u32(data, offset)
    return U32.normalize(byte(data, offset)
        + bit32.lshift(byte(data, offset + 1), 8)
        + bit32.lshift(byte(data, offset + 2), 16)
        + bit32.lshift(byte(data, offset + 3), 24))
end

local function slice(data, offset, length)
    return string.sub(data, offset + 1, offset + length)
end

function Elf32Loader.new(memory)
    return setmetatable({ memory = memory }, Elf32Loader)
end

---Loads an ELF32 executable and returns its entry point and segment metadata.
function Elf32Loader:load(path)
    local handle = fs.open(path, "rb")
    if not handle then error("cannot open ELF file: " .. path) end
    local data = handle.readAll()
    handle.close()

    if #data < 52 then error("ELF file is truncated") end
    if byte(data, 0) ~= 0x7F or byte(data, 1) ~= 0x45 or byte(data, 2) ~= 0x4C or byte(data, 3) ~= 0x46 then
        error("not an ELF file")
    end
    if byte(data, 4) ~= 1 then error("ELF is not 32-bit") end
    if byte(data, 5) ~= 1 then error("ELF is not little-endian") end
    if u16(data, 18) ~= EM_386 then error("ELF target is not i386") end

    local entry = u32(data, 24)
    local program_header_offset = u32(data, 28)
    local program_header_size = u16(data, 42)
    local program_header_count = u16(data, 44)
    local loaded = {}

    if program_header_size < 32 then error("unsupported ELF program header size") end

    for index = 0, program_header_count - 1 do
        local header = program_header_offset + index * program_header_size
        if header + 32 > #data then error("ELF program header table is truncated") end

        local kind = u32(data, header)
        if kind == PT_LOAD then
            local offset = u32(data, header + 4)
            local address = u32(data, header + 8)
            local file_size = u32(data, header + 16)
            local memory_size = u32(data, header + 20)

            if offset + file_size > #data then error("ELF load segment exceeds file") end
            if file_size > memory_size then error("ELF load segment has invalid sizes") end

            local segment = slice(data, offset, file_size)
            self.memory:load(address, segment)
            loaded[#loaded + 1] = {
                address = address,
                file_size = file_size,
                memory_size = memory_size,
            }
        end
    end

    if #loaded == 0 then error("ELF contains no PT_LOAD segments") end
    return entry, loaded
end

return Elf32Loader
