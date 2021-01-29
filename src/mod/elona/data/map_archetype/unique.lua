local MapEntrance = require("mod.elona_sys.api.MapEntrance")
local Enum = require("api.Enum")
local Calc = require("mod.elona.api.Calc")
local Elona122Map = require("mod.elona_sys.map_loader.Elona122Map")
local util = require("mod.elona.data.map_archetype.util")
local Item = require("api.Item")
local Chara = require("api.Chara")
local I18N = require("api.I18N")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local Gui = require("api.Gui")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")

do
   local lumiest_graveyard = {
      _id = "lumiest_graveyard",
      _type = "base.map_archetype",
      elona_id = 10,

      image = "elona.feat_area_crypt",

      starting_pos = MapEntrance.edge,

      properties = {
         music = "elona.ruin",
         types = { "shelter" },
         tileset = "elona.wilderness",
         level = 1,
         is_indoor = false,
         has_anchored_npcs = true,
         default_ai_calm = 1,
         max_crowd_density = 7,
      }
   }

   function lumiest_graveyard.chara_filter(map)
      return {
         level = Calc.calc_object_level(20, map),
         quality = Calc.calc_object_quality(Enum.Quality.Normal),
         fltselect = Enum.FltSelect.Friend
      }
   end

   function lumiest_graveyard.on_generate_map(area, floor)
      local map = Elona122Map.generate("grave_1")
      map:set_archetype("elona.lumiest_graveyard", { set_properties = true })

      for _=1,math.floor(map:calc("max_crowd_density"/2)) do
         MapgenUtils.generate_chara(map)
      end

      return map
   end

   data:add(lumiest_graveyard)

   data:add {
      _type = "base.area_archetype",
      _id = "lumiest_graveyard",
      elona_id = 10,

      image = "elona.feat_area_crypt",

      floors = {
         [1] = "elona.lumiest_graveyard"
      },

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 74,
         y = 31,
         starting_floor = 1
      }
   }
end

do
   local truce_ground = {
      _id = "truce_ground",
      _type = "base.map_archetype",
      elona_id = 20,

      starting_pos = MapEntrance.edge,

      properties = {
         music = "elona.ruin",
         types = { "shelter" },
         tileset = "elona.wilderness",
         level = 1,
         is_indoor = false,
         max_crowd_density = 10,
         has_anchored_npcs = true,
         default_ai_calm = 1
      }
   }

   function truce_ground.chara_filter(map)
      return {
         level = Calc.calc_object_level(20, map),
         quality = Calc.calc_object_quality(Enum.Quality.Normal),
         fltselect = Enum.FltSelect.Friend
      }
   end

   function truce_ground.on_generate_map(area, floor)
      local map = Elona122Map.generate("shrine_1")
      map:set_archetype("elona.truce_ground", { set_properties = true })

      local function mkaltar(god, x, y)
         local item = Item.create("elona.altar", x, y, {}, map)
         item.params.altar_god_id = god
         item.own_state = Enum.OwnState.NotOwned
      end

      mkaltar("elona.mani", 10, 8)
      mkaltar("elona.lulwy", 13, 8)
      mkaltar("elona.opatos", 10, 13)
      mkaltar("elona.ehekatl", 13, 13)
      mkaltar("elona.itzpalt", 20, 8)
      mkaltar("elona.kumiromi", 23, 8)
      mkaltar("elona.jure", 20, 13)

      for _=1,math.floor(map:calc("max_crowd_density")/2) do
         MapgenUtils.generate_chara(map)
      end

      return map
   end

   data:add(truce_ground)

   data:add {
      _type = "base.area_archetype",
      _id = "truce_ground",
      elona_id = 20,

      image = "elona.feat_area_truce_ground",

      floors = {
         [1] = "elona.truce_ground"
      },

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 51,
         y = 9,
         starting_floor = 1
      }
   }
end

do
   local jail = {
      _id = "jail",
      _type = "base.map_archetype",
      elona_id = 41,

      on_generate_map = util.generate_122("jail1"),

      starting_pos = MapEntrance.stairs_up,

      properties = {
         types = { "shelter" },
         tileset = "elona.jail",
         turn_cost = 100000,
         level = 1,
         is_indoor = true,
         default_ai_calm = 0,
         max_crowd_density = 0,
         prevents_teleport = true,
         prevents_return = true,
         prevents_random_events = true
      }
   }

   data:add(jail)

   data:add {
      _type = "base.area_archetype",
      _id = "jail",
      elona_id = 41,

      image = "elona.feat_area_jail",

      floors = {
         [1] = "elona.jail"
      },

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 28,
         y = 37,
         starting_floor = 1
      }
   }
