local uid_tracker = require("internal.uid_tracker")

local pool = class("pool")

function pool:init(type_id, tracker)
   assert_is_an(uid_tracker, tracker)

   self.type_id = type_id
   self.content = {}
   self.uids = {}
   self.uid_tracker = tracker
end

function pool:get(uid)
   if self.content[uid] == nil then
      return nil
   end

   local d = self.content[uid].data

   local mt = {
      __index = function(t, k)
         if k == "is_valid" then
            return self.content[uid] ~= nil
         end

         return d[k]
      end,
      __newindex = function(t, k, v)
         if k ~= "uid" then
            d[k] = v
         end
      end
   }
   return setmetatable({}, mt)
end

function pool:generate(proto)
   local uid = self.uid_tracker:get_next_and_increment(self.type_id)

   local data = setmetatable({}, { __index = proto })

   rawset(data, "uid", uid)

   return data
end

function pool:add_object(obj, uid)
   local entry = { data = obj, array_index = #self.uids + 1 }

   table.insert(self.uids, uid)
   self.content[uid] = entry

   return self:get(uid)
end

function pool:remove(uid)
   if self.content[uid] == nil then
      -- error("UID not found " .. uid)
      return
   end

   -- HACK terribly inefficient for over 100 elements.
   table.remove(self.uids, self.content[uid].array_index)

   local obj = self.content[uid]
   self.content[uid] = nil
   return obj
end

function pool:insert(obj, uid)
   table.insert(self.uids, uid)
   obj.array_index = self.uids

   self.content[uid] = obj
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

function pool:transfer_to(pool_to, uid)
   assert(self.content[uid] ~= nil)
   assert(pool_to.content[uid] == nil)
   local ind = self.content[uid].array_index
   assert(ind ~= nil)
   assert(ind <= #self.uids)
   assert(self.uids[ind] == uid)

   local obj = self:remove(uid)
   pool_to:insert(obj, uid)
end

return pool
