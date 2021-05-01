local Item = require("api.Item")
local Chara = require("api.Chara")
local Gui = require("api.Gui")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local common = require("mod.elona.data.dialog.common")

data:add {
   _type = "elona_sys.dialog",
   _id = "ainc",

   nodes = {
      __start = function()
         local flag = Sidequest.progress("elona.novice_knight")
         if flag == 1000 then
            return "quest_completed"
         elseif flag == 0 then
            return "quest_ask"
         elseif flag == 1 then
            return "quest_waiting"
         elseif flag == 2 then
            return "quest_finish"
         end

         return "elona_sys.ignores_you:__start"
      end,
      quest_completed = {
         text = {
            {"talk.unique.ainc.complete", args = common.args_name}
         }
      },
      quest_ask = {
         text = "talk.unique.ainc.quest.dialog",
         choices = {
            {"quest_yes", "talk.unique.ainc.quest.choices.do_it"},
            {"quest_no", "ui.bye"}
         },
         default_choice = "quest_no"
      },
      quest_yes = {
         on_start = function()
            Sidequest.update_journal()
         end,
         text = "talk.unique.ainc.quest.do_it",
         on_finish = function()
            Sidequest.set_progress("elona.novice_knight", 1)
         end
      },
      quest_no = {
         text = "talk.unique.ainc.quest.bye",
      },
      quest_waiting = {
         text = "talk.unique.ainc.quest.waiting",
      },
      quest_finish = {
         text = "talk.unique.ainc.quest.end",
         on_finish = function()
            local player = Chara.player()
            local map = player:current_map()

            Item.create("elona.dal_i_thalion", player.x, player.y, {}, map)
            Item.create("elona.gold_piece", player.x, player.y, {amount=5000}, map)
            Item.create("elona.platinum_coin", player.x, player.y, {amount=3}, map)

            Gui.mes("quest.completed")
            Gui.play_sound("base.complete1")
            Gui.mes("common.something_is_put_on_the_ground")
            Sidequest.update_journal()

            Sidequest.set_progress("elona.novice_knight", 1000)
         end
      },
   }
}
