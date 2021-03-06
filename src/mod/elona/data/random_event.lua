local Map = require("api.Map")
local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Gui = require("api.Gui")
local Const = require("api.Const")
local Hunger = require("mod.elona.api.Hunger")

data:add_type {
   name = "random_event",
   fields = {}
}

data:add {
   _type = "elona.random_event",
   _id = "murderer",

   asset = "base.bg_re9",

   on_event_triggered = function()
      local map = Map.current()

      local choices = Chara.iter_others():to_list()

      for _ = 1, 20 do
         local victim = Rand.choice(choices)
         if Chara.is_alive(victim, map) then
            Gui.mes("random_event._.elona.murderer.scream")
            victim:damage_hp(math.max(victim:calc("max_hp"), 99999), "elona.unknown")
            break
         end
      end
   end
}

data:add {
   _type = "elona.random_event",
   _id = "strange_feast",

   asset = "base.bg_re10",
   choice_count = 2,

   choices = {
      [1] = function()
         local player = Chara.player()
         player.nutrition = Const.INNKEEPER_MEAL_NUTRITION
         Gui.mes("talk.npc.innkeeper.eat.results")
         Hunger.show_eating_message(player)
         Hunger.proc_anorexia(player)
      end
   }
}
