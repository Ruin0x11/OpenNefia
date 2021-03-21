--- @module Quest
local Save = require("api.Save")
local Enum = require("api.Enum")

local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Map = require("api.Map")
local Log = require("api.Log")
local World = require("api.World")
local Item = require("api.Item")
local Itemgen = require("mod.elona.api.Itemgen")
local I18N = require("api.I18N")
local Event = require("api.Event")
local Gui = require("api.Gui")
local Effect = require("mod.elona.api.Effect")
local Calc = require("mod.elona.api.Calc")
local Area = require("api.Area")

local Quest = {}

--- Iterates all quests that can appear in quest boards.
---
--- @treturn iterator(IQuest)
function Quest.iter()
   return fun.wrap(pairs(save.elona_sys.quest.quests))
end

--- Iterates all quests that the player has accepted (completed or not).
---
--- @treturn iterator(IQuest)
function Quest.iter_accepted()
   return Quest.iter():filter(function(q) return q.state ~= "not_accepted" end)
end

function Quest.get(uid)
   return fun.iter(save.elona_sys.quest.quests):filter(function(q) return q.uid == uid end):nth(1)
end

--- Returns the quest this character is giving as a client, if any.
--- @tparam IChara chara
--- @treturn[opt] table
function Quest.for_client(chara)
   local uid = chara
   if type(chara) == "table" then
      uid = chara.uid
   end

   return fun.iter(save.elona_sys.quest.quests):filter(function(q) return q.client_uid == uid end):nth(1)
end

local function calc_quest_reward(quest)
   local reward_gold = ((quest.difficulty + 3) * 100 + Rand.rnd(quest.difficulty * 30 + 200) + 400) * quest.reward_fix / 100
   reward_gold = reward_gold * 100 / (100 + quest.difficulty * 2 / 3)
   if quest.client_chara_type == 3 or quest.client_chara_type == 2 then
      return math.floor(reward_gold)
   end

   local level = Chara.player():calc("level")
   if level >= quest.difficulty then
      reward_gold = reward_gold * 100 / (100 + (level - quest.difficulty) * 10)
   else
      reward_gold = reward_gold * (100 + math.clamp((quest.difficulty - level) / 5 * 25, 0, 200)) / 100
   end

   return math.floor(reward_gold)
end

function Quest.generate_from_proto(proto_id, chara, map)
   local uid = chara
   if type(chara) == "table" then
      uid = chara.uid
   end

   local client = save.elona_sys.quest.clients[uid]
   if not client then
      return nil, "Character is not a valid quest client."
   end

   local existing_quest = Quest.for_client(uid)
   if existing_quest then
      if existing_quest.state ~= "finished" then
         Log.warn("Overwriting quest for client " .. uid .. " as they are already giving one.")
      end
      assert(table.iremove_value(save.elona_sys.quest.quests, existing_quest))
   end

   local town = save.elona_sys.quest.towns[client.originating_map_uid]
   assert(town)

   Log.debug("generate quest ID: '%s'", proto_id)

   local proto = data["elona_sys.quest"]:ensure(proto_id)

   local quest = {
      uid = save.elona_sys.quest_uids:get_next_and_increment(),
      _id = proto._id,
      client_chara_type = 0,
      difficulty = 0,
      -- not_accepted: quest is viewable in the quest board
      -- accepted: quest is viewable in the player's journal
      -- failed: quest was failed
      -- completed: quest was finished, but not turned in yet
      -- finished: quest was finished and turned in.
      state = "not_accepted",
      expiration_date = 0,
      deadline_days = nil,
      reward = nil,
      reward_fix = 0,
      client_uid = nil,
      client_name = nil,
      originating_map_uid = nil,
      reward_gold = nil,
      map_name = nil,
      params = {},
   }

   local add_field = function(proto, quest, field)
      if proto[field] then
         if type(proto[field]) == "function" then
            quest[field] = proto[field](quest, client, town)
         elseif proto[field] then
            quest[field] = proto[field]
         end
      end
   end

   quest.client_chara_type = proto.client_chara_type or 0

   quest.reward = proto.reward or nil

   quest.reward_fix = proto.reward_fix or 0

   add_field(proto, quest, "difficulty")
   add_field(proto, quest, "deadline_days")

   local expiration_hours
   if type(proto.expiration_hours) == "function" then
      expiration_hours = proto.expiration_hours(quest, client, town)
   else
      expiration_hours = proto.expiration_hours or (Rand.rnd(3) + 1) * 24
   end

   if proto.generate then
      local success, err = proto.generate(quest, client, town, map)
      if not success then
         local mes = ("Tried to generate quest '%s' but did not succeed: %s"):format(proto_id, err)
         Log.warn(mes)
         return nil, mes
      end
   end

   add_field(proto, quest, "reward_fix")

   for key, ty in pairs(proto.params or {}) do
      if type(quest.params[key]) ~= ty then
         error(("Generated quest '%s' expects parameter '%s' of type '%s', got '%s'"):format(proto._id, key, ty, type(quest.params[key])))
      end
   end

   if type(quest.reward) == "string" then
      quest.reward = { _id = quest.reward }
   end
   if quest.reward then
      local reward = data["elona_sys.quest_reward"]:ensure(quest.reward._id)
      if reward.params then
         for key, ty in pairs(reward.params) do
            if type(quest.reward[key]) ~= ty then
               error(("Quest reward '%s' expects parameter '%s' of type '%s', got '%s' (%s)"):format(quest.reward._id, key, ty, type(quest.reward[key]), proto._id))
            end
         end
      end
   end

   quest.client_uid = client.uid
   quest.client_name = client.name
   quest.originating_map_uid = town.uid

   quest.reward_gold = calc_quest_reward(quest)

   if expiration_hours ~= nil then
      quest.expiration_date = expiration_hours + World.date_hours()
   end
   quest.map_name = town.name

   Log.debug("Successfully generated quest: %s", inspect(quest))

   table.insert(save.elona_sys.quest.quests, quest)

   return quest, nil
