local Item = require("api.Item")
local Assert = require("api.test.Assert")
local InstancedMap = require("api.InstancedMap")
local Chara = require("api.Chara")

function test_IStackableObject_separate__single()
   local item = Item.create("elona.putitoro", nil, nil, {amount=1,ownerless=true})
   Assert.eq(1, item.amount)

   local sep = item:separate()
   Assert.eq(1, sep.amount)
   Assert.eq(1, item.amount)
   Assert.eq(sep, item)
end

function test_IStackableObject_separate__multiple()
   local item = Item.create("elona.putitoro", nil, nil, {amount=5,ownerless=true})
   Assert.eq(5, item.amount)

   local sep = item:separate()
   Assert.eq(1, sep.amount)
   Assert.eq(4, item.amount)
   Assert.not_eq(sep, item)
   Assert.not_eq(item.uid, sep.uid)
   Assert.eq(item:get_location(), sep:get_location())
end

function test_IStackableObject_separate__amount()
   local item = Item.create("elona.putitoro", nil, nil, {amount=5,ownerless=true})
   Assert.eq(5, item.amount)

   local sep = item:separate(3)
   Assert.eq(3, sep.amount)
   Assert.eq(2, item.amount)
   Assert.not_eq(sep, item)
   Assert.not_eq(item.uid, sep.uid)
   Assert.eq(item:get_location(), sep:get_location())
end

function test_IStackableObject_separate__amount_exceeding()
   local item = Item.create("elona.putitoro", nil, nil, {amount=5,ownerless=true})
   Assert.eq(5, item.amount)

   local sep = item:separate(10)
   Assert.eq(5, sep.amount)
   Assert.eq(5, item.amount)
   Assert.eq(sep, item)
end

function test_IStackableObject_can_stack_with__nonobject()
   local item = Item.create("elona.putitoro", nil, nil, {amount=5,ownerless=true})
   Assert.eq(false, item:can_stack_with(1))
   Assert.eq(false, item:can_stack_with({}))
   Assert.eq(false, item:can_stack_with(function() end))
end

function test_IStackableObject_can_stack_with__self()
   local item = Item.create("elona.putitoro", nil, nil, {amount=5,ownerless=true})
   Assert.eq(false, item:can_stack_with(item))
end

function test_IStackableObject_can_stack_with__different_object_type()
   local item = Item.create("elona.putitoro", nil, nil, {amount=5,ownerless=true})
   local chara = Chara.create("elona.putit", nil, nil, {ownerless=true})
   Assert.eq(false, item:can_stack_with(chara))
end

function test_IStackableObject_can_stack_with__no_location()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local item_ownerless = Item.create("elona.putitoro", nil, nil, {amount=5,ownerless=true})
   local item_map = Item.create("elona.putitoro", 1, 1, {amount=5}, map)

   Assert.eq(false, item_ownerless:can_stack_with(item_map))
   Assert.eq(false, item_map:can_stack_with(item_ownerless))
end

function test_IStackableObject_can_stack_with__different_location()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local item_ownerless = Item.create("elona.putitoro", nil, nil, {amount=5,ownerless=true})
   local chara = Chara.create("elona.putit", 1, 1, {}, map)
   local item_chara = Item.create("elona.putitoro", nil, nil, {amount=5}, chara)

   Assert.eq(false, item_ownerless:can_stack_with(item_chara))
   Assert.eq(false, item_chara:can_stack_with(item_ownerless))
end

function test_IStackableObject_separate__same_location()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local item = Item.create("elona.putitoro", nil, nil, {amount=5}, map)
   Assert.eq(5, item.amount)
   Assert.eq(map, item:get_location())

   local sep = item:separate()
   Assert.eq(map, sep:get_location())
   Assert.eq(item.location, sep.location)
   Assert.eq(item:get_location(), sep:get_location())
end

disable("Bug #119")
function test_IStackableObject_can_stack_with__separated()
   local item = Item.create("elona.putitoro", nil, nil, {amount=5,ownerless=true})
   local sep = item:separate(2)

   Assert.eq(true, item:can_stack_with(sep))
   Assert.eq(true, sep:can_stack_with(item))
end

disable("Bug #119")
function test_IStackableObject_can_stack_with__separated_in_map()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local item = Item.create("elona.putitoro", 1, 1, {amount=5}, map)
   local sep = item:separate(2)

   Assert.eq(true, item:can_stack_with(sep))
   Assert.eq(true, sep:can_stack_with(item))
end
