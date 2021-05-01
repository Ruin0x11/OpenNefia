local Chara = require("api.Chara")
local Item = require("api.Item")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local common = require("mod.elona.data.dialog.common")
local Gui = require("api.Gui")
local IItemMonsterBall = require("mod.elona.api.aspect.IItemMonsterBall")

local function give_monster_balls()
   local flag = Sidequest.progress("elona.ambitious_scientist")
   local found = false

   for _, item in Chara.player():iter_inventory() do
      if flag >= 6 then
         break
      end

      if item.amount > 0 and item._id == "elona.monster_ball" then
         local aspect = item:get_aspect(IItemMonsterBall)
         if aspect and aspect.chara_id ~= nil then
            found = true
            while item.amount > 0 and flag < 6 do
               Gui.mes("talk.unique.icolle.quest.give.deliver", item:build_name(1));
               item.amount = item.amount - 1
               flag = flag + 1
            end
         end
      end
   end

   Chara.player():refresh_weight()

   Sidequest.set_progress("elona.ambitious_scientist", flag)
   return found
end

data:add {
   _type = "elona_sys.dialog",
   _id = "icolle",

   nodes = {
      __start = function()
         local flag = Sidequest.progress("elona.ambitious_scientist")
         if flag >= 1000 then
            return "quest_completed"
         elseif flag == 0 then
            return "quest_ask"
         elseif flag >= 1 and flag <= 5 then
            return "quest_check"
         elseif flag >= 6 then
            return "quest_finish"
         end

         return "elona_sys.ignores_you:__start"
      end,
      quest_completed = {
         text = "talk.unique.icolle.complete",
      },
      quest_ask = {
         text = "talk.unique.icolle.quest.dialog",
         choices = {
            {"quest_yes", "talk.unique.icolle.quest.choices.alright"},
            {"quest_no", "ui.bye"}
         },
         default_choice = "quest_no"
      },
      quest_yes = {
         on_start = function()
            local aspects = {
               [IItemMonsterBall] = {
                  max_level = 5
               }
            }
            local player = Chara.player()
            local map = player:current_map()
            Item.create("elona.monster_ball", player.x, player.y, {no_stack = true, amount = 6, aspects = aspects}, map)
            Sidequest.update_journal()
         end,
         text = "talk.unique.icolle.quest.alright",
         on_finish = function()
            Sidequest.set_progress("elona.ambitious_scientist", 1)
         end
      },
      quest_no = {
         text = "talk.unique.icolle.quest.bye",
      },
      quest_check = function()
         local gave = give_monster_balls()

         if gave then
            return "quest_give"
         end

         return "quest_waiting"
      end,
      quest_give = {
         text = "talk.unique.icolle.quest.give.have",
         choices = function()
            if Sidequest.progress("elona.ambitious_scientist") >= 6 then
               return {{"quest_finish", "ui.bye"}}
            end
            return {{"__END__", "ui.bye"}}
         end
      },
      quest_waiting = {
         text = "talk.unique.icolle.quest.give.do_not_have",
      },
      quest_finish = {
         text = "talk.unique.icolle.quest.end",
         on_finish = function()
            local player = Chara.player()
            local map = player:current_map()

            Item.create("elona.gene_machine", player.x, player.y, {}, map)
            Item.create("elona.gold_piece", player.x, player.y, {amount=2500}, map)
            Item.create("elona.platinum_coin", player.x, player.y, {amount=2}, map)

            common.quest_completed()

            Sidequest.set_progress("elona.ambitious_scientist", 1000)
         end
      }
   }
}
