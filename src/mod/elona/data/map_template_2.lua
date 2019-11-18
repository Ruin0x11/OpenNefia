local test_world = {
   _id = "test_world",
   _type = "elona_sys.map_template",
   elona_id = 47,
   map = "test",
   copy = {
      types = { "world_map" },
      entrance_type = "WorldMapPos",
      tile_type = 1,
      turn_cost = 50000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 0
   }
}
data:add(test_world)

local test_world_north_border = {
   _id = "test_world_north_border",
   _type = "elona_sys.map_template",
   elona_id = 48,
   map = "test2",
   image = "elona.feat_area_border_tent",
   copy = {
      types = { "guild" },
      entrance_type = "South",
      tile_type = 2,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      chara_filter = chara_filter_town()
   }
}
data:add(test_world_north_border)

local south_tyris = {
   _id = "south_tyris",
   _type = "elona_sys.map_template",
   elona_id = 44,
   map = "styris",
   copy = {
      types = { "world_map" },
      entrance_type = "WorldMapPos",
      tile_type = 1,
      turn_cost = 50000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 0
   }
}
data:add(south_tyris)

local south_tyris_north_border = {
   _id = "south_tyris_north_border",
   _type = "elona_sys.map_template",
   elona_id = 45,
   map = "test2",
   image = "elona.feat_area_border_tent",
   copy = {
      types = { "guild" },
      entrance_type = "South",
      tile_type = 2,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      chara_filter = chara_filter_town()
   }
}
data:add(south_tyris_north_border)

local the_smoke_and_pipe = {
   _id = "the_smoke_and_pipe",
   _type = "elona_sys.map_template",
   elona_id = 46,
   map = "inn1",
   image = "elona.feat_area_the_smoke_and_pipe",
   copy = {
      types = { "guild" },
      entrance_type = "South",
      tile_type = 2,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      chara_filter = chara_filter_town()
   }
}
data:add(the_smoke_and_pipe)

local north_tyris = {
   _id = "north_tyris",
   _type = "elona_sys.map_template",
   elona_id = 4,
   map = "ntyris",
   copy = {
      types = { "world_map" },
      entrance_type = "WorldMapPos",
      tile_type = 1,
      turn_cost = 50000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 0
   }
}
data:add(north_tyris)

local vernis = {
   _id = "vernis",
   _type = "elona_sys.map_template",
   elona_id = 5,
   image = "elona.feat_area_city",
   map = "vernis",
   copy = {
      types = { "town" },
      entrance_type = "Custom",
      tile_type = 2,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 999,
      is_outdoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      quest_town_id = 1,
      quest_custom_map = "vernis",
      chara_filter = chara_filter_town {
         [1] = function()
            if Rand.one_in(2) then
               return { id = "core.miner" }
            end

            return nil
         end
      }
   }
}
data:add(vernis)

local yowyn = {
   _id = "yowyn",
   _type = "elona_sys.map_template",
   elona_id = 12,
   map = "yowyn",
   image = "elona.feat_area_village",
   copy = {
      types = { "town" },
      entrance_type = "Custom",
      tile_type = 2,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 999,
      is_outdoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      quest_town_id = 2,
      quest_custom_map = "yowyn",
      chara_filter = chara_filter_town {
         [1] = function()
            if Rand.one_in(2) then
               return { id = "core.farmer" }
            end

            return nil
         end
      }
   }
}
data:add(yowyn)

local palmia = {
   _id = "palmia",
   _type = "elona_sys.map_template",
   elona_id = 15,
   map = "palmia",
   image = "elona.feat_area_palace",
   copy = {
      types = { "town" },
      entrance_type = "Custom",
      tile_type = 2,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      quest_town_id = 3,
      quest_custom_map = "palmia",
      chara_filter = chara_filter_town {
         [1] = function()
            if Rand.one_in(3) then
               return { id = "core.noble" }
            end

            return nil
         end
      }
   }
}
data:add(palmia)

local derphy = {
   _id = "derphy",
   _type = "elona_sys.map_template",
   elona_id = 14,
   map = "rogueden",
   image = "elona.feat_area_village",
   copy = {
      types = { "town" },
      entrance_type = "Custom",
      tile_type = 2,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 999,
      is_outdoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      quest_town_id = 4,
      quest_custom_map = "rogueden",
      chara_filter = chara_filter_town {
         [1] = function()
            if Rand.one_in(3) then
               return { id = "core.rogue" }
            elseif Rand.one_in(2) then
               return { id = "core.prostitute" }
            end
         end,

         -- Thieves guild
         [3] = function()
            return { id = "core.thief_guild_member" }
         end
      }
   }

}
data:add(derphy)

