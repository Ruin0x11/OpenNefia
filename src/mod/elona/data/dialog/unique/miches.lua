local Chara = require("api.Chara")
local Item = require("api.Item")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local Calc = require("mod.elona.api.Calc")

local common = require("mod.elona.data.dialog.common")

data:add {
   _type = "elona_sys.dialog",
   _id = "miches",

   root = "talk.unique.miches",
   nodes = {
      __start = function()
         local flag = Sidequest.progress("elona.putit_attacks")
         if flag == 1000 then
            return "quest_completed"
         elseif flag == 0 then
            return "quest_ask"
         elseif flag == 1 then
            return "quest_waiting"
         elseif flag == 2 then
            return "quest_finish"
         end
         return "__END__"
      end,
      quest_completed = {
         text = {
            {"complete"}
         }
      },
      quest_ask = {
         text = {
            {"quest.dialog._0"},
            {"quest.dialog._1"}
         },
         choices = {
            {"quest_yes", "quest.choices.yes"},
            {"quest_no", "quest.choices.no"}
         },
         default_choice = "quest_no"
      },
      quest_yes = {
         text = {
            common.show_journal_update_message,
            {"quest.yes"},
         },
         on_finish = function()
            Sidequest.set_progress("elona.putit_attacks", 1)
         end
      },
      quest_no = {
         text = {
            {"quest.no"},
         }
      },
      quest_waiting = {
         text = {
            {"quest.waiting"},
         }
      },
      quest_finish = {
         text = {
            function()
               local cx, cy = Chara.player().x, Chara.player().y
               Item.create("elona.small_shield", cx, cy, Calc.filter(10, "good"))
               Item.create("elona.girdle", cx, cy, Calc.filter(10, "good"))
               Item.create("elona.gold_piece", cx, cy, { amount = 3000 })
               Item.create("elona.platinum_coin", cx, cy, { amount = 2 })

               common.quest_completed()
            end,
            {"quest.end"},
         },
         on_finish = function()
            Sidequest.set_progress("elona.putit_attacks", 1000)
         end
      },
   }
}
