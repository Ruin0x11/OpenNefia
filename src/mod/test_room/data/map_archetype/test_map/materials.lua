local utils = require("mod.test_room.data.map_archetype.utils")
local Feat = require("api.Feat")
local Item = require("api.Item")
local Chara = require("api.Chara")
local Skill = require("mod.elona_sys.api.Skill")

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

   x = 4
   y = 2
   local crafting_tools = {
      "elona.alchemy_kit",
      "elona.gem_cutter",
      "elona.sewing_kit",
      "elona.carpenters_tool",
   }

   for i, _id in ipairs(crafting_tools) do
      Item.create(_id, x + i - 1, y, {}, map)
   end

   local player = Chara.player()
   Skill.gain_skill(player, "elona.alchemy", 1, nil, 400)
   Skill.gain_skill(player, "elona.jeweler", 1, nil, 400)
   Skill.gain_skill(player, "elona.tailoring", 1, nil, 400)
   Skill.gain_skill(player, "elona.carpentry", 1, nil, 400)

   Skill.gain_skill(player, "elona.fishing", 1, nil, 400)
   Skill.gain_skill(player, "elona.mining", 1, nil, 400)
   Skill.gain_skill(player, "elona.gardening", 1, nil, 400)

   return map
end

return materials
