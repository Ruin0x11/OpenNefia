local Chara = require("api.Chara")
local Calc = require("mod.elona.api.Calc")
local Item = require("api.Item")
local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Pos = require("api.Pos")
local Ui = require("api.Ui")
local Charagen = require("mod.tools.api.Charagen")
local Itemgen = require("mod.tools.api.Itemgen")
local Role = require("mod.elona_sys.api.Role")
local Filters = require("mod.elona.api.Filters")
local Quest = require("mod.elona_sys.api.Quest")
local I18N = require("api.I18N")
local Event = require("api.Event")
local Effect = require("mod.elona.api.Effect")

local fallbacks = {
   id = 0,
   difficulty = 0,
   client_chara_uid = 0,
   client_type = 0,
   progress = 0,
   expiration_hours = 0,
   reward_item = "",
}

local function make_quest_rewards(quest, gold, platinum, item_count)
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
         pause()
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

local function mkgenerate(categories)
   return function(self, quest)
      local quality = 2
      if Rand.one_in(2) then
         quality = 3
         if Rand.one_in(12) then
            quality = 4
         end
      end

      local category = Rand.choice(categories)

      return {
         level = math.floor(quest.difficulty + Chara.player():calc("level") / 2 + 1),
         quality = Calc.calc_object_quality(quality),
         categories = {category}
      }
   end
end

data:add {
   _id = "wear",
   _type = "elona_sys.quest_reward",
   elona_id = 1,
   generate = mkgenerate(Filters.fsetwear)
}

data:add {
   _id = "magic",
   _type = "elona_sys.quest_reward",
   elona_id = 2,
   generate = mkgenerate(Filters.fsetmagic)
}

data:add {
   _id = "armor",
   _type = "elona_sys.quest_reward",
   elona_id = 3,
   generate = mkgenerate(Filters.fsetarmor)
}

data:add {
   _id = "weapon",
   _type = "elona_sys.quest_reward",
   elona_id = 4,
   generate = mkgenerate(Filters.fsetweapon)
}

data:add {
   _id = "supply",
   _type = "elona_sys.quest_reward",
   elona_id = 5,
   generate = mkgenerate(Filters.fsetrewardsupply)
}

data:add {
   _id = "by_category",
   _type = "elona_sys.quest_reward",
   params = { category = "string" },
   generate = function(self, quest)
      return mkgenerate({self.category})(self, quest)
   end,

   localize = function(self)
      return I18N.get("item.filter_name." .. self.category)
   end
}

local collect = {
   _id = "collect",
   _type = "elona_sys.quest",

   elona_id = 1011,
   ordering = 10000,
   client_chara_type = 3,
   reward = "elona.supply",
   reward_fix = 60,

   min_fame = 0,
   chance = 14,

   params = {
      target_chara_uid = "number",
      target_name = "string",
      target_item_id = "string"
   },

   difficulty = function()
      return Chara.player():calc("level") / 3
   end,

   deadline_days = function() return Rand.rnd(3) + 2 end,

   generate = function(self, client, start, map)
      local target_chara, target_item

      local charas = Rand.shuffle(map:iter_charas():to_list())

      for _, chara in ipairs(charas)  do
         if chara.uid ~= client.uid then
            if Chara.is_alive(chara, map)
               and chara:reaction_towards(Chara.player(), "original") > 0
               and not Role.has(chara, "elona.guard")
               and not Role.has(chara, "elona.non_quest_target")
            then
               local item = Itemgen.create(nil, nil, { level = 40, quality = 2, categories = Filters.fsetcollect }, chara)
               if item then
                  item.count = 0 -- TODO
                  target_chara = chara
                  target_item = item
                  break
               end
            end
         end
      end

      if not target_chara then
         return false, "No target character found."
      end

      self.params = {
         target_chara_uid = target_chara.uid,
         target_name = target_chara.name,
         target_item_id = target_item._id
      }

      return true
   end,
   locale_data = function(self)
      return {
         item_name = I18N.get("item." .. self.params.target_item_id .. ".name"),
         target_name = self.params.target_name
      }
   end
}
data:add(collect)

local function round_margin(a, b)
   if a > b then
      return a - Rand.rnd(a - b)
   elseif a < b then
      return a + Rand.rnd(b - a)
   else
      return a
   end
end

local function hunt_enemy_id(difficulty, min_level)
   local id

   for _ = 1, 50 do
      local chara = Charagen.create(nil, nil, { level = difficulty, quality = 2, ownerless = true })
      id = chara._id
      if not chara.is_shade and chara.level >= min_level then
         break
      end
   end

   return id
end

