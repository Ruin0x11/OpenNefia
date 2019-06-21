local IOwned = require("api.IOwned")
local Log = require("api.Log")

local IMapObject = interface("IMapObject",
                             {
                                uid = "number",
                                x = "number",
                                y = "number",
                                build = { type = "function", default = function() end },
                                refresh = { type = "function", default = function() self.temp = {} end },
                             },
                             IOwned)

function IMapObject:init()
   self.temp = {}
end

--- Obtains a property or calls a function to compute something. Using
--- this function instead of plain access (obj.prop) means the
--- property will support the value refresh system.
function IMapObject:calc(key, ...)
   if self.temp[key] ~= nil then
      return self.temp[key]
   elseif self[key] ~= nil then
      local can_call = type(self[key]) == "function"
      if can_call then
         return self[key](...)
      else
         return self[key]
      end
   else
      return nil
   end
end

local function merge_recurse(base, add, meth, default, key)
   if type(base) ~= type(add) then
      error("wrong types")
   end

   if type(add[key]) == "table" then
      if base[key] == nil then
         base[key] = {}
      end
      for k, v in pairs(add[key]) do
         merge_recurse(base[key], add[key], meth, default and default[key], k)
      end
   else
      local val = add[key]
      if default and base[key] == nil then
         base[key] = default[key]
      end

      if meth == "add" then
         base[key] = (base[key] or 0) + val
      elseif meth == "set" then
         base[key] = val
      else
         error("unknown merge method " .. meth)
      end
   end

   return base
end

local function merge_ex(base, add, meth, default)
   meth = meth or "set"
   for k, v in pairs(add) do
      merge_recurse(base, add, meth, default, k)
   end
   return base
end

function IMapObject:mod(prop, v, meth)
   meth = meth or "set"

   if type(v) == "table" then
      self.temp[prop] = self.temp[prop] or {}
      table.merge_ex(self.temp[prop], v, meth, self)
   else
      local base = self.temp[prop]
      if base == nil then
         base = self[prop]
      end
      if meth == "add" then
         self.temp[prop] = (base or 0) + v
      elseif meth == "set" then
         self.temp[prop] = v
      end
   end

   return self.temp[prop]
end

function IMapObject:set_pos(x, y)
   local InstancedMap = require("api.InstancedMap")
   local location = self.location

   if not is_an(InstancedMap, location) then
      Log.warn("IMapObject.set_pos: Not setting position of %s to %d,%d\n\t%s", tostring(self), x, y, debug.traceback(""))
      return false
   end

   assert(location:has_object(self))

   if not location:is_in_bounds(x, y) then
      return false
   end

   location:move_object(self, x, y)

   return true
end

function IMapObject:move(dx, dy)
   return self:set_pos(self.x + dx, self.y + dy)
end

return IMapObject
