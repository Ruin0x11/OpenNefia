-- ├── ffhp
-- │   ├── item_133.bmp

-- ├── other
-- │   ├── item_354.bmp
-- │   ├── item_429.bmp
-- │   ├── item_470.bmp
-- │   ├── item_471.bmp
-- │   ├── 宝石で飾られた宝箱っぽい.bmp
-- │   ├── 巻物無地.bmp
-- │   ├── 弁当っぽい.bmp
-- │   └── 魔法書.bmp

data:add {
   _type = "base.theme",
   _id = "ceri_items",

   overrides = {
      {
         _type = "base.chip",
         _id = "elona.item_map",
         image = "mod/ceri_items/graphic/ffhp/item_133.bmp"
      },
      {
         _type = "base.chip",
         _id = "elona.item_potion",
         image = "mod/ceri_items/graphic/other/item_354.bmp"
      },
      {
         _type = "base.chip",
         _id = "elona.item_spellbook",
         image = "mod/ceri_items/graphic/other/item_429.bmp"
      },
      {
         _type = "base.chip",
         _id = "elona.item_scroll",
         image = "mod/ceri_items/graphic/other/item_470.bmp"
      },
      {
         _type = "base.chip",
         _id = "elona.item_rod",
         image = "mod/ceri_items/graphic/other/item_471.bmp"
      },
   }
}
