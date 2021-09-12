local object = require("internal.object")
local data = require("internal.data")

local IObject = require("api.IObject")

local Object = {}

local NO_SAVE_FIELDS = table.set {
   "_ext"
}

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
      if not NO_SAVE_FIELDS[k] then
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
function Object.make_prototype(obj)
   local _type = obj._type
   local _id = obj._id
   assert(_type)
   assert(_id)

   local copy = cycle_aware_copy(obj, {})
   if type(copy) ~= "table" then
      return obj
   end

   setmetatable(copy, nil)

   -- for deserialization, removed afterward
   copy._type = _type
   copy._id = _id

   return copy
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

function Object.generate_from(_type, id)
   -- strip non-copiable fields, which are prefixed with '_'
   local proto = Object.make_prototype(data[_type]:ensure(id))

   return Object.generate(proto)
end

function Object.generate(proto)
   assert(proto._type)
   assert(proto._id)
   local obj = object.deserialize(proto)
   assert(obj.proto)

   local fallbacks = data.fallbacks[obj._type]
   obj:mod_base_with(table.deepcopy(fallbacks), "merge")

   return obj
end

function Object.finalize(obj, params)
   params = params or {}

   if not params.no_build then
      obj:normal_build(params.build_params)
      obj:finalize(params.build_params)
      obj:instantiate(true) -- events are bound by :finalize()
   end
end

local IMockObject = class.interface("IMockObject", {}, IObject)
function IMockObject.build(self)
   IObject.init(self)
end
function IMockObject.refresh(self)
   IObject.on_refresh(self)
end

function Object.mock_interface(mt)
   local tbl = mock(mt)
   local obj = setmetatable(tbl, mt)
   obj:finalize()

   class.assert_is_an(IObject, obj)

   obj:refresh()
   return obj
end

function Object.mock(mt, tbl)
   mt = mt or IMockObject
   tbl = tbl or {}
   tbl._id = tbl._id or "none"

   local obj = setmetatable(tbl, mt)
   obj:finalize()

   class.assert_is_an(IObject, obj)

   obj:refresh()
   return obj
end

-- Validates a params table against the type definitions in an object's data
-- entry.
--
-- For example, a door feat will be able to have an unlock difficulty set on it.
-- `proto_params` is the `params` table in the `base.feat`'s data definition and
-- looks like { difficulty = types.number }, and `passed_params` would have been
-- passed to `Feat.create()` and looks something like { difficulty = 25 }.
function Object.copy_params(proto_params, passed_params, _type, _id)
   proto_params = proto_params or {}
   passed_params = passed_params or {}

   local result = {}

   local found = table.set{}

   for property, entry in pairs(proto_params) do
      local value = passed_params[property]
      local error_msg = "%s '%s' received invalid value for parameter '%s': %s"
      local checker
      if types.is_type_checker(entry) then
         checker = entry
      else
         checker = entry.type
         if not types.is_type_checker(checker) then
            error(("%s '%s' has invalid type checker for parameter '%s': %s"):format(_type, _id, property, checker))
         end
         if value == nil then
            value = entry.default
            error_msg = "%s '%s' is missing required parameter '%s': %s"
         end
      end
      local ok, err = types.check(value, checker)
      if not ok then
         error((error_msg):format(_type, _id, property, err))
      end
      result[property] = value
   end

   if table.count(found) ~= table.count(passed_params) then
      for k, v in pairs(passed_params) do
         if not proto_params[k] then
            error(("%s '%s' does not accept parameter '%s'"):format(_type, _id, k))
         end
      end
   end

   return result
end

return Object
