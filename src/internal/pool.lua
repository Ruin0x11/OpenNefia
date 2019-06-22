local uid_tracker = require("internal.uid_tracker")
local ILocation = require("api.ILocation")
local MapObject = require("api.MapObject")

local pool = class("pool", ILocation)

function pool:init(type_id, tracker, width, height)
   assert_is_an(uid_tracker, tracker)

   self.type_id = type_id
   self.content = {}
   self.uids = {}
   self.uid_tracker = tracker
   self.width = width
   self.height = height

   self.positional = table.of_2d(function() return {} end, width, height, true)
end

function pool:get_object(uid)
   if self.content[uid] == nil then
      return nil
   end

   local d = self.content[uid].data

   return d
end

function pool:create_object(proto, x, y)
   local raw = MapObject.generate(proto, self.uid_tracker)
   return self:take_object(raw, x, y)
end

function pool:take_object(obj, x, y)
   if self.content[obj.uid] ~= nil then
      return nil
   end

   x = x or 0
   y = y or 0
   assert(x >= 0 and x < self.width)
   assert(y >= 0 and y < self.height)

   -- obj:remove_ownership()
   if obj.location then
      if not obj.location:remove_object(obj) then
         return nil
      end
      obj.location = nil
   end

   obj.x = x
   obj.y = y
   obj.location = self

   local entry = { data = obj, array_index = #self.uids + 1 }

   table.insert(self.uids, obj.uid)
   self.content[obj.uid] = entry
   table.insert(self.positional[y][x], obj.uid)

   return self:get_object(obj.uid)
end

local function get_uid(obj)
end

function pool:move_object(obj, x, y)
   assert(self:has_object(obj))
   assert(x >= 0 and x < self.width)
   assert(y >= 0 and y < self.height)

   table.remove_value(self.positional[obj.y][obj.x], obj.uid, true)
   table.insert(self.positional[y][x], obj.uid)

   obj.x = x
   obj.y = y

   return obj
end

function pool:remove_object(obj)
   local uid
   if type(obj) == "table" then
      uid = obj.uid
   elseif type(obj) == "number" then
      uid = obj
   else
      error(string.format("remove_object takes an object or UID (got: %s)", obj))
   end

   local entry = self.content[uid]

   if entry == nil then
      error("UID not found " .. uid)
      return
   end

   -- HACK terribly inefficient for over 100 elements.
   local ind = entry.array_index
   table.remove(self.uids, ind)
   for k, v in pairs(self.content) do
      if v.array_index >= ind then
         v.array_index = v.array_index - 1
      end
   end

   local obj = self.content[uid].data

   self.content[obj.uid] = nil

   table.remove_value(self.positional[obj.y][obj.x], obj.uid, true)

   obj.location = nil

   return obj
end

function pool:objects_at_pos(x, y)
   return self.positional[y][x]
end

function pool:has_object(obj)
   return obj ~= nil and self.content[obj.uid] ~= nil
end

local function iter(a, i)
   if i > #a.uids then
      return nil
   end

   local d = a.content[a.uids[i]].data
   i = i + 1

   return i, d
end

function pool:iter_objects(ordering)
   return iter, {uids=ordering or self.uids, content=self.content}, 1
end

function pool:make_list()
   local t = {}
   for _, v in self:iter_objects() do
      t[#t+1] = v
   end
   return t
end

function pool:object_count()
   return #self.uids
end

function pool:is_positional()
   return true
end

function pool:can_take_object(obj)
   return true
end

function pool:put_into(pool_to, obj, x, y)
   x = x or 0
   y = y or 0
   local uid = obj.uid

   if not pool_to:can_take_object(obj, x, y) then
      return nil
   end

   assert(self:has_object(obj))
   assert(not pool_to:has_object(obj))
   local ind = self.content[uid].array_index
   assert(ind ~= nil)
   assert(ind <= #self.uids)
   assert(self.uids[ind] == uid)
   assert(type(x) == "number")
   assert(type(y) == "number")

   return pool_to:take_object(obj, x, y)
end

return pool
