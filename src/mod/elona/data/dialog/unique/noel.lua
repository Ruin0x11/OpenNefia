local Chara = require("api.Chara")
local Gui = require("api.Gui")
local Item = require("api.Item")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local common = require("mod.elona.data.dialog.common")

data:add {
   _type = "elona_sys.dialog",
   _id = "noel",

   nodes = {
      __start = function()
         local flag = Sidequest.progress("elona.red_blossom_in_palmia")
         if flag == 1000 then
            return "quest_completed"
         elseif flag == 1 then
            return "quest_waiting"
         elseif flag == 2 then
            return "quest_finish"
         elseif flag == 0 then
            return "quest_ask"
         end

         return "elona_sys.ignores_you:__start"
      end,
      quest_completed = {
         text = "talk.unique.noel.complete",
         choices = {
            {"buy_nuke", "ui.more"}
         }
      },
      quest_waiting = {
         text = "talk.unique.noel.quest.waiting",
         choices = {
            {"buy_nuke", "ui.more"}
         }
      },
      quest_finish = {
         on_start = function()
            -- TODO secret treasure
            local player = Chara.player()
            local map = player:current_map()
            local secret_treasure = Item.create("elona.secret_treasure", player.x, player.y, {no_stack = true}, map)
            secret_treasure.params.secret_treasure_trait = "elona.perm_evil"
            Item.create("elona.platinum_coin", player.x, player.y, {amount=6}, map)

            common.quest_completed()

            Sidequest.set_progress("elona.red_blossom_in_palmia", 1000)
         end,
         text = "talk.unique.noel.quest.end",
         choices = {
            {"buy_nuke", "ui.more"}
         }
      },
      quest_ask = {
         text = {
            "talk.unique.noel.quest.dialog._0",
            "talk.unique.noel.quest.dialog._1",
         },
         choices = {
            {"quest_yes", "talk.unique.noel.quest.choices.of_course"},
            {"quest_no", "ui.bye"},
         },
         default_choice = "quest_no"
      },
      quest_yes = {
         on_start = function()
            Sidequest.update_journal()
            Sidequest.set_progress("elona.red_blossom_in_palmia", 1)
         end,
         text = "talk.unique.noel.quest.of_course",
         choices = {
            {"buy_nuke", "ui.more"},
         }
      },
      quest_no = {
         text = "talk.unique.noel.quest.bye",
      },
      buy_nuke = {
         text = "talk.unique.noel.quest.buy_nuke.dialog",
         choices = function()
            local choices = {}
            if Chara.player().gold >= 12000 then
               table.insert(choices, {"buy_nuke_yes", "talk.unique.noel.quest.buy_nuke.choices.buy"})
            end
            table.insert(choices, {"buy_nuke_no", "ui.bye"})

            return choices
         end,
         default_choice = "buy_nuke_no"
      },
      buy_nuke_yes = {
         on_start = function()
            local player = Chara.player()
            local map = player:current_map()
            Gui.mes("common.something_is_put_on_the_ground")
            player.gold = player.gold - 12000
            Gui.play_sound("base.paygold1")
            Item.create("elona.nuclear_bomb", player.x, player.y, {}, map)
         end,
         text = "talk.unique.noel.quest.buy_nuke.buy",
      },
      buy_nuke_no = {
         text = "talk.unique.noel.quest.buy_nuke.bye",
      },
   }
}
