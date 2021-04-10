local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Calc = require("mod.elona.api.Calc")
local Quest = require("mod.elona_sys.api.Quest")
local QuestMap = require("mod.elona.api.QuestMap")
local Map = require("api.Map")
local ElonaQuest = require("mod.elona.api.ElonaQuest")
local Event = require("api.Event")
local I18N = require("api.I18N")
local Gui = require("api.Gui")

local conquer = {
   _id = "conquer",
   _type = "elona_sys.quest",

   elona_id = 1008,
   ordering = 30000,
   client_chara_type = 8,
   reward = "elona.wear",
   reward_fix = 175,

   min_fame = 50000,
   chance = 20,

   params = { enemy_id = "string" },

   reward_count = function() return Rand.rnd(Rand.rnd(4) + 1) + 3 end,

   difficulty = function()
      local difficulty = Rand.rnd(Chara.player():calc("level") + 10) + Rand.rnd(Chara.player():calc("fame") / 2500 + 1)
      difficulty = Calc.round_margin(difficulty, Chara.player():calc("level"))
      return difficulty
   end,

   expiration_hours = function() return (Rand.rnd(6) + 2) * 24 end,

   generate = function(self, client)
      local min_level = math.clamp(math.floor(self.difficulty / 4), 5, 30)
      local enemy_id = Calc.hunt_enemy_id(self.difficulty, min_level)

      self.params = {
         enemy_id = enemy_id,
         enemy_level = math.floor(self.difficulty * 10 / 8)
      }

      return true
   end,
   locale_data = function(self)
      local objective
      local is_unknown = false
      if is_unknown then
         objective = I18N.get("quest.types.elona.conquer.unknown_monster")
      else
         objective = I18N.localize("base.chara", self.params.enemy_id, "name")
      end
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

   on_time_expired = function(self)
      -- >>>>>>>> shade2/main.hsp:1635 	if gQuest=qConquer{ ..
      Gui.mes_c("quest.conquer.fail", "Purple")
      -- <<<<<<<< shade2/main.hsp:1637 		} ..

      ElonaQuest.travel_to_previous_map()
   end,

   prevents_pickpocket = true
}

function conquer.on_accept(self)
   return true, "elona.quest_conquer:accept"
end

data:add(conquer)

data:add {
   _type = "elona_sys.dialog",
   _id = "quest_conquer",

   nodes = {
      accept = function(t)
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
         local hunt_map = QuestMap.generate_conquer(archetype_id, quest)
         local player = Chara.player()
         hunt_map:set_previous_map_and_location(current_map, player.x, player.y)

         Quest.set_immediate_quest(quest)
         Quest.set_immediate_quest_time_limit(quest, 60 * 12)

         Map.travel_to(hunt_map)

         return "__END__"
      end
   }
}

local function check_conquer_quest_targets(map)
   local quest = Quest.get_immediate_quest()
   if quest and (quest._id == "elona.conquer") then
      ElonaQuest.update_target_count_conquer(quest, map)
   end
end
Event.register("elona_sys.on_quest_check", "Check conquer quest targets", check_conquer_quest_targets)

local function display_quest_message_conquer(map)
   local quest = Quest.get_immediate_quest()
   -- >>>>>>>> shade2/map.hsp:2165 		if gQuest=qConquer{ ...
   if quest and quest._id == "elona.conquer" then
      local objective = I18N.localize("base.chara", quest.params.enemy_id, "name")
      Gui.mes_c("map.quest.on_enter.conquer", "SkyBlue", objective, save.elona_sys.quest_time_limit)
   end
   -- <<<<<<<< shade2/map.hsp:2167 			} ..
end
Event.register("base.on_map_entered", "Display quest message (conquer)", display_quest_message_conquer)
