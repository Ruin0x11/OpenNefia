local CodeGenerator = require("api.CodeGenerator")
local EventTree = require ("api.EventTree")
local Log = require ("api.Log")
local env = require ("internal.env")
local fs = require("util.fs")
local Stopwatch = require("api.Stopwatch")
local ISerializable = require("api.ISerializable")
local binser = require("thirdparty.binser")

local data_table = class.class("data_table")

local function script_path()
   local frame = 1
   local going = true
   local str
   local info

   while going do
      info = debug.getinfo(frame, "S")
      if not info then
         return nil
      end
      str = info.source:sub(2)
      if str ~= "./internal/data.lua" then
         going = false
      end
      frame = frame + 1
   end
   return str, info.linedefined
end

function data_table:error(mes, level, ...)
   local file, line = script_path()
   mes = string.format(mes, ...)
   table.insert(self.errors,
                {
                   file = file,
                   line = line,
                   level = "error",
                   message = mes,
                }
   )
   error("data error: " .. mes, level)
end

function data_table:init()
    rawset(self, "errors", {})
    rawset(self, "defaults", {})
    rawset(self, "fallbacks", {})
    rawset(self, "no_save_fields", {})

    rawset(self, "inner", {})
    rawset(self, "inner_sorted", {})
    rawset(self, "index", {})
    rawset(self, "schemas", {})
    rawset(self, "metatables", {})
    rawset(self, "generates", {})
    rawset(self, "ext", {})

    rawset(self, "global_edits", {})
    rawset(self, "single_edits", {})
    rawset(self, "proxy_cache", setmetatable({}, { __mode = "kv" }))
end

function data_table:__inspect()
   return string.tostring_raw(self)
end

function data_table:clear()
   self:init()
end

function data_table:types(kind)
   local keys = table.keys(self.inner)
   if kind == "template" then
      -- Return only types with any "fields" declared.
      local pred = function(id)
         return #self.schemas[id].fields > 0
      end
      return fun.iter(keys):filter(pred):to_list()
   end
   return keys
end

local function add_index_field(self, dat, _type, field)
   if type(field) == "string" then field = {field} end
   for _, v in ipairs(field) do
      local index_key = dat[v]

      -- NOTE: If the field is missing, it is skipped for indexing.
      -- However, if it is specified and not unique, then an error is
      -- raised.
      if index_key ~= nil then
         local key = "by_" .. v
         self.index[_type][key] = self.index[_type][key] or {}

         local exist = self.index[_type][key][index_key]
         if exist ~= nil then
            if env.is_hotloading() then
               Log.warn("overwriting self.index value on '%s': '%s:%s = %s'", _type, v, index_key, exist._id)
               self.index[_type][key][index_key] = dat
            else
               self:error(string.format("self.index value on '%s' is not unique: '%s:%s = %s'", _type, v, index_key, exist._id))
            end
         else
            self.index[_type][key][index_key] = dat
         end
      end
   end
end

local function remove_index_field(self, dat, _type, field)
   if type(field) == "string" then field = {field} end
   for _, v in ipairs(field) do
      local index_key = dat[v]

      if index_key ~= nil then
         local key = "by_" .. v
         self.index[_type][key] = self.index[_type][key] or {}

         self.index[_type][key][index_key] = nil
      end
   end
end

function data_table:_add_index(_type, field)
   if not self.schemas[_type] then
      return
   end

   if self.schemas[_type].indexes[field] then
      return
   end

   -- TODO: verify is a valid field for this type
   self.schemas[_type].indexes[field] = true

   for _, dat in self[_type]:iter() do
      add_index_field(self, dat, _type, field)
   end
end

