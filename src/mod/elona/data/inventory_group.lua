data:add {
   _type = "elona_sys.inventory_group",
   _id = "main",

   protos = {
      "elona.inv_examine",
      "elona.inv_drop",
      "elona.inv_eat",
      "elona.inv_read",
      "elona.inv_drink",
      "elona.inv_zap",
      "elona.inv_use",
      "elona.inv_open",
      "elona.inv_dip_source",
      "elona.inv_throw"
   }
}

data:add {
   _type = "elona_sys.inventory_group",
   _id = "world_map",

   protos = {
      "elona.inv_examine",
      "elona.inv_eat",
      "elona.inv_read",
      "elona.inv_drink",
      "elona.inv_use"
   }
}

data:add {
   _type = "elona_sys.inventory_group",
   _id = "ally",

   protos = {
      "elona.inv_give",
      "elona.inv_take"
   }
}

data:add {
   _type = "elona_sys.inventory_group",
   _id = "food_container",

   protos = {
      "elona.inv_take_food_container",
      "elona.inv_put_food_container"
   }
}

data:add {
   _type = "elona_sys.inventory_group",
   _id = "multidrop",

   protos = {
      "elona.inv_drop",
   }
}

data:add {
   _type = "elona_sys.inventory_group",
   _id = "container_four_dimensional_pocket",

   protos = {
      "elona.inv_get_four_dimensional_pocket",
      "elona.inv_put_four_dimensional_pocket"
   }
}
