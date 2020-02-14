local Calc = require("mod.elona.api.Calc")
local Map = require("api.Map")
local Rand = require("api.Rand")

local Chara = {}

function Chara.respawn_mobs(map)
   map = map or Map.current()

   map:emit("elona.before_respawn_mobs")

   local density = map:calc("max_crowd_density")

   if density <= 0 then
      return
   end

   local function get_filter(map)
      if type(map.chara_filter) == "table" then
         return map.chara_filter
      elseif type(map.chara_filter) == "function" then
         -- TODO standardize where we place functions that aren't
         -- serialized. generators besides map_template have to
         -- manually do all the copying of unserialized functions that
         -- map_template handles automatically.
         return map:chara_filter()
      end

      return Calc.filter(Chara.player().level, "bad", nil, map)
   end

   if map.crowd_density < density / 4 and Rand.one_in(2) then
   end
end

return Chara
