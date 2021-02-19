local InstancedMap = require("api.InstancedMap")
local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Weather = require("mod.elona.api.Weather")
local FieldMap = require("mod.elona.api.FieldMap")
local Log = require("api.Log")
local Area = require("api.Area")
local Pos = require("api.Pos")
local Feat = require("api.Feat")
local Map = require("api.Map")

local Encounter = {}

function Encounter.distance_from_nearest_town(world_map, x, y)
   -- >>>>>>>> shade2/map_func.hsp:232 #module  ...
   if x == nil then
      local player = Chara.player()
      x = player.x
      y = player.y
   end
   local filter = function(feat)
      if not Area.is_area_entrance(feat) then
         return false
      end
      local area = Area.get(feat.params.area_uid)
      return area.metadata.town_floors and #area.metadata.town_floors > 0
   end
   local map = function(feat)
      return Pos.dist(feat.x, feat.y, x, y)
   end
   return Feat.iter(world_map):filter(filter):map(map):into_sorted(fun.op.lt):nth(1) or 0
   -- <<<<<<<< shade2/map_func.hsp:245 #global ..
end

function Encounter.calc_rogue_appearance_chance(player)
   -- >>>>>>>> shade2/action.hsp:662 			if rnd(220+cLevel(pc)*10-limit(gCargoWeight*150 ...
   return 220 + player:calc("level") * 10 - math.clamp(player:calc("cargo_weight") * 150 / (player:calc("max_cargo_weight")+1), 0, 210 + player:calc("level") * 10)
   -- <<<<<<<< shade2/action.hsp:662 			if rnd(220+cLevel(pc)*10-limit(gCargoWeight*150 ..
end

function Encounter.random_encounter_id(map, x, y)
   local encounter_id

   -- >>>>>>>> shade2/action.hsp:653 			p=map(cX(cc),cY(cc),0) ...
   if Rand.one_in(30) then
      encounter_id = "elona.enemy"
   end

   if Weather.is("elona.hard_rain") and Rand.one_in(10) then
      encounter_id = "elona.enemy"
   end

   if Weather.is("elona.etherwind") and Rand.one_in(13) then
      encounter_id = "elona.enemy"
   end

   local tile = map:tile(x, y)
   if tile.is_road then
      if Rand.one_in(2) then
         encounter_id = nil
      end
      if Rand.one_in(100) then
         encounter_id = "elona.merchant"
      end
   end

   local player = Chara.player()
   if Rand.one_in(Encounter.calc_rogue_appearance_chance(player)) then
      encounter_id = "elona.rogue"
   end

   encounter_id = map:emit("elona.on_generate_random_encounter_id", {x=x, y=y}, encounter_id)

   return encounter_id
   -- <<<<<<<< shade2/action.hsp:670 			} ...end
end

function Encounter.generate_default_map(outer_map, outer_x, outer_y)
   -- >>>>>>>> shade2/map.hsp:1502 		mWidth	=34 ...
   local stood_tile = outer_map:tile(outer_x, outer_y)
   return FieldMap.generate(stood_tile, 34, 22, outer_map)
   -- <<<<<<<< shade2/map.hsp:1508 		mnName="" ..
end

function Encounter.start(encounter_id, outer_map, outer_x, outer_y, level)
   local encounter_data = data["elona.encounter"]:ensure(encounter_id)

   local encounter_level = level
   if encounter_level == nil then
      if type(encounter_data.encounter_level) == "number" then
         encounter_level = encounter_data.encounter_level
      elseif type(encounter_data.encounter_level) == "function" then
         encounter_level = encounter_data.encounter_level(outer_map, outer_x, outer_y)
         assert(type(encounter_level) == "number")
      end
   end

   encounter_level = math.floor(encounter_level or 1)

   local map
   if encounter_data.generate_map then
      map = encounter_data.generate_map(encounter_level, outer_map, outer_x, outer_y)
   else
      map = Encounter.generate_default_map(outer_map, outer_x, outer_y)
   end
   class.assert_is_an(InstancedMap, map)

   map:set_previous_map_and_location(outer_map, outer_x, outer_y)

   if encounter_data.before_encounter_start then
      encounter_data.before_encounter_start(encounter_level, outer_map, outer_x, outer_y)
   end

   assert(Map.travel_to(map))

   encounter_data.on_map_entered(map, encounter_level, outer_map, outer_x, outer_y)

   return "turn_begin"
end

return Encounter
