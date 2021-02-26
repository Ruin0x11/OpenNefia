local InstancedMap = require("api.InstancedMap")
local Chara = require("api.Chara")
local Assert = require("api.test.Assert")

function test_IMapObject_set_pos()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   Assert.eq(0, map:iter_type_at_pos("base.chara", 1, 2):length())
   Assert.eq(0, map:iter_type_at_pos("base.chara", 3, 4):length())

   local obj = Chara.create("elona.putit", 1, 2, {}, map)
   Assert.eq(1, map:iter_type_at_pos("base.chara", 1, 2):length())
   Assert.eq(0, map:iter_type_at_pos("base.chara", 3, 4):length())
   Assert.eq(1, obj.x)
   Assert.eq(2, obj.y)

   obj:set_pos(3, 4)
   Assert.eq(0, map:iter_type_at_pos("base.chara", 1, 2):length())
   Assert.eq(1, map:iter_type_at_pos("base.chara", 3, 4):length())
   Assert.eq(3, obj.x)
   Assert.eq(4, obj.y)

   obj:remove_ownership()
   Assert.eq(0, map:iter_type_at_pos("base.chara", 1, 2):length())
   Assert.eq(0, map:iter_type_at_pos("base.chara", 3, 4):length())
end
