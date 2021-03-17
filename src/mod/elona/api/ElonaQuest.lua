local Chara = require("api.Chara")
local Const = require("api.Const")
local Enum = require("api.Enum")
local Gui = require("api.Gui")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local Map = require("api.Map")
local Quest = require("mod.elona_sys.api.Quest")
local Log = require("api.Log")

local ElonaQuest = {}

-- >>>>>>>> shade2/calculation.hsp:1339 #deffunc calcPartyScore ..
function ElonaQuest.calc_party_score(map)
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
function ElonaQuest.calc_party_score_bonus(map, silent)
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

local function hunt_target_count(quest, map, cb)
   -- >>>>>>>> shade2/chara_func.hsp:186 	if gQuestStatus!qSuccess{ ..
   if quest.state == "completed" then
      return
   end

   local target_count = Chara.iter_others():filter(Chara.is_alive):length()

   if target_count == 0 then
      DeferredEvent.add(cb)
   else
      Gui.mes_c("quest.hunt.remaining", "Blue", target_count)
   end
   -- <<<<<<<< shade2/chara_func.hsp:197 		} ..
end

function ElonaQuest.update_target_count_hunt(quest, map)
   return hunt_target_count(quest, map, event_quest_eliminate_hunt(quest))
end

local function event_quest_eliminate_escort(quest)
   return function()
      quest.state = "completed"
      Gui.play_music("elona.fanfare", true)
      Gui.mes_c("quest.hunt.complete", "Green")
   end
end

function ElonaQuest.update_target_count_escort(quest, map)
   return hunt_target_count(quest, map, event_quest_eliminate_escort(quest))
end

local function event_quest_eliminate_conquer(quest)
   return function()
      Gui.play_music("elona.fanfare", true)
      save.elona_sys.quest_time_limit = 0
      quest.state = "completed"
      Gui.mes_c("quest.conquer.complete", "Green")
   end
end

function ElonaQuest.update_target_count_conquer(quest, map)
   if quest.state == "completed" then
      return
   end

   -- >>>>>>>> shade2/chara_func.hsp:194 		if gQuest=qConquer{ ..
   local target = map:get_object_of_type("base.chara", quest.params.target_chara_uid)
   if not Chara.is_alive(target) then
      DeferredEvent.add(event_quest_eliminate_conquer(quest))
   end
   -- <<<<<<<< shade2/chara_func.hsp:196 			} ..
end

-- >>>>>>>> shade2/command.hsp:4378 *check_return ..
function ElonaQuest.is_non_returnable_quest_active()
   local pred = function(q)
      local proto = data["elona_sys.quest"]:ensure(q._id)
      return proto.prevents_return
   end
   return Quest.iter_accepted():any(pred)
end
-- <<<<<<<< shade2/command.hsp:4384 	return f ..

function ElonaQuest.travel_to_previous_map()
   local map = Chara.player():current_map()
   local prev_map_uid, prev_x, prev_y = map:previous_map_and_location()
   if prev_map_uid == nil then
      Log.error("Tried to travel to previous map, but there wasn't one set. This might be an error.")
      return
   end

   Gui.play_sound("base.exitmap1")
   Gui.update_screen()
   local ok, prev_map = assert(Map.load(prev_map_uid))
   Map.travel_to(prev_map, { start_x = prev_x, start_y = prev_y })
end

return ElonaQuest
