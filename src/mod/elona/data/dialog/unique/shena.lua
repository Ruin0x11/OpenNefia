local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local common = require("mod.elona.data.dialog.common")
local Item = require("api.Item")
local Chara = require("api.Chara")
local IItemMonsterBall = require("mod.elona.api.aspect.IItemMonsterBall")
local IItemRod = require("mod.elona.api.aspect.IItemRod")

data:add {
   _type = "elona_sys.dialog",
   _id = "shena",

   nodes = {
      __start = function()
         local flag = Sidequest.progress("elona.thieves_hideout")
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
         text = "talk.unique.shena.complete"
      },
      quest_ask = {
         text = {
            "talk.unique.shena.quest.dialog._0",
            "talk.unique.shena.quest.dialog._1"
         },
         choices = {
            {"quest_yes", "talk.unique.shena.quest.choices.yes"},
            {"quest_no", "talk.unique.shena.quest.choices.no"}
         },
         default_choice = "quest_no"
      },
      quest_yes = {
         on_start = function()
            Sidequest.update_journal()
         end,
         text = "talk.unique.shena.quest.yes",
         on_finish = function(t)
            Sidequest.set_progress("elona.thieves_hideout", 1)
            common.create_downstairs(48, 5, 4, t.speaker:current_map())
         end
      },
      quest_no = {
         text = "talk.unique.shena.quest.no",

      },
      quest_waiting = {
         text = "talk.unique.shena.quest.waiting",

      },
      quest_finish = {
         on_start = function()
            local player = Chara.player()
            local map = player:current_map()

            Item.create("elona.rod_of_identify", player.x, player.y, {aspects={[IItemRod]={charges=12}}}, map)

            local aspects = {
               [IItemMonsterBall] = {
                  max_level = 5
               }
            }
            Item.create("elona.monster_ball", player.x, player.y, {no_stack = true, aspects = aspects}, map)
            Item.create("elona.gold_piece", player.x, player.y, {amount = 1500}, map)
            Item.create("elona.platinum_coin", player.x, player.y, {amount = 2}, map)

            common.quest_completed()
         end,
         text = "talk.unique.shena.quest.end",
         on_finish = function()
            Sidequest.set_progress("elona.thieves_hideout", 1000)
         end
      },
   }
}
