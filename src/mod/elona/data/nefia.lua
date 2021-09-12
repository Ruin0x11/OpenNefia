-- It ain't Eternal League of *Nefia* without any nefias.
local Log = require("api.Log")
local DungeonTemplate = require("mod.elona.api.DungeonTemplate")
local DungeonMap = require("mod.elona.api.DungeonMap")
local Nefia = require("mod.elona.api.Nefia")
local MapEntrance = require("mod.elona_sys.api.MapEntrance")
local Dungeon = require("mod.elona.api.Dungeon")
local Feat = require("api.Feat")
local IFeat = require("api.feat.IFeat")
local InstancedArea = require("api.InstancedArea")
local InstancedMap = require("api.InstancedMap")

data:add_type {
   name = "nefia",
   fields = {
      {
         name = "image",
         type = types.data_id("base.chip")
      },
      {
         name = "color",
         type = types.optional(types.color)
      },
      {
         name = "on_generate_floor",
         type = types.callback({"area", types.class(InstancedArea), "floor", types.uint}, types.class(InstancedMap))
      },
   }
}

data:add {
   _type = "elona.nefia",
   _id = "dungeon",

   image = "elona.feat_area_cave",

   on_generate_floor = function(area, floor)
      local gen, params = DungeonTemplate.nefia_dungeon(floor, { level = Nefia.get_level(area) })
      local map = DungeonMap.generate(area, floor, gen, params)
      return map
   end
}

data:add {
   _type = "elona.nefia",
   _id = "tower",

   image = "elona.feat_area_tower",

   on_generate_floor = function(area, floor)
      local gen, params = DungeonTemplate.nefia_tower(floor, { level = Nefia.get_level(area) })
      local map = DungeonMap.generate(area, floor, gen, params)
      return map
   end
}

data:add {
   _type = "elona.nefia",
   _id = "fort",

   image = "elona.feat_area_temple",

   on_generate_floor = function(area, floor)
      local gen, params = DungeonTemplate.nefia_fort(floor, { level = Nefia.get_level(area) })
      local map = DungeonMap.generate(area, floor, gen, params)
      return map
   end
}

data:add {
   _type = "elona.nefia",
   _id = "forest",

   image = "elona.feat_area_tree",

   on_generate_floor = function(area, floor)
      local gen, params = DungeonTemplate.nefia_forest(floor, { level = Nefia.get_level(area) })
      local map = DungeonMap.generate(area, floor, gen, params)
      return map
   end
}


data:add {
   _type = "base.map_archetype",
   _id = "nefia",

   starting_pos = MapEntrance.stairs_up,

   chara_filter = Dungeon.default_chara_filter,

   properties = {
      turn_cost = 10000,
      is_temporary = false,
      has_anchored_npcs = false,
      is_indoor = true,
      types = { "dungeon" },
   }
}

local area_nefia = {
   _type = "base.area_archetype",
   _id = "nefia",

   types = { "dungeon" },
   image = "elona.feat_area_cave",
}


local function remove_down_stairs(map, area)
   local filter = function(feat)
      return feat._id == "elona.stairs_down"
         and feat.params.area_uid == area.uid
   end
   Feat.iter(map):filter(filter):each(IFeat.remove_ownership)
end

function area_nefia.on_generate_floor(area, floor)
   local nefia_id = Nefia.get_type(area)
   if nefia_id == nil then
      Log.error("Missing nefia type for nefia area '%d'", area.uid)
      nefia_id = "elona.tower"
   end

   local nefia_proto = data["elona.nefia"]:ensure(nefia_id)

   local map = nefia_proto.on_generate_floor(area, floor)

   if map._archetype == nil then
      map:set_archetype("elona.nefia", { set_properties = true })
   end

   map.name = area.name

   if area:deepest_floor() == floor then
      remove_down_stairs(map, area)
   end

   return map
end

data:add(area_nefia)
