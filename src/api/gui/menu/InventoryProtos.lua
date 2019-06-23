local Gui = require("api.Gui")

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
   on_select = function(ctxt, item)
      -- ItemDescriptionMenu:new(item):query()
      Gui.mes(item.name)

      return "inventory_continue"
   end
}

return InventoryProtos
