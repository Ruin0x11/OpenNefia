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
local Rand = require("api.Rand")
local Fs = require("api.Fs")
local SaveFs = require("api.SaveFs")
local World = require("api.World")
local I18N = require("api.I18N")
local save = require("internal.global.save")
local map_template = require("internal.map_template")
local Area = require("api.Area")
local InstancedArea = require("api.InstancedArea")
local Const = require("api.Const")

local Map = {}

--- Replaces the current map without running any cleanup events on the
--- previous map or moving the player over. This is low-level, and you
--- should probably use `Map.travel_to` instead.
---
--- @tparam InstancedMap map
--- @tparam string load_type One of "full" (default), "traveled", "initialize", "continue"
--- @see Map.travel_to
function Map.set_map(map, load_type)
   load_type = load_type or "full"
   assert(class.is_an(InstancedMap, map))
   if field.map == map then return end
   if field.map then
      Map.clear_debris(field.map)
   end
   if load_type ~= "traveled" then
      Gui.mes_clear()
   end
   map:emit("base.on_map_enter", {load_type=load_type})
   map.visit_times = map.visit_times + 1
   field:set_map(map)
   Gui.update_minimap()
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

   local ok, err = SaveFs.write(path, map)
   if not ok then
      return ok, err
   end

   if map.area_uid == nil then
      Log.warn("Autogenerating new area for map '%d'", map.uid)
      local area = InstancedArea:new()
      area:add_floor(map)
      Area.register(area)
   end

   return ok, err
end

function Map.is_saved(map_or_uid)
   local uid
   if class.is_an(InstancedMap, map_or_uid) then
      uid = map_or_uid.uid
   else
      uid = map_or_uid
   end
   assert(type(uid) == "number")
   local path = Fs.join("map", tostring(uid))
   return SaveFs.exists(path)
end

local function run_generator_load_callback(map)
   -- TODO: need a better way of determining this
   local is_templated_map = map.id and not string.match(map.id, "^_")
   if is_templated_map then
      Log.info("Binding events to map: %s", map.id)
      map_template.load(map)
   end
end

--- Loads a map from the current save. If you modify it be sure to
--- call `Map.save` to persist the changes if you don't set it as the
--- current map.
---
--- @tparam uid:InstancedMap|InstancedMap|string id
--- @treturn bool success
--- @treturn InstancedMap|string result/error
function Map.load(id)
   assert(id)
   local uid

   if type(id) == "number" then
      uid = id
   elseif type(id) == "string" then
      local store = save.base.map_registry

      if store[id] == nil then
         local template = data["base.map_template"]:ensure(id)
         if not template.unique then
            return false, ("Map template %s is not a unique map."):format(id)
         end

         local map = Map.generate2(id)

         Map.save(map)
         store[id] = map.uid
      end

      uid = store[id]
   end

   assert(type(uid) == "number")

   local path = Fs.join("map", tostring(uid))
   Log.debug("Loading map %d from %s", uid, path)
   local success, map = SaveFs.read(path)
   if not success then
      return false, map
   end

   -- This binds the events on the map.
   run_generator_load_callback(map)

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
   return (map or field.map):has_type("world_map")
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
--- In OpenNefia this is necessary since the blocked state of a tile
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

-- @tparam InstancedMap map
-- @tparam[opt] InstancedMap previous_map
-- @tparam[opt] IFeat feat
-- @tparam[opt] {x=uint,y=uint}|function start_pos
function Map.calc_start_position(map, previous_map, feat)
   local chara = Chara.player()
   local pos = map:emit("base.calc_map_starting_pos", { prev_map = previous_map, feat = feat, chara = chara }, { x = nil, y = nil })

   local x = pos.x
   local y = pos.y

   return x, y
end

function Map.generate2(map_template_id, opts)
   opts = opts or {}

   local map = map_template.generate(map_template_id, opts)

   map.id = map.id or ("_%d"):format(map.uid)
   map.name = map.name or I18N.get("map.unique." .. map.id .. ".name")

   return map
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
   -- >>>>>>>> shade2/item.hsp:565 	if (val=-1)&(mode!mode_shop){	;set location ..
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
            if Item.at(sx, sy, map):length() > 0 then
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
   -- <<<<<<<< shade2/item.hsp:593 		} ..
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
         if can_place_chara_at(x, y, map) then
            return x, y
         end
      end
   end

   return nil
end

local function failed_to_place(chara)
   assert(not chara:is_player())

   if chara:is_ally() then
      chara.state = "PetWait"
      Gui.mes("chara.place_failure.ally", chara)
   else
      chara.state = "Dead"
      Gui.mes("chara.place_failure.other", chara)
   end
   if next(chara.roles) then
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

local function rebuild_map(map, params)
   Log.info("Rebuilding map.")

   -- Regenerate the map with the same parameters.
   local new_map = Map.generate2(map.id)

   map:emit("base.on_map_rebuild", {new_map=new_map,travel_to_params=params})

   map:replace_with(new_map)
end

