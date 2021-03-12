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
   self.params = self.params or {}
   IObject.instantiate(self)
   self:emit("base.on_feat_instantiated")
end

function IFeat:refresh()
   IMapObject.on_refresh(self)
   IModdable.on_refresh(self)
   if self.on_refresh then
      self:on_refresh()
   end
end

function IFeat:produce_memory(memory)
   memory.uid = self.uid
   memory.show = not self:calc("is_invisible")
   memory.image = (self:calc("image") or "")
   memory.color = self:calc("color")
   memory.shadow_type = self:calc("shadow_type")
   memory.drawables = self.drawables
   memory.drawables_after = self.drawables_after
end

return IFeat
