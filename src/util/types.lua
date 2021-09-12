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
   newline = " ", indent = "", max_length = 32,
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
   local s = { get_name(obj) }
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

local function print_list(list)
   local s = {}
   for i, val in ipairs(list) do
      if i > 10 then
         s[#s+1] = "..."
         break
      end
      s[#s+1] = tostring(val)
   end
   return table.concat(s, ", ")
end

local function print_fields(fields)
   local s = {}
   local i = 0
   for key, val in pairs(fields) do
      if i > 10 then
         s[#s+1] = "..."
         break
      end
      s[#s+1] = get_name(key) .. "=" .. get_name(val)
      i = i + 1
   end
   return table.concat(s, ", ")
end

local function type_error(ty, inner)
   local s = ("Value is not of type \"%s\""):format(ty)
   if inner then
      s = s .. "(" .. inner .. ")"
   end
   return s
end

--
-- single-value checkers
--

local ITypeChecker = class.interface("ITypeChecker", { check = "function" })

local function is_type_checker(obj, ctxt)
   if not class.is_an(ITypeChecker, obj) then
      return false, ("%s is not a type checker"):format(obj, ctxt)
   end
   return true
end
types.is_type_checker = is_type_checker

do
   local any_checker = class.class("primitive_checker", ITypeChecker)
   function any_checker:check(obj, _ctxt)
      return true
   end
   function any_checker:__tostring()
      return "any"
   end
   types.any = any_checker:new()
end

local primitive_checker = class.class("primitive_checker", ITypeChecker)
function primitive_checker:init(ty)
   self.type = ty
end
function primitive_checker:check(obj, ctxt)
   if type(obj, ctxt) == self.type then
      return true
   end
   return false, type_error(self)
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

local function is_nan(obj, ctxt)
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
      return false, type_error(self)
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
      return false, type_error(self)
   end
   function nan_checker:__tostring()
      return "nan"
   end
   types.nan = nan_checker:new()
end

do
   local int_checker = class.class("int_checker", ITypeChecker)
   function int_checker:check(obj, _ctxt)
      if math.type(obj) == "integer" and not is_nan(obj) then
         return true
      end
      return false, type_error(self)
   end
   function int_checker:__tostring()
      return "int"
   end
   types.int = int_checker:new()
end

do
   local float_checker = class.class("float_checker", ITypeChecker)
   function float_checker:check(obj, _ctxt)
      if math.type(obj) == "float" and not is_nan(obj) then
         return true
      end
      return false, type_error(self)
   end
   types.float = float_checker:new()
end

do
   local IDENTIFIER_REGEX = "^[a-z][_a-z0-9]*$"

   local identifier_checker = class.class("identifier_checker", ITypeChecker)
   function identifier_checker:check(obj, ctxt)
      if not types.string:check(obj, ctxt) then
         return false, type_error(self)
      end

      if not obj:match(IDENTIFIER_REGEX) then
         return false, type_error(self)
      end

      return true
   end
   function identifier_checker:__tostring()
      return "identifier"
   end
   types.identifier = identifier_checker:new()
end

local ID_REGEX = "^[_a-z][_a-z0-9]+%.[_a-z][_a-z0-9]+$"
do
   local data_type_id_checker = class.class("data_type_id_checker", ITypeChecker)
   function data_type_id_checker:check(obj, ctxt)
      if not types.string:check(obj, ctxt) then
         return false, type_error(self)
      end

      if not obj:match(ID_REGEX) then
         return false, type_error(self)
      end

      return true
   end
   function data_type_id_checker:__tostring()
      return "data_type_id"
   end
   types.data_type_id = data_type_id_checker:new()
end

do
   local path_checker = class.class("path_checker", ITypeChecker)
   function path_checker:check(obj, ctxt)
      if not types.string:check(obj, ctxt) then
         return false, type_error(self)
      end

      return true
   end
   function path_checker:__tostring()
      return "path"
   end
   types.path = path_checker:new()
end

do
   local locale_id_checker = class.class("locale_id_checker", ITypeChecker)
   function locale_id_checker:check(obj, ctxt)
      if not types.string:check(obj, ctxt) then
         return false, type_error(self)
      end

      return true
   end
   function locale_id_checker:__tostring()
      return "locale_id"
   end
   types.locale_id = locale_id_checker:new()
end

do
   local require_path_checker = class.class("require_path_checker", ITypeChecker)
   function require_path_checker:check(obj, ctxt)
      if not types.string:check(obj, ctxt) then
         return false, type_error(self)
      end

      return true
   end
   function require_path_checker:__tostring()
      return "require_path"
   end
   types.require_path = require_path_checker:new()
end

do
   local type_type_checker = class.class("type_type_checker", ITypeChecker)
   function type_type_checker:check(obj, _ctxt)
      if is_type_checker(obj) then
         return true
      end

      return false, type_error(self)
   end
   function type_type_checker:__tostring()
      return "type checker"
   end
   types.type = type_type_checker:new()
end

do
   local class_type_checker = class.class("class_type_checker", ITypeChecker)
   function class_type_checker:check(obj, _ctxt)
      if class.is_class(obj) then
         return true
      end

      return false, type_error(self)
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

      return false, type_error(self)
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

      return false, type_error(self)
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
   local gt_checker = class.class("gt_checker", ITypeChecker)
   function gt_checker:init(checker, comp)
      assert(is_type_checker(checker))
      self.checker = checker
      self.comp = comp
   end
   function gt_checker:check(obj, ctxt)
      local ok, err = self.checker:check(obj, ctxt)
      if not ok then
         return false, type_error(self, err)
      end

      if obj > self.comp then
         return true
      end

      return false, type_error(self)
   end
   function gt_checker:__tostring()
      return ("%s > %s"):format(self.checker, self.comp)
   end
   types.gt = wrap(gt_checker)
end

do
   local lt_checker = class.class("lt_checker", ITypeChecker)
   function lt_checker:init(checker, comp)
      assert(is_type_checker(checker))
      self.checker = checker
      self.comp = comp
   end
   function lt_checker:check(obj, ctxt)
      local ok, err = self.checker:check(obj, ctxt)
      if not ok then
         return false, type_error(self, err)
      end

      if obj < self.comp then
         return true
      end

      return false, type_error(self)
   end
   function lt_checker:__tostring()
      return ("%s < %s"):format(self.checker, self.comp)
   end
   types.lt = wrap(lt_checker)
end

do
   local gteq_checker = class.class("gteq_checker", ITypeChecker)
   function gteq_checker:init(checker, comp)
      assert(is_type_checker(checker))
      self.checker = checker
      self.comp = comp
   end
   function gteq_checker:check(obj, ctxt)
      local ok, err = self.checker:check(obj, ctxt)
      if not ok then
         return false, type_error(self, err)
      end

      if obj >= self.comp then
         return true
      end

      return false, type_error(self)
   end
   function gteq_checker:__tostring()
      return ("%s >= %s"):format(self.checker, self.comp)
   end
   types.gteq = wrap(gteq_checker)
end

do
   local lteq_checker = class.class("lteq_checker", ITypeChecker)
   function lteq_checker:init(checker, comp)
      assert(is_type_checker(checker))
      self.checker = checker
      self.comp = comp
   end
   function lteq_checker:check(obj, ctxt)
      local ok, err = self.checker:check(obj, ctxt)
      if not ok then
         return false, type_error(self, err)
      end

      if obj <= self.comp then
         return true
      end

      return false, type_error(self)
   end
   function lteq_checker:__tostring()
      return ("%s <= %s"):format(self.checker, self.comp)
   end
   types.lteq = wrap(lteq_checker)
end

function types.positive(checker)
   return types.gteq(checker, 0)
end

function types.negative(checker)
   return types.lt(checker, 0)
end

types.uint = types.positive(types.int)

do
   local range_checker = class.class("range_checker", ITypeChecker)
   function range_checker:init(checker, min, max)
      assert(is_type_checker(checker))
      self.checker = checker
      self.min = min
      self.max = max
   end
   function range_checker:check(obj, ctxt)
      local ok, err = self.checker:check(obj, ctxt)
      if not ok then
         return false, type_error(self, err)
      end

      if obj >= self.min and obj <= self.max then
         return true
      end

      return false, type_error(self)
   end
   function range_checker:__tostring()
      return ("%s in [%s, %s]"):format(self.checker, self.min, self.max)
   end
   types.range = wrap(range_checker)
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

      return false, type_error(self)
   end
   function enum_checker:__tostring()
      return "enum type"
   end
   types.enum = wrap(enum_checker)
end

do
   local class_checker = class.class("class_checker", ITypeChecker)
   function class_checker:init(klass)
      assert(class.is_class(klass), ("%s is not a class"):format(klass))
      self.class = klass
   end
   function class_checker:check(obj, _ctxt)
      if class.is_an(self.class, obj) then
         return true
      end

      return false, type_error(self)
   end
   function class_checker:__tostring()
      return tostring(self.class)
   end
   types.class = wrap(class_checker)
end

do
   local interface_checker = class.class("interface_checker", ITypeChecker)
   function interface_checker:init(iface)
      assert(class.is_interface(iface), ("%s is not an interface"):format(iface))
      self.iface = iface
   end
   function interface_checker:check(obj, _ctxt)
      if class.is_an(self.iface, obj) then
         return true
      end

      return false, type_error(self)
   end
   function interface_checker:__tostring()
      return tostring(self.iface)
   end
   types.interface = wrap(interface_checker)
end

do
   local class_type_implementing_checker = class.class("class_type_implementing_checker", ITypeChecker)
   function class_type_implementing_checker:init(iface)
      assert(class.is_interface(iface), ("%s is not a interface"):format(iface))
      self.iface = iface
   end
   function class_type_implementing_checker:check(obj, _ctxt)
      if not class.is_class(obj) then
         return false, type_error(self)
      end

      if class.uses_interface(obj, self.iface) then
         return true
      end

      return false, type_error(self)
   end
   function class_type_implementing_checker:__tostring()
      return ("<? implements %s>"):format(self.iface)
   end
   types.class_type_implementing = wrap(class_type_implementing_checker)
end

do
   local iterator_checker = class.class("iterator_checker", ITypeChecker)
   function iterator_checker:init(ty)
      self.type = ty
   end
   function iterator_checker:check(obj, ctxt)
      if type(obj) == "table" and tostring(obj) == "<generator>" then
         -- TODO account for type of inner object
         return true
      end

      return false, type_error(self)
   end
   function iterator_checker:__tostring()
      return ("iterator<%s>"):format(self.ty)
   end
   types.iterator = wrap(iterator_checker)
end

local optional_checker = class.class("optional_checker", ITypeChecker)
function optional_checker:init(checker)
   assert(is_type_checker(checker))
   self.checker = checker
end
function optional_checker:check(obj, ctxt)
   if obj == nil then
      return true
   end

   local ok, err = self.checker:check(obj, ctxt)
   if not ok then
      return false, type_error(self, err)
   end

   return true
end
function optional_checker:__tostring()
   return ("optional<%s>"):format(self.checker)
end
types.optional = wrap(optional_checker)

do
   local tuple_checker = class.class("tuple_checker", ITypeChecker)
   function tuple_checker:init(checkers)
      for i, checker in ipairs(checkers) do
         if not is_type_checker(checker) then
            error(("Object for tuple index '%s' is not a type checker (%s)"):format(i, checker))
         end
      end
      self.checkers = checkers
   end
   function tuple_checker:check(obj, ctxt)
      if not types.table:check(obj, ctxt) then
         return false, type_error(self)
      end

      for i, checker in ipairs(self.checkers) do
         local val = obj[i]
         ctxt:push(i, val)
         local ok, err = checker:check(val, ctxt)
         if not ok then
            return false, type_error(self, err)
         end
         ctxt:pop()
      end

      return true
   end
   function tuple_checker:__tostring()
      return ("tuple<%s>"):format(print_list(self.checkers))
   end
   types.tuple = wrap(tuple_checker)
end

do
   local keys_checker = class.class("keys_checker", ITypeChecker)
   function keys_checker:init(checker)
      assert(is_type_checker(checker))
      self.checker = checker
   end
   function keys_checker:check(obj, ctxt)
      if not types.table:check(obj, ctxt) then
         return false, type_error(self)
      end

      for key, _ in pairs(obj, ctxt) do
         ctxt:push(key)
         local ok, err = self.checker:check(key)
         if not ok then
            return false, type_error(self, err)
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
         return false, type_error(self)
      end

      for key, val in pairs(obj, ctxt) do
         ctxt:push(key, val)
         local ok, err = self.checker:check(val)
         if not ok then
            return false, type_error(self, err)
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
         return false, type_error(self)
      end

      for key, val in pairs(obj, ctxt) do
         ctxt:push(key)
         local ok, err = self.key_checker:check(key, ctxt)
         if not ok then
            return false, type_error(self, err)
         end
         ctxt:pop()

         ctxt:push(key, val)
         ok, err = self.value_checker:check(val, ctxt)
         if not ok then
            return false, type_error(self, err)
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
   local list_keys_checker = types.keys(types.uint)

   local list_checker = class.class("list_checker", ITypeChecker)
   function list_checker:init(checker)
      assert(is_type_checker(checker))
      self.checker = checker
   end
   function list_checker:check(obj, ctxt)
      if not types.table:check(obj, ctxt) then
         return false, type_error(self)
      end

      if #obj == 0 then
         return true
      end

      local ok, err = list_keys_checker:check(obj, ctxt)
      if not ok then
         return false, type_error(("table with integer keys (%s)"):format(err))
      end

      for i, val in ipairs(obj, ctxt) do
         ctxt:push(i, val)
         ok, err = self.checker:check(val, ctxt)
         if not ok then
            return false, err
         end
         ctxt:pop()
      end

      return true
   end
   function list_checker:__tostring()
      return ("list<%s>"):format(self.checker)
   end
   types.list = wrap(list_checker)
end

do
   local some_checker = class.class("some_checker", ITypeChecker)
   function some_checker:init(...)
      local checkers = { ... }
      for _, checker in ipairs(checkers) do
         assert(is_type_checker(checker))
      end
      self.checkers = checkers
   end
   function some_checker:check(obj, ctxt)
      for _, checker in ipairs(self.checkers) do
         if checker:check(obj, ctxt) then
            return true
         end
      end
      return false, type_error(self)
   end
   function some_checker:__tostring()
      local s = {}
      for i, checker in ipairs(self.checkers) do
         if i > 10 then
            s[#s+1] = "..."
            break
         end
         s[#s+1] = tostring(checker)
      end
      return ("some<%s>"):format(table.concat(s, ", "))
   end
   types.some = wrap(some_checker)
end

types.serializable = types.some(types["nil"], types.boolean, types.number, types.string, types.table)

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
         local ok, err = checker:check(obj, ctxt)
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
      return ("all<%s>"):format(print_list(self.checkers))
   end
   types.all = wrap(all_checker)
end

do
   local fields_checker = class.class("fields_checker", ITypeChecker)
   function fields_checker:init(fields, array_part)
      for key, checker in pairs(fields) do
         if not is_type_checker(checker) then
            error(("Object for field '%s' is not a type checker (%s)"):format(key, checker))
         end
      end
      if array_part then
         assert(is_type_checker(array_part))
      end
      self.fields = fields
      self.array_part = array_part
   end
   function fields_checker:check(obj, ctxt)
      if not types.table:check(obj, ctxt) then
         return false, type_error(self)
      end

      for key, checker in pairs(self.fields) do
         ctxt:push(key, obj[key])
         local ok, err = checker:check(obj[key], ctxt)
         if not ok then
            return false, err
         end
         ctxt:pop()
      end

      if self.array_part then
         for i, val in ipairs(self.fields) do
            ctxt:push(i, val)
            local ok, err = self.array_part:check(val, ctxt)
            if not ok then
               return false, err
            end
            ctxt:pop()
         end
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
      for key, checker in pairs(fields) do
         if not is_type_checker(checker) then
            error(("Object for field '%s' is not a type checker (%s)"):format(key, checker))
         end
      end
      self.fields = fields
   end
   function fields_strict_checker:check(obj, ctxt)
      if not types.table:check(obj, ctxt) then
         return false, type_error(self)
      end

      local remaining = table.set(table.keys(self.fields))
      for key, val in pairs(obj, ctxt) do
         local checker = self.fields[key]
         if not checker then
            return false, ("Table has superfluous key: \"%s\""):format(key)
         end

         ctxt:push(key, val)
         local ok, err = checker:check(val, ctxt)
         if not ok then
            return false, err
         end
         ctxt:pop()

         if remaining[key] then
            remaining[key] = nil
         end
      end

      local missing = next(remaining)
      if missing then
         local checker = self.fields[missing]
         if not class.is_an(optional_checker, checker) then
            return false, ("Table is missing required field '%s' of type '%s'"):format(missing, checker)
         end
      end

      return true
   end
   function fields_strict_checker:__tostring()
      return ("fields_strict<%s>"):format(print_fields(self.fields))
   end
   types.fields_strict = wrap(fields_strict_checker)
end

do
   local literal_checker = class.class("literal_checker", ITypeChecker)
   function literal_checker:init(...)
      self.literals = { ... }
   end
   function literal_checker:check(obj, ctxt)
      for _, literal in ipairs(self.literals) do
         if obj == literal then
            return true
         end
      end
      return false, type_error(self)
   end
   function literal_checker:__tostring()
      return ("literal<%s>"):format(print_list(self.literals))
   end
   types.literal = wrap(literal_checker)
end

local ty_color_value = types.range(types.int, 0, 255)
types.color = types.tuple {
   ty_color_value,
   ty_color_value,
   ty_color_value,
   types.optional(ty_color_value),
}

do
   local data_id_checker = class.class("data_id_checker", ITypeChecker)
   function data_id_checker:init(_type)
      self._type = _type
   end
   function data_id_checker:check(obj, ctxt)
      if not types.string:check(obj, ctxt) then
         return false, type_error(self)
      end

      if not obj:match(ID_REGEX) then
         return false, type_error(self)
      end

      return true
   end
   function data_id_checker:__tostring()
      return ("data_id<%s>"):format(self._type)
   end
   types.data_id = wrap(data_id_checker)
end

do
   local data_entry_checker = class.class("data_entry_checker", ITypeChecker)
   function data_entry_checker:init(_type)
      self._type = _type
   end
   function data_entry_checker:check(obj, ctxt)
      if not types.table:check(obj, ctxt) then
         return false, type_error(self)
      end

      if obj._type ~= self._type then
         return false, type_error(self)
      end

      return true
   end
   function data_entry_checker:__tostring()
      return ("data_entry<%s>"):format(self._type)
   end
   types.data_entry = wrap(data_entry_checker)
end

do
   local callback_checker = class.class("callback_checker", ITypeChecker)
   function callback_checker:init(...)
      local checkers = { ... }
      local args = {}
      -- TODO retvals
      -- for i=1, #checkers, 2 do
      --    local arg_name = checkers[i]
      --    local checker = checkers[i+1]
      --    assert(type(arg_name) == "string", ("Callback argument name must be string, got '%s'"):format(arg_name))
      --    assert(is_type_checker(checker))
      --    args[#args+1] = {name = arg_name, checker = checker}
      -- end
      self.args = args
   end
   function callback_checker:check(obj, ctxt)
      if types["function"]:check(obj, ctxt) then
         return true
      end

      return false, type_error(self)
   end
   function callback_checker:__tostring()
      return ("function<%s>"):format(print_list(self.args))
   end

   function types.callback(s)
      if s == nil then
         return types["function"]
      end
      return callback_checker:new(s)
   end
end

do
   local map_object_checker = class.class("map_object_checker", ITypeChecker)
   function map_object_checker:init(_type)
      assert(type(_type) == "string")
      self._type = _type
   end
   function map_object_checker:check(obj, ctxt)
      -- copied from MapObject.is_map_object()
      if not class.is_an("api.IMapObject", obj) then
         return false, type_error(self)
      end

      if self._type == "any" then
         return true
      end

      if self._type ~= obj._type then
         return false, ("Expected map object of type '%s', got '%s'"):format(self._type, obj._type)
      end

      return true
   end
   function map_object_checker:__tostring()
      return ("map_object<%s>"):format(self._type)
   end
   types.map_object = wrap(map_object_checker)
end

function types.check(obj, checker, verbose)
   assert(is_type_checker(checker))
   local ctxt = make_ctxt()
   local success, err = checker:check(obj, ctxt)
   if not success then
      err = err or "<unknown error>"
      local s
      if verbose then
         s = ctxt:make_trail(obj)
      else
         local entry = ctxt.stack[#ctxt.stack]
         if entry then
            s = get_name(entry.key)
            if entry.value then
               s = s .. " (" .. get_name(entry.value) .. ")"
            end
         else
            s = get_name(obj, ctxt)
         end
      end
      return false, ("%s: %s"):format(err, s)
   end
   return true
end

function types.wrap(checker)
   return function(obj, ctxt)
      return types.check(obj, checker)
   end
end

function types.wrap_strict(checker)
   return function(obj, ctxt)
      return assert(types.check(obj, checker))
   end
end

return types
