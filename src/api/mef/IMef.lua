local IEventEmitter = require("api.IEventEmitter")
local IMapObject = require("api.IMapObject")
local IObject = require("api.IObject")
local IModdable = require("api.IModdable")
local Mef = require("api.Mef")

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
   self:emit("base.on_build_mef")
end

function IMef:instantiate()
   IObject.instantiate(self)
   self:emit("base.on_mef_instantiated")
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

--- Sets this mef's position. Use this function instead of updating x and y manually.
---
--- @tparam int x
--- @tparam int y
--- @tparam bool force
--- @treturn bool true on success.
--- @overrides IMapObject.set_pos
function IMef:set_pos(x, y, force)
   local map = self:current_map()
   if not map then
      return false
   end

   if Mef.at(x, y, map) then
      return false
   end

   return IMapObject.set_pos(self, x, y, force)
end

return IMef
