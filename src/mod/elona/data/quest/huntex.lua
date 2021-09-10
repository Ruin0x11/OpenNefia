local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Calc = require("mod.elona.api.Calc")
local Quest = require("mod.elona_sys.api.Quest")
local QuestMap = require("mod.elona.api.QuestMap")
local Map = require("api.Map")
local I18N = require("api.I18N")
local MapEntrance = require("mod.elona_sys.api.MapEntrance")

local quest_huntex = {
   _type = "base.map_archetype",
   _id = "quest_huntex",

   starting_pos = MapEntrance.random,

   properties = {
      types = { "quest" },
      tileset = "elona.tower_1",
      level = 1,
      is_indoor = false,
      is_temporary = true,
      max_crowd_density = 0,
      default_ai_calm = "base.calm_null",
      shows_floor_count_in_name = true,
      prevents_building_shelter = true
   }
}
data:add(quest_huntex)

local huntex = {
   _id = "huntex",
   _type = "elona_sys.quest",
   _ordering = 20000,

   elona_id = 1010,
   client_chara_type = 1,
   reward = "elona.supply",
   reward_fix = 140,

   min_fame = 30000,
   chance = 13,

   params = { enemy_id = types.data_id("base.chara") },

   reward_count = function() return Rand.rnd(Rand.rnd(4) + 1) + 3 end,

   difficulty = function()
      local difficulty = Rand.rnd(Chara.player():calc("level") + 10) + Rand.rnd(Chara.player():calc("fame") / 2500 + 1)
      difficulty = Calc.round_margin(difficulty, Chara.player():calc("level"))
      return difficulty
   end,

   expiration_hours = function() return (Rand.rnd(6) + 2) * 24 end,

   generate = function(self, client)
      local min_level = math.clamp(math.floor(self.difficulty / 7), 5, 30)
      local enemy_id = Calc.hunt_enemy_id(self.difficulty, min_level)

      self.params = {
         enemy_id = enemy_id,
         enemy_level = math.floor(self.difficulty * 3 / 2)
      }

      return true
   end,
   locale_data = function(self)
      local objective = I18N.localize("base.chara", self.params.enemy_id, "name")
      return { objective = objective, enemy_level = self.params.enemy_level }
   end,

   calc_reward_platinum = function(self)
      -- >>>>>>>> shade2/quest.hsp:459 	if (qExist(rq)=qConquer)or(qExist(rq)=qHuntEx){ ..
      local plat = 2
      if Rand.rnd(100) < Rand.rnd(Chara.player():calc("fame") / 5000 + 1) then
         plat = plat + 1
      end
      return plat
      -- <<<<<<<< shade2/quest.hsp:461 		} ..
   end,

   calc_reward_item_count = function(self, count)
      -- >>>>>>>> shade2/quest.hsp:466 		if (qExist(rq)=qConquer)or(qExist(rq)=qHuntEx):p ..
      return count + 2
      -- <<<<<<<< shade2/quest.hsp:466 		if (qExist(rq)=qConquer)or(qExist(rq)=qHuntEx):p ..
   end,

   prevents_pickpocket = true
}

function huntex.on_accept(self)
   return true, "elona.quest_huntex:accept"
end

data:add(huntex)

data:add {
   _type = "elona_sys.dialog",
   _id = "quest_huntex",

   nodes = {
      accept = {
         text = "talk.npc.quest_giver.accept.hunt",
         on_finish = function(t)
            local quest = Quest.for_client(t.speaker)
            assert(quest)

            local current_map = t.speaker:current_map()
            local archetype = current_map:archetype()
            local archetype_id
            if archetype == nil or archetype.on_generate_map == nil then
               archetype_id = "elona.vernis"
            else
               archetype_id = archetype._id
            end
            local hunt_map = QuestMap.generate_huntex(archetype_id, quest.params.enemy_id, quest.params.enemy_level, quest.difficulty)
            local player = Chara.player()
            hunt_map:set_previous_map_and_location(current_map, player.x, player.y)

            Quest.set_immediate_quest(quest)

            Map.travel_to(hunt_map)
         end
      },
   }
}