end

local function on_generate_border(map)
   local chara = Chara.create("elona.shopkeeper", 7, 23, nil, map)
   chara:add_role("elona.shopkeeper", { inventory_id = "elona.general_vendor" })
   chara.shop_rank = 10
   chara.name = I18N.get("chara.job.general_vendor", chara.name)
   chara.ai_calm = 3

   chara = Chara.create("elona.shopkeeper", 5, 17, nil, map)
   chara:add_role("elona.shopkeeper", { inventory_id = "elona.trader" })
   chara.shop_rank = 12
   chara.name = I18N.get("chara.job.trader", chara.name)
   chara.ai_calm = 3

   chara = Chara.create("elona.shopkeeper", 16, 19, nil, map)
   chara:add_role("elona.shopkeeper", { inventory_id = "elona.innkeeper" })
   chara:add_role("elona.innkeeper")
   chara.shop_rank = 8
   chara.name = I18N.get("chara.job.innkeeper", chara.name)

   chara = Chara.create("elona.bartender", 17, 13, nil, map)
   chara:add_role("elona.bartender")

   chara = Chara.create("elona.caravan_master", 7, 3, nil, map)
   chara:add_role("elona.caravan_master", {dest=""})

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
   chara:add_role("elona.guard")
   chara.ai_calm = 3

   chara = Chara.create("elona.guard", 8, 7, nil, map)
   chara:add_role("elona.guard")
   chara.ai_calm = 3
end

do
   local test_world_north_border = {
      _id = "test_world_north_border",
      _type = "base.map_archetype",
      elona_id = 48,

      starting_pos = MapEntrance.south,

      chara_filter = util.chara_filter_town(),

      properties = {
         types = { "guild" },
         tileset = "elona.town",
         turn_cost = 10000,
         level = 1,
         is_indoor = false,
         has_anchored_npcs = true,
         default_ai_calm = 1,
         max_crowd_density = 0,
      }
   }

   function test_world_north_border.on_generate_map(area, floor)
      local map = Elona122Map.generate("test2")
      map:set_archetype("elona.test_world_north_border", { set_properties = true })

      on_generate_border(map)

      DeferredEvent.add(function()
            for _, ally in Chara.iter_allies() do
               if not ally:find_role("elona.adventurer")
                  and not ally:find_role("elona.special")
               then
                  ally:set_emotion_icon("elona.blind", 20)
                  Gui.mes("event.my_eyes", ally)
               end
            end
      end)

      return map
   end

   data:add(test_world_north_border)

   data:add {
      _type = "base.area_archetype",
      _id = "test_world_north_border",
      elona_id = 48,

      image = "elona.feat_area_border_tent",

      floors = {
         [1] = "elona.test_world_north_border"
      },

      parent_area = {
         _id = "elona.test_world",
         on_floor = 1,
         x = 28,
         y = 1,
         starting_floor = 1
      }
   }
end

do
   local north_tyris_south_border = {
      _id = "north_tyris_south_border",
      _type = "base.map_archetype",
      elona_id = 43,

      starting_pos = MapEntrance.south,

      chara_filter = util.chara_filter_town(),

      properties = {
         types = { "guild" },
         tileset = "elona.town",
         level = 1,
         is_indoor = false,
         has_anchored_npcs = true,
         default_ai_calm = 1,
         max_crowd_density = 0,
      }
   }

   function north_tyris_south_border.on_generate_map(area, floor)
      local map = Elona122Map.generate("station-nt1")
      map:set_archetype("elona.north_tyris_south_border", { set_properties = true })

      on_generate_border(map)

      return map
   end

   data:add(north_tyris_south_border)

   data:add {
      _type = "base.area_archetype",
      _id = "north_tyris_south_border",
      elona_id = 43,

      image = "elona.feat_area_border_tent",

      floors = {
         [1] = "elona.north_tyris_south_border"
      },

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 27,
         y = 52,
         starting_floor = 1
      }
   }
