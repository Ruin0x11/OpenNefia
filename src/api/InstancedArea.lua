local InstancedMap = require("api.InstancedMap")
local Log = require("api.Log")
local save = require("internal.global.save")
local data = require("internal.data")
local MapArchetype = require("api.MapArchetype")

local InstancedArea = class.class("InstancedArea")

function InstancedArea:init(archetype_id, area_generator, uids)
   self.uid = save.base.area_uids:get_next_and_increment()

   self._archetype = nil
   self.maps = {}
   self.image = nil
   self.area_generator = area_generator or nil
   self.metadata = {}
   self.name = nil
   self.parent_area = nil
   self._parent_area_position = nil
   self._children = {}
   self.parent_x = nil
   self.parent_y = nil
   self.deepest_floor_visited = 0
   self._deepest_floor = nil

   if archetype_id then
      self:set_archetype(archetype_id, { set_properties = true })
   end
end

function InstancedArea:add_floor(map, floor)
   floor = floor or (self:deepest_floor() + 1)

   assert(class.is_an(InstancedMap, map))
   assert(math.type(floor) == "integer")

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

function InstancedArea:set_archetype(area_archetype_id, params)
   data["base.area_archetype"]:ensure(area_archetype_id)
   self._archetype = area_archetype_id

   local archetype = self:archetype()
   if archetype and params and params.set_properties then
      self.image = self.image or archetype.image
      self.color = self.color or archetype.color
      if archetype.metadata then
         for k, v in pairs(archetype.metadata) do
            self.metadata[k] = table.deepcopy(v)
         end
      end
   end
end

function InstancedArea:deepest_floor()
   if self._deepest_floor then
      return self._deepest_floor
   end

   local archetype = self:archetype()
   if archetype and archetype.floors then
      return fun.iter(table.keys(archetype.floors)):max()
   end

   return 1
end

function InstancedArea:starting_floor()
   local archetype = self:archetype()
   if archetype and archetype.floors then
      return fun.iter(table.keys(archetype.floors)):min()
   end

   return 1
end

function InstancedArea:iter_maps()
   -- If the area's list of maps looks like { [1] = { uid = 1 } } then luafun
   -- assumes it's a list, which is wrong. Force it to be iterated as a map
   -- instead.
   return fun.iter_pairs(self.maps)
end

function InstancedArea:floor_of_map(map_uid)
   local pred = function(floor_no, map_meta)
      return map_meta.uid == map_uid
   end
   local floor_no = self:iter_maps():filter(pred):nth(1)
   return floor_no
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
      return ok, map, false
   end

   -- WARNING: Map.save() should always be called on the map this returns, or
   -- weird things will happen!

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
      map = MapArchetype.generate_map(map_archetype_id, self, floor, params)
   else
      if archetype.on_generate_floor == nil then
         return false, "no_archetype_on_generate_floor"
      end
      map = archetype.on_generate_floor(self, floor, params)
   end

   assert(class.is_an(InstancedMap, map))
   self:add_floor(map, floor)

   map:emit("base.on_generate_area_floor", {area=self, floor_number=floor, is_first_generation=params.is_first_generation})

   Log.debug("Generated area %d's floor %d with map archetype %s", self.uid, floor, map._archetype)

   return true, map, true
end

function InstancedArea:iter_child_areas(floor)
   if floor then
      assert(math.type(floor) == "integer")
   end
   if self._archetype == nil then
      return fun.iter({})
   end

   local filter = function(uid, pos)
      return floor == nil or pos.floor == floor
   end

   local map = function(uid, child)
      return {
         uid = uid,
         floor = child.floor,
         x = child.x,
         y = child.y,
      }
   end

   return fun.iter(self._children):filter(filter):map(map)
end

function InstancedArea:load_starting_floor()
   return self:load_floor(self:starting_floor())
end

function InstancedArea:load_or_generate_starting_floor()
   return self:load_or_generate_floor(self:starting_floor())
end

function InstancedArea:add_child_area(child)
   assert(class.is_an(InstancedArea, child))
   if self._children[child.uid] then
      error(("Area %d is already a child of area %d"):format(child.uid, self.uid))
   end

   self._children[child.uid] = {
      floor = nil,
      x = nil,
      y = nil
   }
end

function InstancedArea:has_child_area(child)
   assert(class.is_an(InstancedArea, child))
   return self._children[child.uid] ~= nil
end

function InstancedArea:child_area_position(child)
   assert(class.is_an(InstancedArea, child))
   local meta = self._children[child.uid]
   if not meta then
      return nil, nil, nil
   end

   if meta.floor == nil or meta.x == nil or meta.y == nil then
      return nil, nil, nil
   end

   return meta.x, meta.y, meta.floor
end

function InstancedArea:set_child_area_position(child, x, y, floor)
   assert(class.is_an(InstancedArea, child))
   local meta = self._children[child.uid]
   if not meta then
      error(("Area %d is not a child of area %d"):format(child.uid, self.uid))
   end

   if floor == nil or x == nil or y == nil then
      assert(not (floor ~= nil or x ~= nil or y ~= nil))
      meta.floor = nil
      meta.x = nil
      meta.y = nil
   else
      meta.floor = floor
      meta.x = x
      meta.y = y
   end
end

function InstancedArea:remove_child_area(child)
   assert(class.is_an(InstancedArea, child))
   self._children[child.uid] = nil
end

function InstancedArea:__tostring()
   return ("Area %d (%s)"):format(self.uid, self.name or "<no name>")
end

return InstancedArea
