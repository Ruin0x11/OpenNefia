local Event = require("api.Event")
local IObject = require("api.IObject")
local IMapObject = require("api.IMapObject")

-- A feat is anything that is a part of the map with a position. Feats
-- also include traps.
local IFeat = class.interface("IFeat", {}, IMapObject)

function IFeat:pre_build()
end

function IFeat:normal_build()
end

function IFeat:build()
end

function IFeat:instantiate()
   IObject.instantiate(self)
   Event.trigger("base.on_feat_instantiated", {item=self})
end

function IFeat:refresh()
   self.temp = {}

   if self.on_refresh then
      self:on_refresh()
   end

   IMapObject.refresh(self)
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