local port_kapul = {
   _id = "port_kapul",
   _type = "elona_sys.map_template",
   elona_id = 11,
   map = "kapul",
   image = "elona.feat_area_city",
   copy = {
      types = { "town" },
      entrance_type = "Custom",
      tile_type = 2,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 999,
      is_outdoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      quest_town_id = 5,
      quest_custom_map = "kapul",
      chara_filter = chara_filter_town {
         -- Fighters guild
         [3] = function()
            return { id = "core.fighter_guild_member" }
         end
      }
   }
}
data:add(port_kapul)

local noyel = {
   _id = "noyel",
   _type = "elona_sys.map_template",
   elona_id = 33,
   map = "noyel",
   image = "elona.feat_area_village_snow",
   copy = {
      types = { "town" },
      entrance_type = "Custom",
      tile_type = 2,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      quest_town_id = 6,
      quest_custom_map = "noyel",
      villagers_make_snowmen = true,
      chara_filter = chara_filter_town {
         [1] = function()
            if Rand.one_in(3) then
               return { id = "core.sister" }
            end
         end
      }
   }
}
data:add(noyel)

local lumiest = {
   _id = "lumiest",
   _type = "elona_sys.map_template",
   elona_id = 36,
   map = "lumiest",
   image = "elona.feat_area_city",
   copy = {
      types = { "town" },
      entrance_type = "Custom",
      tile_type = 2,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 999,
      is_outdoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      quest_town_id = 7,
      quest_custom_map = "lumiest",
      chara_filter = chara_filter_town {
         [1] = function()
            if Rand.one_in(3) then
               return { id = "core.artist" }
            end
         end,

         -- Mages guild
         [3] = function()
            return { id = "core.mage_guild_member" }
         end
      }
   }
}
data:add(lumiest)

local fields = {
   _id = "fields",
   _type = "elona_sys.map_template",
   elona_id = 2,
   copy = {
      types = { "field" },
      entrance_type = "Center",
      tile_type = 4,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = true,
      has_anchored_npcs = false,
      default_ai_calm = 0
   }
}
data:add(fields)

local your_home = {
   _id = "your_home",
   _type = "elona_sys.map_template",
   elona_id = 7,

   image = "elona.feat_area_your_dungeon",
   map = "home0",
   copy = {
      types = { "player_owned" },
      entrance_type = "South",
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 10,
      is_outdoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      tile_type = 3,
      is_fixed = false
   }
}
data:add(your_home)

local show_house = {
   _id = "show_house",
   _type = "elona_sys.map_template",
   elona_id = 35,
   map = "dungeon1",
   image = "elona.feat_area_border_tent",
   copy = {
      types = { "temporary" },
      entrance_type = "South",
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = false,
      has_anchored_npcs = false,
      default_ai_calm = 1,
      tile_type = 3,
      reveals_fog = true,
      prevents_monster_ball = true
   }
}
data:add(show_house)

local arena = {
   _id = "arena",
   _type = "elona_sys.map_template",
   elona_id = 6,
   map = "arena_1",
   copy = {
      types = { "temporary" },
      entrance_type = "Center",
      tile_type = 100,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = false,
      has_anchored_npcs = false,
      default_ai_calm = 0,
      reveals_fog = true,
      prevents_domination = true,
      prevents_monster_ball = true
   }
}
data:add(arena)

local pet_arena = {
   _id = "pet_arena",
   _type = "elona_sys.map_template",
   elona_id = 40,
   map = "arena_2",
   copy = {
      types = { "temporary" },
      entrance_type = "StairUp",
      tile_type = 100,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = false,
      has_anchored_npcs = false,
      default_ai_calm = 0,
      reveals_fog = true,
      prevents_teleport = true,
      prevents_domination = true,
      prevents_monster_ball = true
   }
}
data:add(pet_arena)

local quest = {
   _id = "quest",
   _type = "elona_sys.map_template",
   elona_id = 13,
   copy = {
      types = { "temporary" },
      entrance_type = "Center",
      tile_type = 100,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = true,
      has_anchored_npcs = false,
      default_ai_calm = 0,
      shows_floor_count_in_name = true,
      prevents_building_shelter = true
   }
}
data:add(quest)

