local ICloneable = require("api.ICloneable")
local ILocation = require("api.ILocation")
local Log = require("api.Log")

-- Low-level storage for map objects of the same types. Pretty much
-- anything that needs to store map objects uses this internally.
local pool = class.class("pool", { ILocation, ICloneable }, { no_inspect = false })

-- serialization ID for binser
pool.__id = "pool"

function pool:init(type_id, width, height, owner)
   if owner then
      -- assert(class.is_an(ILocation, owner))
      self._parent = owner
   end
   width = width or 1
   height = height or 1

   self.type_id = type_id
   self.content = setmetatable({}, { __inspect = tostring })
   self.uids = {}
   self.width = width
   self.height = height

   self.positional = {}
end

function pool:get_object(uid)
   if self.content[uid] == nil then
      return nil
   end

   local d = self.content[uid].data

   return d
end

function pool:take_object(obj, x, y)
   if self:has_object(obj) then
      return nil, "already_has_object"
   end

   x = math.floor(x or 0)
   y = math.floor(y or 0)
   assert(x >= 0 and x < self.width)
   assert(y >= 0 and y < self.height)

   local mt = getmetatable(obj)

   -- obj:remove_ownership()
   local location = obj:get_location()
   if location then
      if not location:remove_object(obj) then
         return nil, "could_not_transfer"
      end
      mt.location = nil
   end

   -- We make `x` and `y` immutable using `object.__newindex`, to force their
   -- update through IMapObject:set_pos(x, y). This is so `self.positional` can
   -- get updated properly.
   mt.x = x
   mt.y = y

   -- Same thing for `location`.
   local old_location = mt.location
   mt.location = self

   local ok, err = xpcall(obj.on_set_location, debug.traceback, obj, old_location)
   if not ok then
      Log.error("IOwned:on_set_location(): %s", err)
   end

   local entry = { data = obj, array_index = #self.uids + 1 }

   table.insert(self.uids, obj.uid)
   self.content[obj.uid] = entry
   local idx = y*self.width+x+1
   if self.positional[idx] == nil then
      self.positional[idx] = {}
   end
   table.insert(self.positional[idx], obj)

   return self:get_object(obj.uid)
end

function pool:move_object(obj, x, y)
   assert(self:has_object(obj))
   assert(x >= 0 and x < self.width)
   assert(y >= 0 and y < self.height)

   local prev_idx = obj.y*self.width+obj.x+1
   table.iremove_value(self.positional[prev_idx], obj)
   if #self.positional[prev_idx] == 0 then
      self.positional[prev_idx] = nil
   end
   local new_idx = y*self.width+x+1
   if self.positional[new_idx] == nil then
      self.positional[new_idx] = {}
   end
   table.insert(self.positional[new_idx], obj)

   -- We make `x` and `y` immutable using `object.__newindex`, to force their
   -- update through IMapObject:set_pos(x, y). This is so `self.positional` can
   -- get updated properly.
   local mt = getmetatable(obj)
   local old_x = mt.x
   local old_y = mt.y
   mt.x = x
   mt.y = y

   local ok, err = xpcall(obj.on_set_pos, debug.traceback, obj, old_x, old_y)
   if not ok then
      Log.error("IOwned:on_set_pos(): %s", err)
   end

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
   for _, v in pairs(self.content) do
      if v.array_index >= ind then
         v.array_index = v.array_index - 1
      end
   end

   local obj_ = self.content[uid].data

   self.content[obj_.uid] = nil

   local idx = obj_.y*self.width+obj_.x+1
   table.iremove_value(self.positional[idx], obj_)
   if #self.positional[idx] == 0 then
      self.positional[idx] = nil
   end

   local mt = getmetatable(obj_)
   mt.location = nil

   return obj_
end

-- HACK: This should really be extracted into its own class.
-- TODO: rename to iter_objects_at_pos
function pool:objects_at_pos(x, y)
   if not self:is_in_bounds(x, y) then
      return fun.iter({})
   end
   return fun.iter(table.shallow_copy(self.positional[y*self.width+x+1] or {}))
end

function pool:is_in_bounds(x, y)
   return x >= 0 and y >= 0 and x < self.width and y < self.height
end

function pool:has_object(obj)
   return obj ~= nil and self.content[obj.uid] ~= nil
end

function pool:serialize()
end

function pool:deserialize()
   for _, v in self:iter() do
      if type(v) == "table" then
         local mt = getmetatable(v)
         if mt.__id == "object" then
            mt.location = self
         end
      end
   end
end

local function iter(state, index)
   if index > #state.uids then
      return nil
   end

   -- We have to be careful of stale iterators, since state.uids is a deepcopy
   -- from the parent. If this iterator is created as a standalone object and
   -- any objects referred to inside state.uids are removed from the pool
   -- afterwards, they should be skipped over.
   local content
   while content == nil and index <= #state.uids do
      content = state.content[state.uids[index]]
      index = index + 1
   end

   if content == nil then
      return nil
   end

   local data = content.data
   return index, data
end

function pool:iter(ordering)
   return fun.wrap(iter, {uids=ordering or table.deepcopy(self.uids), content=self.content}, 1)
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

function pool:clone(uids, cache, uid_mapping, opts)
   local MapObject = require("api.MapObject")

   local new_pool = pool:new(self.type_id, self.width, self.height)

   for _, obj in self:iter() do
      local new_obj = MapObject.clone(obj, false, uids, cache, uid_mapping, opts)
      uid_mapping[obj.uid] = new_obj.uid
      assert(new_pool:take_object(new_obj, obj.x, obj.y))
   end

   return new_pool
end

return pool