local function make_defaults(fields)
   -- Default values to use when instantiating an object/map object from this
   -- prototype.
   local result = {}

   -- Values that should not be copied from the prototype to the object/map
   -- object on creation, and thus won't get serialized. Examples include _ext
   -- and the events tables on map object prototypes like `base.chara`.
   local no_save_fields = table.set { "_ext", "_ordering" }

   for _, field in ipairs(fields) do
      local default = field.default
      if not field.no_fallback then
         if type(field.default) == "table" then
            local mt = getmetatable(field.default)
            if mt then
               if mt.__codegen_type == "block_string" then
                  default = field.default[1]
               end
            end
         end
         result[field.name] = default
      end
      if field.no_save then
         no_save_fields[field.name] = true
      end
   end

   return result, no_save_fields
end

local ty_schema = types.fields_strict {
   name = types.identifier,
   fields = types.list(
      types.fields_strict {
         name = types.string,
         template = types.optional(types.boolean),
         type = types.type,
         default = types.optional(types.any),
         doc = types.optional(types.string),
         no_fallback = types.optional(types.boolean),
         no_save = types.optional(types.boolean),
         indexed = types.optional(types.boolean)
      }
   ),
   fallbacks = types.optional(types.table),
   doc = types.optional(types.string),
   validation = types.optional(types.literal("strict", "permissive")),
   on_validate = types.optional(types.callback({"entry", types.table, "verbose", types.boolean}, {types.boolean, types.optional(types.string)}))
}

local ty_ext_table = types.map(types.some(types.interface_type, types.data_id("base.data_ext")), types.table)

function data_table:add_type(schema, params)
   assert(types.check(schema, ty_schema))
   schema.fallbacks = schema.fallbacks or {}
   schema.max_ordering = 100000
   schema.needs_resort = true
   schema.indexes = {}

   params = params or {}

   if not env.is_valid_ident(schema.name) then
      self:error("'%s' is not a valid identifier (must consist of lowercase letters, numbers and underscores only, cannot start with a number)", schema.name)
      return nil
   end

   local mod_name, loc = env.find_calling_mod()
   local _type = mod_name .. "." .. schema.name

   local checkers = {}
   local seen = table.set {}
   for i, field in ipairs(schema.fields) do
      if type(field.name) ~= "string" then
         error("Data type %s: missing field name (index %d)"):format(_type, i)
      end
      if seen[field.name] then
         error(("Data type %s: duplicate field name '%s' (index %d)"):format(_type, field.name, i))
      end
      if not types.is_type_checker(field.type) then
         error(("Data type %s: invalid type specified for field named '%s'"):format(_type, field.name))
      end
      if field.default then
         local ok, err = types.check(field.default, field.type)
         if not ok then
            error(("Data type %s: invalid default value for field '%s': '%s'"):format(_type, field.name, err))
         end
      end
      checkers[field.name] = field.type
      seen[field.name] = true

      if field.indexed then
         schema.indexes[field.name] = true
      end
   end

   -- Fields available on all types
   checkers._type = types.data_type_id
   checkers._id = types.data_type_id
   checkers._ext = types.optional(ty_ext_table)
   checkers._ordering = types.optional(types.number)

   if schema.validation == "permissive" then
      schema.type = types.fields(checkers)
   else
      schema.type = types.fields_strict(checkers)
   end

   schema.validate = function(obj, verbose)
      local ok, err = types.check(obj, schema.type, verbose)
      if ok and schema.on_validate then
         ok, err = schema.on_validate(obj, verbose)
      end
      if not ok then
         return false, ("Validation for data entry '%s:%s' failed: %s"):format(_type, obj._id or "<???>", err)
      end
      return true
   end

   if env.is_hotloading() and self.schemas[_type] then
      Log.debug("In-place update of type %s", _type)

      schema.indexes = self.schemas[_type].indexes
      if loc then
         schema._defined_in = {
            relative = fs.normalize(loc.short_src),
            line = loc.lastlinedefined
         }
      else
         schema._defined_in = {
            relative = ".",
            line = 0
         }
      end
      table.replace_with(self.schemas[_type], schema)

      local defaults, no_save_fields = make_defaults(schema.fields)
      self.defaults[_type] = defaults
      self.fallbacks[_type] = table.merge(table.deepcopy(schema.fallbacks, defaults))
      self.no_save_fields[_type] = no_save_fields
      return
   end

   local metatable = params.interface or {}
   metatable._type = _type

   local generate = params.generates or nil

   if loc then
      schema._defined_in = {
         relative = fs.normalize(loc.short_src),
         line = loc.lastlinedefined
      }
   else
      schema._defined_in = {
         relative = ".",
         line = 0
      }
   end

   self.inner[_type] = {}
   self.inner_sorted[_type] = {}
   self.index[_type] = {}
   self.schemas[_type] = schema
   self.metatables[_type] = metatable
   self.generates[_type] = generate

   self.global_edits[_type] = EventTree:new()

   local defaults, no_save_fields = make_defaults(schema.fields)
   self.defaults[_type] = defaults
   self.fallbacks[_type] = table.merge(table.deepcopy(schema.fallbacks, defaults))
   self.no_save_fields[_type] = no_save_fields
