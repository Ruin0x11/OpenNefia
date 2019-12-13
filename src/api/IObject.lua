--- @module IObject

local Event = require("api.Event")
local IModdable = require("api.IModdable")

-- An object instance backed by a data prototype.
local IObject = class.interface("IObject",
                          {
                             _id = "string",
                             _type = "string",
                             pre_build = "function",
                             normal_build = "function",
                             build = "function",
                             refresh = "function",
                             finalize = "function",
                          },
                          IModdable
)

function IObject:pre_build()
end

function IObject:normal_build()
end

function IObject:build()
end

--- Refreshes this object.
function IObject:refresh()
   self:on_refresh()
end

function IObject:init()
   IModdable.init(self)
end

function IObject:on_refresh()
   IModdable.on_refresh(self)
end

function IObject:finalize()
   self:build()
end

function IObject:instantiate()
   Event.trigger("base.on_object_instantiated", {object=self})
end

function IObject:clone(owned)
   local MapObject = require("api.MapObject")
   return MapObject.clone(self, owned)
end

function IObject:is_a(_type)
   return self._type == _type
end

return IObject
