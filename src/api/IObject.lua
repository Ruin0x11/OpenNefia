-- An object instance backed by a data prototype.
local IObject = interface("IObject",
                          {
                             build = { type = "function", default = function() end },
                             refresh = { type = "function", default = function(self) self.temp = {} end },
                             _id = "string",
                             _type = "string",
                          }
)

function IObject:init()
   self.temp = {}
end

--- Obtains a property or calls a function to compute something. Using
--- this function instead of plain access (obj.prop) means the
--- property will support the value refresh system.
function IObject:calc(key, ...)
   if self.temp[key] ~= nil then
      return self.temp[key]
   elseif self[key] ~= nil then
      local can_call = type(self[key]) == "function"
      if can_call then
         return self[key](self, ...)
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

--- Modifies a temporary value. This will be cleared when refresh() is
--- called on the object.
function IObject:mod(prop, v, meth)
   meth = meth or "set"

   if type(v) == "table" then
      self.temp[prop] = self.temp[prop] or {}
      merge_ex(self.temp[prop], v, meth, self)
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

function IObject:clone(owned)
   local MapObject = require("api.MapObject")
   return MapObject.clone(self, owned)
end

function IObject:is_a(_type)
   return self._type == _type
end

return IObject
