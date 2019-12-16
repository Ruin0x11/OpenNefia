--- Functions for querying and manipulating maps.
---
--- As a convention, functions that take an optional `InstancedMap`
--- instance as a last argument can operate on the currently loaded
--- map by omitting this argument.
---
--- @module Map

local field = require("game.field")
local data = require("internal.data")
local Chara = require("api.Chara")
local Event = require("api.Event")
local Log = require("api.Log")
local Gui = require("api.Gui")
local InstancedMap = require("api.InstancedMap")
local IEventEmitter = require("api.IEventEmitter")
local Rand = require("api.Rand")
local Fs = require("api.Fs")
local save = require("internal.global.save")
local SaveFs = require("api.SaveFs")
local World = require("api.World")

local Map = {}

Event.register("base.on_map_enter", "reveal fog",
               function(map, params)
                  if map:has_type({"town", "world_map", "player_owned", "guild"}) then
                     map:mod("reveals_fog", true)
                  end
                  if map:calc("reveals_fog") then
                     for _, x, y in map:iter_tiles() do
                        map:reveal_tile(x, y)
                     end
                  end
end)

Event.register("base.on_map_leave", "call generator.on_enter",
               function(prev_map, params)
                  if params.next_map.generated_with then
                     local generator = data["base.map_generator"][params.next_map.generated_with.generator]
                     if generator and generator.on_enter then
                        generator.on_enter(params.next_map, params.next_map.generated_with.params, prev_map)
                     end
                  end
end)

Event.register("base.on_map_leave", "common events",
               function(prev_map, params)
                  if prev_map:has_type({"town", "guild"}) or prev_map:calc("is_travel_destination") then
                     save.base.departure_date = World.date_hours()
                  end
end)

--- Replaces the current map without running any cleanup events on the
--- previous map or moving the player over. This is low-level, and you
--- should probably use `Map.travel_to` instead.
---
--- @tparam InstancedMap map
--- @see Map.travel_to
function Map.set_map(map)
   map:emit("base.on_map_enter")
   map.visit_times = map.visit_times + 1
   field:set_map(map)
   Gui.mes_clear()
   return field.map
end

--- Saves the provided map to the current save. You must call this
--- function manually to preserve any changes to a loaded map if you
--- load a map but do not switch the current map to it.
---
--- @tparam InstancedMap map
--- @treturn bool success
--- @treturn ?string error
function Map.save(map)
   class.assert_is_an(InstancedMap, map)
   local path = Fs.join("map", tostring(map.uid))
   Log.debug("Saving map %d to %s", map.uid, path)
   return SaveFs.write(path, map)
end

local function run_generator_load_callback(map)
   if map.generated_with then
      local generator = data["base.map_generator"][map.generated_with.generator]
      if generator and generator.load then
         generator.load(map, map.generated_with.params)
      end
   end
end

