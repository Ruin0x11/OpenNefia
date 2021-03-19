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

         return "elona.ignores_you:__start"
      end,
      quest_completed = {
         text = "talk.unique.rillian.complete",
      },
      quest_ask = {
         text = "talk.unique.rillian.quest.dialog",
         choices = {
            {"quest_yes", "talk.unique.rillian.quest.choices.do_it"},
            {"quest_no", "ui.bye"}
         },
         default_choice = "quest_no"
      },
      quest_yes = {
         on_start = function()
            Sidequest.update_journal()
         end,
         text = "talk.unique.rillian.quest.do_it",
         on_finish = function()
            Sidequest.set_progress("elona.puppys_cave", 1)
         end
      },
      quest_no = {
         text = "talk.unique.rillian.quest.bye",
      },
      quest_check = function()
         if Chara.find("elona.poppy", "allies") == nil then
            return "quest_waiting"
         end

         return "quest_finish"
      end,
      quest_waiting = {
         text = "talk.unique.rillian.quest.waiting"
      },
      quest_finish = {
         text = "talk.unique.rillian.quest.end",
         on_finish = function()
            Item.create("elona.cooler_box", Chara.player().x, Chara.player().y)
            Item.create("elona.gold_piece", Chara.player().x, Chara.player().y, {amount=2500})
            Item.create("elona.platinum_coin", Chara.player().x, Chara.player().y, {amount=2})

            common.quest_completed()

            Sidequest.set_progress("elona.puppys_cave", 1000)

            Chara.find("elona.poppy", "allies"):vanquish()
            local poppy = Chara.create("elona.poppy", 31, 4)
            poppy:add_role("elona.special")
         end
      }
   }
}
