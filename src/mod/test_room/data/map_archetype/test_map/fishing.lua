local Item = require("api.Item")
local utils = require("mod.test_room.data.map_archetype.utils")
local Pos = require("api.Pos")
local Skill = require("mod.elona_sys.api.Skill")
local Chara = require("api.Chara")
local IItemBait = require("mod.elona.api.aspect.IItemBait")

local fishing = {
   _id = "fishing"
}

function fishing.on_generate_map(area, floor)
   local map = utils.create_map(20, 20)
   utils.create_stairs(2, 2, area, map)

   Item.create("elona.fishing_pole", 4, 4, {}, map)

   for _, i, proto in data["elona.bait"]:iter():enumerate() do
      Item.create("elona.bait", 5 + i, 4, {amount=5,aspects={[IItemBait]={bait_type=proto._id}}}, map)
   end

   for _, x, y in Pos.iter_rect(6, 6, 7, 7) do
      map:set_tile(x, y, "elona.water")
   end
   for _, x, y in Pos.iter_rect(9, 6, 10, 7) do
      map:set_tile(x, y, "elona.anime_water_hot_spring")
   end
   for _, x, y in Pos.iter_rect(12, 6, 13, 7) do
      map:set_tile(x, y, "elona.anime_water_shallow")
   end

   Skill.gain_skill(Chara.player(), "elona.fishing", 1)

   return map
end

return fishing
