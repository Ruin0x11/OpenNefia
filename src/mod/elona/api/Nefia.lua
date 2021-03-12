local Area = require("api.Area")
local I18N = require("api.I18N")
local Rand = require("api.Rand")
local Chara = require("api.Chara")

local InstancedArea = require("api.InstancedArea")

local Nefia = {}

function Nefia.get_type(area)
   class.assert_is_an(InstancedArea, area)

   return area.metadata.nefia_type or nil
end

function Nefia.get_level(area)
   class.assert_is_an(InstancedArea, area)

   return area.metadata.nefia_level or 1
end

function Nefia.get_boss_uid(area)
   class.assert_is_an(InstancedArea, area)

   return area.metadata.nefia_boss_uid or nil
end

function Nefia.make_name(level, nefia_id)
   local rank_factor = 5
   local kind = Rand.rnd(2)
   local rank = math.clamp(math.floor(level / rank_factor), 0, 5)
   return I18N.get(("nefia.prefix._%d._%d"):format(kind, rank), "nefia._." .. nefia_id .. ".name")
end

function Nefia.calc_random_nefia_type()
   return Rand.choice(data["elona.nefia"]:iter())._id
end

function Nefia.calc_random_nefia_level(player)
   -- >>>>>>>> shade2/map.hsp:3258 	if rnd(3){ ...
   local level
   if Rand.one_in(3) then
      level = Rand.rnd(player:calc("level") + 5) + 1
   else
      level = Rand.rnd(50) + 1
      if Rand.on_in(5) then
         level = level * (Rand.rnd(3) + 1)
      end
   end
   return level
   -- <<<<<<<< shade2/map.hsp:3263 		} ..
end

function Nefia.calc_random_nefia_floor_count()
   -- >>>>>>>> shade2/map.hsp:3265 	areaMaxLevel(p)		=areaMinLevel(p)+rnd(4)+2 ...
   return Rand.rnd(4) + 2
   -- <<<<<<<< shade2/map.hsp:3265 	areaMaxLevel(p)		=areaMinLevel(p)+rnd(4)+2 ..
end

function Nefia.calc_nefia_map_level(floor, nefia_level)
   -- In OpenNefia, we start dungeons on floor 1. Nefia level is what used to be
   -- "starting floor", so a nefia of level 5 would start on the fifth floor.
   return (nefia_level or 1) + floor - 1
end

function Nefia.create(nefia_id, x, y, world_map, level, floor_count)
   local nefia_proto = data["elona.nefia"]:ensure(nefia_id)
   assert(math.type(level) == "integer")
   assert(math.type(floor_count) == "integer")
   level = math.max(level, 1)
   floor_count = math.max(floor_count, 1)

   local area = InstancedArea:new("elona.nefia")
   local starting_floor = 1

   -- TODO: what I want is to be able to specify "this area has a dungeon boss"
   -- without having some weird unschematized variables stuck in `area.metadata`
   -- all the time. say, an interface (capability) like INefia where you put all
   -- the nefia related junk like "boss character UID", "nefia level", "nefia
   -- type", etc. That way you can do a check to see if this area/map has nefia
   -- support instead of looking for weird properties like these.
   area.metadata.nefia_type = nefia_id
   area.metadata.nefia_level = level
   area.metadata.nefia_boss_uid = nil
   area.name = Nefia.make_name(level, nefia_id)
   area._deepest_floor = floor_count

   Area.register(area, { parent = Area.for_map(world_map) })
   local entrance = Area.create_entrance(area, starting_floor, x, y, {}, world_map)

   entrance.image = nefia_proto.image or "elona.feat_area_tower"

   return area, entrance
end

function Nefia.create_random(x, y, world_map)
   local nefia_id = Nefia.calc_random_nefia_type()
   local level = Nefia.calc_random_nefia_level(Chara.player())
   local floor_count = Nefia.calc_random_nefia_floor_count()

   return Nefia.create(nefia_id, x, y, world_map, level, floor_count)
end

return Nefia
