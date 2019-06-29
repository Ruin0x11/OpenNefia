local IObject = require("api.IObject")

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
--- object, as MapObject.clone does.
-- @tparam IObject object
-- @treturn table
function Object.make_prototype(object)
   return cycle_aware_copy(object, {})
end

local mock = function(mt)
   local mock = {}
   mock._id = "mock"
   mock._type = "mock"
   mock.build = function(self)
      IObject.init(self)
      if mt.init then
         mt.init(self)
      end
   end
   mock.refresh = function(self)
      IObject.on_refresh(self)
      if mt.on_refresh then
         mt.on_refresh(self)
      end
   end
   return mock
end

local function makeindex(proto, mt)
   return function(t, k)
      local v = rawget(t, k)
      if v ~= nil then
         return v
      end

      v = proto[k]
      if v ~= nil then
         return v
      end

      return mt[k]
   end
end

function Object.generate_from(id, mt)
   local data = require("internal.data")
   local proto = data[mt._type]:ensure(id)
   return Object.generate(proto, mt)
end

function Object.generate(proto, mt)
   local tbl = {
      temp = {},
      proto = proto
   }

   local data = setmetatable(tbl, { __index = makeindex(proto, mt) })

   assert_is_an(IObject, data)

   data:build()

   return data
end

local IMockObject = interface("IMockObject", {}, IObject)
function IMockObject.build()
   IObject.init(self)
end
function IMockObject.refresh(self)
   IObject.on_refresh(self)
end

function Object.mock_interface(mt)
   local tbl = mock(mt)
   local obj = setmetatable(tbl, mt)
   obj:build()

   assert_is_an(IObject, obj)

   obj:refresh()
   return obj
end

function Object.mock(mt, tbl)
   mt = mt or IMockObject
   tbl = tbl or {}
   tbl._id = tbl._id or "none"

   local obj = setmetatable(tbl, mt)
   obj:build()

   assert_is_an(IObject, obj)

   obj:refresh()
   return obj
end

return Object
