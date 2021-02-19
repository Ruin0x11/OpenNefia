local Area = require("api.Area")
local utils = require("mod.test_room.data.map_archetype.utils")

local dungeon = {
   _id = "dungeon"
}

local DUNGEONS = table.set {
   "elona.lesimas",
   "elona.the_void",
   "elona.tower_of_fire",
   "elona.crypt_of_the_damned",
   "elona.ancient_castle",
   "elona.dragons_nest",
   "elona.mountain_pass",
   "elona.puppy_cave",
   "elona.minotaurs_nest",
   "elona.yeeks_nest",
}

local NEFIAS = table.set {
   "elona.nefia_dungeon",
   "elona.nefia_forest",
   "elona.nefia_tower",
   "elona.nefia_fortress",
}

local function create_static_dungeons(x, y, map, area)
   local ix = x
   local iy = y

   local filter = function(arc) return DUNGEONS[arc._id] end

   for _, idx, area_archetype in data["base.area_archetype"]:iter():filter(filter):enumerate() do
      ix = x + ((idx - 1) % (map:width() - x - 2))
      iy = y + math.floor((idx - 1) / (map:width() - x - 2))
      if not map:can_access(ix, iy) then
         break
      end

      local dungeon_area = Area.create_unique(area_archetype._id, area)
      assert(Area.create_entrance(dungeon_area, 1, ix, iy, {}, map))
   end

   return 2, iy + 2
end

local function create_nefias(x, y, map, area)
   local ix = x
   local iy = y

   -- TODO

   return 2, iy + 2
end

function dungeon.on_generate_map(area, floor)
   local map = utils.create_map(20, 20)
   utils.create_stairs(2, 2, area, map)

   local x = 2
   local y = 4

   x, y = create_static_dungeons(x, y, map, area)
   x, y = create_nefias(x, y, map, area)

   return map
end

return dungeon