end

do
   local south_tyris_north_border = {
      _id = "south_tyris_north_border",
      _type = "base.map_archetype",
      elona_id = 45,

      chara_filter = util.chara_filter_town(),

      starting_pos = MapEntrance.south,

      properties = {
         types = { "guild" },
         tileset = "elona.town",
         turn_cost = 10000,
         level = 1,
         is_indoor = false,
         has_anchored_npcs = true,
         default_ai_calm = 1,
      },
   }
   data:add(south_tyris_north_border)

   function south_tyris_north_border.on_generate_map(area, floor)
      local map = Elona122Map.generate("station-nt1")
      map:set_archetype("elona.south_tyris_north_border", { set_properties = true })

      on_generate_border(map)

      return map
   end

   data:add {
      _type = "base.area_archetype",
      _id = "south_tyris_north_border",
      elona_id = 45,

      image = "elona.feat_area_border_tent",

      floors = {
         [1] = "elona.south_tyris_north_border"
      },

      parent_area = {
         _id = "elona.south_tyris",
         on_floor = 1,
         x = 42,
         y = 1,
         starting_floor = 1
      }
   }
end

do
   local the_smoke_and_pipe = {
      _id = "the_smoke_and_pipe",
      _type = "base.map_archetype",
      elona_id = 46,

      starting_pos = MapEntrance.south,

      chara_filter = util.chara_filter_town(),

      properties = {
         music = "elona.ruin",
         types = { "guild" },
         tileset = "elona.town",
         turn_cost = 10000,
         level = 1,
         is_indoor = true,
         has_anchored_npcs = true,
         default_ai_calm = 1,
         max_crowd_density = 0,
      }
   }

   function the_smoke_and_pipe.on_generate_map(area, floor)
      local map = Elona122Map.generate("inn1")
      map:set_archetype("elona.the_smoke_and_pipe", { set_properties = true })

      local chara = Chara.create("elona.shopkeeper", 19, 10, nil, map)
      chara:add_role("elona.shopkeeper", { inventory_id = "elona.innkeeper" })
      chara:add_role("elona.innkeeper")
      chara.shop_rank = 8
      chara.name = I18N.get("chara.job.innkeeper", chara.name)

      chara = Chara.create("elona.the_leopard_warrior", 26, 16, nil, map)
      chara:add_role("elona.special")
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
      chara:add_role("elona.special")

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

      return map
   end

   data:add(the_smoke_and_pipe)

   data:add {
      _type = "base.area_archetype",
      _id = "the_smoke_and_pipe",
      elona_id = 46,

      image = "elona.feat_area_the_smoke_and_pipe",

      floors = {
         [1] = "elona.the_smoke_and_pipe"
      },

      parent_area = {
         _id = "elona.south_tyris",
         on_floor = 1,
         x = 39,
         y = 13,
         starting_floor = 1
      }
   }
end

do
   local miral_and_garoks_workshop = {
      _id = "miral_and_garoks_workshop",
      _type = "base.map_archetype",
      elona_id = 34,

      starting_pos = MapEntrance.south,

      chara_filter = util.chara_filter_town(),

      properties = {
         music = "elona.ruin",
         types = { "guild" },
         tileset = "elona.town",
         level = 1,
         is_indoor = false,
         has_anchored_npcs = true,
         default_ai_calm = 1,
         reveals_fog = true,
      }
   }

   function miral_and_garoks_workshop.on_generate_map(area, floor)
      local map = Elona122Map.generate("smith0")
      map:set_archetype("elona.miral_and_garoks_workshop", { set_properties = true })

      local chara = Chara.create("elona.garokk", 17, 11, nil, map)
      chara:add_role("elona.special")

      chara = Chara.create("elona.miral", 8, 16, nil, map)
      chara:add_role("elona.shopkeeper", {inventory_id="elona.miral"})

      for _=1,5 do
         chara = Chara.create("elona.cat", nil, nil, nil, map)
         chara:add_role("elona.special")
      end

      return map
   end

   data:add(miral_and_garoks_workshop)

   data:add {
      _type = "base.area_archetype",
      _id = "miral_and_garoks_workshop",
      elona_id = 34,

      image = "elona.feat_area_miral_and_garoks_workshop",

      floors = {
         [1] = "elona.miral_and_garoks_workshop"
      },

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 88,
         y = 25,
         starting_floor = 1
      }
   }
