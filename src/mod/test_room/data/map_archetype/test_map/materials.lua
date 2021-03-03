local utils = require("mod.test_room.data.map_archetype.utils")
local Feat = require("api.Feat")

local materials = {
   _id = "materials"
}

function materials.on_generate_map(area, floor)
   local map = utils.create_map(20, 20)
   utils.create_stairs(2, 2, area, map)

   local x = 2
   local y = 4

   local spots = {
      "elona.material_spot",
      "elona.material_spot_remains",
      "elona.material_spot_spring",
      "elona.material_spot_mine",
      "elona.material_spot_bush",
   }

   for i, feat_id in ipairs(spots) do
      for j = 1, 10 do
         Feat.create(feat_id, x + i, y + j, {}, map)
      end
   end

   return map
end

return materials
