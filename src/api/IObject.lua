local Event = require("api.Event")

-- An object instance backed by a data prototype.
local IObject = class.interface("IObject",
                          {
                             _id = "string",
                             _type = "string",
                             pre_build = "function",
                             normal_build = "function",
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

function IObject:finalize()
   self:build()
   self:instantiate()
end

function IObject:instantiate()
   self:calc("on_instantiate")
   Event.trigger("base.on_object_instantiated", {object=self})
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

-- Modifies a base value. This will persist if refresh() is called,
-- and is the same as regular assignment.
function IObject:mod_base(prop, v, method)
   table.merge_ex_single(self, v, method or "add", self.proto, prop)
   return self[prop]
end

-- Modifies this object's temporary values by merging them with `tbl`.
function IObject:mod_with(tbl, method)
   return table.merge_ex(self.temp, tbl, self, method or "add")
end

-- Modifies this object's base values by merging them with `tbl`.
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
