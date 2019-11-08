local Event = require("api.Event")
local IEventEmitter = require("api.IEventEmitter")
local IMapObject = require("api.IMapObject")
local IObject = require("api.IObject")
local IModdable = require("api.IModdable")

-- A feat is anything that is a part of the map with a position. Feats
-- also include traps.
local IFeat = class.interface("IFeat", {}, { IMapObject, IModdable, IEventEmitter })

function IFeat:pre_build()
   IModdable.init(self)
   IMapObject.init(self)
   IEventEmitter.init(self)
end

function IFeat:normal_build()
end

function IFeat:build()
   self:emit("base.on_build_feat")
end

function IFeat:instantiate()
   IObject.instantiate(self)
   Event.trigger("base.on_feat_instantiated", {item=self})
end

function IFeat:refresh()
   IMapObject.on_refresh(self)
   IModdable.on_refresh(self)
   if self.on_refresh then
      self:on_refresh()
   end
end

function IFeat:produce_memory()
   return {
      uid = self.uid,
      is_invisible = self:calc("is_invisible"),
      image = self:calc("image") .. "#1"
   }
end

function IFeat:on_stepped_on(obj)
end

function IFeat:on_bumped_into(obj)
end

function IFeat:on_open(opener)
end

function IFeat:on_close(closer)
end

function IFeat:on_activate(closer)
end

return IFeat
