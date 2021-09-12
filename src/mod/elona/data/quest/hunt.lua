local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Calc = require("mod.elona.api.Calc")
local Quest = require("mod.elona_sys.api.Quest")
local QuestMap = require("mod.elona.api.QuestMap")
local Map = require("api.Map")
local ElonaQuest = require("mod.elona.api.ElonaQuest")
local Event = require("api.Event")

local hunt = {
   _id = "hunt",
   _type = "elona_sys.quest",
   _ordering = 70000,

   elona_id = 1001,
   client_chara_type = 1,
   reward = "elona.wear",
   reward_fix = 135,

   min_fame = 0,
   chance = 8,

   params = {},

   difficulty = function()
      local difficulty = math.clamp(Rand.rnd(Chara.player():calc("level") + 10) +
                                        Rand.rnd(Chara.player():calc("fame") / 500 + 1) + 1,
                                     1, 80)
      return Calc.round_margin(difficulty, Chara.player():calc("level"))
   end,

   expiration_hours = function() return (Rand.rnd(6) + 2) * 24 end,
   deadline_days = nil,

   generate = function(self, client)
      return true
   end
}

function hunt.on_accept(self)
   return true, "elona.quest_hunt:accept"
end

data:add(hunt)

data:add {
   _type = "elona_sys.dialog",
   _id = "quest_hunt",

   nodes = {
      accept = {
         text = "talk.npc.quest_giver.accept.hunt",
         on_finish = function(t)
            local quest = Quest.for_client(t.speaker)
            assert(quest)

            local hunt_map = QuestMap.generate_hunt(quest.difficulty)
            local current_map = t.speaker:current_map()
            local player = Chara.player()
            hunt_map:set_previous_map_and_location(current_map, player.x, player.y)

            Quest.set_immediate_quest(quest)

            Map.travel_to(hunt_map)
         end
      },
   }
}

local function check_hunt_quest_targets(map)
   local quest = Quest.get_immediate_quest()
   if quest and (quest._id == "elona.hunt" or quest._id == "elona.huntex") then
      ElonaQuest.update_target_count_hunt(quest, map)
   end
end
Event.register("elona_sys.on_quest_check", "Check hunt quest targets", check_hunt_quest_targets)
