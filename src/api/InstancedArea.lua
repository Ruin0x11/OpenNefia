local InstancedMap = require("api.InstancedMap")
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
end

function InstancedArea:add_floor(map, floor)
   assert(math.type(floor) == "integer")
   floor = floor or (self:deepest_floor() + 1)
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
   local map = self.maps[floor]
   if map == nil then
      return false, "missing_floor"
   end

   return map
end

function InstancedArea:load_floor(floor)
   assert(math.type(floor) == "integer")
   local map = self.maps[floor]
   if map == nil then
      return false, "missing_floor"
   end

   local Map = require("api.Map")
   return Map.load(map.uid)
end

function InstancedArea:load_or_generate_floor(floor)
   assert(math.type(floor) == "integer")
   local map_meta = self.maps[floor]
   if map_meta then
      local Map = require("api.Map")
      return Map.load(map_meta.uid)
   end

   local archetype = self:archetype()
   if archetype == nil then
      return false, "no_archetype"
   end

   local map = archetype.on_generate_floor(self, floor)
   assert(class.is_an(InstancedMap, map))
   self:add_floor(map, floor)

   map:emit("base.on_generate_area_floor", {area=self, floor_number=floor})

   return true, map
end

function InstancedArea:load_starting_floor()
   return self:load_floor(self:starting_floor())
end

function InstancedArea:__tostring()
   return ("Area %d (%s)"):format(self.uid, self.name or "<no name>")
end

return InstancedArea
