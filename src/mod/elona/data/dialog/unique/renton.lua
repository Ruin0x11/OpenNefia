local Chara = require("api.Chara")
local IItemBookOfRachel = require("mod.elona.api.aspect.IItemBookOfRachel")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local Item = require("api.Item")
local common = require("mod.elona.data.dialog.common")
local Gui = require("api.Gui")

local function take_books()
   local taken_books = {}
   for _, item in Chara.player():iter_inventory() do
      if item.amount ~= 0 then
         local aspect = item:get_aspect(IItemBookOfRachel)
         if aspect then
            local book_number = aspect:calc(item, "book_number")
            if book_number >= 1 and book_number <= 4 then
               if not taken_books[book_number] then
                  item.amount = item.amount - 1
                  taken_books[book_number] = true
               end
            end
         end
      end
   end
end

data:add {
   _type = "elona_sys.dialog",
   _id = "renton",

   nodes = {
      __start = function()
         local flag = Sidequest.progress("elona.rare_books")
         if flag == 1000 then
            return "quest_completed"
         elseif flag == 0 or flag == 1 then
            return "quest_dialog"
         end

         return "elona_sys.ignores_you:__start"
      end,
      quest_completed = {
         text = "talk.unique.renton.complete",
      },
      quest_dialog = {
         text = {
            "talk.unique.renton.quest.dialog._0",
            "talk.unique.renton.quest.dialog._1",
            "talk.unique.renton.quest.dialog._2",
            "talk.unique.renton.quest.dialog._3",
         },
         choices = {
            {"quest_check", "ui.more"},
         },
      },
      quest_check = function()
         if Sidequest.progress("elona.rare_books") == 0 then
            Sidequest.update_journal()
            Sidequest.set_progress("elona.rare_books", 1)
            return "__END__"
         end

         local found_books = {}
         local total_books = 0
         for _, item in Chara.player():iter_inventory() do
            if item.amount ~= 0 then
               local aspect = item:get_aspect(IItemBookOfRachel)
               if aspect then
                  local book_number = aspect:calc(item, "book_number")
                  if book_number >= 1 and book_number <= 4 then
                     if not found_books[book_number] then
                        total_books = total_books + 1
                        found_books[book_number] = true
                     end
                  end
               end
            end
         end

         if total_books > 0 then
            if total_books ~= 4 then
               return { node_id = "quest_brought_some", params = {total_books=total_books} }
            else
               return "quest_finish"
            end
         end
      end,
      quest_brought_some = {
         text = {
            {"talk.unique.renton.quest.brought", args = function(_, _, params) return {params.total_books} end},
         },
      },
      quest_finish = {
         on_start = take_books,
         text = {
            "talk.unique.renton.quest.brought_all.dialog._0",
            "talk.unique.renton.quest.brought_all.dialog._1",
            "talk.unique.renton.quest.brought_all.dialog._2",
            "talk.unique.renton.quest.brought_all.dialog._3",
            "talk.unique.renton.quest.brought_all.dialog._4",
            function(t)
               Gui.mes_c("talk.unique.renton.quest.brought_all.ehekatl", "Yellow")
            end,
            "talk.unique.renton.quest.brought_all.dialog._5",
         },
         on_finish = function()
            local player = Chara.player()
            local map = player:current_map()

            Item.create("elona.statue_of_lulwy", player.x, player.y, {}, map)
            Item.create("elona.hero_cheese", player.x, player.y, {}, map)
            Item.create("elona.gold_piece", player.x, player.y, {amount=20000}, map)
            Item.create("elona.platinum_coin", player.x, player.y, {amount=5}, map)

            common.quest_completed()

            Sidequest.set_progress("elona.rare_books", 1000)
         end
      },
   }
}
