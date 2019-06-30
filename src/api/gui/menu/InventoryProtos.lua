local Gui = require("api.Gui")
local Action = require("api.Action")
local ItemDescriptionMenu = require("api.gui.menu.ItemDescriptionMenu")
local Map = require("api.Map")

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
   icon = 6,
   on_select = function(ctxt, item, amount, rest)
      local list = rest:to_list()
      ItemDescriptionMenu:new(item, list):query()

      return "inventory_continue"
   end
}

InventoryProtos.inv_get = {
   sources = { "ground" },
   icon = 7,
   on_select = function(ctxt, item, amount)
      if not ctxt.chara:owns_item(item) then
         Gui.play_sound("base.fail1");
         Gui.mes("It's not yours.")
         return "turn_end"
      end

      local result = Action.get(ctxt.chara, item, amount)

      -- TODO: handle harvest action

      return "inventory_continue"
   end,

   after_filter = function(ctxt, filtered)
      if #filtered == 0 then
         return "player_turn_query"
      end
   end
}

InventoryProtos.inv_drop = {
   keybinds = {
      x = function(ctxt, item)
         if not ctxt.multi_drop then
            ctxt.multi_drop = true
         end
      end
   },

   sources = { "chara" },
   icon = 5,
   can_select = function(ctxt, item)
      if item:calc("flags").is_no_drop then
         return false, "marked as no drop"
      end

      if not Map.can_drop_items() and not item:has_type("base.furniture") then
         return false, "Map is full."
      end

      return true
   end,

   query_amount = true,

   on_select = function(ctxt, item, amount)
      Action.drop(ctxt.chara, item, amount)

      if ctxt.multi_drop then
         return "inventory_continue"
      end

      return "turn_end"
   end,

   on_menu_exit = function(ctxt)
      -- TODO: Ensure this is always called in multi-drop by
      -- restricting the menus that can be switched to when it is
      -- active, or in some other way.
      if ctxt.multi_drop then
         return "turn_end"
      end

      return "player_turn_query"
   end
}

InventoryProtos.inv_equip = {
   params = { body_part_id = "string" },
   sources = { "chara" },
   icon = 4,
   filter = function(ctxt, item)
      return item:can_equip_at(ctxt.body_part_id)
   end,
   can_select = function(ctxt, item)
      -- TODO: fairy trait
      -- return ctxt.chara:can_equip(item)
      return true
   end
}

local general_actions = {
   "inv_general",
   "inv_drop"
}

local multidrop_actions = {
   "inv_drop"
}

return InventoryProtos
