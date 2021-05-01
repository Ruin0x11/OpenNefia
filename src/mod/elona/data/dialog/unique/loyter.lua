local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local Chara = require("api.Chara")
local common = require("mod.elona.data.dialog.common")
local Item = require("api.Item")
local ItemMaterial = require("mod.elona.api.ItemMaterial")

data:add {
   _type = "elona_sys.dialog",
   _id = "loyter",

   nodes = {
      __start = function()
         local flag = Sidequest.progress("elona.nightmare")
         if Chara.player().fame < 20000 then
            return "quest_fame_too_low"
         end
         if flag == 1000 then
            return "quest_completed"
         end
         if flag == 0 then
            return "quest_ask"
         end
         if flag == 1 or flag == 2 then
            return "quest_begin"
         end
         if flag == 3 then
            return "quest_finish"
         end
         return "__END__"
      end,
      quest_fame_too_low = {
         text = "talk.unique.loyter.fame_too_low"

      },
      quest_completed = {
         text = "talk.unique.loyter.complete"
      },
      quest_ask = {
         text = {
            {"talk.unique.loyter.quest.dialog._0", args = common.args_title},
            "talk.unique.loyter.quest.dialog._1",
         },
         choices = {
            {"quest_yes", "talk.unique.loyter.quest.choices.yes"},
            {"quest_no", "talk.unique.loyter.quest.choices.no"}
         },
         default_choice = "quest_no"
      },
      quest_yes = {
         on_start = function()
            Sidequest.update_journal()
         end,
         text = "talk.unique.loyter.quest.yes",
         on_finish = function()
            Sidequest.set_progress("elona.nightmare", 1)
         end
      },
      quest_no = {
         text = "talk.unique.loyter.quest.no",
      },
      quest_begin = {
         text = "talk.unique.loyter.quest.begin.dialog",
         choices = {
            {"quest_begin_yes", "talk.unique.loyter.quest.begin.choices.yes"},
            {"quest_begin_no", "talk.unique.loyter.quest.begin.choices.no"}
         },
         default_choice = "quest_begin_no"
      },
      quest_begin_yes = {
         on_begin = function()
            Sidequest.update_journal()
         end,
         text = "talk.unique.loyter.quest.begin.yes",
         on_finish = function(t)
            Sidequest.set_progress("elona.nightmare", 2)
            local map = t.speaker:current_map()
            common.go_to_quest_map(map, 5)
         end
      },
      quest_begin_no = {
         text = "talk.unique.loyter.quest.begin.no",
      },
      quest_finish = {
         on_start = function()
            local player = Chara.player()
            local map = player:current_map()
            local material_kit = Item.create("elona.material_kit", player.x, player.y, {no_stack = true}, map)
            ItemMaterial.change_item_material(material_kit, "elona.rubynus")
            Item.create("elona.gold_piece", player.x, player.y, {amount=100000}, map)
            Item.create("elona.platinum_coin", player.x, player.y, {amount=5}, map)

            common.quest_completed()
         end,
         text = "talk.unique.loyter.quest.end",
         on_finish = function()
            Sidequest.set_progress("elona.nightmare", 1000)
         end
      }
   }
}
