local utils = require("mod.test_room.data.map_archetype.utils")
local Chara = require("api.Chara")
local Const = require("api.Const")

local function generate_map(area, floor)
   local map = utils.create_map(20, 20)
   utils.create_stairs(2, 2, area, map)

   local x = 2
   local y = 4

   local chara = Chara.create("elona.shopkeeper", x, y, {}, map)
   chara:add_role("elona.maid")

   chara = Chara.create("elona.moyer_the_crooked", x + 1, y, {}, map)
   chara:add_role("elona.shopkeeper", { inventory_id = "elona.moyer" })

   chara = Chara.create("elona.shopkeeper", x + 2, y, {}, map)
   chara:add_role("elona.slaver")

   chara = Chara.create("elona.shopkeeper", x + 3, y, {}, map)
   chara.impression = Const.IMPRESSION_FELLOW
   chara.personality = 3

   chara = Chara.create("elona.prostitute", x + 4, y, {}, map)

   chara = Chara.create("elona.trainer", x + 5, y, {}, map)
   chara:add_role("elona.trainer")

   return map
end

return {
   talk = generate_map
}
