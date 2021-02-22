local utils = require("mod.test_room.data.map_archetype.utils")
local Item = require("api.Item")
local Enum = require("api.Enum")
local Chara = require("api.Chara")

local give = {
   _id = "give"
}

local function layout_items(iter, x, y, ex, ey, map)
   local ix = x
   local iy = y

   for _, i, id in iter:enumerate() do
      ix = x + ((i - 1) % (map:width() - x - ex))
      iy = y + math.floor((i - 1) / (map:width() - x - ex))
      if not map:can_access(ix, iy) then
         break
      end

      Item.create(id, ix, iy, {}, map)
   end

   return ex, iy + ey
end

function give.on_generate_map(area, floor)
   local map = utils.create_map(20, 20)
   utils.create_stairs(2, 2, area, map)

   local x = 2
   local y = 4

   local special = fun.iter({"elona.engagement_ring", "elona.engagement_amulet", "elona.love_potion"})
   x, y = layout_items(special, x, y, 2, 2, map)

   local filter = function(i)
      if i.tags then
         return table.set(i.tags)["neg"] or table.set(i.tags)["nogive"]
      end
   end
   local neg_nogive = data["base.item"]:iter():filter(filter)
   x, y = layout_items(neg_nogive, x, y, 2, 2, map)

   utils.normalize_items(map)

   local i = Item.create("elona.putitoro", x, y, {}, map)
   i.curse_state = Enum.CurseState.Cursed
   x = x + 1

   for _, item in Item.iter(map) do
      item.identify_state = Enum.IdentifyState.Full
   end

   Chara.create("elona.citizen", 4, 2, nil, map)

   return map
end

return give
