local InstancedMap = require("api.InstancedMap")
local MapTileset = require("mod.elona_sys.map_tileset.api.MapTileset")
local Dungeon = require("mod.elona.api.Dungeon")
local Rand = require("api.Rand")
local Item = require("api.Item")
local Calc = require("mod.elona.api.Calc")
local Enum = require("api.Enum")
local Charagen = require("mod.tools.api.Charagen")
local Chara = require("api.Chara")
local Pos = require("api.Pos")
local InstancedArea = require("api.InstancedArea")
local DungeonTemplate = require("mod.elona.api.DungeonTemplate")
local DungeonMap = require("mod.elona.api.DungeonMap")
local Area = require("api.Area")
local Map = require("api.Map")
local I18N = require("api.I18N")
local Elona122Map = require("mod.elona_sys.map_loader.Elona122Map")
local Feat = require("api.Feat")
local IOwned = require("api.IOwned")
local Quest = require("mod.elona_sys.api.Quest")
local MapgenUtils = require("mod.elona.api.MapgenUtils")
local Filters = require("mod.elona.api.Filters")
local Itemgen = require("mod.tools.api.Itemgen")

local QuestMap = {}

local function random_point_in(rx, ry, rw, rh)
   return Rand.rnd(rw) + rx, Rand.rnd(rh) + ry
end

-- >>>>>>>> elona122/shade2/map_rand.hsp:645  ..
local PARTY_ROOM_CHARAS = {
   { "elona.citizen_of_cyber_dome",  "elona.beggar",        "elona.old_person"        },
   { "elona.farmer",                 "elona.miner",         "elona.town_child"        },
   { "elona.farmer",                 "elona.punk",          "elona.mercenary"         },
   { "elona.punk",                   "elona.citizen",       "elona.hot_spring_maniac" },
   { "elona.citizen",                "elona.tourist",       "elona.wizard"            },
   { "elona.tourist",                "elona.noble",         "elona.noble_child"       },
   { "elona.noble",                  "elona.artist",        "elona.bartender"         },
   { "elona.artist",                 "elona.elder",         "elona.shopkeeper"        },
   { "elona.elder",                  "elona.nun",           "elona.captain"           },
   { "elona.nun",                    "elona.arena_master",  "elona.informer"          }
}
-- <<<<<<<< elona122/shade2/map_rand.hsp:656  ..

-- >>>>>>>> elona122/shade2/map_rand.hsp:683 	flt:p=217,218,216,215,215,152,152,91,189:item_cre ..
local PARTY_RANDOM_ITEMS = {
   "elona.empty_bowl",
   "elona.bowl",
   "elona.basket",
   "elona.lot_of_empty_bottles",
   "elona.lot_of_empty_bottles",
   "elona.lot_of_alcohols",
   "elona.lot_of_alcohols",
   "elona.barrel",
   "elona.stack_of_dishes"
}
-- <<<<<<<< elona122/shade2/map_rand.hsp:683 	flt:p=217,218,216,215,215,152,152,91,189:item_cre ..

