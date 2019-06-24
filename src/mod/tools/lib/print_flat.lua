local print_flat = {}

local function is_valid_lua_identifier(s)
   return string.match(s, "^[_a-zA-Z][_a-zA-Z0-9]*$") ~= nil
end

local function concat(acc, s)
   if acc == "" then
      return s
   end

   return acc .. "\n" .. s
end

local function print_key(k, dot)
   if is_valid_lua_identifier(k) then
      if dot then
         return "." .. k
      else
         return k
      end
   end
   return string.format("[\"%s\"]", k)
end

local function print_value(v)
   if type(v) == "string" then
      return "\"" .. v .. "\""
   end
   return tostring(v)
end

local print_object
local function gen_print_kv_pair(stack, cache)
   return function(k, v)
      return print_object(v, (stack == "" and print_key(k)) or (stack .. print_key(k, true)), cache)
   end
end
local function gen_print_array_index(stack, cache)
   return function(i, v)
      return print_object(v, (stack == "" and print_key(k)) or (stack .. "[" .. tostring(i) .. "]"), cache)
   end
end

local function is_array(o)
   return o[1] ~= nil
end

print_object = function(o, stack, cache)
   if cache[o] then
      return stack .. " = <cycle>"
   end

   if type(o) == "table" then
      cache[o] = true
      if is_array(o) then
         return fun.enumerate(o):map(gen_print_array_index(stack, cache)):foldl(concat, "")
      else
         return fun.iter(o):map(gen_print_kv_pair(stack, cache)):foldl(concat, "")
      end
   else
      return stack .. " = " .. print_value(o)
   end
end

function print_flat.print_flat(o, name)
   return print_object(o, name or "", {})
end

return print_flat
