local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Calc = require("mod.elona.api.Calc")
local Quest = require("mod.elona_sys.api.Quest")
local Gui = require("api.Gui")
local Map = require("api.Map")
local MapArchetype = require("api.MapArchetype")


data:add {
   _type = "elona_sys.quest",
   _id = "noafindskitten",

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
                                     1, 80)
      return Calc.round_margin(difficulty, Chara.player():calc("level"))
   end,

   expiration_hours = function() return (Rand.rnd(6) + 2) * 24 end,
   deadline_days = nil,

   generate = function(self, client)
      return true
   end,

   on_accept = function(self)
      return true, "noafindskitten.quest:accept"
   end,
   on_complete = function()
      return "noafindskitten.quest:complete"
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
         local quest_map = MapArchetype.generate_map_and_area("noafindskitten.quest_noafindskitten")
         local player = Chara.player()
         quest_map:set_previous_map_and_location(current_map, player.x, player.y)

         Quest.set_immediate_quest(quest)

         Map.travel_to(quest_map)
      end,
      complete = {
         text = "quest.types.noafindskitten.noafindskitten.complete",
         on_start = function(t)
            local quest = Quest.for_client(t.speaker)
            assert(quest)
            Quest.complete(quest, t.speaker)
         end,
         jump_to = "elona.default:__start"
      }
   }
}
