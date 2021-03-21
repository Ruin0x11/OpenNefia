local Item = require("api.Item")
local Action = require("api.Action")
local Chara = require("api.Chara")
local Assert = require("api.test.Assert")
local World = require("api.World")

function test_container_combine_weight()
   local item = Item.create("elona.cooler_box", nil, nil, {ownerless=true})
   local putitoro = Item.create("elona.putitoro", nil, nil, {ownerless=true})

   Assert.eq(2500, item.weight)

   Action.put_in_container(item.inv, putitoro, 1, item)

   Assert.eq(2700, item.weight)

   local chara = Chara.create("elona.putit", nil, nil, {ownerless=true})
   Action.take_from_container(chara, putitoro, 1, item)

   Assert.eq(2500, item.weight)
end

function test_cooler_box()
   local item = Item.create("elona.cooler_box", nil, nil, {ownerless=true})
   local grape = Item.create("elona.grape", nil, nil, {ownerless=true})

   local date1 = World.date_hours()
   Assert.eq(date1 + grape.spoilage_hours, grape.spoilage_date)

   Action.put_in_container(item.inv, grape, 1, item)
   Assert.eq(0, grape.spoilage_date)

   World.pass_time_in_seconds(60 * 60 * 24 * 7)

   local chara = Chara.create("elona.putit", nil, nil, {ownerless=true})
   Action.take_from_container(chara, grape, 1, item)

   local date2 = World.date_hours()
   Assert.eq(date1 + 24 * 7, date2)
   Assert.eq(date2 + grape.spoilage_hours, grape.spoilage_date)
end