function QuestMap.generate_party(difficulty)
   -- >>>>>>>> elona122/shade2/map_rand.hsp:584 *map_createDungeonPerform ..
   local map = InstancedMap:new(38, 28)
   map:set_archetype("elona.quest", { set_properties = true })
   map.tileset = "elona.castle"
   map.music = "elona.casino"
   map.name = I18N.get("map.quest.party_room")

   local room_count = 80

   map:clear("elona.mapgen_tunnel")
   for _, x, y in Pos.iter_border(0, 0, map:width() - 1, map:height() - 1) do
      map:set_tile(x, y, "elona.mapgen_wall")
   end

   local rooms = {}
   for _ = 1, room_count do
      if #rooms >= room_count then
         break
      end
      Dungeon.dig_room(Dungeon.RoomType.Random, 5, 5, rooms, {}, map)
   end
   map.rooms = rooms

   for _ = 1, 500 do
      local dx = Rand.rnd(map:width() - 5)
      local dy = Rand.rnd(map:height() - 5)
      local space_for_decor = true
      local space_for_table = true

      for y = dy, dy+3 do
         for x = dx, dx+3 do
            if map:tile(x, y)._id ~= "elona.mapgen_tunnel" or Item.at(x, y, map):length() > 0 then
               space_for_decor = false
            end
            if map:tile(x, y)._id ~= "elona.mapgen_room" or Item.at(x, y, map):length() > 0 then
               space_for_table = false
            end
         end
      end

      if space_for_decor then
         local choice = Rand.rnd(5)

         for j = 0, 3 do
            local y = dy + j
            for i = 0, 3 do
               local x = dx + i

               if choice < 2 then
                  if i ~= 0 and i ~= 3 and j ~= 0 and j ~= 3 then
                     map:set_tile(x, y, "elona.wall_concrete_light_top")
                  end
               elseif choice == 2 then
                  if i == 3 or j == 3 then
                     break
                  end
                  if i == 1 and j == 1 then
                     map:set_tile(x, y, "elona.stacked_crates_green")
                  else
                     map:set_tile(x, y, "elona.wood_floor_2")
                     Item.create("elona.barrel", x, y, {}, map)
                  end
               elseif choice == 3 then
                  if i == 1 and j == 1 then
                     map:set_tile(x, y, "elona.carpet_blue")
                     Item.create("elona.fancy_lamp", x, y, {}, map)
                  end
               elseif choice == 4 then
                  if i == 1 and j == 1 then
                     map:set_tile(x, y, "elona.ballroom_room_floor")
                     Item.create("elona.statue_ornamented_with_plants", x, y, {}, map)
                  end
               end
            end
         end
      end

      if space_for_table then
         Item.create("elona.modern_table", dx+1, dy+1, {}, map)
         if Rand.one_in(2) then
            Item.create("elona.modern_chair", dx+1, dy, {}, map)
         end
         if Rand.one_in(2) then
            Item.create("elona.modern_chair", dx+1, dy+2, {}, map)
         end
         if Rand.one_in(2) then
            Item.create("elona.modern_chair", dx, dy+1, {}, map)
         end
         if Rand.one_in(2) then
            Item.create("elona.modern_chair", dx+2, dy+1, {}, map)
         end
      end
   end

   local function place_item_in_room(item, rx, ry, rw, rh)
      local x, y = random_point_in(rx, ry, rw, rh)
      if Item.at(x, y, map):length() == 0 then
         Item.create(item, x, y, {}, map)
      end
   end

   for _, room in ipairs(map.rooms) do
      local rx = room.x + 1
      local ry = room.y + 1
      local rw = room.width - 2
      local rh = room.height - 2
      local room_size = rw * rh
      local room_difficulty = math.clamp(Rand.rnd(difficulty / 3 + 3), 0, 9)

      if Rand.one_in(2) then
         place_item_in_room("elona.grand_piano", rx, ry, rw, rh)
      end
      if Rand.one_in(3) then
         place_item_in_room("elona.casino_table", rx, ry, rw, rh)
      end
      if Rand.one_in(2) then
         place_item_in_room("elona.narrow_dining_table", rx, ry, rw, rh)
      end
      if Rand.one_in(3) then
         place_item_in_room("elona.barbecue_set", rx, ry, rw, rh)
      end

      for i = 0, Rand.rnd(room_size / 5 + 2) + room_size / 5 + 2 do
         local filter = {
            level = room_difficulty * 5,
            quality = Calc.calc_object_quality(Enum.Quality.Normal, map),
            initial_level = room_difficulty * 7 + Rand.rnd(5),
            id = Rand.choice(PARTY_ROOM_CHARAS[room_difficulty+1])
         }
         local x, y = random_point_in(rx, ry, rw, rh)
         local chara = Charagen.create(x, y, filter, map)
         if chara then
            chara:add_role("elona.special")
            chara.faction = "base.citizen" -- TODO faction
            chara.gold = chara.level * (20 + Rand.rnd(20))
         end
      end
   end

   for _ = 1, 25 + Rand.rnd(10) do
      local x = Rand.rnd(map:width())
      local y = Rand.rnd(map:height())
      if Item.at(x, y, map):length() == 0 and map:can_access(x, y) then
         Item.create(Rand.choice(PARTY_RANDOM_ITEMS), x, y, {}, map)
      end
   end

   local function special_chara(id)
      local chara = Chara.create(id, nil, nil, {}, map)
      chara:add_role("elona.special")
      chara.faction = "base.citizen" -- TODO faction
   end

   special_chara("elona.loyter")
   special_chara("elona.gilbert_the_colonel")
   special_chara("elona.shena")
   special_chara("elona.mia")

   if Rand.one_in(10) then special_chara("elona.lomias") end
   if Rand.one_in(10) then special_chara("elona.whom_dwell_in_the_vanity") end
   if Rand.one_in(10) then special_chara("elona.raphael") end
   if Rand.one_in(10) then special_chara("elona.renton") end
   if Rand.one_in(10) then special_chara("elona.strange_scientist") end

   MapTileset.apply(map.tileset, map)

   for _, item in Item.iter(map) do
      item.own_state = Enum.OwnState.NotOwned
   end

   return map
   -- <<<<<<<< elona122/shade2/map_rand.hsp:703 	return true ..
