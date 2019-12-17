--- @module Quest

local Role = require("mod.elona_sys.api.Role")
local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Map = require("api.Map")
local Log = require("api.Log")
local World = require("api.World")
local Item = require("api.Item")
local Itemgen = require("mod.tools.api.Itemgen")
local I18N = require("api.I18N")
local Event = require("api.Event")
local Gui = require("api.Gui")
local Effect = require("mod.elona.api.Effect")
local Calc = require("mod.elona.api.Calc")

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

   local town = save.elona_sys.quest.towns[client.originating_map_uid]
   assert(town)

   local quest = {
      _id = "",
      client_chara_type = 0,
      difficulty = 0,
      state = "not_accepted",
      expiration_date = 0,
      deadline_days = nil,
      reward = nil,
      reward_fix = 0,
      params = {}
   }

   local expiration_hours = (Rand.rnd(3) + 1) * 24
   local proto = data["elona_sys.quest"]:ensure(proto_id)

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

   if type(proto.expiration_hours) == "function" then
      expiration_hours = proto.expiration_hours(quest, client, town)
   else
      expiration_hours = proto.expiration_hours
   end

   if proto.generate then
      local success = proto.generate(quest, client, town, map)
      if not success then
         Log.debug("Quest generation did not succeed.")
         return nil, "Quest generation did not succeed."
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
   quest._id = proto._id
   quest.map_name = town.name

   Log.debug("Successfully generated quest: %s", inspect(quest))

   table.insert(save.elona_sys.quest.quests, quest)

   return quest, nil
end

local function get_reward_text(quest)
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

function Quest.get_locale_params(quest, is_active)
   local proto = data["elona_sys.quest"]:ensure(quest._id)
   local params = {}

   params.map = quest.map_name

   local reward = get_reward_text(quest)
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

function Quest.get_name_and_desc(quest, speaker, is_active)
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

--- Registers this character as a quest client. The following
--- conditions must be satisfied:
---
--- - You must be able to talk to the character.
--- - The character must have at least one role.
--- - The character must not have the role "role.non_quest_client".
--- - The character must be on a map.
--- - The character's map must be registered as a town using
---   Quest.register_town().
--- - The character must not be currently giving a quest.
---
--- @tparam IChara chara
function Quest.register_client(chara)
   if chara == nil or chara.state == "Dead" then
      return nil, "Character is not alive."
   end
   if not chara.can_talk then
      return nil, "Cannot talk to character."
   end
   if next(chara.roles) == nil then
      return nil, "Character has no role."
   end
   if Role.has(chara, "elona.non_quest_client") then
      return nil, "Character is marked as being unable to be a quest client."
   end

   local map = chara:current_map()

   if map == nil then
      return nil, "Character is not on a map."
   end
   if not save.elona_sys.quest.towns[map.uid] then
      return nil, ("Map %d (%s) is not registered as a valid quest endpoint map. Use Quest.register_town() to register it as one.")
         :format(map.uid, map.gen_id)
   end

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
   local ok, world_map = Map.world_map_containing(map)
   if not ok then
      return nil, "Map must have containing world map"
   end

   local x, y = Map.position_in_world_map(map)
   assert(x)

   Log.debug("Register quest endpoint %d", map.uid)

   local town = {
      uid = map.uid,
      name = map.name,
      gen_id = map.gen_id,
      world_map_uid = world_map.uid,
      world_map_x = x,
      world_map_y = y,
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
   if map:has_type("town") and Map.world_map_containing(map) then
      Quest.register_town(map)
   end

   if Quest.town_info(map) then
      -- Register all characters that can be quest targets.
      for _, chara in Chara.iter_others(map) do
         if chara.quality < 6 and not Role.has(chara, "elona.unique_chara") then
            Quest.register_client(chara)
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
      for _, client in Quest.iter_clients() do
         local quest = Quest.for_client(client)
         local do_generate = quest == nil
            or (World.date():hours() > quest.expiration_date
                   and quest.state == "not_accepted")
         if do_generate then
            if not Rand.one_in(3) then
               if quest then
                  assert(table.iremove_value(save.elona_sys.quest.quests, quest))
               end
               Quest.generate(client.uid, map)
            end
         end
      end
   end
end

function Quest.complete(quest, client)
   local reward_text = get_reward_text(quest)
   local text = I18N.get("quest.giver.complete.done_well", client)
   if reward_text then
      Gui.mes("quest.giver.complete.take_reward", reward_text, client)
   end

   local proto = data["elona_sys.quest"]:ensure(quest._id)

   text = proto.on_complete(quest, client, text) or text

   Event.trigger("elona_sys.on_quest_completed", {quest=quest, client=client})

   table.iremove_value(save.elona_sys.quest.quests, quest)

   Gui.update_screen()

   return "elona.default:__start", {text}
end

--- @tparam table quest
--- @tparam[opt] uint gold
--- @tparam[opt] uint platinum
--- @tparam[opt] uint item_count
function Quest.create_rewards(quest, gold, platinum, item_count)
   gold = gold or quest.reward_gold
   platinum = platinum or 1

   local player = Chara.player()
   local map = player:current_map()

   if gold > 0 then
      Item.create("elona.gold_piece", player.x, player.y, {amount=gold}, map)
   end
   if platinum > 0 then
      Item.create("elona.platinum_coin", player.x, player.y, {amount=platinum}, map)
   end

   if quest.reward then
      item_count = item_count or Rand.rnd(Rand.rnd(4) + 1) + 1

      for _=1, item_count do
         local reward_proto = data["elona_sys.quest_reward"]:ensure(quest.reward._id)
         local filter = reward_proto.generate(quest.reward, quest)
         Itemgen.create(player.x, player.y, filter, map)
      end
   end

   Gui.play_sound("base.complete1")

   Effect.modify_karma(player, 1)

   local fame_gained = Calc.calc_fame_gained(player, quest.difficulty * 3 + 10)
   Gui.mes_c("quest.completed_taken_from", "Green", quest.client_name)
   Gui.mes_c("quest.gain_fame", "Green", fame_gained)
   player.fame = player.fame + fame_gained

   Gui.mes("common.something_is_put_on_the_ground")
end

return Quest
