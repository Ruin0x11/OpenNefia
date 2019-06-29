-- An object instance backed by a data prototype.
local IObject = interface("IObject",
                          {
                             _id = "string",
                             _type = "string",
                             build = "function",
                             refresh = "function",
                             temp = "table"
                          }
)

function IObject:init()
   self.temp = {}
end

function IObject:on_refresh()
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

--- Modifies a temporary value. This will be cleared when refresh() is
--- called on the object.
function IObject:mod(prop, v, method)
   table.merge_ex_single(self.temp, v, method or "add", self, prop)
   return self.temp[prop]
end

function IObject:mod_base(prop, v, method)
   table.merge_ex_single(self, v, method or "add", self.proto, prop)
   return self[prop]
end

function IObject:mod_with(tbl, method)
   return table.merge_ex(self.temp, tbl, self, method or "add")
end

-- TODO: allow option to skip merging if value exists in base, or
-- exists in prototype
function IObject:mod_base_with(tbl, method)
   return table.merge_ex(self, tbl, self.proto, method or "add")
end

function IObject:clone(owned)
   local MapObject = require("api.MapObject")
   return MapObject.clone(self, owned)
end

function IObject:is_a(_type)
   return self._type == _type
end

return IObject