end

-- Apply data edits.
--
-- This system is here for mods that modify existing data added by other mods in
-- a nondestructive manner. It takes the original copy of the data and applies a
-- sequence of edits to produce new values. That way, if anything in the chain
-- of edits is changed with a hotload, the entire process can be repeated from
-- scratch without a program restart.
function data_table:run_all_edits()
   Log.debug("Running all data edits.")
   for _type, tree in pairs(self.global_edits) do
      for k, v in self[_type]:iter() do
         -- TODO: store base separately
         -- TODO: this does not deepcopy proto, so originals are lost
         self[_type][k] = tree(v) -- TODO modify event tree for args
      end
   end
end

function data_table:run_edits_for(_type, _id)
   self[_type][_id] = self.global_edits[_type](self[_type][_id])
end

function data_table:validate_all(verbose)
   local errors = {}
   for _, _type, proxy in self:iter() do
      for _, entry in proxy:iter() do
         local ok, err = proxy:validate(entry, verbose)
         if not ok then
            errors[#errors+1] = { _type = _type, _id = entry._id, error = err }
         end
      end
   end
   return errors
end

local function sort_data_entries(a, b)
   if a._ordering == b._ordering then
      return a._id < b._id
   end
   return a._ordering < b._ordering
end

function data_table:sort_all()
   local errors = {}
   local inner = self.inner
   local sw = Stopwatch:new("info")
   for _type, _ in pairs(inner) do
      self:sort_type(_type)
   end
   sw:p("data:sort_all()")
   return errors
end

function data_table:sort_type(_type)
   local src = self.inner[_type]
   local dst = {}
   assert(src, "Unknown type")
   for _, entry in pairs(src) do
      table.insert(dst, entry)
   end
   table.sort(dst, sort_data_entries)
   self.inner_sorted[_type] = dst
   self.schemas[_type].needs_resort = false
end

function data_table:replace(dat)
   local mod_name = env.find_calling_mod()
   local _id = dat._id
   local _type = dat._type
   local full_id = mod_name .. "." .. _id

   if not self.inner[_type][full_id]  then
      self:error("ID does not exist for type '%s': '%s'", _type, full_id)
   end

   Log.debug("Replacing %s:%s", _type, full_id)
   self.inner[_type][full_id] = nil
   self:add(dat)
end

local function make_ext_fallback(dat)
   local fields = dat.fields or {}

   local ext = make_defaults(fields)

   return ext
end

local data_entry_mt = {
   __serial_id = "data_entry",
   __serial_opts = {
      load_type = "reference"
   }
}
data_entry_mt.__index = data_entry_mt

local function data_entry_serialize(self)
   print("SERIALID", rawget(self, "_type"), rawget(self, "_id"))
   return rawget(self, "_type"), rawget(self, "_id")
end

local function data_entry_deserialize(_type, _id)
   print("GETDATAENTRY", package.loaded["internal.data"][_type][_id])
   return package.loaded["internal.data"][_type][_id]
end

if not binser.hasRegistry("data_entry") then
   binser.register("data_entry", "data_entry", data_entry_serialize, data_entry_deserialize)
end

function data_table:add(dat)
   local mod_name, loc = env.find_calling_mod()

   local _id = dat._id
   local _type = dat._type

   if not (string.nonempty(_id) and string.nonempty(_type)) then
      self:error("Missing _id (%s) or _type (%s)", "error", tostring(_id), tostring(_type))
      return nil
   end

   if not env.is_valid_ident(_id) then
      self:error("'%s' is not a valid identifier (must consist of lowercase letters, numbers and underscores only, cannot start with a number)", 3, _id)
      return nil
   end

   local _schema = self.schemas[_type]

   if _schema == nil then
      self:error("No type registered for " .. _type)
      return nil
   end

   dat = table.merge_missing(dat, self.defaults[_type])

   -- Verify extension fields.
   if dat._ext then
      -- Convert extensions in list part to blank-parameter ones in map part
      --
      -- _ext = {
      --    IItemFromChara
      -- }
      --
      -- _ext = {
      --    [IItemFromChara] = {}
      -- }
      --
      -- This is for easier querying by always being able to do
      -- data._ext[aspect].
      local move_to_key = {}
      for k, v in pairs(dat._ext) do
         if type(k) == "number" then
            table.insert(move_to_key, k)
         end
      end
      for _, k in ipairs(move_to_key) do
         local v = dat._ext[k]
         dat._ext[v] = {}
         dat._ext[k] = nil
      end

      for k, v in pairs(dat._ext) do
         if type(k) == "string" then
            -- This is a base.data_ext identifier.
            if not self["base.data_ext"][k] then
               self:error("No data extension (base.data.ext) with ID " .. k .. " was registered yet.")
            end
         elseif type(k) == "table" then
            -- This is an aspect.
         end
      end
   end

   local full_id = mod_name .. "." .. _id

   Log.trace("Adding data entry %s:%s", _type, full_id)

   if self.inner[_type][full_id] ~= nil then
      if env.is_hotloading() then
         Log.debug("In-place update of %s:%s", _type, full_id)
         dat._id = full_id

         local Event = require("api.Event")
         Event.trigger("base.before_hotload_prototype", {old=self.inner[_type][full_id], new=dat})

         dat._ordering = self.inner[_type][full_id]._ordering

         table.replace_with(self.inner[_type][full_id], dat)
         self:run_edits_for(_type, full_id)

         for field, _ in pairs(_schema.indexes) do
            remove_index_field(self, dat, _type, field)
            add_index_field(self, dat, _type, field)
         end

         if _type == "base.data_ext" then
            self.ext[full_id] = make_ext_fallback(dat)
         end

         Event.trigger("base.on_hotload_prototype", {entry=dat})

         return dat
      else
         self:error(("ID is already taken on type '%s': '%s'"):format(_type, full_id))
         return nil
      end
   end

   if dat._ordering then
      if type(dat._ordering) ~= "number" then
         self:error(("_ordering field must be number, got %s (%s)"):format(dat._ordering, full_id))
         return nil
      end
      _schema.max_ordering = math.max(_schema.max_ordering, dat._ordering)
   else
      _schema.max_ordering = _schema.max_ordering + 1000
      dat._ordering = _schema.max_ordering
   end

   -- TODO fallbacks and prototype_fallbacks should be separate
   self.inner[_type][full_id] = dat

   for field, _ in pairs(_schema.indexes) do
      add_index_field(self, dat, _type, field)
   end

   dat._id = full_id
   setmetatable(dat, data_entry_mt)

   if _type == "base.data_ext" then
      self.ext[full_id] = make_ext_fallback(dat)
   end

   _schema.needs_resort = true

   return dat
end

function data_table:make_template(_type, opts)
   if not self.schemas[_type] then
      error(("No such type: '%s'"):format(_type))
   end

   opts = opts or {}
   opts.scope = opts.scope or "template"
   if opts.comments == nil then
      opts.comments = false
   end
   if opts.snippets == nil then
      opts.snippets = false
   end

   local gen = CodeGenerator:new()
   local snippet_index = 1

   gen:write("data:add ")
   gen:write_table_start()
   gen:write_key_value("_type", _type)

   local _id = "default"
   if opts.snippets then
      _id = ("${%d:%s}"):format(snippet_index, _id)
      snippet_index = snippet_index + 1
   end
   gen:write_key_value("_id", _id)

   local first = true
   local did_comment
   local write_fields = function(pred)
      for _, field in ipairs(self.schemas[_type].fields) do
         local is_in_scope = opts.scope == "all" or field.template
         local do_write = pred(field) and is_in_scope
         if do_write then
            if first then
               gen:tabify()
               first = false
            elseif did_comment then
               gen:tabify()
            end
            local do_comment = opts.comments and field.doc
            if do_comment then
               gen:tabify()
               gen:write_comment(field.doc, {type="docstring"})
               local ty = field.type
               if ty == nil and field.default ~= nil then
                  ty = type(field.default)
               end
               if ty then
                  gen:write_comment(("@type %s"):format(ty), {type="docstring"})
               end
            end

            local value = field.default
            if opts.snippets then
               if type(value) == "string" then
                  value = string.format("${%d:%s}", snippet_index, value)
               else
                  local gen2 = CodeGenerator:new()
                  gen2:write_value(value)
                  value = tostring(gen2):gsub("([}])", "\\%1")
                  value = string.format("${%d:%s}", snippet_index, value)
                  value = CodeGenerator.gen_literal(value)
               end
               snippet_index = snippet_index + 1
            end
            gen:write_key_value(field.name, value)

            did_comment = do_comment
         end
      end
   end

   -- group fields with documentation first
   write_fields(function(field) return field.doc ~= nil end)
   write_fields(function(field) return field.doc == nil end)

   if opts.scope == "optional_commented" then
      local first = true
      local write_fields = function(pred)
         local prev_comment
         for _, field in ipairs(self.schemas[_type].fields) do
            local do_comment = true
            local do_write = pred(field) and opts.scope == "optional_commented"
               and not field.default and not field.template
            if do_write then
               if first then
                  gen:tabify()
                  gen:tabify()
                  gen:tabify()
                  first = false
               end
               do_comment = opts.comments and field.doc
               if do_comment then
                  if not prev_comment then
                     gen:tabify()
                  end
                  gen:write_comment(field.doc, {type="docstring"})
                  local ty = field.type
                  if ty == nil and field.default ~= nil then
                     ty = type(field.default)
                  end
                  if ty then
                     gen:write_comment(("@type %s"):format(ty), {type="docstring"})
                  end
               end
               local gen2 = CodeGenerator:new()
               gen2:write_key_value(field.name, field.default)
               gen:write_comment(tostring(gen2))

               if do_comment then
                  gen:tabify()
               end
            end
            prev_comment = do_comment
         end
      end

      -- group fields with documentation first
      write_fields(function(field) return field.doc ~= nil end)
      write_fields(function(field) return field.doc == nil end)
   end

   gen:write_table_end()
   if opts.snippets then
      gen:write("${0}")
   end

   return tostring(gen)
end

function data_table:iter()
   return fun.iter(table.keys(self.schemas)):map(function(ty) return ty, self[ty] end)
end

function data_table:add_multi(_type, list)
   for _, dat in ipairs(list) do
      dat._type = _type
      self:add(dat)
   end
end

function data_table:has_type(_type)
   return self.inner[_type] ~= nil
end

local proxy = class.class("proxy", ISerializable)
-- WARNING: This serial ID is reserved! Do not change!
proxy.__serial_id = "data_proxy"
proxy.__serial_opts = {
   load_type = "reference"
}

function proxy:init(_type, data)
   rawset(self, "_type", _type)
   rawset(self, "data", data)
end

function proxy:__newindex(k, v)
   return nil
end

function proxy:serialize()
   return rawget(self, "_type")
end

function proxy.deserialize(_type)
   return package.loaded["internal.data"][_type]
end

function proxy:edit(name, func)
   assert(type(name) == "string", "edit() must be passed a unique descriptor")
   assert(type(func) == "function", "edit() must be passed a function")

   local mod_name = env.find_calling_mod()

   local full_name = mod_name .. ": " .. name

   if env.is_hotloading() then
      -- TODO: determine edit order and recalculate prototype
      Log.info("In-place edit update of %s", full_name)
      assert(self.data.global_edits[self._type]:replace(full_name, func))

      -- TODO: rerun all edits at end of hotload
      data:run_all_edits()
   else
      assert(self.data.global_edits[self._type]:insert(10000, func, full_name),
             "Edit name is already taken: " .. full_name)
   end
end

function proxy:find_by(index_field, value)
   if not self.data.index[self._type] then
      error("Unknown type " .. self._type)
   end
   if self.data.index[self._type]["by_" .. index_field] ~= nil then
      return self.data.index[self._type]["by_" .. index_field][value]
   end

   return nil
end

function proxy:__index(k)
   local exist = rawget(proxy, k)
   if exist then return exist end

   if k == "_defined_in" then
      return self.data.schemas[self._type]._defined_in
   end

   if k == "doc" then
      return self.data.schemas[self._type].doc
   end

   if k == "_fallbacks" then
      return self.data.fallbacks[self._type]
   end

   if k == "_no_save_fields" then
      return self.data.no_save_fields[self._type]
   end

   local _type = rawget(self, "_type")
   local for_type = rawget(self.data.inner, _type)
   if for_type == nil then
      return nil
   end

   -- Permit substituting an instance of a data type if it is passed
   -- in instead of a string key.
   if type(k) == "table"
      and k._type == _type
      and for_type[k._id]
   then
      return k
   end

   return for_type[k]
end

function proxy:interface()
   return self.data.metatables[self._type]
end

function proxy:type()
   return self.data.schemas[self._type].type
end

function proxy:validate(obj, verbose)
   return self.data.schemas[self._type].validate(obj, verbose)
end

function proxy:ensure(k)
   local it = self[k]
   if it == nil then
      error(string.format("No instance of '%s' with ID '%s' was found.", self._type, k))
   end
   return it
end

function proxy:ext(k, ext_id)
   self.data["base.data_ext"]:ensure(ext_id)
   local it = self:ensure(k)
   local ext = it._ext and it._ext[ext_id]
   if ext == nil then
      local fallback = self.data.ext[ext_id]
      ext = fallback
   end
   return ext
end

local function iter(state, prev_index)
   if state.iter == nil then
      return nil
   end

   local next_index, dat = state.iter(state.state, prev_index)

   if next_index == nil then
      return nil
   end

   return next_index, dat
end

function proxy:iter()
   if self.data.schemas[self._type].needs_resort then
      self.data:sort_type(self._type)
   end
   local inner_iter, inner_state, inner_index = ipairs(self.data.inner_sorted[self._type])
   return fun.wrap(iter, {iter=inner_iter,state=inner_state}, inner_index)
end

function proxy:print()
   local list = {}
   for _, v in self:iter() do
      list[#list+1] = { v._id }
   end
   return table.concat(table.print(list, { header = { "ID" }, sort = 1 }), "\n")
end

function data_table:__index(k)
   -- This always returns a table instead of nil so
   -- that references to data type tables can be
   -- populated later, after mods have finished
   -- loading. As an example, if this returned nil if
   -- a type was nonexistent, it would be necessary to
   -- initialize things like the sound manager only
   -- after mods have been loaded.
   if data_table[k] then return data_table[k] end
   if self.proxy_cache[k] then
      return self.proxy_cache[k]
   end
   self.proxy_cache[k] = proxy:new(k, self)
   return self.proxy_cache[k]
end

function data_table:__newindex(k, v)
end

return data_table, { inner_defns = { proxy } }
