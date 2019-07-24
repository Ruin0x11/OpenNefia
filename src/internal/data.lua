local Log = require ("api.Log")
local EventTree = require ("api.EventTree")
local env = require ("internal.env")
local schema = require ("thirdparty.schema")
local fun = require ("thirdparty.fun")

if env.is_hotloading() then
   return "no_hotload"
end

local data = {
   errors = {}
}

function script_path()
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

function data:error(mes, ...)
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
   error("data: " .. mes)
end

local stage = nil
local inner = {}
local schemas = {}
local metatables = {}
local generates = {}
local strict = false

local global_edits = {}
local single_edits = {}

-- HACK: separate into Data API and internal.data
function data:clear()
   inner = {}
   schemas = {}
   metatables = {}
end

local function add_index_field(dat, _type, field)
   if type(field) == "string" then field = {field} end
   for _, v in ipairs(field) do
      local index_key = dat[v]

      -- NOTE: If the field is missing, it is skipped for indexing.
      -- However, if it is specified and not unique, then an error is
      -- raised.
      if index_key ~= nil then
         local key = "by_" .. v
         inner[_type][key] = inner[_type][key] or {}

         if inner[_type][key][index_key] ~= nil then
            self:error(string.format("Index key '%s' on '%s' is not unique: '%s'", v, full_id, index_key))
         else
            inner[_type][key][index_key] = dat
         end
      end
   end
end

function data:add_index(_type, field)
   if schemas[_type].indexes[field] then
      return
   end

   -- TODO: verify is a valid field for this type
   schemas[_type].indexes[field] = true

   for _, dat in data[_type]:iter() do
      add_index_field(dat, _type, field)
   end
end

function data:add_type(schema, params)
   params = params or {}

   local mod_name = env.find_calling_mod()
   local _type = mod_name .. "." .. schema.name

   if env.is_hotloading() and schemas[_type] then
      return
   end

   schema.indexes = {}

   local metatable = params.interface or {}
   metatable._type = _type

   local generate = params.generates or nil

   schemas[_type] = schema
   metatables[_type] = metatable
   generates[_type] = generate

   global_edits[_type] = EventTree:new()
end

function data:extend_type(type_id, delta)
end

function data:run_all_edits()
   Log.info("Running all data edits.")
   for _type, tree in pairs(global_edits) do
      for k, v in self[_type]:iter() do
         -- TODO: store base separately
         -- TODO: this does not deepcopy proto, so originals are lost
         self[_type][k] = tree(v) -- TODO modify event tree for args
      end
   end
end

function data:run_edits_for(_type, _id)
   self[_type][_id] = global_edits[_type](self[_type][_id])
end

function data:add(dat)
   -- if stage ~= "loading" then error("stop") end

   local mod_name = env.find_calling_mod()

   local _id = dat._id
   local _type = dat._type

   if not (string.nonempty(_id) and string.nonempty(_type)) then
      data:error("Missing _id (%s) or _type (%s)", tostring(_id), tostring(_type))
      return nil
   end

   local _schema = schemas[_type]

   if _schema == nil then
      data:error("No type registered for " .. _type)
      return nil
   end

   local errs = schema.CheckSchema(dat, _schema.schema)
   local failed = false

   for _, err in ipairs(errs) do
      local add = true

      if string.match(err.message, "^Superfluous value: ") then
         local path = tostring(err.path)
         if path == "_id"
            or path == "_type"
            or path == "_index_on"
         then
            add = false
         end
      end

      if add then
         failed = true
         -- self:error(tostring(err))
      end
   end

   if strict and failed then return nil end

   local full_id = mod_name .. "." .. _id

   inner[_type] = inner[_type] or {}

   if inner[_type][full_id] ~= nil then
      if env.is_hotloading() then
         Log.debug("In-place update of %s:%s", _type, full_id)
         dat._id = full_id
         table.replace_with(inner[_type][full_id], dat)
         self:run_edits_for(_type, full_id)
         return dat
      else
         Log.error("ID is already taken on type '%s': '%s'", _type, full_id)
         -- self:error(string.format("ID is already taken on type '%s': '%s'", _type, full_id))
         return nil
      end
   end

   inner[_type][full_id] = dat

   for field, _ in pairs(_schema.indexes) do
      add_index_field(dat, _type, field)
   end

   dat._id = full_id
   return dat
end

function data:add_multi(_type, list)
   for _, dat in ipairs(list) do
      dat._type = _type
      self:add(dat)
   end
end

local proxy = class.class("proxy")

function proxy:init(_type)
   rawset(self, "_type", _type)
end

function proxy:__newindex(k, v)
end

function proxy:edit(name, func)
   assert(type(name) == "string", "edit() must be passed a unique descriptor")
   assert(type(func) == "function", "edit() must be passed a function")

   local mod_name = env.find_calling_mod()

   local full_name = mod_name .. ": " .. name

   if env.is_hotloading() then
      -- TODO: determine edit order and recalculate prototype
      Log.info("In-place edit update of %s", full_name)
      assert(global_edits[self._type]:replace(full_name, func))

      -- TODO: rerun all edits at end of hotload
      data:run_all_edits()
   else
      assert(global_edits[self._type]:insert(10000, func, full_name),
             "Edit name is already taken: " .. full_name)
   end
end

function proxy:find_by(index, value)
   if not inner[self._type] then
      error("Unknown type " .. self._type)
   end
   if inner[self._type]["by_" .. index] ~= nil then
      return inner[self._type]["by_" .. index][value]
   end

   return nil
end

function proxy:__index(k)
   local exist = rawget(proxy, k)
   if exist then return exist end

   local _type = rawget(self, "_type")
   local for_type = rawget(inner, _type)
   if not for_type then
      error("Unknown type " .. _type)
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
   return metatables[self._type]
end

function proxy:ensure(k)
   local it = self[k]
   if it == nil then
      error(string.format("No instance of %s with ID %s was found.", self._type, k))
   end
   return it
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
   local inner_iter, inner_state, inner_index
   if inner[self._type] ~= nil then
      inner_iter, inner_state, inner_index = pairs(inner[self._type])
   end
   return fun.wrap(iter, {iter=inner_iter,state=inner_state}, inner_index)
end

function proxy:print()
   local list = {}
   for _, v in self:iter() do
      list[#list+1] = { v._id }
   end
   return table.print(list, { header = { "ID" }, sort = 1 })
end

setmetatable(data, {
                __index = function(t, k)
                   return proxy:new(k)
                end,
                __newindex = function(t, k, v)
                end
})

return data
