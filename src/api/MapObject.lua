local object = require("internal.object")
local ILocation = require("api.ILocation")
local pool = require("internal.pool")
local IOwned = require("api.IOwned")

local Event = require("api.Event")
local Object = require("api.Object")
local Log = require("api.Log")

local MapObject = {}

function MapObject.generate_from(_type, id, UidTracker)
   UidTracker = UidTracker or require("internal.global.save").base.uids

   local uid = UidTracker:get_next_and_increment()

   -- params.no_pre_build = true
   local obj = Object.generate_from(_type, id)

   rawset(obj, "uid", uid)

   -- class.assert_is_an(IMapObject, data)

   return obj
end

function MapObject.generate(proto, UidTracker)
   UidTracker = UidTracker or require("internal.global.save").base.uids

   local uid = UidTracker:get_next_and_increment()

   -- params.no_pre_build = true
   local obj = Object.generate(proto)

   rawset(obj, "uid", uid)

   -- class.assert_is_an(IMapObject, obj)

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

   if owned and class.is_an("api.IMapObject", obj) and class.is_an("api.ILocation", obj.location) then
      -- HACK: This makes cloning characters harder, since the
      -- location also has to be changed manually, or there will be
      -- more than one character on the same square. Perhaps
      -- IMapObject:find_free_pos(x, y) would help.
      local x = new_object.x or 0
      local y = new_object.y or 0

      if not obj.location:can_take_object(new_object, x, y) then
         Log.warn("Tried to clone object %d (%s), but the location %s couldn't take the object.",
                  obj.uid, obj._type, tostring(obj.location))
         new_object:remove_ownership()
         return nil
      end

      assert(obj.location:take_object(new_object, x, y))
   end

   Event.trigger("base.on_object_cloned", {object=obj, type="base"})

   return new_object
end

function MapObject.is_map_object(t)
   return type(t._id) == "string" and type(t._type) == "string" and type(t.uid) == "number"
end

-- NOTE: We could have an interface for classes that need special cloning logic.
local function clone_pool(the_pool, uids, cache, opts)
   local new_pool = pool:new(the_pool.type_id, the_pool.width, the_pool.height)

   for _, obj in the_pool:iter() do
      local new_obj = MapObject.clone(obj, false, uids, cache, opts)
      assert(new_pool:take_object(new_obj, obj.x, obj.y))
   end

   return new_pool
end

-- Another modification of penlight's algorithm that also calls :clone() on any
-- map objects it finds in the table.
local function cycle_aware_copy(t, cache, uids, first, opts)
   if type(t) ~= 'table' then return t end
   if cache[t] then return cache[t] end
   if class.is_class_or_interface(t) then
      cache[t] = t
      return t
   end
   if not first and MapObject.is_map_object(t) then
      local new_obj = MapObject.clone(t, false, uids, cache, opts)
      cache[t] = new_obj
      return new_obj
   end
   if class.is_an(pool, t) then
      local new_pool = clone_pool(t, uids, cache, opts)
      cache[t] = new_pool
      return new_pool
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
      elseif k ~= "location" and k ~= "proto" then
         local nk = cycle_aware_copy(k, cache, uids, false)
         local nv = cycle_aware_copy(v, cache, uids, false)
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
   setmetatable(res,mt)

   -- This is tricky. A lot of implementers of `ILocation` first call
   -- pool:take_object() and then manually set the `location` field on the
   -- object afterwards. Because we deliberately don't try to clone `location`
   -- as it's a back reference, we have to determine what to set `location` to
   -- by hand.
   --
   -- So at this point, `location` on the cloned object is nil. There are two
   -- cases:
   --
   -- 1. `location` lied outside the original object, so it didn't get cloned.
   --    Hopefully this should only ever happen at the top level, with the
   --    original call to MapObject.clone(). In this case we don't have to do
   --    anything since MapObject.clone() will try to reconnect the object's
   --    location if the `owned` argument is set to `true`.
   --
   -- 2. `location` referred to something nested inside a parent object, like
   --    EquipSlots. In this case the thing that was originally the object's
   --    `location` will itself be cloned onto the new object and we have to
   --    reassociate the cloned object with it, because `pool:take_object()`
   --    will set `location` but it has no knowledge of any implementer of
   --    `ILocation` that uses it as a field.
   --
   -- The below code handles the second case.
   if class.is_an(ILocation, t) then
      -- Try to see if this is a class instance that implements ILocation and
      -- manually sets the `location` field.
      local sets_location
      if class.is_class_or_interface(t.__class) then
         assert(class.is_class_instance(res))
         local obj = t:iter():nth(1)
         if obj and obj.location == t then
            sets_location = true
         end
      end

      -- If not, see if the previous location was a map object. Map objects
      -- can implement `ILocation` even though they aren't class instances.
      if not sets_location and MapObject.is_map_object(t) then
         local obj = t:iter():nth(1)
         if obj and obj.location == t then
            sets_location = true
         end
      end

      -- If we've determined that the thing acts like an `ILocation` and
      -- manually sets `location`, update the `location` field on the newly
      -- cloned object to match.
      if sets_location then
         for _, new_obj in res:iter() do
            Log.warn("Set location %s %s %s", new_obj, res.__class, res)
            new_obj.location = res
         end
      end
   end
   return res
end

--- Similar to `table.deepcopy()`, but has awareness of map objects.
function MapObject.deepcopy(t, UidTracker, opts)
   if MapObject.is_map_object(t) then
      return MapObject.clone(t, false, UidTracker, {}, opts)
   end

   return cycle_aware_copy(t, {}, UidTracker, true, opts)
end

function MapObject.clone(obj, owned, UidTracker, cache, opts)
   UidTracker = UidTracker or require("internal.global.save").base.uids
   local preserve_uid = (opts and opts.preserve_uid) or false

   local new_object = cycle_aware_copy(obj, cache or {}, UidTracker, true, opts)

   if not preserve_uid then
      new_object.uid = UidTracker:get_next_and_increment()
   end

   local mt = getmetatable(obj)
   setmetatable(new_object, mt)

   if owned and class.is_an("api.IMapObject", obj) and class.is_an("api.ILocation", obj.location) then
      assert(not preserve_uid, "Cannot preserve UID for owned object")
      -- HACK: This makes cloning characters harder, since the
      -- location also has to be changed manually, or there will be
      -- more than one character on the same square. Perhaps
      -- IMapObject:find_free_pos(x, y) would help.
      local x = new_object.x or 0
      local y = new_object.y or 0

      if not obj.location:can_take_object(new_object, x, y) then
         Log.warn("Tried to clone object %d (%s), but the location %s couldn't take the object.",
                  obj.uid, obj._type, tostring(obj.location))
         new_object:remove_ownership()
         return nil
      end

      assert(obj.location:take_object(new_object, x, y))
   end

   Event.trigger("base.on_object_cloned", {object=obj, type="full", owned=owned})

   return new_object
end

return MapObject