--- Cleans up the current map and moves the player and allies to a
--- different map. This is the recommended function to call to
--- transport the player to another map.
---
--- @tparam InstancedMap map
--- @tparam[opt] table params Extra parameters.
---   - feat (IFeat): feat used to travel to this map, like stairs.
---   - start_x (uint)
---   - start_y (uint)
function Map.travel_to(map, params)
   params = params or {}
   class.assert_is_an(InstancedMap, map)

   local current = field.map
   Log.debug("Traveling: %d -> %d", current.uid, map.uid)

   if map.visit_times > 0 and map.is_generated_every_time then
      rebuild_map(map, params)
   end

   if map.uid == current.uid then
      -- Nothing to do.
      return
   end

   local x, y
   if type(params.start_x) == "number" and type(params.start_y) == "number" then
      x = params.start_x
      y = params.start_y
   else
      x, y = Map.calc_start_position(map,
                                     current,
                                     params.feat)
   end

   Log.debug("Start position: %d %d (%s)", x, y)
   if not (x and y) then
      Log.error("Map does not declare a start position. Defaulting to the center of the map.")
      x = math.floor(map:width() / 2)
      y = math.floor(map:height() / 2)
   end

   if map.area_uid == nil then
      Log.warn("Autogenerating new area for map '%d'", map.uid)
      local player = Chara.player()
      local area = InstancedArea:new()
      local floor = Area.floor_number(current)
      area.parent_x = player.x
      area.parent_y = player.y
      area.parent_floor = floor
      area:add_floor(map)
      Area.register(area, { parent = Area.for_map(current) })
   end

   -- >>>>>>>> shade2/map.hsp:1863 	randomize ..
   Rand.set_seed()

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

   local success = Map.try_place_chara(player, x, y, map)
   assert(success, "Could not place player in map")

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

   Gui.mes_clear()

   current:emit("base.on_map_leave", {next_map=map})
   -- <<<<<<<< shade2/map.hsp:1892 	loop ..

   if not current.is_temporary then
      Map.save(current)
   end

   Map.set_map(map, "traveled")
   Gui.update_screen()

   collectgarbage()

   return true
end

function Map.load_parent_map(map)
   local area = Area.for_map(map)
   local parent = Area.parent(map)
   if parent == nil then
      return nil
   end

   local floor = area.parent_floor or 1
   return parent:load_or_generate_floor(floor)
end

--- Finds the location of an entrance to this map in its containing world area.
---
--- NOTE: Currently the implementation assumes the map's area and parent area
--- both have area archetypes. This is to prevent having to load the entire
--- world map from disk just to know the position. This might have to be
--- redesigned later.
---
--- @tparam InstancedMap map
function Map.position_in_parent_map(map)
   local area = Area.for_map(map)
   local parent = Area.parent(map)
   if parent == nil then
      return nil, nil
   end

   -- Try seeing if there is a custom position set first.
   if area.parent_x and area.parent_y then
      return area.parent_x, area.parent_y
   end

   local floor = area.parent_floor or 1

   -- Look in the area's archetype definition for a child map.
   return parent:position_of_child(area, floor)
end

-- @tparam uint hour
-- @tparam InstancedMap[opt] map
function Map.calc_shadow(hour, map)
   map = map or field.map

   local shadow = {5, 5, 5}

   if map.is_indoor then
      return shadow
   end

   if hour >= 24 or (hour >= 0 and hour < 4) then
      shadow = {110, 90, 60}
   elseif hour >= 4 and hour < 10 then
      shadow = {
         70 - (hour - 3) * 10,
         80 - (hour - 3) * 12,
         60 - (hour - 3) * 10
      }
   elseif hour >= 10 and hour < 12 then
      shadow = {10, 10, 10}
   elseif hour >= 12 and hour < 17 then
      shadow = {0, 0, 0}
   elseif hour >= 17 and hour < 21 then
      shadow = {
         0 + (hour - 17) * 20,
         15 + (hour - 16) * 15,
         10 + (hour - 16) * 10
      }
   elseif hour >= 21 and hour < 24 then
      shadow = {
         80 + (hour - 21) * 10,
         70 + (hour - 21) * 10,
         40 + (hour - 21) * 5,
      }
   end

   -- TODO weather, noyel

   return shadow
end

function Map.spill_blood(x, y, amount, map)
   map = map or field.map

   local tx, ty

   for i = 1, amount do
      if i == 1 then
         tx = x
         ty = y
      else
         tx = x + Rand.rnd(2) - Rand.rnd(2)
         ty = y + Rand.rnd(2) - Rand.rnd(2)
      end

      if Map.is_in_bounds(tx, ty, map) and Map.is_floor(tx, ty, map) then
         local d = map.debris[ty*map._width+tx+1] or {}
         d.blood = math.min((d.blood or 0) + 1, 5)
         map.debris[ty*map._width+tx+1] = d
      end
   end
end

function Map.spill_fragments(x, y, amount, map)
   map = map or field.map

   local tx, ty

   for i = 1, amount do
      if i == 1 then
         tx = x
         ty = y
      else
         tx = x + Rand.rnd(2) - Rand.rnd(2)
         ty = y + Rand.rnd(2) - Rand.rnd(2)
      end

      if Map.is_in_bounds(tx, ty, map) and Map.is_floor(tx, ty, map) then
         local d = map.debris[ty*map._width+tx+1] or {}
         d.fragments = math.min((d.fragments or 0) + 1, 4)
         map.debris[ty*map._width+tx+1] = d
      end
   end
end

function Map.clear_debris(map)
   map = map or field.map
   map.debris = {}
end

function Map.max_chara_count(map)
   -- TODO implement artificial charcter count
   return Const.MAX_CHARAS_OTHER
end

return Map
