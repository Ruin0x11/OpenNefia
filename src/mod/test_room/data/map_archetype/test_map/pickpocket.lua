local utils = require("mod.test_room.data.map_archetype.utils")
local Chara = require("api.Chara")
local Item = require("api.Item")
local Skill = require("mod.elona_sys.api.Skill")
local Enum = require("api.Enum")

local pickpocket = {
   _id = "pickpocket"
}

function pickpocket.on_generate_map(area, floor)
   local map = utils.create_map(20, 20)
   utils.create_stairs(2, 2, area, map)

   local x = 2
   local y = 4

   local chara = Chara.create("elona.shopkeeper", x, y, {}, map)
   chara:add_role("elona.maid")
   local i = Item.create("elona.putitoro", nil, nil, {}, chara)
   i.own_state = Enum.OwnState.NotOwned
   i = Item.create("elona.zantetsu", nil, nil, {}, chara)
   i.own_state = Enum.OwnState.NotOwned

   chara = Chara.create("elona.moyer_the_crooked", x + 1, y, {}, map)
   chara:add_role("elona.shopkeeper", { inventory_id = "elona.moyer" })
   i = Item.create("elona.putitoro", nil, nil, {}, chara)
   i.own_state = Enum.OwnState.NotOwned
   chara:apply_effect("elona.sleep", 9999)

   chara = Chara.create("elona.guard", x + 2, y, {}, map)
   i = Item.create("elona.putitoro", nil, nil, {}, chara)
   i.own_state = Enum.OwnState.NotOwned
   chara:add_role("elona.guard")

   chara = Chara.create("elona.putit", x + 3, y, {}, map)
   i = Item.create("elona.putitoro", nil, nil, {}, chara)
   i.own_state = Enum.OwnState.NotOwned
   chara:add_role("elona.custom_chara")

   i = Item.create("elona.tree_of_beech", x, y + 2, {}, map)
   i.own_state = Enum.OwnState.NotOwned
   i = Item.create("elona.guillotine", x + 1, y + 2, {}, map)
   i.own_state = Enum.OwnState.NotOwned
   i = Item.create("elona.iron_maiden", x + 2, y + 2, {}, map)
   i.own_state = Enum.OwnState.NotOwned

   Skill.gain_skill(Chara.player(), "elona.pickpocket")

   return map
end

return pickpocket
