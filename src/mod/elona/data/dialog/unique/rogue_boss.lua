local global = require("mod.elona.internal.global")
local Chara = require("api.Chara")
local Gui = require("api.Gui")
local ElonaQuest = require("mod.elona.api.ElonaQuest")
local IItemCargo = require("mod.elona.api.aspect.IItemCargo")

-- >>>>>>>> shade2/chat.hsp:1973 		snd sePayGold ...
local function surrender_cost()
   return Chara.player().gold / 5
end

local function surrender()
   local player = Chara.player()
   Gui.play_sound("base.paygold1")
   player.gold = player.gold - surrender_cost()

   for _, item in player:iter_inventory() do
      if item.amount > 0 and item:get_aspect(IItemCargo) then
         Gui.mes("talk.npc.common.hand_over", item)
         item:remove_ownership()
      end
   end

   Chara.player():refresh_weight()
end
-- <<<<<<<< shade2/chat.hsp:1980 		call calcBurdenPc ..

data:add {
   _type = "elona_sys.dialog",
   _id = "rogue_boss",

   nodes = {
      __start = function()
         -- >>>>>>>> shade2/chat.hsp:1964 	if cGold(pc)<=10{ ...
         if Chara.player().gold <= 10 then
            return "too_poor"
         end
         -- <<<<<<<< shade2/chat.hsp:1967 	} ..

         return "ambush"
      end,
      too_poor = {
         text = {
            {"talk.unique.rogue_boss.too_poor", args = function(t) return {t.speaker} end},
         },
         on_finish = function()
            ElonaQuest.travel_to_previous_map()
         end
      },
      ambush = {
         text = {
            {
               "talk.unique.rogue_boss.ambush.dialog",
               args = function(t)
                  return {
                     global.rogue_party_name,
                     surrender_cost(),
                     t.speaker
                  }
               end
            },
         },
         choices = {
            {"try_me", "talk.unique.rogue_boss.ambush.choices.try_me"},
            {"surrender", "talk.unique.rogue_boss.ambush.choices.surrender"},
         }
      },
      try_me = {
         text = {
            {"talk.unique.rogue_boss.ambush.try_me", args = function(t) return {t.speaker} end},
         },
      },
      surrender = {
         text = {
            surrender,
            {"talk.unique.rogue_boss.ambush.surrender", args = function(t) return {t.speaker} end},
         },
         on_finish = function()
            ElonaQuest.travel_to_previous_map()
         end
      },
   }
}
