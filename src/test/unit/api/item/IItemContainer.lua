local Item = require("api.Item")
local Assert = require("api.test.Assert")
local InstancedMap = require("api.InstancedMap")

function test_IItemContainer_is_item_container__false()
   local putitoro = Item.create("elona.putitoro", nil, nil, {ownerless=true})
   Assert.eq(false, putitoro:is_item_container())
end

function test_IItemContainer_is_item_container__true()
   local shopkeepers_trunk = Item.create("elona.shopkeepers_trunk", nil, nil, {ownerless=true})
   Assert.eq(true, shopkeepers_trunk:is_item_container())
end

function test_IItemContainer_is_item_container__containing_map()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local shopkeepers_trunk = Item.create("elona.shopkeepers_trunk", 1, 2, {}, map)
   local putitoro = Item.create("elona.putitoro", nil, nil, {}, shopkeepers_trunk)

   Assert.is_truthy(putitoro)
   Assert.is_truthy(putitoro.location)
   Assert.eq(shopkeepers_trunk, putitoro:get_location())
   Assert.eq(true, shopkeepers_trunk:has_object(putitoro))
   Assert.eq(nil, putitoro:current_map())

   local containing_map, containing_obj, x, y = putitoro:containing_map()
   Assert.eq(map, containing_map)
   Assert.eq(shopkeepers_trunk, containing_obj)
   Assert.eq(1, x)
   Assert.eq(2, y)

   shopkeepers_trunk:remove_ownership()
   Assert.eq(nil, putitoro:current_map())
   Assert.eq(nil, putitoro:containing_map())
end
