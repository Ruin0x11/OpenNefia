local Chara = require("api.Chara")
local Item = require("api.Item")
local Gui = require("api.Gui")
local IItemBook = require("mod.elona.api.aspect.IItemBook")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local common = require("mod.elona.data.dialog.common")

data:add {
   _type = "elona_sys.dialog",
   _id = "marks",

   nodes = {
      __start = function()
         local flag = Sidequest.progress("elona.pyramid_trial")
         if flag ~= 0 then
            return "quest_completed"
         elseif Chara.player().fame < 3000 then
            return "quest_fame_too_low"
         elseif flag == 0 then
            return "quest_ask"
         end

         return "elona_sys.ignores_you:__start"
      end,
      quest_completed = {
         text = "talk.unique.marks.complete",
      },
      quest_fame_too_low = {
         text = "talk.unique.marks.fame_too_low",
      },
      quest_ask = {
         text = {
            {"talk.unique.marks.quest.dialog._0", args = common.args_title},
            "talk.unique.marks.quest.dialog._1",
         },
         choices = function()
            local choices = {}
            if Chara.player().gold >= 20000 then
               table.insert(choices, {"quest_yes", "talk.unique.marks.quest.choices.pay"})
            end
            table.insert(choices, {"quest_no", "ui.bye"})

            return choices
         end,
         default_choice = "quest_no"
      },
      quest_yes = {
         on_start = function()
            Sidequest.update_journal()
            Gui.mes("common.something_is_put_on_the_ground")

            local player = Chara.player()
            local map = player:current_map()
            player.gold = player.gold - 20000
            Gui.play_sound("base.paygold1")
            local aspects = {
               [IItemBook] = {
                  book_id = "elona.pyramid_invitation"
               }
            }
            Item.create("elona.book", player.x, player.y, {aspects=aspects}, map)
         end,
         text = "talk.unique.marks.quest.pay",
         on_finish = function()
            Sidequest.set_progress("elona.pyramid_trial", 1)
         end
      },
      quest_no = {
         text = "talk.unique.marks.quest.bye",
      },
   }
}
