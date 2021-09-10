local DungeonMap = require("mod.elona.api.DungeonMap")
local util = require("mod.elona.data.map_archetype.util")
local Rand = require("api.Rand")
local Enum = require("api.Enum")
local Calc = require("mod.elona.api.Calc")
local MapEntrance = require("mod.elona_sys.api.MapEntrance")
local Elona122Map = require("mod.elona_sys.map_loader.Elona122Map")
local Area = require("api.Area")
local NpcMemory = require("mod.elona_sys.api.NpcMemory")
local Chara = require("api.Chara")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local DungeonTemplate = require("mod.elona.api.DungeonTemplate")
local Dungeon = require("mod.elona.api.Dungeon")
local Gui = require("api.Gui")

do
   local lesimas = {
      _type = "base.map_archetype",
      _id = "lesimas",
      elona_id = 3,

      starting_pos = MapEntrance.stairs_up,

      properties = {
         types = { "dungeon" },
         is_indoor = true,
         has_anchored_npcs = true,
         default_ai_calm = "base.calm_null",
         shows_floor_count_in_name = true,
         material_spot_type = "elona.dungeon"
      }
   }

   function lesimas.chara_filter(map)
      -- >>>>>>>> shade2/map.hsp:30 	if gArea=areaLesimas{ ..
      local level = Calc.calc_object_level(map.level, map)
      local quality = Calc.calc_object_quality(Enum.Quality.Normal)

      if map.level < 4 and level > 5 then
         level = 5
      end

      return {
         level = level,
         quality = quality
      }
      -- <<<<<<<< shade2/map.hsp:33 	}  ..
   end

   data:add(lesimas)

   local area_lesimas = {
      _type = "base.area_archetype",
      _id = "lesimas",

      types = { "dungeon" },
      image = "elona.feat_area_lesimas",

      deepest_floor = 45,

      metadata = {
         can_return_to = true
      },

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 23,
         y = 29,
         starting_floor = 1
      }
   }

   local function last_boss_map(area, floor)
      -- >>>>>>>> shade2/map.hsp:1664 		if gLevel=areaMaxLevel(gArea){ ...
      local map = Elona122Map.generate("lesimas_1")
      map:set_archetype("elona.lesimas", { set_properties = true })
      map.max_crowd_density = 0
      map.is_temporary = true
      map.level = floor

      if Sidequest.is_active_main_quest("elona.main_quest") then
         map.music = "elona.last_boss"

         assert(Area.create_stairs_up(area, floor - 1, 16, 13, {}, map))

         if NpcMemory.killed("elona.zeome") == 0 then
            assert(Chara.create("elona.zeome", 16, 6, {}, map))
         elseif NpcMemory.killed("elona.orphe") == 0 then
            assert(Chara.create("elona.orphe", 16, 6, {}, map))
         end
      end

      return map
      -- <<<<<<<< shade2/map.hsp:1682 			} ..
   end

   function area_lesimas.on_generate_floor(area, floor)
      local map

      if floor == area:archetype().deepest_floor then
         map = last_boss_map(area, floor)
      else
         local gen, params = DungeonTemplate.lesimas(floor, { level = 1 })
         params.map_archetype_id = "elona.lesimas"
         map = DungeonMap.generate(area, floor, gen, params)
      end

      return map
   end

   data:add(area_lesimas)
end


do
   local the_void = {
      _id = "the_void",
      _type = "base.map_archetype",
      elona_id = 42,

      starting_pos = MapEntrance.stairs_up,

      properties = {
         types = { "dungeon" },
         is_indoor = true,
         default_ai_calm = "base.calm_null",
         prevents_domination = true,
         material_spot_type = "elona.dungeon"
      }
   }

   function the_void.chara_filter(map)
      local map_level = map.level + Area.floor_number(map)
      local level = Chara.calc_object_level(map_level % 50 + 5, map)
      local quality = Chara.calc_object_quality(Enum.Quality.Normal)
      return {
         level = level,
         quality = quality
      }
   end

   data:add(the_void)

   local area_the_void = {
      _type = "base.area_archetype",
      _id = "the_void",

      types = { "dungeon" },
      image = "elona.feat_area_lesimas",

      metadata = {
         can_return_to = true
      },

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 81,
         y = 51,
         starting_floor = 1
      }
   }

   function area_the_void.on_generate_floor(area, floor)
      local gen, params = DungeonTemplate.nefia_dungeon(floor, { level = 50 })
      params.map_archetype_id = "elona.the_void"
      local map = DungeonMap.generate(area, floor, gen, params)

      -- TODO void boss

      return map
   end

   data:add(area_the_void)
