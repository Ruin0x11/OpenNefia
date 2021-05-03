local Item = require("api.Item")
local utils = require("mod.test_room.data.map_archetype.utils")
local IChargeable = require("mod.elona.api.aspect.IChargeable")

local chargeable = {
   _id = "chargeable"
}

local function make_chargeables(x, y, map, can_gen)
   local filter = function(item)
      if not item._ext then
         return false
      end
      for iface, _ in pairs(item._ext) do
         if class.is_an(IChargeable, iface) then
            return true
         end
      end

      return false
   end

   local ix = x
   local iy = y
   for _, idx, item in data["base.item"]:iter():filter(filter):enumerate() do
      ix = x + ((idx - 1) % (map:width() - x - 2))
      iy = y + math.floor((idx - 1) / (map:width() - x - 2))
      if not map:can_access(ix, iy) then
         break
      end

      assert(Item.create(item._id, ix, iy, {}, map))
   end

   return 2, iy + 2
end

function chargeable.on_generate_map(area, floor)
   local map = utils.create_map(15, 15)
   utils.create_stairs(2, 2, area, map)

   local x = 2
   local y = 4

   x, y = make_chargeables(x, y, map)

   return map
end

return chargeable
