local Item = require("api.Item")
local utils = require("mod.test_room.data.map_archetype.utils")
local Chara = require("api.Chara")
local Hunger = require("mod.elona.api.Hunger")
local Rand = require("api.Rand")
local MapgenUtils = require("mod.elona.api.MapgenUtils")
local Map = require("api.Map")
local Enum = require("api.Enum")

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

function food.on_map_pass_turn(map)
   local player = Chara.player()
   for _, chara in player:iter_other_party_members() do
      if not Chara.is_alive(chara) then
         local x, y = Map.find_free_position(player.x, player.y, {only_map=true}, map)
         if x then
            chara:revive()
            chara:set_pos(x, y)
         end
      end
   end
   player.nutrition = 100000
end

function food.on_map_entered(map)
   if Chara.player():iter_other_party_members(map):all(function(i) return i._id ~= "elona.golden_knight" end) then
      for _ = 1, 14 do
         local knight = Chara.create("elona.golden_knight", nil, nil, {}, map)
         Chara.player():recruit_as_ally(knight)
         knight.nutrition = 0
      end
   end

   local starve = function(chara) chara.nutrition = 0 end
   for _, ally in Chara.iter_allies(map) do
      if not ally:is_player() then
         if not ally:has_event_handler("base.on_chara_turn_end", "set to starving each turn") then
            ally:connect_self("base.on_chara_turn_end", "set to starving each turn", starve)
         end
      end
   end
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

   for _, item in Item.iter(map) do
      item.curse_state = Enum.CurseState.Normal
   end

   MapgenUtils.spray_tile(map, "elona.dryground", 30)

   return map
end

return food