local lesimas = {
   _id = "lesimas",
   _type = "elona_sys.map_template",
   elona_id = 3,
   map = "dungeon1",
   image = "elona.feat_area_lesimas",
   copy = {
      types = { "dungeon" },
      entrance_type = "StairUp",
      tile_type = 0,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 45,
      is_outdoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 0,
      can_return_to = true,
      shows_floor_count_in_name = true,
      chara_filter = function()
         local opts = { objlv = Calc.calc_objlv(Map.current().dungeon_level), quality = 1 }

         if Map.current().dungeon_level < 4 and opts.objlv > 5 then
            opts.objlv = 5
         end

         return opts
      end
   }
}
data:add(lesimas)

local the_void = {
   _id = "the_void",
   _type = "elona_sys.map_template",
   elona_id = 42,
   map = "dungeon1",
   image = "elona.feat_area_lesimas",
   copy = {
      types = { "dungeon" },
      entrance_type = "StairUp",
      tile_type = 0,
      turn_cost = 10000,
      danger_level = 50,
      deepest_dungeon_level = 99999999,
      is_outdoor = false,
      has_anchored_npcs = false,
      default_ai_calm = 0,
      can_return_to = true,
      prevents_domination = true,
      chara_filter = function()
         return { level = math.modf(Map.current().dungeon_level, 50) + 5, quality = 1 }
      end
   }
}
data:add(the_void)

local tower_of_fire = {
   _id = "tower_of_fire",
   _type = "elona_sys.map_template",
   elona_id = 16,
   map = "dungeon1",
   image = "elona.feat_area_tower_of_fire",
   copy = {
      types = { "dungeon_tower" },
      entrance_type = "StairUp",
      tile_type = 0,
      turn_cost = 10000,
      danger_level = 15,
      deepest_dungeon_level = 18,
      is_outdoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 0,
      chara_filter = function()
         return { level = Map.current().dungeon_level, quality = 1, fltn = "fire" }
      end
   }
}
data:add(tower_of_fire)

local crypt_of_the_damned = {
   _id = "crypt_of_the_damned",
   _type = "elona_sys.map_template",
   elona_id = 17,
   map = "dungeon1",
   image = "elona.feat_area_crypt",
   copy = {
      types = { "dungeon" },
      entrance_type = "StairUp",
      tile_type = 0,
      turn_cost = 10000,
      danger_level = 25,
      deepest_dungeon_level = 30,
      is_outdoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 0,
      chara_filter = function()
         return { level = Map.current().dungeon_level, quality = 1, fltn = "undead" }
      end
   }
}
data:add(crypt_of_the_damned)

local ancient_castle = {
   _id = "ancient_castle",
   _type = "elona_sys.map_template",
   elona_id = 18,
   map = "dungeon1",
   image = "elona.feat_area_castle",
   copy = {
      types = { "dungeon_castle" },
      entrance_type = "StairUp",
      tile_type = 0,
      turn_cost = 10000,
      danger_level = 17,
      deepest_dungeon_level = 22,
      is_outdoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 0,
      chara_filter = function()
         local opts = { level = Map.current().dungeon_level, quality = 1 }

         if Rand.one_in(2) then
            opts.fltn = "man"
         end

         return opts
      end
   }
}
data:add(ancient_castle)

local dragons_nest = {
   _id = "dragons_nest",
   _type = "elona_sys.map_template",
   elona_id = 19,
   map = "dungeon1",
   image = "elona.feat_area_dungeon",
   copy = {
      types = { "dungeon" },
      entrance_type = "StairUp",
      tile_type = 0,
      turn_cost = 10000,
      danger_level = 30,
      deepest_dungeon_level = 33,
      is_outdoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 0,
      chara_filter = function()
         return { level = Map.current().dungeon_level, quality = 1 }
      end
   }
}
data:add(dragons_nest)

local mountain_pass = {
   _id = "mountain_pass",
   _type = "elona_sys.map_template",
   elona_id = 26,
   map = "dungeon1",
   image = "elona.feat_area_dungeon",
   copy = {
      types = { "dungeon" },
      entrance_type = "StairDown",
      tile_type = 0,
      turn_cost = 10000,
      danger_level = 25,
      deepest_dungeon_level = 29,
      is_outdoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 0
   }
}
data:add(mountain_pass)

