local field = require("game.field")
local Chara = require("api.Chara")
local MapObject = require("api.MapObject")
local ILocation = require("api.ILocation")

local Feat = {}

function Feat.at(x, y, map)
   map = map or field.map

   if not map:is_in_bounds(x, y) then
      return fun.iter({})
   end

   return map:iter_type_at_pos("base.feat", x, y)
end

function Feat.create(id, x, y, params, where)
   if x == nil then
      local player = Chara.player()
      if Chara.is_alive(player) then
         x = player.x
         y = player.y
      end
   end

   params = params or {}

   where = where or field.map

   if not is_an(ILocation, where) then return nil end

   if where:is_positional() then
      if not where:is_in_bounds(x, y) then
         return nil
      end
   end

   local feat = MapObject.generate_from("base.feat", id)

   feat = where:take_object(feat, x, y)

   return feat
end

return Feat