--- Loads a map from the current save. If you modify it be sure to
--- call `Map.save` to persist the changes if you don't set it as the
--- current map.
---
--- @tparam uid:InstancedMap|InstancedMap uid
--- @treturn bool success
--- @treturn InstancedMap|string result/error
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

   -- Map events should be initialized here because they will not be
   -- serialized.
   run_generator_load_callback(map)

   if type(map.events) == "table" then
      Log.debug("Connecting %d events for map %d (%s)", #map.events, map.uid, map.gen_id)
      map:connect_self_multiple(map.events)
   end

   map:emit("base.on_map_loaded")

   return success, map
end

--- Loads a map from the current save, runs a callback on it, and
--- saves it.
---
--- @tparam uid:InstancedMap|InstancedMap uid
--- @tparam function cb
--- @treturn bool success
--- @treturn InstancedMap|string result/error
function Map.edit(uid, cb)
   if Map.current().uid == uid then
      return false, "Map.edit should only be called for maps besides the currently loaded one"
   end

   local ok, err = Map.load(uid)
   if not ok then
      return false, err
   end

   local map = err
   ok, err = xpcall(function() return cb(map) end, debug.traceback)

   if not ok then
      return false, err
   end

   return Map.save(map)
end

--- True if this map is an overworld like North Tyris.
---
--- @tparam[opt] InstancedMap map
--- @treturn bool
function Map.is_world_map(map)
   return (map or field.map):calc("is_world_map")
end

--- Returns the current map. This can only be nil if a game has not
--- been loaded yet (e.g. at the title screen).
---
--- @treturn[opt] InstancedMap
function Map.current()
   return field.map
end

--- @tparam[opt] InstancedMap map
--- @treturn int
function Map.width(map)
   return (map or field.map):width()
end

--- @tparam[opt] InstancedMap map
--- @treturn int
function Map.height(map)
   return (map or field.map):height()
end

--- Returns true if the point is in bounds of the map.
---
--- @tparam int x
--- @tparam int y
--- @tparam[opt] InstancedMap map
--- @treturn bool
function Map.is_in_bounds(x, y, map)
   return (map or field.map):is_in_bounds(x, y)
end

--- Returns true if there is an unblocked line of sight that is
--- completely within player-visible tiles between two points. This
--- includes tiles that are outside the game window.
---
--- @tparam int x1
--- @tparam int y1
--- @tparam int x2
--- @tparam int y2
--- @tparam[opt] InstancedMap map
--- @treturn bool
function Map.has_los(x1, y1, x2, y2, map)
   return (map or field.map):is_in_fov(x1, y1, x2, y2)
end

--- Returns true if the player can see a position on screen.
---
--- NOTE: This function returns false for any positions that are not
--- contained in the game window. This is the same behavior as
--- vanilla. For game calculations depending on LoS outside of the
--- game window, use Map.has_los combined with a maximum distance
--- check instead.
---
--- @tparam int x
--- @tparam int y
--- @tparam[opt] InstancedMap map
--- @treturn bool
function Map.is_in_fov(x, y, map)
   return (map or field.map):is_in_fov(x, y)
end

--- @tparam int x
--- @tparam int y
--- @tparam[opt] InstancedMap map
--- @treturn bool
function Map.is_floor(x, y, map)
   return (map or field.map):is_floor(x, y)
end

--- True if items can be dropped in this map (the maximum item count
--- of this map has not been exceeded). If false, it does not mean it
--- is not possible to create more items in the map from a technical
--- standpoint, only that the player should not be permitted to do so.
---
--- @tparam[opt] InstancedMap map
--- @treturn bool
function Map.can_drop_items(map)
   return true
end

--- True if a character can walk on top of the given position.
---
--- @tparam int x
--- @tparam int y
--- @tparam[opt] InstancedMap map
--- @treturn bool
function Map.can_access(x, y, map)
   map = map or field.map
   return Map.is_in_bounds(x, y, map)
      and Map.is_floor(x, y, map)
      and map:can_access(x, y)
end

--- Calculates access to a tile with respect to the objects on it.
--- Allows excluding an object, so you can for example calculate
--- access to tile ignoring a character on it.
---
--- In Elona_next this is necessary since the blocked state of a tile
--- is dependent on the "is_solid" flag of all the objects on it along
--- with the "is_solid" flag of the tile.
---
--- @tparam int x
--- @tparam int y
--- @tparam table params Extra parameters.
---  - exclude (IMapObject[opt]): An object to exclude from access
---    calculation.
--- @tparam[opt] InstancedMap map
--- @treturn bool
function Map.recalc_access(x, y, params, map)
   params = params or {}
   return Map.is_in_bounds(x, y, map)
      and map:recalc_access(x, y, params.exclude)
end

--- Gets the tile at a position for a map.
---
--- @tparam int x
--- @tparam int y
--- @tparam[opt] InstancedMap map
--- @treturn[opt] base.map_tile
function Map.tile(x, y, map)
   return (map or field.map):tile(x, y)
end

--- Returns the tile at a position for a map.
---
--- @tparam int x
--- @tparam int y
--- @tparam id:base.map_tile id
--- @tparam[opt] InstancedMap map
function Map.set_tile(x, y, id, map)
   (map or field.map):set_tile(x, y, id)
end

--- @tparam int x
--- @tparam int y
--- @tparam[opt] InstancedMap map
--- @treturn Iterator(IMapObject)
function Map.iter_objects_at(x, y, map)
   return (map or field.map):iter_objects_at(x, y)
end

-- @tparam IChara chara
-- @tparam[opt] InstancedMap previous_map
-- @tparam[opt] IFeat feat
-- @tparam[opt] InstancedMap map
function Map.calc_start_position(chara, previous_map, feat, map)
   map = map or field.map

   local x, y
   if type(map.player_start_pos) == "table" then
      x = map.player_start_pos.x
      y = map.player_start_pos.y
   elseif type(map.player_start_pos) == "function" then
      x, y = map:player_start_pos(chara, previous_map, feat)
   else
      error("invalid map start pos: " .. tostring(map.player_start_pos))
   end

   return x,y
end

--- Generates a new map using a map generator template.
---
--- @tparam id:base.map_generator generator_id ID of the generator to use.
--- @tparam[opt] table params Parameters to pass to the map generator.
--- @tparam[opt] table opts Extra options.
---   - outer_map (InstancedMap): Outer map to associate with the
---     newly created map.
---   - area_uid (InstancedMap): Area to associate with the newly
---     created map.
--- @treturn bool success
--- @treturn InstancedMap|string result/error
function Map.generate(generator_id, params, opts)
   params = params or {}

   opts = opts or {}
   opts.outer_map = opts.outer_map or Map.current()
   opts.area_uid = opts.area_uid or nil

   local generator = data["base.map_generator"]:ensure(generator_id)
   local success, map, id = xpcall(function() return generator:generate(params, opts) end, debug.traceback)
   if not success then
      return nil, map
   end
   local ok, err = class.is_an(InstancedMap, map)
   if not ok then
      return nil, ("result of map_generator:generate must be a map and string ID (%s)"):format(err)
   end
   if type(id) ~= "string" then
      return nil, ("map ID '%s' must be string (got: %s)"):format(tostring(id), type(id))
   end
   if string.find(id, "[^0-9a-zA-Z_.]") then
      return nil, ("map ID can only contain alphanumeric characters, underscore and period (got: %s)"):format(id)
   end

   map.gen_id = id
   map.generated_with = { generator = generator_id, params = params }
   Log.info("Generated new map %d (%s) from '%s'", map.uid, map.gen_id, generator_id)

   if type(map.events) == "table" then
      Log.debug("Connecting %d events for map %d (%s)", #map.events, map.uid, map.gen_id)
      map:connect_self_multiple(map.events)
   end

   map:emit("base.on_map_generated")

   run_generator_load_callback(map)
   map:emit("base.on_map_loaded")

   if not params.no_refresh then
      Map.refresh(map)
   end

   return success, map
end

local function relocate_chara(chara, map)
   local x, y
   for i=1, 1000 do
      if i <= 100 then
         x = chara.x + Rand.rnd(math.floor(i / 2) + 2) - Rand.rnd(math.floor(i / 2) + 2)
         y = chara.y + Rand.rnd(math.floor(i / 2) + 2) - Rand.rnd(math.floor(i / 2) + 2)
      else
         x = Rand.rnd(map:width())
         y = Rand.rnd(map:height())
      end

      if Map.can_access(x, y, map) then
         chara:set_pos(x, y)
         break
      end
   end
end

local function refresh_chara(chara, map)
   chara.was_passed_item = nil

   local is_initializing_economy = false
   if is_initializing_economy then
      -- TODO return if adventurer/ally
   end

   if chara.state == "CitizenDead" then
      if World.date_hours() >= chara.date_to_revive_on then
         chara:revive()
      else
         return
      end
   end

   local Chara = require("api.Chara")
   if not Chara.is_alive(chara, map) then
      return
   end

   chara:emit("base.on_chara_refresh_in_map")

   local can_access = Map.recalc_access(chara.x, chara.y, {exclude=chara}, map)

   if not can_access then
      relocate_chara(chara, map)
   end
end

local function regenerate_map(map)
   local Item = require("api.Item")
   local first_time = map.next_regenerate_date == 0

   Log.info("Regenerating map %d (%s)", map.uid, map.gen_id)

   if not first_time then
      for _, item in map:iter_items() do
         if map:has_type({"town", "guild"}) then
            -- Remove player-owned items on the ground.
            if not Item.is_alive(item) or item.own_state == "none" then
               item:remove_ownership()
            else
               item:emit("base.on_regenerate")
            end
         end
      end

      for _, chara in map:iter_charas() do
         chara:clear_status_effects()

         if Chara.is_alive(chara) and chara.is_temporary and Rand.one_in(2) then
            chara:remove_ownership()
         else
            chara:emit("base.on_regenerate")
         end
      end
   end

   if map.generated_with then
      local generator = data["base.map_generator"][map.generated_with.generator]
      if generator and generator.on_regenerate then
         generator.on_regenerate(map, map.generated_with.params)
      end
   end

   map.next_regenerate_date = World.date_hours() + 120
end

Event.register("base.on_regenerate_map", "regenerate map", regenerate_map)

function Map.refresh(map)
   Log.info("Refreshing map %d (%s)", map.uid, map.gen_id)

   if map.is_regenerated and World.date_hours() >= map.next_regenerate_date then
      map:emit("base.on_regenerate_map")
   end

   if not map.is_generated_every_time then
      map:emit("base.before_map_refresh")
      -- three_years_later
      -- update_adventureres

      for _, chara in Chara.iter(map) do
         refresh_chara(chara, map)
      end
   end

   return map, nil
end

--- Clears a position on a map so it can be accessable by a character.
---
--- @tparam int x
--- @tparam int y
--- @tparam[opt] InstancedMap map
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
   local Chara = require("api.Chara")
   return Map.can_access(x, y, map)
end

--- Finds a free position to place something on a map.
---
--- @tparam int x
--- @tparam int y
--- @tparam[opt] table params Extra parameters.
---  - allow_stacking (bool): If true, ignore items on the ground when
---    checking for tile openness.
---  - only_map (bool): ignore characters on tiles; only check for
---    walls/floors.
--- @tparam[opt] InstancedMap map
function Map.find_free_position(x, y, params, map)
   params = params or {}
   map = map or Map.current()

   local check_tile = Map.can_access
   if params.only_map then
      check_tile = Map.is_floor
   end

   if x and check_tile(x, y, map) then
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

      if not check_tile(sx, sy, map) then
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
-- @tparam[opt] string scope Determines how hard to try.
--  - "npc" - Find a random position nearby. Give up after 100 tries.
--            (default)
--  - "ally" - Same as "npc", but keep looking across the entire map
--             for an open space. Give up if not found.
-- @tparam[opt] InstancedMap map
-- @treturn ?int x position
-- @treturn ?int y position
function Map.find_position_for_chara(x, y, scope, map)
   map = map or Map.current()
   x = x or Rand.rnd(map:width() - 4) + 2
   y = y or Rand.rnd(map:height() - 4) + 2

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

   if scope ~= "ally" then
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

local function failed_to_place(chara)
   assert(not chara:is_player())

   if chara:is_ally() then
      chara.state = "OtherMap"
      Gui.mes("chara.place_failure.ally", chara)
   else
      chara.state = "Dead"
      Gui.mes("chara.place_failure.other", chara)
   end
   if chara.roles ~= nil then
      chara.state = "CitizenDead"
   end

   chara:emit("base.on_chara_place_failure")
end

--- Tries to place a character near a position, moving it somewhere
--- close if it isn't available.
---
--- @tparam IChara chara
--- @tparam int x
--- @tparam int y
--- @tparam[opt] InstancedMap map
function Map.try_place_chara(chara, x, y, map)
   local scope = "npc"
   if chara:is_allied() then
      scope = "ally"
   end

   local real_x, real_y = Map.find_position_for_chara(x, y, nil, map)

   if real_x == nil and chara:is_player() then
      real_x = Rand.rnd(map:width())
      real_y = Rand.rnd(map:height())

      Map.force_clear_pos(real_x, real_y, map)
   end

   if real_x ~= nil then
      assert(can_place_chara_at(real_x, real_y, map))

      chara.initial_x = real_x
      chara.initial_y = real_y

      local result = map:take_object(chara, real_x, real_y)
      if result then
         map:refresh_tile(real_x, real_y)
      end
      return result
   end

   failed_to_place(chara)
   return nil
end

--- Cleans up the current map and moves the player and allies to a
--- different map. This is the recommended function to call to
--- transport the player to another map.
---
--- @tparam InstancedMap|uid:InstancedMap map_or_uid
--- @tparam[opt] table params Extra parameters.
---   - start_x (int): starting X position in the new map.
---   - start_y (int): starting Y position in the new map.
---   - feat (IFeat): feat used to travel to this map, like stairs.
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
   Log.info("Traveling: %d -> %d", current.uid, map.uid)

   if map.visit_times > 0 and map.is_generated_every_time then
      Log.info("Rebuilding map.")
      -- Regenerate the map with the same parameters.
      assert(map.generated_with)
      local success, err = Map.generate(map.generated_with.generator, map.generated_with.params)
      if not success then
         error(err)
      end

      local new_map = err

      if map.generated_with then
         local generator = data["base.map_generator"][map.generated_with.generator]
         if generator and generator.on_rebuild then
            generator.on_rebuild(map, map.generated_with.params, new_map, params)
         end
      end

      new_map.uid = map.uid
      map = new_map
   end

   local x, y = 0, 0

   if map.uid == current.uid then
      -- Nothing to do.
      return
   end

   if params.start_x and params.start_y then
      x = params.start_x
      y = params.start_y
   else
      x, y = Map.calc_start_position(Chara.player(), current, params.feat, map)
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

   player:remove_activity()
   player:reset_ai()

   success = Map.try_place_chara(player, x, y, map)
   assert(success)

   for _, uid in ipairs(allies) do
      -- TODO: try to find a place to put the ally. If they can't fit,
      -- then delay adding them to the map until the player moves. If
      -- the player moves back before the allies have a chance to
      -- spawn, be sure they are still preserved.
      local ally = current:get_object_of_type("base.chara", uid)
      assert(ally ~= nil)

      ally:remove_activity()
      ally:reset_ai()

      local new_ally = Map.try_place_chara(ally, x, y, map)
      assert(new_ally ~= nil)
   end

   current:emit("base.on_map_leave", {next_map=map})

   if not current.is_temporary then
      Map.save(current)
   end

   Map.refresh(map)

   Map.set_map(map)
   Gui.update_screen()

   current = nil
   collectgarbage()

   return true
end

--- Returns the world map which is directly accessable by this map.
---
--- NOTE: This only works in maps on the overworld for now, not nested
--- dungeons.
---
--- @tparam[opt] InstancedMap map
--- @treturn[opt] InstancedMap
function Map.world_map_containing(map)
   map = map or Map.current()

   local area = save.base.area_mapping:area_for_map(map)
   if area == nil or area.outer_map_uid == nil then
      return nil, ("Map %d (%s) doesn't have an outer map in area: %s"):format(map.uid, map.gen_id, inspect(area))
   end

   return Map.load(area.outer_map_uid)
end

--- Finds the location of this map in its containing world map.
--- TODO: needs to support nested dungeons.
---  - A group of maps is contained in one area.
---  - The area has a containing world map.
--- @tparam InstancedMap map
function Map.position_in_world_map(map)
   map = map or Map.current()

   local area = save.base.area_mapping:area_for_map(map)
   if area == nil then
      return nil, nil
   end

   return area.x, area.y
end

return Map
