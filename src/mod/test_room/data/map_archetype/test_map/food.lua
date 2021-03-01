local Item = require("api.Item")
local utils = require("mod.test_room.data.map_archetype.utils")
local Chara = require("api.Chara")
local Hunger = require("mod.elona.api.Hunger")
local Rand = require("api.Rand")

local food = {
   _id = "food"
}

local function create_dishes(x, y, map)
   local j = 0
   for _, _id in data["elona.food_type"]:iter():extract("_id") do
      local filter = function(i)
         return i.params
            and i.params.food_type == _id
            and i.params.food_quality == nil
      end
      local item_proto = data["base.item"]:iter():filter(filter):nth(1)
      if item_proto then
         for i = 0, 9 do
            local item = Item.create(item_proto._id, x + i, y + j, {amount = 3}, map)
            if item then
               Hunger.make_dish(item, i)
            end
         end
      end
      j = j + 1
   end

   return x, y + 9
end

local function create_corpses(x, y, width, map)
   local filter = function(c)
      return c.on_eat_corpse
   end

   local create = function(c)
      local item = Item.create("elona.corpse", nil, nil, {amount=3}, map)
      item.params.chara_id = c._id
      Hunger.make_dish(item, Rand.rnd(5) + 2)
      return item
   end
   local sort = function(a, b)
      return (a.proto.elona_id or 0) < (b.proto.elona_id or 0)
   end

   local items = data["base.chara"]:iter():filter(filter):map(create):to_list()
   table.sort(items, sort)

   return utils.roundup(items, x, y, width)
end

local function create_on_eat_foods(x, y, width, map)
   local filter = function(i)
      return i.on_eat
   end

   local create = function(i)
      local item = Item.create(i._id, nil, nil, {amount=3}, map)
      return item
   end
   local sort = function(a, b)
      return (a.proto.elona_id or 0) < (b.proto.elona_id or 0)
   end

   local items = data["base.item"]:iter():filter(filter):map(create):to_list()
   table.sort(items, sort)

   return utils.roundup(items, x, y, width)
end

function food.on_generate_map(area, floor)
   local map = utils.create_map(20, 30)
   utils.create_stairs(2, 2, area, map)

   local x = 2
   local y = 4

   x, y = create_dishes(x, y, map)

   local putitoro = Item.create("elona.putitoro", x, y, {amount=3}, map)
   if putitoro then
      putitoro.spoilage_date = -1
   end

   local corpse1 = Item.create("elona.corpse", x + 1, y, {amount=3}, map)
   if corpse1 then
      corpse1.params.chara_id = "elona.little_sister"
      corpse1.params.food_quality = 8
   end

   y = y + 2
   x, y = create_corpses(x, y, 20 - 4, map)

   y = y + 2
   x, y = create_on_eat_foods(x, y, 20 - 4, map)

   if Chara.player():iter_other_party_members():all(function(i) return i._id ~= "elona.cute_fairy" end) then
      local fairy = Chara.create("elona.cute_fairy", nil, nil, {}, map)
      Chara.player():recruit_as_ally(fairy)
      fairy.nutrition = 0
   end

   return map
end

return food
