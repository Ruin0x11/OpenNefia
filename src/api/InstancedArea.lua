local InstancedMap = require("api.InstancedMap")
local Log = require("api.Log")
local save = require("internal.global.save")
local data = require("internal.data")

local InstancedArea = class.class("InstancedArea")

function InstancedArea:init(image, area_generator, uids)
   self.uid = save.base.area_uids:get_next_and_increment()

   self._archetype = nil
   self.maps = {}
   self.image = image or nil
   self.area_generator = area_generator or nil
   self.metadata = {}
   self.name = nil
   self.parent_area = nil
   self.parent_x = nil
   self.parent_y = nil
end

function InstancedArea:add_floor(map, floor)
   floor = floor or (self:deepest_floor() + 1)
   assert(math.type(floor) == "integer")
   assert(class.is_an(InstancedMap, map))

   assert(self.maps[floor] == nil, ("Map already exists at floor '%d'"):format(floor))
   if map.area_uid then
      error(("Map already registered in area '%d'"):format(map.area_uid))
   end
   self.maps[floor] = { uid = map.uid }
   self.name = self.name or map.name
   map.area_uid = self.uid
end

function InstancedArea:archetype()
   if self._archetype == nil then
      return nil
   end
   return data["base.area_archetype"]:ensure(self._archetype)
end

function InstancedArea:set_archetype(area_archetype_id)
   data["base.area_archetype"]:ensure(area_archetype_id)
   self._archetype = area_archetype_id
end

function InstancedArea:deepest_floor()
   if #self.maps == 0 then
      return 0
   end
   return fun.iter(table.keys(self.maps)):max()
end

function InstancedArea:starting_floor()
   if #self.maps == 0 then
      return 0
   end
   return fun.iter(table.keys(self.maps)):min()
end

function InstancedArea:iter_maps()
   -- If the area's list of maps looks like { [1] = { uid = 1 } } then luafun
   -- assumes it's a list, which is wrong. Force it to be iterated as a map
   -- instead.
   return fun.iter_pairs(self.maps)
end

function InstancedArea:iter_maps()
   return fun.iter_pairs(self.maps)
end

function InstancedArea:get_floor(floor)
   assert(math.type(floor) == "integer")
   local map_meta = self.maps[floor]
   if map_meta == nil then
      return false, "missing_floor"
   end

   return true, map_meta
end

function InstancedArea:load_floor(floor)
   assert(math.type(floor) == "integer")
   local ok, map_meta = self:get_floor(floor)
   if not ok then
      return nil, map_meta
   end

   local Map = require("api.Map")
   local ok, map =  Map.load(map_meta.uid)
   if ok then
      return ok, map
   end

   -- Map is now invalid, clear it.
   self.maps[floor] = nil

   return nil, map
end

function InstancedArea:load_or_generate_floor(floor, map_archetype_id)
   assert(math.type(floor) == "integer")
   local ok, map = self:load_floor(floor)
   if ok then
      return ok, map
   end

   local archetype = self:archetype()

   if map_archetype_id == nil then
      if archetype == nil then
         return false, "no_archetype"
      end

      if archetype.floors and archetype.floors[floor] then
         map_archetype_id = archetype.floors[floor]
      end
   end

   local params = {
      -- used by mansion of younger sister
      is_first_generation = true
   }

   if map_archetype_id then
      local map_archetype = data["base.map_archetype"]:ensure(map_archetype_id)
      assert(type(map_archetype.on_generate_map) == "function", ("Map archetype '%s' was associated with floor '%d' of area archetype '%s', but it doesn't have an `on_generate_floor` callback."):format(map_archetype_id, floor, self._archetype))

      map = map_archetype.on_generate_map(self, floor, params)
      if map._archetype == nil then
         Log.debug("Map archetype unset on new floor, setting to %s", map_archetype_id)
         map:set_archetype(map_archetype_id, { set_properties = true })
      else
         Log.debug("Map archetype was already set to %s on generation", map._archetype)
      end
   else
      map = archetype.on_generate_floor(self, floor, params)
   end

   assert(class.is_an(InstancedMap, map))
   self:add_floor(map, floor)

   map:emit("base.on_generate_area_floor", {area=self, floor_number=floor, is_first_generation=params.is_first_generation})

   Log.debug("Generated area floor with map archetype %s", map._archetype)

   return true, map
end

function InstancedArea:iter_child_areas(floor)
   assert(math.type(floor) == "integer")
   if self._archetype == nil then
      return fun.iter({})
   end

   local filter = function(arc)
      return arc.parent_area
         and self._archetype == arc.parent_area._id
         and floor == arc.parent_area.on_floor
   end
   return data["base.area_archetype"]:iter():filter(filter)
end

function InstancedArea:position_of_child(child, floor)
   assert(class.is_an(InstancedArea, child))
   assert(math.type(floor) == "integer")

   if self._archetype == nil or child._archetype == nil then
      return nil, nil
   end

   local child_archetype = self:iter_child_areas(floor):filter(function(arc) return arc._id == child._archetype end):nth(1)
   if child_archetype == nil then
      return nil, nil
   end

   local parent = child_archetype.parent_area
   return parent.x, parent.y
end

function InstancedArea:load_starting_floor()
   return self:load_floor(self:starting_floor())
end

function InstancedArea:__tostring()
   return ("Area %d (%s)"):format(self.uid, self.name or "<no name>")
end

return InstancedArea
