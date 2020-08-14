local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Calc = require("mod.elona.api.Calc")
local Quest = require("mod.elona_sys.api.Quest")
local Gui = require("api.Gui")
local Map = require("api.Map")


data:add {
   _type = "elona_sys.quest",
   _id = "noafindskitten",

   ordering = 200000,
   client_chara_type = 1,
   reward = "elona.wear",
   reward_fix = 135,

   min_fame = 0,
   chance = 1, -- 4,

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
      return "quest.noafindskitten.noafindskitten.dialog.complete"
   end
}


---
--- Dialog
---

data:add {
   _type = "elona_sys.dialog",
   _id = "quest",

   root = "quest.noafindskitten.noafindskitten.dialog",
   nodes = {
      accept = function(t)
         error("TODO")
         -- local map = Map.generate2("noafindskitten.quest_noafindskitten")

         -- TODO remove
         map._outer_map = t.speaker:current_map().uid

         local quest = Quest.for_client(t.speaker)
         assert(quest)
         map._quest = quest
         Map.travel_to(map)
      end
   }
}
