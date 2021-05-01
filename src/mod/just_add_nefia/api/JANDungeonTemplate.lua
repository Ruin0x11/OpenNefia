local Nefia = require("mod.elona.api.Nefia")
local JANDungeon = require("mod.just_add_nefia.api.JANDungeon")
local Dungeon = require("mod.elona.api.Dungeon")
local Log = require("api.Log")
local Rand = require("api.Rand")

local JANDungeonTemplate = {}

local MAX_ATTEMPTS = 5

local function wrap(gen)
   return function(floor, params)
      if params.generation_attempt > MAX_ATTEMPTS then
         Log.warn("Couldn't generate just_add_nefia dungeon in %d attempts. Falling back to something boring.", MAX_ATTEMPTS)
         return Dungeon.gen_type_standard(floor, params)
      end
      return gen(floor, params)
   end
end

function JANDungeonTemplate.nefia_mazey(floor, params)
   params.level = Nefia.calc_nefia_map_level(floor, params.level)
   params.tileset = "elona.dungeon_castle"
   Dungeon.set_template_property(params, "material_spot", "elona.dungeon")

   local gen = JANDungeon.gen_maze

   if Rand.one_in(2) then
      gen = JANDungeon.gen_mazelike
   end

   return wrap(gen), params
end

function JANDungeonTemplate.nefia_putit(floor, params)
   params.level = Nefia.calc_nefia_map_level(floor, params.level)
   params.tileset = "elona.tower_1"
   Dungeon.set_template_property(params, "material_spot", "elona.dungeon")

   return wrap(JANDungeon.gen_putit), params
end

function JANDungeonTemplate.nefia_weird(floor, params)
   params.level = Nefia.calc_nefia_map_level(floor, params.level)
   Dungeon.set_template_property(params, "material_spot", "elona.dungeon")

   local gen = JANDungeon.gen_roomed

   if Rand.one_in(2) then
      gen = JANDungeon.gen_firey_life
   end

   return wrap(gen), params
end

return JANDungeonTemplate
