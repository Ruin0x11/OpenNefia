data:add_type {
   name = "bait",

   fields = {
      {
         name = "image",
         type = types.data_id("base.chip")
      },
      {
         name = "rank",
         type = types.uint,
      },
      {
         name = "value",
         type = types.uint
      }
   }
}

local function value(rank)
   return rank * rank * 500 + 200
end

data:add {
   _type = "elona.bait",
   _id = "water_flea",

   image = "elona.item_bait_water_flea",
   rank = 0,
   value = value(0)
}

data:add {
   _type = "elona.bait",
   _id = "grasshopper",

   image = "elona.item_bait_grasshopper",
   rank = 1,
   value = value(1)
}

data:add {
   _type = "elona.bait",
   _id = "ladybug",

   image = "elona.item_bait_ladybug",
   rank = 2,
   value = value(2)
}

data:add {
   _type = "elona.bait",
   _id = "dragonfly",

   image = "elona.item_bait_dragonfly",
   rank = 3,
   value = value(3)
}

data:add {
   _type = "elona.bait",
   _id = "locust",

   image = "elona.item_bait_locust",
   rank = 4,
   value = value(4)
}

data:add {
   _type = "elona.bait",
   _id = "beetle",

   image = "elona.item_bait_beetle",
   rank = 5,
   value = value(5)
}
