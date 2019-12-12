local Chara = require("api.Chara")
local Calc = require("mod.elona.api.Calc")
local Item = require("api.Item")
local Map = require("api.Map")
local Feat = require("api.Feat")
local I18N = require("api.I18N")
local Rand = require("api.Rand")
local IChara = require("api.chara.IChara")
local MapEntrance = require("mod.elona_sys.api.MapEntrance")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local Gui = require("api.Gui")
local World = require("api.World")
local Text = require("mod.elona.api.Text")

local function reload_122_map_geometry(current, elona122_map_id)
   local _, temp = assert(Map.generate("elona_sys.elona122", { name = elona122_map_id }))
   assert(current:width() == temp:width())
   assert(current:height() == temp:height())

   for _, x, y, tile in temp:iter_tiles() do
      current:set_tile(x, y, tile)
   end
end

local north_tyris = {
   _type = "elona_sys.map_template",
   _id = "north_tyris",

   map = "ntyris",

   elona_id = 4,

   copy = {
      appearance = 0,
      types = { "world_map" },
      player_start_pos = MapEntrance.world_map,
      tile_type = 1,
      turn_cost = 50000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 0,
   },

   areas = {
      { map = "elona.vernis", x = 26, y = 23 },
      { map = "elona.yowyn", x = 43, y = 32 },
      { map = "elona.palmia", x = 53, y = 24 },
      { map = "elona.derphy", x = 14, y = 35 },
      { map = "elona.port_kapul", x = 3, y = 15 },
      { map = "elona.noyel", x = 89, y = 14 },
      { map = "elona.lumiest", x = 61, y = 32 },
      { map = "elona.your_home", x = 22, y = 21 },
      { map = "elona.show_house", x = 35, y = 27 },
      { map = "elona.lesimas", x = 23, y = 29 },
      { map = "elona.the_void", x = 81, y = 51 },
      { map = "elona.tower_of_fire", x = 43, y = 4 },
      { map = "elona.crypt_of_the_damned", x = 38, y = 20 },
      { map = "elona.ancient_castle", x = 26, y = 44 },
      { map = "elona.dragons_nest", x = 13, y = 32 },
      { map = "elona.mountain_pass", x = 64, y = 43 },
      { map = "elona.puppy_cave", x = 29, y = 24 },
      { map = "elona.minotaurs_nest", x = 43, y = 39 },
      { map = "elona.yeeks_nest", x = 38, y = 31 },
      { map = "elona.pyramid", x = 4, y = 11 },
      { map = "elona.lumiest_graveyard", x = 74, y = 31 },
      { map = "elona.truce_ground", x = 51, y = 9 },
      { map = "elona.jail", x = 28, y = 37 },
      { map = "elona.cyber_dome", x = 21, y = 27 },
      { map = "elona.larna", x = 64, y = 47 },
      { map = "elona.miral_and_garoks_workshop", x = 88, y = 25 },
      { map = "elona.mansion_of_younger_sister", x = 18, y = 2 },
      { map = "elona.embassy", x = 53, y = 21 },
      { map = "elona.north_tyris_south_border", x = 27, y = 52 },
      { map = "elona.fort_of_chaos_beast", x = 13, y = 43 },
      { map = "elona.fort_of_chaos_machine", x = 51, y = 32 },
      { map = "elona.fort_of_chaos_collapsed", x = 35, y = 10 },
      { map = "elona.test_site", x = 20, y = 20 },
   }
}
data:add(north_tyris)

local function chara_filter_town(callbacks)
   return function(self)
      local opts = Calc.filter(10, "bad", {fltselect = 5}, self)

      if callbacks == nil then
         return opts
      end

      local result = {}
      local level = 1 -- map.dungeon_level
      local callback = callbacks[level]

      if callback then
         local result_ = callback(self)
         if result_ ~= nil and type(result_) == "table" then
            result = result_
         end
      end

      return table.merge(opts, result)
   end
end

