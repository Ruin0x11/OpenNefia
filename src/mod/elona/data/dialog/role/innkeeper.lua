local Calc = require("mod.elona.api.Calc")
local Chara = require("api.Chara")
local Gui = require("api.Gui")
local Const = require("api.Const")
local Hunger = require("mod.elona.api.Hunger")
local MapArchetype = require("api.MapArchetype")
local Map = require("api.Map")

data:add {
   _type = "elona_sys.dialog",
   _id = "innkeeper",

   nodes = {
      buy_meal = function(t)
         -- >>>>>>>> shade2/chat.hsp:2382 	if chatVal=13{ ...
         local cost = Calc.calc_innkeeper_meal_cost()
         local player = Chara.player()
         if player.gold < cost then
            Gui.mes("ui.inv.buy.not_enough_money")
            return "elona.default:talk"
         end

         if player.nutrition >= Const.INNKEEPER_MEAL_NUTRITION then
            return "elona.innkeeper:buy_meal_not_hungry"
         end

         Gui.play_sound("base.paygold1")
         player.gold = player.gold - cost
         Gui.play_sound("base.eat1")

         player.nutrition = Const.INNKEEPER_MEAL_NUTRITION
         Gui.mes("talk.npc.innkeeper.eat.results")
         Hunger.show_eating_message(player)
         Hunger.proc_anorexia(player)

         return "elona.innkeeper:buy_meal_finish"
         -- <<<<<<<< shade2/chat.hsp:2392 		} ..
      end,
      buy_meal_finish = {
         text = "talk.npc.innkeeper.eat.here_you_are",
         jump_to = "elona.default:__start"
      },
      buy_meal_not_hungry = {
         text = "talk.npc.innkeeper.eat.not_hungry",
         jump_to = "elona.default:__start"
      },
      -- >>>>>>>> shade2/chat.hsp:2735 	if chatVal=43{	 ...
      shelter = {
         text ="talk.npc.innkeeper.go_to_shelter",
         on_finish = function(t)
            local shelter_map = MapArchetype.generate_map_and_area("elona.shelter")
            local current_map = t.speaker:current_map()
            local player = Chara.player()
            shelter_map:set_previous_map_and_location(current_map, player.x, player.y)

            Gui.play_sound("base.exitmap1")
            Map.travel_to(shelter_map)
         end
      }
      -- <<<<<<<< shade2/chat.hsp:2741 		} ..
   }
}
