local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local Chara = require("api.Chara")
local common = require("mod.elona.data.dialog.common")
local Item = require("api.Item")

data:add {
   _type = "elona_sys.dialog",
   _id = "gilbert",

   nodes = {
      __start = function()
         local flag = Sidequest.progress("elona.defense_line")
         if flag == 1000 then
            return "quest_completed"
         elseif Chara.player():calc("fame") < 5000 then
            return "quest_fame_too_low"
         elseif flag == 0 then
            return "quest_ask"
         elseif flag == 1 or flag == 2 then
            return "quest_begin"
         elseif flag == 3 then
            return "quest_finish"
         end

         return "elona_sys.ignores_you:__start"
      end,
      quest_completed = {
         text = "talk.unique.gilbert.complete",
      },
      quest_fame_too_low = {
         text = "talk.unique.gilbert.fame_too_low",
      },
      quest_ask = {
         text = {
            {"talk.unique.gilbert.quest.dialog._0", args = common.args_title},
            "talk.unique.gilbert.quest.dialog._1",
         },
         choices = {
            {"quest_yes", "talk.unique.gilbert.quest.choices.yes"},
            {"quest_no", "talk.unique.gilbert.quest.choices.no"}
         },
         default_choice = "quest_no"
      },
      quest_yes = {
         on_start = function()
            Sidequest.update_journal()
         end,
         text = "talk.unique.gilbert.quest.yes",
         on_finish = function()
            Sidequest.set_progress("elona.defense_line", 1)
         end
      },
      quest_no = {
         text = "talk.unique.gilbert.quest.no",
      },
      quest_begin = {
         text = "talk.unique.gilbert.quest.begin.dialog",
         choices = {
            {"quest_begin_yes", "talk.unique.gilbert.quest.begin.choices.yes"},
            {"quest_begin_no", "talk.unique.gilbert.quest.begin.choices.no"}
         },
         default_choice = "quest_begin_no"
      },
      quest_begin_yes = {
         text = "talk.unique.gilbert.quest.begin.yes",
         on_finish = function(t)
            Sidequest.set_progress("elona.defense_line", 2)
            common.go_to_quest_map(t.speaker:current_map(), 4)
         end
      },
      quest_begin_no = {
         text = "talk.unique.gilbert.quest.begin.no",
      },
      quest_finish = {
         on_start = function()
            local player = Chara.player()
            local map = player:current_map()
            Item.create("elona.hero_cheese", player.x, player.y, {}, map)
            Item.create("elona.gold_piece", player.x, player.y, {amount=10000}, map)
            Item.create("elona.platinum_coin", player.x, player.y, {amount=3}, map)

            common.quest_completed()
         end,
         text = "talk.unique.gilbert.quest.end",
         on_finish = function()
            Sidequest.set_progress("elona.defense_line", 1000)
         end
      }
   }
}
