local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Ui = require("api.Ui")
local I18N = require("api.I18N")
local Quest = require("mod.elona_sys.api.Quest")
local QuestMap = require("mod.elona.api.QuestMap")
local Map = require("api.Map")
local Calc = require("mod.elona.api.Calc")
local Enum = require("api.Enum")
local Gui = require("api.Gui")
local Input = require("api.Input")
local ElonaQuest = require("mod.elona.api.ElonaQuest")
local Event = require("api.Event")
local IOwned = require("api.IOwned")
local Item = require("api.Item")
local IItem = require("api.item.IItem")

local quest_harvest = {
   _type = "base.map_archetype",
   _id = "quest_harvest",

   starting_pos = function(map, chara, prev)
      -- >>>>>>>> shade2/map_rand.hsp:375 	gLevelStartOn=mStartSpec ..
      return {
         x = Rand.rnd(map:width() / 3) + map:width() / 3,
         y = Rand.rnd(map:height() / 3) + map:height() / 3
      }
      -- <<<<<<<< shade2/map_rand.hsp:377 	map_placePlayer	 ..
   end,

   properties = {
      types = { "quest" },
      tileset = "elona.wilderness",
      -- >>>>>>>> shade2/sound.hsp:413 			if gQuest=qHarvest	:music=mcVillage1 ...
      music = "elona.village1",
      -- <<<<<<<< shade2/sound.hsp:412 			if gQuest=qHunt		:music=mcBattle1 ..
      level = 1,
      is_indoor = false,
      is_temporary = true,
      max_crowd_density = 15,
      default_ai_calm = 0,
      shows_floor_count_in_name = true,
      prevents_building_shelter = true
   }
}

function quest_harvest.on_map_entered_events(map)
   if not Item.find("elona.masters_delivery_chest", "ground", map) then
      local player = Chara.player()
      local harvest_chest = Item.create("elona.masters_delivery_chest", player.x, player.y, {}, map)
      harvest_chest.own_state = Enum.OwnState.NotOwned
   end
end

