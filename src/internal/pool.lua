local uid_tracker = require("internal.uid_tracker")

local pool = class("pool")

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

function pool:get(uid)
   if self.content[uid] == nil then
      return nil
   end

   local d = self.content[uid].data

   local mt = {
      __index = function(t, k)
         -- BUG Does not preserve the validity of references that are
         -- moved between maps when they're supposed to stay valid.
         if k == "is_valid" then
            return self.content[uid] ~= nil
         end

         return d[k]
      end,
      __newindex = function(t, k, v)
         if k ~= "uid" then
            d[k] = v
         end
      end,
      __eq = function(a, b)
         return type(a) == "table" and type(b) == "table" and a.uid == b.uid
      end
   }
   return setmetatable({}, mt)
end

local function pool_generate(self, proto)
   local uid = self.uid_tracker:get_next_and_increment(self.type_id)

   local data = setmetatable({}, { __index = proto })

   rawset(data, "uid", uid)

   return data
end

function pool:create_object(proto, x, y)
   local raw = pool_generate(self, proto)

   return self:add_object(raw, x, y)
end

function pool:add_object(obj, x, y)
   assert(self.content[obj.uid] == nil)
   assert(x >= 0 and x < self.width)
   assert(y >= 0 and y < self.height)

   local entry = { data = obj, array_index = #self.uids + 1 }

   obj.x = x
   obj.y = y

   table.insert(self.uids, obj.uid)
   self.content[obj.uid] = entry
   table.insert(self.positional[y][x], obj.uid)

   return self:get(obj.uid)
end

function pool:move_object(obj, x, y)
   assert(self:exists(obj.uid))
   assert(x >= 0 and x < self.width)
   assert(y >= 0 and y < self.height)

   table.remove_value(self.positional[obj.y][obj.x], obj.uid, true)
   table.insert(self.positional[y][x], obj.uid)

   obj.x = x
   obj.y = y
end

function pool:remove(uid)
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

   self.content[uid] = nil

   local obj = entry.data
   table.remove_value(self.positional[obj.y][obj.x], obj.uid, true)

   return obj
end

function pool:objects_at(x, y)
   return self.positional[y][x]
end

function pool:exists(uid)
   return self.content[uid] ~= nil
end

local function iter(a, i)
   if i > #a.uids then
      return nil
   end

   local d = a.content[a.uids[i]].data
   i = i + 1

   return i, d
end

function pool:iter()
   return iter, {uids=self.uids, content=self.content}, 1
end

function pool:transfer_to(pool_to, uid, x, y)
   assert(self.content[uid] ~= nil)
   assert(pool_to.content[uid] == nil)
   local ind = self.content[uid].array_index
   assert(ind ~= nil)
   assert(ind <= #self.uids)
   assert(self.uids[ind] == uid)
   assert(type(x) == "number")
   assert(type(y) == "number")

   local obj = self:remove(uid)
   return pool_to:add_object(obj, x, y)
end

return pool
