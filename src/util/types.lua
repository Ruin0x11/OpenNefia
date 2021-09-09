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

--
-- single-value checkers
--

local ITypeChecker = class.interface("ITypeChecker", { check = "function" })

local function is_type_checker(obj)
   if not class.is_an(ITypeChecker, obj) then
      return false, ("%s is not a type checker"):format(obj)
   end
   return true
end

local primitive_checker = class.class("primitive_checker", ITypeChecker)
function primitive_checker:init(ty)
   self.type = ty
end
function primitive_checker:check(obj, ctxt)
   if type(obj) == self.type then
      return true
   end
   return false, tostring(self)
end
function primitive_checker:__tostring()
   return self.type
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
   types[ty] = primitive_checker:new(ty)
end

local function is_nan(obj)
   -- According to IEEE 754, a nan value is considered not equal to any value,
   -- including itself.
   return obj ~= obj
end

do
   local number_checker = class.class("primitive_checker", ITypeChecker)
   function number_checker:check(obj, _ctxt)
      if type(obj) == "number" and not is_nan(obj) then
         return true
      end
      return false, tostring(self)
   end
   function number_checker:__tostring()
      return "number"
   end
   types.number = number_checker:new()
end

do
   local nan_checker = class.class("nan_checker", ITypeChecker)
   function nan_checker:check(obj, _ctxt)
      if type(obj) == "number" and is_nan(obj) then
         return true
      end
      return false, tostring(self)
   end
   function nan_checker:__tostring()
      return "nan"
   end
   types.nan = nan_checker:new()
end

do
   local integer_checker = class.class("integer_checker", ITypeChecker)
   function integer_checker:check(obj, _ctxt)
      if math.type(obj) == "integer" and not is_nan(obj) then
         return true
      end
      return false, tostring(self)
   end
   function integer_checker:__tostring()
      return "integer"
   end
   types.integer = integer_checker:new()
end

do
   local float_checker = class.class("float_checker", ITypeChecker)
   function float_checker:check(obj, _ctxt)
      if math.type(obj) == "float" and not is_nan(obj) then
         return true
      end
      return false, tostring(self)
   end
   types.float = float_checker:new()
end

do
   local class_type_checker = class.class("class_type_checker", ITypeChecker)
   function class_type_checker:check(obj, _ctxt)
      if class.is_class(obj) then
         return true
      end

      return false, tostring(self)
   end
   function class_type_checker:__tostring()
      return "class type"
   end
   types.class_type = class_type_checker:new()
end

do
   local interface_type_checker = class.class("interface_type_checker", ITypeChecker)
   function interface_type_checker:check(obj, _ctxt)
      if class.is_interface(obj) then
         return true
      end

      return false, tostring(self)
   end
   function interface_type_checker:__tostring()
      return "interface type"
   end
   types.interface_type = interface_type_checker:new()
end

local function is_enum(tbl)
   -- see api/Enum.lua
   return tbl.__enum == true
end

do
   local enum_type_checker = class.class("enum_type_checker", ITypeChecker)
   function enum_type_checker:check(obj, _ctxt)
      if is_enum(obj) then
         return true
      end

      return false, tostring(self)
   end
   function enum_type_checker:__tostring()
      return "enum type"
   end
   types.enum_type = enum_type_checker:new()
end

--
-- higher-order checkers
--

local function wrap(klass)
   return function(...)
      return klass:new(...)
   end
end

do
   local enum_checker = class.class("enum_checker", ITypeChecker)
   function enum_checker:init(enum)
      assert(is_enum(enum), ("%s is not an enum"):format(enum))
      self.enum = enum
   end
   function enum_checker:check(obj, _ctxt)
      if self.enum:has_value(obj) then
         return true
      end

      return false, tostring(self)
   end
   function enum_checker:__tostring()
      return "enum type"
   end
   types.enum = wrap(enum_checker)
end

