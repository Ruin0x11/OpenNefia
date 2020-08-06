local Sha1 = require("mod.extlibs.api.Sha1")

local Hash = {}

local function hash_string(h, str)
   return Sha1.hex(h .. "string:" .. Sha1.hex(str))
end

local function hash_boolean(h, bool)
   return Sha1.hex(h .. "boolean:" .. tostring(bool))
end

local function hash_number(h, num)
   return Sha1.hex(h .. "number:" .. num)
end

local function hash_function(h, fun)
   return Sha1.hex(h .. "function:" .. Sha1.hex(string.dump(fun)))
end

local function hash_nil(h)
   return Sha1.hex(h .. "nil:" .. "nil")
end

local function sort_keys(tbl)
   local string_keys = {}
   local number_keys = {}
   local boolean_keys = {}

   for key, _ in pairs(tbl) do
      if type(key) == 'string' then
         table.insert(string_keys, key)
      elseif type(key) == 'number' then
         table.insert(number_keys, key)
      elseif type(key) == 'boolean' then
         table.insert(boolean_keys, key)
      else
         error("Can't hash a table with a key of type " .. type(key))
      end
   end

   -- sort stably
   table.insertion_sort(string_keys)
   table.insertion_sort(number_keys)
   table.insertion_sort(boolean_keys)

   return string_keys, number_keys, boolean_keys
end

local function hash_table(h, tbl)
   h = Sha1.hex(h .. "table:")
   local string_keys, number_keys, boolean_keys = sort_keys(tbl)
   for k, v in ipairs(string_keys) do
      h = hash_string(h, k)
      h = Hash.hash_one(h, v)
   end
   for k, v in ipairs(number_keys) do
      h = hash_number(h, k)
      h = Hash.hash_one(h, v)
   end
   for k, v in ipairs(boolean_keys) do
      h = hash_boolean(h, k)
      h = Hash.hash_one(h, v)
   end
   return h
end

local function hash_one(h, thing)
   h = h or ""
   local ty = type(thing)
   if ty == "string" then
      return hash_string(h, thing)
   elseif ty == "number" then
      return hash_number(h, thing)
   elseif ty == "boolean" then
      return hash_boolean(h, thing)
   elseif ty == "function" then
      return hash_function(h, thing)
   elseif ty == "table" then
      return hash_table(h, thing)
   elseif ty == "nil" then
      return hash_nil(h, thing)
   end

   error("Unsupported type " .. ty)
end

--- Hashes an arbitrary sequence of objects based on their structure.
---
--- This has the following limitations:
---
--- - You can't hash userdata or thread values.
--- - You can't hash tables with function, table, userdata or thread keys.
--- - The value of the hash returned is not guaranteed to be identical for
---   structually equivalent objects between different versions of the engine or
---   different Lua runtimes.
---
--- @tparam any ...
--- @treturn string SHA-1 of the hashed objects
function Hash.hash(...)
   local h = ""

   for i = 1, select("#", ...) do
      local v = select(i, ...)
      h = hash_one(h, v)
   end

   return h
end

return Hash
