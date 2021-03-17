local Area = require("api.Area")
local I18N = require("api.I18N")
local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Enum = require("api.Enum")
local Charagen = require("mod.elona.api.Charagen")
local Itemgen = require("mod.elona.api.Itemgen")
local Calc = require("mod.elona.api.Calc")
local Item = require("api.Item")

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

function Nefia.set_boss_uid(area, uid)
   class.assert_is_an(InstancedArea, area)
   assert(math.type(uid) == "integer" or uid == nil)

   area.metadata.nefia_boss_uid = uid
end

function Nefia.iter_all()
   return Area.iter():filter(Nefia.get_type)
end

function Nefia.iter_in_area(map_or_area)
   return Area.iter_children(map_or_area):filter(Nefia.get_type)
end

function Nefia.iter_entrances_in(map)
   local filter = function(feat)
      if not feat.params.area_uid then
         return
      end
      local area = Area.get(feat.params.area_uid)
      if area == nil then
         return
      end
      return Nefia.get_type(area) ~= nil
   end
   return Area.iter_entrances_in_parent(map):filter(filter)
end

function Nefia.random_name(level, nefia_id)
   local rank_factor = 5
   local kind = Rand.rnd(2)
   local rank = math.clamp(math.floor(level / rank_factor), 0, 4)
   return I18N.get(("nefia.prefix._%d._%d"):format(kind, rank), "nefia._." .. nefia_id .. ".name")
end

function Nefia.calc_random_nefia_type()
   return Rand.choice(data["elona.nefia"]:iter())._id
end

function Nefia.calc_random_nefia_level(player, nefia_id)
   -- >>>>>>>> shade2/map.hsp:3258 	if rnd(3){ ...
   local level
   if Rand.one_in(3) then
      level = Rand.rnd((player and player:calc("level") or 1) + 5) + 1
   else
      level = Rand.rnd(50) + 1
      if Rand.one_in(5) then
         level = level * (Rand.rnd(3) + 1)
      end
   end
   return level
   -- <<<<<<<< shade2/map.hsp:3263 		} ..
end

function Nefia.calc_random_nefia_floor_count(nefia_id)
   -- >>>>>>>> shade2/map.hsp:3265 	areaMaxLevel(p)		=areaMinLevel(p)+rnd(4)+2 ...
   return Rand.rnd(4) + 2
   -- <<<<<<<< shade2/map.hsp:3265 	areaMaxLevel(p)		=areaMinLevel(p)+rnd(4)+2 ..
end

function Nefia.calc_nefia_map_level(floor, nefia_level)
   -- In OpenNefia, we start dungeons on floor 1. Nefia level is what used to be
   -- "starting floor", so a nefia of level 5 would start on the fifth floor.
   -- This means (nefia_level + floor) would be off by one, so subtract 1.
   return (nefia_level or 1) + floor - 1
end

function Nefia.create(nefia_id, world_area, level, floor_count)
   data["elona.nefia"]:ensure(nefia_id)
   assert(math.type(level) == "integer")
   assert(math.type(floor_count) == "integer")
   level = math.max(level, 1)
   floor_count = math.max(floor_count, 1)

   local area = InstancedArea:new("elona.nefia")

   -- TODO: what I want is to be able to specify "this area has a dungeon boss"
   -- without having some weird unschematized variables stuck in `area.metadata`
   -- all the time. say, an interface (capability) like INefia where you put all
   -- the nefia related junk like "boss character UID", "nefia level", "nefia
   -- type", etc. That way you can do a check to see if this area/map has nefia
   -- support instead of looking for weird properties like these.
   area.metadata.nefia_type = nefia_id
   area.metadata.nefia_level = level
   area.metadata.nefia_boss_uid = nil
   area.name = Nefia.random_name(level, nefia_id)
   area._deepest_floor = floor_count

   Area.register(area, { parent = world_area })

   return area
end

function Nefia.create_entrance(area, x, y, world_map)
   local nefia_id = Nefia.get_type(area)
   if nefia_id == nil then
      error(("Area %d is not a nefia"):format(area.uid))
   end

   local starting_floor = 1
   local nefia_proto = data["elona.nefia"]:ensure(nefia_id)
   local entrance = Area.create_entrance(area, starting_floor, x, y, {}, world_map)

   entrance.image = nefia_proto.image or "elona.feat_area_tower"
   entrance.color = nefia_proto.color or { 255, 255, 255 }

   return entrance
end

function Nefia.create_random(world_area)
   local nefia_id = Nefia.calc_random_nefia_type()
   local level = Nefia.calc_random_nefia_level(Chara.player(), nefia_id)
   local floor_count = Nefia.calc_random_nefia_floor_count(nefia_id)

   return Nefia.create(nefia_id, world_area, level, floor_count)
end

function Nefia.spawn_boss(map)
   -- >>>>>>>> shade2/main.hsp:1741 	case evRandBoss ...
   local boss
   while boss == nil do
      local filter = {
         quality = Enum.Quality.Great,
         initial_level = map:calc("level") + Rand.rnd(5)
      }
      boss = Charagen.create(nil, nil, filter, map)
   end

   boss.is_precious = true
   boss.name = ("%s Lv%d"):format(boss.name, boss.level)

   return boss
   -- <<<<<<<< shade2/main.hsp:1749 	swbreak ..
end

function Nefia.calc_boss_platinum_amount(player)
   return math.clamp(Rand.rnd(3) + player:calc("level") / 10, 1, 6)
end

function Nefia.calc_boss_fame_gained(player, map)
   -- >>>>>>>> shade2/main.hsp:1763 	gQuestFame	=calcFame(pc,gLevel*30+200) ...
   map = map or player:current_map()
   return Calc.calc_fame_gained(player, map:calc("level") * 30 + 200)
   -- <<<<<<<< shade2/main.hsp:1763 	gQuestFame	=calcFame(pc,gLevel*30+200) ..
end

function Nefia.create_boss_rewards(player, boss)
   -- >>>>>>>> shade2/main.hsp:1751 	case evRandBossWin ...
   player = player or Chara.player()
   local map = player:current_map()

   local filter = {
      level = Calc.calc_object_level(nil, map),
      quality = Calc.calc_object_quality(),
      categories = "elona.spellbook"
   }
   Itemgen.create(player.x, player.y, filter, map)

   local scroll = Item.create("elona.scroll_of_return", player.x, player.y, {}, map)

   local gold_amount = 200 + scroll.amount * 5 -- XXX: ...What?
   Item.create("elona.gold_piece", player.x, player.y, {amount=gold_amount}, map)

   local platinum_amount = Nefia.calc_boss_platinum_amount(player)
   Item.create("elona.platinum_coin", player.x, player.y, {amount=platinum_amount}, map)

   local chest = Item.create("elona.bejeweled_chest", player.x, player.y, {}, map)
   if chest then
      chest.params.chest_lockpick_difficulty = 0
   end
   -- <<<<<<<< shade2/main.hsp:1765 	cFame(pc)+=gQuestFame ..
end

return Nefia
