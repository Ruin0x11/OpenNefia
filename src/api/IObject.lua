--- @module IObject

local IEventEmitter = require("api.IEventEmitter")
local IModDataHolder = require("api.IModDataHolder")
local IModdable = require("api.IModdable")
local IAspectHolder = require("api.IAspectHolder")
local data = require("internal.data")

-- An object instance backed by a data prototype.
local IObject = class.interface("IObject",
                          {
                             _id = "string",
                             _type = "string",
                             uid = "number",
                             pre_build = "function",
                             normal_build = "function",
                             build = "function",
                             refresh = "function",
                             finalize = "function",
                          },
                          { IModdable, IModDataHolder, IAspectHolder }
)

function IObject:pre_build()
end

function IObject:normal_build(build_params)
   IAspectHolder.normal_build(self, build_params)
end

function IObject:build()
end

--- Refreshes this object.
function IObject:refresh()
   self:on_refresh()
end

function IObject:init()
   IModdable.init(self)
   IModDataHolder.init(self)
   IAspectHolder.init(self)
end

function IObject:on_refresh()
   IModdable.on_refresh(self)
end

function IObject:finalize(build_params)
   -- TODO this is redundant
   self:build(build_params)
   if class.is_an(IEventEmitter, self) then
      IEventEmitter.on_reload_prototype(self)
      self:emit("base.on_object_finalized")
   end
end

function IObject:instantiate(no_bind_events)
   if class.is_an(IEventEmitter, self) then
      self:emit("base.on_object_prototype_changed", {old_id=nil,no_bind_events=no_bind_events})
      self:emit("base.on_object_instantiated")
   end
end

function IObject:clone_base(owned)
   local MapObject = require("api.MapObject")
   return MapObject.clone_base(self, owned)
end

function IObject:clone(owned)
   local MapObject = require("api.MapObject")
   return MapObject.clone(self, owned)
end

function IObject:is_a(_type)
   return self._type == _type
end

function IObject:change_prototype(new_id)
   data[self._type]:ensure(new_id)
   local mt = getmetatable(self)
   local old_id = mt._id
   mt._id = new_id
   if class.is_an(IEventEmitter, self) then
      self:emit("base.on_object_prototype_changed", {old_id=old_id})
   end
end

return IObject
