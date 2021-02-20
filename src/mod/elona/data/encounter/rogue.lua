local Chara = require("api.Chara")
local Rand = require("api.Rand")
local Charagen = require("mod.tools.api.Charagen")
local Text = require("mod.elona.api.Text")
local Dialog = require("mod.elona_sys.dialog.api.Dialog")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local global = require("mod.elona.internal.global")

data:add {
   _type = "elona.encounter",
   _id = "rogue",

   encounter_level = function()
      -- >>>>>>>> shade2/action.hsp:673 			encounterLv=cFame(pc)/1000 ...
      return Chara.player():calc("fame") / 1000
      -- <<<<<<<< shade2/action.hsp:673 			encounterLv=cFame(pc)/1000 ..
   end,

   on_map_entered = function(map, level, outer_map, outer_x, outer_y)
      local player = Chara.player()

      -- >>>>>>>> shade2/map.hsp:1594 			mModerateCrowd =0  ...
      map.max_crowd_density = 0
      Chara.create("elona.rogue_boss", player.x, player.y, { level = level }, map)

      for _ = 1, 6 + Rand.rnd(6) do
         local filter = {
            initial_level = level + Rand.rnd(10),
            tag_filters = { "rogue_guard" }
         }
         local rogue = Charagen.create(14, 11, filter, map)
         if rogue then
            rogue.name = ("%s Lv %d"):format(rogue.name, rogue.level)
         end

         global.rogue_party_name = Text.random_title("party")
      end

      local event = function()
         -- >>>>>>>> shade2/main.hsp:1680 	tc=findChara(idShopKeeper) : gosub *chat ...
         local map_ = player:current_map()
         if map_.uid == map.uid then
            local rogue_boss = Chara.find("elona.rogue_boss", "all", map_)
            Dialog.start(rogue_boss)
         end
         -- <<<<<<<< shade2/main.hsp:1680 	tc=findChara(idShopKeeper) : gosub *chat ..
      end

      DeferredEvent.add(event)
      -- <<<<<<<< shade2/map.hsp:1604 			evAdd evRogue  ..
   end
}