end

function Quest.format_reward_text(quest)
   local reward = I18N.get("quest.info.gold_pieces", quest.reward_gold)
   if quest.reward ~= nil then
      local reward_proto = data["elona_sys.quest_reward"]:ensure(quest.reward._id)
      local text
      if reward_proto.localize then
         text = reward_proto.localize(quest.reward, quest)
      else
         text = I18N.get("quest.reward." .. quest.reward._id)
      end
      reward = reward .. I18N.get("quest.info.and") .. text
   end

   return reward
end

function Quest.format_detail_text(quest)
   local locale_params = Quest.get_locale_params(quest, true)
   return I18N.get("quest.types." .. quest._id .. ".detail", locale_params)
end

function Quest.get_locale_params(quest, is_active)
   local proto = data["elona_sys.quest"]:ensure(quest._id)
   local params = {}

   params.map = quest.map_name

   local reward = Quest.format_reward_text(quest)
   params.reward = reward

   local locale_key = "quest.types." .. quest._id
   if proto.locale_data then
      -- contains data specific to each quest type, like enemy level,
      -- harvest item weight, etc.
      local extra_params, locale_key_suffix = proto.locale_data(quest)

      assert(extra_params)
      params = table.merge(params, extra_params)
      if locale_key_suffix then
         locale_key = locale_key .. "." .. locale_key_suffix
      end
   end

   return params, locale_key
end

function Quest.format_name_and_desc(quest, speaker, is_active)
   local params, locale_key = Quest.get_locale_params(quest, speaker, is_active)

   -- Count how many entries under the key that exist containing a
   -- "title" field.
   local choices = I18N.get_choice_count(locale_key, "title")
   if choices == 0 then
      print(locale_key)
      return "<unknown>", "<unknown>"
   end

   Rand.set_seed(quest.client_uid + 1)

   local index = Rand.rnd(choices) + 1

   Rand.set_seed()

   local player = Chara.player()
   local title = I18N.get(locale_key .. "._" .. index .. ".title", player, speaker, params)
   local desc = I18N.get(locale_key .. "._" .. index .. ".desc", player, speaker, params)

   return title, desc
end

function Quest.format_deadline_text(deadline_days)
   if deadline_days == nil then
      return I18N.get("quest.info.no_deadline")
   else
      return I18N.get("quest.info.days", deadline_days)
   end
end

