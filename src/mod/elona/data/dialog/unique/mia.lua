local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local Chara = require("api.Chara")
local Item = require("api.Item")
local common = require("mod.elona.data.dialog.common")
local Enum = require("api.Enum")

data:add {
   _type = "elona_sys.dialog",
   _id = "mia",

   nodes = {
      __start = function()
         local flag = Sidequest.progress("elona.mias_dream")
         if flag == 1000 then
            return "quest_completed"
         elseif flag == 0 then
            return "quest_ask"
         elseif flag == 1 then
            return "quest_check"
         end

         return "elona_sys.ignores_you:__start"
      end,
      quest_completed = {
         text = "talk.unique.mia.complete",
      },
      quest_ask = {
         text = "talk.unique.mia.quest.dialog",
         choices = {
            {"quest_yes", "talk.unique.mia.quest.choices.yes"},
            {"quest_no", "talk.unique.mia.quest.choices.no"}
         },
         default_choice = "quest_no"
      },
      quest_yes = {
         on_start = function()
            Sidequest.update_journal()
         end,
         text = "talk.unique.mia.quest.yes",
         on_finish = function()
            Sidequest.set_progress("elona.mias_dream", 1)
         end
      },
      quest_no = {
         text = "talk.unique.mia.quest.no",
      },
      quest_check = function(t)
         local map = Chara.player():current_map()
         if Chara.find("elona.silver_cat", "allies", map) == nil then
            return "quest_waiting"
         end

         return "quest_finish"
      end,
      quest_waiting = {
         text = "talk.unique.mia.quest.waiting"
      },
      quest_finish = {
         text = {
            "talk.unique.mia.quest.end._0",
            "talk.unique.mia.quest.end._1",
         },
         on_finish = function()
            -- >>>>>>>> shade2/chat.hsp:1435 		flt : item_create -1,idMonsterHeart,cX(pc),cY(pc ...
            local player = Chara.player()
            local map = player:current_map()

            Item.create("elona.monster_heart", player.x, player.y, {}, map)
            Item.create("elona.gold_piece", player.x, player.y, {amount=5000}, map)
            Item.create("elona.platinum_coin", player.x, player.y, {amount=3}, map)

            common.quest_completed()

            Sidequest.set_progress("elona.mias_dream", 1000)

            local silver_cat = Chara.find("elona.silver_cat", "allies", map)
            silver_cat:leave_party()
            silver_cat.relation = Enum.Relation.Dislike
            silver_cat:reset_all_relations()
            silver_cat:remove_all_roles()
            silver_cat:add_role("elona.special")
            -- <<<<<<<< shade2/chat.hsp:1441 		goto *chat_end ..
         end
      }
   }
}
