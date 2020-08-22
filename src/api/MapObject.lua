local object = require("internal.object")
local ILocation = require("api.ILocation")
local pool = require("internal.pool")

local Event = require("api.Event")
local Object = require("api.Object")
local Log = require("api.Log")

local MapObject = {}

function MapObject.generate_from(_type, id, uid_tracker)
   uid_tracker = uid_tracker or require("internal.global.save").base.uids

   local uid = uid_tracker:get_next_and_increment()

   -- params.no_pre_build = true
   local obj = Object.generate_from(_type, id)

   rawset(obj, "uid", uid)

   -- class.assert_is_an(IMapObject, data)

   return obj
end

function MapObject.generate(proto, uid_tracker)
   uid_tracker = uid_tracker or require("internal.global.save").base.uids

   local uid = uid_tracker:get_next_and_increment()

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

local function is_map_object(thing)
   return type(thing) == "table" and thing._id and thing._type
end

-- NOTE: We could have an interface for classes that need special cloning logic.
local function clone_pool(the_pool, uids, cache)
   local new_pool = pool:new(the_pool.type_id, the_pool.width, the_pool.height)

   if not the_pool.uids then
      pause()
   end
   for _, obj in the_pool:iter() do
      local new_obj = MapObject.clone(obj, false, uids, cache)
      assert(new_pool:take_object(new_obj, obj.x, obj.y))
   end

   return new_pool
end

-- Another modification of penlight's algorithm that also calls :clone() on any
-- map objects it finds in the table.
local function cycle_aware_copy(t, cache, uids, first)
   if type(t) ~= 'table' then return t end
   if cache[t] then return cache[t] end
   if not first and is_map_object(t) then
      local new_obj = MapObject.clone(t, false, uids, cache)
      cache[t] = new_obj
      return new_obj
   end
   if class.is_an(pool, t) then
      local new_pool = clone_pool(t, uids, cache)
      cache[t] = new_pool
      return new_pool
   end
   local res = {}
   cache[t] = res
   local mt = getmetatable(t)
   for k,v in pairs(t) do
      -- TODO: standardize no-save fields
      -- NOTE: preserves the UID for now.
      -- HACK: workaround for delegation memoization referring to the original
      -- object
      if k == "__memoized" then
         res[k] = {}
      elseif k ~= "location" and k ~= "proto" then
         k = cycle_aware_copy(k, cache)
         v = cycle_aware_copy(v, cache)
         res[k] = v
      end
   end
   setmetatable(res,mt)
   return res
end

function MapObject.clone(obj, owned, uid_tracker, cache)
   uid_tracker = uid_tracker or require("internal.global.save").base.uids

   local new_object = cycle_aware_copy(obj, cache or {}, uid_tracker, true)

   new_object.uid = uid_tracker:get_next_and_increment()

   local mt = getmetatable(obj)
   setmetatable(new_object, mt)

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

   Event.trigger("base.on_object_cloned", {object=obj, type="full"})

   return new_object
end

return MapObject
