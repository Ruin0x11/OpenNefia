local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local common = require("mod.elona.data.dialog.common")
local Item = require("api.Item")
local Chara = require("api.Chara")
local ItemMaterial = require("mod.elona.api.ItemMaterial")

data:add {
   _type = "elona_sys.dialog",
   _id = "conery",

   nodes = {
      __start = function()
         local flag = Sidequest.progress("elona.minotaur_king")
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
         text = "talk.unique.conery.complete"
      },
      quest_ask = {
         text = "talk.unique.conery.quest.dialog",
         choices = {
            {"quest_yes", "talk.unique.conery.quest.choices.do_it"},
            {"quest_no", "talk.unique.conery.quest.choices.bye"}
         },
         default_choice = "quest_no"
      },
      quest_yes = {
         on_start = function()
            Sidequest.update_journal()
         end,
         text = "talk.unique.conery.quest.do_it",
         on_finish = function()
            Sidequest.set_progress("elona.minotaur_king", 1)
         end
      },
      quest_no = {
         text = {
            {"talk.unique.conery.quest.bye", args = common.args_name},
         }
      },
      quest_waiting = {
         text = "talk.unique.conery.quest.waiting",
      },
      quest_finish = {
         text = "talk.unique.conery.quest.end",
         on_finish = function()
            local player = Chara.player()
            local map = player:current_map()
            local material_kit = Item.create("elona.material_kit", player.x, player.y, {no_stack = true}, map)
            ItemMaterial.change_item_material(material_kit, "elona.adamantium")
            Item.create("elona.gold_piece", player.x, player.y, {amount=50000}, map)
            Item.create("elona.platinum_coin", player.x, player.y, {amount=4}, map)

            common.quest_completed()

            Sidequest.set_progress("elona.minotaur_king", 1000)
         end
      },
   }
}
