---@class RawLoader
---Loads flat binary images from the CC:Tweaked filesystem into guest RAM.
local RawLoader = {}
RawLoader.__index = RawLoader

---Creates a raw loader targeting a memory instance.
function RawLoader.new(memory) return setmetatable({ memory = memory }, RawLoader) end

---Loads a complete file at the supplied physical guest address.
function RawLoader:load(path, address)
    local handle = fs.open(path, "rb")
    if not handle then error("cannot open binary: " .. path) end
    local data = handle.readAll()
    handle.close()
    self.memory:load(address, data)
    return #data
end

return RawLoader
