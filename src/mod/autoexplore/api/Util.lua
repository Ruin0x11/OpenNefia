local Chara = require("api.Chara")
local Map = require("api.Map")

local Util = {}

function Util.chara_blocks(pos)
   local chara = Chara.at(pos.x, pos.y)
   return chara
      and not Chara.is_player(chara)
      and Chara.player():has_los(chara.x, chara.y)
      and chara:reaction_towards(Chara.player()) < 0
end

function Util.mef_blocks(pos)
   return false -- Map.get_mef(pos.x, pos.y) ~= 0
end

function Util.has_trap(pos)
   return false -- Feat.at(pos.x, pos.y)
end

function Util.is_safe_to_travel(pos)
   if not Map.is_floor(pos.x, pos.y) then
      return false
   end

   if not Map.current():is_memorized(pos.x, pos.y) then
      return false
   end

   if Util.chara_blocks(pos) then
      return false
   end

   if Util.mef_blocks(pos) then
      return false
   end

   if Util.has_trap(pos) then
      return false
   end

   return true
end


return Util