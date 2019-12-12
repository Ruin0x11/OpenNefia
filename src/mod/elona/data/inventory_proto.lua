local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Action = require("api.Action")
local Input = require("api.Input")
local ElonaCommand = require("mod.elona.api.ElonaCommand")
local ElonaAction = require("mod.elona.api.ElonaAction")
local ItemDescriptionMenu = require("api.gui.menu.ItemDescriptionMenu")
local Map = require("api.Map")

local inv_general = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_general",

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
data:add(inv_general)

local inv_get = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_get",

   sources = { "ground" },
   icon = 7,
   on_select = function(ctxt, item, amount)
      if not ctxt.chara:owns_item(item) then
         Gui.play_sound("base.fail1");
         Gui.mes("It's not yours.")
         return "turn_end"
      end

      local result = Action.get(ctxt.chara, item, amount)

      if result then
         Gui.mes("action.pick_up.execute", ctxt.chara, item:build_name(amount))
         Gui.play_sound(Rand.choice({"base.get1", "base.get2"}), ctxt.chara.x, ctxt.chara.y)
      end

      -- TODO: handle harvest action

      return "inventory_continue"
   end,

   after_filter = function(ctxt, filtered)
      if #filtered == 0 then
         return "player_turn_query"
      end
   end
}
data:add(inv_get)

local inv_drop = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_drop",

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
data:add(inv_drop)

local inv_equip = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_equip",

   params = { body_part_id = "string" },
   sources = { "chara" },
   icon = 4,
   filter = function(ctxt, item)
      return item:can_equip_at(ctxt.body_part_id)
   end,
   can_select = function(ctxt, item)
      if ctxt.chara:has_trait("elona.fairy_equip_restriction") and item:calc("weight") >= 1000 then
         Gui.mes("ui.inv.equip.too_heavy")
         return false, "too heavy"
      end

      return true
   end
}
data:add(inv_equip)

local inv_read = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_read",

   sources = { "chara", "ground" },
   shortcuts = true,
   icon = 4,
   filter = function(ctxt, item)
      if not item:has_event_handler("elona_sys.on_item_read") then
         return false
      end

      if ctxt.chara:current_map():has_type("world_map") then
         if not (item:has_category("elona.scroll_deed") or item:calc("can_read_in_world_map")) then
            return false
         end
      end

      return true
   end,
   on_select = function(ctxt, item)
      return ElonaAction.read(ctxt.chara, item)
   end
}
data:add(inv_read)

local inv_eat = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_eat",

   sources = { "chara", "equipment", "ground" },
   shortcuts = true,
   icon = 5,
   filter = function(ctxt, item)
      return item:has_category("elona.food")
         or item:has_category("elona.cargo_food")
         or item:calc("material") == "elona.raw"
         or item:has_event_handler("elona_sys.on_item_eat")
   end,
   can_select = function(ctxt, item)
      if item:calc("flags").is_no_drop then
         return false, "marked as no drop"
      end

      return true
   end,
   on_select = function(ctxt, item)
      return ElonaAction.eat(ctxt.chara, item)
   end
}
data:add(inv_eat)

local inv_drink = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_drink",

   sources = { "chara", "ground" },
   shortcuts = true,
   icon = 6,
   filter = function(ctxt, item)
      return item:has_event_handler("elona_sys.on_item_drink")
   end,
   on_select = function(ctxt, item)
      return ElonaAction.drink(ctxt.chara, item)
   end
}
data:add(inv_drink)

local inv_zap = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_zap",

   sources = { "chara", "ground" },
   shortcuts = true,
   icon = 6,
   filter = function(ctxt, item)
      return item:has_event_handler("elona_sys.on_item_zap")
   end,
   on_select = function(ctxt, item)
      return ElonaAction.zap(ctxt.chara, item)
   end
}
data:add(inv_zap)

local inv_buy = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_buy",

   sources = { "shop" },
   shortcuts = false,
   icon = 6,
   query_amount = true,
   show_money = true,
   can_select = function(ctxt, item)
      if item:calc("flags").is_no_drop then
         return false, "marked as no drop"
      end

      return true
   end,
   on_select = function(ctxt, item, amount)
      if not Input.yes_no("Really buy?") then
         return "inventory_continue"
      end

      local cost = item:calc("value") * amount

      if cost > ctxt.chara.gold then -- TODO
         Gui.mes("not enough money")
         return "inventory_continue"
      end

      local separated = Action.get(ctxt.chara, item, amount)
      if not separated then
         Gui.mes("inventory is full")
         return "inventory_continue"
      end

      Gui.mes(ctxt.chara.uid .. " buys " .. item:build_name(amount))
      Gui.play_sound("base.paygold1", ctxt.chara.x, ctxt.chara.y)
      ctxt.chara.gold = ctxt.chara.gold - cost
      ctxt.target.gold = ctxt.target.gold + cost

      return "inventory_continue"
   end
}
data:add(inv_buy)

local inv_sell = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_sell",

   sources = { "chara" },
   shortcuts = false,
   icon = 7,
   query_amount = true,
   show_money = true,
   can_select = function(ctxt, item)
      if item:calc("flags").is_no_drop then
         return false, "marked as no drop"
      end

      return true
   end,
   on_select = function(ctxt, item, amount)
      if not Input.yes_no("Really sell?") then
         return "inventory_continue"
      end

      local cost = math.floor((item:calc("value") * amount) / 5)

      if cost > ctxt.target.gold then -- TODO
         Gui.mes("shopkeeper doesn't have enough money")
         return "inventory_continue"
      end

      local separated = Action.get(ctxt.target, item, amount)
      if not separated then
         Gui.mes("shopkeeper's inventory is full")
         return "inventory_continue"
      end

      Gui.mes(ctxt.chara.uid .. " sells " .. item:build_name(amount))
      Gui.play_sound("base.getgold1", ctxt.chara.x, ctxt.chara.y)
      ctxt.target.gold = ctxt.target.gold - cost
      ctxt.chara.gold = ctxt.chara.gold + cost

      separated.own_state = "none"
      separated.identify_state = "completely"

      return "inventory_continue"
   end
}
data:add(inv_sell)

local inv_steal = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_steal",

   sources = { "target" },
   icon = 7,
   show_money = true,
   after_filter = function(ctxt, filtered)
      if #filtered == 0 then
         Gui.mes("ui.inv.steal.has_nothing", ctxt.target)
         return "player_turn_query"
      end
      if ctxt.target:is_ally() then
         Gui.mes("ui.inv.steal.do_not_rob_ally")
         return "player_turn_query"
      end
   end,
   on_select = function(ctxt, item, amount)
      Gui.mes("steal")

      return "turn_end"
   end
}
data:add(inv_steal)

local inv_cook = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_cook",

   sources = { "chara" },
   icon = 7,
   filter = function(ctxt, item)
      if not item:has_category("elona.food") then
         return false
      end

      if item:calc("food_quality") then
         -- Item is already cooked.
         return false
      end

      return true
   end,
}
data:add(inv_cook)

local general_actions = {
   "inv_general",
   "inv_drop"
}

local multidrop_actions = {
   "inv_drop"
}