local huntex = {
   _id = "huntex",
   _type = "elona_sys.quest",

   elona_id = 1010,
   ordering = 20000,
   client_chara_type = 1,
   reward = "elona.supply",
   reward_fix = 140,

   min_fame = 30000,
   chance = 13,

   params = { enemy_id = "string" },

   reward_count = function() return Rand.rnd(Rand.rnd(4) + 1) + 3 end,

   difficulty = function()
      local difficulty = Rand.rnd(Chara.player():calc("level") + 10) + Rand.rnd(Chara.player():calc("fame") / 2500 + 1)
      difficulty = round_margin(difficulty, Chara.player():calc("level"))
      return difficulty
   end,

   expiration_hours = function() return (Rand.rnd(6) + 2) * 24 end,

   generate = function(self, client)
      local min_level = math.clamp(math.floor(self.difficulty / 7), 5, 30)
      local enemy_id = hunt_enemy_id(self.difficulty, min_level)

      self.params = {
         enemy_id = enemy_id,
         enemy_level = math.floor(self.difficulty * 3 / 2)
      }

      return true
   end,
   locale_data = function(self)
      return { objective = self.params.enemy_id, enemy_level = self.params.enemy_level }
   end
}
data:add(huntex)

local conquer = {
   _id = "conquer",
   _type = "elona_sys.quest",

   elona_id = 1008,
   ordering = 30000,
   client_chara_type = 8,
   reward = "elona.wear",
   reward_fix = 175,

   min_fame = 50000,
   chance = 20,

   params = { enemy_id = "string" },

   reward_count = function() return Rand.rnd(Rand.rnd(4) + 1) + 3 end,

   difficulty = function()
      local difficulty = Rand.rnd(Chara.player():calc("level") + 10) + Rand.rnd(Chara.player():calc("fame") / 2500 + 1)
      difficulty = round_margin(difficulty, Chara.player():calc("level"))
      return difficulty
   end,

   expiration_hours = function() return (Rand.rnd(6) + 2) * 24 end,

   generate = function(self, client)
      local min_level = math.clamp(math.floor(self.difficulty / 4), 5, 30)
      local enemy_id = hunt_enemy_id(self.difficulty, min_level)

      self.params = {
         enemy_id = enemy_id,
         enemy_level = math.floor(self.difficulty * 10 / 8)
      }

      return true
   end,
   locale_data = function(self)
      return { objective = self.params.enemy_id, enemy_level = self.params.enemy_level }
   end
}
data:add(conquer)

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

   params = { escort_difficulty = "number", destination_map_uid = "number" },

   difficulty = 0,

   expiration_hours = function() return (Rand.rnd(6) + 2) * 24 end,

   generate = function(self, client, start)
      local dest = Rand.choice(Quest.iter_towns():filter(function(t) return t.uid ~= start.uid end))
      if not dest then
         return false, "No destinations to escort to."
      end

      local escort_difficulty = Rand.rnd(3)
      local dist = Pos.dist(start.world_map_x, start.world_map_y, dest.world_map_x, dest.world_map_y)

      if escort_difficulty == 0 then
         self.reward_fix = 140 + dist * 2
         self.deadline_days = Rand.rnd(8) + 6
         self.difficulty = math.clamp(Rand.rnd(Chara.player():calc("level") + 10)
                                         + Rand.rnd(Chara.player():calc("fame") / 500 + 1)
                                         + 1,
                                      1, 80)
      elseif escort_difficulty == 1 then
         self.reward_fix = 130 + dist * 2
         self.deadline_days = Rand.rnd(5) + 2
         self.difficulty = math.clamp(math.floor(self.reward_fix / 10 + 1), 1, 40)
      elseif escort_difficulty == 2 then
         self.reward_fix = 80 + dist * 2
         self.deadline_days = Rand.rnd(8) + 6
         self.difficulty = math.clamp(math.floor(self.reward_fix / 20) + 1, 1, 40)
      end

      if start.gen_id == "elona.noyel" or dest.gen_id == "elona.noyel" then
         self.reward_fix = math.floor(self.reward_fix * 180 / 100)
      end

      self.params = {
         escort_difficulty = escort_difficulty,
         destination_map_uid = dest.uid,
         destination_map_name = dest.name
      }

      return true
   end,
   locale_data = function(self)
      return { map = self.params.destination_map_name, }, "difficulty._" .. self.params.escort_difficulty
   end
}
data:add(escort)

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
      if town.gen_id == "elona.palmia" then
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

   generate = function(self, client)
      self.params = {
         required_points = self.difficulty * 10 + Rand.rnd(50)
      }

      return true
   end,
   locale_data = function(self)
      return { required_points = self.params.required_points }
   end
}
data:add(party)

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
      if town.gen_id == "elona.yowyn" then
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
         objective = objective
      }
   end
}
data:add(harvest)

