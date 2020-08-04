local lumiest_graveyard = {
   _id = "lumiest_graveyard",
   _type = "base.map_archetype",
   elona_id = 10,

   map = generate_122("grave_1"),
   image = "elona.feat_area_crypt",
   unique = true,

   properties = {
      music = "elona.ruin",
      types = { "shelter" },
      player_start_pos = "base.edge",
      tileset = "elona.wilderness",
      level = 1,
      deepest_dungeon_level = 1,
      is_indoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      max_crowd_density = 7,
      chara_filter = function(map)
         return Calc.filter(20, "good", {fltselect = 4}, map)
      end
   }
}
function lumiest_graveyard.on_generate(map)
   for _=1,math.floor(map:calc("max_crowd_density"/2)) do
      generate_chara(map)
   end
end
data:add(lumiest_graveyard)

local truce_ground = {
   _id = "truce_ground",
   _type = "base.map_archetype",

   elona_id = 20,
   map = generate_122("shrine_1"),
   image = "elona.feat_area_truce_ground",
   unique = true,

   properties = {
      music = "elona.ruin",
      types = { "shelter" },
      player_start_pos = "base.edge",
      tileset = "elona.wilderness",
      level = 1,
      deepest_dungeon_level = 1,
      is_indoor = false,
      max_crowd_density = 10,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      chara_filter = function(map)
         return Calc.filter(20, "good", {fltselect = 4}, map)
      end
   }
}
function truce_ground.on_generate(map)
   local function mkaltar(god, x, y)
      local item = Item.create("elona.altar", x, y, {}, map)
      item.params.god_id = god
      item.own_state = "not_owned"
   end

   mkaltar("elona.mani", 10, 8)
   mkaltar("elona.lulwy", 13, 8)
   mkaltar("elona.opatos", 10, 13)
   mkaltar("elona.ehekatl", 13, 13)
   mkaltar("elona.itzpalt", 20, 8)
   mkaltar("elona.kumiromi", 23, 8)
   mkaltar("elona.jure", 20, 13)

   for _=1,math.floor(map:calc("max_crowd_density")/2) do
      generate_chara(map)
   end
end
data:add(truce_ground)

local jail = {
   _id = "jail",
   _type = "base.map_archetype",

   elona_id = 41,
   map = generate_122("jail1"),
   image = "elona.feat_area_jail",
   unique = true,

   properties = {
      types = { "shelter" },
      player_start_pos = "elona.stair_up",
      tileset = "elona.jail",
      turn_cost = 100000,
      level = 1,
      deepest_dungeon_level = 1,
      is_indoor = true,
      default_ai_calm = 0,
      max_crowd_density = 0,
      prevents_teleport = true,
      prevents_return = true,
      prevents_random_events = true
   }
}
data:add(jail)

local test_world = {
   _id = "test_world",
   _type = "base.map_archetype",

   elona_id = 47,
   map = generate_122("test"),
   unique = true,

   properties = {
      types = { "world_map" },
      player_start_pos = "base.world",
      tileset = "elona.world_map",
      turn_cost = 50000,
      level = 1,
      deepest_dungeon_level = 1,
      is_indoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 0
   },
   areas = {
      { map = generate_122("elona.test_world_north_border"), x = 28, y = 1 },
   }
}
data:add(test_world)

