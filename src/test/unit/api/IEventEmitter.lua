local Assert = require("api.test.Assert")
local Item = require("api.Item")

function test_IEventEmitter_has_event_handler()
   local item = Item.create("elona.putitoro", nil, nil, {ownerless=true})
   Assert.eq(false, item:has_event_handler("elona_sys.on_item_throw"))

   item:connect_self("elona_sys.on_item_throw", "Thrown event", function() end)
   Assert.eq(true, item:has_event_handler("elona_sys.on_item_throw"))
   Assert.eq(true, item:has_event_handler("elona_sys.on_item_throw", "Thrown event"))
   Assert.eq(false, item:has_event_handler("elona_sys.on_item_throw", "dood"))
   Assert.eq(false, item:has_event_handler("elona_sys.on_item_use"))
end

function test_IEventEmitter_has_event_handler__throws_if_invalid()
   local item = Item.create("elona.putitoro", nil, nil, {ownerless=true})

   Assert.throws_error(function() item:has_event_handler("dood") end, "Unknown event type \"dood\"")
end

function test_IEventEmitter_disconnect_self()
   local item = Item.create("elona.putitoro", nil, nil, {ownerless=true})
   Assert.eq(false, item:has_event_handler("elona_sys.on_item_throw"))

   item:connect_self("elona_sys.on_item_throw", "Thrown event", function() end)
   item:connect_self("elona_sys.on_item_throw", "Thrown event 2", function() end)

   item:disconnect_self("elona_sys.on_item_throw", "dood")
   Assert.eq(true, item:has_event_handler("elona_sys.on_item_throw"))
   Assert.eq(true, item:has_event_handler("elona_sys.on_item_throw", "Thrown event"))
   Assert.eq(true, item:has_event_handler("elona_sys.on_item_throw", "Thrown event 2"))

   item:disconnect_self("elona_sys.on_item_throw", "Thrown event")
   Assert.eq(true, item:has_event_handler("elona_sys.on_item_throw"))
   Assert.eq(false, item:has_event_handler("elona_sys.on_item_throw", "Thrown event"))
   Assert.eq(true, item:has_event_handler("elona_sys.on_item_throw", "Thrown event 2"))

   item:disconnect_self("elona_sys.on_item_throw", "Thrown event 2")
   Assert.eq(false, item:has_event_handler("elona_sys.on_item_throw"))
   Assert.eq(false, item:has_event_handler("elona_sys.on_item_throw", "Thrown event"))
   Assert.eq(false, item:has_event_handler("elona_sys.on_item_throw", "Thrown event 2"))
end
