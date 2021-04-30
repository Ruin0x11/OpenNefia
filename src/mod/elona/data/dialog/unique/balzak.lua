local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local Item = require("api.Item")
local Chara = require("api.Chara")
local common = require("mod.elona.data.dialog.common")
local IItemMonsterBall = require("mod.elona.api.aspect.IItemMonsterBall")

data:add {
   _type = "elona_sys.dialog",
   _id = "balzak",

   nodes = {
      __start = function()
         local flag = Sidequest.progress("elona.sewer_sweeping")
         if flag == 1000 then
            return "quest_completed"
         elseif flag == 0 then
            return "quest_ask"
         elseif flag == 1 then
            return "quest_waiting"
         elseif flag == 2 then
            return "quest_finish"
         end
         return "__END__"
      end,
      quest_completed = {
         text = "talk.unique.balzak.complete"
      },
      quest_ask = {
         text = {
            {"talk.unique.balzak.quest.dialog._0"},
            {"talk.unique.balzak.quest.dialog._1"}
         },
         choices = {
            {"quest_yes", "talk.unique.balzak.quest.choices.yes"},
            {"quest_no", "talk.unique.balzak.quest.choices.no"}
         },
         default_choice = "quest_no"
      },
      quest_yes = {
         on_start = function()
            Sidequest.update_journal()
         end,
         text = "talk.unique.balzak.quest.yes",
         on_finish = function(t)
            Sidequest.set_progress("elona.sewer_sweeping", 1)
            common.create_downstairs(18, 45, 20, t.speaker:current_map())
         end
      },
      quest_no = {
         text = "talk.unique.balzak.quest.no",
      },
      quest_waiting = {
         text = "talk.unique.balzak.quest.waiting",
      },
      quest_finish = {
         on_start = function()
            local player = Chara.player()
            local map = player:current_map()
            Item.create("elona.statue_of_jure", player.x, player.y, {}, map)
            Item.create("elona.monster_ball", player.x, player.y, {no_stack = true, aspects = {[IItemMonsterBall] = { max_level = 30 }}}, map)
            Item.create("elona.gold_piece", player.x, player.y, {amount=15000}, map)
            Item.create("elona.platinum_coin", player.x, player.y, {amount=4}, map)
            common.quest_completed()
         end,
         text = "talk.unique.balzak.quest.end",
         on_finish = function()
            Sidequest.set_progress("elona.sewer_sweeping", 1000)
         end
      },
   }
}
