local Rand = require("api.Rand")
local Quest = require("mod.elona_sys.api.Quest")
local Pos = require("api.Pos")
local Filters = require("mod.elona.api.Filters")
local Itemgen = require("mod.tools.api.Itemgen")
local I18N = require("api.I18N")
local Chara = require("api.Chara")
local Item = require("api.Item")
local Gui = require("api.Gui")
local Event = require("api.Event")

---
--- Data
---

local deliver = {
   _id = "deliver",
   _type = "elona_sys.quest",

   elona_id = 1002,
   ordering = 80000,
   client_chara_type = 2,
   reward = "elona.supply",
   reward_fix = 70,

   min_fame = 0,
   chance = 6,

   params = {
      target_map_uid = "number",
      target_chara_uid = "number",
      target_name = "string",
      item_category = "string",
      item_id = "string",
   },

   difficulty = 0,

   expiration_hours = function() return (Rand.rnd(6) + 2) * 24 end
}

function deliver.generate(self, client, start)
   local cur_uid = client.originating_map_uid

   local function pred(client)
      -- Only consider clients outside this map (doesn't make sense to
      -- deliver within the same one)
      if client.originating_map_uid == cur_uid then
         return false
      end

      -- Find a random incomplete quest with a client who is not also
      -- the target of another delivery quest.
      local function has_quest(q)
         return q._id == "elona.deliver" and q.params.target_chara_uid == client.uid
      end
      local existing_quest = Quest.iter():filter(has_quest):nth(1)
      return existing_quest == nil
   end

   local found_client = Rand.choice(Quest.iter_clients():filter(pred))

   if found_client == nil then
      return false, "No client to deliver to found."
   end

   local dest = Quest.town_info(found_client.originating_map_uid)

   self.reward_fix = 70 + Pos.dist(start.world_map_x, start.world_map_y, dest.world_map_x, dest.world_map_y) * 2

   if start.gen_id == "elona.noyel" or dest.gen_id == "elona.noyel" then
      self.reward_fix = math.floor(self.reward_fix * 175 / 100)
   end

   self.reward = "elona.supply"

   local category = Rand.choice(Filters.fsetdeliver)
   local item_id = Itemgen.random_item_id_raw(nil, {category})
   assert(item_id)

   if category == "elona.spellbook" then
      self.reward = "elona.magic"
   elseif category == "elona.ore" then
      self.reward = "elona.armor"
   elseif category == "elona.junk" then
      self.reward = { _id = "elona.by_category", category = "elona.ore" }
   elseif category == "elona.furniture" then
      self.reward = { _id = "elona.by_category", category = "elona.furniture" }
   end

   self.deadline_days = Rand.rnd(12) + 3
   self.difficulty = math.clamp(math.floor(self.reward_fix / 20 + 1), 1, 25)

   self.params = {
      target_map_uid = found_client.originating_map_uid,
      target_map_name = found_client.originating_map_name,
      target_name = found_client.name,
      target_chara_uid = found_client.uid,
      item_category = category,
      item_id = item_id
   }

   return true
end

function deliver.locale_data(self)
   local params = {
      item_category = self.params.item_category,
      item_name = I18N.get("item.info." .. self.params.item_id .. ".name"),
      target_name = self.params.target_name,
      map = self.params.target_map_name
   }
   local key = self.params.item_category
   return params, key
end

function deliver.on_accept(self)
   local player = Chara.player()
   local item = Item.create(self.params.item_id, player.x, player.y, {ownerless=true})
   if not player:can_take_object(item) then
      return false, "elona.quest_deliver:backpack_full"
   end

   player:take_object(item)
   Gui.mes("common.you_put_in_your_backpack", item)
   Gui.play_sound("base.inv")

   return true, "elona.quest_deliver:accept"
end

function deliver.on_complete(self, client, text)
   local platinum = Rand.rnd(2) + 1
   Quest.make_quest_rewards(self, nil, platinum)
   client.is_quest_delivery_target = nil
end

data:add(deliver)


---
--- Dialog
---

local function delivery_quest_for(chara)
   return Quest.iter_accepted()
      :filter(function(q)
            return q._id == "elona.deliver"
               and q.params.target_chara_uid == chara.uid
             end)
      :nth(1) -- There should only ever be a single one per character.
end

local function find_delivery_item(client)
   local item_id = client.is_quest_delivery_target
   local item = Chara.player():iter_inventory():filter(function(i) return i._id == item_id end):nth(1)
   return item
end

data:add {
   _type = "elona_sys.dialog",
   _id = "quest_deliver",

   root = "talk.npc.quest_giver",
   nodes = {
      backpack_full = {
         text = {
            {"about.backpack_full"}
         },
         choices = "elona.default:__start"
      },
      accept = {
         text = {
            {"about.here_is_package"}
         },
         choices = "elona.default:__start"
      },
      finish = function(t)
         local quest = delivery_quest_for(t.speaker)
         assert(quest)

         local item = find_delivery_item(t.speaker)

         Gui.mes("talk.npc.common.hand_over", item)
         local sep = assert(item:move_some(1, t.speaker))
         t.speaker.item_to_use = sep

         Chara.player():refresh_weight()

         return Quest.complete(quest, t.speaker)
      end
   }
}


---
--- Events
---

local function mark_delivery_targets(map)
   local charas_with_delivery = Quest.iter_accepted()
      :filter(function(q) return q.params.target_map_uid == map.uid and q._id == "elona.deliver" end)
      :map(function(q) return q.params.target_chara_uid, q.params.item_id end):to_map()

   for _, chara in map:iter_charas() do
      chara.is_quest_delivery_target = charas_with_delivery[chara.uid]
   end
end

Event.register("base.on_map_enter", "Mark quest delivery targets", mark_delivery_targets)

local function add_quest_delivery_choice(speaker, _, result)
   if speaker.is_quest_delivery_target then
      local item = find_delivery_item(speaker)
      if item then
         table.insert(result, {"elona.quest_deliver:finish", "talk.npc.quest_giver.choices.here_is_delivery"})
      end
   end

   return result
end

Event.register("elona.calc_dialog_choices", "Add quest delivery choice", add_quest_delivery_choice)
