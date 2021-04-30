local Log = require("api.Log")
local I18N = require("api.I18N")
local Nefia = require("mod.elona.api.Nefia")
local Chara = require("api.Chara")
local Rand = require("api.Rand")
local Area = require("api.Area")
local Gui = require("api.Gui")
local Map = require("api.Map")
local MapEntrance = require("mod.elona_sys.api.MapEntrance")
local ExHelp = require("mod.elona.api.ExHelp")
local NefiaCompletionDrawable = require("mod.elona.api.gui.NefiaCompletionDrawable")
local IFeatLockedHatch = require("mod.elona.api.aspect.feat.IFeatLockedHatch")
local InstancedMap = require("api.InstancedMap")
local InstancedArea = require("api.InstancedArea")

local function get_map_display_name(area, description)
   if area.metadata.is_hidden then
      return ""
   end

   local _id = area._archetype or "<no archetype>"

   local desc = I18N.get_optional("map.unique." .. _id .. ".desc")
   local name = area.name or I18N.get_optional("map.unique." .. _id .. ".name")
   if name == nil and desc then
      name = desc
   end

   if name == nil then
      name = area.name
   end

   if not description then
      return name
   end

   local text
   if Nefia.get_type(area) then
      text = I18N.get("map.you_see_an_entrance", name, Nefia.get_level(area))
   elseif desc then
      text = desc
   else
      text = I18N.get("map.you_see", name)
   end

   return text
end


local function entrance_in_parent_map(map, area, parent_area, chara, prev)
   local x, y, floor = parent_area:child_area_position(area)
   if x == nil or floor ~= parent_area:floor_of_map(map.uid) then
      return nil
   end

   local index = 0
   for i, c in Chara.iter_allies(prev) do
      if c.uid == chara.uid then
         index = i
         break
      end
   end

   return { x = x + Rand.rnd(math.floor(index / 5) + 1), y = y + Rand.rnd(math.floor(index / 5) + 1) }
end

-- This should take place before things like StayingCharas, which is
-- triggered in "base.on_map_leave".
local function rebuild_map(map, params)
   local map_uid = map.uid
   Log.warn("About to regenerate map %s. (is_generated_every_time == true)", map_uid)

   local area = Area.for_map(map)
   if area == nil then
      Log.error("Map must be in an area to regenerate it every time.")
      return false, nil
   end

   local floor = assert(area:floor_of_map(map_uid))

   local ok, new_map = area:generate_map_for_floor(floor)
   if not ok then
      local err = new_map
      Log.error("Could not generate map for %s, floor %s: %s", area, floor, err)
      return false, nil
   end

   new_map.uid = map_uid

   -- Update the area_uid on the new map.
   --
   -- This is only safe because we know the new map is supposed to have the same
   -- map UID as the old map, and because we're throwing away the old map
   -- entirely. Otherwise we'd have to load the old map from disk and make sure
   -- its area_uid property is updated.
   new_map.area_uid = area.uid

   Log.warn("Regenerated map %s.", map_uid)
   return true, new_map
end

local function get_travel_map(feat, area_uid, area_floor, prev_map, params)
   local area = Area.get(area_uid)

   local event_params = {
      area_uid = area_uid,
      area_floor = area_floor,
      prev_map = prev_map,
      prev_map_x = feat.x,
      prev_map_y = feat.y
   }
   local result = feat:emit("elona.on_travel_using_feat", event_params, { area = area, map = nil, travel_params = params })

   if result.area then
      assert(class.is_an(InstancedArea, result.area))
      area = result.area
   end

   if area == nil then
      Log.error("Missing area, requested area UID '%d'", area_uid)
      return nil
   end

   local map
   if result.map then
      assert(class.is_an(InstancedMap, result.map))
      map = result.map
   else
      local ok
      ok, map = area:load_or_generate_floor(area_floor)
      if not ok then
         local err = map
         if err == "no_archetype" then
            Log.error("Area does not specify an archetype, so there is no way to know what kind of map should be generated. Use InstancedArea:set_archetype(archetype_id) to set one.")
         else
            error(("Missing map with floor number '%d' in area '%d' (%s)"):format(area_floor, area.uid, err))
         end
         return nil
      end
   end

   if map.visit_times > 0 and map.is_generated_every_time then
      local ok, new_map = rebuild_map(map, params)
      if ok then
         map = new_map
      end
   end

   return area, map
