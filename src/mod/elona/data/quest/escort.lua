local Rand = require("api.Rand")
local Quest = require("mod.elona_sys.api.Quest")
local Pos = require("api.Pos")
local Chara = require("api.Chara")
local QuestMap = require("mod.elona.api.QuestMap")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local Event = require("api.Event")
local Gui = require("api.Gui")
local Dialog = require("mod.elona_sys.dialog.api.Dialog")
local Enum = require("api.Enum")
local Charagen = require("mod.tools.api.Charagen")
local Map = require("api.Map")
local Effect = require("mod.elona.api.Effect")
local Skill = require("mod.elona_sys.api.Skill")

local global = require("mod.elona.internal.global")

local function escort_for_quest(quest, map)
   -- >>>>>>>> shade2/map.hsp:2104 			repeat maxFollower ..
   local pred = function(chara)
      return chara.is_being_escorted
         and Chara.is_alive(chara)
         and quest.params.escort_chara_uid == chara.uid
   end
   return Chara.iter_allies(map):filter(pred):nth(1)
   -- <<<<<<<< shade2/map.hsp:2107 			} ..
end

local function escort_for_quest_died(quest, map)
   -- >>>>>>>> shade2/map.hsp:2104 			repeat maxFollower ..
   local pred = function(chara)
      return chara.is_being_escorted
         and not Chara.is_alive(chara)
         and quest.params.escort_chara_uid == chara.uid
   end

   local dead = Chara.iter_allies(map):filter(pred):nth(1)
   local party = Chara.player():get_party()
   local not_in_party = not fun.iter(save.base.parties:get(party).members):any(function(uid) return uid == quest.params.escort_chara_uid end)

   return dead or not_in_party
   -- <<<<<<<< shade2/map.hsp:2107 			} ..
end

local escort = {
   _id = "escort",
   _type = "elona_sys.quest",

   elona_id = 1007,
   ordering = 40000,
   client_chara_type = 6,
   reward = "elona.supply",
   reward_fix = 140,

   min_fame = 0,
   chance = 11,

   params = { escort_type = "string", destination_map_uid = "number", encounters_seen = "number" },

   difficulty = 0,

   expiration_hours = function() return (Rand.rnd(6) + 2) * 24 end,

   locale_data = function(self)
      return {map = self.params.destination_map_name}, "type." .. self.params.escort_type
   end,

   prevents_return = true
}

function escort.generate(self, client, start)
   local dest = Rand.choice(Quest.iter_towns():filter(function(t) return t.uid ~= start.uid end))
   if not dest then
      return false, "No destinations to escort to."
   end

   local escort_type = Rand.choice { "protect", "poison", "deadline" }
   local dist = Pos.dist(start.world_map_x, start.world_map_y, dest.world_map_x, dest.world_map_y)

   if escort_type == "protect" then
      self.reward_fix = 140 + dist * 2
      self.deadline_days = Rand.rnd(8) + 6
      self.difficulty = math.clamp(Rand.rnd(Chara.player():calc("level") + 10)
                                      + Rand.rnd(Chara.player():calc("fame") / 500 + 1)
                                      + 1,
                                   1, 80)
   elseif escort_type == "poison" then
      self.reward_fix = 130 + dist * 2
      self.deadline_days = Rand.rnd(5) + 2
      self.difficulty = math.clamp(math.floor(self.reward_fix / 10 + 1), 1, 40)
   elseif escort_type == "deadline" then
      self.reward_fix = 80 + dist * 2
      self.deadline_days = Rand.rnd(8) + 6
      self.difficulty = math.clamp(math.floor(self.reward_fix / 20) + 1, 1, 40)
   end

   if start.archetype_id == "elona.noyel" or dest.archetype_id == "elona.noyel" then
      self.reward_fix = math.floor(self.reward_fix * 180 / 100)
   end

   self.params = {
      escort_type = escort_type,
      destination_map_uid = dest.uid,
      destination_map_name = dest.name,
      encounters_seen = 0
   }

   return true
end

function escort.on_accept(self)
   -- TODO party limit
   return true, "elona.quest_escort:accept"
end

function escort.on_failure(self)
   -- >>>>>>>> shade2/quest.hsp:356 			txtMore:txtEf coPurple:txt lang("あなたは護衛の任務を果たせな ..
   Gui.mes_c("quest.escort.you_failed_to_protect", "Purple")
   local chara = escort_for_quest(self)
   if chara then
      chara.is_being_escorted = nil
      if Chara.is_alive(chara) then
         local escort_type = self.params.escort_type
         local damage_source
         if escort_type == "protect" then
            Gui.mes_c("quest.escort.failed.protect", "SkyBlue", chara)
            damage_source = "elona.unknown"
         elseif escort_type == "poison" then
            Gui.mes_c("quest.escort.failed.poison", "SkyBlue", chara)
            damage_source = "elona.from_poison"
         elseif escort_type == "deadline" then
            Gui.mes_c("quest.escort.failed.deadline", "SkyBlue", chara)
            damage_source = "elona.from_fire"
         end
         chara:damage_hp(math.max(chara.hp + 1, 999999), damage_source)
      end
      chara.state = "Dead"
      if chara:is_ally() then
         local party = Chara.player():get_party()
         save.base.parties:remove_member(party, chara)
      end
   end
   Effect.modify_karma(Chara.player(), -10)
   -- <<<<<<<< shade2/quest.hsp:371 			} ..
