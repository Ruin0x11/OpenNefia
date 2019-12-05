local IItem = require("api.item.IItem")
local Skill = require("mod.elona_sys.api.Skill")

local Magic = {}

local function is_cursed(curse_state)
   return curse_state == "cursed" or curse_state == "doomed"
end

local function calc_adjusted_power(magic, power, curse_state)
   if magic.alignment == "negative" then
      if curse_state == "blessed" then
         return 50
      elseif is_cursed(curse_state) then
         return power * 150 / 100
      end
   else
      if curse_state == "blessed" then
         return power * 150 / 100
      elseif is_cursed(curse_state) then
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
      x = 0,
      y = 0
   }

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
