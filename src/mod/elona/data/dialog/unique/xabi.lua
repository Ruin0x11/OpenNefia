local Gui = require("api.Gui")
local Chara = require("api.Chara")
local Item = require("api.Item")
local common = require("mod.elona.data.dialog.common")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")

data:add {
   _type = "elona_sys.dialog",
   _id = "xabi",

   nodes = {
      __start = function()
         local flag = Sidequest.progress("elona.main_quest")
         if flag >= 60 then
            return "late"
         elseif flag == 50 then
            return "mid"
         elseif flag == 40 then
            return "early"
         end

         return "elona_sys.ignores_you:__start"
      end,
      late = {
         text = "talk.unique.xabi.late"
      },
      mid = {
         text = "talk.unique.xabi.mid"
      },
      early = {
         on_start = function()
            Sidequest.set_progress("elona.main_quest", 50)
         end,
         text = {
            "talk.unique.xabi.early._0",
            function() Gui.fade_out() end,
            {"talk.unique.xabi.early._1", args = common.args_name},
         },
         choices = {
            {"__start", "ui.more"}
         },
         on_finish = function()
            local player = Chara.player()
            local x = player.x
            local y = player.y
            local map = player:current_map()
            Item.create("elona.gold_piece", x, y, {amount=2500}, map)
            Item.create("elona.platinum_coin", x, y, {amount=3}, map)
            Item.create("elona.potion_of_cure_corruption", x, y, {}, map)
            Item.create("elona.treasure_map", x, y, {}, map)
            Gui.mes("common.something_is_put_on_the_ground")
            Sidequest.update_journal()
         end
      }
   }
}