end

do
   local mansion_of_younger_sister = {
      _id = "mansion_of_younger_sister",
      _type = "base.map_archetype",
      elona_id = 29,

      starting_pos = MapEntrance.south,

      properties = {
         types = { "shelter" },
         tileset = "elona.town",
         level = 1,
         is_indoor = false,
         has_anchored_npcs = true,
         default_ai_calm = 1,
         villagers_make_snowmen = true,
         max_crowd_density = 0,
         is_hidden_in_world_map = true
      }
   }

   function mansion_of_younger_sister.on_generate_map(area, floor, params)
      local map = Elona122Map.generate("sister")
      map:set_archetype("elona.mansion_of_younger_sister", { set_properties = true })

      if params.is_first_generation then
         local item = Item.create("elona.book_of_rachel", 12, 8, nil, map)
         item.params.book_of_rachel_number = 4
      end

      local chara = Chara.create("elona.younger_sister_of_mansion", 12, 6, nil, map)
      chara:add_role("elona.shopkeeper", {inventory_id="elona.younger_sister_of_mansion"})

      for _=1,6 do
         chara = Chara.create("elona.young_lady", nil, nil, nil, map)
         chara:add_role("elona.special")
      end

      for _=1,8 do
         chara = Chara.create("elona.silver_cat", nil, nil, nil, map)
         chara:add_role("elona.special")
      end

      return map
   end

   data:add(mansion_of_younger_sister)

   data:add {
      _type = "base.area_archetype",
      _id = "mansion_of_younger_sister",
      elona_id = 29,

      floors = {
         [1] = "elona.mansion_of_younger_sister"
      },

      metadata = {
         can_return_to = true,
      },

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 18,
         y = 2,
         starting_floor = 1
      }
   }
end

do
   local cyber_dome = {
      _id = "cyber_dome",
      _type = "base.map_archetype",
      elona_id = 21,

      starting_pos = MapEntrance.south,

      properties = {
         music = "elona.town5",
         types = { "guild" },
         tileset = "elona.sf",
         level = 1,
         is_indoor = true,
         has_anchored_npcs = true,
         default_ai_calm = 1,
         max_crowd_density = 10,
      }
   }

   function cyber_dome.chara_filter(map)
      return {
         level = Calc.calc_object_level(10, map),
         quality = Calc.calc_object_quality(Enum.Quality.Normal),
         tag_filters = {"sf"}
      }
   end

   function cyber_dome.on_generate_map(area, floor)
      local map = Elona122Map.generate("cyberdome")
      map:set_archetype("elona.cyber_dome", { set_properties = true })

      local item = Item.create("elona.altar", 19, 5, {}, map)
      item.params.god_id = "elona.mani"
      item.own_state = "not_owned"

      local chara = Chara.create("elona.sales_person", 9, 16, nil, map)
      chara:add_role("elona.shopkeeper", {inventory_id="elona.cyber_dome"})
      chara.shop_rank = 10

      chara = Chara.create("elona.sales_person", 9, 8, nil, map)
      chara:add_role("elona.shopkeeper", {inventory_id="elona.cyber_dome"})
      chara.shop_rank = 10

      chara = Chara.create("elona.strange_scientist", 28, 7, nil, map)
      chara:add_role("elona.special")
      chara.shop_rank = 10

      for _=1,4 do
         chara = Chara.create("elona.citizen_of_cyber_dome", nil, nil, nil, map)
         chara:add_role("elona.citizen")

         chara = Chara.create("elona.citizen_of_cyber_dome2", nil, nil, nil, map)
         chara:add_role("elona.citizen")
      end

      for _=1,math.floor(map:calc("max_crowd_density")/2) do
         MapgenUtils.generate_chara(map)
      end

      return map
   end

   data:add(cyber_dome)

   data:add {
      _type = "base.area_archetype",
      _id = "cyber_dome",
      elona_id = 21,

      image = "elona.feat_area_tent",

      floors = {
         [1] = "elona.cyber_dome"
      },

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 21,
         y = 27,
         starting_floor = 1
      }
   }
end

