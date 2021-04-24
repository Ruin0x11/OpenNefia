local Chara = require("api.Chara")
local Calc = require("mod.elona.api.Calc")
local Enum = require("api.Enum")
local Filters = require("mod.elona.api.Filters")
local Itemgen = require("mod.elona.api.Itemgen")
local Item = require("api.Item")
local Rand = require("api.Rand")
local Gui = require("api.Gui")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")

data:add {
   _type = "elona_sys.dialog",
   _id = "slan",

   nodes = {
      __start = function()
         local flag = Sidequest.progress("elona.main_quest")
         if flag == 20 then
            return "dialog"
         end

         return "elona_sys.ignores_you:__start"
      end,
      dialog = {
         on_start = function()
            Sidequest.set_progress("elona.main_quest", 30)
         end,
         text = {
            "talk.unique.slan.dialog._0",
            "talk.unique.slan.dialog._1",
            "talk.unique.slan.dialog._2",
         },
         on_finish = function(t)
            -- >>>>>>>> shade2/chat.hsp:733 		repeat 4 ...
            local player = Chara.player()
            local map = player:current_map()
            local x = player.x
            local y = player.y

            for _ = 1, 4 do
               local filter = {
                  level = Calc.calc_object_level(map:calc("level"), map),
                  quality = Enum.Quality.Normal,
                  categories = Filters.dungeon()
               }
               Itemgen.create(x, y, filter, map)
            end
            Item.create("elona.gold_piece", x, y, { amount = 1000 + Rand.rnd(200) }, map)
            Item.create("elona.platinum_coin", x, y, { amount = 3 }, map)
            local chest = Item.create("elona.bejeweled_chest", x, y, {}, map)
            if chest then
               chest.params.chest_lockpick_difficulty = 0
            end
            Gui.play_sound("base.write1")
            Gui.mes("talk.unique.slan.you_receive")
            Gui.mes("talk.unique.slan.dies", t.speaker)
            t.speaker:vanquish()
            -- <<<<<<<< shade2/chat.hsp:744 		goto *chat_end ..
         end
      }
   }
}
