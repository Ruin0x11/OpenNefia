local Chara = require("api.Chara")
local Input = require("api.Input")
local Item = require("api.Item")
local Role = require("mod.elona_sys.api.Role")
local ShopInventory = require("mod.elona.api.ShopInventory")
local World = require("api.World")

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

local function refresh_shop(shopkeeper)
   local inv_id = shopkeeper.roles["elona.shopkeeper"].inventory_id
   shopkeeper.shop_inventory = ShopInventory.generate(inv_id, shopkeeper)

   -- TODO
   local restock_interval = 4
   shopkeeper.shop_restock_date = World.date():hours() + 24 * restock_interval

   shopkeeper:emit("elona.on_shop_restocked", {inventory_id=inv_id})
end

data:add {
   _type = "elona_sys.dialog",
   _id = "shopkeeper",

   root = "",
   nodes = {
      buy = function(t)
         if t.speaker.shop_inventory == nil
            or World.date():hours() >= t.speaker:calc("shop_restock_date")
         then
            refresh_shop(t.speaker)
         end

         Input.query_inventory(Chara.player(), "elona.inv_buy", {target=t.speaker, shop=t.speaker.shop_inventory})
         return "elona.default:talk"
      end,
      sell = function(t)
         Input.query_inventory(Chara.player(), "elona.inv_sell", {target=t.speaker})
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
