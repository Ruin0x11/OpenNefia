--
-- Remains
--
local IItemFromChara = require("mod.elona.api.aspect.IItemFromChara")
local IItemMuseumValued = require("mod.elona.api.aspect.IItemMuseumValued")
local ItemMuseumValuedFigureAspect = require("mod.elona.api.aspect.ItemMuseumValuedFigureAspect")
local ItemMuseumValuedCardAspect = require("mod.elona.api.aspect.ItemMuseumValuedCardAspect")

data:add {
   _type = "base.item",
   _id = "remains_skin",
   elona_id = 337,
   image = "elona.item_rabbits_tail",
   value = 100,
   weight = 1500,
   coefficient = 100,
   categories = {
      "elona.remains"
   },
   _ext = {
      IItemFromChara
   }
}

data:add {
   _type = "base.item",
   _id = "remains_blood",
   elona_id = 338,
   image = "elona.item_remains_blood",
   value = 100,
   weight = 1500,
   rarity = 200000,
   coefficient = 100,
   categories = {
      "elona.remains"
   },
   _ext = {
      IItemFromChara
   }
}

data:add {
   _type = "base.item",
   _id = "remains_eye",
   elona_id = 339,
   image = "elona.item_remains_eye",
   value = 100,
   weight = 1500,
   rarity = 400000,
   coefficient = 100,
   categories = {
      "elona.remains"
   },
   _ext = {
      IItemFromChara
   }
}

data:add {
   _type = "base.item",
   _id = "remains_heart",
   elona_id = 340,
   image = "elona.item_remains_heart",
   value = 100,
   weight = 1500,
   rarity = 100000,
   coefficient = 100,
   categories = {
      "elona.remains"
   },
   _ext = {
      IItemFromChara
   }
}

data:add {
   _type = "base.item",
   _id = "remains_bone",
   elona_id = 341,
   image = "elona.item_remains_bone",
   value = 100,
   weight = 1500,
   coefficient = 100,
   categories = {
      "elona.remains"
   },
   _ext = {
      IItemFromChara
   }
}

--
-- Card/Figure
--

data:add {
   _type = "base.item",
   _id = "figurine",
   elona_id = 503,
   image = "elona.item_figurine",
   value = 1000,
   weight = 2500,
   fltselect = 1,
   rarity = 100000,
   coefficient = 100,
   categories = {
      "elona.remains",
      "elona.no_generate"
   },
   _ext = {
      IItemFromChara,
      [IItemMuseumValued] = {
         _impl = ItemMuseumValuedFigureAspect
      }
   }
}

data:add {
   _type = "base.item",
   _id = "card",
   elona_id = 504,
   image = "elona.item_card",
   value = 500,
   weight = 200,
   fltselect = 1,
   rarity = 100000,
   coefficient = 100,
   categories = {
      "elona.remains",
      "elona.no_generate"
   },
   _ext = {
      IItemFromChara,
      [IItemMuseumValued] = {
         _impl = ItemMuseumValuedCardAspect
      }
   }
}
