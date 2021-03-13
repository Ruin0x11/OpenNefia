local Map = require("api.Map")
local Area = require("api.Area")
local Assert = require("api.test.Assert")
local Chara = require("api.Chara")
local StayingCharas = require("api.StayingCharas")

function test_Map_delete__removes_stayers()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")
   local ok, north_tyris_map = assert(north_tyris_area:load_or_generate_floor(north_tyris_area:starting_floor()))

   Assert.is_truthy(Map.save(north_tyris_map))

   local chara = Chara.create("elona.putit", nil, nil, nil, north_tyris_map)
   StayingCharas.register_global(chara, north_tyris_map)

   Assert.eq(north_tyris_map.uid, StayingCharas.get_staying_map_for_global(chara).map_uid)

   Assert.is_truthy(Map.delete(north_tyris_map.uid))

   Assert.eq(nil, StayingCharas.get_staying_map_for_global(chara))
end
