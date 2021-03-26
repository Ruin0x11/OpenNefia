local object = require("internal.object")
local ILocation = require("api.ILocation")
local pool = require("internal.pool")
local IOwned = require("api.IOwned")
local IMapObject = require("api.IMapObject")
local ICloneable = require("api.ICloneable")

local Event = require("api.Event")
local Object = require("api.Object")
local Log = require("api.Log")

local MapObject = {}

function MapObject.generate_from(_type, id, uid_tracker)
   uid_tracker = uid_tracker or require("internal.global.save").base.uids

   local uid = uid_tracker:get_next_and_increment()

   -- params.no_pre_build = true
   local obj = Object.generate_from(_type, id)

   local mt = getmetatable(obj)
   assert(mt.__id == "object")
   rawset(mt, "uid", uid)

   -- class.assert_is_an(IMapObject, data)

   obj:pre_build()

   return obj
end

function MapObject.generate(proto, uid_tracker)
   uid_tracker = uid_tracker or require("internal.global.save").base.uids

   local uid = uid_tracker:get_next_and_increment()

   -- params.no_pre_build = true
   local obj = Object.generate(proto)

   local mt = getmetatable(obj)
   assert(mt.__id == "object")
   rawset(mt, "uid", uid)

   -- class.assert_is_an(IMapObject, obj)

   obj:pre_build()

   return obj
end

function MapObject.finalize(obj, params)
   return Object.finalize(obj, params)
end

--- Copies all non-class fields in an object to a new object, giving
--- it a new UID. If `owned` is true, also attempts to transfer the
--- object to the original object's location. If this fails, deletes
--- the cloned object and returns nil. If unsuccessful, no state is
--- changed except the UID increment.
-- @tparam IMapObject object
-- @tparam bool owned
-- @treturn[1] IMapObject
-- @treturn[2] nil
function MapObject.clone_base(obj, owned)
   owned = owned or false

   -- TODO: the nomenclature is confusing. things like
   -- data["mytype"]["id"] are named 'prototypes', but there are also
   -- tables with a backing data prototype set that are also called
   -- 'prototypes'.
   local proto = Object.make_prototype(obj)
   assert(proto.location == nil)

   -- Generate a new object using the stripped object as a prototype.
   local new_object = MapObject.generate(proto)
   MapObject.finalize(new_object, { no_build=true })

   local location = obj:get_location()
   if owned and class.is_an("api.IMapObject", obj) and class.is_an("api.ILocation", location) then
      -- HACK: This makes cloning characters harder, since the
      -- location also has to be changed manually, or there will be
      -- more than one character on the same square. Perhaps
      -- IMapObject:find_free_pos(x, y) would help.
      local x = new_object.x or 0
      local y = new_object.y or 0

      if not location:can_take_object(new_object, x, y) then
         Log.warn("Tried to clone object %d (%s), but the location %s couldn't take the object.",
                  obj.uid, obj._type, tostring(location))
         new_object:remove_ownership()
         return nil
      end

      assert(location:take_object(new_object, x, y))
   end

   Event.trigger("base.on_object_cloned", {object=obj, type="base"})

   return new_object
end

function MapObject.is_map_object(t, _type)
   if not class.is_an(IMapObject, t) then
      return false, ("'%s' is not a map object"):format(t)
   end

   if _type == nil then
      return true
   end

   if _type ~= t._type then
      return false, ("Expected map object of type '%s', got '%s'"):format(_type, t._type)
   end

   return true
end

