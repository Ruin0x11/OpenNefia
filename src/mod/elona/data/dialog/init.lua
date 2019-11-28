local Chara = require("api.Chara")
local Input = require("api.Input")
local Item = require("api.Item")
local Role = require("mod.elona_sys.api.Role")
local ShopInventory = require("mod.elona.api.ShopInventory")

data:add {
   _type = "elona_sys.dialog",
   _id = "default",

   root = "",
   nodes = {
      __start = {
         text = {
            {"dialog"}
         },
         choices = function(t)
            local choices = t.speaker:emit("elona.calc_dialog_choices", {}, {})

            table.insert(choices, {"__END__", "__BYE__"})

            return choices
         end
      },
      talk = {
         text = {
            {"talk"}
         },
         choices = "__start"
      },
   },
}

data:add {
   _type = "elona_sys.dialog",
   _id = "shopkeeper",

   root = "",
   nodes = {
      buy = function(t)
         local inv_id = Role.get(t.speaker, "elona.shopkeeper").params.inventory_id
         local shop = ShopInventory.generate(inv_id, t.speaker)

         Input.query_inventory(Chara.player(), "inv_buy", {target=t.speaker, shop=shop})
         return "elona.default:talk"
      end,
      sell = function(t)
         Input.query_inventory(Chara.player(), "inv_sell", {target=t.speaker})
         return "elona.default:talk"
      end,
   }
}

data:add {
   _type = "elona_sys.dialog",
   _id = "guard",

   root = "",
   nodes = {
      where_is = function(t)
         return "elona.default:talk"
      end,
      lost_item = function(t)
         return "elona.default:talk"
      end,
   }
}

require("mod.elona.data.dialog.unique.miches")
require("mod.elona.data.dialog.unique.larnneire")
require("mod.elona.data.dialog.unique.lomias")
require("mod.elona.data.dialog.unique.rilian")
