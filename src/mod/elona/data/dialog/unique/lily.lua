local Item = require("api.Item")
local Gui = require("api.Gui")
local Chara = require("api.Chara")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local common = require("mod.elona.data.dialog.common")
local Effect = require("mod.elona.api.Effect")
local Area = require("api.Area")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local DeferredEvents = require("mod.elona.api.DeferredEvents")
local Event = require("api.Event")

local function give_potion()
   local player = Chara.player()
   local potion = player:find_item("elona.potion_of_cure_corruption")
   potion.amount = potion.amount - 1
   Gui.mes("talk.unique.lily.progress.end_life.give.you_hand_her")
   Gui.play_sound("base.equip1")
   Effect.modify_karma(player, 20)
end

data:add {
   _type = "elona_sys.dialog",
   _id = "lily",

   nodes = {
      __start = function(t)
         local flag = Sidequest.progress("elona.pael_and_her_mom")
         if flag == 1002 then
            return "after_sold"
         elseif flag == 10 then
            return "last"
         elseif flag == 1000 then
            local map = t.speaker:current_map()
            local area = map and Area.for_map(map)
            if map._archetype == "elona.noyel" and area.metadata.is_noyel_christmas_festival then
               return "festival"
            end
            return "end_life"
         elseif flag > 7 then
            return "very_late"
         elseif flag > 5 then
            return "late"
         elseif flag > 3 then
            return "mid"
         end

         return "early"
      end,

      after_sold = {
         text = "talk.unique.lily.after_sold"
      },

      last = {
         text = {
            {"talk.unique.lily.progress.last._0", args = common.args_name},
            "talk.unique.lily.progress.last._1",
            function()
               local player = Chara.player()
               local map = player:current_map()

               Item.create("elona.happy_apple", player.x, player.y, {}, map)
               Item.create("elona.gold_piece", player.x, player.y, {amount=20000}, map)
               Item.create("elona.platinum_coin", player.x, player.y, {amount=4}, map)

               Gui.play_sound("base.complete1")
               common.quest_completed()
            end,
            "talk.unique.lily.progress.last._2",
         },
         on_finish = function(t)
            Sidequest.set_progress("elona.pael_and_her_mom", 1000)
            t.speaker.is_talk_silenced = true
         end
      },

      festival = {
         text = "talk.unique.lily.progress.festival.dialog",
         choices = function()
            local choices = {}
            local potion = Chara.player():find_item("elona.potion_of_cure_corruption")
            if Item.is_alive(potion) then
               table.insert(choices, {"festival_give", "talk.unique.lily.progress.festival.choices.give"})
            end
            table.insert(choices, {"festival_take_care", "talk.unique.lily.progress.festival.choices.take_care"})

            return choices
         end,
         default_choice = "festival_take_care"
      },
      festival_give = {
         on_start = give_potion,
         text = "talk.unique.lily.progress.festival.give.dialog",
      },
      festival_take_care = {
         text = "talk.unique.lily.progress.festival.take_care",
      },

      end_life = {
         text = {
            {"talk.unique.lily.progress.end_life.dialog._0", args = common.args_name},
            "talk.unique.lily.progress.end_life.dialog._1",
         },
         choices = function()
            local choices = {}
            local potion = Chara.player():find_item("elona.potion_of_cure_corruption")
            if potion ~= nil then
               table.insert(choices, {"end_life_give", "talk.unique.lily.progress.end_life.choices.give"})
            end
            table.insert(choices, {"end_life_end", "talk.unique.lily.progress.end_life.choices.end"})
            table.insert(choices, {"end_life_leave", "talk.unique.lily.progress.end_life.choices.leave"})

            return choices
         end,
         default_choice = "end_life_leave"
      },
      end_life_give = {
         on_start = give_potion,
         text = "talk.unique.lily.progress.end_life.give.dialog",

      },
      end_life_end = {
         text = "talk.unique.lily.progress.end_life.end",
         on_finish = function(t)
            DeferredEvent.add(function() DeferredEvents.lily_end_life(t.speaker) end)
         end
      },
      end_life_leave = {
         text = "talk.unique.lily.progress.end_life.leave",
      },

      very_late = {
         text = "talk.unique.lily.progress.very_late",
      },
      late = {
         text = {
            {"talk.unique.lily.progress.late", args = common.args_name},
         }
      },
      mid = {
         text = "talk.unique.lily.progress.mid",

      },
      early = {
         text = "talk.unique.lily.progress.early",
      },
   }
}
