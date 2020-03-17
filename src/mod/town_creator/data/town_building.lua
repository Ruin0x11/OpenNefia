local Chara = require("api.Chara")
local I18N = require("api.I18N")

data:add_type {
   name = "town_building",
   fields = {
      {
         name = "map",
         default = [[
###
#.#
###
]],
         template = true
      },
      {
         name = "atlas",
         default = {
            ["#"] = { map_tile = "elona.wall_brick_top" },
            ["."] = { map_tile = "elona.hardwood_floor_1" },
         }
      }
   }
}

data:add {
   _type = "town_creator.town_building",
   _id = "test",

   map = [[
#######
#.....#
#..x..#
#.....#
###=###
]],
   atlas = {
      ["."] = {
         map_tile = "elona.hardwood_floor_1"
      },
      ["#"] = {
         map_tile = "elona.wall_brick_top"
      },
      ["="] = {
         map_tile = "elona.hardwood_floor_1",
         objects = {
            {
               type = "feat",
               id = "elona.door"
            }
         }
      },
      ["x"] = {
         map_tile = "elona.hardwood_floor_1",
         on_create = function(x, y, map)
            local chara = Chara.create("elona.shopkeeper", x, y, nil, map)
            chara.roles["elona.shopkeeper"] = { inventory_id = "elona.general_vendor" }
            chara.shop_rank = 10
            chara.name = I18N.get("chara.job.general_vendor", chara.name)
         end
      }
   }
}