function quest_harvest.chara_filter(map)
   -- >>>>>>>> shade2/map.hsp:71 		if gQuest>=qHeadRdQuest{ ..
   local quest = Quest.get_immediate_quest()
   local difficulty = 1
   if quest then
      difficulty = quest.difficulty
   end
   local level = Calc.calc_object_level(difficulty, map)
   level = math.clamp(level / 4, 1, 8)
   return {
      level = level,
      quality = Calc.calc_object_quality(Enum.Quality.Normal),
      tag_filters = {"wild"}
   }
   -- <<<<<<<< shade2/map.hsp:75 		return ..
end

data:add(quest_harvest)

local function is_harvest_great_success(quest)
   return quest.params.required_weight * 125 / 100 < quest.params.current_weight
end

local harvest = {
   _id = "harvest",
   _type = "elona_sys.quest",

   elona_id = 1006,
   ordering = 60000,
   client_chara_type = 5,
   reward = "elona.supply",
   reward_fix = 60,

   min_fame = 0,
   chance = function(client, town)
      if town.archetype_id == "elona.yowyn" then
         return 2
      end

      return 30
   end,

   params = { required_weight = "number", current_weight = "number" },

   difficulty = function()
      return math.clamp(Rand.rnd(Chara.player():calc("level") + 5) +
                           Rand.rnd(Chara.player():calc("fame") / 800 + 1) + 1,
                        1, 50)
   end,

   expiration_hours = function() return (Rand.rnd(6) + 2) * 24 end,

   generate = function(self, client)
      self.reward_fix = 60 + self.difficulty * 2

      self.params = {
         required_weight = 15000 + self.difficulty * 2500,
         current_weight = 0
      }

      return true
   end,

   locale_data = function(self, is_active)
      local required_weight = Ui.display_weight(self.params.required_weight)
      local objective = I18N.get("quest.info.harvest.text", required_weight)
      if is_active then
         objective = objective .. I18N.get("quest.info.now", Ui.display_weight(self.params.current_weight))
      end

      return {
         objective = objective,
         required_weight = required_weight
      }
   end,

   calc_reward_gold = function(self, gold)
      -- >>>>>>>> shade2/quest.hsp:456 	if qExist(rq)=qHarvest:if qParam1(rq)!0:if qParam ...
      if is_harvest_great_success(self) then
         gold = math.clamp(gold*self.params.current_weight/self.params.required_weight, gold, gold*3)
      end
      -- <<<<<<<< shade2/quest.hsp:456 	if qExist(rq)=qHarvest:if qParam1(rq)!0:if qParam ..
      return gold
   end,

   on_time_expired = function(self)
      -- >>>>>>>> shade2/main.hsp:1625 	if gQuest=qHarvest{ ...
      if self.params.required_weight < self.params.current_weight then
         self.state = "completed"
         Gui.mes_c("quest.harvest.complete", "Green")
         Input.query_more()
      else
         self.state = "failed"
         Gui.mes_c("quest.harvest.fail", "Purple")
      end
      -- <<<<<<<< shade2/main.hsp:1635 	if gQuest=qConquer{ ..

      ElonaQuest.travel_to_previous_map()
   end
}

function harvest.on_accept(self)
   return true, "elona.quest_harvest:accept"
end

function harvest.on_complete()
   return "elona.quest_harvest:complete"
end

data:add(harvest)

data:add {
   _type = "elona_sys.dialog",
   _id = "quest_harvest",

   nodes = {
      accept = {
         text = "talk.npc.quest_giver.accept.harvest",
         on_finish = function(t)
            local quest = Quest.for_client(t.speaker)
            assert(quest)

            local harvest_map = QuestMap.generate_harvest(quest.difficulty)
            local current_map = t.speaker:current_map()
            local player = Chara.player()
            harvest_map:set_previous_map_and_location(current_map, player.x, player.y)

            Quest.set_immediate_quest(quest)
            -- >>>>>>>> shade2/map_rand.hsp:335 	gTimeLimit=120:gCountNotice=9999 ...
            Quest.set_immediate_quest_time_limit(quest, 120)
            -- <<<<<<<< shade2/map_rand.hsp:334 *map_createDungeonHarvest ..

            Map.travel_to(harvest_map)
         end
      },
      complete = {
         on_start = function(t)
            local quest = Quest.for_client(t.speaker)
            assert(quest)
            Quest.complete(quest, t.speaker)
         end,
         text = function(t)
            local text = I18N.get("quest.giver.complete.done_well", t.speaker)

            -- >>>>>>>> shade2/text.hsp:1252 		if qExist(rq)=qHarvest:if qParam1(rq)*125/100<qP ..
            local quest = Quest.for_client(t.speaker)
            assert(quest)
            if is_harvest_great_success(quest) then
               text = text .. I18N.space() .. I18N.get("quest.giver.complete.extra_coins", t.speaker)
            end
            -- <<<<<<<< shade2/text.hsp:1252 		if qExist(rq)=qHarvest:if qParam1(rq)*125/100<qP ..

            return {text}
         end,
         jump_to = "elona.default:__start"
      }
   }
}

local function display_quest_message_harvest(map)
   local quest = Quest.get_immediate_quest()
   -- >>>>>>>> shade2/map.hsp:2161 		if gQuest=qHarvest{ ...
   if quest and quest._id == "elona.harvest" then
      if quest.params.required_weight <= 0 then
         quest.params.required_weight = 15000
         quest.reward_gold = 400
      end
      Gui.mes_c("map.quest.on_enter.harvest", "SkyBlue", Ui.display_weight(quest.params.required_weight), save.elona_sys.quest_time_limit)
   end
   -- <<<<<<<< shade2/map.hsp:2164 			} ..
end
Event.register("base.on_map_entered_events", "Display quest message (harvest)", display_quest_message_harvest)

local CAN_INCLUDE_QUEST_ITEMS = table.set {
   "elona.inv_examine",
   "elona.inv_drop",
   "elona.inv_get",
   "elona.inv_eat",
   "elona.inv_harvest_delivery_chest",
}
local function filter_quest_items(_, params, result)
   -- >>>>>>>> shade2/command.hsp:3423 		if iProperty(cnt)=propQuest:if (invCtrl!1)&(invC ..
   local context = params.context
   local item = params.item

   if item.own_state ~= Enum.OwnState.Quest then
      return result
   end

   local can_include = CAN_INCLUDE_QUEST_ITEMS[context.proto._id]
   if can_include == nil then
      return false
   end

   return result
   -- <<<<<<<< shade2/command.hsp:3423 		if iProperty(cnt)=propQuest:if (invCtrl!1)&(invC ..
end
Event.register("base.on_inventory_context_filter", "Filter quest items in most inventory contexts", filter_quest_items)

local function remove_quest_items_on_leave(_, params, result)
   -- >>>>>>>> shade2/quest.hsp:314 	if gQuest=qHarvest{ ..
   local quest = params.quest
   if quest._id ~= "elona.harvest" then
      return
   end

   local player = Chara.player()
   local pred = function(i) return i.own_state == Enum.OwnState.Quest end
   player:iter_items():filter(pred):each(IItem.remove_ownership)
   player:refresh_weight()
   -- <<<<<<<< shade2/quest.hsp:320 		} ..
end
Event.register("elona_sys.on_quest_map_leave", "When exiting map, remove quest items", remove_quest_items_on_leave)

local function start_harvesting_action(item, params, result)
   -- >>>>>>>> shade2/action.hsp:151 		if iType(ci)=fltFood:if iProperty(ci)=propQuest: ...
   local chara = params.chara

   if item:has_category("elona.food")
      and item.own_state == Enum.OwnState.Quest
      -- We also call Action.get() from the activity, which triggers this event,
      -- but during the activity's on_finish callback, so we can skip this logic
      -- when the item is successfully harvested.
      and not chara:has_activity()
   then
      -- HACK: Here we want to skip running the normal item getting logic and
      -- instead run the harvest activity. There is currently nothing in the
      -- events logic that allows for this in a general fashion, so instead we
      -- send down a turn result. There is a hack in Action.get() to skip the
      -- logic if it sees the current result is a string (meaning "turn
      -- result"). Otherwise `result` will be a boolean or nil.
      if chara:is_inventory_full() then
         Gui.mes("ui.inv.common.inventory_is_full")
         return "player_turn_query" -- TODO skip rest
      end

      chara:start_activity("elona.harvest", { item = item })

      return "turn_end"
   end
   -- <<<<<<<< shade2/action.hsp:155 		} ..
   return result
end
Event.register("base.on_get_item", "Start harvesting action", start_harvesting_action, 50000)