function Quest.generate(chara, map)
   local uid = chara
   if type(chara) == "table" then
      uid = chara.uid
   end

   local client = save.elona_sys.quest.clients[uid]
   if not client then
      return nil, "Character is not a valid quest client."
   end

   local town = save.elona_sys.quest.towns[client.originating_map_uid]
   assert(town)

   Log.debug("Attempting to generate quest for client %d", uid)

   -- Sort by ordering to preserve the imperative randomization
   -- (sequential checks for rnd(n) == 0)
   local list = data["elona_sys.quest"]:iter():to_list()
   table.sort(list, function(a, b) return a.ordering < b.ordering end)

   local fame = Chara.player():calc("fame")

   local proto
   for _, p in ipairs(list) do
      local chance = p.chance
      if type(chance) == "function" then
         chance = chance(client, town)
      end
      assert(type(chance) == "number")

      local min_fame = p.min_fame or 0
      if p.min_fame <= 0 or fame >= p.min_fame then
         if Rand.one_in(chance) then
            proto = p
            break
         end
      end
   end

   if proto == nil then
      Log.debug("Quest generation was skipped.")
      return nil, "Generation was skipped."
   end

   return Quest.generate_from_proto(proto._id, client, map)
end

function Quest.create_reward(quest)
   local proto = data["elona_sys.quest"]:ensure(quest._id)
   local quest_reward = data["elona_sys.quest_reward"]:ensure(quest.reward._id)

   local reward_count = Rand.rnd(Rand.rnd(4) + 1) + 1
   if proto.reward_count then
      reward_count = proto.reward_count(quest)
   end

   for _ = 1, reward_count do
      local params = quest_reward.generate(quest.reward, quest)
      local item
      if params.id then
         item = Item.create(params.id, Chara.player().x, Chara.player().y, params)
      else
         item = Itemgen.create(Chara.player().x, Chara.player().y, params)
      end
   end
end

--- Iterates all potential quest client characters.
function Quest.iter_clients()
   return fun.wrap(pairs(save.elona_sys.quest.clients))
end

--- Iterates all potential quest client characters in this map.
function Quest.iter_clients_in_map(map)
   return Quest.iter_clients():filter(function(c) return c.originating_map_uid == map.uid end)
end

--- Iterates all potential quest destinations.
function Quest.iter_towns()
   return fun.wrap(pairs(save.elona_sys.quest.towns))
end

--- Returns the quest destination info for a registered town map.
function Quest.town_info(map)
   local uid = map
   if type(map) == "table" then
      uid = map.uid
   end
   return save.elona_sys.quest.towns[uid] or nil
end

function Quest.is_valid_quest_client(chara)
   if chara == nil or chara.state == "Dead" then
      return false, "Character is not alive."
   end
   if not chara.can_talk then
      return false, "Cannot talk to character."
   end
   if not chara:has_any_roles() then
      return false, "Character has no role."
   end
   if chara:find_role("elona.special") then
      return false, "Character is marked as being unable to be a quest client."
   end
   if chara:find_role("elona.adventurer") then
      return false, "Character is an adventurer."
   end

   local map = chara:current_map()

   if map == nil then
      return false, "Character is not on a map."
   end
   if not save.elona_sys.quest.towns[map.uid] then
      return false, ("Map %d (%s) is not registered as a valid quest endpoint map. Use Quest.register_town() to register it as one.")
         :format(map.uid, map.gen_id)
   end

   return true
end

--- Registers this character as a quest client. The following
--- conditions must be satisfied:
---
--- - You must be able to talk to the character.
--- - The character must have at least one role.
--- - The character must not have the role "elona.special".
--- - The character must be on a map.
--- - The character's map must be registered as a town using
---   Quest.register_town().
--- - The character must not be currently giving a quest.
---
--- @tparam IChara chara
function Quest.register_client(chara)
   local ok, reason = Quest.is_valid_quest_client(chara)
   if not ok then
      return nil, reason
   end

   local map = chara:current_map()

   Log.debug("Register quest client %d", chara.uid)

   local client = {
      uid = chara.uid,
      name = chara.name,
      originating_map_uid = map.uid,
      originating_map_name = map.name
   }

   save.elona_sys.quest.clients[chara.uid] = client

   return client
end

