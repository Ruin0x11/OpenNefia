local Servant = require("mod.elona.api.Servant")
local Chara = require("api.Chara")
local Assert = require("api.test.Assert")
local Area = require("api.Area")
local Map = require("api.Map")
local TestUtil = require("api.test.TestUtil")

function test_Servant_calc_wage_cost()
   local maid = Chara.create("elona.maid", nil, nil, {ownerless=true})

   Assert.eq(0, Servant.calc_wage_cost(maid))

   maid:add_role("elona.maid")
   Assert.eq(450, Servant.calc_wage_cost(maid))

   maid:add_role("elona.trainer")
   Assert.eq(700, Servant.calc_wage_cost(maid))
end

function test_Servant_calc_wage_cost__shopkeeper()
   local shopkeeper = Chara.create("elona.shopkeeper", nil, nil, {ownerless=true})

   Assert.eq(0, Servant.calc_wage_cost(shopkeeper))

   shopkeeper:add_role("elona.shopkeeper", { inventory_id = "elona.goods_vendor" })
   Assert.eq(1000, Servant.calc_wage_cost(shopkeeper))

   shopkeeper:add_role("elona.shopkeeper", { inventory_id = "elona.blackmarket" })
   Assert.eq(5000, Servant.calc_wage_cost(shopkeeper))
end

function test_Servant_is_servant()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")

   local your_home_area = Area.create_unique("elona.your_home", north_tyris_area)
   local ok, first_floor = your_home_area:load_or_generate_floor(your_home_area:starting_floor())

   local shopkeeper = Chara.create("elona.shopkeeper", nil, nil, {ownerless=true})

   Assert.eq(false, Servant.is_servant(shopkeeper))

   Assert.is_truthy(Map.try_place_chara(shopkeeper, nil, nil, first_floor))
   Assert.eq(false, Servant.is_servant(shopkeeper))

   shopkeeper:add_role("elona.shopkeeper", { inventory_id = "elona.goods_vendor" })
   Assert.eq(true, Servant.is_servant(shopkeeper))
end

function test_Servant_is_servant__story_charas()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")

   local your_home_area = Area.create_unique("elona.your_home", north_tyris_area)
   local ok, first_floor = your_home_area:load_or_generate_floor(your_home_area:starting_floor())

   local lomias = Chara.create("elona.lomias", 5, 5, {}, first_floor)
   local larnneire = Chara.create("elona.larnneire", 5, 6, {}, first_floor)

   Assert.eq(false, Servant.is_servant(lomias))
   Assert.eq(false, Servant.is_servant(larnneire))
end

function test_Servant_calc_max_servant_limit()
   Assert.eq(2, Servant.calc_max_servant_limit())

   save.elona.home_rank = "elona.small_castle"
   Assert.eq(7, Servant.calc_max_servant_limit())
end

function test_Servant_calc_total_labor_expenses()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")

   local your_home_area = Area.create_unique("elona.your_home", north_tyris_area)
   local ok, first_floor = your_home_area:load_or_generate_floor(your_home_area:starting_floor())

   local player = TestUtil.set_player(first_floor)

   player.karma = 0

   Assert.eq(0, Servant.calc_total_labor_expenses(first_floor))

   local shopkeeper = Chara.create("elona.shopkeeper", nil, nil, {ownerless=true})
   Assert.is_truthy(Map.try_place_chara(shopkeeper, nil, nil, first_floor))
   shopkeeper:add_role("elona.shopkeeper", { inventory_id = "elona.goods_vendor" })

   Assert.eq(500, Servant.calc_total_labor_expenses(first_floor))

   local maid = Chara.create("elona.maid", nil, nil, {ownerless=true})
   Assert.is_truthy(Map.try_place_chara(maid, nil, nil, first_floor))
   maid:add_role("elona.maid")

   Assert.eq(725, Servant.calc_total_labor_expenses(first_floor))

   player.karma = 30
   Assert.eq(652, Servant.calc_total_labor_expenses(first_floor))

   player:modify_trait_level("elona.tax", 1)
   Assert.eq(551, Servant.calc_total_labor_expenses(first_floor))
end
