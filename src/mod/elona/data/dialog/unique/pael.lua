local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local common = require("mod.elona.data.dialog.common")
local Area = require("api.Area")
local Chara = require("api.Chara")
local Gui = require("api.Gui")

local function prompt_give_potion(prompt)
   return {
      text = {
         prompt
      },
      choices = {
         {"give_check", "talk.unique.pael.give.choice"},
         {"__END__", "ui.bye"}
      }
   }
end

data:add {
   _type = "elona_sys.dialog",
   _id = "pael",

   nodes = {
      __start = function(t)
         local flag = Sidequest.progress("elona.pael_and_her_mom")
         if flag == 1000 then
            local map = t.speaker:current_map()
            local area = map and Area.for_map(map)
            if map._archetype == "elona.noyel" and area.metadata.is_noyel_christmas_festival then
               return "festival"
            end
            return "after_face"
         elseif flag == 1001 then
            return "after_death"
         elseif flag == 1002 then
            return "after_sold"
         elseif flag == 0 then
            return "before"
         elseif flag == 1 or flag == 3 then
            return "progress_0"
         elseif flag == 5 or flag == 7 then
            return "progress_1"
         elseif flag == 2 or flag == 4 then
            return "progress_2"
         elseif flag == 6 then
            return "progress_3"
         elseif flag == 8 then
            return "progress_4"
         elseif flag == 9 then
            return "progress_5"
         elseif flag == 10 then
            return "progress_6"
         end

         return "elona_sys.ignores_you:__start"
      end,
      give_check = function()
         local potion = Chara.player():find_item("elona.potion_of_cure_corruption")
         if potion == nil then
            return "do_not_have_potion"
         end

         return "give_potion"
      end,
      do_not_have_potion = {
         text = "talk.unique.pael.give.do_not_have",
         choices = {
            {"__END__", "ui.more"}
         }
      },
      give_potion = {
         on_start = function()
            local potion = Chara.player():find_item("elona.potion_of_cure_corruption")
            potion.amount = potion.amount - 1
            Gui.mes("talk.unique.pael.give.you_give")
            Gui.play_sound("base.equip1")
         end,
         text = "talk.unique.pael.give.dialog",
         choices = {
            {"__END__", "ui.more"}
         },
         on_finish = function()
            Sidequest.update_journal()
            local flag = Sidequest.progress("elona.pael_and_her_mom")
            Sidequest.set_progress("elona.pael_and_her_mom", flag + 1)
         end
      },
      after_face = {
         text = "talk.unique.pael.after_face",

      },
      after_sold = {
         text = "talk.unique.pael.after_sold",

      },
      after_death = {
         text = "talk.unique.pael.after_death",

      },
      festival = {
         text = "talk.unique.pael.festival"

      },
      before = prompt_give_potion({"talk.unique.pael.before"}),
      progress_0 = {
         text = "talk.unique.pael.progress._0",

      },
      progress_1 = {
         text = {
            {"talk.unique.pael.progress._1", args = common.args_name},
         }
      },
      progress_2 = prompt_give_potion({"talk.unique.pael.progress._2", args = common.args_name}),
      progress_3 = prompt_give_potion({"talk.unique.pael.progress._3"}),
      progress_4 = prompt_give_potion({"talk.unique.pael.progress._4", args = common.args_name}),
      progress_5 = {
         text = "talk.unique.pael.progress._5",
      },
      progress_6 = {
         text = {
            {"talk.unique.pael.progress._6", args = common.args_name}
         }
      },
   }
}
