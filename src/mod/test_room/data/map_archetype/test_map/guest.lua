local utils = require("mod.test_room.data.map_archetype.utils")
local Chara = require("api.Chara")
local Item = require("api.Item")
local IItemChair = require("mod.elona.api.aspect.IItemChair")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local Effect = require("mod.elona.api.Effect")

local guest = {
   _id = "guest"
}

function guest.on_generate_map(area, floor)
   local map = utils.create_map(20, 20)
   utils.create_stairs(2, 2, area, map)

   local maid = Chara.create("elona.maid", 5, 2, {}, map)
   maid:add_role("elona.maid")

   Item.create("elona.modern_chair", 5, 5, {aspects={[IItemChair]={chair_type="my"}}}, map)
   Item.create("elona.modern_chair", 7, 5, {aspects={[IItemChair]={chair_type="guest"}}}, map)
   Item.create("elona.modern_chair", 6, 4, {aspects={[IItemChair]={chair_type="ally"}}}, map)
   Item.create("elona.modern_chair", 6, 6, {aspects={[IItemChair]={chair_type="free"}}}, map)

   return map
end

function guest.on_map_entered(map)
   save.elona.waiting_guests = 100
   DeferredEvent.add(function()
         local maid = Chara.find("elona.maid", "others", map)
         if maid then
            Effect.try_to_chat(maid, Chara.player(), false, "elona.maid:meet_guest_prompt")
         end
   end)
end

return guest