local puppy_cave = {
   _id = "puppy_cave",
   _type = "elona_sys.map_template",
   elona_id = 27,
   map = "dungeon1",
   image = "elona.feat_area_dungeon",
   copy = {
      types = { "dungeon" },
      entrance_type = "StairUp",
      tile_type = 0,
      turn_cost = 10000,
      danger_level = 2,
      deepest_dungeon_level = 5,
      is_outdoor = false,
      has_anchored_npcs = false,
      default_ai_calm = 0,
      generator = map.puppy_cave
   }
}
data:add(puppy_cave)

local minotaurs_nest = {
   _id = "minotaurs_nest",
   _type = "elona_sys.map_template",
   elona_id = 38,
   map = "dungeon1",
   image = "elona.feat_area_dungeon",
   copy = {
      types = { "dungeon" },
      entrance_type = "StairUp",
      tile_type = 0,
      turn_cost = 10000,
      danger_level = 23,
      deepest_dungeon_level = 27,
      is_outdoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 0,
      chara_filter = function()
         local opts = { level = Map.current().dungeon_level, quality = 1 }

         if Rand.one_in(2) then
            opts.fltn = "mino"
         end

         return opts
      end
   }
}
local yeeks_nest = {
   _id = "yeeks_nest",
   _type = "elona_sys.map_template",
   elona_id = 28,
   map = "dungeon1",
   image = "elona.feat_area_dungeon",
   copy = {
      types = { "dungeon" },
      entrance_type = "StairUp",
      tile_type = 0,
      turn_cost = 10000,
      danger_level = 5,
      deepest_dungeon_level = 5,
      is_outdoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 0,
      chara_filter = function()
         local opts = { level = Map.current().dungeon_level, quality = 1 }

         if Rand.one_in(2) then
            opts.fltn = "yeek"
         end

         return opts
      end
   }
}
local pyramid = {
   _id = "pyramid",
   _type = "elona_sys.map_template",
   elona_id = 37,
   map = "sqPyramid",
   image = "elona.feat_area_pyramid",
   copy = {
      types = { "dungeon" },
      entrance_type = "StairUp",
      tile_type = 0,
      turn_cost = 10000,
      danger_level = 20,
      deepest_dungeon_level = 21,
      is_outdoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 0,
      prevents_teleport = true,
      chara_filter = function()
         return { level = Map.current().dungeon_level, quality = 1, flttypemajor = 13 }
      end
   }
}
data:add(pyramid)

local lumiest_graveyard = {
   _id = "lumiest_graveyard",
   _type = "elona_sys.map_template",
   elona_id = 10,
   map = "grave_1",
   image = "elona.feat_area_crypt",
   copy = {
      types = { "shelter" },
      entrance_type = "Custom",
      tile_type = 4,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      chara_filter = function()
         return { level = 20, quality = 1, fltselect = 4 }
      end
   }
}
data:add(lumiest_graveyard)

local truce_ground = {
   _id = "truce_ground",
   _type = "elona_sys.map_template",
   elona_id = 20,
   map = "truce_ground",
   image = "elona.feat_area_truce_ground",
   copy = {
      types = { "shelter" },
      entrance_type = "Custom",
      tile_type = 4,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      chara_filter = function()
         return { level = 20, quality = 1, fltselect = 4 }
      end
   }
}
data:add(truce_ground)

local jail = {
   _id = "jail",
   _type = "elona_sys.map_template",
   elona_id = 41,
   map = "jail1",
   image = "elona.feat_area_jail",
   copy = {
      types = { "shelter" },
      entrance_type = "StairUp",
      tile_type = 12,
      turn_cost = 100000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = false,
      has_anchored_npcs = false,
      default_ai_calm = 0,
      prevents_teleport = true,
      prevents_return = true,
      prevents_random_events = true
   }
}
data:add(jail)

local cyber_dome = {
   _id = "cyber_dome",
   _type = "elona_sys.map_template",
   elona_id = 21,
   map = "cyberdome",
   image = "elona.feat_area_tent",
   copy = {
      types = { "guild" },
      entrance_type = "South",
      tile_type = 8,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      chara_filter = function()
         return { level = 10, quality = 1, fltn = "sf" }
      end
   }
}
data:add(cyber_dome)