end


do
   local tower_of_fire = {
      _id = "tower_of_fire",
      _type = "base.map_archetype",
      elona_id = 16,

      starting_pos = MapEntrance.stairs_up,

      properties = {
         types = { "dungeon" },
         is_indoor = true,
         has_anchored_npcs = true,
         default_ai_calm = "base.calm_null",
         material_spot_type = "elona.building"
      }
   }

   function tower_of_fire.chara_filter(map)
      local level = Calc.calc_object_level(map.level, map)
      local quality = Calc.calc_object_quality(Enum.Quality.Normal)

      return {
         level = level,
         quality = quality,
         tag_filters = {"fire"}
      }
   end

   function tower_of_fire.on_map_pass_turn(map)
      -- >>>>>>>> shade2/map.hsp:3310 	if gArea=areaFireTrial{ ...
      if Rand.one_in(5) then
         local player = Chara.player()
         local resist = player:resist_grade("elona.fire")
         if resist < 6 then
            local damage = ((6 - resist) ^ 2) * 2
            Gui.mes_c("action.exit_map.it_is_hot", "Red")
            player:damage_hp(damage, "elona.fire")
         end
      end
      -- <<<<<<<< shade2/map.hsp:3316 	} ..
   end

   data:add(tower_of_fire)

   local area_tower_of_fire = {
      _type = "base.area_archetype",
      _id = "tower_of_fire",

      types = { "dungeon" },
      image = "elona.feat_area_tower_of_fire",

      deepest_floor = 4,

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 43,
         y = 4,
         starting_floor = 1
      }
   }

   function area_tower_of_fire.on_generate_floor(area, floor)
      local map

      if floor == area:archetype().deepest_floor then
         map = Elona122Map.generate("firet1")
         map:set_archetype("elona.tower_of_fire", { set_properties = true })
         map.max_crowd_density = 0
         map.level = floor
         map.music = "elona.last_boss"

         util.connect_existing_stairs(map, area, floor)
      else
         local gen, params = DungeonTemplate.tower_of_fire(floor, { level = 15 })
         params.map_archetype_id = "elona.tower_of_fire"
         map = DungeonMap.generate(area, floor, gen, params)
      end

      return map
   end

   data:add(area_tower_of_fire)
end


do
   local crypt_of_the_damned = {
      _id = "crypt_of_the_damned",
      _type = "base.map_archetype",
      elona_id = 17,

      starting_pos = MapEntrance.stairs_up,

      properties = {
         types = { "dungeon" },
         is_indoor = true,
         has_anchored_npcs = true,
         default_ai_calm = "base.calm_null",
         material_spot_type = "elona.dungeon"
      }
   }

   function crypt_of_the_damned.chara_filter(map)
      local level = Calc.calc_object_level(map.level, map)
      local quality = Calc.calc_object_quality(Enum.Quality.Normal)

      return {
         level = level,
         quality = quality,
         tag_filters = {"undead"}
      }
   end

   data:add(crypt_of_the_damned)

   local area_crypt_of_the_damned = {
      _type = "base.area_archetype",
      _id = "crypt_of_the_damned",

      types = { "dungeon" },
      image = "elona.feat_area_crypt",

      deepest_floor = 6,

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 38,
         y = 20,
         starting_floor = 1
      }
   }

   function area_crypt_of_the_damned.on_generate_floor(area, floor)
      local map

      if floor == area:archetype().deepest_floor then
         map = Elona122Map.generate("undeadt1")
         map:set_archetype("elona.crypt_of_the_damned", { set_properties = true })
         map.max_crowd_density = 0
         map.music = "elona.last_boss"
         map.level = floor

         util.connect_existing_stairs(map, area, floor)
      else
         local gen, params = DungeonTemplate.crypt_of_the_damned(floor, { level = 25 })
         params.map_archetype_id = "elona.crypt_of_the_damned"
         map = DungeonMap.generate(area, floor, gen, params)
      end

      return map
   end

   data:add(area_crypt_of_the_damned)
end


