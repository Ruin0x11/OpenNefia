local Chara = require("api.Chara")
local Rand = require("api.Rand")
local I18N = require("api.I18N")

data:add {
   _type = "elona_sys.map_template",
   _id = "north_tyris",

   map = "ntyris",

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

local MapEntrance = {}
function MapEntrance.directional(chara, map)
   local pos = save.base.player_pos_on_map_leave
   if pos then
      return pos.x, pos.y
   end
   local next_dir = chara.last_move_direction
   local x = 0
   local y = 0

   if next_dir == "West" then
      x = map:width() - 2
      y = math.floor(map:width() / 2)
   elseif next_dir == "East" then
      x = 1
      y = math.floor(map:width() / 2)
   elseif next_dir == "North" then
      x = math.floor(map:width() / 2)
      y = map:height() - 2
   else
      x = math.floor(map:width() / 2)
      y = 1
   end

   return x, y
end

local function chara_filter_town(callbacks)
   return function(self)
      local opts = { level = 10, quality = 1, fltselect = 5 }

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
   local params = {}
   if map.chara_filter then
      params = map.chara_filter()
      assert(type(params) == "table")
   end
   -- TODO
   local Charagen = require("mod.tools.api.Charagen")
   return Charagen.create(nil, nil, params, map)
end

local vernis = {
   _type = "elona_sys.map_template",
   _id = "vernis",

   elona_id = 5,
   map = "vernis",

   copy = {
      appearance = 132,
      types = { "town" },
      player_start_pos = MapEntrance.directional,
      tile_set = "Normal",
      tile_type = 2,
      turn_cost = 10000,
      danger_level = 1,
      deepest_dungeon_level = 999,
      is_outdoors = true,
      is_temporary = false,
      default_ai_calm = 1,
      -- quest_town_id = 1,
      -- quest_custom_map = "vernis",
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
         { 47, 9, "elona.shopkeeper", { roles = {{ id = "elona.shopkeeper", params = { 1014 } }}, shop_rank = 5, _name = "chara.job.fisher" } },
         { 14, 12, "elona.shopkeeper", { roles = {{ id = "elona.shopkeeper", params = { 1001 } }}, shop_rank = 12, _name = "chara.job.blacksmith" } },
         { 39, 27, "elona.shopkeeper", { roles = {{ id = "elona.shopkeeper", params = { 1009 } }}, shop_rank = 12, _name = "chara.job.trader" } },
         { 10, 15, "elona.shopkeeper", { roles = {{ id = "elona.shopkeeper", params = { 1006 } }}, shop_rank = 10, _name = "chara.job.general_vendor" } },
         { 7, 26, "elona.wizard", { roles = {{ id = "elona.shopkeeper", params = { 1004 } }}, shop_rank = 11, _name = "chara.job.magic_vendor" } },
         { 14, 25, "elona.shopkeeper", { roles = {{ id = "elona.shopkeeper", params = { 1005 } }}, shop_rank = 8, _name = "chara.job.innkeeper" } },
         { 22, 26, "elona.shopkeeper", { roles = {{ id = "elona.shopkeeper", params = { 1003 } }}, shop_rank = 9, _name = "chara.job.baker", image = "elona.baker" } },
         { 28, 16, "elona.wizard", { role = 5 } },
         { 38, 27, "elona.bartender", { role = 9 } },
         { 6, 25, "elona.healer", { role = 12 } },
         { 10, 7, "elona.elder", { role = 6, _name = "chara.job.of_vernis" } },
         { 27, 16, "elona.trainer", { role = 7, _name = "chara.job.trainer" } },
         { 25, 16, "elona.informer", { role = 8 } },
         { nil, nil, "elona.citizen", { _count = 4, role = 4 } },
         { nil, nil, "elona.citizen2", { _count = 4, role = 4 } },
         { nil, nil, "elona.guard", { _count = 4, role = 14 } },
      }

      create_charas(map, charas)

      update_quests_in_map(map)

      for i=0,25 do
         generate_chara(map)
      end
   end
}
data:add(vernis)

--- unfinished

local dungeon = "dungeon1"

local temp = {
   yowyn = "yowyn",
   palmia = "palmia",
   derphy = "derphy",
   port_kapul = "kapul",
   noyel = "noyel",
   lumiest = "lumiest",
   your_home = "home0",
   show_house = dungeon,
   lesimas = dungeon,
   the_void = dungeon,
   tower_of_fire = dungeon,
   crypt_of_the_damned = dungeon,
   ancient_castle = dungeon,
   dragons_nest = dungeon,
   mountain_pass = dungeon,
   puppy_cave = dungeon,
   minotaurs_nest = dungeon,
   yeeks_nest = dungeon,
   pyramid = "sqPyramid",
   lumiest_graveyard = "grave_1",
   truce_ground = "truce_ground",
   jail = "jail1",
   cyber_dome = "cyberdome",
   larna = "highmountain",
   miral_and_garoks_workshop = "smith0",
   mansion_of_younger_sister = "sister",
   embassy = "office_1",
   north_tyris_south_border = "station-nt1",
   fort_of_chaos_beast = "god",
   fort_of_chaos_machine = "god",
   fort_of_chaos_collapsed = "god",
   test_site = dungeon,
}

for k, v in pairs(temp) do
   data:add {
      _type = "elona_sys.map_template",
      _id = k,

      map = v
   }
end
