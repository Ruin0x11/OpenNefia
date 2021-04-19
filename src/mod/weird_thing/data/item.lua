local IItemFood = require("mod.elona.api.aspect.IItemFood")
local IItemSeed = require("mod.elona.api.aspect.IItemSeed")
local IItemFromChara = require("mod.elona.api.aspect.IItemFromChara")
local IItemCargo = require("mod.elona.api.aspect.IItemCargo")
local IItemMuseumValued = require("mod.elona.api.aspect.IItemMuseumValued")
local IItemBlacksmithHammer = require("mod.smithing.api.aspect.IItemBlacksmithHammer")
local Gui = require("api.Gui")
local Item = require("api.Item")
local Rand = require("api.Rand")
local IItemEquipment = require("mod.elona.api.aspect.IItemEquipment")
local IItemMeleeWeapon = require("mod.elona.api.aspect.IItemMeleeWeapon")
local IItemRangedWeapon = require("mod.elona.api.aspect.IItemRangedWeapon")
local IItemAmmo = require("mod.elona.api.aspect.IItemAmmo")
local IItemMonsterBall = require("mod.elona.api.aspect.IItemMonsterBall")

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
      -- [IItemCargo] = {
      --    cargo_weight = 1000,
      --    cargo_quality = 10
      -- },
      [IItemMuseumValued] = {
         museum_value = 100
      },
      [IItemBlacksmithHammer] = {},
      [IItemEquipment] = {
         dv = 10,
         pv = 10,
         hit_bonus = 10,
         damage_bonus = 10,
         equip_slots = { "elona.hand", "elona.arm", "elona.back", "elona.ranged", "elona.ammo" },
         pcc_part = 1
      },
      [IItemMeleeWeapon] = {
         skill = "elona.long_sword",
         dice_x = 20,
         dice_y = 20,
         pierce_rate = 50,
      },
      [IItemRangedWeapon] = {
         skill = "elona.firearm",
         dice_x = 10,
         dice_y = 10,
         effective_range = { 50, 90, 100, 90, 80, 80, 70, 60, 50, 20 },
         pierce_rate = 20,
      },
      [IItemAmmo] = {
         skill = "elona.firearm",
         dice_x = 10,
         dice_y = 10,
      },
      IItemMonsterBall
   }
}