-- Another modification of penlight's algorithm that also calls :clone() on any
-- map objects it finds in the table.
local function cycle_aware_copy(t, uids, cache, uid_mapping, first, opts)
   if type(t) ~= 'table' then return t end
   if cache[t] then return cache[t] end
   if class.is_class_or_interface(t) then
      cache[t] = t
      return t
   end
   if not first then
      if MapObject.is_map_object(t) then
         local new_obj = MapObject.clone(t, false, uids, cache, uid_mapping, opts)
         cache[t] = new_obj
         return new_obj
      elseif class.is_an(ICloneable, t) then
         local new = t:clone(uids, cache, uid_mapping, opts)
         cache[t] = new
         return new
      end
   end
   local res = {}
   cache[t] = res
   local mt = getmetatable(t)
   for k, v in pairs(t) do
      -- TODO: standardize no-save fields
      -- NOTE: preserves the UID for now.
      -- HACK: workaround for delegation memoization referring to the original
      -- object
      if k == "__memoized" then
         res[k] = {}
      elseif k ~= "location" then
         local nk = cycle_aware_copy(k, uids, cache, uid_mapping, false)
         local nv = cycle_aware_copy(v, uids, cache, uid_mapping, false)
         res[nk] = nv

         -- Special case for classes like `EquipSlots` that have a `_parent`
         -- field for use with IOwned:containing_map() and similar.
         if class.is_an(IOwned, v) and v._parent == t then
            nv._parent = res
         end
      end
   end
   if t.__class and class.is_class_or_interface(mt) then
      res.__class = mt
   end
   if mt then
      local is_object = mt.__id == "object"
      if is_object then
         local new_mt = {}

         -- see `object.deserialize()`
         new_mt.__id = mt.__id
         new_mt.__index = object.__index
         new_mt.__newindex = object.__newindex
         new_mt.__iface = mt.__iface
         new_mt.__tostring = object.__tostring
         new_mt.__inspect = object.__inspect

         -- immutable state
         new_mt.uid = nil
         new_mt.x = mt.x
         new_mt.y = mt.y
         new_mt.location = nil
         new_mt._id = mt._id
         new_mt._type = mt._type

         setmetatable(res,new_mt)
      else
         setmetatable(res,mt)
      end
   end

   return res
end

--- Similar to `table.deepcopy()`, but has awareness of map objects.
function MapObject.deepcopy(t, uid_tracker, cache, uid_mapping, opts)
   cache = cache or {}
   uid_mapping = uid_mapping or {}

   if MapObject.is_map_object(t) then
      return MapObject.clone(t, false, uid_tracker, cache, uid_mapping, opts)
   end

   return cycle_aware_copy(t, uid_tracker, cache, uid_mapping, true, opts)
end

function MapObject.clone(obj, owned, uid_tracker, cache, uid_mapping, opts)
   uid_tracker = uid_tracker or require("internal.global.save").base.uids
   uid_mapping = uid_mapping or {}
   local preserve_uid = (opts and opts.preserve_uid) or false

   local new_object = cycle_aware_copy(obj, uid_tracker, cache or {}, uid_mapping, true, opts)

   local mt = getmetatable(new_object)
   if preserve_uid then
      mt.uid = obj.uid
   else
      mt.uid = uid_tracker:get_next_and_increment()
   end
   uid_mapping[obj.uid] = mt.uid

   local location = obj:get_location()
   if owned and class.is_an("api.IMapObject", obj) and class.is_an("api.ILocation", location) then
      assert(not preserve_uid, "Cannot preserve UID for owned object")
      -- HACK: This makes cloning characters harder, since the
      -- location also has to be changed manually, or there will be
      -- more than one character on the same square. Perhaps
      -- IMapObject:find_free_pos(x, y) would help.
      local x = new_object.x or 0
      local y = new_object.y or 0

      if not location:can_take_object(new_object, x, y) then
         Log.warn("Tried to clone object %d (%s), but the location %s couldn't take the object.",
                  obj.uid, obj._type, tostring(location))
         new_object:remove_ownership()
         return nil
      end

      assert(location:take_object(new_object, x, y))
   end

   Event.trigger("base.on_object_cloned", {object=obj, new_object=new_object, type="full", owned=owned})
   new_object:instantiate()

   return new_object
end

return MapObject