do
   local ancient_castle = {
      _id = "ancient_castle",
      _type = "base.map_archetype",
      elona_id = 18,

      starting_pos = MapEntrance.stairs_up,

      properties = {
         types = { "dungeon" },
         is_indoor = true,
         has_anchored_npcs = true,
         default_ai_calm = "base.calm_null",
         material_spot_type = "elona.building"
      }
   }

   function ancient_castle.chara_filter(map)
      local level = Calc.calc_object_level(map.level, map)
      local quality = Calc.calc_object_quality(Enum.Quality.Normal)
      local tag_filters = nil

      if Rand.one_in(2) then
         tag_filters = {"man"}
      end

      return {
         level = level,
         quality = quality,
         tag_filters = tag_filters
      }
   end

   data:add(ancient_castle)

   local area_ancient_castle = {
      _type = "base.area_archetype",
      _id = "ancient_castle",

      types = { "dungeon" },
      image = "elona.feat_area_castle",

      deepest_floor = 6,

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 26,
         y = 44,
         starting_floor = 1
      }
   }

   function area_ancient_castle.on_generate_floor(area, floor)
      local map

      if floor == area:archetype().deepest_floor then
         map = Elona122Map.generate("roguet1")
         map:set_archetype("elona.ancient_castle", { set_properties = true })
         map.max_crowd_density = 0
         map.music = "elona.last_boss"
         map.level = floor

         util.connect_existing_stairs(map, area, floor)
      else
         local gen, params = DungeonTemplate.ancient_castle(floor, { level = 17 })
         params.map_archetype_id = "elona.ancient_castle"
         map = DungeonMap.generate(area, floor, gen, params)
      end

      return map
   end

   data:add(area_ancient_castle)
end


do
   local dragons_nest = {
      _id = "dragons_nest",
      _type = "base.map_archetype",
      elona_id = 19,

      starting_pos = MapEntrance.stairs_up,

      properties = {
         types = { "dungeon" },
         is_indoor = true,
         has_anchored_npcs = true,
         default_ai_calm = "base.calm_null",
         material_spot_type = "elona.dungeon"
      }
   }

   function dragons_nest.chara_filter(map)
      local level = Calc.calc_object_level(map.level, map)
      local quality = Calc.calc_object_level(Enum.Quality.Normal)
      return {
         level = level,
         quality = quality
      }
   end

   data:add(dragons_nest)

   local area_dragons_nest = {
      _type = "base.area_archetype",
      _id = "dragons_nest",

      types = { "dungeon" },
      image = "elona.feat_area_dungeon",

      deepest_floor = 4,

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 13,
         y = 32,
         starting_floor = 1
      }
   }

   function area_dragons_nest.on_generate_floor(area, floor)
      local gen, params = DungeonTemplate.nefia_dungeon(floor, { level = 30 })
      params.map_archetype = "elona.dragons_nest"
      local map = DungeonMap.generate(area, floor, gen, params)
      return map
   end

   data:add(area_dragons_nest)
end


do
   local mountain_pass = {
      _id = "mountain_pass",
      _type = "base.map_archetype",
      elona_id = 26,

      starting_pos = MapEntrance.stairs_down,

      chara_filter = Dungeon.default_chara_filter,

      properties = {
         types = { "dungeon" },
         is_indoor = true,
         has_anchored_npcs = true,
         default_ai_calm = "base.calm_null",
         material_spot_type = "elona.dungeon"
      }
   }
   data:add(mountain_pass)

   local area_mountain_pass = {
      _type = "base.area_archetype",
      _id = "mountain_pass",

      types = { "dungeon" },
      image = "elona.feat_area_dungeon",

      deepest_floor = 5,

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 64,
         y = 43,
         starting_floor = 1
      }
   }

   function area_mountain_pass.on_generate_floor(area, floor)
      local gen, params = DungeonTemplate.type_long(floor, { level = 25 })
      params.map_archetype_id = "elona.mountain_pass"
      local map = DungeonMap.generate(area, floor, gen, params)

      if floor == area:archetype().deepest_floor then
         -- create up stairs, set to area of Larna
         error("TODO")
      end

      return map
   end

   data:add(area_mountain_pass)
end

do
   local puppy_cave = {
      _id = "puppy_cave",
      _type = "base.map_archetype",
      elona_id = 27,

      image = "elona.feat_area_dungeon",
      starting_pos = MapEntrance.stairs_up,

      chara_filter = Dungeon.default_chara_filter,

      properties = {
         types = { "dungeon" },
         is_indoor = true,
         default_ai_calm = "base.calm_null",
         is_generated_every_time = true,
         material_spot_type = "elona.dungeon"
      },
   }

   data:add(puppy_cave)

   local area_puppy_cave = {
      _type = "base.area_archetype",
      _id = "puppy_cave",

      types = { "dungeon" },
      image = "elona.feat_area_dungeon",

      deepest_floor = 4,

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 29,
         y = 24,
         starting_floor = 1
      }
   }

   function area_puppy_cave.on_generate_floor(area, floor)
      local gen, params = DungeonTemplate.type_puppy_cave(floor, { level = 2 })
      params.map_archetype_id = "elona.puppy_cave"
      local map = DungeonMap.generate(area, floor, gen, params)

      if floor == area:archetype().deepest_floor
         and Sidequest.progress("elona.puppys_cave") < 2
         and not Chara.find("elona.poppy", "allies")
      then
         local poppy = Chara.create("elona.poppy", nil, nil, {}, map)
         poppy.is_not_targeted_by_ai = true
      end

      return map
   end

   data:add(area_puppy_cave)
