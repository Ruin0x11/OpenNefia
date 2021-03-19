local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Calc = require("mod.elona.api.Calc")
local Quest = require("mod.elona_sys.api.Quest")
local Map = require("api.Map")
local SokobanMap = require("mod.sokoban.api.SokobanMap")


data:add {
   _type = "elona_sys.quest",
   _id = "sokoban",

   ordering = 200000,
   client_chara_type = 1,
   reward = "elona.wear",
   reward_fix = 135,

   min_fame = 0,
   chance = 4,

   params = {},

   difficulty = function()
      local difficulty = math.clamp(Rand.rnd(Chara.player():calc("level") + 10) +
                                        Rand.rnd(Chara.player():calc("fame") / 500 + 1) + 1,
                                     1, 90)
      return Calc.round_margin(difficulty, Chara.player():calc("level"))
   end,

   expiration_hours = function() return (Rand.rnd(6) + 2) * 24 end,
   deadline_days = nil,

   generate = function(self, client)
      return true
   end,

   on_accept = function(self)
      return true, "sokoban.quest:accept"
   end,
   on_complete = function()
      return "sokoban.quest:complete"
   end
}


---
--- Dialog
---

data:add {
   _type = "elona_sys.dialog",
   _id = "quest",

   nodes = {
      accept = function(t)
         local quest = Quest.for_client(t.speaker)
         assert(quest)

         local current_map = t.speaker:current_map()
         local quest_map = SokobanMap.generate(("sokoban.builtin_%d"):format(quest.difficulty))
         local player = Chara.player()
         quest_map:set_previous_map_and_location(current_map, player.x, player.y)

         Quest.set_immediate_quest(quest)

         Map.travel_to(quest_map)
      end,
      complete = {
         on_start = function(t)
            local quest = Quest.for_client(t.speaker)
            assert(quest)
            Quest.complete(quest, t.speaker)
         end,
         text = "quest.types.sokoban.sokoban.complete",
         jump_to = "elona.default:__start"
      }
   }
}
