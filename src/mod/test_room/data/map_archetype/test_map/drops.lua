local utils = require("mod.test_room.data.map_archetype.utils")
local Chara = require("api.Chara")
local Enum = require("api.Enum")

local drops = {
   _id = "drops"
}

function drops.on_generate_map(area, floor)
   local map = utils.create_map(20, 20)
   utils.create_stairs(2, 2, area, map)

   local filter = function(c)
      return c.on_drop_loot
         or c.always_drop_gold
         or c.rich_loot_amount
   end

   for _, proto in data["base.chara"]:iter():filter(filter) do
      local chara = Chara.create(proto._id, nil, nil, nil, map)
      if chara then
         chara.relation = Enum.Relation.Dislike
      end
   end

   return map
end

return drops
