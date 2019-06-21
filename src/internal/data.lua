local schema = require ("thirdparty.schema")

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

function data:error(mes)
   local file, line = script_path()
   table.insert(self.errors,
                {
                   file = file,
                   line = line,
                   level = "error",
                   message = mes
                }
   )
   error("data: " .. mes)
end

local stage = nil
local inner = {}
local schemas = {}
local metatables = {}
local strict = false

-- HACK: separate into Data API and internal.data
function data:clear()
   inner = {}
end

function data:add_type(schema, metatable)
   local _type = "base." .. schema.name
   metatable = metatable or {}
   metatable._type = _type

   schemas[_type] = schema
   metatables[_type] = metatable
end

function data:edit_type(type_id, delta)
end

function data:add(dat)
   -- if stage ~= "loading" then error("stop") end

   local _id = dat._id
   local _type = dat._type

   if not (string.nonempty(_id) and string.nonempty(_type)) then
      data:error("Missing _id or _type")
      return
   end

   local _schema = schemas[_type]

   if _schema == nil then
      data:error("No type registered for " .. _type)
      return
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

   if strict and failed then return end

   local mod = "base"
   local full_id = mod .. "." .. _id

   inner[_type] = inner[_type] or {}

   if inner[_type][full_id] ~= nil then
      self:error(string.format("ID is already taken on type '%s': '%s'", _type, full_id))
      return
   end

   inner[_type][full_id] = dat

   if _schema.index_on then
      local i = _schema.index_on
      if type(i) == "string" then i = {i} end
      for _, v in ipairs(i) do
         local index_key = dat[v]
         local key = "by_" .. v
         inner[_type][key] = inner[_type][key] or {}

         if inner[_type][key][index_key] ~= nil then
            self:error(string.format("Index key '%s' on '%s' is not unique: '%s'", v, full_id, index_key))
         else
            inner[_type][key][index_key] = dat
         end
      end
   end

   dat._id = full_id
   setmetatable(dat, metatables[_type])
end

function data:add_multi(_type, ...)
   for _, dat in ipairs({...}) do
      dat._type = _type
      self:add(dat)
   end
end

local proxy = class("proxy")

function proxy:init(_type)
   rawset(self, "_type", _type)
end

function proxy:__newindex(k, v)
end

function proxy:find_by(index, value)
   if inner[self._type]["by_" .. index] ~= nil then
      return inner[self._type]["by_" .. index][value]
   end

   return nil
end

function proxy:__index(k)
   local exist = rawget(proxy, k)
   if exist then return exist end

   if not inner[self._type] then return nil end

   -- Permit substituting an instance of a data type if it is passed
   -- in instead of a string key.
   if type(k) == "table"
      and k._type == self._type
      and inner[self._type][k._id]
   then
      return k
   end

   return inner[self._type][k]
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
   return iter, {iter=inner_iter,state=inner_state}, inner_index
end

setmetatable(data, {
                __index = function(t, k)
                   return proxy:new(k)
                end,
                __newindex = function(t, k, v)
                end
})

return data
