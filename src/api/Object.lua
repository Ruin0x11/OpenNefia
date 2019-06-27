local IObject = require("api.IObject")
local IMapObject = require("api.IMapObject")

local Object = {}

-- Modification of penlight's algorithm to ignore class fields
local function cycle_aware_copy(t, cache)
   -- TODO: standardize no-save fields
   if type(t) == "table" and t.__class then
      return
   end

   if type(t) ~= 'table' then return t end
   if cache[t] then return cache[t] end
   local res = {}
   cache[t] = res
   local mt = getmetatable(t)
   for k,v in pairs(t) do
      -- TODO: standardize no-save fields
      -- NOTE: preserves the UID for now.
      if k ~= "location" then
         k = cycle_aware_copy(k, cache)
         v = cycle_aware_copy(v, cache)
         res[k] = v
      end
   end
   setmetatable(res,mt)
   return res
end

--- Strips any classes and extracts only the fields and underlying
--- prototype of an object to a table. The returned table can then be
--- passed to Object.generate to build a new copy of the original
--- object, as Object.clone does.
-- @tparam IObject object
-- @treturn table
function Object.make_prototype(object)
   return cycle_aware_copy(object, {})
end

--- Wraps a table with the object metatable.
function Object.create(tbl)
   local obj = setmetatable(tbl, IObject)
   self:build()
   return obj
end

--- Copies all non-class fields in an object to a new object, giving
--- it a new UID. If `owned` is true, also attempts to transfer the
--- object to the original object's location. If this fails, deletes
--- the cloned object and returns nil. If unsuccessful, no state is
--- changed except the UID increment.
-- @tparam IObject object
-- @tparam bool owned
-- @treturn[1] IObject
-- @treturn[2] nil
function Object.clone(object, owned)
   owned = owned or false

   -- TODO: the nomenclature is confusing. things like
   -- data["mytype"]["id"] are named 'prototypes', but there are also
   -- tables with a backing prototype set that are also called
   -- 'prototypes'.
   local proto = Object.make_prototype(object)
   assert(proto.location == nil)

   -- Generate a new object using the stripped object as a prototype.
   local new_object = Object.generate(proto)

   if owned and is_an(IObject, object) then
      -- HACK: This makes cloning characters harder, since the
      -- location also has to be changed manually, or there will be
      -- more than one character on the same square. Perhaps
      -- IMapObject:find_free_pos(x, y) would help.
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

return Object
