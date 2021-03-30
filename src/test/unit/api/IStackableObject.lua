local Item = require("api.Item")
local Assert = require("api.test.Assert")
local InstancedMap = require("api.InstancedMap")
local Chara = require("api.Chara")
local test_util = require("api.test.test_util")

function test_IStackableObject_separate__single()
   local item = test_util.stripped_item("elona.putitoro")
   Assert.eq(1, item.amount)

   local sep = item:separate()
   Assert.eq(1, sep.amount)
   Assert.eq(1, item.amount)
   Assert.eq(sep, item)
end

function test_IStackableObject_separate__multiple()
   local item = test_util.stripped_item("elona.putitoro", nil, nil, nil, 5)
   Assert.eq(5, item.amount)

   local sep = item:separate()
   Assert.eq(1, sep.amount)
   Assert.eq(4, item.amount)
   Assert.not_eq(sep, item)
   Assert.not_eq(item.uid, sep.uid)
   Assert.eq(item:get_location(), sep:get_location())
end

function test_IStackableObject_separate__amount()
   local item = test_util.stripped_item("elona.putitoro", nil, nil, nil, 5)
   Assert.eq(5, item.amount)

   local sep = item:separate(3)
   Assert.eq(3, sep.amount)
   Assert.eq(2, item.amount)
   Assert.not_eq(sep, item)
   Assert.not_eq(item.uid, sep.uid)
   Assert.eq(item:get_location(), sep:get_location())
end

function test_IStackableObject_separate__amount_exceeding()
   local item = test_util.stripped_item("elona.putitoro", nil, nil, nil, 5)
   Assert.eq(5, item.amount)

   local sep = item:separate(10)
   Assert.eq(5, sep.amount)
   Assert.eq(5, item.amount)
   Assert.eq(sep, item)
end

function test_IStackableObject_separate__same_location()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local item = test_util.stripped_item("elona.putitoro", map, 1, 1, 5)
   Assert.eq(5, item.amount)
   Assert.eq(map, item:get_location())

   local sep = item:separate()
   Assert.eq(map, sep:get_location())
   Assert.eq(item.location, sep.location)
   Assert.eq(item:get_location(), sep:get_location())
end

function test_IStackableObject_separate__events()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local item = test_util.stripped_item("elona.putitoro", nil, nil, nil, 5)

   local sep = item:separate()
   local result, id, name = item:compare_events(sep)

   Assert.eq(true, result, ("%s:%s"):format(id, name))
end

function test_IStackableObject_can_stack_with__nonobject()
   local item = test_util.stripped_item("elona.putitoro", nil, nil, nil, 5)
   Assert.eq(false, item:can_stack_with(1))
   Assert.eq(false, item:can_stack_with({}))
   Assert.eq(false, item:can_stack_with(function() end))
end

function test_IStackableObject_can_stack_with__self()
   local item = test_util.stripped_item("elona.putitoro", nil, nil, nil, 5)
   Assert.eq(false, item:can_stack_with(item))
end

function test_IStackableObject_can_stack_with__different_object_type()
   local item = test_util.stripped_item("elona.putitoro", nil, nil, nil, 5)
   local chara = Chara.create("elona.putit", nil, nil, {ownerless=true})
   Assert.eq(false, item:can_stack_with(chara))
end

function test_IStackableObject_can_stack_with__no_location()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local item_ownerless = test_util.stripped_item("elona.putitoro", nil, nil, nil, 5)
   local item_map = test_util.stripped_item("elona.putitoro", map, 1, 1, 5)

   Assert.eq(false, item_ownerless:can_stack_with(item_map))
   Assert.eq(false, item_map:can_stack_with(item_ownerless))
end

function test_IStackableObject_can_stack_with__different_location()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local item_ownerless = test_util.stripped_item("elona.putitoro", nil, nil, nil, 5)
   local chara = Chara.create("elona.putit", 1, 1, {}, map)
   local item_chara = test_util.stripped_item("elona.putitoro", chara, nil, nil, 5)

   Assert.eq(false, item_ownerless:can_stack_with(item_chara))
   Assert.eq(false, item_chara:can_stack_with(item_ownerless))
end

function test_IStackableObject_can_stack_with__different_id()
   local item_a = test_util.stripped_item("elona.putitoro")
   local item_b = test_util.stripped_item("elona.apple")

   Assert.eq(false, item_a:can_stack_with(item_b))
   Assert.eq(false, item_b:can_stack_with(item_b))
end

function test_IStackableObject_can_stack_with__separated()
   local item = test_util.stripped_item("elona.putitoro", nil, nil, nil, 5)
   local sep = item:separate(2)

   Assert.eq(true, item:can_stack_with(sep))
   Assert.eq(true, sep:can_stack_with(item))
end

function test_IStackableObject_can_stack_with__separated_in_map()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local item = test_util.stripped_item("elona.putitoro", map, 1, 1, 5)
   local sep = item:separate(2)

   Assert.eq(true, item:can_stack_with(sep))
   Assert.eq(true, sep:can_stack_with(item))
end

function test_IStackableObject_stack()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local item_a = test_util.stripped_item("elona.putitoro", map, 1, 1)
   local item_b = test_util.stripped_item("elona.putitoro", map, 1, 2)
   local item_c = test_util.stripped_item("elona.apple", map, 1, 3)
   item_b:set_pos(1, 1)
   item_c:set_pos(1, 1)

   Assert.eq(1, item_a.amount)
   Assert.eq(1, item_b.amount)
   Assert.eq(1, item_c.amount)

   item_b:stack()

   Assert.eq(0, item_a.amount)
   Assert.eq(2, item_b.amount)
   Assert.eq(1, item_c.amount)

   item_a:stack()

   Assert.eq(0, item_a.amount)
   Assert.eq(2, item_b.amount)
   Assert.eq(1, item_c.amount)
end

function test_IStackableObject_stack__chara()
   local chara = test_util.stripped_chara("elona.putit")

   local item_a = test_util.stripped_item("elona.putitoro", chara)
   local item_b = test_util.stripped_item("elona.putitoro", chara)
   local item_c = test_util.stripped_item("elona.apple", chara)

   item_b:stack()

   Assert.eq(0, item_a.amount)
   Assert.eq(2, item_b.amount)
   Assert.eq(1, item_c.amount)
end
