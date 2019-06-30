local field = require("game.field")
local data = require("internal.data")
local InstancedMap = require("api.InstancedMap")
local Rand = require("api.Rand")

-- Concerns anything that has to do with map querying/manipulation.
-- @module Map
local Map = {}

function Map.is_world_map(map)
   return fun.iter((map or field.map).types):index("base.world_map") ~= nil
end

function Map.current()
   return field.map
end

function Map.width(map)
   return (map or field.map).width
end

function Map.height(map)
   return (map or field.map).height
end

function Map.is_in_bounds(x, y, map)
   return (map or field.map):is_in_bounds(x, y)
end

function Map.has_los(x1, y1, x2, y2, map)
   return (map or field.map):is_in_fov(x1, y1, x2, y2)
end

function Map.is_in_fov(x, y, map)
   return (map or field.map):is_in_fov(x, y)
end

function Map.is_floor(x, y, map)
   return (map or field.map):can_access(x, y)
end

function Map.can_drop_items(map)
   return true
end

function Map.can_access(x, y, map)
   local Chara = require("api.Chara")
   return Map.is_in_bounds(x, y, map)
      and Map.is_floor(x, y, map)
      and Chara.at(x, y, map) == nil
end

function Map.tile(x, y, map)
   return (map or field.map):tile(x, y)
end

function Map.set_tile(x, y, id, map)
   local tile = data["base.map_tile"][id]
   if tile == nil then return end

   return (map or field.map):set_tile(x, y, tile)
end

function Map.iter_charas(map)
   return (map or field.map):iter_charas()
end

function Map.iter_items(map)
   return (map or field.map):iter_items()
end

--- Creates a new blank map.
function Map.create(width, height)
   return InstancedMap:new(width, height)
end

function Map.generate(generator_id, params)
   params = params or {}
   local generator = data["base.map_generator"]:ensure(generator_id)
   local success, result = pcall(function() return generator:generate(params) end)
   if not success then
      return nil, result
   end
   class.assert_is_an(InstancedMap, result)
   return result
end

function Map.force_clear_pos(x, y, map)
   local Chara = require("api.Chara")

   if not Map.is_floor(x, y, map) then
      map:set_tile(x, y, "base.floor")
   end

   local on_cell = Chara.at(x, y, map)
   if on_cell ~= nil then
      map:remove_object(on_cell)
   end

   -- TODO: on_force_clear_pos
end

local function can_place_chara_at(x, y, map)
   return Map.can_access(x, y, map)
end

--- Tries to find an open tile to place a character.
-- @tparam int x
-- @tparam int y
-- @tparam string scope Determines how hard to try.
--  - "npc" - Find a random position nearby. Give up after 100 tries.
--            (default)
--  - "ally" - Same as "npc", but keep looking across the entire map
--             for an open space. Give up if not found.
-- @treturn[1][1] int
-- @treturn[1][2] int
-- @treturn[2] nil
function Map.find_position_for_chara(x, y, scope, map)
   scope = scope or "npc"

   local tries = 0
   local cx, cy

   repeat
      cx = x + Rand.rnd(tries + 1) - Rand.rnd(tries + 1)
      cy = y + Rand.rnd(tries + 1) - Rand.rnd(tries + 1)
      if can_place_chara_at(cx, cy, map) then
         return cx, cy
      end
      tries = tries + 1
   until tries == 100

   if scope ~= "ally" and scope ~= "player" then
      return nil
   end

   for x=0,map.width-1 do
      for y=0,map.height-1 do
         if can_place_chara_at(chara, x, y, map) then
            return x, y
         end
      end
   end

   return nil
end

local function try_place(chara, x, y, current, map)
   local scope = "npc"
   if chara:is_in_party() then
      scope = "ally"
   end

   local real_x, real_y = Map.find_position_for_chara(x, y, scope, map)

   if real_x == nil and chara:is_player() then
      real_x = Rand.rnd(map.width)
      real_y = Rand.rnd(map.height)

      Map.force_clear_pos(real_x, real_y, map)
   end

   if real_x ~= nil then
      assert(can_place_chara_at(real_x, real_y, map))

      return map:take_object(chara, real_x, real_y)
   end

   return nil
end

function Map.travel_to(map)
   local current = field.map
   local x, y = 0, 0

   if type(map.player_start_pos) == "table" then
      x = map.player_start_pos.x or x
      y = map.player_start_pos.y or y
   elseif type(map.player_start_pos) == "function" then
      x, y = map.player_start_pos(field.player)
   end

   -- take the player, allies and any items they carry.
   --
   -- TODO: map objects should be transferrable (moves maps with the
   -- player) and persistable (remains in the map even after it is
   -- deleted and the map is exited).
   local player = field.player
   local allies = field.allies
   -- TODO: items

   -- Transfer each to the new map.

   field.player = try_place(field.player, x, y, current, map)
   assert(field.player ~= nil)

   for _, uid in ipairs(allies) do
      -- TODO: try to find a place to put the ally. If they can't fit,
      -- then delay adding them to the map until the player moves. If
      -- the player moves back before the allies have a chance to
      -- spawn, be sure they are still preserved.
      local ally = current:get_object_of_type("base.chara", uid)
      assert(ally ~= nil)

      local new_ally = try_place(ally, x, y, current, map)
      assert(new_ally ~= nil)
   end

   field:set_map(map)
   field:update_screen()

   return "turn_begin"
end

-- TODO: way of accessing map variables without exposing internals

return Map
