local utils = require("mod.test_room.data.map_archetype.utils")
local Chara = require("api.Chara")
local Item = require("api.Item")
local Skill = require("mod.elona_sys.api.Skill")

local open = {
   _id = "open"
}

function open.on_generate_map(area, floor)
   local map = utils.create_map(20, 20)
   utils.create_stairs(2, 2, area, map)

   local x = 2
   local y = 4

   Item.create("elona.lockpick", x, y, {amount=99}, map)
   Item.create("elona.skeleton_key", x+1, y, {}, map)

   for _, _id in data["base.item"]:iter():filter(function(i) return i.on_open end) do
      for _ = 1, 5 do
         Item.create(_id, nil, nil, {}, map)
      end
   end

   Skill.gain_skill(Chara.player(), "elona.lock_picking")

   return map
end

return open
