local IItemBlacksmithHammer = require("mod.smithing.api.aspect.IItemBlacksmithHammer")

data:add {
   _type = "base.item",
   _id = "blacksmith_hammer",
   custom_author = "名も知れぬ鍛冶屋",

   image = "smithing.blacksmith_hammer",
   level = 1,
   rarity = 1000000,
   value = 75,
   weight = 5000,
   tags = { "nodownload" },
   categories = { "elona.misc_item" },

   _ext = {
      IItemBlacksmithHammer
   }
}
