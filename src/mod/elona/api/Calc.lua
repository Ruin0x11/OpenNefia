local Map = require("api.Map")
local Rand = require("api.Rand")
local Charagen = require("mod.tools.api.Charagen")

local Calc = {}

function Calc.calc_object_level(base, map)
   assert(map)

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

function Calc.calc_fame_gained(chara, base)
   local ret = math.floor(base * 100 / (100 + chara.fame / 100 * (chara.fame / 100) / 2500))
   if ret < 5 then
      ret = Rand.rnd(5) + 1
   end
   return ret
end

function Calc.hunt_enemy_id(difficulty, min_level)
   local id

   for _ = 1, 50 do
      local chara = Charagen.create(nil, nil, { level = difficulty, quality = 2, ownerless = true })
      id = chara._id
      if not chara.is_shade and chara.level >= min_level then
         break
      end
   end

   return id
end

function Calc.round_margin(a, b)
   if a > b then
      return a - Rand.rnd(a - b)
   elseif a < b then
      return a + Rand.rnd(b - a)
   else
      return a
   end
end

function Calc.do_stamina_action(chara, delta)
   chara:damage_sp(delta)
   return chara.stamina >= 50 or chara.stamina >= Rand.rnd(75)
end

function Calc.make_sound(chara, map)
end

function Calc.make_guards_hostile(map)
end

return Calc
