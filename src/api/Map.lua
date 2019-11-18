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

function Map.set_map(map)
   map:emit("base.on_map_enter")
   field:set_map(map)
   return field.map
end

function Map.save(map)
   class.assert_is_an(InstancedMap, map)
   local path = Fs.join("map", tostring(map.uid))
   Log.info("Saving map %d to %s", map.uid, path)
   return SaveFs.write(path, map)
end

Event.register("base.on_map_loaded", "apply template options",
               function(_, params)
                  if params.map.generated_with then
                     local generator = data["base.map_generator"][params.map.generated_with.generator]
                     if generator and generator.load then
                        generator.load(params.map, params.map.generated_with.params)
                     end
                  end
end)

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

function Map.generate(generator_id, params, opts)
   params = params or {}

   opts = opts or {}
   opts.outer_map = opts.outer_map or Map.current()

   if not opts.no_generate_area and not opts.area then
      local area_uid
      if type(params.area_params) == "number" then
         area_uid = params.area_params
         opts.area = save.base.area_mapping:get_data_of_area(area_uid).data
         Log.warn("Reusing area for map: %s", inspect(opts.area))
      else
         area_uid = save.base.area_mapping:generate_area()

         opts.area = save.base.area_mapping:get_data_of_area(area_uid).data
         table.merge_missing(opts.area, params.area_params)
         Log.warn("Generating new area for map: %s", inspect(opts.area))
      end
   end

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

   Map.refresh(map)

   return success, map
end

function Map.refresh(map)
   local Chara = require("api.Chara")
   if map:calc("has_anchored_npcs") then
      for _, chara in Chara.iter_others() do
         chara.initial_x = chara.x
         chara.initial_y = chara.y
      end
   end
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
   local Chara = require("api.Chara")
   return Map.can_access(x, y, map)
end

function Map.find_free_position(x, y, params, map)
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

local function failed_to_place(chara)
   assert(not chara:is_player())

   if chara:is_ally() then
      chara.state = "OtherMap"
      Gui.mes("chara.place_failure.ally", chara)
   else
      chara.state = "Dead"
      Gui.mes("chara.place_failure.other", chara)
   end
   if chara.role ~= nil then
      chara.state = "CitizenDead"
   end

   chara:emit("base.on_chara_place_failure")
end

function Map.try_place_chara(chara, x, y, map)
   local scope = "npc"
   if chara:is_in_party() then
      scope = "ally"
   end
   if chara:is_player() then
      scope = "player"
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

      return map:take_object(chara, real_x, real_y)
   end

   failed_to_place(chara)
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
      -- Nothing to do.
      return
   end

   if params.start_x and params.start_y then
      x = params.start_x
      y = params.start_y
   else
      if type(map.player_start_pos) == "table" then
         x = map.player_start_pos.x or x
         y = map.player_start_pos.y or y
      elseif type(map.player_start_pos) == "function" then
         x, y = map.player_start_pos(Chara.player(), map, current)
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

   Map.set_map(map)
   Gui.update_screen()

   return true
end

-- TODO: way of accessing map variables without exposing internals

return Map
