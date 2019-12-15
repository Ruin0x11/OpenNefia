local Event = require("api.Event")
local Chara = require("api.Chara")
local Skill = require("mod.elona_sys.api.Skill")
local Item = require("api.Item")

local function level_up()
   local player = Chara.player()
   local map = player:current_map()

   for _= 1, 100 do
      Skill.gain_level(player)
      Skill.grow_primary_skills(player)
   end

   local bow = Item.create("content.bow", nil, nil, {}, player)
   assert(player:equip_item(bow))

   local arrow = Item.create("content.arrow", nil, nil, {}, player)
   assert(player:equip_item(arrow))

   player:gain_skill("elona.mining", 10000)

   player.gold = 10000000
   player.platinum = 10000

   player:heal_to_max()
end

Event.register("base.on_new_game", "Make player stronger", level_up)
