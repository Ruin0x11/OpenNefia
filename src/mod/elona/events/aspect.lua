local IItemUseable = require("mod.elona.api.aspect.IItemUseable")
local Event = require("api.Event")
local IEvented = require("mod.elona.api.aspect.IEvented")

local function aspect_item_useable(item, params, result)
   for _, aspect in item:iter_aspects(IItemUseable) do
      local result = aspect:on_use(item, params, result)
      if result then
         return result
      end
   end

   return result
end
Event.register("elona_sys.on_item_use", "Aspect: IItemUseable", aspect_item_useable)

local _retain = setmetatable({}, { __mode = "k" })
local function aspect_item_evented(obj, params, result)
   for _, aspect in obj:iter_aspects(IEvented) do
      obj:connect_self_multiple(aspect:get_events(obj), true)
   end
   _retain[obj] = true

   return result
end
Event.register("base.on_object_instantiated", "Aspect: IEvented", aspect_item_evented)
