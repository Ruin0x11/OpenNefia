local Log = require("api.Log")

local MapObject = {}

local uids = require("internal.global.uids")

function MapObject.generate_from(_type, id, uid_tracker)
   local data = require("internal.data")
   local proto = data[_type]:ensure(id)
   return MapObject.generate(proto, uid_tracker)
end

local function makeindex(proto)
   return function(t, k)
      local v = rawget(t, k)
      if v ~= nil then
         return v
      end

      return proto[k]
   end
end

function MapObject.generate(proto, uid_tracker)
   uid_tracker = uid_tracker or uids

   local uid = uid_tracker:get_next_and_increment()

   local tbl = {
      temp = {},
      proto = proto
   }

   local data = setmetatable(tbl, { __index = makeindex(proto) })

   rawset(data, "uid", uid)
   data.x = 0
   data.y = 0

   data:build()

   return data
end

-- Modification of penlight's algorithm to ignore class fields
local function cycle_aware_copy(t, cache)
   if type(t) == "table" and t.__class then
      return
   end

   if type(t) ~= 'table' then return t end
   if cache[t] then return cache[t] end
   local res = {}
   cache[t] = res
   local mt = getmetatable(t)
   for k,v in pairs(t) do
      k = cycle_aware_copy(k, cache)
      v = cycle_aware_copy(v, cache)
      res[k] = v
   end
   setmetatable(res,mt)
   return res
end

-- Strips any classes and extracts only the fields and underlying
-- prototype of an object to a table. The returned table can then be
-- passed to MapObject.generate to build a new copy of the original
-- object, as MapObject.clone does.
-- @tparam IMapObject object
-- @treturn table
function MapObject.make_prototype(object)
   return cycle_aware_copy(object, {})
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
function MapObject.clone(object, owned)
   owned = owned or false

   -- TODO: the nomenclature is confusing. things like
   -- data["mytype"]["id"] are named 'prototypes', but there are also
   -- tables with a backing prototype set that are also called
   -- 'prototypes'.
   local proto = MapObject.make_prototype(object)
   assert(proto.location == nil)

   -- Generate a new object using the stripped object as a prototype.
   local new_object = MapObject.generate(proto)

   if owned and object.location then
      local x = new_object.x or 0
      local y = new_object.y or 0

      if not object.location.can_take_object(new_object, x, y) then
         Log.warn("Tried to clone object %d (%s), but the location %s couldn't take the object.",
                  object.uid, object._type, tostring(object.location))
         new_object:remove_ownership()
         return nil
      end

      assert(object.location:take_object(new_object, x, y))
   end

   return new_object
end

return MapObject
