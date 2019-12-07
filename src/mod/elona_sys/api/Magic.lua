local IItem = require("api.item.IItem")
local IMapObject = require("api.IMapObject")
local Effect = require("mod.elona.api.Effect")

local Magic = {}

local function calc_adjusted_power(magic, power, curse_state)
   if magic.alignment == "negative" then
      if curse_state == "blessed" then
         return 50
      elseif Effect.is_cursed(curse_state) then
         return power * 150 / 100
      end
   else
      if curse_state == "blessed" then
         return power * 150 / 100
      elseif Effect.is_cursed(curse_state) then
         return 50
      end
   end

   return power
end

function Magic.cast(id, params)
   local magic = data["elona_sys.magic"]:ensure(id)
   params = params or {
      power = 0,
      source = nil,
      target = nil,
      item = nil,
      curse_state = nil,
      x = nil,
      y = nil
   }
   params.power = params.power or 0

   if class.is_an(IMapObject, params.source) then
      params.x = params.x or params.source.x
      params.y = params.y or params.source.y
   end
   if class.is_an(IMapObject, params.target) then
      params.x = params.x or params.target.x
      params.y = params.y or params.target.y
   end

   local curse_state = "none"

   if class.is_an(IItem, params.item) then
      params.curse_state = params.curse_state or item:calc("curse_state")
   end
   params.curse_state = params.curse_state or "none"

   params.power = calc_adjusted_power(magic, params.power, curse_state)

   local did_something, result = magic:cast(params)
   return did_something, result
end

return Magic
