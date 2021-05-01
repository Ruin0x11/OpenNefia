local Chara = require("api.Chara")
local Item = require("api.Item")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local common = require("mod.elona.data.dialog.common")
local ItemMaterial = require("mod.elona.api.ItemMaterial")

data:add {
   _type = "elona_sys.dialog",
   _id = "tam",

   nodes = {
      __start = function()
         local flag = Sidequest.progress("elona.cat_house")
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
         text = "talk.unique.tam.complete",
      },
      quest_ask = {
         text = "talk.unique.tam.quest.dialog",
         choices = {
            {"quest_yes", "talk.unique.tam.quest.choices.yes"},
            {"quest_no", "talk.unique.tam.quest.choices.no"}
         },
         default_choice = "quest_no"
      },
      quest_yes = {
         on_start = function()
            Sidequest.update_journal()
         end,
         text = "talk.unique.tam.quest.yes",
         on_finish = function(t)
            Sidequest.set_progress("elona.cat_house", 1)
            common.create_downstairs(23, 22, 3, t.speaker:current_map())
         end
      },
      quest_no = {
         text = "talk.unique.tam.quest.no",
      },
      quest_waiting = {
         text = "talk.unique.tam.quest.waiting"
      },
      quest_finish = {
         on_start = function()
            local player = Chara.player()
            local map = player:current_map()

            local material_kit = Item.create("elona.material_kit", player.x, player.y, {}, map)
            ItemMaterial.change_item_material(material_kit, "elona.dragon_scale")
            Item.create("elona.gold_piece", player.x, player.y, {amount=25500}, map)
            Item.create("elona.platinum_coin", player.x, player.y, {amount=4}, map)

            common.quest_completed()
         end,
         text = "talk.unique.tam.quest.end",
         on_finish = function()
            Sidequest.set_progress("elona.cat_house", 1000)
         end
      }
   }
}
