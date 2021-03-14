local InstancedMap = require("api.InstancedMap")
local Assert = require("api.test.Assert")
local Chara = require("api.Chara")
local PriorityMap = require("api.PriorityMap")

function test_InstancedMap_memorize_tile__map_tile()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   Assert.same(nil, map:memory(4, 5, "base.map_tile"))

   local expected = {
      _id = "elona.cobble",
      _type = "base.map_tile",
      count_x = 1,
      elona_atlas = 1,
      elona_id = 78,
      image = {
         height = 48,
         source = "graphic/map1.bmp",
         width = 48,
         x = 576,
         y = 96
      }
   }

   map:memorize_tile(4, 5)
   Assert.same({ expected }, map:memory(4, 5, "base.map_tile"))

   map:memorize_tile(4, 5)
   Assert.same({ expected }, map:memory(4, 5, "base.map_tile"))
end

disable("not fixed yet")
function test_InstancedMap_memorize_tile__map_object()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   Assert.same(nil, map:memory(4, 5, "base.chara"))

   Chara.create("elona.putit", 4, 5, nil, map)
   local expected = {
      drawables = PriorityMap:new(),
      hp_bar = "hp_bar_other",
      hp_ratio = 1,
      image = "elona.chara_race_slime",
      shadow_type = "normal",
      show = true,
      uid = 1,
      y_offset = 0
   }

   map:memorize_tile(4, 5)
   Assert.same({ expected }, map:memory(4, 5, "base.chara"))

   map:memorize_tile(4, 5)
   Assert.same({ expected }, map:memory(4, 5, "base.chara"))
end
