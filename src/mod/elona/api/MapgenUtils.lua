local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Calc = require("mod.elona.api.Calc")
local Enum = require("api.Enum")
local Charagen = require("mod.tools.api.Charagen")
local Map = require("api.Map")
local Feat = require("api.Feat")
local Item = require("api.Item")
local Filters = require("mod.elona.api.Filters")
local Itemgen = require("mod.tools.api.Itemgen")

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

function MapgenUtils.spawn_random_site(map, is_major_renew, x, y)
   -- >>>>>>>> shade2/map_func.hsp:793 #deffunc map_randSite int dx,int dy ...
   if not x or not y then
      local pos = function()
         return Rand.rnd(map:width() - 5) + 2, Rand.rnd(map:height() - 5) + 2
      end

      local filter = function(x, y)
         return map:can_access(x, y)
            and Feat.at(x, y, map):length() == 0
            and Item.at(x, y, map):length() == 0
      end

      x, y = fun.tabulate(pos):filter(filter):take(20):nth(1)
   end

   if not x or not y then
      return false
   end

   if map:has_type("world") then
      local tile = map:tile(x, y)
      if tile.field_type == "elona.sea" or tile.is_road then
         return false
      end
   end

   if map:has_type("dungeon") then
      if is_major_renew then
         if Rand.one_in(25) then
            local fountain = Item.create("elona.fountain", x, y, {}, map)
            if fountain then
               fountain.own_state = Enum.OwnState.NotOwned
               return true
            end
         end
         if Rand.one_in(100) then
            local altar = Item.create("elona.altar", x, y, {}, map)
            if altar then
               altar.own_state = Enum.OwnState.NotOwned
               -- TODO god
               return true
            end
         end
      end

      local mat_spot_info = "elona.default"

      if Rand.one_in(14) then
         mat_spot_info = "elona.remains"
      elseif Rand.one_in(13) then
         mat_spot_info = "elona.mine"
      elseif Rand.one_in(12) then
         mat_spot_info = "elona.spring"
      elseif Rand.one_in(11) then
         mat_spot_info = "elona.bush"
      end

      Feat.create("elona.material_spot", x, y, {params={material_spot_info=mat_spot_info}}, map)
      return true
   end

   if map:has_type("town") or map:has_type("guild") then
      if Rand.one_in(3) then
         Item.create("elona.moongate", x, y, {}, map)
         return true
      end

      if Rand.one_in(15) then
         Item.create("elona.platinum_coin", x, y, {}, map)
         return true
      end

      if Rand.one_in(20) then
         Item.create("elona.wallet", x, y, {}, map)
         return true
      end

      if Rand.one_in(15) then
         Item.create("elona.suitcase", x, y, {}, map)
         return true
      end

      if Rand.one_in(18) then
         local player = Chara.player()
         local filter = {
            level = Calc.calc_object_level(Rand.rnd(player:calc("level")), map),
            quality = Calc.calc_object_quality(Enum.Quality.Good),
            categories = Rand.choice(Filters.fsetwear)
         }
         Itemgen.create(x, y, filter, map)
         return true
      end

      local filter = { level = 10, categories = "elona.junk_town" }
      Itemgen.create(x, y, filter, map)
      return true
   end

   return false
   -- <<<<<<<< shade2/map_func.hsp:891 	return ..
end

return MapgenUtils
