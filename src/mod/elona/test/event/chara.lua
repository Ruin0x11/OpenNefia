local Chara = require("api.Chara")
local Assert = require("api.test.Assert")
local test_util = require("api.test.test_util")
local InstancedMap = require("api.InstancedMap")
local StayingCharas = require("api.StayingCharas")
local Map = require("api.Map")
local InstancedArea = require("api.InstancedArea")
local Area = require("api.Area")

function test_chara_can_recruit_allies()
   local map = InstancedMap:new(10, 10)
   local chara = Chara.create("elona.putit", 10, 10, {}, map)
   local player = test_util.set_player(map)
   player:mod_base_skill_level("elona.stat_charisma", 1, "set")
   player:refresh()

   Assert.eq(true, player:can_recruit_allies())
   Assert.eq(false, chara:can_recruit_allies())

   Assert.is_truthy(player:recruit_as_ally(chara))

   Assert.eq(true, player:can_recruit_allies())

   local chara2 = Chara.create("elona.putit", 10, 10, {}, map)
   Assert.is_truthy(player:recruit_as_ally(chara2))

   Assert.eq(false, player:can_recruit_allies())

   local chara3 = Chara.create("elona.putit", 10, 10, {}, map)
   Assert.is_falsy(player:recruit_as_ally(chara3))
end

function test_chara_can_recruit_allies_stayers()
   local area_outside = InstancedArea:new()
   local outside = InstancedMap:new(10, 10)
   Area.register(area_outside, { parent = "root" })
   area_outside:add_floor(outside, 1)

   local map = InstancedMap:new(10, 10)
   local area = InstancedArea:new()
   Area.register(area, { parent = area_outside })
   area:add_floor(map, 1)
   local chara = Chara.create("elona.putit", 10, 10, {}, map)
   local player = test_util.set_player(map)
   player:mod_base_skill_level("elona.stat_charisma", 1, "set")
   player:refresh()
   Map.set_map(map)

   Assert.eq(true, player:can_recruit_allies())

   Assert.is_truthy(player:recruit_as_ally(chara))
   Assert.eq(true, player:can_recruit_allies())

   local chara2 = Chara.create("elona.putit", 10, 10, {}, map)
   Assert.is_truthy(player:recruit_as_ally(chara2))

   Assert.eq(2, player:iter_other_party_members(map):length())
   Assert.eq(false, player:can_recruit_allies())

   StayingCharas.register_global(chara, area, 1)
   StayingCharas.register_global(chara2, area, 1)

   Assert.is_truthy(Map.travel_to(outside))

   Assert.eq("Alive", chara.state)
   Assert.eq("Alive", chara2.state)
   Assert.eq(0, player:iter_other_party_members(map):length())
   Assert.eq(false, player:can_recruit_allies())

   Assert.is_truthy(Map.travel_to(map))

   Assert.eq("Alive", chara.state)
   Assert.eq("Alive", chara2.state)
   Assert.eq(2, player:iter_other_party_members(map):length())
   Assert.eq(false, player:can_recruit_allies())
end
