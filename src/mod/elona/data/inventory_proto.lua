local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Action = require("api.Action")
local Input = require("api.Input")
local ElonaCommand = require("mod.elona.api.ElonaCommand")
local ElonaAction = require("mod.elona.api.ElonaAction")
local ItemDescriptionMenu = require("api.gui.menu.ItemDescriptionMenu")
local Map = require("api.Map")

local function fail_in_world_map(ctxt)
   if ctxt.chara:current_map():has_type("world_map") then
      Gui.mes("action.cannot_do_in_global")
      return "player_turn_query"
   end
end

local inv_examine = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_examine",
   elona_id = 1,

   keybinds = {
      x = function(ctxt, item)
         item.flags.no_drop = not item.flags.no_drop
         print("nodrop toggle")
      end
   },

   sources = { "chara", "equipment", "ground" },
   shortcuts = true,
   icon = 7,
   text = "ui.inventory_command.general",
   on_select = function(ctxt, item, amount, rest)
      local list = rest:to_list()
      ItemDescriptionMenu:new(item, list):query()

      return "inventory_continue"
   end
}
data:add(inv_examine)

local inv_drop = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_drop",
   elona_id = 2,

   keybinds = {
      x = function(ctxt, item)
         if not ctxt.multi_drop then
            ctxt.multi_drop = true
         end
      end
   },

   sources = { "chara" },
   icon = 8,
   text = "ui.inventory_command.drop",
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

local inv_get = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_get",
   elona_id = 3,

   sources = { "ground" },
   icon = 7,
   text = "ui.inventory_command.get",
   on_select = function(ctxt, item, amount)
      if not ctxt.chara:owns_item(item) then
         Gui.play_sound("base.fail1");
         Gui.mes("It's not yours.")
         return "turn_end"
      end

      local result = Action.get(ctxt.chara, item, amount)

      Gui.update_screen()

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

local inv_eat = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_eat",
   elona_id = 5,

   sources = { "chara", "equipment", "ground" },
   shortcuts = true,
   icon = 2,
   text = "ui.inventory_command.eat",
   filter = function(ctxt, item)
      return item:calc("can_eat")
         or item:calc("material") == "elona.raw" -- TODO
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

local inv_equip = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_equip",
   elona_id = 6,

   params = { body_part_id = "string" },
   sources = { "chara" },
   icon = nil,
   text = "ui.inventory_command.equip",
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
   elona_id = 7,

   sources = { "chara", "ground" },
   shortcuts = true,
   icon = 3,
   text = "ui.inventory_command.read",
   filter = function(ctxt, item)
      if ctxt.chara:current_map():has_type("world_map") then
         if not (item:calc("can_read_in_world_map")) then
            return false
         end
      end

      return item:calc("can_read")
   end,
   on_select = function(ctxt, item)
      return ElonaAction.read(ctxt.chara, item)
   end
}
data:add(inv_read)

local inv_drink = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_drink",
   elona_id = 8,

   sources = { "chara", "ground" },
   shortcuts = true,
   icon = 0,
   text = "ui.inventory_command.drink",
   filter = function(ctxt, item)
      return item:calc("can_drink")
   end,
   on_select = function(ctxt, item)
      return ElonaAction.drink(ctxt.chara, item)
   end
}
data:add(inv_drink)

local inv_zap = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_zap",
   elona_id = 9,

   sources = { "chara", "ground" },
   shortcuts = true,
   icon = 1,
   text = "ui.inventory_command.zap",
   filter = function(ctxt, item)
      return item:calc("can_zap")
   end,
   on_shortcut = fail_in_world_map,
   on_select = function(ctxt, item)
      return ElonaAction.zap(ctxt.chara, item)
   end
}
data:add(inv_zap)

local inv_buy = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_buy",
   elona_id = 11,

   sources = { "shop" },
   shortcuts = false,
   icon = nil,
   query_amount = true,
   show_money = true,
   text = "ui.inventory_command.buy",
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
   elona_id = 12,

   sources = { "chara" },
   shortcuts = false,
   icon = nil,
   query_amount = true,
   show_money = true,
   text = "ui.inventory_command.sell",
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

local inv_use = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_use",
   elona_id = 14,

   sources = { "chara", "equipment", "ground" },
   shortcuts = true,
   icon = 5,
   allow_special_owned = true,
   text = "ui.inventory_command.use",
   filter = function(ctxt, item)
      return item:calc("can_use")
   end,
   on_select = function(ctxt, item, amount, rest)
      return ElonaAction.use(ctxt.chara, item)
   end
}
data:add(inv_use)

local inv_open = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_open",
   elona_id = 15,

   sources = { "chara", "ground" },
   shortcuts = true,
   icon = 4,
   text = "ui.inventory_command.open",
   filter = function(ctxt, item)
      return item:calc("can_open")
   end,
   on_shortcut = fail_in_world_map,
   on_select = function(ctxt, item, amount, rest)
      return ElonaAction.open(ctxt.chara, item)
   end
}
data:add(inv_open)

local inv_cook = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_cook",
   elona_id = 16,

   sources = { "chara" },
   icon = nil,
   text = "ui.inventory_command.cook",
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

local inv_dip_source = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_dip_source",
   elona_id = 17,

   sources = { "chara", "ground" },
   icon = 6,
   text = "ui.inventory_command.dip_source",
   filter = function(ctxt, item)
      return item:has_category("elona.drink")
         or item:calc("can_dip_source")
   end,
   on_select = function(ctxt, item, amount, rest)
      Gui.mes("TODO")
      return "player_turn_query" -- ElonaAction.dip(ctxt.chara, item)
   end
}
data:add(inv_dip_source)

local inv_throw = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_throw",
   elona_id = 26,

   sources = { "chara", "ground" },
   icon = 18,
   on_shortcut = fail_in_world_map,
   text = "ui.inventory_command.throw",
   filter = function(ctxt, item)
      return item:calc("can_throw")
   end,
   on_select = function(ctxt, item, amount, rest)
      return ElonaAction.throw(ctxt.chara, item)
   end
}
data:add(inv_throw)

local inv_steal = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_steal",
   elona_id = 27,

   sources = { "target" },
   icon = 7,
   show_money = true,
   text = "ui.inventory_command.steal",
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
