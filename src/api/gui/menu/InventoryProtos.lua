local Gui = require("api.Gui")
local ItemDescriptionMenu = require("api.gui.menu.ItemDescriptionMenu")

local InventoryProtos = {}

InventoryProtos.inv_general = {
   keybinds = {
      x = function(ctxt, item)
         item.flags.no_drop = not item.flags.no_drop
         print("nodrop toggle")
      end
   },

   sources = { "chara", "equipment", "ground" },
   shortcuts = true,
   sort = function(ctxt, a, b)
      return a.item._id > b.item._id
   end,
   on_select = function(ctxt, item, rest)
      local list = rest:to_list()
      ItemDescriptionMenu:new(item, list):query()

      return "inventory_continue"
   end
}

return InventoryProtos
