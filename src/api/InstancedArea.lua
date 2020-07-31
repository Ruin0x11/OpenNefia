local InstancedMap = require("api.InstancedMap")
local save = require("internal.global.save")

local InstancedArea = class.class("InstancedArea")

function InstancedArea:init(image, area_generator, uids)
   self.uid = save.base.area_uids:get_next_and_increment()

   self._id = nil
   self.maps = {}
   self.image = image or nil
   self.area_generator = area_generator or nil
   self.metadata = {}
end

function InstancedArea:add_floor(map, floor)
   floor = floor or (self:deepest_floor() + 1)
   assert(class.is_an(InstancedMap, map))

   assert(self.maps[floor] == nil, ("Map already exists at floor '%d'"):format(floor))
   if map.area_uid then
      error(("Map already registered in area '%d'"):format(map.area_uid))
   end
   self.maps[floor] = { uid = map.uid }
   map.area_uid = self.uid
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

function InstancedArea:get_floor(floor)
   local map = self.maps[floor]
   if map == nil then
      return false, "missing_floor"
   end

   return map
end

function InstancedArea:load_floor(floor)
   local map = self.maps[floor]
   if map == nil then
      return false, "missing_floor"
   end

   local Map = require("api.Map")
   return Map.load(map.uid)
end

function InstancedArea:load_starting_floor()
   return self:load_floor(self:starting_floor())
end

return InstancedArea
