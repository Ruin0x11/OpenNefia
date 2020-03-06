local Event = require("api.Event")
local Chara = require("api.Chara")
local Skill = require("mod.elona_sys.api.Skill")
local Item = require("api.Item")

local function level_up()
   local player = Chara.player()

   local levels = 100
   for _= 1, levels do
      Skill.gain_level(player)
      Skill.grow_primary_skills(player)
   end

   player:gain_skill("elona.mining", 10000)

   player.gold = 10000000
   player.platinum = 10000

   player:heal_to_max()
end

Event.register("base.on_new_game", "Make player stronger", level_up)
