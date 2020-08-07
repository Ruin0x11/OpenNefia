local Chara = require("api.Chara")
local Calc = require("mod.elona.api.Calc")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local Gui = require("api.Gui")
local Item = require("api.Item")
local I18N = require("api.I18N")
local Rand = require("api.Rand")
local IChara = require("api.chara.IChara")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local World = require("api.World")
local Text = require("mod.elona.api.Text")
local Elona122Map = require("mod.elona_sys.map_loader.Elona122Map")
local HomeMap = require("mod.elona.api.HomeMap")

local function entrance_edge(chara, map)
   -- TODO map archetype
   error("TODO")
   return data["base.map_entrance"]["base.edge"].pos(chara, map)
end

local function generate_122(elona122_map_id)
   return function()
      return Elona122Map.generate(elona122_map_id)
   end
end

local function reload_122_map_geometry(current, elona122_map_id)
   local temp = Elona122Map.generate(elona122_map_id)
   assert(current:width() == temp:width())
   assert(current:height() == temp:height())

   for _, x, y, tile in temp:iter_tiles() do
      current:set_tile(x, y, tile)
   end
end

local north_tyris = {
   _type = "base.map_template",
   _id = "north_tyris",

   elona_id = 4,
   map = generate_122("ntyris"),
   unique = true,

   properties = {
      appearance = 0,
      types = { "world_map" },
      player_start_pos = "base.world",
      tileset = "elona.world_map",
      turn_cost = 50000,
      is_indoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 0,
   },

   --[[
   areas = {
      { map = generate_122("elona.vernis"), x = 26, y = 23 },
      { map = generate_122("elona.yowyn"), x = 43, y = 32 },
      { map = generate_122("elona.palmia"), x = 53, y = 24 },
      { map = generate_122("elona.derphy"), x = 14, y = 35 },
      { map = generate_122("elona.port_kapul"), x = 3, y = 15 },
      { map = generate_122("elona.noyel"), x = 89, y = 14 },
      { map = generate_122("elona.lumiest"), x = 61, y = 32 },
      { map = generate_122("elona.your_home"), x = 22, y = 21 },
      { map = generate_122("elona.show_house"), x = 35, y = 27 },
      { map = generate_122("elona.lesimas"), x = 23, y = 29 },
      { map = generate_122("elona.the_void"), x = 81, y = 51 },
      { map = generate_122("elona.tower_of_fire"), x = 43, y = 4 },
      { map = generate_122("elona.crypt_of_the_damned"), x = 38, y = 20 },
      { map = generate_122("elona.ancient_castle"), x = 26, y = 44 },
      { map = generate_122("elona.dragons_nest"), x = 13, y = 32 },
      { map = generate_122("elona.mountain_pass"), x = 64, y = 43 },
      { map = generate_122("elona.puppy_cave"), x = 29, y = 24 },
      { map = generate_122("elona.minotaurs_nest"), x = 43, y = 39 },
      { map = generate_122("elona.yeeks_nest"), x = 38, y = 31 },
      { map = generate_122("elona.pyramid"), x = 4, y = 11 },
      { map = generate_122("elona.lumiest_graveyard"), x = 74, y = 31 },
      { map = generate_122("elona.truce_ground"), x = 51, y = 9 },
      { map = generate_122("elona.jail"), x = 28, y = 37 },
      { map = generate_122("elona.cyber_dome"), x = 21, y = 27 },
      { map = generate_122("elona.larna"), x = 64, y = 47 },
      { map = generate_122("elona.miral_and_garoks_workshop"), x = 88, y = 25 },
      { map = generate_122("elona.mansion_of_younger_sister"), x = 18, y = 2 },
      { map = generate_122("elona.embassy"), x = 53, y = 21 },
      { map = generate_122("elona.north_tyris_south_border"), x = 27, y = 52 },
      { map = generate_122("elona.fort_of_chaos_beast"), x = 13, y = 43 },
      { map = generate_122("elona.fort_of_chaos_machine"), x = 51, y = 32 },
      { map = generate_122("elona.fort_of_chaos_collapsed"), x = 35, y = 10 },
      { map = generate_122("elona.test_site"), x = 20, y = 20 },
   }
   --]]
}
data:add(north_tyris)

local function chara_filter_town(callback)
   return function(map)
      local opts = Calc.filter(10, "bad", {fltselect = 5}, map)
      if callback == nil then
         return opts
      end

      local result = callback(map)
      if result ~= nil and type(result) == "table" then
         return table.merge(opts, result)
      end

      return opts
   end
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

