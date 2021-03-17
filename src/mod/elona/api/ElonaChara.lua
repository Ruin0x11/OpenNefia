local Calc = require("mod.elona.api.Calc")
local Map = require("api.Map")
local Rand = require("api.Rand")
local Enum = require("api.Enum")
local Charagen = require("mod.tools.api.Charagen")
local api_Chara = require("api.Chara")
local Log = require("api.Log")


local ElonaChara = {}

function ElonaChara.default_filter(map)
   -- >>>>>>>> shade2/map.hsp:100 	flt calcObjLv(cLevel(pc)),calcFixLv(fixNormal) ...
   return {
      level = Calc.calc_object_level(api_Chara.player():calc("level"), map),
      quality = Calc.calc_object_quality(Enum.Quality.Normal)
   }
   -- <<<<<<<< shade2/map.hsp:100 	flt calcObjLv(cLevel(pc)),calcFixLv(fixNormal) ..
end

function ElonaChara.random_filter(map)
   local archetype = map:archetype()
   if archetype and archetype.chara_filter then
      return archetype.chara_filter
   end

   return ElonaChara.default_filter
end

function ElonaChara.spawn_mobs(map, chara_id)
-- >>>>>>>> shade2/map.hsp:104 *chara_spawn ...
   map = map or Map.current()

   local chara_filter = ElonaChara.random_filter(map)

   map:emit("elona.before_spawn_mobs", {chara_filter=chara_filter, chara_id=chara_id})

   -- >>>>>>>> shade2/map.hsp:108  ..
   local density = map:calc("max_crowd_density")

   if density <= 0 then
      return
   end

   if map.crowd_density < density / 4 and Rand.one_in(2) then
      local filter = chara_filter(map)
      filter.id = filter.id or chara_id
      Charagen.create(nil, nil, filter, map)
   end
   if map.crowd_density < density / 2 and Rand.one_in(4) then
      local filter = chara_filter(map)
      filter.id = filter.id or chara_id
      Charagen.create(nil, nil, filter, map)
   end
   if map.crowd_density < density and Rand.one_in(8) then
      local filter = chara_filter(map)
      filter.id = filter.id or chara_id
      Charagen.create(nil, nil, filter, map)
   end
   -- <<<<<<<< shade2/map.hsp:113 	return ..
end

return ElonaChara
