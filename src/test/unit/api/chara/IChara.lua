local InstancedMap = require("api.InstancedMap")
local Chara = require("api.Chara")
local Assert = require("api.test.Assert")
local StayingCharas = require("api.StayingCharas")
local save = require("internal.global.save")

function test_IChara_swap_places()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local player = Chara.create("base.player", 1, 2, {}, map)
   local ally = Chara.create("base.player", 3, 4, {}, map)

   Assert.eq(1, player.x)
   Assert.eq(2, player.y)
   Assert.eq(3, ally.x)
   Assert.eq(4, ally.y)

   player:swap_places(ally)
   Assert.eq(1, ally.x)
   Assert.eq(2, ally.y)
   Assert.eq(3, player.x)
   Assert.eq(4, player.y)

   ally:set_pos(0, 1)
   Assert.eq(nil, Chara.at(1, 2, map))
end

function test_IChara_kill__unregisters_staying()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local chara = Chara.create("base.player", 1, 2, {}, map)
   StayingCharas.register_global(chara, map)

   Assert.eq(map.uid, save.base.staying_charas:get_staying_map_for(chara).map_uid)

   chara:kill()

   Assert.eq(nil, save.base.staying_charas:get_staying_map_for(chara))
end

function test_IChara_vaniquish__unregisters_staying()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local chara = Chara.create("base.player", 1, 2, {}, map)
   StayingCharas.register_global(chara, map)

   Assert.eq(map.uid, save.base.staying_charas:get_staying_map_for(chara).map_uid)

   chara:vanquish()

   Assert.eq(nil, save.base.staying_charas:get_staying_map_for(chara))
end

function test_IChara_remove_ownership__unregisters_staying()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local chara = Chara.create("base.player", 1, 2, {}, map)
   StayingCharas.register_global(chara, map)

   Assert.eq(map.uid, save.base.staying_charas:get_staying_map_for(chara).map_uid)

   chara:remove_ownership()

   Assert.eq(nil, save.base.staying_charas:get_staying_map_for(chara))
end
