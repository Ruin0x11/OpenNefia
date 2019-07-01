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

   if not class.is_an(ILocation, where) then return nil end

   if where:is_positional() then
      if not where:is_in_bounds(x, y) then
         return nil
      end
   end

   local gen_params = {
      no_build = params.no_build
   }
   local feat = MapObject.generate_from("base.feat", id, gen_params)

   feat = where:take_object(feat, x, y)

   if feat then
      feat:refresh()
   end

   return feat
end

local function feat_bumped_into_handler(source, p, result)
   for _, feat in Feat.at(p.x, p.y) do
      if feat:calc("is_solid") then
         feat:on_bumped_into(p.chara)
         result.blocked = true
      end
   end

   return result
end

local function feat_stepped_on_handler(source, p, result)
   for _, feat in Feat.at(p.x, p.y, p.chara:current_map()) do
      if feat.on_stepped_on then
         feat:on_stepped_on(p.chara)
      end
   end

   return result
end

local Event = require("api.Event")
Event.register("base.on_chara_moved", "feat handler", feat_stepped_on_handler)
Event.register("base.before_chara_moved", "before move feat handler", feat_bumped_into_handler)

return Feat