local hunt = {
   _id = "hunt",
   _type = "elona_sys.quest",

   elona_id = 1001,
   ordering = 70000,
   client_chara_type = 1,
   reward = "elona.wear",
   reward_fix = 135,

   min_fame = 0,
   chance = 8,

   params = {},

   difficulty = function()
      local difficulty =  math.clamp(Rand.rnd(Chara.player():calc("level") + 10) +
                                        Rand.rnd(Chara.player():calc("fame") / 500 + 1) + 1,
                                     1, 80)
      return round_margin(difficulty, Chara.player():calc("level"))
   end,

   expiration_hours = function() return (Rand.rnd(6) + 2) * 24 end,
   deadline_days = nil,

   generate = function(self, client)
      return true
   end
}
data:add(hunt)

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

   expiration_hours = function() return (Rand.rnd(6) + 2) * 24 end,

   generate = function(self, client, start)
      local cur_uid = client.originating_map_uid

      local pred = function(client)
         -- Only consider clients outside this map (doesn't make sense to
         -- deliver within the same one)
         if client.originating_map_uid == cur_uid then
            return false
         end

         -- Find a random incomplete quest with a client who is not also
         -- the target of another delivery quest.
         local has_quest = function(q) return q._id == "elona.deliver" and q.params.target_chara_uid == client.uid end
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
   end,
   locale_data = function(self)
      local params = {
         item_category = self.params.item_category,
         item_name = I18N.get("item." .. self.params.item_id .. ".name"),
         target_name = self.params.target_name,
         map = self.params.target_map_name
      }
      local key = self.params.item_category
      return params, key
   end,
   on_accept = function(self)
      local player = Chara.player()
      local item = Item.create(self.params.item_id, player.x, player.y, {ownerless=true})
      if not player:can_take_object(item) then
         return false, "elona.quest_deliver:backpack_full"
      end

      player:take_object(item)
      Gui.mes("common.you_put_in_your_backpack", item)
      Gui.play_sound("base.inv")

      return true, "elona.quest_deliver:accept"
   end,
   on_complete = function(self, client, text)
      local platinum = Rand.rnd(2) + 1
      make_quest_rewards(self, nil, platinum)
      client.is_quest_delivery_target = nil
   end
}
data:add(deliver)

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

Event.register("base.on_map_enter", "Mark quest delivery targets",
               function(map)
                  local charas_with_delivery = Quest.iter_accepted()
                      :filter(function(q) return q.params.target_map_uid == map.uid and q._id == "elona.deliver" end)
                      :map(function(q) return q.params.target_chara_uid, q.params.item_id end):to_map()

                  for _, chara in map:iter_charas() do
                     chara.is_quest_delivery_target = charas_with_delivery[chara.uid]
                  end
               end)

Event.register("elona.calc_dialog_choices", "Add quest delivery choice",
               function(speaker, params, result)
                  if speaker.is_quest_delivery_target then
                     local item = find_delivery_item(speaker)
                     if item then
                        table.insert(result, {"elona.quest_deliver:finish", "talk.npc.quest_giver.choices.here_is_delivery"})
                     end
                  end

                  return result
               end)

local cook = {
   _id = "cook",
   _type = "elona_sys.quest",

   elona_id = 1003,
   ordering = 90000,
   client_chara_type = 3,
   reward = "elona.supply",
   reward_fix = 60,

   min_fame = 0,
   chance = 6,

   params = {
      food_type = "number",
      food_quality = "number"
   },

   difficulty = 0,

   expiration_hours = function() return (Rand.rnd(3) + 1) * 24 end,
   deadline_days = function() return Rand.rnd(6) + 2 end,

   generate = function(self, client, start)
      local food_type = Rand.rnd(8) + 1

      local category

      if food_type == 4 then
         category = "elona.drink"
      elseif food_type == 6 then
         category = "elona.equip_ammo"
      elseif food_type == 1 then
         category = "elona.equip_ammo"
      elseif food_type == 5 then
         category = "elona.drink"
      elseif food_type == 7 then
         category = "elona.ore"
      elseif food_type == 2 then
         category = "elona.rod"
      elseif food_type == 3 then
         category = "elona.scroll"
      end

      if category then
         self.reward = { _id = "elona.by_category", category = category }
      else
         self.reward = { _id = "elona.supply" }
      end

      local food_quality = Rand.rnd(7) + 3
      self.difficulty = food_quality * 3
      self.reward_fix = 60 + self.difficulty

      self.params = {
         food_type = food_type,
         food_quality = food_quality
      }

      return true
   end,

   locale_data = function(self)
      local ingredient = "food.names._" .. self.params.food_type .. ".default_origin"
      local objective = I18N.get("food.names._" .. self.params.food_type .. "._" .. self.params.food_quality, ingredient)
      local params = { objective = objective }
      local key = "food_type._" .. self.params.food_type
      return params, key
   end
}
data:add(cook)

local supply = {
   _id = "supply",
   _type = "elona_sys.quest",

   elona_id = 1004,
   ordering = 100000,
   client_chara_type = 3,
   reward = "elona.supply",
   reward_fix = 65,

   min_fame = 0,
   chance = 5,

   params = {
      target_item_id = "string"
   },

   difficulty = function() return math.clamp(Rand.rnd(Chara.player():calc("level") + 5) + 1, 1, 30) end,

   expiration_hours = function() return (Rand.rnd(3) + 1) * 24 end,
   deadline_days = function() return Rand.rnd(6) + 2 end,

   generate = function(self, client, start)
      local category = Rand.choice(Filters.fsetsupply)
      local item_id = Itemgen.random_item_id_raw(nil, {category})
      assert(item_id)

      self.reward_fix = self.reward_fix + self.difficulty

      self.params = {
         target_item_id = item_id,
      }

      return true
   end,
   locale_data = function(self)
      return {
         objective = I18N.get("item." .. self.params.target_item_id .. ".name"),
      }
   end
}
data:add(supply)
