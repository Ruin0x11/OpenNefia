local Log = require("api.Log")
local data = require("internal.data")

-- Allows deferring the generation of random parameters until object
-- creation. The idea was borrowed from ToME.
local Resolver = {}

function Resolver.make(id, params, target_field)
   if not id or not (type(id) == "string" or type(id) == "table") then
      error(string.format("Resolver is not valid (%s)", id))
   end

   params = params or {}
   params.__resolver = id
   params.__target_field = target_field or nil
   return params
end

function Resolver.resolve_one(tbl, params)
   local id = tbl.__resolver

   local resolver
   if type(id) == "string" then
      resolver = data["base.resolver"]:ensure(id)
   elseif type(id) == "table" then
      resolver = id
   else
      error(string.format("Resolver is not valid (%s)", id))
   end
   -- if not Schema.check(resolver.params, params) then error() end

   local result = resolver.resolve(tbl, params)
   if resolver.method and not params.override_method then
      result = {
         __method = resolver.method,
         __value = result
      }
   end
   return result
end

local function resolve_recurse(result, proto, params, key, seen)
   if type(proto) == "table" then
      if proto.__resolver then
         result[key] = Resolver.resolve_one(proto, params)
      else
         for k, v in pairs(proto) do
            result[key] = result[key] or {}
            if not seen[result[key]] then
               seen[result[key]] = true
               resolve_recurse(result[key], v, params, k, seen)
            end
         end
      end
   elseif not params.diff_only then
      result[key] = proto
   end
end

function Resolver.resolve(proto, params)
   params = params or {}
   local result = {}
   local seen = {}

   if type(proto) == "table" then
      if proto.__resolver then
         result = Resolver.resolve_one(proto, params)
      else
         -- resolve key-value first, then array values, to allow
         -- specifying the order of resolving if one resolver modifies
         -- a value that is depended on for a later resolver.
         for k, v in pairs(proto) do
            if type(k) ~= "number" then
               resolve_recurse(result, v, params, k, seen)
            end
         end
         for _, v in ipairs(proto) do
            assert(type(v) == "table" and v.__resolver)
            local resolved = Resolver.resolve_one(v, params, result)

            for k, v in pairs(resolved) do
               result[k] = v
            end
         end
      end
   elseif not params.diff_only then
      result = proto
   end

   if params.value and type(result) == "table" and result.__value then
      return result.__value
   end

   return result
end

return Resolver
