local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Action = require("api.Action")
local Input = require("api.Input")
local ElonaAction = require("mod.elona.api.ElonaAction")
local ItemDescriptionMenu = require("api.gui.menu.ItemDescriptionMenu")
local Map = require("api.Map")
local Calc = require("mod.elona.api.Calc")
local Effect = require("mod.elona.api.Effect")
local elona_Item = require("mod.elona.api.Item")
local Enum = require("api.Enum")

local function fail_in_world_map(ctxt)
   if ctxt.chara:current_map():has_type("world_map") then
      Gui.mes("action.cannot_do_in_global")
      return "player_turn_query"
   end
end

local function can_take(item)
   if item.own_state == Enum.OwnState.NotOwned or item.own_state == Enum.OwnState.Shop then
      Gui.play_sound("base.fail1")
      if item.own_state == "not_owned" then
         Gui.mes("action.get.not_owned")
      elseif item.own_state == "shop" then
         Gui.mes("action.get.cannot_carry")
      end
      return false
   end
   return true
end

local inv_examine = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_examine",
   elona_id = 1,

   keybinds = {
      mode2 = function(ctxt, item)
         item.flags.no_drop = not item.flags.no_drop
         print("nodrop toggle")
      end
   },

   sources = { "chara", "equipment", "ground" },
   shortcuts = true,
   icon = 7,
   window_title = "ui.inventory_command.general",
   query_text = "ui.inv.title.general",
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
      mode2 = function(ctxt, item)
         if not ctxt.multi_drop then
            ctxt.multi_drop = true
         end
      end
   },

   sources = { "chara" },
   icon = 8,
   window_title = "ui.inventory_command.drop",
   query_text = "ui.inv.title.drop",
   can_select = function(ctxt, item)
      if item:calc("is_no_drop") then
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
   window_title = "ui.inventory_command.get",
   query_text = "ui.inv.title.get",
   on_select = function(ctxt, item, amount)
      if not can_take(item) then
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
data:add(inv_get)

local inv_eat = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_eat",
   elona_id = 5,

   sources = { "chara", "equipment", "ground" },
   shortcuts = true,
   icon = 2,
   window_title = "ui.inventory_command.eat",
   query_text = "ui.inv.title.eat",
   filter = function(ctxt, item)
      return item:calc("can_eat")
         or item:calc("material") == "elona.fresh" -- TODO
   end,
   can_select = function(ctxt, item)
      if item:calc("is_no_drop") then
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
   window_title = "ui.inventory_command.equip",
   query_text = "ui.inv.title.equip",
   filter = function(ctxt, item)
      return item:can_equip_at(ctxt.body_part_id)
   end,
   can_select = function(ctxt, item)
      if ctxt.chara:has_trait("elona.perm_weak") and item:calc("weight") >= 1000 then
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
   window_title = "ui.inventory_command.read",
   query_text = "ui.inv.title.read",
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
   window_title = "ui.inventory_command.drink",
   query_text = "ui.inv.title.drink",
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
   window_title = "ui.inventory_command.zap",
   query_text = "ui.inv.title.zap",
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
   window_title = "ui.inventory_command.buy",
   query_text = "ui.inv.title.buy",
   can_select = function(ctxt, item)
      if item:calc("is_no_drop") then
         return false, "marked as no drop"
      end

      if not can_take(item) then
         return "turn_end"
      end

      return true
   end,
   on_select = function(ctxt, item, amount)
      Gui.mes("ui.inv.buy.prompt", item:build_name(amount), amount)
      if not Input.yes_no() then
         return "inventory_continue"
      end

      local cost = Calc.calc_item_value(item) * amount

      if cost > ctxt.chara.gold then
         Gui.mes("ui.inv.buy.not_enough_money")
         return "inventory_continue"
      end

      local separated = Action.get(ctxt.chara, item, amount)
      if not separated then
         Gui.mes("ui.inv.buy.common.inventory_is_full")
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
   window_title = "ui.inventory_command.sell",
   query_text = "ui.inv.title.sell",
   can_select = function(ctxt, item)
      if item:calc("is_no_drop") then
         return false, "marked as no drop"
      end

      if not can_take(item) then
         return "turn_end"
      end

      return true
   end,
   on_select = function(ctxt, item, amount)
      Gui.mes("ui.inv.sell.prompt", item:build_name(amount), amount)
      if not Input.yes_no() then
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
      separated.identify_state = Enum.IdentifyState.Full

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
   window_title = "ui.inventory_command.use",
   query_text = "ui.inv.title.use",
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
   window_title = "ui.inventory_command.open",
   query_text = "ui.inv.title.open",
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
   window_title = "ui.inventory_command.cook",
   query_text = "ui.inv.title.cook",
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
   window_title = "ui.inventory_command.dip_source",
   query_text = "ui.inv.title.dip_source",
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
   window_title = "ui.inventory_command.throw",
   query_text = "ui.inv.title.throw",
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
   window_title = "ui.inventory_command.steal",
   query_text = "ui.inv.title.steal",
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

