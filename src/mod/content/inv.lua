local source_chara = function(ctxt)
   return ctxt.chara:iter_inventory()
end

local source_equipment = function(ctxt)
   return ctxt.chara:iter_equipment()
end

local source_target_equipment = function(ctxt)
   return ctxt.target:iter_equipment()
end

local source_ground = function(ctxt)
   return Item.at(ctxt.chara.x, ctxt.chara.y)
end

local source_container = function(ctxt)
   return ctxt.container:iter()
end

local inv_general = {
   keybinds = {
      x = function(ctxt, item)
         item.flags.no_drop = not item.flags.no_drop
         print("nodrop toggle")
      end
   },

   sources = { "chara", "equipment", "ground" },
   shortcuts = true,
   sort = function(ctxt, a, b)
      return Item.location(a) == "ground"
         or Item.is_equipped(a)
   end,
   on_select = function(ctxt, item)
      ItemDescriptionMenu:new(item):query()

      return "inventory_continue"
   end
}

local inv_drop = {
   keybinds = {
      x = function(ctxt, item)
         if not ctxt.multi_drop then
            ctxt.multi_drop = true
         end
      end
   },

   sources = "chara",
   can_select = function(ctxt, item)
      if item.flags.no_drop then
         return false, "marked as no drop"
      end

      if not Map.can_drop_items() and not item.types["base.furniture"] then
         return false, "Map is full."
      end

      return true
   end,
   query_amount = true,
   on_select = function(ctxt, item, amount)
      Item.drop(item, amount)
      return "turn_end"
   end,
   on_menu_exit = function(ctxt)
      if ctxt.multi_drop then
         return "turn_end"
      end

      return "player_turn_query"
   end
}

local inv_pick_up = {
   sources = "ground",
   can_select = function(ctxt, item)
      return true
   end,
   query_amount = true,
   on_select = function(ctxt, item)
      if not Chara.owns_item(item) then
         Gui.mes("It's not yours.")
         return "turn_end"
      end

      -- NOTE: how to mark item as removed?
      local result = Chara.receive_item(ctxt.chara, item)

      -- TODO: handle harvest action

      return "inventory_continue"
   end
}

local inv_eat = {
   sources = { "chara", "equipment", "ground", }
   shortcuts = true,
   filter = function(ctxt, item)
      -- NOTE: on_set_material for raw
      return item.types["base.edible"]
   end,
   can_select = function(ctxt, item)
      if item.flags.no_drop then
         return false, "marked as no drop"
      end

      if ctxt.chara.nutrition > 10000 then
         return false, "Too full."
      end

      return true
   end,
   on_select = function(ctxt, item)
      return Hunger.action_eat(ctxt.chara, item)
   end
}

local inv_equip = {
   sources = { "chara" },
   filter = function(ctxt, item)
      local same_body_part = item.body_parts[ctxt.body_part]
      local not_equipped = Item.location(item).type ~= "equip"
      return same_body_part and not_equipped
   end,
   can_select = function(ctxt, item)
      -- TODO: fairy trait
      return true
   end,
}

local inv_read = {
   source = { "chara", "ground" },
   shortcuts = true,
   filter = function(ctxt, item)
      -- TODO: deed
      local readable = item.can_read_in_world_map or not Map.is_world_map()
      return readable and item.on_read ~= nil
   end,
   on_select = function(ctxt, item)
      return Action.read(ctxt.chara, item)
   end
}

local inv_drink = {
   source = { "chara", "ground" },
   shortcuts = true,
   filter = function(ctxt, item)
      return item.on_drink ~= nil
   end,
   on_select = function(ctxt, item)
      return Action.drink(ctxt, item)
   end
}

local inv_zap = {
   source = { "chara", "ground" },
   shortcuts = true,
   filter = function(ctxt, item)
      return item.on_drink ~= nil
   end,
   on_select = function(ctxt, item)
      return Command.query_zap(ctxt, item)
   end
}

local function prevent_if_sleep(ctxt, item)
   -- if StatusEffect.get_turns("base.sleep", ctxt.target) > 0 then
   --    return false, "target is asleep"
   -- end

   return true
end

local inv_ally_give = {
   source = { "chara" },
   can_select = function(ctxt, item)
      if item.flags.no_drop then
         return false, "marked as no drop"
      end

      if ctxt.target.inv:is_full() then
         return false, "Target's inventory is full."
      end

      return true
   end,
   on_select = function(ctxt, item)
      print("inventory give")
      return "inventory_continue"
   end
}

local function shop_filter(ctxt, item)
   if item.value <= 1 then
      return false
   end

   if item.flags.is_precious then
      return false
   end

   -- TODO: param3

   if item.quality == 6 then -- special
      return false
   end

   return true
