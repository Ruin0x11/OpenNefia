local Map = require("api.Map")
local Rand = require("api.Rand")

local Calc = {}

function Calc.calc_object_level(base, map)
   map = map or Map.current()

   local ret = base or 0
   if base < 0 then
      ret = map:calc("dungeon_level")
   end

   local map_base = map:calc("base_object_level")
   if map_base then
      ret = map_base
   end

   for i=1, 3 do
      if Rand.one_in(30 + i * 5) then
         ret = ret + Rand.rnd(10 + i)
      else
         break
      end
   end

   if base <= 3 and not Rand.one_in(4) then
      ret = Rand.rnd(3) + 1
   end

   return ret
end

local QUALITY = {
   bad = 1,
   good = 2,
   great = 3,
   miracle = 4,
   godly = 5,
   special = 6
}

function Calc.calc_object_quality(quality)
   if type(quality) == "string" then
      assert(QUALITY[quality], ("Unknown quality %s"):format(quality))
      quality = QUALITY[quality]
   end

   local ret = quality or 2
   if ret == 0 then
      ret = 2
   end

   for i=1, 3 do
      local n = Rand.rnd(30 + i * 5)
      if n == 0 then
         ret = ret + 1
      elseif n < 3 then
         ret = ret - 1
      else
         break
      end
   end

   return math.clamp(ret, 1, 5)
end

function Calc.filter(level, quality, rest, map)
   map = map or Map.current()

   return table.merge({
      level = Calc.calc_object_level(level, map),
      quality = Calc.calc_object_quality(quality),
   }, rest or {})
end

return Calc