end

data:add(escort)

data:add {
   _type = "elona_sys.dialog",
   _id = "quest_escort",

   nodes = {
      accept = function(t)
         -- >>>>>>>> shade2/chat.hsp:3022 			repeat  ..
         local quest = Quest.for_client(t.speaker)
         local map = t.speaker:current_map()
         assert(quest)

         local target
         for i = 1, 100 do
            local id
            if i == 100 then
               id = "elona.town_child"
            end
            local filter = { level = quest.difficulty + i - 1, quality = Enum.Quality.Bad, id = id, ownerless = true }
            target = Charagen.create(nil, nil, filter)
            if target then
               local pred = function(chara)
                  return chara._id == target._id and chara.is_being_escorted
               end

               if not Chara.iter_allies(map):any(pred) then
                  break
               end
            end
         end

         local player = Chara.player()
         assert(Map.try_place_chara(target, player.x, player.y, map))

         player:recruit_as_ally(target)
         target.is_being_escorted = true
         target.is_not_changeable = true
         quest.params.escort_chara_uid = target.uid
         -- <<<<<<<< shade2/chat.hsp:3035 			qParam2(rq)=cId(rc) ..

         return "elona.quest_giver:accept"
      end,
      complete = {
         text = "talk.npc.quest_giver.finish.escort"
      }
   }
}

local function check_escort_destination_reached(map)
   local pred = function(quest)
      return quest._id == "elona.escort" and quest.state == "accepted"
   end

   for _, quest in Quest.iter():filter(pred) do
      -- >>>>>>>> shade2/main.hsp:1776 	case evClientReached ..
      local target = escort_for_quest(quest, map)

      if target and map.uid == quest.params.destination_map_uid then
         local cb = function()
            Gui.mes("quest.escort.complete")
            Dialog.start(target, "elona.quest_escort:complete")
            Quest.complete(quest, nil)
            target:vanquish()
         end
         -- <<<<<<<< shade2/main.hsp:1780 	swbreak ..
         DeferredEvent.add(cb)
      elseif escort_for_quest_died(quest, map) then
         Quest.fail(quest)
      end
   end
end
Event.register("base.on_map_enter", "Check if escort destination is reached", check_escort_destination_reached)

local function event_client_dead(chara)
   -- >>>>>>>> shade2/main.hsp:1782 	case evClientDead ..
   return function()
      for _, quest in Quest.iter() do
         if quest._id == "elona.escort"
            and quest.state == "accepted"
            and chara.uid == quest.params.escort_chara_uid
         then
            Quest.fail(quest)
            break
         end
      end
   end
   -- <<<<<<<< shade2/main.hsp:1785 	loop ..
end

local function check_escort_killed(chara)
   -- >>>>>>>> shade2/chara_func.hsp:1674 		if tc!pc :if tc<maxFollower { ..
   if chara:is_player() or not chara:is_in_player_party() then
      return
   end

   Skill.modify_impression(chara, -10)

   if chara.is_being_escorted then
      chara.state = "Dead"
      if chara:is_ally() then
         local party = Chara.player():get_party()
         save.base.parties:remove_member(party, chara)
      end
      DeferredEvent.add(event_client_dead(chara))
   end
   -- <<<<<<<< shade2/chara_func.hsp:1683 			} ..
end

Event.register("base.on_chara_killed", "Check if escort was killed", check_escort_killed)

local function check_escort_left_behind(_, params)
   -- >>>>>>>> shade2/quest.hsp:324 		if gQuest=qGuard:if qStatus(rq)=0:gQuest=0,0,0,0 ..
   local quest = params.quest

   -- TODO create a temporary "sub quest" for the random encounter, preserve the
   -- state of the overarching escort quest
   if quest._id == "elona.escort" and quest.state == "completed" then
      quest.state = "accepted"
      save.elona_sys.immediate_quest_uid = nil
      return true
   end

   if quest.state == "completed" then
      return
   end

   if quest._id == "elona.escort" then
      Gui.mes("quest.escort.you_left_your_client")
   end
   return nil
   -- <<<<<<<< shade2/quest.hsp:324 		if gQuest=qGuard:if qStatus(rq)=0:gQuest=0,0,0,0 ..
end
Event.register("elona_sys.on_quest_map_leave", "Check if escort was left behind", check_escort_left_behind)

local function proc_assassin_encounter(map, params, encounter_id)
   -- >>>>>>>> shade2/action.hsp:664 			if rnd(20)=0{ ...
   if Rand.one_in(20) then
      local filter = function(quest)
         return quest._id == "elona.escort" and quest.params.escort_type == "protect" and quest.params.encounters_seen < 2
      end
      local escort_quest = Quest.iter_accepted():filter(filter):nth(1)
      if escort_quest then
         encounter_id = "elona.assassin"
         escort_quest.params.encounters_seen = escort_quest.params.encounters_seen + 1
         global.encounter_quest_uid = escort_quest.uid
      end
   end

   return encounter_id
   -- <<<<<<<< shade2/action.hsp:670 			} ..
end
Event.register("elona.on_generate_random_encounter_id", "Chance to encounter assassins in world map for escort quests", proc_assassin_encounter)
