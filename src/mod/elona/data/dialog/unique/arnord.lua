local Chara = require("api.Chara")
local Item = require("api.Item")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local common = require("mod.elona.data.dialog.common")
local Area = require("api.Area")
local Map = require("api.Map")

data:add {
   _type = "elona_sys.dialog",
   _id = "arnord",

   nodes = {
      __start = function()
         local flag = Sidequest.progress("elona.kamikaze_attack")
         if flag == 1000 then
            return "quest_completed"
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
         text = {
            {"talk.unique.arnord.complete", args = common.args_name},
         },
      },
      quest_ask = {
         text = "talk.unique.arnord.quest.dialog",
         choices = {
            {"quest_yes", "talk.unique.arnord.quest.choices.yes"},
            {"quest_no", "talk.unique.arnord.quest.choices.no"}
         },
         default_choice = "quest_no"
      },
      quest_yes = {
         on_start = function()
            Sidequest.update_journal()
         end,
         text = "talk.unique.arnord.quest.yes",
         on_finish = function()
            Sidequest.set_progress("elona.kamikaze_attack", 1)
         end
      },
      quest_no = {
         text = "talk.unique.arnord.quest.no",
      },
      quest_begin = {
         text = "talk.unique.arnord.quest.begin.dialog",
         choices = {
            {"quest_begin_yes", "talk.unique.arnord.quest.begin.choices.yes"},
            {"quest_begin_no", "talk.unique.arnord.quest.begin.choices.no"}
         },
         default_choice = "quest_begin_no"
      },
      quest_begin_yes = {
         on_start = function()
            Sidequest.update_journal()
         end,
         text = "talk.unique.arnord.quest.begin.yes",
         on_finish = function(t)
            Sidequest.set_progress("elona.kamikaze_attack", 2)

            local player = Chara.player()
            local current_map = t.speaker:current_map()
            local area = assert(Area.for_map(current_map))
            local ok, quest_map = assert(area:load_or_generate_floor(25))
            quest_map:set_previous_map_and_location(current_map, player.x, player.y)
            Map.travel_to(quest_map)
            -- Internal.go_to_quest_map("core.port_kapul", 25)
         end
      },
      quest_begin_no = {
         text = "talk.unique.arnord.quest.begin.no",
      },
      quest_finish = {
         on_start = function()
            local player = Chara.player()
            local map = player:current_map()

            Item.create("elona.magic_fruit", player.x, player.y, {}, map)
            Item.create("elona.gold_piece", player.x, player.y, {amount=7500}, map)
            Item.create("elona.platinum_coin", player.x, player.y, {amount=3}, map)

            common.quest_completed()
         end,
         text = "talk.unique.arnord.quest.end",
         on_finish = function()
            Sidequest.set_progress("elona.kamikaze_attack", 1000)
         end
      }
   }
}