do
   local instance_of_checker = class.class("instance_of_checker", ITypeChecker)
   function instance_of_checker:init(klass)
      assert(class.is_class(klass), ("%s is not a class"):format(klass))
      self.class = klass
   end
   function instance_of_checker:check(obj, _ctxt)
      if class.is_an(self.class, obj) then
         return true
      end

      return false, tostring(self)
   end
   function instance_of_checker:__tostring()
      return tostring(self.class)
   end
   types.instance_of = wrap(instance_of_checker)
end

do
   local implements_checker = class.class("implements_checker", ITypeChecker)
   function implements_checker:init(iface)
      assert(class.is_interface(iface), ("%s is not an interface"):format(iface))
      self.iface = iface
   end
   function implements_checker:check(obj, _ctxt)
      if class.is_an(self.iface, obj) then
         return true
      end

      return false, tostring(self)
   end
   function implements_checker:__tostring()
      return tostring(self.iface)
   end
   types.implements = wrap(implements_checker)
end

do
   local optional_checker = class.class("optional_checker", ITypeChecker)
   function optional_checker:init(checker)
      assert(is_type_checker(checker))
      self.checker = checker
   end
   function optional_checker:check(obj, ctxt)
      if obj == nil then
         return true
      end

      local ok, _err = self.checker:check(obj, ctxt)
      if not ok then
         return false, tostring(self)
      end

      return true
   end
   function optional_checker:__tostring()
      return ("optional<%s>"):format(self.checker)
   end
   types.optional = wrap(optional_checker)
end

do
   local keys_checker = class.class("keys_checker", ITypeChecker)
   function keys_checker:init(checker)
      assert(is_type_checker(checker))
      self.checker = checker
   end
   function keys_checker:check(obj, ctxt)
      if not types.table:check(obj, ctxt) then
         return false, "table"
      end

      for key, _ in pairs(obj) do
         ctxt:push(key)
         local ok, _err = self.checker:check(key)
         if not ok then
            return false, tostring(self)
         end
         ctxt:pop()
      end

      return true
   end
   function keys_checker:__tostring()
      return ("keys<%s>"):format(self.checker)
   end
   types.keys = wrap(keys_checker)
end

do
   local values_checker = class.class("values_checker", ITypeChecker)
   function values_checker:init(checker)
      assert(is_type_checker(checker))
      self.checker = checker
   end
   function values_checker:check(obj, ctxt)
      if not types.table:check(obj, ctxt) then
         return false, "table"
      end

      for key, val in pairs(obj) do
         ctxt:push_value(key, val)
         local ok, _err = self.checker:check(val)
         if not ok then
            return false, tostring(self)
         end
         ctxt:pop()
      end

      return true
   end
   function values_checker:__tostring()
      return ("values<%s>"):format(self.checker)
   end
   types.values = wrap(values_checker)
end

do
   local map_checker = class.class("map_checker", ITypeChecker)
   function map_checker:init(key_checker, value_checker)
      assert(is_type_checker(key_checker))
      assert(is_type_checker(value_checker))
      self.key_checker = key_checker
      self.value_checker = value_checker
   end
   function map_checker:check(obj, ctxt)
      if not types.table:check(obj, ctxt) then
         return false, "table"
      end

      for key, val in pairs(obj) do
         ctxt:push(key)
         local ok, _err = self.key_checker:check(key, ctxt)
         if not ok then
            return false, tostring(self)
         end
         ctxt:pop()

         ctxt:push_value(key, val)
         ok, _err = self.value_checker:check(val, ctxt)
         if not ok then
            return false, tostring(self)
         end
         ctxt:pop()
      end

      return true
   end
   function map_checker:__tostring()
      return ("map<%s, %s>"):format(self.key_checker, self.value_checker)
   end
   types.map = wrap(map_checker)
end

function types.set(value_checker)
   return types.map(types.boolean, value_checker)
end

