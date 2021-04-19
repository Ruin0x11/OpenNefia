local ItemMaterial = require("mod.elona.api.ItemMaterial")
local Rand = require("api.Rand")
local IItemMeleeWeapon = require("mod.elona.api.aspect.IItemMeleeWeapon")
local IItemRangedWeapon = require("mod.elona.api.aspect.IItemRangedWeapon")
local IItemAmmo = require("mod.elona.api.aspect.IItemAmmo")
local TestUtil = require("api.test.TestUtil")
local Assert = require("api.test.Assert")
local IItemEquipment = require("mod.elona.api.aspect.IItemEquipment")

function test_ItemMaterial_apply_item_material__aspect_equip()
   local item = TestUtil.stripped_item("elona.gloves")

   Assert.eq(5, item:calc_aspect(IItemEquipment, "hit_bonus"))
   Assert.eq(1, item:calc_aspect(IItemEquipment, "damage_bonus"))
   Assert.eq(5, item:calc_aspect(IItemEquipment, "dv"))
   Assert.eq(4, item:calc_aspect(IItemEquipment, "pv"))

   Rand.set_seed(0)
   ItemMaterial.change_item_material(item, "elona.titanium")

   Assert.eq(7, item:calc_aspect(IItemEquipment, "hit_bonus"))
   Assert.eq(0, item:calc_aspect(IItemEquipment, "damage_bonus"))
   Assert.eq(5, item:calc_aspect(IItemEquipment, "dv"))
   Assert.eq(6, item:calc_aspect(IItemEquipment, "pv"))

   ItemMaterial.change_item_material(item, nil)

   Assert.eq(5, item:calc_aspect(IItemEquipment, "hit_bonus"))
   Assert.eq(1, item:calc_aspect(IItemEquipment, "damage_bonus"))
   Assert.eq(5, item:calc_aspect(IItemEquipment, "dv"))
   Assert.eq(4, item:calc_aspect(IItemEquipment, "pv"))
end

function test_ItemMaterial_apply_item_material__aspect_dice()
   data:add {
      _type = "base.item",
      _id = "material_aspects",

      _ext = {
         [IItemMeleeWeapon] = {
            dice_y = 10
         },
         [IItemRangedWeapon] = {
            dice_y = 20
         },
         [IItemAmmo] = {
            dice_y = 30
         }
      }
   }

   local item = TestUtil.stripped_item("@test@.material_aspects")

   Assert.eq(10, item:calc_aspect(IItemMeleeWeapon, "dice_y"))
   Assert.eq(20, item:calc_aspect(IItemRangedWeapon, "dice_y"))
   Assert.eq(30, item:calc_aspect(IItemAmmo, "dice_y"))

   Rand.set_seed(0)
   ItemMaterial.change_item_material(item, "elona.titanium")

   Assert.eq(13, item:calc_aspect(IItemMeleeWeapon, "dice_y"))
   Assert.eq(27, item:calc_aspect(IItemRangedWeapon, "dice_y"))
   Assert.eq(42, item:calc_aspect(IItemAmmo, "dice_y"))

   ItemMaterial.change_item_material(item, nil)

   Assert.eq(10, item:calc_aspect(IItemMeleeWeapon, "dice_y"))
   Assert.eq(20, item:calc_aspect(IItemRangedWeapon, "dice_y"))
   Assert.eq(30, item:calc_aspect(IItemAmmo, "dice_y"))
end
