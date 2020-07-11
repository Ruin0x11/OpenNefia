local IEventEmitter = require("api.IEventEmitter")
local IMapObject = require("api.IMapObject")
local IObject = require("api.IObject")
local IModdable = require("api.IModdable")

-- A mef, short for map effect, is an obstacle that can occupy a tile. There can
-- only be a single mef on a tile at a time.
local IMef = class.interface("IMef", {}, { IMapObject, IModdable, IEventEmitter })

function IMef:pre_build()
   IModdable.init(self)
   IMapObject.init(self)
   IEventEmitter.init(self)
end

function IMef:normal_build()
end

function IMef:build()
   -- self:emit("base.on_build_mef")
end

function IMef:instantiate()
   IObject.instantiate(self)
   -- self:emit("base.on_mef_instantiated")
end

function IMef:refresh()
   IMapObject.on_refresh(self)
   IModdable.on_refresh(self)
   if self.on_refresh then
      self:on_refresh()
   end
end

function IMef:produce_memory()
   return {
      uid = self.uid,
      show = not self:calc("is_invisible"),
      image = (self:calc("image") or ""),
      color = self:calc("color"),
      shadow_type = self:calc("shadow_type")
   }
end

return IMef
