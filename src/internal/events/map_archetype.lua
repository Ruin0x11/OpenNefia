local Event = require("api.Event")

-- TODO
-- local function archetype_on_spawn_monster(map)
-- end

local function archetype_starting_pos(map, params, result)
   local archetype = map:archetype()
   if not (archetype and archetype.starting_pos) then
      return result
   end

   if type(archetype.starting_pos) == "table" then
      local pos = archetype.starting_pos
      assert(pos.x and pos.y, "`starting_pos` must declare `x` and `y` fields if table")
      return pos
   end

   local chara = params.chara
   local prev_map = params.prev_map
   local feat = params.feat
   return archetype.starting_pos(map, chara, prev_map, feat)
end

Event.register("base.calc_map_starting_pos", "Archetype callback (starting_pos)", archetype_starting_pos, {priority = 200000})

local function archetype_on_map_renew_minor(map, params)
   local archetype = map:archetype()
   if not (archetype and archetype.on_map_renew_minor) then
      return
   end

   archetype.on_map_renew_minor(map, params)
end

Event.register("base.on_map_renew_minor", "Archetype callback (on_map_renew_minor)", archetype_on_map_renew_minor, {priority = 200000})

local function archetype_on_map_renew_major(map, params)
   local archetype = map:archetype()
   if not (archetype and archetype.on_map_renew_major) then
      return
   end

   archetype.on_map_renew_major(map, params)
end

Event.register("base.on_map_renew_major", "Archetype callback (on_map_renew_major)", archetype_on_map_renew_major, {priority = 200000})

local function archetype_on_map_renew_geometry(map, params)
   local archetype = map:archetype()
   if not (archetype and archetype.on_map_renew_geometry) then
      return
   end

   archetype.on_map_renew_geometry(map, params)
end

Event.register("base.on_map_renew_geometry", "Archetype callback (on_map_renew_geometry)", archetype_on_map_renew_geometry, {priority = 200000})

local function archetype_on_map_loaded_events(map, params)
   local archetype = map:archetype()
   if not (archetype and archetype.on_map_loaded_events) then
      return
   end

   archetype.on_map_loaded_events(map, params)
end

Event.register("base.on_map_loaded_events", "Archetype callback (on_map_loaded_events)", archetype_on_map_loaded_events, {priority = 200000})

local function archetype_on_map_entered_events(map, params)
   local archetype = map:archetype()
   if not (archetype and archetype.on_map_entered_events) then
      return
   end

   archetype.on_map_entered_events(map, params)
end

Event.register("base.on_map_entered_events", "Archetype callback (on_map_entered_events)", archetype_on_map_entered_events, {priority = 200000})

local function archetype_on_map_pass_turn(chara, params, result)
   -- >>>>>>>> shade2/main.hsp:733  ..
   local map = chara:current_map()
   if not chara:is_player() or not map then
      return result
   end

   if params.is_first_turn then
      return result
   end

   local archetype = map:archetype()
   if not (archetype and archetype.on_map_pass_turn) then
      return
   end

   archetype.on_map_pass_turn(map, params)
   -- <<<<<<<< shade2/main.hsp:735 	 ..
end

Event.register("base.before_chara_turn_start", "Archetype callback (on_map_pass_turn)", archetype_on_map_pass_turn, {priority = 200000})