end

-- >>>>>>>> shade2/map.hsp:70 	if gArea=areaQuest{ ..
local function quest_chara_filter(difficulty)
   return function(map)
      return {
         level = Calc.calc_object_level(difficulty + 1, map),
         quality = Calc.calc_object_quality(Enum.Quality.Normal),
      }
   end
end
-- <<<<<<<< shade2/map.hsp:76 		} ..

function QuestMap.generate_hunt(difficulty)
-- >>>>>>>> shade2/map_rand.hsp:117 		if gQuest=qHunt{ ..
   local params = {
      tileset = "elona.dungeon_forest",
      width = 28 + Rand.rnd(6),
      height = 20 + Rand.rnd(6),
      chara_filter = quest_chara_filter(difficulty)
   }

   local area = InstancedArea:new()
   local floor = 1
   local gen, params = DungeonTemplate.type_hunt(floor, params)
   local map = DungeonMap.generate(area, floor, gen, params)
   area:add_floor(map)
   Area.register(area, { parent = Area.for_map(Map.current()) })
   -- <<<<<<<< shade2/map_rand.hsp:122 			} ..

   map:set_archetype("elona.quest", { set_properties = true })
   map.is_indoor = false
   -- >>>>>>>> shade2/sound.hsp:412 			if gQuest=qHunt		:music=mcBattle1 ...
   map.music = "elona.battle1"
   -- <<<<<<<< shade2/sound.hsp:411 		if gArea=areaQuest{ ..
   map.name = I18N.get("map.quest.outskirts")

   return map
end

-- >>>>>>>> shade2/map_rand.hsp:709 *map_createDungeonConquer ..
function QuestMap.generate_derived_hunt(map_archetype_id, create_cb)
   local area = InstancedArea:new()
   local floor = 1
   local params = {}

   local map_archetype = data["base.map_archetype"]:ensure(map_archetype_id)
   local map = map_archetype.on_generate_map(area, floor, params)
   map:set_archetype("elona.quest_huntex", { set_properties = true })
   map.name = I18N.get("map.quest.urban_area")
   Rand.set_seed()

   map:iter_feats():each(IOwned.remove_ownership)
   map:iter_charas():each(IOwned.remove_ownership)

   create_cb(map)

   for _, item in Item.iter(map) do
      if item._id == "elona.well" or item._id == "elona.fountain" then
         item.params.amount_remaining = item.params.amount_remaining - 10
      end
      if item._id == "elona.safe" then
         item.params.chest_item_level = 0
      end
   end

   area:add_floor(map)
   Area.register(area, { parent = Area.for_map(Map.current()) })

   return map
end
-- <<<<<<<< shade2/map_rand.hsp:744 	return ..

function QuestMap.generate_huntex(map_archetype_id, chara_id, enemy_level, difficulty)
   -- >>>>>>>> shade2/map_rand.hsp:722 	if gQuest=qHuntEx{ ..
   local gen_charas = function(map)
      local count = Rand.rnd(6) + 4
      for i = 1, count do
         local filter = {
            level = difficulty * 3 / 2,
            initial_level = enemy_level,
            quality = Enum.Quality.Bad,
            id = chara_id
         }
         local chara = Charagen.create(nil, nil, filter, map)
         chara.faction = "base.enemy"
      end
   end
   -- <<<<<<<< shade2/map_rand.hsp:726 		} ..

   local map = QuestMap.generate_derived_hunt(map_archetype_id, gen_charas)
-- >>>>>>>> shade2/sound.hsp:416 			if gQuest=qHuntEx	:music=mcArena ...
   map.music = "elona.arena"
-- <<<<<<<< shade2/sound.hsp:415 			if gQuest=qConquer	:music=mcBoss ..
   return map
end

function QuestMap.generate_conquer(map_archetype_id, quest)
   -- >>>>>>>> shade2/map_rand.hsp:718 	if gQuest=qConquer{ ..
   local difficulty = quest.difficulty
   local enemy_level = quest.params.enemy_level
   local chara_id = quest.params.enemy_id

   local gen_charas = function(map)
      local filter = {
         level = difficulty,
         initial_level = enemy_level,
         quality = Enum.Quality.God,
         id = chara_id
      }
      local chara = Charagen.create(nil, nil, filter, map)
      chara.faction = "base.enemy"
      quest.params.target_chara_uid = chara.uid
   end
   -- <<<<<<<< shade2/map_rand.hsp:721 		} ..

   local map = QuestMap.generate_derived_hunt(map_archetype_id, gen_charas)
-- >>>>>>>> shade2/sound.hsp:415 			if gQuest=qConquer	:music=mcBoss ...
   map.music = "elona.boss"
-- <<<<<<<< shade2/sound.hsp:414 			if gQuest=qPerform	:music=mcCasino ..
   return map
end

function QuestMap.generate_harvest(difficulty)
   -- >>>>>>>> shade2/map_rand.hsp:337 	mField=mFieldOutdoor ..
   local map = InstancedMap:new(58 + Rand.rnd(16), 50 + Rand.rnd(16))
   map:set_archetype("elona.quest_harvest", { set_properties = true })
   map:clear(MapTileset.get("elona.mapgen_floor", map))
   map.name = I18N.get("map.quest.harvest")

   MapgenUtils.spray_tile(map, "elona.grass_bush_3", 10)
   MapgenUtils.spray_tile(map, "elona.grass_patch_3", 10)
   MapgenUtils.spray_tile(map, "elona.grass", 30)
   MapgenUtils.spray_tile(map, "elona.grass_violets", 4)
   MapgenUtils.spray_tile(map, "elona.grass_tall_2", 2)
   MapgenUtils.spray_tile(map, "elona.grass_tall_1", 2)
   MapgenUtils.spray_tile(map, "elona.grass_tall_2", 2)
   MapgenUtils.spray_tile(map, "elona.grass_patch_1", 2)

   for _ = 1, 30 do
      local width = Rand.rnd(5) + 5
      local height = Rand.rnd(4) + 4
      local dx = Rand.rnd(map:width())
      local dy = Rand.rnd(map:height())

      local tile = "elona.field_1"
      if Rand.one_in(2) then
         tile = "elona.field_2"
      end

      local size = math.floor(math.clamp(Pos.dist(dx, dy, map:width()/2, map:height()/2)/8, 0, 8))
      local crop_item_id = Rand.choice(Filters.isetcrop)

      for y = dy, dy + height do
         if y >= map:height() then
            break
         end
         for x = dx, dx + width do
            if x >= map:width() then
               break
            end

            map:set_tile(x, y, tile)
            if Rand.one_in(10) and Item.at(x, y, map):length() == 0 then
               local item_id
               if Rand.one_in(4) then
                  item_id = crop_item_id
               else
                  item_id = Rand.choice(Filters.isetcrop)
               end
               local crop = Item.create(item_id, x, y, {}, map)
               crop.own_state = Enum.OwnState.Quest
               local weight = math.floor(math.clamp(size + Rand.rnd(Rand.rnd(4) + 1), 0, 9))
               crop.weight = math.floor(crop.weight * (80 + weight * weight * 100) / 100)
               crop.params.harvest_weight_class = weight
            end
         end
      end
   end

   for _ = 1, 70 + Rand.rnd(20) do
      local x = Rand.rnd(map:width())
      local y = Rand.rnd(map:height())
      local tile = map:tile(x, y)._id
      if tile ~= "elona.field_1" and tile ~= "elona.field_2" and Item.at(x, y, map):length() == 0 then
         if Rand.one_in(8) then
            local tree = Itemgen.create(x, y, { categories = "elona.tree" }, map)
            tree.own_state = Enum.OwnState.NotOwned
         else
            Feat.create("elona.pot", x, y, {}, map)
         end
      end
   end

   for _ = 1, 30 do
      MapgenUtils.generate_chara(map)
   end

   return map
   -- <<<<<<<< shade2/map_rand.hsp:393 	return true ..
end

return QuestMap