end

local inv_shop_buying = {
   source = { "target" },
   show_money = true,
   filter = function(ctxt, item)
      if item._id == "base.gold_piece" then
         return false
      end

      if item._id == "base.platinum_coin" then
         return false
      end

      return shop_filter(ctxt, item)
   end,
   can_select = function(ctxt, item)
      if item.flags.no_drop then
         return false, "marked as no drop"
      end

      if not Chara.owns_item(ctxt.chara, item) then
         return false, "It's not yours."
      end

      if not Chara.can_receive_items(ctxt.chara) then
         return false, "Your inventory is full."
      end
   end
   query_amount = true, -- TODO: message
   on_select = function(ctxt, item)
      Gui.mes("Buy?")
      if not Input.yes_no() then
         return "inventory_continue"
      end

      if ctxt.chara.gold < item.value then
         Gui.mes("You don't have enough money.")
         return "inventory_continue"
      end

      local result = Chara.receive_item(ctxt.chara, item)
      assert(result)

      return "inventory_continue"
   end
}

local inv_shop_selling = {}

local inv_identify = {
   source = { "chara", "equipment", "ground" },
   filter = function(ctxt, item)
      return item.identify_state ~= "completely"
   end,
   on_select = function(ctxt, item)
      print("identify")
      item.identify_state = "completely"
      return "turn_end"
   end
}

local inv_use = {
   source = { "chara", "equipment", "ground" },
   shortcuts = true,
   filter = function(ctxt, item)
      return item.on_use ~= nil
   end,
   on_select = function(ctxt, item)
      return Action.use(ctxt.chara, item)
   end
}

local inv_open = {
   source = { "chara", "ground" },
   shortcuts = true,
   filter = function(ctxt, item)
      return item.on_open ~= nil or item.inv ~= nil
   end,
   on_select = function(ctxt, item)
      return Action.open(ctxt.chara, item)
   end
}

local inv_cook = {
   source = { "chara" },
   filter = function(ctxt, item)
      return item.types["base.edible"] and item.types["base.edible"].dish == nil
   end,
}

local inv_dip = {
   source = { "chara" },
   filter = function(ctxt, item)
      -- TODO: bait
      return item.types["base.liquid"]
   end,
   on_select = function(ctxt, item)
      return "inventory_push", "base.inv_dip_target"
   end,
}

local inv_dip_target = {
   source = { "chara", "equipment", "ground" },
   filter = function(ctxt, item)
      -- TODO: bait
      return ctxt.item ~= item and item.can_dip
   end,
   on_menu_enter = function(ctxt)
      Gui.mes("What to dip into " .. ctxt.stack[1].item.uid .. "?")
   end,
   on_select = function(ctxt, item)
      return Action.dip(ctxt.chara, item, ctxt.stack[1].item)
   end,
}

local inv_offer = {
   source = { "chara", "ground" },
   filter = function(ctxt, item)
      -- TODO
      return true
   end,
   after_filter = function(ctxt)
      local altar = Item.find("base.altar", "player_and_ground")
      if altar == nil then
         Gui.mes("No altar.")
         return "turn_end"
      end
   end,
   can_select = function(ctxt, item)
      if item.flags.no_drop then
         return false, "marked as no drop"
      end

      return true
   end,
   on_select = function(ctxt, item)
      return "turn_end"
   end,
}

local inv_trade = {
   source = { "target", "target_equipment" },
   filter = function(ctxt, item)
      return item._id ~= "base.gold_piece" and item._id ~= "base.platinum_coin"
   end,
   on_select = function(ctxt, item)
      return "inventory_push", "base.inv_trade_target"
   end,
}

local inv_trade_target = {
   source = { "chara" },
   filter = function(ctxt, item)
      -- TODO: stolen
      local target = ctxt.stack[1].item
      return item.value * item.number >= target.value * target.number / 2 * 3
   end,
   after_filter = function(ctxt)
      if #ctxt.items == 0 then
         return "turn_end", "No items."
      end
   end,
   on_menu_enter = function(ctxt)
      Gui.mes("What to trade for " .. ctxt.stack[1].item.uid .. "?")
   end,
   on_select = function(ctxt, item)
      return "turn_end"
   end,
}

local inv_take = {
   source = { "container" },
   query_amount = function(ctxt, item)
      return item.number
   end,
   on_select = function(ctxt, item, number)
      if not Chara.owns_item(item) then
         Gui.mes("It's not yours.")
         return "turn_end"
      end

      local result = Chara.receive_item(ctxt.chara, item, number)

      return "inventory_continue"
   end,
}