do
   local any_checker = class.class("any_checker", ITypeChecker)
   function any_checker:init(...)
      local checkers = { ... }
      for _, checker in ipairs(checkers) do
         assert(is_type_checker(checker))
      end
      self.checkers = checkers
   end
   function any_checker:check(obj, ctxt)
      for _, checker in ipairs(self.checkers) do
         if checker(obj, ctxt) then
            return true
         end
      end
      return false, tostring(self)
   end
   function any_checker:__tostring()
      local s = {}
      for i, checker in ipairs(self.checkers) do
         if i > 10 then
            s[#s+1] = "..."
            break
         end
         s[#s+1] = tostring(checker)
      end
      return ("any<%s>"):format(table.concat(", "))
   end
   types.any = wrap(any_checker)
end

do
   local all_checker = class.class("all_checker", ITypeChecker)
   function all_checker:init(...)
      local checkers = { ... }
      for _, checker in ipairs(checkers) do
         assert(is_type_checker(checker))
      end
      self.checkers = checkers
   end
   function all_checker:check(obj, ctxt)
      for _, checker in ipairs(self.checkers) do
         local ok, err = checker(obj, ctxt)
         if not ok then
            return false, err
         end
      end
      return true
   end
   function all_checker:__tostring()
      local s = {}
      for i, checker in ipairs(self.checkers) do
         if i > 10 then
            s[#s+1] = "..."
            break
         end
         s[#s+1] = tostring(checker)
      end
      return ("all<%s>"):format(table.concat(", "))
   end
   types.all = wrap(all_checker)
end

local function print_fields(fields)
   local s = {}
   local i = 0
   for key, checker in pairs(fields) do
      if i > 10 then
         s[#s+1] = "..."
         break
      end
      s[#s+1] = get_name(key) .. "=" .. tostring(checker)
      i = i + 1
   end
   return table.concat(s, ", ")
end

do
   local fields_checker = class.class("fields_checker", ITypeChecker)
   function fields_checker:init(fields)
      for _, checker in pairs(fields) do
         assert(is_type_checker(checker))
      end
      self.fields = fields
   end
   function fields_checker:check(obj, ctxt)
      if not types.table:check(obj, ctxt) then
         return false, "table"
      end

      for key, checker in pairs(self.fields) do
         ctxt:push(key, obj[key])
         local ok, err = checker:check(obj[key], ctxt)
         if not ok then
            return false, err
         end
         ctxt:pop()
      end

      return true
   end
   function fields_checker:__tostring()
      return ("fields<%s>"):format(print_fields(self.fields))
   end
   types.fields = wrap(fields_checker)
end

do
   local fields_strict_checker = class.class("fields_strict_checker", ITypeChecker)
   function fields_strict_checker:init(fields)
      for _, checker in pairs(fields) do
         assert(is_type_checker(checker))
      end
      self.fields = fields
   end
   function fields_strict_checker:check(obj, ctxt)
      if not types.table:check(obj, ctxt) then
         return false, "table"
      end

      for key, val in pairs(obj) do
         local checker = self.fields[key]
         if not checker then
            return false, ("table with key \"%s\""):format(key)
         end

         ctxt:push(key, val)
         local ok, err = checker(val, ctxt)
         if not ok then
            return false, err
         end
         ctxt:pop()
      end

      return true
   end
   function fields_strict_checker:__tostring()
      return ("fields<%s>"):format(print_fields(self.fields))
   end
   types.fields_strict = wrap(fields_strict_checker)
end

function types.check(obj, checker, verbose)
   assert(is_type_checker(checker))
   local ctxt = make_ctxt()
   local success, needed_ty = checker:check(obj, ctxt)
   if not success then
      needed_ty = needed_ty or "<unknown>"
      local s
      if verbose then
         s = ctxt:make_trail(obj)
      else
         local entry = ctxt.stack[#ctxt.stack]
         if entry then
            s = get_name(entry.value or entry.key)
         else
            s = get_name(obj)
         end
      end
      return false, ("Typecheck failed - Value is not of type \"%s\": %s"):format(needed_ty, s)
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
