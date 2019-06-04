local data = require("internal.data")
local asset_drawable = require("internal.draw.asset_drawable")

local Asset = {}

local cache = setmetatable({}, { __mode = "v" })
local outdated = {}

function Asset.load(id)
   if cache[id] and not outdated[id] then
      return cache[id]
   end

   outdated[id] = nil

   local dat = data["base.asset"][id]
   if dat == nil then
      return nil
   end

   cache[id] = asset_drawable:new(dat)

   return cache[id]
end

function Asset.mark_outdated(id)
   outdated[id] = true
end

return Asset