local function on_generate_border(map)
   local chara = Chara.create("elona.shopkeeper", 7, 23, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.general_vendor" }
   chara.shop_rank = 10
   chara.name = I18N.get("chara.job.general_vendor", chara.name)
   chara.ai_calm = 3

   chara = Chara.create("elona.shopkeeper", 5, 17, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.trader" }
   chara.shop_rank = 12
   chara.name = I18N.get("chara.job.trader", chara.name)
   chara.ai_calm = 3

   chara = Chara.create("elona.shopkeeper", 16, 19, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.innkeeper" }
   chara.roles["elona.innkeeper"] = true
   chara.shop_rank = 8
   chara.name = I18N.get("chara.job.inkeeper", chara.name)

   chara = Chara.create("elona.bartender", 17, 13, nil, map)
   chara.roles["elona.bartender"] = true

   chara = Chara.create("elona.caravan_master", 7, 3, nil, map)
   chara.roles["elona.caravan_master"] = {dest=""}

   for _=1,2 do
      chara = Chara.create("elona.beggar", nil, nil, nil, map)

      chara = Chara.create("elona.mercenary_warrior", nil, nil, nil, map)
      chara.faction = "base.citizen"

      chara = Chara.create("elona.mercenary_archer", nil, nil, nil, map)
      chara.faction = "base.citizen"

      chara = Chara.create("elona.mercenary_wizard", nil, nil, nil, map)
      chara.faction = "base.citizen"
   end

   chara = Chara.create("elona.guard", 5, 7, nil, map)
   chara.roles["elona.guard"] = true
   chara.ai_calm = 3

   chara = Chara.create("elona.guard", 8, 7, nil, map)
   chara.roles["elona.guard"] = true
   chara.ai_calm = 3
end

local test_world_north_border = {
   _id = "test_world_north_border",
   _type = "base.map_archetype",

   elona_id = 48,
   map = generate_122("test2"),
   image = "elona.feat_area_border_tent",
   unique = true,

   properties = {
      types = { "guild" },
      player_start_pos = "base.south",
      tileset = "elona.town",
      turn_cost = 10000,
      level = 1,
      deepest_dungeon_level = 1,
      is_indoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      max_crowd_density = 0,
      chara_filter = chara_filter_town()
   }
}
function test_world_north_border.on_generate(map)
   on_generate_border(map)

   DeferredEvent.add(function()
         for _, ally in Chara.iter_allies() do
            if not ally.roles["elona.adventurer"]
               and not ally.roles["elona.special"]
            then
               ally:set_emotion_icon("elona.blind", 20)
               Gui.mes("event.my_eyes", ally)
            end
         end
   end)
end
data:add(test_world_north_border)

local south_tyris = {
   _id = "south_tyris",
   _type = "base.map_archetype",

   elona_id = 44,
   map = generate_122("styris"),
   unique = true,

   properties = {
      types = { "world_map" },
      player_start_pos = "base.world",
      tileset = "elona.world_map",
      turn_cost = 50000,
      level = 1,
      deepest_dungeon_level = 1,
      is_indoor = false,
      has_anchored_npcs = true,
      max_crowd_density = 0,
      default_ai_calm = 0
   },
   areas = {
      { map = generate_122("elona.south_tyris_north_border"), x = 42, y = 1 },
      { map = generate_122("elona.the_smoke_and_pipe"), x = 39, y = 13 },
   }
}
data:add(south_tyris)

local north_tyris_south_border = {
   _id = "north_tyris_south_border",
   _type = "base.map_archetype",

   elona_id = 43,
   map = generate_122("station-nt1"),
   image = "elona.feat_area_border_tent",
   unique = true,

   properties = {
      types = { "guild" },
      player_start_pos = "base.south",
      tileset = "elona.town",
      level = 1,
      deepest_dungeon_level = 1,
      is_indoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      max_crowd_density = 0,
      chara_filter = chara_filter_town()
   },
   on_generate = on_generate_border
}
data:add(north_tyris_south_border)

local south_tyris_north_border = {
   _id = "south_tyris_north_border",
   _type = "base.map_archetype",

   elona_id = 45,
   map = generate_122("station-nt1"),
   image = "elona.feat_area_border_tent",
   unique = true,

   properties = {
      types = { "guild" },
      player_start_pos = "base.south",
      tileset = "elona.town",
      turn_cost = 10000,
      level = 1,
      deepest_dungeon_level = 1,
      is_indoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      chara_filter = chara_filter_town()
   },
   on_generate = on_generate_border
}
data:add(south_tyris_north_border)

local the_smoke_and_pipe = {
   _id = "the_smoke_and_pipe",
   _type = "base.map_archetype",

   elona_id = 46,
   map = generate_122("inn1"),
   image = "elona.feat_area_the_smoke_and_pipe",
   unique = true,

   properties = {
      music = "elona.ruin",
      types = { "guild" },
      player_start_pos = "base.south",
      tileset = "elona.town",
      turn_cost = 10000,
      level = 1,
      deepest_dungeon_level = 1,
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      max_crowd_density = 0,
      chara_filter = chara_filter_town()
   }
}
function the_smoke_and_pipe.on_generate(map)
   local chara = Chara.create("elona.shopkeeper", 19, 10, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.innkeeper" }
   chara.roles["elona.innkeeper"] = true
   chara.shop_rank = 8
   chara.name = I18N.get("chara.job.innkeeper", chara.name)

   chara = Chara.create("elona.the_leopard_warrior", 26, 16, nil, map)
   chara.roles["elona.special"] = true
   chara.ai_calm = 3

   chara = Chara.create("elona.town_child", 25, 15, nil, map)
   chara.ai_calm = 3

   chara = Chara.create("elona.town_child", 25, 17, nil, map)
   chara.ai_calm = 3

   chara = Chara.create("elona.town_child", 27, 18, nil, map)
   chara.ai_calm = 3

   chara = Chara.create("elona.town_child", 27, 16, nil, map)
   chara.ai_calm = 3

   chara = Chara.create("elona.town_child", 26, 17, nil, map)
   chara.ai_calm = 3

   chara = Chara.create("elona.silvia", 4, 3, nil, map)
   chara.roles["elona.special"] = true

   Chara.create("elona.rogue", 4, 2, nil, map)
   Chara.create("elona.farmer", 3, 3, nil, map)
   Chara.create("elona.artist", 4, 4, nil, map)
   Chara.create("elona.noble", 5, 4, nil, map)
   Chara.create("elona.hot_spring_maniac", 24, 3, nil, map)
   Chara.create("elona.hot_spring_maniac", 26, 4, nil, map)
   Chara.create("elona.hot_spring_maniac", 25, 5, nil, map)
   Chara.create("elona.hot_spring_maniac", 25, 9, nil, map)
   Chara.create("elona.bard", 12, 9, nil, map)

   for _=1,2 do
      Chara.create("elona.beggar", nil, nil, nil, map)

      chara = Chara.create("elona.mercenary_warrior", nil, nil, nil, map)
      chara.faction = "base.citizen"

      chara = Chara.create("elona.old_person", nil, nil, nil, map)
      chara.faction = "base.citizen"

      Chara.create("elona.mercenary", nil, nil, nil, map)
      Chara.create("elona.tourist", nil, nil, nil, map)
   end
end
data:add(the_smoke_and_pipe)

local miral_and_garoks_workshop = {
   _id = "miral_and_garoks_workshop",
   _type = "base.map_archetype",

   elona_id = 34,
   map = generate_122("smith0"),
   image = "elona.feat_area_miral_and_garoks_workshop",
   unique = true,

   properties = {
      music = "elona.ruin",
      types = { "guild" },
      player_start_pos = "base.south",
      tileset = "elona.town",
      level = 1,
      deepest_dungeon_level = 1,
      is_indoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      reveals_fog = true,
      chara_filter = chara_filter_town()
   }
}
function miral_and_garoks_workshop.on_generate(map)
   local chara = Chara.create("elona.garokk", 17, 11, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.miral", 8, 16, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id="elona.miral"}

   for _=1,5 do
      chara = Chara.create("elona.cat", nil, nil, nil, map)
      chara.roles["elona.special"] = true
   end
end
data:add(miral_and_garoks_workshop)

local mansion_of_younger_sister = {
   _id = "mansion_of_younger_sister",
   _type = "base.map_archetype",

   elona_id = 29,
   map = generate_122("sister"),
   unique = true,

   properties = {
      types = { "shelter" },
      player_start_pos = "base.south",
      tileset = "elona.town",
      level = 1,
      deepest_dungeon_level = 1,
      is_indoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      can_return_to = true,
      villagers_make_snowmen = true,
      max_crowd_density = 0,
      is_hidden_in_world_map = true
   }
}
function mansion_of_younger_sister.on_generate(map, params)
   if params.is_first_generation then
      local item = Item.create("elona.book_of_rachel", 12, 8, nil, map)
      item.params.book_no = 4
   end

   local chara = Chara.create("elona.younger_sister_of_mansion", 12, 6, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id="elona.younger_sister_of_mansion"}

   for _=1,6 do
      chara = Chara.create("elona.young_lady", nil, nil, nil, map)
      chara.roles["elona.special"] = true
   end

   for _=1,8 do
      chara = Chara.create("elona.silver_cat", nil, nil, nil, map)
      chara.roles["elona.special"] = true
   end
end
data:add(mansion_of_younger_sister)

local cyber_dome = {
   _id = "cyber_dome",
   _type = "base.map_archetype",

   elona_id = 21,
   map = generate_122("cyberdome"),
   image = "elona.feat_area_tent",
   unique = true,

   properties = {
      music = "elona.town5",
      types = { "guild" },
      player_start_pos = "base.south",
      tileset = "elona.sf",
      level = 1,
      deepest_dungeon_level = 1,
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      max_crowd_density = 10,
      chara_filter = function(map)
         return Calc.filter(10, "bad", {tag_filters = {"sf"}}, map)
      end
   }
}
function cyber_dome.on_generate(map)
   local item = Item.create("elona.altar", 19, 5, {}, map)
   item.params.god_id = "elona.mani"
   item.own_state = "not_owned"

   local chara = Chara.create("elona.sales_person", 9, 16, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id="elona.cyber_dome"}
   chara.shop_rank = 10

   chara = Chara.create("elona.sales_person", 9, 8, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id="elona.cyber_dome"}
   chara.shop_rank = 10

   chara = Chara.create("elona.strange_scientist", 28, 7, nil, map)
   chara.roles["elona.special"] = true
   chara.shop_rank = 10

   for _=1,4 do
      chara = Chara.create("elona.citizen_of_cyber_dome", nil, nil, nil, map)
      chara.roles["elona.citizen"] = true

      chara = Chara.create("elona.citizen_of_cyber_dome2", nil, nil, nil, map)
      chara.roles["elona.citizen"] = true
   end

   for _=1,math.floor(map:calc("max_crowd_density")/2) do
      generate_chara(map)
   end
end
data:add(cyber_dome)

local larna = {
   _id = "larna",
   _type = "base.map_archetype",

   elona_id = 25,
   map = generate_122("highmountain"),
   image = "elona.feat_area_village",
   unique = true,

   properties = {
      music = "elona.village1",
      types = { "guild" },
      player_start_pos = { x = 1, y = 14 },
      tileset = "elona.eastern",
      level = 1,
      deepest_dungeon_level = 1,
      is_indoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      can_return_to = true,
      max_crowd_density = 20,
      chara_filter = chara_filter_town()
   }
}
function larna.on_generate(map)
   local chara = Chara.create("elona.wizard", 21, 23, nil, map)
   chara.roles["elona.returner"] = true

   chara = Chara.create("elona.shopkeeper", 9, 44, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.dye_vendor" }
   chara.shop_rank = 5
   chara.name = I18N.get("chara.job.dye_vendor", chara.name)

   chara = Chara.create("elona.shopkeeper", 13, 37, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.souvenir_vendor" }
   chara.shop_rank = 30
   chara.name = I18N.get("chara.job.souvenir_vendor", chara.name)

   chara = Chara.create("elona.bartender", 24, 48, nil, map)
   chara.roles["elona.bartender"] = true

   Chara.create("elona.hot_spring_maniac", 7, 36, nil, map)
   Chara.create("elona.hot_spring_maniac", 9, 38, nil, map)
   Chara.create("elona.hot_spring_maniac", 6, 33, nil, map)
   Chara.create("elona.hot_spring_maniac", 3, 33, nil, map)
   Chara.create("elona.hot_spring_maniac", 8, 31, nil, map)
   Chara.create("elona.hot_spring_maniac", 4, 36, nil, map)

   for _=1,7 do
      chara = Chara.create("elona.citizen", nil, nil, nil, map)
      chara.roles["elona.citizen"] = true

      chara = Chara.create("elona.citizen2", nil, nil, nil, map)
      chara.roles["elona.citizen"] = true

      Chara.create("elona.hot_spring_maniac", nil, nil, nil, map)
   end

   for _=1,15 do
      Chara.create("elona.hot_spring_maniac", nil, nil, nil, map)
   end

   for _=1,math.floor(map:calc("max_crowd_density"/2)) do
      generate_chara(map)
   end
end
data:add(larna)

local embassy = {
   _id = "embassy",
   _type = "base.map_archetype",

   elona_id = 32,
   map = generate_122("office_1"),
   image = "elona.feat_area_embassy",
   unique = true,

   properties = {
      music = "elona.ruin",
      types = { "guild" },
      player_start_pos = "base.south",
      tileset = "elona.town",
      level = 1,
      deepest_dungeon_level = 1,
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      reveals_fog = true,
      max_crowd_density = 0,
      chara_filter = chara_filter_town()
   }
}
function embassy.on_generate(map)
   local chara = Chara.create("elona.sales_person", 9, 2, {}, map)
   chara.roles["elona.shopkeeper"] = {inventory_id="elona.embassy"}
   chara.shop_rank = 10

   chara = Chara.create("elona.sales_person", 15, 2, {}, map)
   chara.roles["elona.shopkeeper"] = {inventory_id="elona.embassy"}
   chara.shop_rank = 10

   chara = Chara.create("elona.sales_person", 21, 2, {}, map)
   chara.roles["elona.shopkeeper"] = {inventory_id="elona.deed"}
   chara.shop_rank = 10

   chara = Chara.create("elona.sales_person", 3, 2, {}, map)
   chara.roles["elona.shopkeeper"] = {inventory_id="elona.deed"}
   chara.shop_rank = 10

   for _=1,3 do
      chara = Chara.create("elona.citizen", nil, nil, nil, map)
      chara.roles["elona.citizen"] = true

      chara = Chara.create("elona.citizen2", nil, nil, nil, map)
      chara.roles["elona.citizen"] = true
   end

   for i=1,4 do
      chara = Chara.create("elona.guard", 3+(i-1)*6, 9, nil, map)
      chara.roles["elona.guard"] = true
   end
end
data:add(embassy)

local fort_of_chaos_beast = {
   _id = "fort_of_chaos_beast",
   _type = "base.map_archetype",

   elona_id = 22,
   map = generate_122("god"),
   image = "elona.feat_area_god",
   unique = true,

   properties = {
      music = "elona.boss2",
      types = { "shelter" },
      player_start_pos = "base.south",
      tileset = "elona.tower_1",
      level = 33,
      deepest_dungeon_level = 33,
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      max_crowd_density = 0,
      chara_filter = chara_filter_town()
   }
}
function fort_of_chaos_beast.on_generate(map)
   Chara.create("elona.frisia", 12, 14, nil, map)
end
data:add(fort_of_chaos_beast)

local fort_of_chaos_machine = {
   _id = "fort_of_chaos_machine",
   _type = "base.map_archetype",

   elona_id = 23,
   map = generate_122("god"),
   image = "elona.feat_area_god",
   unique = true,

   properties = {
      music = "elona.boss2",
      types = { "shelter" },
      player_start_pos = "base.south",
      tileset = "elona.tower_1",
      level = 33,
      deepest_dungeon_level = 33,
      max_crowd_density = 0,
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1
   }
}
function fort_of_chaos_machine.on_generate(map)
   Chara.create("elona.utima", 12, 14, nil, map)
end
data:add(fort_of_chaos_machine)

local fort_of_chaos_collapsed = {
   _id = "fort_of_chaos_collapsed",
   _type = "base.map_archetype",

   elona_id = 24,
   map = generate_122("god"),
   image = "elona.feat_area_god",
   unique = true,

   properties = {
      music = "elona.boss2",
      types = { "shelter" },
      player_start_pos = "base.south",
      tileset = "elona.tower_1",
      level = 33,
      deepest_dungeon_level = 33,
      max_crowd_density = 0,
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1
   }
}
function fort_of_chaos_collapsed.on_generate(map)
   Chara.create("elona.azzrssil", 12, 14, nil, map)
end
data:add(fort_of_chaos_collapsed)

local shelter = {
   _id = "shelter",
   _type = "base.map_archetype",

   elona_id = 30,
   map = generate_122("shelter_1"),
   unique = true,

   properties = {
      music = "elona.lonely",
      types = { "player_owned" },
      player_start_pos = "elona.stair_up",
      tileset = "elona.tower_1",
      turn_cost = 1000000,
      level = -999999,
      deepest_dungeon_level = 999999,
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      max_crowd_density = 0,
      item_limit = 5,

      reveals_fog = true,
      prevents_return = true,
      prevents_building_shelter = true,
      prevents_random_events = true
   }
}
data:add(shelter)

local shelter_inn = {
   _id = "shelter_inn",
   _type = "base.map_archetype",

   map = generate_122("shelter_2"),
   unique = true,

   properties = {
      music = "elona.lonely",
      types = { "field" },
      player_start_pos = "elona.stair_up",
      tileset = "elona.tower_1",
      turn_cost = 1000000,
      level = -999999,
      deepest_dungeon_level = 999999,
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      max_crowd_density = 0,
      item_limit = 5,
      is_generated_every_time = true,

      reveals_fog = true,
      prevents_return = true,
      prevents_building_shelter = true,
      prevents_random_events = true
   }
}
data:add(shelter_inn)

local test_site = {
   _id = "test_site",
   _type = "base.map_archetype",

   map = generate_122("sqNightmare"),
   unique = true,

   properties = {
      music = "elona.puti",
      types = { "dungeon" },
      player_start_pos = { x = 6, y = 27 },
      level = 5,
      deepest_dungeon_level = 999,
      is_indoor = true,
      is_not_renewable = true,
      max_crowd_density = 0,
      default_ai_calm = 0
   },
   events = {
      {
         id = "elona_sys.on_quest_check",
         name = "Sidequest: nightmare",

         callback = function(map)
            if Sidequest.progress("elona.nightmare") < 2 then
               if Sidequest.no_targets_remaining(map) then
                  Sidequest.set_progress("elona.nightmare", 2)
                  Sidequest.update_journal()
               end
            end
         end
      },
      {
         id = "base.on_map_generated",
         name = "Sidequest: nightmare",

         callback = function(map)
            Sidequest.set_quest_targets(map)
         end
      }
   }
}
data:add(test_site)
