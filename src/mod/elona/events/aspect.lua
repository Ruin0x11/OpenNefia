local IItemUseable = require("mod.elona.api.aspect.IItemUseable")
local Event = require("api.Event")

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