end

do
   local minotaurs_nest = {
      _id = "minotaurs_nest",
      _type = "base.map_archetype",
      elona_id = 38,

      starting_pos = MapEntrance.stairs_up,

      properties = {
         types = { "dungeon" },
         is_indoor = true,
         has_anchored_npcs = true,
         default_ai_calm = "base.calm_null",
         material_spot_type = "elona.dungeon"
      }
   }

   function minotaurs_nest.chara_filter(map)
      local level = Calc.calc_object_level(map.level, map)
      local quality = Calc.calc_object_quality(Enum.Quality.Normal)
      local tag_filters = nil

      if Rand.one_in(2) then
         tag_filters = {"mino"}
      end

      return {
         level = level,
         quality = quality,
         tag_filters = tag_filters
      }
   end

   data:add(minotaurs_nest)

   local area_minotaurs_nest = {
      _type = "base.area_archetype",
      _id = "minotaurs_nest",

      types = { "dungeon" },
      image = "elona.feat_area_dungeon",

      deepest_floor = 5,

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 43,
         y = 39,
         starting_floor = 1
      }
   }

   function area_minotaurs_nest.on_generate_floor(area, floor)
      local gen, params = DungeonTemplate.type_maze(floor, { level = 23 })
      params.map_archetype_id = "elona.minotaurs_nest"
      local map =  DungeonMap.generate(area, floor, gen, params)

      -- >>>>>>>> shade2/map.hsp:1747 	if gArea=areaMinotaur{ ...
      if area and floor == area:archetype().deepest_floor then
         if Sidequest.progress("elona.minotaur_king") < 2 then
            Chara.create("elona.ungaga", nil, nil, {}, map)
         end
      end
      -- <<<<<<<< shade2/map.hsp:1752 		} ..

      return map
   end

   data:add(area_minotaurs_nest)
end


do
   local yeeks_nest = {
      _id = "yeeks_nest",
      _type = "base.map_archetype",
      elona_id = 28,

      starting_pos = MapEntrance.stairs_up,

      properties = {
         types = { "dungeon" },
         is_indoor = true,
         has_anchored_npcs = true,
         default_ai_calm = "base.calm_null",
         material_spot_type = "elona.dungeon"
      }
   }

   function yeeks_nest.chara_filter(map)
      local level = Calc.calc_object_level(map.level, map)
      local quality = Calc.calc_object_quality(Enum.Quality.Normal)
      local tag_filters = nil

      if Rand.one_in(2) then
         tag_filters = {"yeek"}
      end

      return {
         level = level,
         quality = quality,
         tag_filters = tag_filters
      }
   end

   data:add(yeeks_nest)

   local area_yeeks_nest = {
      _type = "base.area_archetype",
      _id = "yeeks_nest",

      types = { "dungeon" },
      image = "elona.feat_area_dungeon",

      deepest_floor = 1,

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 38,
         y = 31,
         starting_floor = 1
      }
   }

   function area_yeeks_nest.on_generate_floor(area, floor)
      local gen, params = DungeonTemplate.nefia_dungeon(floor, { level = 5 })
      local map = DungeonMap.generate(area, floor, gen, params)
      map:set_archetype("elona.yeeks_nest", { set_properties = true })

      -- >>>>>>>> shade2/map.hsp:1754 	if gArea=areaYeekDungeon{ ...
      if area and floor == area:archetype().deepest_floor then
         if Sidequest.progress("elona.novice_knight") < 2 then
            local rodlob = Chara.create("elona.rodlob", nil, nil, {}, map)
            if Chara.is_alive(rodlob) then
               local x = rodlob.x
               local y = rodlob.y

               for _ = 1, 5 do
                  Chara.create("elona.master_yeek", x, y, {}, map)
               end
               for _ = 1, 10 do
                  Chara.create("elona.yeek_warrior", x, y, {}, map)
                  Chara.create("elona.kamikaze_yeek", x, y, {}, map)
               end
            end
         end
      end
      -- <<<<<<<< shade2/map.hsp:1769 		} ..

      return map
   end

   data:add(area_yeeks_nest)
end
