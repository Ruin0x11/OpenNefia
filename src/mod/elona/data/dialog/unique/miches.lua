local Chara = require("api.Chara")
local Item = require("api.Item")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local Enum = require("api.Enum")

local common = require("mod.elona.data.dialog.common")

data:add {
   _type = "elona_sys.dialog",
   _id = "miches",

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
         text = "talk.unique.miches.complete"

      },
      quest_ask = {
         text = {
            "talk.unique.miches.quest.dialog._0",
            "talk.unique.miches.quest.dialog._1"
         },
         choices = {
            {"quest_yes", "talk.unique.miches.quest.choices.yes"},
            {"quest_no", "talk.unique.miches.quest.choices.no"}
         },
         default_choice = "quest_no"
      },
      quest_yes = {
         on_start = function()
            Sidequest.update_journal()
         end,
         text = "talk.unique.miches.quest.yes",
         on_finish = function()
            Sidequest.set_progress("elona.putit_attacks", 1)
         end
      },
      quest_no = {
         text = "talk.unique.miches.quest.no",
      },
      quest_waiting = {
         text = "talk.unique.miches.quest.waiting",
      },
      quest_finish = {
         on_start = function()
            local player = Chara.player()
            local map = player:current_map()

            Item.create("elona.small_shield", player.x, player.y, {level = 10, quality = Enum.Quality.Good}, map)
            Item.create("elona.girdle", player.x, player.y, {level = 10, quality = Enum.Quality.Good}, map)
            Item.create("elona.gold_piece", player.x, player.y, { amount = 3000 }, map)
            Item.create("elona.platinum_coin", player.x, player.y, { amount = 2 }, map)

            common.quest_completed()
         end,
         text = "talk.unique.miches.quest.end",
         on_finish = function()
            Sidequest.set_progress("elona.putit_attacks", 1000)
         end
      },
   }
}
