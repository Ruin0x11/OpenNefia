local field = require("game.field")
local data = require("internal.data")
local Event = require("api.Event")
local Log = require("api.Log")
local Gui = require("api.Gui")
local InstancedMap = require("api.InstancedMap")
local Rand = require("api.Rand")
local Fs = require("api.Fs")
local save = require("internal.global.save")
local SaveFs = require("api.SaveFs")

-- Concerns anything that has to do with map querying/manipulation.
-- @module Map
local Map = {}

function Map.set_map(map)
   field:set_map(map)
   return field.map
end

function Map.save(map)
   class.assert_is_an(InstancedMap, map)
   local path = Fs.join("map", tostring(map.uid))
   Log.info("Saving map %d to %s", map.uid, path)
   return SaveFs.write(path, map)
end

Event.register("base.on_map_loaded", "instantiate all map objects",
               function(_, params)
                  for _, v in params.map:iter() do
                     v:instantiate()
                  end
               end)

function Map.load(uid)
   if type(uid) == "table" and uid.uid then
      return uid
   end
   assert(type(uid) == "number")

   local path = Fs.join("map", tostring(uid))
   Log.info("Loading map %d from %s", uid, path)
   local success, map = SaveFs.read(path)
   if not success then
      return false, map
   end

   Event.trigger("base.on_map_loaded", {map=map})

   return success, map
end

function Map.edit(uid, cb)
   if Map.current().uid == uid then
      return false, "Map.edit should only be called for maps besides the currently loaded one"
   end

   local ok, map = Map.load(uid)
   if not ok then
      return false, map
   end

   local err
   ok, err = xpcall(function() return cb(map) end, debug.traceback)

   if not ok then
      return false, err
   end

   return Map.save(map)
end

function Map.is_world_map(map)
   return (map or field.map):calc("is_world_map")
end

function Map.current()
   return field.map
end

function Map.width(map)
   return (map or field.map):width()
end

function Map.height(map)
   return (map or field.map):height()
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
   return (map or field.map):set_tile(x, y, id)
end

function Map.iter_objects_at(x, y, map)
   return (map or field.map):iter_objects_at(x, y)
end

function Map.iter_charas(map)
   return (map or field.map):iter_charas()
end

function Map.iter_items(map)
   return (map or field.map):iter_items()
end

function Map.iter_feats(map)
   return (map or field.map):iter_feats()
end

--- Creates a new blank map.
function Map.create(width, height)
   return InstancedMap:new(width, height)
end

function Map.generate(generator_id, params)
   params = params or {}
   local opts = {}

   local generator = data["base.map_generator"]:ensure(generator_id)
   local success, map = xpcall(function() return generator:generate(params, opts) end, debug.traceback)
   if not success then
      return nil, map
   end
   if not class.is_an(InstancedMap, map) then
      return nil, "result of map_generator:generate must be a map"
   end

   map.generated_with = { generator = generator_id, params = params }

   Event.trigger("base.on_map_generated", {map=map})
   Event.trigger("base.on_map_loaded", {map=map})

   return success, map
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

function Map.free_position(x, y, params, map)
   params = params or {}
   map = map or Map.current()

   if x and Map.is_in_bounds(x, y, map) then
      return x, y
   end

   local tries = 0
   local sx, sy

   repeat
      local ok = true
      if not x then
         sx = Rand.rnd(map:width() - 2) + 2
         sy = Rand.rnd(map:height() - 2) + 2
         if not params.allow_stacking then
            local Item = require("api.Item")
            if Item.at(sx, sy):length() > 0 then
               ok = false
            end
         end
      else
         if tries == 0 then
            sx = x
            sy = y
         else
            sx = x + Rand.rnd(tries + 1) - Rand.rnd(tries + 1)
            sy = y + Rand.rnd(tries + 1) - Rand.rnd(tries + 1)
         end
      end

      if not Map.can_access(sx, sy, map) then
         ok = false
      end

      if ok then
         return sx, sy
      end

      tries = tries + 1
   until tries == 100

   return nil
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
   map = map or Map.current()
   x = x or Rand.rnd(map:width())
   y = y or Rand.rnd(map:height())

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

   for x=0,map:width()-1 do
      for y=0,map:height()-1 do
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
      real_x = Rand.rnd(map:width())
      real_y = Rand.rnd(map:height())

      Map.force_clear_pos(real_x, real_y, map)
   end

   if real_x ~= nil then
      assert(can_place_chara_at(real_x, real_y, map))

      return map:take_object(chara, real_x, real_y)
   end

   return nil
end

function Map.travel_to(map_or_uid, params)
   params = params or {}

   local Chara = require("api.Chara")

   local success, map
   if type(map_or_uid) == "number" then
      local uid = map_or_uid
      success, map = Map.load(uid)
      if not success then
         error(string.format("Error loading map %d: %s", uid, map))
      end
   else
      class.assert_is_an(InstancedMap, map_or_uid)
      map = map_or_uid
   end

   local current = field.map
   local x, y = 0, 0

   if map.uid == current.uid then
      error("Map cannot be the same as the one being traveled to.")
   end

   if params.start_x and params.start_y then
      x = params.start_x
      y = params.start_y
   else
      if type(map.player_start_pos) == "table" then
         x = map.player_start_pos.x or x
         y = map.player_start_pos.y or y
      elseif type(map.player_start_pos) == "function" then
         x, y = map.player_start_pos(Chara.player())
      end
   end

   -- take the player, allies and any items they carry.
   --
   -- TODO: map objects should be transferrable (moves maps with the
   -- player) and persistable (remains in the map even after it is
   -- deleted and the map is exited).
   local player = Chara.player()
   local allies = save.base.allies
   -- TODO: items

   -- Transfer each to the new map.

   success = try_place(player, x, y, current, map)
   assert(success)

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

   if not current.is_temporary then
      Map.save(current)
   end

   Map.set_map(map)
   Gui.update_screen()

   return true
end

-- TODO: way of accessing map variables without exposing internals

return Map
