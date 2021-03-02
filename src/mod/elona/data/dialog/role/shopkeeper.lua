local World = require("api.World")
local ShopInventory = require("mod.elona.api.ShopInventory")
local Input = require("api.Input")
local Chara = require("api.Chara")

data:add {
   _type = "elona_sys.dialog",
   _id = "shopkeeper",

   nodes = {
      buy = function(t)
         if t.speaker.shop_inventory == nil
            or World.date():hours() >= t.speaker.shop_restock_date
         then
            ShopInventory.refresh_shop(t.speaker)
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