end

local function travel(start_pos_fn, set_prev_map)
   return function(self, params)
      local chara = params.chara
      if not chara:is_player() then return end

      local result = self:emit("elona.before_travel_using_feat", {chara=chara}, { blocked = false, turn_result = nil })
      if result.blocked then
         return result.turn_result or "player_turn_query"
      end

      Gui.play_sound("base.exitmap1")

      local prev_map = self:current_map()
      local prev_area = Area.for_map(prev_map)
      local parent_area = Area.parent(prev_area)
      local start_x, start_y
      local area, map

      if self.params.area_uid then
         area, map = get_travel_map(self, self.params.area_uid, self.params.area_floor, prev_map, params)
         if area == nil and map == nil then
            return "player_turn_query"
         end

         local starting_pos
         local map_archetype = map:archetype()

         local function start_pos_or_archetype(map, chara, prev_map, self)
            local pos
            if start_pos_fn then
               pos = start_pos_fn(map, chara, prev_map, self)
               if pos == nil then
                  Log.debug("No stairs found in connecting map, attempting to use map archetype's starting position.")
                  if map_archetype and map_archetype.starting_pos then
                     pos = map_archetype.starting_pos(map, chara, prev_map, self)
                  end
               end
            elseif map_archetype and map_archetype.starting_pos then
               pos = map_archetype.starting_pos(map, chara, prev_map, self)
            end
            return pos
         end

         -- >>>>>>>> shade2/map.hsp:152 		if feat(1)=objDownstairs :msgTemp+=lang("階段を降りた。 ..
         if self.params.area_starting_x and self.params.area_starting_y then
            starting_pos = { x = self.params.area_starting_x, y = self.params.area_starting_y }
         else
            if area and area.uid ~= prev_area.uid then
               -- If the area we're trying to travel to is the parent of this area, then
               -- put the player directly on the area's entrance.
               if parent_area == area then
                  -- TODO allow configuring ally start positions in Map.travel_to() (mStartWorld)
                  starting_pos = entrance_in_parent_map(map, prev_area, parent_area, chara, prev_map)
                  if starting_pos == nil then
                     -- Assume there will be stairs in the connecting map, and if
                     -- not fall back to the archetype's declared map start
                     -- position.
                     Log.warn("Did not find entrance in parent map for map %s, parent %s.", map.uid, parent_area)
                     starting_pos = start_pos_or_archetype(map, chara, prev_map, self)
                  end
               else
                  -- We're going into a dungeon. Assume there's stairs there, and
                  -- if not fall back to the archetype.
                  starting_pos = start_pos_or_archetype(map, chara, prev_map, self)

                  if area and prev_area:has_child_area(area) then
                     -- `prev_area` contains the entrance to this area.
                     local floor = assert(Map.floor_number(prev_map))
                     prev_area:set_child_area_position(area, chara.x, chara.y, floor)
                  end
               end
            else
               starting_pos = start_pos_or_archetype(map, chara, prev_map, self)
            end
         end

         if starting_pos == nil then
            Log.error("Map does not declare a start position. Defaulting to the center of the map.")
            starting_pos = MapEntrance.center(map, chara, prev_map, self)
         end

         if starting_pos.x and starting_pos.y then
            start_x = starting_pos.x
            start_y = starting_pos.y
         end
         -- <<<<<<<< shade2/map.hsp:153 		if feat(1)=objUpstairs	 :msgTemp+=lang("階段を昇った。" ..
      else
         Log.error("This staircase (%s) doesn't have an area UID set.", self)
         return "player_turn_query"
      end

      local travel_params = {
         feat = self,
         start_x = start_x,
         start_y = start_y
      }

      -- If we're entering from the world map, set the previous map so we know
      -- where to go if exiting from the edge.
      if set_prev_map then
         map:set_previous_map_and_location(prev_map, self.x, self.y)
      end

      Map.travel_to(map, travel_params)

      return "player_turn_query"
   end
end

local function gen_stair(down)
   local field = (down and "on_descend") or "on_ascend"
   local id = (down and "stairs_down") or "stairs_up"
   local elona_id = (down and 11) or 10
   local image = (down and "elona.feat_stairs_down") or "elona.feat_stairs_up"
   local start_pos_fn = (down and MapEntrance.stairs_up) or MapEntrance.stairs_down
   local stepped_on_mes = (down and "action.move.feature.stair.down") or "action.move.feature.stair.up"

   return {
      _type = "base.feat",
      _id = id,
      elona_id = elona_id,

      image = image,
      is_solid = false,
      is_opaque = false,

      params = {
         area_uid = nil,
         area_floor = nil,
      },

      on_refresh = function(self)
         self:mod("can_activate", true)
      end,

      on_stepped_on = function(self, params)
         if params.chara:is_player() and self.params.area_uid then
            local area = Area.get(self.params.area_uid)
            if area then
               Gui.mes(stepped_on_mes)
            end
         end
      end,

      on_activate = travel(start_pos_fn),

      -- NOTE: assumes polymorphism between params of elona_sys.on_feat_activate
      -- and elona_sys.on_feat_ascend/elona_sys.on_feat_descend
      [field] = function(self, params)
         self.proto.on_activate(self, params)
      end
   }
end

data:add(gen_stair(true))
data:add(gen_stair(false))

data:add
{
   _type = "base.feat",
   _id = "map_entrance",
   elona_id = 15,

   image = "elona.feat_area_city",
   is_solid = false,
   is_opaque = false,

   params = {
      area_uid = nil,
      area_floor = nil,
   },

   on_refresh = function(self)
      self:mod("can_activate", true)
   end,

   on_activate = travel(nil, true),

   on_descend = function(self, params) self.proto.on_activate(self, params) end,

   on_stepped_on = function(self, params)
      if params.chara:is_player() and self.params.area_uid then
         local area = Area.get(self.params.area_uid)
         if area then
            -- >>>>>>>> shade2/action.hsp:758 			if feat(1)=objArea		:txt mapName(feat(2)+feat(3 ...
            if Nefia.get_type(area) then
               ExHelp.show("elona.nefia")
            end
            -- <<<<<<<< shade2/action.hsp:758 			if feat(1)=objArea		:txt mapName(feat(2)+feat(3 ..
            local name = get_map_display_name(area, true)
            if name and name ~= "" then
               Gui.mes(name)
            end
         end
      end
   end,

   events = {
      {
         id = "base.on_feat_make_target_text",
         name = "Target text",

         callback = function(self)
            -- >>>>>>>> shade2/command.hsp:49 		if mType=mTypeWorld{ ...
            local map = self:current_map()
            if not map:has_type("world_map") then
               return nil
            end

            local area = Area.get(self.params.area_uid)
            if area == nil or area._archetype == nil then
               return nil
            end

            return get_map_display_name(area, true)
            -- <<<<<<<< shade2/command.hsp:53 				} ..
         end
      },
      {
         id = "base.on_feat_instantiated",
         name = "Add nefia completion drawable and light",

         callback = function(self)
            if self.params.area_uid ~= nil then
               local area = Area.get(self.params.area_uid)
               if area and Nefia.get_type(area) then
                  local state
                  if area.deepest_floor_visited == area:deepest_floor() then
                     state = "conquered"
                  elseif area.deepest_floor_visited > 0 then
                     state = "in_progress"
                  end
                  self:set_drawable("elona.nefia_completion", NefiaCompletionDrawable:new(state), "above", 200000)
               else
                  self:set_drawable("elona.nefia_completion", nil)
               end

               -- >>>>>>>> shade2/map.hsp:2442 	if (areaType(cnt)=mTypeTown)or(areaType(cnt)=mTyp ...
               if area then
                  local has_light = area.metadata.has_light or area:has_type("town") or area:has_type("guild")

                  if has_light then
                     self.light = {
                        chip = "light_town_light",
                        bright = 140,
                        offset_y = 48 - 48,
                        power = 10,
                        flicker = 20,
                        always_on = false
                     }
                     self:refresh_cell_on_map()
                  end
               end
               -- <<<<<<<< shade2/map.hsp:2442 	if (areaType(cnt)=mTypeTown)or(areaType(cnt)=mTyp ..

               if area.metadata.is_hidden then
                  self.image = nil
               end
            end
         end
      }
   }
}

data:add {
   _type = "base.feat",
   _id = "locked_hatch",
   -- elona_id = 21,

   image = "elona.feat_locked_hatch",
   is_solid = false,
   is_opaque = false,

   _ext = {
      [IFeatLockedHatch] = {
         sidequest_id = "elona.main_quest",
         feat_id = "elona.stairs_down",
      }
   }
}