local vernis = {
   _type = "base.map_template",
   _id = "vernis",

   elona_id = 5,
   map = generate_122("vernis"),
   image = "elona.feat_area_city",
   unique = true,

   properties = {
      music = "elona.town1",
      types = { "town" },
      player_start_pos = "base.edge",
      tileset = "elona.town",
      turn_cost = 10000,
      level = 1,
      deepest_dungeon_level = 999,
      is_indoor = false,
      is_temporary = false,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      max_crowd_density = 40,

      chara_filter = chara_filter_town(
         function()
            if Rand.one_in(2) then
               return { id = "elona.miner" }
            end

            return nil
         end
      )
   },
}
function vernis.on_generate(map)
   local chara = Chara.create("elona.whom_dwell_in_the_vanity", 39, 3, nil, map)

   chara = Chara.create("elona.loyter", 42, 23, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.miches", 24, 5, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.shena", 40, 24, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.dungeon_cleaner", 40, 25, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.rilian", 30, 5, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.bard", 42, 24, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.shopkeeper", 47, 9, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.fisher" }
   chara.shop_rank = 5
   chara.name = I18N.get("chara.job.fisher", chara.name)

   chara = Chara.create("elona.shopkeeper", 14, 12, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.blacksmith" }
   chara.shop_rank = 12
   chara.name = I18N.get("chara.job.blacksmith", chara.name)

   chara = Chara.create("elona.shopkeeper", 39, 27, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.trader" }
   chara.shop_rank = 12
   chara.name = I18N.get("chara.job.trader", chara.name)

   chara = Chara.create("elona.shopkeeper", 10, 15, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.general_vendor" }
   chara.shop_rank = 10
   chara.name = I18N.get("chara.job.general_vendor", chara.name)

   chara = Chara.create("elona.wizard", 7, 26, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.magic_vendor" }
   chara.shop_rank = 11
   chara.name = I18N.get("chara.job.magic_vendor", chara.name)

   chara = Chara.create("elona.shopkeeper", 14, 25, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.innkeeper" }
   chara.roles["elona.innkeeper"] = true
   chara.shop_rank = 8
   chara.name = I18N.get("chara.job.innkeeper", chara.name)

   chara = Chara.create("elona.shopkeeper", 22, 26, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.bakery" }
   chara.shop_rank = 9
   chara.image = "elona.chara_baker"
   chara.name = I18N.get("chara.job.baker", chara.name)

   chara = Chara.create("elona.wizard", 28, 16, nil, map)
   chara.roles["elona.wizard"] = true

   chara = Chara.create("elona.bartender", 38, 27, nil, map)
   chara.roles["elona.bartender"] = true

   chara = Chara.create("elona.healer", 6, 25, nil, map)
   chara.roles["elona.healer"] = true

   chara = Chara.create("elona.elder", 10, 7, nil, map)
   chara.roles["elona.elder"] = true
   chara.name = I18N.get("chara.job.of_vernis", chara.name)

   chara = Chara.create("elona.trainer", 27, 16, nil, map)
   chara.roles["elona.trainer"] = true
   chara.name = I18N.get("chara.job.trainer", chara.name)

   chara = Chara.create("elona.informer", 25, 16, nil, map)
   chara.roles["elona.informer"] = true

   for _=1,4 do
      chara = Chara.create("elona.citizen", nil, nil, nil, map)
      chara.roles["elona.citizen"] = true

      chara = Chara.create("elona.citizen2", nil, nil, nil, map)
      chara.roles["elona.citizen"] = true
   end

   for _=1,4 do
      chara = Chara.create("elona.guard", nil, nil, nil, map)
      chara.roles["elona.guard"] = true
   end

   for _=1,25 do
      generate_chara(map)
   end

   -- TODO only if sidequest
   --local stair = Feat.at(28, 9, map):nth(1)
   --assert(stair)
   --stair.generator_params = { generator = "base.map_template", params = { id = "elona.the_mine" }}
   --stair.area_params = { outer_map_id = map._id }
end
data:add(vernis)

local the_mine = {
   _type = "base.map_template",
   _id = "the_mine",

   map = generate_122("puti"),
   unique = true,

   properties = {
      music = "elona.puti",
      types = { "dungeon" },
      player_start_pos = "elona.stair_up",
      level = 3,
      deepest_dungeon_level = 999,
      is_indoor = true,
      is_not_renewable = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      max_crowd_density = 0,
   },

   events = {
      {
         id = "elona_sys.on_quest_check",
         name = "Sidequest: putit_attacks",

         callback = function(map)
            if Sidequest.progress("elona.putit_attacks") < 2 then
               if Sidequest.no_targets_remaining(map) then
                  Sidequest.set_progress("elona.putit_attacks", 2)
                  Sidequest.update_journal()
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
   _type = "base.map_template",

   elona_id = 12,
   map = generate_122("yowyn"),
   image = "elona.feat_area_village",
   unique = true,

   properties = {
      music = "elona.village1",
      types = { "town" },
      player_start_pos = "base.edge",
      tileset = "elona.town",
      level = 1,
      deepest_dungeon_level = 999,
      is_indoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      quest_town_id = 2,
      quest_custom_map = generate_122("yowyn"),
      chara_filter = chara_filter_town(
         function()
            if Rand.one_in(2) then
               return { id = "elona.farmer" }
            end

            return nil
         end
      )
   }
}
function yowyn.on_generate(map)
   -- TODO only if sidequest
   --local stair = Feat.at(23, 22, map):nth(1)
   --stair.generator_params = { generator = "base.map_template", params = { id = "elona.cat_mansion" }}
   --stair.area_params = { outer_map_id = map._id }

   local chara = Chara.create("elona.ainc", 3, 17, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.tam", 26, 11, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.gilbert_the_colonel", 14, 20, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.shopkeeper", 11, 5, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id="elona.general_vendor"}
   chara.shop_rank = 10
   chara.name = I18N.get("chara.job.general_vendor", chara.name)

   chara = Chara.create("elona.shopkeeper", 25, 8, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.innkeeper" }
   chara.roles["elona.innkeeper"] = true
   chara.shop_rank = 8
   chara.name = I18N.get("chara.job.inkeeper", chara.name)

   chara = Chara.create("elona.shopkeeper", 7, 8, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id="elona.goods_vendor"}
   chara.shop_rank = 8
   chara.name = I18N.get("chara.job.goods_vendor", chara.name)

   chara = Chara.create("elona.shopkeeper", 14, 14, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.trader" }
   chara.shop_rank = 12
   chara.name = I18N.get("chara.job.trader", chara.name)

   chara = Chara.create("elona.shopkeeper", 35, 18, nil, map)
   chara.roles["elona.horse_master"] = true
   chara.shop_rank = 12
   chara.name = I18N.get("chara.job.horse_master", chara.name)

   chara = Chara.create("elona.lame_horse", 33, 16, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.lame_horse", 37, 19, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.yowyn_horse", 34, 19, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.yowyn_horse", 38, 16, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.elder", 3, 4, nil, map)
   chara.roles["elona.elder"] = true
   chara.name = I18N.get("chara.job.of_yowyn", chara.name)

   chara = Chara.create("elona.trainer", 20, 14, nil, map)
   chara.roles["elona.trainer"] = true
   chara.name = I18N.get("chara.job.trainer", chara.name)

   chara = Chara.create("elona.wizard", 24, 16, nil, map)
   chara.roles["elona.wizard"] = true

   chara = Chara.create("elona.informer", 26, 16, nil, map)
   chara.roles["elona.informer"] = true

   chara = Chara.create("elona.gwen", 14, 12, nil, map)
   chara.roles["elona.special"] = true


   for _=1,2 do
      chara = Chara.create("elona.citizen", nil, nil, nil, map)
      chara.roles["elona.citizen"] = true

      chara = Chara.create("elona.citizen2", nil, nil, nil, map)
      chara.roles["elona.citizen"] = true
   end

   for _=1,3 do
      chara = Chara.create("elona.guard", nil, nil, nil, map)
      chara.roles["elona.guard"] = true
   end

   for _=1,15 do
      generate_chara(map)
   end
end
data:add(yowyn)

local palmia = {
   _id = "palmia",
   _type = "base.map_template",

   elona_id = 15,
   map = generate_122("palmia"),
   image = "elona.feat_area_palace",
   unique = true,

   properties = {
      music = "elona.town4",
      types = { "town" },
      player_start_pos = function(chara, map)
         local x, y = entrance_edge(chara, map)
         if save.base.player_pos_on_map_leave then
            return x, y
         end
         local last_dir = Chara.player().direction
         if last_dir == "East" then
            y = 22
         elseif last_dir == "North" then
            x = 30
         end
         return x, y
      end,
      tileset = "elona.town",
      level = 1,
      deepest_dungeon_level = 1,
      is_indoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      max_crowd_density = 45,
      quest_town_id = 3,
      quest_custom_map = generate_122("palmia"),
      chara_filter = chara_filter_town(
         function()
            if Rand.one_in(3) then
               return { id = "elona.noble" }
            end

            return nil
         end
      ),
   },
}
function palmia.on_generate(map)
   local chara = Chara.create("elona.bartender", 42, 27, nil, map)
   chara.roles["elona.bartender"] = true

   chara = Chara.create("elona.healer", 34, 3, nil, map)
   chara.roles["elona.healer"] = true

   chara = Chara.create("elona.arena_master", 22, 31, nil, map)
   chara.roles["elona.arena_master"] = true

   chara = Chara.create("elona.erystia", 5, 15, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.mia", 41, 11, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.conery", 5, 6, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.cleaner", 24, 6, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.cleaner", 15, 22, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.bard", 15, 22, nil, map)
   chara.roles["elona.special"] = true

   if Sidequest.progress("elona.mias_dream") == 1000 then
      local silver_cat = Chara.create("elona.silver_cat", 42, 11, {}, map, nil, map)
      silver_cat.roles["elona.special"] = true
   end

   chara = Chara.create("elona.shopkeeper", 48, 18, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id="elona.general_vendor"}
   chara.shop_rank = 10
   chara.name = I18N.get("chara.job.general_vendor", chara.name)

   chara = Chara.create("elona.shopkeeper", 30, 17, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.innkeeper" }
   chara.roles["elona.innkeeper"] = true
   chara.shop_rank = 8
   chara.name = I18N.get("chara.job.inkeeper", chara.name)

   chara = Chara.create("elona.shopkeeper", 48, 3, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id="elona.goods_vendor"}
   chara.shop_rank = 8
   chara.name = I18N.get("chara.job.goods_vendor", chara.name)

   chara = Chara.create("elona.shopkeeper", 42, 17, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id = "elona.blacksmith"}
   chara.shop_rank = 12
   chara.name = I18N.get("chara.job.blacksmith", chara.name)

   chara = Chara.create("elona.shopkeeper", 11, 14, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.bakery" }
   chara.shop_rank = 9
   chara.image = "elona.chara_baker"
   chara.name = I18N.get("chara.job.baker", chara.name)

   chara = Chara.create("elona.wizard", 41, 3, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.magic_vendor" }
   chara.shop_rank = 11
   chara.name = I18N.get("chara.job.magic_vendor", chara.name)

   chara = Chara.create("elona.shopkeeper", 41, 28, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.trader" }
   chara.shop_rank = 12
   chara.name = I18N.get("chara.job.trader", chara.name)

   chara = Chara.create("elona.stersha", 7, 2, nil, map)
   chara.roles["elona.royal_family"] = true
   chara.ai_calm = 3

   chara = Chara.create("elona.xabi", 6, 2, nil, map)
   chara.roles["elona.royal_family"] = true
   chara.ai_calm = 3

   chara = Chara.create("elona.elder", 49, 11, nil, map)
   chara.roles["elona.elder"] = true
   chara.name = I18N.get("chara.job.of_palmia", chara.name)

   chara = Chara.create("elona.trainer", 30, 27, nil, map)
   chara.roles["elona.trainer"] = true
   chara.name = I18N.get("chara.job.trainer", chara.name)

   chara = Chara.create("elona.wizard", 32, 27, nil, map)
   chara.roles["elona.wizard"] = true

   chara = Chara.create("elona.informer", 29, 28, nil, map)
   chara.roles["elona.informer"] = true

   chara = Chara.create("elona.guard", 16, 5, nil, map)
   chara.roles["elona.guard"] = true
   chara.ai_calm = 3

   chara = Chara.create("elona.guard", 16, 9, nil, map)
   chara.roles["elona.guard"] = true
   chara.ai_calm = 3

   chara = Chara.create("elona.guard", 5, 3, nil, map)
   chara.roles["elona.guard"] = true
   chara.ai_calm = 3

   chara = Chara.create("elona.guard", 8, 3, nil, map)
   chara.roles["elona.guard"] = true
   chara.ai_calm = 3

   chara = Chara.create("elona.guard", 35, 14, nil, map)
   chara.roles["elona.guard"] = true
   chara.ai_calm = 3

   chara = Chara.create("elona.guard", 38, 14, nil, map)
   chara.roles["elona.guard"] = true
   chara.ai_calm = 3

   chara = Chara.create("elona.guard", 29, 2, nil, map)
   chara.roles["elona.guard"] = true
   chara.ai_calm = 3

   chara = Chara.create("elona.guard", 19, 18, nil, map)
   chara.roles["elona.guard"] = true
   chara.ai_calm = 3

   chara = Chara.create("elona.guard", 22, 18, nil, map)
   chara.roles["elona.guard"] = true
   chara.ai_calm = 3

   for _=1,5 do
      chara = Chara.create("elona.citizen", nil, nil, nil, map)
      chara.roles["elona.citizen"] = true

      chara = Chara.create("elona.citizen2", nil, nil, nil, map)
      chara.roles["elona.citizen"] = true
   end

   for _=1,4 do
    chara = Chara.create("elona.guard", nil, nil, nil, map)
    chara.roles["elona.guard"] = true
   end

   for _=1,25 do
      generate_chara(map)
   end
end
data:add(palmia)

local derphy = {
   _id = "derphy",
   _type = "base.map_template",

   elona_id = 14,
   map = generate_122("rogueden"),
   image = "elona.feat_area_village",
   unique = true,

   properties = {
      music = "elona.town3",
      types = { "town" },
      player_start_pos = "base.edge",
      tileset = "elona.town",
      level = 1,
      deepest_dungeon_level = 999,
      is_indoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      quest_town_id = 4,
      quest_custom_map = generate_122("rogueden"),
      chara_filter = chara_filter_town(
         function()
            if Rand.one_in(3) then
               return { id = "elona.rogue" }
            elseif Rand.one_in(2) then
               return { id = "elona.prostitute" }
            end
         end
      )
   }
}
function derphy.on_generate(map)
   local chara = Chara.create("elona.marks", 23, 14, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.noel", 13, 18, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.abyss", 16, 17, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.shopkeeper", 10, 17, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.trader" }
   chara.shop_rank = 12
   chara.name = I18N.get("chara.job.trader", chara.name)

   chara = Chara.create("elona.bartender", 15, 15, nil, map)
   chara.roles["elona.bartender"] = true

   chara = Chara.create("elona.shopkeeper", 13, 3, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id="elona.general_vendor"}
   chara.shop_rank = 10
   chara.name = I18N.get("chara.job.general_vendor", chara.name)

   chara = Chara.create("elona.shopkeeper", 29, 23, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.innkeeper" }
   chara.roles["elona.innkeeper"] = true
   chara.shop_rank = 8
   chara.name = I18N.get("chara.job.inkeeper", chara.name)

   chara = Chara.create("elona.shopkeeper", 26, 7, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id="elona.goods_vendor"}
   chara.shop_rank = 10
   chara.name = I18N.get("chara.job.goods_vendor", chara.name)

   chara = Chara.create("elona.shopkeeper", 30, 4, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id = "elona.blackmarket"}
   chara.shop_rank = 10
   chara.name = I18N.get("chara.job.blackmarket", chara.name)

   chara = Chara.create("elona.shopkeeper", 29, 4, nil, map)
   chara.roles["elona.slaver"] = true
   chara.name = I18N.get("chara.job.slave_master", chara.name)

   chara = Chara.create("elona.shopkeeper", 10, 6, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id = "elona.blacksmith"}
   chara.shop_rank = 12
   chara.name = I18N.get("chara.job.blacksmith", chara.name)

   chara = Chara.create("elona.arena_master", 7, 15, nil, map)
   chara.roles["elona.arena_master"] = true

   chara = Chara.create("elona.elder", 9, 18, nil, map)
   chara.roles["elona.elder"] = true
   chara.name = I18N.get("chara.job.of_derphy", chara.name)

   chara = Chara.create("elona.trainer", 13, 18, nil, map)
   chara.roles["elona.trainer"] = true
   chara.name = I18N.get("chara.job.trainer", chara.name)

   chara = Chara.create("elona.wizard", 5, 26, nil, map)
   chara.roles["elona.wizard"] = true

   chara = Chara.create("elona.informer", 3, 28, nil, map)
   chara.roles["elona.informer"] = true

   for _=1,4 do
      chara = Chara.create("elona.citizen", nil, nil, nil, map)
      chara.roles["elona.citizen"] = true

      chara = Chara.create("elona.citizen2", nil, nil, nil, map)
      chara.roles["elona.citizen"] = true
   end

   for _=1,20 do
      generate_chara(map)
   end
end
data:add(derphy)

local thieves_guild = {
   _type = "base.map_template",
   _id = "thieves_guild",

   map = generate_122("thiefguild"),
   unique = true,

   properties = {
      music = "elona.ruin",
      types = { "guild" },
      player_start_pos = "elona.stair_up",
      level = 3,
      deepest_dungeon_level = 999,
      is_indoor = true,
      max_crowd_density = 25,

      chara_filter = chara_filter_town(
         function()
            return { id = "elona.thief_guild_member" }
         end
      )
   },
}
function thieves_guild.on_generate(map)
   local chara = Chara.create("elona.sin", 21, 9, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.trainer", 3, 6, nil, map)
   chara.roles["elona.trainer"] = true
   chara.name = I18N.get("chara.job.trainer", chara.name)

   chara = Chara.create("elona.wizard", 3, 12, nil, map)
   chara.roles["elona.wizard"] = true

   chara = Chara.create("elona.shopkeeper", 5, 18, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id = "elona.blackmarket"}
   chara.shop_rank = 10
   chara.name = I18N.get("chara.job.blackmarket", chara.name)

   chara = Chara.create("elona.shopkeeper", 27, 13, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id = "elona.blackmarket"}
   chara.shop_rank = 10
   chara.name = I18N.get("chara.job.blackmarket", chara.name)

   chara = Chara.create("elona.shopkeeper", 21, 19, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id = "elona.the_fence"}
   chara.shop_rank = 10
   chara.name = I18N.get("chara.job.fence", chara.name)

   for _=1, 16 do
      Chara.create("elona.thief_guild_member", nil, nil, nil, map)
   end
end
data:add(thieves_guild)

local port_kapul = {
   _id = "port_kapul",
   _type = "base.map_template",

   elona_id = 11,
   map = generate_122("kapul"),
   image = "elona.feat_area_city",
   unique = true,

   properties = {
      music = "elona.town2",
      types = { "town" },
      player_start_pos = "base.edge",
      tileset = "elona.town",
      level = 1,
      deepest_dungeon_level = 999,
      is_indoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      quest_town_id = 5,
      quest_custom_map = generate_122("kapul"),
      chara_filter = chara_filter_town()
   }
}
function port_kapul.on_generate(map)
   local chara = Chara.create("elona.raphael", 15, 18, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.arnord", 36, 27, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.icolle", 5, 26, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.doria", 29, 3, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.cleaner", 24, 21, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.cleaner", 12, 26, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.cleaner", 8, 11, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.bard", 8, 14, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.shopkeeper", 16, 17, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.trader" }
   chara.shop_rank = 12
   chara.name = I18N.get("chara.job.trader", chara.name)

   chara = Chara.create("elona.shopkeeper", 23, 7, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id = "elona.blacksmith"}
   chara.shop_rank = 12
   chara.name = I18N.get("chara.job.blacksmith", chara.name)

   chara = Chara.create("elona.shopkeeper", 32, 14, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id="elona.general_vendor"}
   chara.shop_rank = 10
   chara.name = I18N.get("chara.job.general_vendor", chara.name)

   chara = Chara.create("elona.shopkeeper", 22, 14, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id="elona.goods_vendor"}
   chara.shop_rank = 10
   chara.name = I18N.get("chara.job.goods_vendor", chara.name)

   chara = Chara.create("elona.shopkeeper", 16, 25, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id = "elona.blackmarket"}
   chara.shop_rank = 10
   chara.name = I18N.get("chara.job.blackmarket", chara.name)

   chara = Chara.create("elona.shopkeeper", 17, 28, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id="elona.food_vendor"}
   chara.shop_rank = 10
   chara.name = I18N.get("chara.job.food_vendor", chara.name)

   chara = Chara.create("elona.wizard", 22, 22, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.magic_vendor" }
   chara.shop_rank = 11
   chara.name = I18N.get("chara.job.magic_vendor", chara.name)

   chara = Chara.create("elona.shopkeeper", 35, 3, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.innkeeper" }
   chara.roles["elona.innkeeper"] = true
   chara.shop_rank = 8
   chara.name = I18N.get("chara.job.innkeeper", chara.name)

   chara = Chara.create("elona.bartender", 15, 15, nil, map)
   chara.roles["elona.bartender"] = true

   chara = Chara.create("elona.arena_master", 26, 3, nil, map)
   chara.roles["elona.arena_master"] = true

   chara = Chara.create("elona.pet_arena_master", 25, 4, nil, map)
   chara.roles["elona.arena_master"] = true

   chara = Chara.create("elona.elder", 8, 12, nil, map)
   chara.roles["elona.elder"] = true
   chara.name = I18N.get("chara.job.of_port_kapul", chara.name)

   chara = Chara.create("elona.trainer", 16, 4, nil, map)
   chara.roles["elona.trainer"] = true
   chara.name = I18N.get("chara.job.trainer", chara.name)

   chara = Chara.create("elona.wizard", 14, 4, nil, map)
   chara.roles["elona.wizard"] = true

   chara = Chara.create("elona.informer", 17, 5, nil, map)
   chara.roles["elona.informer"] = true

   chara = Chara.create("elona.healer", 27, 11, nil, map)
   chara.roles["elona.healer"] = true

   for _=1,2 do
      chara = Chara.create("elona.citizen", nil, nil, nil, map)
      chara.roles["elona.citizen"] = true

      chara = Chara.create("elona.citizen2", nil, nil, nil, map)
      chara.roles["elona.citizen"] = true
   end

   for _=1,4 do
      chara = Chara.create("elona.sailor", nil, nil, nil, map)
      chara.roles["elona.citizen"] = true
   end

   for _=1,5 do
      chara = Chara.create("elona.guard_port_kapul", nil, nil, nil, map)
      chara.roles["elona.guard"] = true
   end

   chara = Chara.create("elona.captain", 7, 6, nil, map)
   chara.roles["elona.citizen"] = true

   for _=1,20 do
      generate_chara(map)
   end
end
data:add(port_kapul)

local fighters_guild = {
   _type = "base.map_template",
   _id = "fighters_guild",

   map = generate_122("fighterguild"),
   unique = true,

   properties = {
      music = "elona.ruin",
      types = { "guild" },
      player_start_pos = "elona.stair_up",
      level = 3,
      deepest_dungeon_level = 999,
      is_indoor = true,
      max_crowd_density = 25,

      chara_filter = chara_filter_town(
         function()
            return { id = "elona.fighter_guild_member" }
         end
      )
   },
}
function fighters_guild.on_generate(map)
   local chara = Chara.create("elona.fray", 27, 4, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.healer", 28, 10, nil, map)
   chara.roles["elona.healer"] = true

   chara = Chara.create("elona.trainer", 15, 10, nil, map)
   chara.roles["elona.trainer"] = true
   chara.name = I18N.get("chara.job.trainer", chara.name)

   chara = Chara.create("elona.wizard", 14, 18, nil, map)
   chara.roles["elona.wizard"] = true

   chara = Chara.create("elona.blacksmith", 29, 15, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id = "elona.blacksmith"}
   chara.shop_rank = 12
   chara.name = I18N.get("chara.job.blacksmith", chara.name)

   for _=1, 16 do
      Chara.create("elona.fighter_guild_member", nil, nil, nil, map)
   end
end
data:add(fighters_guild)

local noyel = {
   _id = "noyel",
   _type = "base.map_template",

   elona_id = 33,
   map = generate_122("noyel"),
   image = "elona.feat_area_village_snow",
   unique = true,

   properties = {
      music = "elona.town6",
      types = { "town" },
      player_start_pos = function(chara, map)
         local x, y = entrance_edge(chara, map)
         if save.base.player_pos_on_map_leave then
            return x, y
         end
         local last_dir = Chara.player().direction
         if last_dir == "East" then
            y = 3
         elseif last_dir == "North" then
            x = 28
         elseif last_dir == "South" then
            x = 5
         end
         return x, y
      end,
      tileset = "elona.town",
      level = 1,
      deepest_dungeon_level = 1,
      is_indoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      quest_town_id = 6,
      quest_custom_map = generate_122("noyel"),
      villagers_make_snowmen = true,
      chara_filter = chara_filter_town(
         function()
            if Rand.one_in(3) then
               return { id = "elona.sister" }
            end
         end
      )
   },
}
local function reload_noyel_christmas(map)
   local item = Item.create("elona.pedestal", 29, 16, nil, map)
   item.own_state = "not_owned"

   item = Item.create("elona.statue_of_jure", 29, 16, nil, map)
   item.own_state = "not_owned"

   item = Item.create("elona.altar", 29, 17, nil, map)
   item.own_state = "not_owned"
   item.params = { god_id = "elona.jure" }

   item = Item.create("elona.mochi", 29, 17, nil, map)
   item.own_state = "unobtainable"

   local chara = Chara.create("elona.kaneda_bike", 48, 19, nil, map)
   chara.roles["elona.special"] = true
   chara.is_only_in_christmas = true

   chara = Chara.create("elona.part_time_worker", 30, 17, nil, map)
   chara.roles["elona.special"] = true
   chara.is_only_in_christmas = true

   chara = Chara.create("elona.punk", 38, 19, nil, map)
   chara.is_only_in_christmas = true
   chara.is_hung_on_sandbag = true
   chara.name = I18N.get("chara.job.fanatic")

   chara = Chara.create("elona.fanatic", 35, 19, nil, map)
   chara.is_only_in_christmas = true

   chara = Chara.create("elona.fanatic", 37, 18, nil, map)
   chara.is_only_in_christmas = true

   chara = Chara.create("elona.fanatic", 37, 21, nil, map)
   chara.is_only_in_christmas = true

   chara = Chara.create("elona.fanatic", 39, 20, nil, map)
   chara.is_only_in_christmas = true

   chara = Chara.create("elona.fanatic", 38, 21, nil, map)
   chara.is_only_in_christmas = true

   chara = Chara.create("elona.bartender", 17, 8, nil, map)
   chara.ai_calm = 3
   chara.is_only_in_christmas = true
   chara.roles["elona.shopkeeper"] = {inventory_id="elona.food_vendor"}
   chara.shop_rank = 10
   chara.name = I18N.get("chara.job.food_vendor", chara.name)

   chara = Chara.create("elona.hot_spring_maniac", 25, 8, nil, map)
   chara.ai_calm = 3
   chara.faction = "base.citizen"
   chara.is_only_in_christmas = true
   chara.roles["elona.shopkeeper"] = {inventory_id="elona.souvenir_vendor"}
   chara.shop_rank = 30
   chara.name = I18N.get("chara.job.souvenir_vendor", Text.random_name())

   chara = Chara.create("elona.rogue", 24, 22, nil, map)
   chara.ai_calm = 3
   chara.faction = "base.citizen"
   chara.is_only_in_christmas = true
   chara.roles["elona.shopkeeper"] = {inventory_id="elona.souvenir_vendor"}
   chara.shop_rank = 30
   chara.name = I18N.get("chara.job.souvenir_vendor", Text.random_name())

   chara = Chara.create("elona.shopkeeper", 38, 12, nil, map)
   chara.ai_calm = 3
   chara.roles["elona.shopkeeper"] = {inventory_id="elona.blackmarket"}
   chara.shop_rank = 10
   chara.name = I18N.get("chara.job.blackmarket", Text.random_name())
   chara.is_only_in_christmas = true

   chara = Chara.create("elona.rogue", 28, 9, nil, map)
   chara.ai_calm = 3
   chara.faction = "base.citizen"
   chara.is_only_in_christmas = true
   chara.roles["elona.shopkeeper"] = {inventory_id="elona.street_vendor"}
   chara.shop_rank = 30
   chara.name = I18N.get("chara.job.street_vendor", Text.random_name())

   chara = Chara.create("elona.rogue", 29, 24, nil, map)
   chara.ai_calm = 3
   chara.faction = "base.citizen"
   chara.is_only_in_christmas = true
   chara.roles["elona.shopkeeper"] = {inventory_id="elona.street_vendor"}
   chara.shop_rank = 30
   chara.name = I18N.get("chara.job.street_vendor2", Text.random_name())

   for _ = 1, 20 do
      chara = Chara.create("elona.holy_beast", nil, nil, nil, map)
      chara.is_only_in_christmas = true

      chara = Chara.create("elona.festival_tourist", nil, nil, nil, map)
      chara.is_only_in_christmas = true
   end

   for _ = 1, 15 do
      chara = Chara.create("elona.bard", nil, nil, nil, map)
      chara.is_only_in_christmas = true
   end

   for _ = 1, 7 do
      chara = Chara.create("elona.prostitute", nil, nil, nil, map)
      chara.is_only_in_christmas = true

      chara = Chara.create("elona.tourist", nil, nil, nil, map)
      chara.is_only_in_christmas = true

      chara = Chara.create("elona.noble", nil, nil, nil, map)
      chara.is_only_in_christmas = true

      chara = Chara.create("elona.punk", nil, nil, nil, map)
      chara.is_only_in_christmas = true
   end

   for _ = 1, 3 do
      chara = Chara.create("elona.stray_cat", nil, nil, nil, map)
      chara.is_only_in_christmas = true

      chara = Chara.create("elona.tourist", nil, nil, nil, map)
      chara.is_only_in_christmas = true
   end
end
local function reload_noyel(map)
   Chara.iter_others(map)
   :filter(function(c) return c.is_only_in_christmas end)
      :each(IChara.vanquish)
end
function noyel.on_generate(map)
   for _, item in Item.iter_ground(map) do
      if item.id ~= "elona.shelter" and item.id ~= "elona.giants_shackle" then
         item:remove()
      end
   end

   if World.date().month == 12 then
      if not map.is_noyel_christmas_festival then
         map.is_noyel_christmas_festival = true
         reload_noyel_christmas(map)
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
data:add(noyel)

local lumiest = {
   _id = "lumiest",
   _type = "base.map_template",

   elona_id = 36,
   map = generate_122("lumiest"),
   image = "elona.feat_area_city",
   unique = true,

   properties = {
      music = "elona.town2",
      types = { "town" },
      player_start_pos = function(chara, map)
         local x, y = entrance_edge(chara, map)
         if save.base.player_pos_on_map_leave then
            return x, y
         end
         local last_dir = Chara.player().direction
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
      tileset = "elona.town",
      level = 1,
      deepest_dungeon_level = 999,
      is_indoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      quest_town_id = 7,
      quest_custom_map = generate_122("lumiest"),
      chara_filter = chara_filter_town(
         function()
            if Rand.one_in(3) then
               return { id = "elona.artist" }
            end
         end
      )
   }
}
function lumiest.on_generate(map)
   -- TODO only if sidequest
   --local stair = Feat.at(18, 45, map):nth(1)
   --assert(stair)
   --stair.generator_params = { generator = "base.map_template", params = { id = "elona.the_sewer" }}
   --stair.area_params = { outer_map_id = map._id }

   local chara = Chara.create("elona.renton", 12, 24, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.balzak", 21, 3, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.lexus", 5, 20, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.cleaner", 28, 29, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.bard", 41, 19, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.bard", 32, 43, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.bard", 29, 28, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.bard", 16, 45, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.bard", 13, 24, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.bartender", 41, 42, nil, map)
   chara.roles["elona.bartender"] = true

   chara = Chara.create("elona.healer", 10, 16, nil, map)
   chara.roles["elona.healer"] = true

   chara = Chara.create("elona.shopkeeper", 47, 30, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id="elona.general_vendor"}
   chara.shop_rank = 10
   chara.name = I18N.get("chara.job.general_vendor", chara.name)

   chara = Chara.create("elona.shopkeeper", 24, 47, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.innkeeper" }
   chara.roles["elona.innkeeper"] = true
   chara.shop_rank = 8
   chara.name = I18N.get("chara.job.inkeeper", chara.name)

   chara = Chara.create("elona.shopkeeper", 37, 30, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id = "elona.blacksmith"}
   chara.shop_rank = 12
   chara.name = I18N.get("chara.job.blacksmith", chara.name)

   chara = Chara.create("elona.shopkeeper", 37, 12, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.bakery" }
   chara.shop_rank = 9
   chara.image = "elona.chara_baker"
   chara.name = I18N.get("chara.job.baker", chara.name)

   chara = Chara.create("elona.wizard", 6, 15, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.magic_vendor" }
   chara.shop_rank = 11
   chara.name = I18N.get("chara.job.magic_vendor", chara.name)

   chara = Chara.create("elona.shopkeeper", 33, 43, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.trader" }
   chara.shop_rank = 12
   chara.name = I18N.get("chara.job.trader", chara.name)

   chara = Chara.create("elona.shopkeeper", 47, 12, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.fisher" }
   chara.shop_rank = 5
   chara.name = I18N.get("chara.job.fisher", chara.name)

   chara = Chara.create("elona.elder", 3, 38, nil, map)
   chara.roles["elona.elder"] = true
   chara.name = I18N.get("chara.job.of_lumiest", chara.name)

   chara = Chara.create("elona.trainer", 21, 28, nil, map)
   chara.roles["elona.trainer"] = true
   chara.name = I18N.get("chara.job.trainer", chara.name)

   chara = Chara.create("elona.wizard", 21, 30, nil, map)
   chara.roles["elona.wizard"] = true

   chara = Chara.create("elona.informer", 23, 38, nil, map)
   chara.roles["elona.informer"] = true

   for _=1,6 do
      chara = Chara.create("elona.citizen", nil, nil, nil, map)
      chara.roles["elona.citizen"] = true

      chara = Chara.create("elona.citizen2", nil, nil, nil, map)
      chara.roles["elona.citizen"] = true
   end

   for _=1,7 do
      chara = Chara.create("elona.guard", nil, nil, nil, map)
      chara.roles["elona.guard"] = true
   end

   for _=1,25 do
      generate_chara(map)
   end
end
data:add(lumiest)

local mages_guild = {
   _type = "base.map_template",
   _id = "mages_guild",

   map = generate_122("mageguild"),
   unique = true,

   properties = {
      music = "elona.ruin",
      types = { "guild" },
      player_start_pos = "elona.stair_up",
      level = 3,
      deepest_dungeon_level = 999,
      is_indoor = true,
      max_crowd_density = 25,

      chara_filter = chara_filter_town(
         function()
            return { id = "elona.mage_guild_member" }
         end
      )
   },
}
function mages_guild.on_generate(map)
   local chara = Chara.create("elona.revlus", 24, 3, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.wizard", 27, 8, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id="spell_writer"}
   chara.roles["elona.spell_writer"] = true
   chara.name = I18N.get("chara.job.spell_writer", chara.name)

   chara = Chara.create("elona.wizard", 22, 8, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.magic_vendor" }
   chara.shop_rank = 11
   chara.name = I18N.get("chara.job.magic_vendor", chara.name)

   chara = Chara.create("elona.healer", 3, 9, nil, map)
   chara.roles["elona.healer"] = true

   chara = Chara.create("elona.trainer", 12, 6, nil, map)
   chara.roles["elona.trainer"] = true
   chara.name = I18N.get("chara.job.trainer", chara.name)

   chara = Chara.create("elona.wizard", 3, 3, nil, map)
   chara.roles["elona.wizard"] = true

   for _=1, 16 do
      Chara.create("elona.mage_guild_member", nil, nil, nil, map)
   end
end
data:add(mages_guild)

local the_sewer = {
   _type = "base.map_template",
   _id = "the_sewer",

   map = generate_122("sqSewer"),
   unique = true,

   properties = {
      music = "elona.puti",
      types = { "dungeon" },
      player_start_pos = "elona.stair_up",
      level = 20,
      deepest_dungeon_level = 999,
      is_indoor = true,
      is_not_renewable = true,
      default_ai_calm = 1,
      max_crowd_density = 0,
   },

   events = {
      {
         id = "elona_sys.on_quest_check",
         name = "Sidequest: sewer_sweeping",

         callback = function(map)
            if Sidequest.progress("elona.sewer_sweeping") < 2 then
               if Sidequest.no_targets_remaining(map) then
                  Sidequest.set_progress("elona.sewer_sweeping", 2)
                  Sidequest.update_journal()
               end
            end
         end
      },
      {
         id = "base.on_map_generated",
         name = "Sidequest: sewer_sweeping",

         callback = function(map)
            Sidequest.set_quest_targets(map)
         end
      }
   }
}
data:add(the_sewer)

local fields = {
   _id = "fields",
   _type = "base.map_template",
   elona_id = 2,
   properties = {
      types = { "field" },
      player_start_pos = "base.center",
      tileset = "elona.wilderness",
      level = 1,
      deepest_dungeon_level = 1,
      is_indoor = false,
      default_ai_calm = 0
   }
}
data:add(fields)

local your_home = {
   _id = "your_home",
   _type = "base.map_template",

   elona_id = 7,
   map = function()
      return HomeMap.generate("elona.cave") -- TODO
   end,
   image = "elona.feat_area_your_dungeon",
   unique = true,

   properties = {
      music = "elona.lonely",
      types = { "player_owned" },
      player_start_pos = "base.south",
      level = 1,
      deepest_dungeon_level = 10,
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      tileset = "elona.home",

      is_fixed = true,
      can_return_to = false
   }
}
data:add(your_home)

local show_house = {
   _id = "show_house",
   _type = "base.map_template",

   elona_id = 35,
   map = generate_122("dungeon1"),
   image = "elona.feat_area_border_tent",
   unique = true,

   properties = {
      types = { "temporary" },
      player_start_pos = "base.south",
      level = 1,
      deepest_dungeon_level = 1,
      is_indoor = true,
      default_ai_calm = 1,
      tileset = "elona.home",
      reveals_fog = true,
      prevents_monster_ball = true
   }
}
data:add(show_house)

local arena = {
   _id = "arena",
   _type = "base.map_template",

   elona_id = 6,
   map = generate_122("arena_1"),
   unique = true,

   properties = {
      music = "elona.arena",
      types = { "temporary" },
      player_start_pos = "base.center",
      tileset = "elona.tower_1",
      level = 1,
      deepest_dungeon_level = 1,
      is_indoor = true,
      default_ai_calm = 0,
      max_crowd_density = 0,
      reveals_fog = true,
      prevents_domination = true,
      prevents_monster_ball = true
   }
}
function arena.on_generate(map)
   -- TODO
   Chara.create("elona.putit", nil, nil, nil, map)
end
data:add(arena)

local pet_arena = {
   _id = "pet_arena",
   _type = "base.map_template",

   elona_id = 40,
   map = generate_122("arena_2"),
   unique = true,

   properties = {
      types = { "temporary" },
      player_start_pos = "elona.stair_up",
      tileset = "elona.tower_1",
      level = 1,
      deepest_dungeon_level = 1,
      is_indoor = true,
      default_ai_calm = 0,
      max_crowd_density = 0,
      reveals_fog = true,
      prevents_teleport = true,
      prevents_domination = true,
      prevents_monster_ball = true
   }
}
function arena.on_generate(map)
   -- TODO
   Chara.create("elona.putit", nil, nil, nil, map)
end
data:add(pet_arena)

local quest = {
   _id = "quest",
   _type = "base.map_template",
   elona_id = 13,
   properties = {
      types = { "temporary" },
      player_start_pos = "base.center",
      tileset = "elona.tower_1",
      level = 1,
      deepest_dungeon_level = 1,
      is_indoor = false,
      max_crowd_density = 0,
      default_ai_calm = 0,
      shows_floor_count_in_name = true,
      prevents_building_shelter = true
   }
}
data:add(quest)

local lesimas = {
   _id = "lesimas",
   _type = "base.map_template",

   elona_id = 3,
   map = {
      generator = "elona.dungeon_template",
      params = {
         id = "elona.lesimas",
         start_dungeon_level = 1,
         deepest_dungeon_level = 45
      }
   },
   image = "elona.feat_area_lesimas",
   unique = true,

   properties = {
      types = { "dungeon" },
      player_start_pos = "elona.stair_up",
      level = 1,
      deepest_dungeon_level = 45,
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 0,
      can_return_to = true,
      shows_floor_count_in_name = true,
      chara_filter = function(map)
         local opts = Calc.filter(map.dungeon_level, "bad", nil, map)

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
   _type = "base.map_template",

   elona_id = 42,
   map = generate_122("dungeon1"),
   image = "elona.feat_area_lesimas",
   unique = true,

   properties = {
      types = { "dungeon" },
      player_start_pos = "elona.stair_up",
      level = 50,
      deepest_dungeon_level = 99999999,
      is_indoor = true,
      default_ai_calm = 0,
      can_return_to = true,
      prevents_domination = true,
      chara_filter = function(map)
         return Calc.filter((map.dungeon_level % 50) + 5, "bad", nil, map)
      end
   }
}
data:add(the_void)

local tower_of_fire = {
   _id = "tower_of_fire",
   _type = "base.map_template",
   elona_id = 16,

   map = {
      generator = "elona.dungeon_template",
      params = {
         id = "elona.tower_of_fire",
         start_dungeon_level = 15,
         deepest_dungeon_level = 18
      }
   },
   image = "elona.feat_area_tower_of_fire",
   unique = true,

   properties = {
      types = { "dungeon_tower" },
      player_start_pos = "elona.stair_up",
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 0,
      chara_filter = function(map)
         return Calc.filter(map.dungeon_level, "bad", { tag_filters = {"fire"}}, map)
      end
   }
}
data:add(tower_of_fire)

local crypt_of_the_damned = {
   _id = "crypt_of_the_damned",
   _type = "base.map_template",
   elona_id = 17,

   map = {
      generator = "elona.dungeon_template",
      params = {
         id = "elona.crypt_of_the_damned",
         start_dungeon_level = 25,
         deepest_dungeon_level = 30
      }
   },
   image = "elona.feat_area_crypt",
   unique = true,

   properties = {
      types = { "dungeon" },
      player_start_pos = "elona.stair_up",
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 0,
      chara_filter = function(map)
         return Calc.filter(map.dungeon_level, "bad", { tag_filters = {"undead"}}, map)
      end
   }
}
data:add(crypt_of_the_damned)

local ancient_castle = {
   _id = "ancient_castle",
   _type = "base.map_template",

   elona_id = 18,
   map = {
      generator = "elona.dungeon_template",
      params = {
         id = "elona.ancient_castle",
         start_dungeon_level = 17,
         deepest_dungeon_level = 22
      }
   },
   image = "elona.feat_area_castle",
   unique = true,

   properties = {
      types = { "dungeon_castle" },
      player_start_pos = "elona.stair_up",
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 0,
      chara_filter = function(map)
         local opts = Calc.filter(map.dungeon_level, "bad", nil, map)

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
   _type = "base.map_template",

   elona_id = 19,
   map = generate_122("dungeon1"),
   image = "elona.feat_area_dungeon",
   unique = true,

   properties = {
      types = { "dungeon" },
      player_start_pos = "elona.stair_up",
      level = 30,
      deepest_dungeon_level = 33,
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 0,
      chara_filter = function(map)
         return Calc.filter(map.dungeon_level, "bad", nil, map)
      end
   }
}
data:add(dragons_nest)

local mountain_pass = {
   _id = "mountain_pass",
   _type = "base.map_template",

   elona_id = 26,
   map = {
      generator = "elona.dungeon_template",
      params = {
         id = "elona.type_8",
         start_dungeon_level = 25,
         deepest_dungeon_level = 29
      }
   },
   image = "elona.feat_area_dungeon",
   unique = true,

   properties = {
      types = { "dungeon" },
      player_start_pos = "elona.stair_down",
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 0
   }
}
data:add(mountain_pass)

local puppy_cave = {
   _id = "puppy_cave",
   _type = "base.map_template",

   elona_id = 27,
   map = {
      generator = "elona.dungeon_template",
      params = {
         id = "elona.type_10",
         start_dungeon_level = 2,
         deepest_dungeon_level = 5
      }
   },
   image = "elona.feat_area_dungeon",
   unique = true,

   properties = {
      types = { "dungeon" },
      player_start_pos = "elona.stair_up",
      is_indoor = true,
      default_ai_calm = 0,
      is_generated_every_time = true
   },
}
function puppy_cave.on_generate(map)
   if map.dungeon_level == map.deepest_dungeon_level
      and Sidequest.progress("elona.puppys_cave") < 2
      and not Chara.find("elona.poppy", "allies")
   then
      local poppy = Chara.create("elona.poppy", nil, nil, {}, map, nil, map)
      poppy.is_not_targeted_by_ai = true
   end
end
data:add(puppy_cave)

local minotaurs_nest = {
   _id = "minotaurs_nest",
   _type = "base.map_template",

   elona_id = 38,
   map = {
      generator = "elona.dungeon_template",
      params = {
         id = "elona.type_9",
         start_dungeon_level = 23,
         deepest_dungeon_level = 27
      }
   },
   image = "elona.feat_area_dungeon",
   unique = true,

   properties = {
      types = { "dungeon" },
      player_start_pos = "elona.stair_up",
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 0,
      chara_filter = function(map)
         local opts = Calc.filter(map.dungeon_level, "bad", nil, map)

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
   _type = "base.map_template",

   elona_id = 28,
   map = generate_122("dungeon1"),
   image = "elona.feat_area_dungeon",
   unique = true,

   properties = {
      types = { "dungeon" },
      player_start_pos = "elona.stair_up",
      level = 5,
      deepest_dungeon_level = 5,
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 0,
      chara_filter = function(map)
         local opts = Calc.filter(map.dungeon_level, "bad", nil, map)

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
   _type = "base.map_template",

   elona_id = 37,
   map = generate_122("sqPyramid"),
   image = "elona.feat_area_pyramid",
   unique = true,

   properties = {
      music = "elona.puti",
      types = { "dungeon" },
      player_start_pos = "elona.stair_up",
      level = 20,
      deepest_dungeon_level = 21,
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 0,
      max_crowd_density = 40,
      prevents_teleport = true,
      chara_filter = function(map)
         return Calc.filter(map.dungeon_level, "bad", {category = 13}, map)
      end
   }
}
function pyramid.on_generate(map)
   for _=1,map:calc("max_crowd_density")+1 do
      generate_chara(map)
   end
end
data:add(pyramid)

local pyramid_2 = {
   _id = "pyramid_2",
   _type = "base.map_template",

   -- elona_id = 37,
   map = generate_122("sqPyramid2"),
   image = "elona.feat_area_pyramid",
   unique = true,

   properties = {
      music = "elona.puti",
      types = { "dungeon" },
      player_start_pos = "elona.stair_up",
      level = 21,
      deepest_dungeon_level = 21,
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 0,
      max_crowd_density = 0,
      prevents_teleport = true,
      chara_filter = function(map)
         return Calc.filter(map.dungeon_level, "bad", {category = 13}, map)
      end
   }
}
data:add(pyramid_2)

local lumiest_graveyard = {
   _id = "lumiest_graveyard",
   _type = "base.map_template",

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
   _type = "base.map_template",

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
   _type = "base.map_template",

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
   _type = "base.map_template",

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
   _type = "base.map_template",

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
   _type = "base.map_template",

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
   _type = "base.map_template",

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
   _type = "base.map_template",

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
   _type = "base.map_template",

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
   _type = "base.map_template",

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
   _type = "base.map_template",

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
   _type = "base.map_template",

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
   _type = "base.map_template",

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
   _type = "base.map_template",

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
   _type = "base.map_template",

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
   _type = "base.map_template",

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
   _type = "base.map_template",

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
   _type = "base.map_template",

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
   _type = "base.map_template",

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
   _type = "base.map_template",

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

local rq = {
   _id = "rq",
   _type = "base.map_template",
   elona_id = 9,
   map = generate_122("dungeon1"),
   properties = {
      types = { "shelter" },
      player_start_pos = "base.center",
      tileset = "elona.wilderness",
      level = 1,
      deepest_dungeon_level = 45,
      is_indoor = false,
      max_crowd_density = 0,
      default_ai_calm = 0
   }
}
data:add(rq)

local shop = {
   _id = "shop",
   _type = "base.map_template",
   elona_id = 102,
   map = generate_122("shop_1"),
   properties = {
      music = "elona.town3",
      types = { "player_owned" },
      player_start_pos = "base.south",
      is_indoor = true,
      max_items = 10,
   }
}
function shop.on_generate(map)
   local item = Item.create("elona.book", 17, 14, nil, map)
   item.params.book_id = 8

   Item.create("elona.shop_strongbox", 19, 10, nil, map)
   Item.create("elona.register", 17, 11, nil, map)
end
data:add(shop)

local crop = {
   _id = "crop",
   _type = "base.map_template",
   elona_id = 103,
   map = generate_122("crop_1"),
   properties = {
      music = "elona.lonely",
      types = { "player_owned" },
      player_start_pos = "base.south",
      is_indoor = false,
      max_items = 80,
   }
}
function crop.on_generate(map)
   local item = Item.create("elona.book", 17, 14, nil, map)
   item.params.book_id = 9
end
data:add(crop)

local ranch = {
   _id = "ranch",
   _type = "base.map_template",
   elona_id = 31,
   map = generate_122("ranch_1"),
   properties = {
      music = "elona.lonely",
      types = { "player_owned" },
      player_start_pos = "base.south",
      is_indoor = false,
      max_items = 80,
   }
}
function ranch.on_generate(map)
   local item = Item.create("elona.book", 23, 8, nil, map)
   item.params.book_id = 11

   Item.create("elona.register", 22, 6, nil, map)
end
data:add(ranch)

local dungeon = {
   _id = "dungeon",
   _type = "base.map_template",
   elona_id = 39,
   map = generate_122("dungeon1"),
   properties = {
      music = "elona.lonely",
      types = { "player_owned" },
      player_start_pos = "base.south",
      is_indoor = false,
      max_items = 350,
   }
}
function dungeon.on_generate(map)
   local item = Item.create("elona.book", 39, 54, nil, map)
   item.params.book_id = 15
end
data:add(dungeon)

local storage = {
   _id = "storage",
   _type = "base.map_template",
   elona_id = 104,
   map = generate_122("storage_1"),
   properties = {
      music = "elona.lonely",
      types = { "player_owned" },
      player_start_pos = "base.south",
      is_indoor = false,
      max_items = 200,
   }
}
data:add(storage)
