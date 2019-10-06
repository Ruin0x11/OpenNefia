local uid_tracker = require("internal.uid_tracker")

-- manages groups of related maps ("areas"). it makes no assumptions
-- about things like dungeon level.
local area_mapping = class.class("area_mapping")

function area_mapping:init(uids)
   self.uids = uids or uid_tracker:new()

   self.map_to_area = {}
   self.area_to_maps = {}
end

function area_mapping:generate_area()
   local area_uid = self.uids:get_next_and_increment()
   assert(not self.area_to_maps[area_uid])
   self.area_to_maps[area_uid] = { uid = area_uid, maps = {}, data = {} }
   return area_uid
end

function area_mapping:set_area_of_map(map_uid, area_uid)
   local old = self.map_to_area[map_uid]
   if old then
      self.area_to_maps[old].maps[map_uid] = nil
   end

   self.map_to_area[map_uid] = area_uid
   self.area_to_maps[area_uid].maps[map_uid] = true
end

function area_mapping:maybe_generate_area_for_map(map_uid)
   if not self.map_to_area[map_uid] then
      local area = self:generate_area()
      self:set_area_of_map(map_uid, area)
      return true, area
   end

   return false, self.map_to_area[map_uid]
end

function area_mapping:iter_maps_in_area(area)
   if not self.area_to_maps[area] then
      error("Unknown area UID " .. tostring(area))
   end
   return fun.iter(self.area_to_maps[area].maps)
end

function area_mapping:get_area_of_map(map)
   return self.map_to_area[map]
end

function area_mapping:get_data_of_area(area)
   _p(self.area_to_maps, area)
   return self.area_to_maps[area]
end

function area_mapping:iter_maps_in_same_area(map)
   local area_uid = self:get_area_of_map(map)
   assert(area_uid)
   return self:iter_maps_in_area(area_uid)
end

return area_mapping
