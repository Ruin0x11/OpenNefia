local ElonaWorld = {}
local Nefia = require("mod.elona.api.Nefia")
local Rand = require("api.Rand")
local MapArchetype = require("api.MapArchetype")
local Gui = require("api.Gui")
local Area = require("api.Area")
local IFeat = require("api.feat.IFeat")
local Feat = require("api.Feat")

local function count_live_nefias(world_map)
   local filter = function(area)
      local boss_uid = Nefia.get_boss_uid(area)
      return boss_uid == nil or boss_uid >= 0
   end
   return Nefia.iter_in_area(world_map):filter(filter):length()
end

-- >>>>>>>> shade2/init.hsp:10 	#define global defAreaRenew	25 ...
ElonaWorld.LIVE_NEFIA_THRESHOLD = 25
-- <<<<<<<< shade2/init.hsp:10 	#define global defAreaRenew	25 ..

function ElonaWorld.should_regenerate_nefias(world_map)
   -- >>>>>>>> shade2/map.hsp:2363 	p=0 ...
   local live_nefias = count_live_nefias(world_map)

   return live_nefias < ElonaWorld.LIVE_NEFIA_THRESHOLD
      or Rand.one_in(150)
      or save.elona.about_to_regenerate_world_map
      or save.elona.about_to_regenerate_nefias
   -- <<<<<<<< shade2/map.hsp:2368 	if (p<=defAreaRenew)or(rnd(150)=0)or(flagRenewDun ..
end

-- >>>>>>>> shade2/map.hsp:3227 	if map(x,y,0)>19:continue ...
local NEFIA_SPAWNABLE_TILES = table.set {
   "elona.world_grass",
   "elona.world_small_trees_1",
   "elona.world_small_trees_2",
   "elona.world_small_trees_3",
   "elona.world_trees_1",
   "elona.world_trees_2",
   "elona.world_trees_3",
   "elona.world_trees_4",
   "elona.world_trees_5",
   "elona.world_trees_6",
   "elona.world_plants_1",
   "elona.world_plants_2",
   "elona.world_plants_3",
   "elona.world_dirt_1",
   "elona.world_dirt_2",
}
-- <<<<<<<< shade2/map.hsp:3227 	if map(x,y,0)>19:continue ..

function ElonaWorld.find_position_for_nefia(world_map)
   -- >>>>>>>> shade2/map.hsp:3221 	f=-1 ...
   local sx, sy = Rand.rnd(world_map:width()), Rand.rnd(world_map:height())
   local world_area = assert(Area.for_map(world_map))
   local world_map_floor = assert(world_area:floor_of_map(world_map.uid))

   local gen_pos = function(i)
      return sx + Rand.rnd(i + 1) - Rand.rnd(i + 1),
             sy + Rand.rnd(i + 1) - Rand.rnd(i + 1)
   end

   local filter = function(x, y)
      if x <= 5 or y <= 5 or x >= world_map:width() - 6 or y >= world_map:height() - 6 then
         return false
      end

      local tile = world_map:tile(x, y)
      if tile.is_road then
         return false
      end

      if not NEFIA_SPAWNABLE_TILES[tile._id] then
         return false
      end

      if Feat.at(x, y, world_map):length() > 0 then
         return false
      end

      for _, nefia in Nefia.iter_in_area(world_area) do
         local ox, oy, floor = world_area:child_area_position(nefia)
         if ox and oy and floor == world_map_floor then
            if x >= ox - 2 and x <= ox + 2 and y >= oy - 2 and y <= oy + 2 then
               return false
            end
         end
      end

      return true
   end

   return fun.range(1000):map(gen_pos):filter(filter):nth(1)
   -- <<<<<<<< shade2/map.hsp:3228 	if cellFeat1(x,y)!0:continue ..
end

function ElonaWorld.generate_random_nefias(world_map)
   -- >>>>>>>> shade2/map.hsp:2314 *world_newRandArea ...
   local nefia_amount = ElonaWorld.LIVE_NEFIA_THRESHOLD - count_live_nefias(world_map)
   local world_area = assert(Area.for_map(world_map))
   for _ = 1, nefia_amount do
      local x, y = ElonaWorld.find_position_for_nefia(world_map)
      if x and y then
         local nefia = Nefia.create_random(world_area)
         Nefia.create_entrance(nefia, x, y, world_map)
      end
   end
   -- <<<<<<<< shade2/map.hsp:2330 	return true ..
end

function ElonaWorld.regenerate_nefias(world_map)
   -- >>>>>>>> shade2/map.hsp:2369 		proc "world_update_rand_dungeon" ...
   save.elona.about_to_regenerate_nefias = false
   Gui.mes("action.move.global.diastrophism")
   Nefia.iter_entrances_in(world_map):each(IFeat.remove_ownership)
   Nefia.iter_in_area(world_map):each(Area.delete)
   ElonaWorld.generate_random_nefias(world_map)
   -- <<<<<<<< shade2/map.hsp:2378 		gosub *world_refresh ..
end

function ElonaWorld.proc_world_regenerate(world_map)
   -- >>>>>>>> shade2/map.hsp:2353 *world_update ...
   if save.elona.about_to_regenerate_world_map then
      MapArchetype.generate_area_archetype_entrances(world_map, true)
   end

   if ElonaWorld.should_regenerate_nefias(world_map) then
      ElonaWorld.regenerate_nefias(world_map)
   end

   for _, entrance in Area.iter_entrances_in_parent(world_map) do
      -- >>>>>>>> shade2/map.hsp:2442 	if (areaType(cnt)=mTypeTown)or(areaType(cnt)=mTyp ...
      entrance:refresh_cell_on_map()
      -- <<<<<<<< shade2/map.hsp:2442 	if (areaType(cnt)=mTypeTown)or(areaType(cnt)=mTyp ..
   end

   save.elona.about_to_regenerate_world_map = false
   -- <<<<<<<< shade2/map.hsp:2381 	return ..
end

return ElonaWorld