function Quest.register_town(map)
   if map.is_generated_every_time then
      return nil, "Map must be able to be regenerated (is_generated_every_time = false)"
   end
   local area = Area.for_map(map)
   if not area then
      return nil, "Map must have area"
   end
   local parent = Area.parent(area)
   if not area then
      return nil, "Map must have parent area"
   end

   local x, y, floor = parent:child_area_position(area)
   assert(x, "Town must have a parent area and position set")

   Log.debug("Register quest endpoint %d", map.uid)

   local town = {
      uid = map.uid,
      name = map.name,
      archetype_id = map._archetype,
      world_map_area_uid = parent.uid,
      world_map_x = x,
      world_map_y = y,
      world_map_floor = floor
   }

   save.elona_sys.quest.towns[map.uid] = town

   return town
end

function Quest.unregister_client(chara)
   local uid = chara
   if type(chara) == "table" then
      uid = chara.uid
   end

   save.elona_sys.quest.clients[uid] = nil

   local remove = {}
   for i, client in pairs(save.elona_sys.quest.quests) do
      if client.uid == uid then
         remove[#remove+1] = i
      end
   end

   table.remove_indices(save.elona_sys.quest.quests, remove)
end

function Quest.unregister_town(map)
   local remove = {}
   for k, client in pairs(save.elona_sys.quest.clients) do
      if client.originating_map_uid == map.uid then
         remove[#remove+1] = k
      end
   end

   table.remove_keys(save.elona_sys.quest.clients, remove)

   remove = {}
   for i, quest in ipairs(save.elona_sys.quest.quests) do
      if quest.originating_map_uid == map.uid then
         remove[#remove+1] = i
      end
   end

   table.remove_keys(save.elona_sys.quest.quests, remove)

   save.elona_sys.quest.towns[map.uid] = nil
end

--- Updates the status of all quests in this map.
---
--- NOTE: This function modifies the map, so the caller has to be sure
--- to call `Map.save()` on it afterward. For example, the "collect"
--- quest generates an item on the target character.
---
--- @tparam InstancedMap map
function Quest.update_in_map(map)
   -- This overwrites and updates the quest info for the map if it
   -- goes out of date (like the entrance was moved for some reason)
   if map:has_type("town") and Area.parent(map) then
      Quest.register_town(map)
   end

   if Quest.town_info(map) then
      -- Register all characters that can be quest targets.
      for _, chara in Chara.iter_others(map) do
         if chara.quality < Enum.Quality.Unique
            and not chara:find_role("elona.special")
            and not chara:find_role("elona.adventurer")
         then
            local ok, err = Quest.register_client(chara)
            if not ok then
               Log.debug(err)
            end
         end
      end

      -- Remove clients that do not exist in this map any longer.
      local remove = {}
      for i, client in pairs(save.elona_sys.quest.clients) do
         if map:get_object(client.uid == nil) then
            Log.warn("Remove missing quest client %d", client.uid)
            remove[#remove+1] = i
         end
      end

      table.remove_indices(save.elona_sys.quest.clients, remove)

      -- Generate quests for characters that are not already quest givers.
      for _, client in Quest.iter_clients_in_map(map) do
         local quest = Quest.for_client(client)
         local do_generate = quest == nil
            or (World.date():hours() > quest.expiration_date
                   and quest.state == "not_accepted")
            or quest.state == "finished"
         if do_generate then
            if not Rand.one_in(3) then
               Quest.generate(client.uid, map)
            end
         end
      end
   end
end

function Quest.complete(quest, client)
   local reward_text = Quest.format_reward_text(quest)
   local next_node = "elona.quest_giver:complete_default"
   if reward_text and client then
      Gui.mes("quest.giver.complete.take_reward", reward_text, client)
   end

   Event.trigger("elona_sys.on_quest_completed", {quest=quest, client=client})

   quest.state = "finished"
   Gui.update_screen()

   Save.queue_autosave()

   return next_node
end

function Quest.fail(quest)
   quest.state = "failed"
   Gui.mes("quest.failed_taken_from", quest.client_name)
   Event.trigger("elona_sys.on_quest_failed", {quest=quest})

   local fame_delta = Effect.decrement_fame(Chara.player(), 40)
   Gui.mes_c("quest.lose_fame", "Red", fame_delta)

   table.iremove_value(save.elona_sys.quest.quests, quest)

   if save.elona_sys.immediate_quest_uid == quest.uid then
      save.elona_sys.immediate_quest_uid = nil
   end
end

local function calc_reward_gold(quest)
   -- >>>>>>>> shade2/quest.hsp:455 	p=qReward(rq)	 ..
   local quest_proto = data["elona_sys.quest"]:ensure(quest._id)
   local gold = quest.reward_gold

   if quest_proto.calc_reward_gold then
      gold = quest_proto.calc_reward_gold(quest, gold)
   end

   return math.floor(gold)
   -- <<<<<<<< shade2/quest.hsp:456 	if qExist(rq)=qHarvest:if qParam1(rq)!0:if qParam ..
end

local function calc_reward_platinum(quest)
-- >>>>>>>> shade2/quest.hsp:458 	if qExist(rq)=qDeliver : p=rnd(2)+1:else:p=1 ..
   local quest_proto = data["elona_sys.quest"]:ensure(quest._id)
   local platinum = 1

   if quest_proto.calc_reward_platinum then
      platinum = quest_proto.calc_reward_platinum(quest, platinum)
   end

   return math.floor(platinum)
   -- <<<<<<<< shade2/quest.hsp:462 	flt:item_create -1,idPlat,cX(pc),cY(pc),p ..
end

local function calc_reward_item_count(quest)
   local quest_proto = data["elona_sys.quest"]:ensure(quest._id)
   local item_count = Rand.rnd(Rand.rnd(4) + 1) + 1

   if quest_proto.calc_reward_item_count then
      item_count = quest_proto.calc_reward_platinum(quest, item_count)
   end

   return item_count
end

--- @tparam table quest
--- @tparam[opt] uint gold
--- @tparam[opt] uint platinum
--- @tparam[opt] uint item_count
function Quest.create_rewards(quest, gold, platinum, item_count)
   -- >>>>>>>> shade2/quest.hsp:453 *quest_success ..
   local gold = gold or calc_reward_gold(quest)
   local platinum = platinum or calc_reward_platinum(quest)

   local player = Chara.player()
   local map = player:current_map()

   if gold > 0 then
      Item.create("elona.gold_piece", player.x, player.y, {amount=gold}, map)
   end
   if platinum > 0 then
      Item.create("elona.platinum_coin", player.x, player.y, {amount=platinum}, map)
   end

   if quest.reward then
      item_count = item_count or calc_reward_item_count(quest)

      for _=1, item_count do
         local reward_proto = data["elona_sys.quest_reward"]:ensure(quest.reward._id)
         local filter = reward_proto.generate(quest.reward, quest)
         Itemgen.create(player.x, player.y, filter, map)
      end
   end
   -- <<<<<<<< shade2/quest.hsp:491 	txtQuestItem ..
end

function Quest.set_immediate_quest(quest)
   assert(type(quest) == "table")
   assert(quest.state == "accepted")
   save.elona_sys.immediate_quest_uid = quest.uid
end

function Quest.set_immediate_quest_time_limit(quest, limit_mins)
   assert(type(quest) == "table")
   assert(save.elona_sys.immediate_quest_uid == quest.uid)
   save.elona_sys.quest_time_limit = math.max(limit_mins, 0)
   save.elona_sys.quest_time_limit_notice_interval = math.huge
end

function Quest.is_in_immediate_quest_map()
   local player = Chara.player()
   local map = player:current_map()
   return map:has_type("quest") and save.elona_sys.immediate_quest_uid
end

function Quest.is_immediate_quest_active()
   if not Quest.is_in_immediate_quest_map() then
      return false
   end

   local quest = Quest.get_immediate_quest()

   return quest and quest.state == "accepted"
end

function Quest.get_immediate_quest()
   local quest_uid = save.elona_sys.immediate_quest_uid
   local quest
   if quest_uid then
      quest = Quest.get(quest_uid)
   end
   return quest
end

function Quest.find_target_charas(quest, map)
   local proto = data["elona_sys.quest"]:ensure(quest._id)
   local targets = {}
   if proto.target_chara_uids then
      for _, uid in ipairs(proto.target_chara_uids(quest)) do
         local chara = map:get_object_of_type("base.chara", uid)
         if chara then
            targets[#targets+1] = chara
         end
      end
   end
   return targets
end

return Quest
