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

   for _, i, proto in data["elona.material_spot_feat_info"]:iter():enumerate() do
      for j = 1, 10 do
         Feat.create("elona.material_spot", x + i, y + j, {params={material_spot_info=proto._id}}, map)
      end
   end

   return map
end

return materials
