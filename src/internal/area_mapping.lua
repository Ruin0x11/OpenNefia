local Log = require("api.Log")
local uid_tracker = require("internal.uid_tracker")

-- manages groups of related maps ("areas"). it makes no assumptions
-- about things like dungeon level.
local area_mapping = class.class("area_mapping")

function area_mapping:init(uids)
   self.uids = uids or uid_tracker:new()

   self.areas = {}
   self.maps = {}
end

local function get_uid(obj)
   local uid = obj
   if type(obj) == "table" then
      uid = obj.uid
   end
   return uid
end

function area_mapping:create_area(outer_map_or_uid, x, y)
   local outer_map_uid = get_uid(outer_map_or_uid)
   if outer_map_or_uid ~= nil then
      assert(type(x) == "number")
      assert(type(y) == "number")
   end

   local uid = self.uids:get_next_and_increment()
   self.areas[uid] = {
      uid = uid,
      outer_map_uid = outer_map_uid,
      x = x,
      y = y,
      maps = {},
      data = {}
   }

   Log.debug("Created area %d in map %s at (%s,%s)", uid, outer_map_uid, x, y)
   return self.areas[uid]
end

function area_mapping:remove_area(area_uid)
   local area = self.areas[area_uid]
   if area == nil then
      error(("Area %s does not exist"):format(area_uid))
   end

   for _, map_uid in ipairs(area.maps) do
      self.maps[map_uid] = nil
   end

   Log.debug("Removed area %d", area_uid)
   self.areas[area_uid] = nil
end

function area_mapping:add_map_to_area(area_uid, map_or_uid)
   local map_uid = get_uid(map_or_uid)
   assert(type(map_uid) == "number")

   local area = self.areas[area_uid]
   if area == nil then
      error(("Area %s does not exist"):format(area_uid))
   end
   if self.maps[map_uid] ~= nil then
      error(("Map UID %d is already part of an area: %d"):format(map_uid, self.maps[map_uid]))
   end

   Log.debug("Associating map %d with area %d", map_uid, area_uid)

   area.maps[map_uid] = {}
   self.maps[map_uid] = area_uid
end

function area_mapping:remove_map(map_or_uid)
   local map_uid = get_uid(map_or_uid)
   assert(type(map_uid) == "number")

   local area = self:area_for_map(map_uid)
   if area == nil then
      return
   end

   Log.debug("Removing map %d from area %d", map_uid, area.uid)

   area.maps[map_uid] = nil
   self.maps[map_uid] = nil
end

function area_mapping:area(area_uid)
   return self.areas[area_uid]
end

function area_mapping:area_for_map(map_or_uid)
   local map_uid = get_uid(map_or_uid)
   if map_uid == nil then
      return nil
   end

   local area_uid = self.maps[map_uid]
   if area_uid == nil then
      return nil
   end

   return self.areas[area_uid]
end

function area_mapping:area_for_outer_map(map_or_uid)
   local map_uid = get_uid(map_or_uid)
   if map_uid == nil then
      return nil
   end

   for _, v in ipairs(self.areas) do
      if v.outer_map_uid == map_uid then
         return v
      end
   end

   return nil
end

return area_mapping