local inv_get_pocket = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_get_pocket",
   elona_id = 22,
   elona_sub_id = 5,

   sources = { "container" },
   icon = 17,
   show_money = false,
   query_amount = true,
   window_title = "ui.inventory_command.put",
   query_text = "ui.inv.title.put",

   can_select = function(ctxt, item)
      local success = Effect.do_stamina_check(ctxt.chara, 10)
      if not success then
         Gui.mes("magic.common.too_exhausted")
         return "turn_end"
      end

      if not can_take(item) then
         return "turn_end"
      end

      return true
   end,

   on_select = function(ctxt, item, amount)
      local result = Action.get_from_container(ctxt.chara, item, amount)

      return "inventory_continue"
   end
}
data:add(inv_get_pocket)

local inv_put_pocket = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_put_pocket",
   elona_id = 24,
   elona_sub_id = 5,

   sources = { "chara" },
   icon = 17,
   show_money = false,
   query_amount = true,
   window_title = "ui.inventory_command.put",
   query_text = "ui.inv.title.put",

   can_select = function(ctxt, item)
      local success = Effect.do_stamina_check(ctxt.chara, 10)
      if not success then
         Gui.mes("magic.common.too_exhausted")
         return "turn_end"
      end

      if not can_take(item) then
         return "turn_end"
      end

      return true
   end,

   on_select = function(ctxt, item, amount)
      -- HACK: Assuming ctxt.container is an api.Inventory. Probably want to have
      -- an IInventory interface that both IChara and Inventory satisfy.
      if ctxt.container:is_full() then
         Gui.play_sound("base.fail1")
         Gui.mes("ui.inv.put.container.full")
         return "inventory_continue"
      end

      if item:calc("weight") >= ctxt.container.max_weight then
         Gui.play_sound("base.fail1")
         Gui.mes("ui.inv.put.container.too_heavy", ctxt.container.max_weight)
         return "inventory_continue"
      end

      if item.is_cargo then
         Gui.play_sound("base.fail1")
         Gui.mes("ui.inv.put.container.cannot_hold_cargo")
         return "inventory_continue"
      end

      local result = Action.put_in_container(ctxt.container, item, amount)

      return "inventory_continue"
   end
}
data:add(inv_put_pocket)

local inv_identify = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_identify",
   elona_id = 13,

   sources = { "chara" },
   icon = 17,
   show_money = false,
   query_amount = false,
   window_title = "ui.inventory_command.identify",
   query_text = "ui.inv.title.identify",

   filter = function(ctxt, item)
      return item.identify_state ~= Enum.IdentifyState.Full
   end,

   on_select = function(ctxt, item, amount)
      return "inventory_continue"
   end
}
data:add(inv_identify)

local inv_equipment = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_equipment",
   elona_id = 23,
   elona_sub_id = 0,

   sources = { "chara", "equipment" },
   icon = 17,
   show_money = false,
   query_amount = false,
   window_title = "ui.inventory_command.target",
   query_text = "ui.inv.title.target",

   filter = function(ctxt, item)
      return item:has_category("elona.furniture") or elona_Item.is_equipment(item)
   end,

   on_select = function(ctxt, item, amount)
      return "inventory_continue"
   end
}
data:add(inv_equipment)

local inv_equipment_weapon = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_equipment_weapon",
   elona_id = 23,
   elona_sub_id = 1,

   sources = { "chara", "equipment" },
   icon = 17,
   show_money = false,
   query_amount = false,
   window_title = "ui.inventory_command.target",
   query_text = "ui.inv.title.target",

   filter = function(ctxt, item)
      return item:has_category("elona.equip_melee") or item:has_category("elona.equip_ranged")
   end,

   on_select = function(ctxt, item, amount)
      return "inventory_continue"
   end
}
data:add(inv_equipment_weapon)

local inv_equipment_armor = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_equipment_armor",
   elona_id = 23,
   elona_sub_id = 2,

   sources = { "chara", "equipment" },
   icon = 17,
   show_money = false,
   query_amount = false,
   window_title = "ui.inventory_command.target",
   query_text = "ui.inv.title.target",

   filter = function(ctxt, item)
      return elona_Item.is_armor(item)
   end,

   on_select = function(ctxt, item, amount)
      return "inventory_continue"
   end
}
data:add(inv_equipment_armor)

local inv_equipment_flight = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_equipment_flight",
   elona_id = 23,
   elona_sub_id = 6,

   sources = { "chara", "equipment" },
   icon = 17,
   show_money = false,
   query_amount = false,
   window_title = "ui.inventory_command.target",
   query_text = "ui.inv.title.target",

   filter = function(ctxt, item)
      -- >>>>>>>> shade2/command.hsp:3404 		if invCtrl(1)=6: if (iWeight(cnt)<=0)or(iId(cnt) ..
      return item.weight > 1 and not item:calc("cannot_use_flight_on")
      -- <<<<<<<< shade2/command.hsp:3404 		if invCtrl(1)=6: if (iWeight(cnt)<=0)or(iId(cnt) ..
   end,

   on_select = function(ctxt, item, amount)
      return "inventory_continue"
   end
}
data:add(inv_equipment_flight)

local inv_garoks_hammer = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_garoks_hammer",
   elona_id = 23,
   elona_sub_id = 7,

   sources = { "chara", "equipment" },
   icon = 17,
   show_money = false,
   query_amount = false,
   window_title = "ui.inventory_command.target",
   query_text = "ui.inv.title.target",

   filter = function(ctxt, item)
      return item:calc("quality") < Enum.Quality.Great and elona_Item.is_equipment(item)
   end,

   on_select = function(ctxt, item, amount)
      return "inventory_continue"
   end
}
data:add(inv_garoks_hammer)
