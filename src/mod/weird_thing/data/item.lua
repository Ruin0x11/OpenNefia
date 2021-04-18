local IItemFood = require("mod.elona.api.aspect.IItemFood")
local IItemSeed = require("mod.elona.api.aspect.IItemSeed")
local IItemFromChara = require("mod.elona.api.aspect.IItemFromChara")
local IItemCargo = require("mod.elona.api.aspect.IItemCargo")
local IItemMuseumValued = require("mod.elona.api.aspect.IItemMuseumValued")
local IItemBlacksmithHammer = require("mod.smithing.api.aspect.IItemBlacksmithHammer")
local Gui = require("api.Gui")
local Item = require("api.Item")
local Rand = require("api.Rand")

data:add {
   _type = "elona.plant",
   _id = "weird",

   growth_difficulty = 10,
   regrowth_difficulty = 15,

   on_harvest = function(plant, params)
      local item = Item.create("weird_thing.weird_thing", plant.x, plant.y, {amount=Rand.rnd(4)+1,no_stack=true}, params.chara)
      Gui.mes("action.plant.harvest", item:build_name())
      item:stack(true)
   end
}

data:add {
   _type = "base.item",
   _id = "weird_thing",

   image = "elona.item_moonfish",
   value = 100000,
   weight = 40,
   rarity = 1000000,
   coefficient = 100,

   tags = { "noshop", "spshop" },
   color = { 0, 90, 128 },

   categories = {
      "elona.tag_noshop",
      "elona.tag_spshop",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.meat"
      },
      [IItemSeed] = {
         plant_id = "weird_thing.weird"
      },
      [IItemFromChara] = {
         chara_id = "elona.gwen"
      },
      [IItemCargo] = {
         cargo_weight = 1000,
         cargo_quality = 10
      },
      [IItemMuseumValued] = {
         museum_value = 100
      },
      [IItemBlacksmithHammer] = {}
   }
}
