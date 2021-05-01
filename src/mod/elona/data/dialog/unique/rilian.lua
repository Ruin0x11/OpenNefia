local Chara = require("api.Chara")
local Item = require("api.Item")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")

local common = require("mod.elona.data.dialog.common")

data:add {
   _type = "elona_sys.dialog",
   _id = "rilian",

   nodes = {
      __start = function()
         local flag = Sidequest.progress("elona.puppys_cave")
         if flag == 1000 then
            return "quest_completed"
         elseif flag == 0 then
            return "quest_ask"
         elseif flag == 1 then
            return "quest_check"
         end

         return "elona_sys.ignores_you:__start"
      end,
      quest_completed = {
         text = "talk.unique.rilian.complete",
      },
      quest_ask = {
         text = "talk.unique.rilian.quest.dialog",
         choices = {
            {"quest_yes", "talk.unique.rilian.quest.choices.do_it"},
            {"quest_no", "ui.bye"}
         },
         default_choice = "quest_no"
      },
      quest_yes = {
         on_start = function()
            Sidequest.update_journal()
         end,
         text = "talk.unique.rilian.quest.do_it",
         on_finish = function()
            Sidequest.set_progress("elona.puppys_cave", 1)
         end
      },
      quest_no = {
         text = "talk.unique.rilian.quest.bye",
      },
      quest_check = function()
         local map = Chara.player():current_map()
         if Chara.find("elona.poppy", "allies", map) == nil then
            return "quest_waiting"
         end

         return "quest_finish"
      end,
      quest_waiting = {
         text = "talk.unique.rilian.quest.waiting"
      },
      quest_finish = {
         text = "talk.unique.rilian.quest.end",
         on_finish = function()
            local player = Chara.player()
            local map = player:current_map()
            Item.create("elona.cooler_box", player.x, player.y, {}, map)
            Item.create("elona.gold_piece", player.x, player.y, {amount=2500}, map)
            Item.create("elona.platinum_coin", player.x, player.y, {amount=2}, map)

            common.quest_completed()

            Sidequest.set_progress("elona.puppys_cave", 1000)

            Chara.find("elona.poppy", "allies", map):vanquish()
            local poppy = Chara.create("elona.poppy", 31, 4)
            poppy:add_role("elona.special")
         end
      }
   }
}
