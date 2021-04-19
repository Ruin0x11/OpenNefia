local Item = require("api.Item")
local utils = require("mod.test_room.data.map_archetype.utils")
local IItemMusicDisc = require("mod.elona.api.aspect.IItemMusicDisc")

local music_disc = {
   _id = "music_disc"
}

local function make_music_discs(x, y, map, can_gen)
   local sort = function(a, b)
      if a.elona_id and b.elona_id then
         return a.elona_id < b.elona_id
      elseif a.elona_id then
         return true
      elseif b.elona_id then
         return false
      else
         return a._id < b._id
      end
   end

   local filter = function(music)
      return data["base.music"]:ext(music._id, "elona.music_disc").can_randomly_generate == can_gen
   end

   local ix = x
   local iy = y
   for _, idx, music in data["base.music"]:iter():filter(filter):into_sorted(sort):enumerate() do
      ix = x + ((idx - 1) % (map:width() - x - 2))
      iy = y + math.floor((idx - 1) / (map:width() - x - 2))
      if not map:can_access(ix, iy) then
         break
      end

      assert(Item.create("elona.disc", ix, iy, {aspects={[IItemMusicDisc]={music_id=music._id}}}, map))
   end

   return 2, iy + 2
end

function music_disc.on_generate_map(area, floor)
   local map = utils.create_map(15, 15)
   utils.create_stairs(2, 2, area, map)

   local x = 2
   local y = 4

   x, y = make_music_discs(x, y, map, true)
   x, y = make_music_discs(x, y, map, false)

   return map
end

return music_disc