local function create_charas(map, charas)
   for _, data in ipairs(charas) do
      local x, y, id, opts = table.unpack(data)

      local count = (opts and opts["_count"]) or 1

      for i=1,count do
         local chara = Chara.create(id, x, y, {}, map)
         assert(chara, ("%s:%s:%s"):format(x, y, id))

         if opts then
            for k, v in pairs(opts) do
               if k == "_name" then
                  chara.name = I18N.get(v, chara.name)
               elseif k == "_role" then
                  if type(v) == "table" then
                     chara.roles = { [v[1]] = v[2] }
                  elseif type(v) == "string" then
                     chara.roles = { [v] = {} }
                  else
                     error()
                  end
               elseif k ~= "_count" then
                  chara[k] = v
               end
            end
         end
      end
   end
end

local function update_quests_in_map(map)
end

local function generate_chara(map)
   local params
   if map.chara_filter then
      params = map:chara_filter()
      assert(type(params) == "table")
   else
      local player = Chara.player()
      local level = (player and player.level) or 1
      params = { level = level, quality = 1 }
   end
   -- TODO
   local Charagen = require("mod.tools.api.Charagen")
   return Charagen.create(nil, nil, params, map)
end

local function set_quest_targets(map)
   for _, c in Chara.iter_others(map) do
      if Chara.is_alive(c) then
         c.is_quest_target = true
         c.faction = "base.enemy"
      end
   end
end

