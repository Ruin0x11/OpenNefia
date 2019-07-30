local Log = require("api.Log")
local data = require("internal.data")

-- Allows deferring the generation of random parameters until object
-- creation. The idea was borrowed from ToME.
local Resolver = {}

function Resolver.make(id, params)
   if not id or type(id) ~= "string" then
      error(string.format("Resolver is not an ID (%s)", id))
   end

   params = params or {}
   params.__resolver = id
   return params
end

function Resolver.resolve_one(tbl, params)
   local id = tbl.__resolver
   if not id or type(id) ~= "string" then
      error(string.format("Table is not a resolver (%s)", id))
   end

   local resolver = data["base.resolver"]:ensure(id)

   -- if not Schema.check(resolver.params, params) then error() end

   local result = resolver.resolve(tbl, params)
   if resolver.method then
      result = {
         __method = resolver.method,
         __value = result
      }
   end
   return result
end

local function resolve_recurse(result, proto, params, key)
   if type(proto) == "table" then
      if proto.__resolver then
         result[key] = Resolver.resolve_one(proto, params)
      else
         for k, v in pairs(proto) do
            result[key] = result[key] or {}
            resolve_recurse(result[key], v, params, k)
         end
      end
   else
      result[key] = proto
   end
end

function Resolver.resolve(proto, params)
   params = params or {}
   local result = {}

   if type(proto) == "table" then
      if proto.__resolver then
         result = Resolver.resolve_one(proto, params)
      else
         for k, v in pairs(proto) do
            resolve_recurse(result, v, params, k)
         end
      end
   else
      result = proto
   end

   return result
end

function Resolver.run(id, invariants, params)
   local resolver = Resolver.make(id, invariants)
   return Resolver.resolve(resolver, params)
end

return Resolver