do
   local larna = {
      _id = "larna",
      _type = "base.map_archetype",
      elona_id = 25,

      chara_filter = util.chara_filter_town(),

      properties = {
         music = "elona.village1",
         types = { "guild" },
         tileset = "elona.eastern",
         level = 1,
         is_indoor = false,
         has_anchored_npcs = true,
         default_ai_calm = 1,
         max_crowd_density = 20,
      }
   }

   function larna.starting_pos(map)
      return { x = 1, y = 14 }
   end

   function larna.on_generate_map(area, floor)
      local map = Elona122Map.generate("highmountain")
      map:set_archetype("elona.larna", { set_properties = true })

      local chara = Chara.create("elona.wizard", 21, 23, nil, map)
      chara:add_role("elona.returner")

      chara = Chara.create("elona.shopkeeper", 9, 44, nil, map)
      chara:add_role("elona.shopkeeper", { inventory_id = "elona.dye_vendor" })
      chara.shop_rank = 5
      chara.name = I18N.get("chara.job.dye_vendor", chara.name)

      chara = Chara.create("elona.shopkeeper", 13, 37, nil, map)
      chara:add_role("elona.shopkeeper", { inventory_id = "elona.souvenir_vendor" })
      chara.shop_rank = 30
      chara.name = I18N.get("chara.job.souvenir_vendor", chara.name)

      chara = Chara.create("elona.bartender", 24, 48, nil, map)
      chara:add_role("elona.bartender")

      Chara.create("elona.hot_spring_maniac", 7, 36, nil, map)
      Chara.create("elona.hot_spring_maniac", 9, 38, nil, map)
      Chara.create("elona.hot_spring_maniac", 6, 33, nil, map)
      Chara.create("elona.hot_spring_maniac", 3, 33, nil, map)
      Chara.create("elona.hot_spring_maniac", 8, 31, nil, map)
      Chara.create("elona.hot_spring_maniac", 4, 36, nil, map)

      for _=1,7 do
         chara = Chara.create("elona.citizen", nil, nil, nil, map)
         chara:add_role("elona.citizen")

         chara = Chara.create("elona.citizen2", nil, nil, nil, map)
         chara:add_role("elona.citizen")

         Chara.create("elona.hot_spring_maniac", nil, nil, nil, map)
      end

      for _=1,15 do
         Chara.create("elona.hot_spring_maniac", nil, nil, nil, map)
      end

      for _=1,math.floor(map:calc("max_crowd_density"/2)) do
         MapgenUtils.generate_chara(map)
      end

      return map
   end

   data:add(larna)

   data:add {
      _type = "base.area_archetype",
      _id = "larna",
      elona_id = 25,

      image = "elona.feat_area_village",

      floors = {
         [1] = "elona.larna"
      },

      metadata = {
         can_return_to = true,
      },

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 64,
         y = 47,
         starting_floor = 1
      }
   }
end

do
   local embassy = {
      _id = "embassy",
      _type = "base.map_archetype",
      elona_id = 32,

      starting_pos = MapEntrance.south,

      chara_filter = util.chara_filter_town(),

      properties = {
         music = "elona.ruin",
         types = { "guild" },
         tileset = "elona.town",
         level = 1,
         is_indoor = true,
         has_anchored_npcs = true,
         default_ai_calm = 1,
         reveals_fog = true,
         max_crowd_density = 0,
      }
   }
   function embassy.on_generate_map(area, floor)
      local map = Elona122Map.generate("office_1")
      map:set_archetype("elona.embassy", { set_properties = true })

      local chara = Chara.create("elona.sales_person", 9, 2, {}, map)
      chara:add_role("elona.shopkeeper", {inventory_id="elona.embassy"})
      chara.shop_rank = 10

      chara = Chara.create("elona.sales_person", 15, 2, {}, map)
      chara:add_role("elona.shopkeeper", {inventory_id="elona.embassy"})
      chara.shop_rank = 10

      chara = Chara.create("elona.sales_person", 21, 2, {}, map)
      chara:add_role("elona.shopkeeper", {inventory_id="elona.deed"})
      chara.shop_rank = 10

      chara = Chara.create("elona.sales_person", 3, 2, {}, map)
      chara:add_role("elona.shopkeeper", {inventory_id="elona.deed"})
      chara.shop_rank = 10

      for _=1,3 do
         chara = Chara.create("elona.citizen", nil, nil, nil, map)
         chara:add_role("elona.citizen")

         chara = Chara.create("elona.citizen2", nil, nil, nil, map)
         chara:add_role("elona.citizen")
      end

      for i=1,4 do
         chara = Chara.create("elona.guard", 3+(i-1)*6, 9, nil, map)
         chara:add_role("elona.guard")
      end

      return map
   end

   data:add(embassy)

   data:add {
      _type = "base.area_archetype",
      _id = "embassy",
      elona_id = 32,

      image = "elona.feat_area_embassy",

      floors = {
         [1] = "elona.embassy"
      },

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 53,
         y = 21,
         starting_floor = 1
      }
   }
