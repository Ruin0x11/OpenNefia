local Chara = require("api.Chara")
local Gui = require("api.Gui")
local Ui = require("api.Ui")
local ElonaItem = require("mod.elona.api.ElonaItem")
local Calc = require("mod.elona.api.Calc")
local World = require("api.World")
local ShopInventory = require("mod.elona.api.ShopInventory")
local Input = require("api.Input")
local I18N = require("api.I18N")
local Dialog = require("mod.elona_sys.dialog.api.Dialog")

local function upgrade_cargo_limit(t, speaker, params)
   local player = Chara.player()
   local cost = params.cost
   local amount = math.floor(Calc.calc_cargo_limit_upgrade_amount(player))
   local small_medals = ElonaItem.find_small_medals(player)

   Gui.mes_newline()
   Gui.mes("talk.unique.miral.upgrade_cart.give.limit_increased", Ui.display_weight(amount))
   Gui.play_sound("base.build1")

   small_medals:remove(cost)
   player.max_cargo_weight = player.max_cargo_weight + amount
   player:refresh_weight()
end

data:add {
   _type = "elona_sys.dialog",
   _id = "miral",

   nodes = {
      __start = {
         text = "talk.unique.miral.dialog",
         choices = {
            {"small_medals", "talk.unique.miral.choices.small_medals"},
            {"upgrade_cart", "talk.unique.miral.choices.upgrade_cart"},
            {"__END__", "ui.bye"},
         }
      },
      small_medals = {
         text = "talk.unique.miral.small_medals",
         choices = {
            {"__start", "ui.more"},
         },
         on_finish = function(t)
            if t.speaker.shop_inventory == nil or World.date():hours() >= t.speaker.shop_restock_date then
               ShopInventory.refresh_shop(t.speaker, "elona.miral")
            end

            Input.query_inventory(Chara.player(), "elona.inv_buy_small_medals", {target=t.speaker, shop=t.speaker.shop_inventory})
         end
      },
      upgrade_cart = function(t)
         local params = {
            cost = math.floor(Calc.calc_cargo_limit_upgrade_cost(Chara.player()))
         }
         return { node_id = "upgrade_cart_confirm", params = params }
      end,
      upgrade_cart_confirm = {
         text = function(t, state, params)
            return {I18N.get("talk.unique.miral.upgrade_cart.dialog", params.cost)}
         end,
         choices = function(t, state, params)
            local choices = {}
            local small_medals = ElonaItem.find_small_medals(Chara.player())
            if small_medals ~= nil and small_medals.amount >= params.cost then
               Dialog.add_choice("upgrade_cart_give", "talk.unique.miral.upgrade_cart.choices.give", choices, params)
            end
            Dialog.add_choice("upgrade_cart_go_back", "talk.unique.miral.upgrade_cart.choices.go_back", choices)

            return choices
         end
      },
      upgrade_cart_go_back = {
         text = "talk.unique.miral.upgrade_cart.go_back",
         choices = {
            {"__start", "ui.more"},
         }
      },
      upgrade_cart_give = {
         on_start = upgrade_cargo_limit,
         text = "talk.unique.miral.upgrade_cart.give.dialog",
         choices = {
            {"__start", "ui.more"},
         },
      },
   }
}
