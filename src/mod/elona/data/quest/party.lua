local Chara = require("api.Chara")
local Rand = require("api.Rand")
local Quest = require("mod.elona_sys.api.Quest")
local Map = require("api.Map")
local QuestMap = require("mod.elona.api.QuestMap")
local Gui = require("api.Gui")
local Input = require("api.Input")
local Event = require("api.Event")
local elona_Quest = require("mod.elona.api.Quest")
local I18N = require("api.I18N")
local Item = require("api.Item")
local Const = require("api.Const")

local map_party = {
   _type = "base.map_archetype",
   _id = "quest_party",

   properties = {
      types = { "temporary" },
      tileset = "elona.castle",
      level = 1,
      is_indoor = false,
      max_crowd_density = 0,
      default_ai_calm = 0,
      shows_floor_count_in_name = true,
      prevents_building_shelter = true
   }
}

-- >>>>>>>> elona122/shade2/map_rand.hsp:676 	gLevelStartOn=mStartSpec ..
function map_party.starting_pos(map, chara)
   return {
      x = Rand.rnd(map:width()  / 3)  + map:width()  / 3,
      y = Rand.rnd(map:height() / 3)  + map:height() / 3
   }
end
-- <<<<<<<< elona122/shade2/map_rand.hsp:678 	map_placePlayer	 ..

data:add(map_party)

local party = {
   _id = "party",
   _type = "elona_sys.quest",

   elona_id = 1009,
   ordering = 50000,
   client_chara_type = 7,
   reward = nil,
   reward_fix = 0,

   min_fame = 0,
   chance = function(client, town)
      if town._archetype == "elona.palmia" then
         return 8
      end

      return 23
   end,

   params = { required_points = "number" },

   difficulty = function()
      local performer_skill = Chara.player():skill_level("elona.performer")
      return math.clamp(Rand.rnd(performer_skill + 10),
                        math.floor(1.5 * math.sqrt(performer_skill)) + 1,
                        math.floor(Chara.player():calc("fame") / 1000) + 10)
   end,

   expiration_hours = function() return (Rand.rnd(6) + 2) * 24 end,

   locale_data = function(self)
      local required_points = ("%d%s%s"):format(self.params.required_points, I18N.space(), I18N.get("quest.party.points"))
      return { required_points = required_points }
   end,

   on_time_expired = function(self)
      -- >>>>>>>> shade2/main.hsp:1609 	if gQuest=qPerform{ ..
      Gui.mes("quest.party.is_over")

      local map = Map.current()
      local score = elona_Quest.calc_party_score(map)
      local bonus = elona_Quest.calc_party_score_bonus(map)
      if bonus > 0 then
         Gui.mes("quest.party.total_bonus", bonus)
      end
      score = math.floor(score * (100+bonus)/100)
      self.params.current_points = score

      Gui.mes("quest.party.final_score", score)
      if score >= self.params.required_points then
         self.state = "completed"
         Gui.mes_c("quest.party.complete", "Green")
         Input.query_more()
      else
         self.state = "failed"
         Gui.mes_c("quest.party.fail", "Purple")
      end
      -- <<<<<<<< shade2/main.hsp:1623 		} ..

      local prev_map_uid, prev_x, prev_y = map:previous_map_and_location()
      Gui.play_sound("base.exitmap1")
      Gui.update_screen()
      local ok, prev_map = assert(Map.load(prev_map_uid))
      Map.travel_to(prev_map, { start_x = prev_x, start_y = prev_y })
   end
}

function party.generate(self, client)
   self.params = {
      required_points = self.difficulty * 10 + Rand.rnd(50),
      current_points = 0
   }

   return true
end

function party.on_accept(self)
   return true, "elona.quest_party:accept"
end

function party.on_complete()
   return "elona.quest_party:complete"
end

data:add(party)

---
--- Dialog
---

local function is_party_great_success(quest)
   return quest.params.required_points * 150 / 100 < quest.params.current_points
end

data:add {
   _type = "elona_sys.dialog",
   _id = "quest_party",

   nodes = {
      accept = {
         text = "talk.npc.quest_giver.accept.party",
         on_finish = function(t)
            local quest = Quest.for_client(t.speaker)
            assert(quest)

            local party_map = QuestMap.generate_party(quest.difficulty)
            local current_map = t.speaker:current_map()
            local player = Chara.player()
            party_map:set_previous_map_and_location(current_map, player.x, player.y)

            Quest.set_immediate_quest(quest)
            Quest.set_immediate_quest_time_limit(quest, 60)

            Map.travel_to(party_map)
         end
      },
      complete = {
         text = function(t)
            local text = I18N.get("quest.giver.complete.done_well", t.speaker)

            -- >>>>>>>> shade2/text.hsp:1253 		if qExist(rq)=qPerform:if qParam1(rq)*150/100<qP ..
            local quest = Quest.for_client(t.speaker)
            assert(quest)
            if is_party_great_success(quest) then
               text = text .. I18N.space() .. I18N.get("quest.giver.complete.music_tickets", t.speaker)
            end
            -- <<<<<<<< shade2/text.hsp:1253 		if qExist(rq)=qPerform:if qParam1(rq)*150/100<qP ..

            return {text}
         end,
         on_start = function(t)
            local quest = Quest.for_client(t.speaker)
            assert(quest)
            Quest.complete(quest, t.speaker)
         end,
         jump_to = "elona.default:__start"
      }
   }
}

local function add_music_tickets(_, params)
   local quest = params.quest
   -- >>>>>>>> shade2/quest.hsp:463 	if qExist(rq)=qPerform:if qParam1(rq)*150/100<qPa ..
   if quest._id == "elona.party" and is_party_great_success(quest) then
      local player = Chara.player()
      local amount = 1 + quest.params.current_points / 10
      Item.create("elona.music_ticket", player.x, player.y, { amount = amount })
   end
   -- <<<<<<<< shade2/quest.hsp:463 	if qExist(rq)=qPerform:if qParam1(rq)*150/100<qPa ..
end

Event.register("elona_sys.on_quest_completed", "Add music tickets if perform quest score high enough", add_music_tickets)

local function set_party_emotion_icon(chara)
   -- >>>>>>>> shade2/calculation.hsp:1295 	if gQuest=qPerform{ ..
   if not chara:is_allied() then
      local quest = Quest.get_immediate_quest()
      if quest and quest._id == "elona.party" then
         if chara.impression >= Const.IMPRESSION_PARTY then
            chara:set_emotion_icon("elona.party", 100)
         end
      end
   end
   -- <<<<<<<< shade2/calculation.hsp:1297 		} ..
end
Event.register("base.on_chara_turn_end", "Set emotion icon if guest satisfied", set_party_emotion_icon)