end

do
   local fort_of_chaos_beast = {
      _id = "fort_of_chaos_beast",
      _type = "base.map_archetype",
      elona_id = 22,

      starting_pos = MapEntrance.south,

      properties = {
         music = "elona.boss2",
         types = { "shelter" },
         tileset = "elona.tower_1",
         level = 33,
         is_indoor = true,
         has_anchored_npcs = true,
         default_ai_calm = 1,
         max_crowd_density = 0,
      }
   }
   function fort_of_chaos_beast.on_generate_map(area,floor)
      local map = Elona122Map.generate("god")
      map:set_archetype("elona.fort_of_chaos_beast", { set_properties = true })

      Chara.create("elona.frisia", 12, 14, nil, map)

      return map
   end

   data:add(fort_of_chaos_beast)

   data:add {
      _type = "base.area_archetype",
      _id = "fort_of_chaos_beast",
      elona_id = 22,

      image = "elona.feat_area_god",

      floors = {
         [1] = "elona.fort_of_chaos_beast"
      },

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 13,
         y = 43,
         starting_floor = 1
      }
   }
end

do
   local fort_of_chaos_machine = {
      _id = "fort_of_chaos_machine",
      _type = "base.map_archetype",
      elona_id = 23,

      starting_pos = MapEntrance.south,

      properties = {
         music = "elona.boss2",
         types = { "shelter" },
         tileset = "elona.tower_1",
         level = 33,
         max_crowd_density = 0,
         is_indoor = true,
         has_anchored_npcs = true,
         default_ai_calm = 1
      }
   }
   function fort_of_chaos_machine.on_generate_map(area, floor)
      local map = Elona122Map.generate("god")
      map:set_archetype("elona.fort_of_chaos_machine", { set_properties = true })

      Chara.create("elona.utima", 12, 14, nil, map)

      return map
   end

   data:add(fort_of_chaos_machine)

   data:add {
      _type = "base.area_archetype",
      _id = "fort_of_chaos_machine",
      elona_id = 23,

      image = "elona.feat_area_god",

      floors = {
         [1] = "elona.fort_of_chaos_machine"
      },

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 51,
         y = 32,
         starting_floor = 1
      }
   }
end

do
   local fort_of_chaos_collapsed = {
      _id = "fort_of_chaos_collapsed",
      _type = "base.map_archetype",
      elona_id = 24,

      image = "elona.feat_area_god",

      starting_pos = MapEntrance.south,

      properties = {
         music = "elona.boss2",
         types = { "shelter" },
         tileset = "elona.tower_1",
         level = 33,
         max_crowd_density = 0,
         is_indoor = true,
         has_anchored_npcs = true,
         default_ai_calm = 1
      }
   }
   function fort_of_chaos_collapsed.on_generate_map(area, floor)
      local map = Elona122Map.generate("god")
      map:set_archetype("elona.fort_of_chaos_collapsed", { set_properties = true })

      Chara.create("elona.azzrssil", 12, 14, nil, map)

      return map
   end

   data:add(fort_of_chaos_collapsed)

   data:add {
      _type = "base.area_archetype",
      _id = "fort_of_chaos_collapsed",
      elona_id = 24,

      image = "elona.feat_area_god",

      floors = {
         [1] = "elona.fort_of_chaos_collapsed"
      },

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 35,
         y = 10,
         starting_floor = 1
      }
   }
end

