local Item = require("api.Item")
local utils = require("mod.test_room.data.map_archetype.utils")
local Filters = require("mod.elona.api.Filters")

local deed = {
   _id = "deed"
}

local function make_deeds(x, y, map)
   local ix = x
   local iy = y
   for i, deed_id in ipairs(Filters.isetdeed) do
      ix = x + ((i - 1) % (map:width() - x - 2))
      iy = y + math.floor((i - 1) / (map:width() - x - 2))
      if not map:can_access(ix, iy) then
         break
      end

      Item.create(deed_id, ix, iy, {}, map)
   end

   return 2, iy + 2
end

local function make_seeds(x, y, map)
   local ix = x
   local iy = y

   local filter = function(i)
      if i.categories then
         return table.set(i.categories)["elona.crop_seed"] ~= nil
      end
   end

   for _, i, seed_id in data["base.item"]:iter():filter(filter):enumerate() do
      ix = x + ((i - 1) % (map:width() - x - 2))
      iy = y + math.floor((i - 1) / (map:width() - x - 2))
      if not map:can_access(ix, iy) then
         break
      end

      Item.create(seed_id, ix, iy, {}, map)
   end

   return 2, iy + 2
end

function deed.on_generate_map(area, floor)
   local map = utils.create_map(20, 20)
   utils.create_stairs(2, 2, area, map)

   local x = 2
   local y = 4

   x, y = make_deeds(x, y, map)
   x, y = make_seeds(x, y, map)

   utils.normalize_items(map)

   return map
end

return deed
