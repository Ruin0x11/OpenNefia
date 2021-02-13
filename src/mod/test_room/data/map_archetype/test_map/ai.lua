local utils = require("mod.test_room.data.map_archetype.utils")
local Chara = require("api.Chara")

local ai = {
   _id = "ai"
}

function ai.on_map_pass_turn(map)
   for _, chara in Chara.player():iter_other_party_members() do
      if not Chara.is_alive(chara) then
         chara:revive()
         chara:set_pos(5, 10)
      end
   end

   if Chara.iter_others(map):filter(Chara.is_alive):length() == 0 then
      Chara.create("elona.putit", 15, 10, {}, map)
   end
end

function ai.on_generate_map(area, floor)
   local map = utils.create_map(20, 20)
   utils.create_stairs(10, 9, area, map)

   local player = Chara.player()

   if player:iter_other_party_members():length() == 0 then
      local ally = Chara.create("elona.putit", 5, 10, {}, map)
      player:recruit_as_ally(ally)
   end

   player.is_not_targeted_by_ai = true
   player.fov = 50

   return map
end

return ai