do
   local shelter = {
      _id = "shelter",
      _type = "base.map_archetype",
      elona_id = 30,

      starting_pos = MapEntrance.stairs_up,

      properties = {
         music = "elona.lonely",
         types = { "player_owned" },
         tileset = "elona.tower_1",
         turn_cost = 1000000,
         level = -999999,
         is_indoor = true,
         has_anchored_npcs = true,
         default_ai_calm = 1,
         max_crowd_density = 0,
         item_on_ground_limit = 5,

         reveals_fog = true,
         prevents_return = true,
         prevents_building_shelter = true,
         prevents_random_events = true
      }
   }

   function shelter.on_generate_map(area, floor)
      -- >>>>>>>> shade2/map.hsp:379 	if gArea=areaShelter{ ..
      -- TODO inn
      local map
      local is_inn = floor == 1 -- TODO put in area metadata?
      if is_inn then
         map = Elona122Map.generate("shelter_2")
         map:set_archetype("elona.shelter", { set_properties = true })
         map.is_temporary = true
         map.types = { "field" }
      else
         map = Elona122Map.generate("shelter_1")
         map:set_archetype("elona.shelter", { set_properties = true })
      end

      return map
      -- <<<<<<<< shade2/map.hsp:392 		} ..
   end

   data:add(shelter)
end

do
   local test_site = {
      _id = "test_site",
      _type = "base.map_archetype",

      unique = true,

      properties = {
         music = "elona.puti",
         types = { "dungeon" },
         level = 5,
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
         }
      }
   }

   function test_site.starting_pos(map)
      return { x = 6, y = 27 }
   end

   function test_site.on_generate_map(area, floor)
      local map = Elona122Map.generate("sqNightmare")
      map:set_archetype("elona.shelter", { set_properties = true })

      Sidequest.set_quest_targets(map)

      return map
   end

   data:add(test_site)

   data:add {
      _type = "base.area_archetype",
      _id = "test_site",

      floors = {
         [1] = "elona.test_site"
      },

      --parent_area = {
      --   _id = "elona.north_tyris",
      --   on_floor = 1,
      --   x = 20,
      --   y = 20,
      --   starting_floor = 1
      --}
   }
end


do
   local pyramid = {
      _id = "pyramid",
      _type = "base.map_archetype",
      elona_id = 37,

      starting_pos = MapEntrance.stairs_up,

      properties = {
         music = "elona.puti",
         types = { "dungeon" },
         player_start_pos = "elona.stair_up",
         level = 20,
         is_indoor = true,
         has_anchored_npcs = true,
         default_ai_calm = 0,
         max_crowd_density = 40,
         prevents_teleport = true,
      }
   }

   function pyramid.chara_filter(map)
      local level = Calc.calc_object_level(map.level, map)
      local quality = Calc.calc_object_quality(Enum.Quality.Normal)

      return {
         level = level,
         quality = quality,
         category = 13
      }
   end

   function pyramid.on_generate_map(area, floor)
      local map = Elona122Map.generate("sqPyramid")
      map:set_archetype("elona.pyramid", { set_properties = true })

      for _ = 1, map:calc("max_crowd_density") + 1 do
         MapgenUtils.generate_chara(map)
      end

      util.connect_existing_stairs(map, area, floor)

      return map
   end

   data:add(pyramid)

   local pyramid_2 = {
      _id = "pyramid_2",
      _type = "base.map_archetype",
      -- elona_id = 37,

      starting_pos = MapEntrance.stairs_up,

      properties = {
         music = "elona.puti",
         types = { "dungeon" },
         level = 21,
         is_indoor = true,
         has_anchored_npcs = true,
         default_ai_calm = 0,
         max_crowd_density = 0,
         prevents_teleport = true,
      }
   }

   function pyramid_2.chara_filter(map)
      local level = Calc.calc_object_level(map.level, map)
      local quality = Calc.calc_object_quality(Enum.Quality.Normal)

      return {
         level = level,
         quality = quality,
         category = 13
      }
   end

   function pyramid_2.on_generate_map(area, floor)
      local map = Elona122Map.generate("sqPyramid2")
      map:set_archetype("elona.pyramid_2", { set_properties = true })

      util.connect_existing_stairs(map, area, floor)

      return map
   end

   data:add(pyramid_2)

   local area_pyramid = {
      _type = "base.area_archetype",
      _id = "pyramid",

      image = "elona.feat_area_pyramid",

      floors = {
         [1] = "elona.pyramid",
         [2] = "elona.pyramid_2",
      },

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 4,
         y = 11,
         starting_floor = 1
      }
   }

   data:add(area_pyramid)
end
