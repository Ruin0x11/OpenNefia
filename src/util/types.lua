local types = {}

local ctxt_mt = {}
ctxt_mt.__index = ctxt_mt

function ctxt_mt:push(key, value)
   self.stack[#self.stack+1] = {
      key = key,
      value = value
   }
end

function ctxt_mt:pop()
   self.stack[#self.stack] = nil
end

local function smart_quote(str)
  if str:match('"') and not str:match("'") then
    return "'" .. str .. "'"
  end
  return '"' .. str:gsub('"', '\\"') .. '"'
end

local INSPECT_OPTIONS = {
   newline = " ", indent = "", max_length = 16,
}

local function get_name(obj)
   if type(obj) == "string" then
      return smart_quote(obj)
   elseif type(obj) == "table" then
      if class.is_class_instance(obj) then
         return tostring(obj)
      end
      return inspect(obj, INSPECT_OPTIONS)
   end

   return tostring(obj)
end

function ctxt_mt:make_trail(obj)
   local seen = {obj = true}
   local s = { get_name(obj, seen) }
   for _, entry in ipairs(self.stack) do
      s[#s+1] = "["
      s[#s+1] = get_name(entry.key)
      s[#s+1] = "]"
      if entry.value then
         s[#s+1] = " -> "
         s[#s+1] = get_name(entry.value)
      end
   end
   return table.concat(s)
end

local function make_ctxt()
   local t = {
      stack = {}
   }
   return setmetatable(t, ctxt_mt)
end

local names = {}

--
-- single-value checkers
--

local function primitive(ty)
   return function(obj, _ctxt)
      if type(obj) == ty then
         return true
      end
      return false, ty
   end
end

local primitives = {
   "nil",
   "boolean",
   "string",
   "table",
   "function",
   "userdata",
   "thread"
}

for _, ty in ipairs(primitives) do
   types[ty] = primitive(ty)
end

local function is_nan(obj)
   -- According to IEEE 754, a nan value is considered not equal to any value,
   -- including itself.
   return obj ~= obj
end

function types.number(obj, _ctxt)
   if type(obj) == "number" and not is_nan(obj) then
      return true
   end
   return false, names[types.number]
end

function types.nan(obj, _ctxt)
   if type(obj) == "number" and is_nan(obj) then
      return true
   end
   return false, names[types.nan]
end

function types.integer(obj, _ctxt)
   if math.type(obj) == "integer" and not is_nan(obj) then
      return true
   end
   return false, names[types.integer]
end

function types.float(obj, _ctxt)
   if math.type(obj) == "float" and not is_nan(obj) then
      return true
   end
   return false, names[types.float]
end

function types.class_type(obj, _ctxt)
   if class.is_class(obj) then
      return true
   end

   return false, "class type"
end

function types.interface_type(obj, _ctxt)
   if class.is_class(obj) then
      return true
   end

   return false, "interface type"
end

--
-- higher-order checkers
--

local function is_enum(tbl)
   -- see api/Enum.lua
   return tbl.__enum == true
end

function types.enum(enum)
   assert(is_enum(enum), ("%s is not an enum"):format(enum))
   return function(obj, _ctxt)
      if enum:has_value(obj) then
         return true
      end

      return false, ("member of %s"):format(enum)
   end
end

function types.class(klass)
   assert(class.is_class(klass), ("%s is not a class"):format(klass))
   return function(obj, _ctxt)
      if class.is_an(klass, obj) then
         return true
      end

      return false, tostring(klass)
   end
end

function types.implements(iface)
   assert(class.is_interface(iface), ("%s is not an interface"):format(iface))
   return function(obj, _ctxt)
      if class.is_an(iface, obj) then
         return true
      end

      return false, tostring(iface)
   end
end

function types.optional(checker)
   return function(obj, ctxt)
      if obj == nil then
         return true
      end

      local ok, err = checker(obj, ctxt)
      if not ok then
         return false, ("optional<%s>"):format(err)
      end

      return true
   end
end

function types.keys(checker)
   return function(obj, ctxt)
      if not types.table(obj, ctxt) then
         return false, "table"
      end

      for key, _ in pairs(obj) do
         ctxt:push(key)
         local ok, err = checker(key)
         if not ok then
            return false, err
         end
         ctxt:pop()
      end

      return true
   end
end

function types.values(checker)
   return function(obj, ctxt)
      if not types.table(obj, ctxt) then
         return false, "table"
      end

      for key, val in pairs(obj) do
         ctxt:push_value(key, val)
         local ok, err = checker(val)
         if not ok then
            return false, err
         end
         ctxt:pop()
      end

      return true
   end
end

function types.map(key_checker, value_checker)
   return function(obj, ctxt)
      if not types.table(obj, ctxt) then
         return false, "table"
      end

      for key, val in pairs(obj) do
         ctxt:push(key)
         local ok, err = key_checker(key, ctxt)
         if not ok then
            return false, err
         end
         ctxt:pop()

         ctxt:push_value(key, val)
         ok, err = value_checker(val, ctxt)
         if not ok then
            return false, err
         end
         ctxt:pop()
      end

      return true
   end
end

function types.set(value_checker)
   return types.map(types.boolean, value_checker)
end

function types.any(...)
   local checkers = { ... }

   return function(obj, ctxt)
      for _, checker in ipairs(checkers) do
         if checker(obj, ctxt) then
            return true
         end
      end

      local s = {}
      for _, checker in ipairs(checkers) do
         s[#s+1] = names[checker]
      end
      return false, ("any<%s>"):format(table.concat(s, ", "))
   end
end

function types.all(...)
   local checkers = { ... }

   return function(obj, ctxt)
      for i, checker in ipairs(checkers) do
         local ok, err = checker(obj, ctxt)
         if not ok then
            return false, err
         end
      end

      return true
   end
end

function types.fields(kvs)
   return function(obj, ctxt)
      if not types.table(obj, ctxt) then
         return false, "table"
      end

      for key, checker in pairs(kvs) do
         ctxt:push(key)
         local ok, err = checker(obj[key], ctxt)
         if not ok then
            return false, err
         end
         ctxt:pop()
      end

      return true
   end
end

function types.fields_strict(kvs)
   return function(obj, ctxt)
      if not types.table(obj, ctxt) then
         return false
      end

      for key, val in pairs(obj) do
         local checker = kvs[key]
         if not checker then
            return false
         end

         ctxt:push(key)
         if not checker(val, ctxt) then
            return false
         end
         ctxt:pop()
      end

      return true
   end
end

for key, checker in pairs(types) do
   names[checker] = key
end

function types.check(obj, checker)
   local ctxt = make_ctxt()
   local success, needed_ty = checker(obj, ctxt)
   if not success then
      needed_ty = needed_ty or "<unknown>"
      return false, ("Typecheck failed - Value is not of type \"%s\": %s"):format(needed_ty, ctxt:make_trail(obj))
   end
   return true
end

function types.wrap(checker)
   return function(obj)
      return types.check(obj, checker)
   end
end

function types.wrap_strict(checker)
   return function(obj)
      return assert(types.check(obj, checker))
   end
end

return types