local larna = {
   _id = "larna",
   _type = "elona_sys.map_template",
   elona_id = 25,
   map = "highmountain",
   image = "elona.feat_area_village",
   copy = {
      types = { "guild" },
      entrance_type = "Custom",
      tile_type = 9,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      can_return_to = true,
      chara_filter = chara_filter_town()
   }
}
data:add(larna)

local miral_and_garoks_workshop = {
   _id = "miral_and_garoks_workshop",
   _type = "elona_sys.map_template",
   elona_id = 34,
   map = "smith0",
   image = "elona.feat_area_miral_and_garoks_workshop",
   copy = {
      types = { "guild" },
      entrance_type = "South",
      tile_type = 2,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      reveals_fog = true,
      chara_filter = chara_filter_town()
   }
}
data:add(miral_and_garoks_workshop)

local mansion_of_younger_sister = {
   _id = "mansion_of_younger_sister",
   _type = "elona_sys.map_template",
   elona_id = 29,
   map = "sister",
   copy = {
      types = { "shelter" },
      entrance_type = "South",
      tile_type = 2,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      can_return_to = true,
      villagers_make_snowmen = true,
      is_hidden_in_world_map = true
   }
}
data:add(mansion_of_younger_sister)

local embassy = {
   _id = "embassy",
   _type = "elona_sys.map_template",
   elona_id = 32,
   map = "office_1",
   image = "elona.feat_area_embassy",
   copy = {
      types = { "guild" },
      entrance_type = "South",
      tile_type = 2,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      reveals_fog = true,
      chara_filter = chara_filter_town()
   }
}
data:add(embassy)

local north_tyris_south_border = {
   _id = "north_tyris_south_border",
   _type = "elona_sys.map_template",
   elona_id = 43,
   map = "station-nt1",
   image = "elona.feat_area_border_tent",
   copy = {
      types = { "guild" },
      entrance_type = "South",
      tile_type = 2,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      chara_filter = chara_filter_town()
   }
}
data:add(north_tyris_south_border)

local fort_of_chaos_beast = {
   _id = "fort_of_chaos_beast",
   _type = "elona_sys.map_template",
   elona_id = 22,
   map = "god",
   image = "elona.feat_area_god",
   copy = {
      types = { "shelter" },
      entrance_type = "South",
      tile_type = 100,
      turn_cost = 10000,
      danger_level = 33,
      deepest_dungeon_level = 33,
      is_outdoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      chara_filter = chara_filter_town()
   }
}
data:add(fort_of_chaos_beast)

local fort_of_chaos_machine = {
   _id = "fort_of_chaos_machine",
   _type = "elona_sys.map_template",
   elona_id = 23,
   map = "god",
   image = "elona.feat_area_god",
   copy = {
      types = { "shelter" },
      entrance_type = "South",
      tile_type = 100,
      turn_cost = 10000,
      danger_level = 33,
      deepest_dungeon_level = 33,
      is_outdoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 1
   }
}
data:add(fort_of_chaos_machine)

local fort_of_chaos_collapsed = {
   _id = "fort_of_chaos_collapsed",
   _type = "elona_sys.map_template",
   elona_id = 24,
   map = "god",
   image = "elona.feat_area_god",
   copy = {
      types = { "shelter" },
      entrance_type = "South",
      tile_type = 100,
      turn_cost = 10000,
      danger_level = 33,
      deepest_dungeon_level = 33,
      is_outdoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 1
   }
}
data:add(fort_of_chaos_collapsed)

local shelter = {
   _id = "shelter",
   _type = "elona_sys.map_template",
   elona_id = 30,
   map = "shelter_2", -- TODO
   copy = {
      types = { "player_owned" },
      entrance_type = "StairUp",
      tile_type = 100,
      turn_cost = 1000000,
      danger_level = -999999,
      deepest_dungeon_level = 999999,
      is_outdoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      reveals_fog = true,
      prevents_return = true,
      prevents_building_shelter = true,
      prevents_random_events = true
   }
}
data:add(shelter)

local test_site = {
   _id = "test_site",
   _type = "elona_sys.map_template",
   elona_id = 9,
   map = "dungeon1",
   copy = {
      types = { "shelter" },
      entrance_type = "Center",
      tile_type = 4,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 45,
      is_outdoor = true,
      has_anchored_npcs = false,
      default_ai_calm = 0
   }
}
data:add(test_site)