local test_world = {
   _id = "test_world",
   _type = "elona_sys.map_template",
   elona_id = 47,
   map = "test",
   copy = {
      types = { "world_map" },
      player_start_pos = MapEntrance.world_map,
      tile_type = 1,
      turn_cost = 50000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 0
   },
   areas = {
      { map = "elona.test_world_north_border", x = 28, y = 1 },
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
      player_start_pos = MapEntrance.south,
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
      player_start_pos = MapEntrance.world_map,
      tile_type = 1,
      turn_cost = 50000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 0
   },
   areas = {
      { map = "elona.south_tyris_north_border", x = 42, y = 1 },
      { map = "elona.the_smoke_and_pipe", x = 39, y = 13 },
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
      player_start_pos = MapEntrance.south,
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
      player_start_pos = MapEntrance.south,
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

local vernis = {
   _type = "elona_sys.map_template",
   _id = "vernis",

   elona_id = 5,
   map = "vernis",
   image = "elona.feat_area_city",

   copy = {
      types = { "town" },
      player_start_pos = MapEntrance.directional,
      tile_type = 2,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 999,
      is_outdoor = true,
      is_temporary = false,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      max_crowd_density = 40,

      chara_filter = chara_filter_town {
         [1] = function()
            if Rand.one_in(2) then
               return { id = "elona.miner" }
            end

            return nil
         end
      }
   },

   on_generate = function(map)
      local charas = {
         { 39, 3, "elona.whom_dwell_in_the_vanity" },
         { 42, 23, "elona.loyter", { role = 3 } },
         { 24, 5, "elona.miches", { role = 3 } },
         { 40, 24, "elona.shena", { role = 3 } },
         { 40, 25, "elona.dungeon_cleaner", { role = 3 } },
         { 30, 5, "elona.rilian", { role = 3 } },
         { 42, 24, "elona.bard", { role = 3 } },
         { 47, 9, "elona.shopkeeper", { _role = { "elona.shopkeeper", { inventory_id = "elona.fisher" } }, shop_rank = 5, _name = "chara.job.fisher" } },
         { 14, 12, "elona.shopkeeper", { _role = { "elona.shopkeeper", { inventory_id = "elona.blacksmith" } }, shop_rank = 12, _name = "chara.job.blacksmith" } },
         { 39, 27, "elona.shopkeeper", { _role = { "elona.shopkeeper", { inventory_id = "elona.trader" } }, shop_rank = 12, _name = "chara.job.trader" } },
         { 10, 15, "elona.shopkeeper", { _role = { "elona.shopkeeper", { inventory_id = "elona.general_vendor" } }, shop_rank = 10, _name = "chara.job.general_vendor" } },
         { 7, 26, "elona.wizard", { _role = { "elona.shopkeeper", { inventory_id = "elona.magic_vendor" } }, shop_rank = 11, _name = "chara.job.magic_vendor" } },
         { 14, 25, "elona.shopkeeper", { _role = { "elona.shopkeeper", { inventory_id = "elona.innkeeper" } }, shop_rank = 8, _name = "chara.job.innkeeper" } },
         { 22, 26, "elona.shopkeeper", { _role = { "elona.shopkeeper", { inventory_id = "elona.bakery" } }, shop_rank = 9, _name = "chara.job.baker", image = "elona.chara__138" } },
         { 28, 16, "elona.wizard", { role = 5 } },
         { 38, 27, "elona.bartender", { role = 9 } },
         { 6, 25, "elona.healer", { role = 12 } },
         { 10, 7, "elona.elder", { role = 6, _name = "chara.job.of_vernis" } },
         { 27, 16, "elona.trainer", { role = 7, _name = "chara.job.trainer" } },
         { 25, 16, "elona.informer", { role = 8 } },
         { nil, nil, "elona.citizen", { _count = 4, _role = "elona.non_quest_target" } },
         { nil, nil, "elona.citizen2", { _count = 4, _role = "elona.non_quest_target" } },
         { nil, nil, "elona.guard", { _count = 4, role = 14 } },
      }

      create_charas(map, charas)

      update_quests_in_map(map)

      for i=0,25 do
         generate_chara(map)
      end

      local stair = Feat.at(28, 9, map):nth(1)
      assert(stair)
      stair.generator_params = { generator = "elona_sys.map_template", params = { id = "elona.the_mine" }}
      stair.area_params = { outer_map_id = map._id }
   end
}
data:add(vernis)

local the_mine = {
   _type = "elona_sys.map_template",
   _id = "the_mine",

   map = "puti",

   copy = {
      bgm = 61,
      types = { "dungeon" },
      player_start_pos = nil,
      tile_set = 0,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 999,
      is_outdoor = false,
      is_regenerated = false,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      max_crowd_density = 0,
   },

   on_generate = function(map)
      set_quest_targets(map)
   end,

   events = {
      {
         id = "elona_sys.on_quest_check",
         name = "Sidequest: putit_attacks",

         callback = function(map)
            if Sidequest.progress("elona.putit_attacks") < 2 then
               if Sidequest.no_targets_remaining(map) then
                  Sidequest.set_progress("elona.putit_attacks", 2)
                  Gui.play_sound("base.write1");
                  Gui.mes_c("quest.journal_updated", "Green");
               end
            end
         end
      },
      {
         id = "base.on_map_generated",
         name = "Sidequest: putit_attacks",

         callback = function(map)
            Sidequest.set_quest_targets(map)
         end
      }
   }
}
data:add(the_mine)

local yowyn = {
   _id = "yowyn",
   _type = "elona_sys.map_template",
   elona_id = 12,
   map = "yowyn",
   image = "elona.feat_area_village",
   copy = {
      types = { "town" },
      player_start_pos = MapEntrance.directional,
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
      player_start_pos = function(chara, map)
         local x, y = MapEntrance.directional(chara, map)
         if save.base.player_pos_on_map_leave then
            return x, y
         end
         local last_dir = Chara.player().last_move_direction
         if last_dir == "East" then
            y = 22
         elseif last_dir == "North" then
            x = 30
         end
         return x, y
      end,
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
      player_start_pos = MapEntrance.directional,
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
      player_start_pos = MapEntrance.directional,
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
      player_start_pos = function(chara, map)
         local x, y = MapEntrance.directional(chara, map)
         if save.base.player_pos_on_map_leave then
            return x, y
         end
         local last_dir = Chara.player().last_move_direction
         if last_dir == "East" then
            y = 3
         elseif last_dir == "North" then
            x = 28
         elseif last_dir == "South" then
            x = 5
         end
         return x, y
      end,
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
   },

   on_regenerate = function(map)
      local function reload_noyel(map)
         for _, item in Item.iter_ground() do
            if item.id ~= "elona.shelter" and item.id ~= "elona.giants_shackle" then
               item:remove()
            end
         end

         if map.is_noyel_christmas_festival then
            local item = Item.create("elona.pedestal", 29, 16)
            item.own_state = "not_owned"

            item = Item.create("elona.statue_of_jure", 29, 16)
            item.own_state = "not_owned"

            item = Item.create("elona.altar", 29, 17)
            item.own_state = "not_owned"
            item.params = { god_id = "elona.jure" }

            item = Item.create("elona.mochi", 29, 17)
            item.own_state = "unobtainable"

            local chara = Chara.create("elona.kaneda_bike", 48, 19)
            if chara then
               chara.roles = {["elona.unique_chara"] = {}}
               chara.is_only_in_christmas = true
            end

            chara = Chara.create("elona.part_time_worker", 30, 17)
            if chara then
               chara.roles = {["elona.unique_chara"] = {}}
               chara.is_only_in_christmas = true
            end

            chara = Chara.create("elona.punk", 38, 19)
            if chara then
               chara.is_only_in_christmas = true
               chara.is_hung_on_sand_bag = true
               chara.name = I18N.get("chara.job.fanatic")
            end

            chara = Chara.create("elona.fanatic", 35, 19)
            if chara then
               chara.is_only_in_christmas = true
            end

            chara = Chara.create("elona.fanatic", 37, 18)
            if chara then
               chara.is_only_in_christmas = true
            end

            chara = Chara.create("elona.fanatic", 37, 21)
            if chara then
               chara.is_only_in_christmas = true
            end

            chara = Chara.create("elona.fanatic", 39, 20)
            if chara then
               chara.is_only_in_christmas = true
            end

            chara = Chara.create("elona.fanatic", 38, 21)
            if chara then
               chara.is_only_in_christmas = true
            end

            chara = Chara.create("elona.bartender", 17, 8)
            if chara then
               chara.ai_calm = 3
               chara.is_only_in_christmas = true
               chara.roles = {["elona.shopkeeper"] = {inventory_id="elona.food_vendor", rank=10}}
               chara.name = I18N.get("chara.job.food_vendor", chara.name)
            end

            chara = Chara.create("elona.hot_spring_maniac", 25, 8)
            if chara then
               chara.ai_calm = 3
               chara.faction = "elona.citizen"
               chara.is_only_in_christmas = true
               chara.roles = {["elona.shopkeeper"] = {inventory_id="elona.souvenir_vendor", rank=30}}
               chara.name = I18N.get("chara.job.souvenir_vendor", Text.random_name())
            end

            chara = Chara.create("elona.rogue", 24, 22)
            if chara then
               chara.ai_calm = 3
               chara.faction = "elona.citizen"
               chara.is_only_in_christmas = true
               chara.roles = {["elona.shopkeeper"] = {inventory_id="elona.souvenir_vendor", rank=30}}
               chara.name = I18N.get("chara.job.souvenir_vendor", Text.random_name())
            end

            chara = Chara.create("elona.shopkeeper", 38, 12)
            if chara then
               chara.ai_calm = 3
               chara.roles = {["elona.shopkeeper"] = {inventory_id="elona.blackmarket", rank=10}}
               chara.name = I18N.get("chara.job.blackmarket", Text.random_name())
               chara.is_only_in_christmas = true
            end

            chara = Chara.create("elona.rogue", 28, 9)
            if chara then
               chara.ai_calm = 3
               chara.faction = "elona.citizen"
               chara.is_only_in_christmas = true
               chara.roles = {["elona.shopkeeper"] = {inventory_id="elona.street_vendor", rank=30}}
               chara.name = I18N.get("chara.job.street_vendor", Text.random_name())
            end

            chara = Chara.create("elona.rogue", 29, 24)
            if chara then
               chara.ai_calm = 3
               chara.faction = "elona.citizen"
               chara.is_only_in_christmas = true
               chara.roles = {["elona.shopkeeper"] = {inventory_id="elona.street_vendor", rank=30}}
               chara.name = I18N.get("chara.job.street_vendor2", Text.random_name())
            end

            for _ = 1, 20 do
               chara = Chara.create("elona.holy_beast")
               if chara then
                  chara.is_only_in_christmas = true
               end

               chara = Chara.create("elona.festival_tourist")
               if chara then
                  chara.is_only_in_christmas = true
               end
            end

            for _ = 1, 15 do
               chara = Chara.create("elona.bard")
               if chara then
                  chara.is_only_in_christmas = true
               end
            end

            for _ = 1, 7 do
               chara = Chara.create("elona.prostitute")
               if chara then
                  chara.is_only_in_christmas = true
               end

               chara = Chara.create("elona.tourist")
               if chara then
                  chara.is_only_in_christmas = true
               end

               chara = Chara.create("elona.noble")
               if chara then
                  chara.is_only_in_christmas = true
               end

               chara = Chara.create("elona.punk")
               if chara then
                  chara.is_only_in_christmas = true
               end
            end

            for _ = 1, 3 do
               chara = Chara.create("elona.stray_cat")
               if chara then
                  chara.is_only_in_christmas = true
               end

               chara = Chara.create("elona.tourist")
               if chara then
                  chara.is_only_in_christmas = true
               end
            end
         else
            Chara.iter_others()
               :filter(function(c) return c.is_only_in_christmas end)
               :each(IChara.vanquish)
         end
      end

      if World.date().month == 12 then
         if not map.is_noyel_christmas_festival then
            map.is_noyel_christmas_festival = true
            reload_noyel(map)
         end
         reload_122_map_geometry(map, "noyel_fest")
      else
         if map.is_noyel_christmas_festival then
            map.is_noyel_christmas_festival = false
            reload_noyel(map)
         end
         reload_122_map_geometry(map, "noyel")
      end
   end
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
      player_start_pos = function(chara, map)
         local x, y = MapEntrance.directional(chara, map)
         if save.base.player_pos_on_map_leave then
            return x, y
         end
         local last_dir = Chara.player().last_move_direction
         if last_dir == "West" then
            x = 58
            y = 21
         elseif last_dir == "East" then
            x = 25
            y = 1
         elseif last_dir == "North" then
            x = 58
            y = 21
         elseif last_dir == "South" then
            x = 25
            y = 1
         end
         return x, y
      end,
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
   map = {
      generator = "elona.home",
      params = {
         id = "elona.cave",
      }
   },
   image = "elona.feat_area_your_dungeon",

   copy = {
      types = { "player_owned" },
      player_start_pos = MapEntrance.south,
      turn_cost = 10000,
      dungeon_level = 1,
      deepest_dungeon_level = 10,
      is_outdoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      tile_type = 3,
      is_fixed = true
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
      player_start_pos = MapEntrance.south,
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
   map = {
      generator = "elona.dungeon_template",
      params = {
         id = "elona.lesimas",
         dungeon_level = 1,
         deepest_dungeon_level = 45
      }
   },
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
      chara_filter = function(map)
         local opts = Calc.filter(map.dungeon_level, "bad")

         if map.dungeon_level < 4 and opts.level > 5 then
            opts.level = 5
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
      chara_filter = function(map)
         return Calc.filter((map.dungeon_level % 50) + 5, "bad")
      end
   }
}
data:add(the_void)

local tower_of_fire = {
   _id = "tower_of_fire",
   _type = "elona_sys.map_template",
   elona_id = 16,
   map = {
      generator = "elona.dungeon_template",
      params = {
         id = "elona.tower_of_fire",
         dungeon_level = 15,
         deepest_dungeon_level = 18
      }
   },
   image = "elona.feat_area_tower_of_fire",
   copy = {
      types = { "dungeon_tower" },
      entrance_type = "StairUp",
      tile_type = 0,
      turn_cost = 10000,
      is_outdoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 0,
      chara_filter = function(map)
         return Calc.filter(map.dungeon_level, "bad", { tag_filters = {"fire"}})
      end
   }
}
data:add(tower_of_fire)

local crypt_of_the_damned = {
   _id = "crypt_of_the_damned",
   _type = "elona_sys.map_template",
   elona_id = 17,
   map = {
      generator = "elona.dungeon_template",
      params = {
         id = "elona.crypt_of_the_damned",
         dungeon_level = 25,
         deepest_dungeon_level = 30
      }
   },
   image = "elona.feat_area_crypt",
   copy = {
      types = { "dungeon" },
      entrance_type = "StairUp",
      tile_type = 0,
      turn_cost = 10000,
      is_outdoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 0,
      chara_filter = function(map)
         return Calc.filter(map.dungeon_level, "bad", { tag_filters = {"undead"} })
      end
   }
}
data:add(crypt_of_the_damned)

local ancient_castle = {
   _id = "ancient_castle",
   _type = "elona_sys.map_template",
   elona_id = 18,
   map = {
      generator = "elona.dungeon_template",
      params = {
         id = "elona.ancient_castle",
         dungeon_level = 17,
         deepest_dungeon_level = 22
      }
   },
   image = "elona.feat_area_castle",
   copy = {
      types = { "dungeon_castle" },
      entrance_type = "StairUp",
      tile_type = 0,
      turn_cost = 10000,
      is_outdoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 0,
      chara_filter = function(map)
         local opts = Calc.filter(map.dungeon_level, "bad")

         if Rand.one_in(2) then
            opts.tag_filters = {"man"}
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
      chara_filter = function(map)
         return Calc.filter(map.dungeon_level, "bad")
      end
   }
}
data:add(dragons_nest)

local mountain_pass = {
   _id = "mountain_pass",
   _type = "elona_sys.map_template",
   elona_id = 26,
   map = {
      generator = "elona.dungeon_template",
      params = {
         id = "elona.type_8",
         dungeon_level = 25,
         deepest_dungeon_level = 29
      }
   },
   image = "elona.feat_area_dungeon",
   copy = {
      types = { "dungeon" },
      entrance_type = "StairDown",
      tile_type = 0,
      turn_cost = 10000,
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
   map = {
      generator = "elona.dungeon_template",
      params = {
         id = "elona.type_10",
         dungeon_level = 2,
         deepest_dungeon_level = 5
      }
   },
   image = "elona.feat_area_dungeon",
   copy = {
      types = { "dungeon" },
      entrance_type = "StairUp",
      tile_type = 0,
      turn_cost = 10000,
      is_outdoor = false,
      has_anchored_npcs = false,
      default_ai_calm = 0,
      is_generated_every_time = true
   },

   on_generate = function(map)
      if map.dungeon_level == map.deepest_dungeon_level
         and Sidequest.progress("elona.puppys_cave") < 2
         and not Chara.find("elona.poppy", "ally")
      then
         local poppy = Chara.create("elona.poppy", nil, nil, {}, map)
         poppy.is_not_targeted_by_ai = true
      end
   end,
}
data:add(puppy_cave)

local minotaurs_nest = {
   _id = "minotaurs_nest",
   _type = "elona_sys.map_template",
   elona_id = 38,
   map = {
      generator = "elona.dungeon_template",
      params = {
         id = "elona.type_9",
         dungeon_level = 23,
         deepest_dungeon_level = 27
      }
   },
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
         local opts = Calc.filter(map.dungeon_level, "bad")

         if Rand.one_in(2) then
            opts.tag_filters = {"mino"}
         end

         return opts
      end
   }
}
data:add(minotaurs_nest)

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
      chara_filter = function(map)
         local opts = Calc.filter(map.dungeon_level, "bad")

         if Rand.one_in(2) then
            opts.tag_filters = {"yeek"}
         end

         return opts
      end
   }
}
data:add(yeeks_nest)

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
      chara_filter = function(map)
         return Calc.filter(map.dungeon_level, "bad", {category = 13})
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
      player_start_pos = MapEntrance.directional,
      tile_type = 4,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      chara_filter = function()
         return Calc.filter(20, "bad", {fltselect = 4})
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
      player_start_pos = MapEntrance.directional,
      tile_type = 4,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      chara_filter = function()
         return Calc.filter(20, "bad", {fltselect = 4})
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
      player_start_pos = MapEntrance.south,
      tile_type = 8,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 1,
      is_outdoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      chara_filter = function()
         return Calc.filter(10, "bad", {tag_filters = {"sf"}})
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
      player_start_pos = { x = 1, y = 14 },
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
      player_start_pos = MapEntrance.south,
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
      player_start_pos = MapEntrance.south,
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
      player_start_pos = MapEntrance.south,
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
      player_start_pos = MapEntrance.south,
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
      player_start_pos = MapEntrance.south,
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
      player_start_pos = MapEntrance.south,
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
      player_start_pos = MapEntrance.south,
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
