local Chara = require("api.Chara")
local Const = require("api.Const")
local Enum = require("api.Enum")
local Gui = require("api.Gui")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")

local Quest = {}

-- >>>>>>>> shade2/calculation.hsp:1339 #deffunc calcPartyScore ..
function Quest.calc_party_score(map)
   local score = 0
   for _, chara in Chara.iter_others(map):filter(Chara.is_alive) do
      if chara.impression >= Const.IMPRESSION_PARTY then
         score = score + chara:calc("level") + 5
      end
      if chara.impression < Const.IMPRESSION_NORMAL then
         score = score - 20
      end
   end
   return score
end
-- <<<<<<<< shade2/calculation.hsp:1349 	return  ..

-- >>>>>>>> shade2/calculation.hsp:1351 #deffunc calcPartyScore2 ..
function Quest.calc_party_score_bonus(map, silent)
   local bonus = 0
   for _, chara in Chara.iter_others(map):filter(Chara.is_alive) do
      if chara.impression >= Const.IMPRESSION_PARTY and chara:calc("quality") >= Enum.Quality.Great then
         bonus = math.floor(bonus + 20 + chara:calc("level") / 2)
         if not silent then
            Gui.mes("quest.party.is_satisfied", chara)
         end
      end
   end
   return bonus
end
-- <<<<<<<< shade2/calculation.hsp:1359 	return  ..

local function event_quest_eliminate_hunt(quest)
   return function()
      Gui.play_music("elona.fanfare", true)
      quest.state = "completed"
      Gui.mes_c("quest.hunt.complete", "Green")
   end
end

function Quest.update_target_count_hunt(quest, map)
   -- >>>>>>>> shade2/chara_func.hsp:186 	if gQuestStatus!qSuccess{ ..
   if quest.state == "completed" then
      return
   end

   local target_count = Chara.iter_others():filter(Chara.is_alive):length()

   if target_count == 0 then
      DeferredEvent.add(event_quest_eliminate_hunt(quest))
   else
      Gui.mes_c("quest.hunt.remaining", "Blue", target_count)
   end
   -- <<<<<<<< shade2/chara_func.hsp:197 		} ..
end

return Quest
