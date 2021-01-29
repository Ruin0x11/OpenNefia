local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Calc = require("mod.elona.api.Calc")
local Enum = require("api.Enum")
local Charagen = require("mod.tools.api.Charagen")

local MapgenUtils = {}

function MapgenUtils.spray_tile(map, tile_id, density)
   local n = math.floor(map:width() * map:height() * density / 100 + 1)
   print(n,tile_id)

   for _=1,n do
      local x = Rand.rnd(map:width())
      local y = Rand.rnd(map:height())
      map:set_tile(x, y, tile_id)
   end
end

function MapgenUtils.generate_chara(map, x, y, extra_params)
   local params
   local archetype = map:archetype()
   if archetype and archetype.chara_filter then
      params = archetype.chara_filter(map)
      assert(type(params) == "table")
   else
      -- >>>>>>>> shade2/map.hsp:100 	flt calcObjLv(cLevel(pc)),calcFixLv(fixNormal) ...
      local player = Chara.player()
      local level = Calc.calc_object_level((player and player.level) or 1, map)
      local quality = Calc.calc_object_quality(Enum.Quality.Normal)
      params = { level = level, quality = quality }
      -- <<<<<<<< shade2/map.hsp:100 	flt calcObjLv(cLevel(pc)),calcFixLv(fixNormal) ..
   end
   if extra_params then
      table.merge(params, extra_params)
   end
   return Charagen.create(x, y, params, map)
end

return MapgenUtils
