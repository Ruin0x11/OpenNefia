local Chara = require("api.Chara")
local Calc = require("mod.elona.api.Calc")
local Rand = require("api.Rand")
local Pos = require("api.Pos")
local Log = require("api.Log")
local Ui = require("api.Ui")
local MapArea = require("api.MapArea")
local Charagen = require("mod.tools.api.Charagen")
local Itemgen = require("mod.tools.api.Itemgen")
local Role = require("mod.elona_sys.api.Role")
local Filters = require("mod.elona.api.Filters")
local Quest = require("mod.elona_sys.api.Quest")
local Map = require("api.Map")

local fallbacks = {
   id = 0,
   difficulty = 0,
   client_chara_uid = 0,
   client_type = 0,
   progress = 0,
   expiration_hours = 0,
   reward_item = "",
}

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
         level = math.floor(quest.difficulty - Chara.player():calc("level") / 2 + 1),
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

   locale_data = function(self)
      return I18N.get("item.filter_name." .. self.params.category)
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

   min_fame = 30000,
   chance = 13,

   params = { target_chara_uid = "number", target_item_id = "string" },

   difficulty = function()
      return Chara.player():calc("level") / 3
   end,

   deadline_days = function() return Rand.rnd(3) + 2 end,

   generate = function(self, client, map)
      local target_chara, target_item

      for _, chara in map:iter_charas()  do
         if chara.uid ~= client.uid then
            if Chara.is_alive(chara)
               and chara:reaction_towards(Chara.player(), "original") > 0
               and not Role.has(chara, "elona.guard")
               and not Role.has(chara, "elona.non_quest_target")
            then
               local item = Itemgen.create(nil, nil, { level = 40, quality = 2, categories = Filters.fsetcollect }, chara)
               if item then
                  -- item.count = 0
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
         target_item_id = target_item._id
      }

      return true
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

local hunt = {
   _id = "hunt",
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

      self.params = { enemy_id = enemy_id }

      return true
   end
}
data:add(hunt)

local hunt_ex = {
   _id = "hunt_ex",
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

      self.params = { enemy_id = enemy_id }

      return true
   end
}
data:add(hunt_ex)

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
         destination_map_uid = dest.uid
      }

      return true
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
      local ref = Ui.display_weight(self.params.required_weight)
      local objective = I18N.get("quest.info.harvest.text", ref)
      if is_active then
         objective = objective .. I18N.get("quest.info.now", Ui.display_weight(self.params.current_weight))
      end

      return {
         ref = ref,
         objective = objective
      }
   end
}
data:add(harvest)

local hunt2 = {
   _id = "hunt2",
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

   generate = function(self, client)
      self.params = {
         required_weight = 15000 + self.difficulty * 2500
      }

      return true
   end
}
data:add(hunt2)

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

      -- Only consider clients outside this map (doesn't make sense to
      -- deliver within the same one)
      local free_clients = Quest.iter_clients():filter(function(c) return c.originating_map_uid ~= cur_uid end)

      -- Find a random incomplete quest with a client who is not also
      -- the target of another delivery quest.
      local found_client
      for _, client in free_clients:unwrap() do
         if client.originating_map_uid ~= cur_uid then
            local exists = function(q) return q._id == "elona.deliver" and q.params.target_chara_uid == client.uid end
            local existing = Quest.iter():filter(exists):nth(1)
            if existing == nil then
               found_client = client
               break
            end
         end
      end

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
      elseif category == "category:elona.furniture" then
         self.reward = { _id = "elona.by_category", category = "elona.furniture" }
      end

      self.deadline_days = Rand.rnd(12) + 3
      self.difficulty = math.clamp(math.floor(self.reward_fix / 20 + 1), 1, 25)

      self.params = {
         target_map_uid = found_client.originating_map_uid,
         target_name = found_client.name,
         target_chara_uid = found_client.uid,
         item_category = category,
         item_id = item_id
      }

      return true
   end
}
data:add(deliver)

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

      self.reward = { _id = "elona.by_category", category = category }

      local food_quality = Rand.rnd(7) + 3
      self.difficulty = food_quality * 3
      self.reward_fix = 60 + self.difficulty

      self.params = {
         food_type = food_type,
         food_quality = food_quality
      }

      return true
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

      self.difficulty = food_quality * 3
      self.reward_fix = 60 + self.difficulty

      self.params = {
         food_type = food_type,
         food_quality = food_quality
      }

      return true
   end
}
data:add(cook)
