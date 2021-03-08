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
local Quest = require("mod.elona_sys.api.Quest")
local Ui = require("api.Ui")
local I18N = require("api.I18N")
local Equipment = require("mod.elona.api.Equipment")
local Skill = require("mod.elona_sys.api.Skill")
local Chara = require("api.Chara")
local Const = require("api.Const")

local function fail_in_world_map(ctxt)
   if ctxt.chara:current_map():has_type("world_map") then
      Gui.mes("action.cannot_do_in_global")
      return "player_turn_query"
   end
end

local function can_take(item)
   if item.own_state == Enum.OwnState.NotOwned or item.own_state == Enum.OwnState.Shop then
      Gui.play_sound("base.fail1")
      if item.own_state == Enum.OwnState.NotOwned then
         Gui.mes("action.get.not_owned")
      elseif item.own_state == Enum.OwnState.Shop then
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

      if type(result) == "string" then
         -- This is a turn result like "turn_end", used by the harvest quest to
         -- indicate the harvesting action should start instead of staying in
         -- the inventory screen.
         return result
      end

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
      -- >>>>>>>> shade2/command.hsp:3735 			if cHunger(pc)>EatLimit:if develop=false:txt la ...
      if ctxt.chara.nutrition > Const.EATING_NUTRITION_LIMIT
         and not config.base.development_mode
      then
         Gui.mes("ui.inv.eat.too_bloated")
         return "player_turn_query"
      end

      return ElonaAction.eat(ctxt.chara, item)
      -- <<<<<<<< shade2/command.hsp:3736 			goto *act_eat ..
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
      return item:can_equip_at(ctxt.params.body_part_id)
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

local inv_give = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_give",
   elona_id = 10,

   sources = { "chara" },
   params = { is_giving_to_ally = "boolean" },
   icon = 17,
   show_money = false,
   query_amount = false,
   default_amount = 1,
   window_title = "ui.inventory_command.give",
   query_text = "ui.inv.title.give",
}

function inv_give.on_select(ctxt, item, amount)
   -- >>>>>>>> shade2/command.hsp:3756 			ifnodrop ci:goto *com_inventory_loop ...
   if item:calc("is_no_drop") then
      Gui.mes("ui.inv.common.set_as_no_drop")
      Gui.play_sound("base.fail1")
      return "inventory_continue"
   end

   local chara = ctxt.chara
   local target = ctxt.target

   if target:has_effect("elona.sleep") then
      Gui.mes("ui.inv.give.is_sleeping", target)
      Gui.play_sound("base.fail1")
      return "inventory_continue"
   end
   if target:is_inventory_full() then
      Gui.mes("ui.inv.give.inventory_is_full", target)
      Gui.play_sound("base.fail1")
      return "inventory_continue"
   end

   if item._id == "elona.gift" then
      Gui.mes("ui.inv.give.present.text", target, item:build_name(amount))
      item:remove(1)
      Gui.mes("ui.inv.give.present.dialog", target)

      local gift_value = item.params.gift_value
      Skill.modify_impression(target, gift_value)
      target:set_emotion_icon("elona.heart", 3)

      Gui.update_screen()

      return "player_turn_query"
   end

   local will_carry, complaint = Calc.will_chara_take_item(target, item, amount)
   if not will_carry then
      Gui.play_sound("base.fail1")
      complaint = complaint or "ui.inv.give.refuses"
      Gui.mes(complaint, target, item:build_name(amount))
      return "inventory_continue"
   end

   -- TODO move
   -- >>>>>>>> shade2/command.hsp:3813 					if cBit(cPregnant,tc):if (iId(ci)=262)or(iId( ...
   if target:calc("is_pregnant") and item:has_tag("elona.is_acid") then
      Gui.mes("ui.inv.give.abortion")
   end
   -- <<<<<<<< shade2/command.hsp:3813 					if cBit(cPregnant,tc):if (iId(ci)=262)or(iId( ..

   Gui.play_sound("base.equip1")

   Gui.mes("ui.inv.give.you_hand", item:build_name(amount), target)

   local result = item:emit("elona.on_item_given", {chara=chara, target=target, amount=amount}, nil)
   if result then
      return result
   end

   local sep = item:separate(1)
   sep:remove_ownership()
   assert(target:take_item(sep))
   sep:stack(true)

   Effect.try_to_set_ai_item(target, sep)
   Equipment.equip_all_optimally(target)
   target:refresh()
   target:refresh_weight()

   if ctxt.params.is_giving_to_ally then
      return "inventory_continue"
   end

   Gui.update_screen()
   return "turn_end"
   -- <<<<<<<< shade2/command.hsp:3842 			goto *com_inventory_loop ...
end

data:add(inv_give)

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
      local cost = Calc.calc_item_value(item, "buy") * amount

      Gui.mes("ui.inv.buy.prompt", item:build_name(amount), cost)
      if not Input.yes_no() then
         return "inventory_continue"
      end

      if cost > ctxt.chara.gold then
         Gui.mes("ui.inv.buy.not_enough_money")
         return "inventory_continue"
      end

      local separated = Action.get(ctxt.chara, item, amount)
      if not separated then
         Gui.mes("ui.inv.buy.common.inventory_is_full")
         return "inventory_continue"
      end

      Gui.mes("action.pick_up.you_buy", item:build_name(amount))
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

   filter = function(ctxt, item)
      -- >>>>>>>> shade2/command.hsp:3368 		if shopTrade{ ...
      if (item:calc("cargo_weight") or 0) > 0 then
         return false
      end

      if item:calc("value") <= 1 then
         return false
      end

      if item:calc("is_precious") then
         return false
      end

      if (item.spoilage_date or 0) < 0 then
         return false
      end

      if item:calc("quality") == Enum.Quality.Unique then
         return false
      end

      return true
      -- <<<<<<<< shade2/command.hsp:3377 		if iQuality(cnt)=fixUnique	:continue ..
   end,

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

      if cost > ctxt.target.gold then
         Gui.mes("ui.inv.sell.not_enough_money")
         return "inventory_continue"
      end

      local separated = Action.get(ctxt.target, item, amount)
      if not separated then
         Gui.mes("action.pick_up.shopkeepers_inventory_is_full")
         return "inventory_continue"
      end

      Gui.mes("action.pick_up.you_sell", item:build_name(amount))
      Gui.play_sound("base.getgold1", ctxt.chara.x, ctxt.chara.y)
      ctxt.target.gold = ctxt.target.gold - cost
      ctxt.chara.gold = ctxt.chara.gold + cost

      separated.own_state = Enum.OwnState.None
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

      if (item.params.food_quality or 0) > 0  then
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

local inv_trade = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_trade",
   elona_id = 20,

   sources = { "target", "target_equipment" },
   window_title = "ui.inventory_command.trade",
   query_text = "ui.inv.title.trade",
   filter = function(ctxt, item)
      return item._id ~= "elona.gold_piece" and item._id ~= "elona.platinum_coin"
   end,
   on_select = function(ctxt, item, amount, rest)
      local result, canceled = Input.query_inventory(ctxt.chara, "elona.inv_present", {target=ctxt.target, params={trade_item=item}})
      if result and not canceled then
         return "player_turn_query"
      end
      return "inventory_cancel"
   end
}
data:add(inv_trade)

local inv_present = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_present",
   elona_id = 20,

   sources = { "chara" },
   params = { trade_item = "api.item.IItem" },
   window_title = "ui.inventory_command.present",

   query_text = function(ctxt)
      return I18N.get("ui.inv.title.present", ctxt.params.trade_item:build_name())
   end,
   filter = function(ctxt, item)
      -- >>>>>>>> shade2/command.hsp:3390 	if invCtrl=21{ ..
      local trade_item = ctxt.params.trade_item
      local trade_value = Calc.calc_item_value(trade_item) * trade_item.amount
      local offer_value = Calc.calc_item_value(item) * item.amount
      return offer_value >= trade_value / 2 * 3
         and not item:calc("is_stolen")
      -- <<<<<<<< shade2/command.hsp:3393 		} ..
   end,
   after_filter = function(ctxt, filtered)
      if #filtered == 0 then
         Gui.mes("ui.inv.trade.too_low_value", ctxt.params.trade_item:build_name())
         return "inventory_cancel"
      end
   end,
   on_select = function(ctxt, item, amount, rest)
      -- >>>>>>>> shade2/command.hsp:3872 		if invCtrl=21{ ...
      if item:calc("is_no_drop") then
         return "inventory_continue"
      end

      local trade_item = ctxt.params.trade_item
      Gui.play_sound("base.equip1")
      item:remove_activity()
      trade_item:remove_activity()
      trade_item.always_drop = false
      Gui.mes("ui.inv.trade.you_receive", trade_item:build_name(), item:build_name())
      if trade_item:is_equipped() then
         assert(ctxt.target:unequip_item(trade_item))
      end

      trade_item:remove_ownership()
      item:remove_ownership()
      assert(ctxt.chara:take_item(trade_item))
      assert(ctxt.target:take_item(item))

      elona_Item.convert_artifact(trade_item)
      Equipment.equip_all_optimally(ctxt.target)
      if not ctxt.target:is_in_player_party() then
         Equipment.generate_and_equip(ctxt.target)
      end
      elona_Item.ensure_free_item_slot(ctxt.target)
      ctxt.target:refresh()
      ctxt.target:refresh_weight()
      ctxt.chara:refresh_weight()

      return "player_turn_query"
      -- <<<<<<<< shade2/command.hsp:3892 			} ..
   end
}
data:add(inv_present)

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
      -- >>>>>>>> shade2/command.hsp:3957 		if invCtrl=26{	 ...
      local x, y, can_see = Input.query_position()
      if not can_see then
         Gui.mes("action.which_direction.cannot_see_location")
         return "player_turn_query"
      end
      if not Map.is_floor(x, y, ctxt.chara:current_map()) then
         Gui.mes("ui.inv.throw.location_is_blocked")
         return "player_turn_query"
      end
      return ElonaAction.throw(ctxt.chara, item, x, y)
      -- <<<<<<<< shade2/command.hsp:3966 			} ..
   end
}
data:add(inv_throw)

local inv_steal = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_steal",
   elona_id = 27,

   sources = { "target_optional", "ground" },
   icon = 7,
   show_money = true,
   window_title = "ui.inventory_command.steal",
   query_text = "ui.inv.title.steal",
   filter = function(ctxt, item)
      -- >>>>>>>> shade2/command.hsp:3429 	if invCtrl=27	:if cnt2=0:if iProperty(cnt)!propNp ...
      return item.own_state == Enum.OwnState.NotOwned
      -- <<<<<<<< shade2/command.hsp:3429 	if invCtrl=27	:if cnt2=0:if iProperty(cnt)!propNp ..
   end,
   after_filter = function(ctxt, filtered)
      -- >>>>>>>> shade2/command.hsp:3456 		if invCtrl=27{ ...
      if #filtered == 0 then
         if Chara.is_alive(ctxt.target) and not ctxt.target:is_player() then
            Gui.mes("ui.inv.steal.has_nothing", ctxt.target)
         else
            Gui.mes("ui.inv.steal.there_is_nothing")
         end
         return "player_turn_query"
      end
      if Chara.is_alive(ctxt.target) and ctxt.target:is_ally() then
         Gui.mes("ui.inv.steal.do_not_rob_ally")
         return "player_turn_query"
      end
      -- <<<<<<<< shade2/command.hsp:3459 		} ..
   end,
   on_select = function(ctxt, item, amount)
      -- >>>>>>>> shade2/command.hsp:3967 		if invCtrl=27:gosub *act_pickpocket:invSubRoutin ...
      ctxt.chara:start_activity("elona.pickpocket", {item=item})
      return "turn_end"
      -- <<<<<<<< shade2/command.hsp:3967 		if invCtrl=27:gosub *act_pickpocket:invSubRoutin ..
   end
}
data:add(inv_steal)

local inv_get_container = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_get_container",
   elona_id = 22,
   elona_sub_id = 0,

   sources = { "container" },
   icon = 17,
   show_money = false,
   query_amount = false,
   window_title = "ui.inventory_command.take",
   query_text = "ui.inv.title.take",

   can_select = function(ctxt, item)
      if not can_take(item) then
         return "turn_end"
      end

      return true
   end,

   on_menu_exit = function(ctxt)
      -- >>>>>>>> shade2/command.hsp:4018 		if invCtrl=22:if invCtrl(1)=0:if listMax>0{ ...
      local item_count = ctxt.container:iter():length()
      if item_count > 0 and ctxt.params.query_leftover then
         Gui.mes("ui.inv.take.really_leave")
         if not Input.yes_no() then
            return "inventory_continue"
         end
      end
      -- <<<<<<<< shade2/command.hsp:4022 			} ..

      return "player_turn_query"
   end,

   on_select = function(ctxt, item, amount)
      local result = Action.get_from_container(ctxt.chara, item, amount)

      return "inventory_continue"
   end
}
data:add(inv_get_container)

local inv_get_four_dimensional_pocket = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_get_four_dimensional_pocket",
   elona_id = 22,
   elona_sub_id = 5,

   sources = { "container" },
   icon = 17,
   show_money = false,
   query_amount = true,
   window_title = "ui.inventory_command.take",
   query_text = "ui.inv.title.take",

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
data:add(inv_get_four_dimensional_pocket)

local inv_harvest_delivery_chest = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_harvest_delivery_chest",
   elona_id = 24,
   elona_sub_id = 0,

   sources = { "chara" },
   icon = 17,
   show_money = false,
   query_amount = false,
   window_title = "ui.inventory_command.put",
   query_text = "ui.inv.title.put",

   filter = function(ctxt, item)
      return not item:has_category("elona.container")
      -- >>>>>>>> shade2/command.hsp:3413 				if iProperty(cnt)!propQuest:continue ..
         and item.own_state == Enum.OwnState.Quest
         and item.params.harvest_weight_class
      -- <<<<<<<< shade2/command.hsp:3413 				if iProperty(cnt)!propQuest:continue ..
   end,

   on_select = function(ctxt, item, amount)
      -- >>>>>>>> shade2/command.hsp:3898 			if invCtrl(1)=0{ ...
      Gui.play_sound("base.inv")
      local quest = assert(Quest.get_immediate_quest())
      assert(quest._id == "elona.harvest", quest._id)
      quest.params.current_weight = quest.params.current_weight + item:calc("weight") * item.amount
      Gui.mes_c("ui.inv.put.harvest", "Green",
                item,
                Ui.display_weight(item:calc("weight") * item.amount),
                Ui.display_weight(quest.params.current_weight),
                Ui.display_weight(quest.params.required_weight))

      item.amount = 0
      item:remove_ownership()
      ctxt.chara:refresh_weight()

      return "inventory_continue"
      -- <<<<<<<< shade2/command.hsp:3911 				} ...      return "inventory_continue"
   end
}
data:add(inv_harvest_delivery_chest)

local inv_put_tax_box = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_put_tax_box",
   elona_id = 24,
   elona_sub_id = 2,

   sources = { "chara" },
   icon = 17,
   show_money = false,
   query_amount = true,
   window_title = "ui.inventory_command.put",
   query_text = "ui.inv.title.put",

   filter = function(ctxt, item)
      return item._id == "elona.bill"
   end,

   can_select = function(ctxt, item)
      -- >>>>>>>> shade2/command.hsp:3907 				if cGold(pc)<iSubName(ci):snd seFail1:txt lang ...
      if ctxt.chara.gold < item.params.bill_gold_amount then
         Gui.play_sound("base.fail1")
         Gui.mes("ui.inv.put.tax.not_enough_money")
         return false
      end

      -- This can happen if you buy an extra bill from Miral.
      if save.elona.unpaid_bill_count <= 0 then
         Gui.play_sound("base.fail1")
         Gui.mes("ui.inv.put.tax.not_enough_money")
         return false
      end
      -- <<<<<<<< shade2/command.hsp:3908 				if gBill<=0 : snd seFail1:txt lang("まだ納税する必要はな ..

      return true
   end,

   on_select = function(ctxt, item, amount)
      -- >>>>>>>> shade2/command.hsp:3909 				cGold(pc)-=iSubName(ci) ...
      ctxt.chara.gold = math.floor(ctxt.chara.gold - item.params.bill_gold_amount)
      Gui.play_sound("base.paygold1")
      Gui.mes_c("ui.inv.put.tax.you_pay", "Green", item:build_name())
      item:remove(1)
      save.elona.unpaid_bill_count = save.elona.unpaid_bill_count - 1

      return "inventory_continue"
      -- <<<<<<<< shade2/command.hsp:3915 				goto *com_inventory ..
   end
}
data:add(inv_put_tax_box)

local inv_put_four_dimensional_pocket = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_put_four_dimensional_pocket",
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
data:add(inv_put_four_dimensional_pocket)

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

local inv_equipment_alchemy = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_equipment_alchemy",
   elona_id = 23,
   elona_sub_id = 4,

   sources = { "chara" },
   icon = 17,
   show_money = false,
   query_amount = false,
   window_title = "ui.inventory_command.target",
   query_text = "ui.inv.title.target",

   filter = function(ctxt, item)
      -- >>>>>>>> shade2/command.hsp:3402 		if invCtrl(1)=4: if iEquip(cnt)!0 :continue ..
      return true
      -- <<<<<<<< shade2/command.hsp:3402 		if invCtrl(1)=4: if iEquip(cnt)!0 :continue ..
   end,

   on_select = function(ctxt, item, amount)
      return "inventory_continue"
   end
}
data:add(inv_equipment_alchemy)

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

local inv_take = {
   _type = "elona_sys.inventory_proto",
   _id = "inv_take",
   elona_id = 25,

   sources = { "target", "target_equipment" },
   icon = 17,
   show_money = true,
   query_amount = false,
   -- >>>>>>>> shade2/command.hsp:3943 			if iId(ci)=idGold:in=iNum(ci):else:in=1 ...
   default_amount = 1,
   -- <<<<<<<< shade2/command.hsp:3943 			if iId(ci)=idGold:in=iNum(ci):else:in=1 ..
   -- >>>>>>>> shade2/command.hsp:3565 	if invCtrl=25:s="" ...
   show_weight_text = false,
   -- <<<<<<<< shade2/command.hsp:3565 	if invCtrl=25:s="" ..
   -- >>>>>>>> shade2/command.hsp:3568 	if invCtrl=25{ ...
   show_target_equip = true,
   -- <<<<<<<< shade2/command.hsp:3568 	if invCtrl=25{ ..
   window_title = "ui.inventory_command.take",
   query_text = "ui.inv.title.take",
}

function inv_take.on_select(ctxt, item, amount)
   -- >>>>>>>> shade2/command.hsp:3919 		if invCtrl=25{ ...
   local chara = ctxt.chara
   local target = ctxt.target

   if chara:is_inventory_full() then
      Gui.mes("ui.inv.common.inventory_full")
      return "inventory_continue"
   end

   local will_give, complaint = Calc.will_chara_give_item_back(target, item, amount)
   if not will_give then
      Gui.play_sound("base.fail1")
      complaint = complaint or "ui.inv.take_ally.refuse_dialog"
      Gui.mes_c(complaint, "Blue", target, item:build_name(amount))
      return "inventory_continue"
   end

   if item:is_equipped() then
      if item:calc("curse_state") <= Enum.CurseState.Cursed then
         Gui.mes("ui.inv.take_ally.cursed", item:build_name())
         return "inventory_continue"
      end
      assert(target:unequip_item(item))
   end

   local result = item:emit("elona.on_item_taken", {chara=chara, target=target, amount=amount}, nil)
   if result then
      return result
   end

   Gui.play_sound("base.equip1")
   item.always_drop = false

   if item._id == "elona.gold_piece" then
      amount = item.amount
   end

   Gui.mes("ui.inv.take_ally.you_take", item:build_name(amount))

   -- TODO maybe make less special-casey
   if item._id == "elona.gold_piece" then
      chara.gold = chara.gold + amount
      item:remove(amount)
   else
      local sep = item:separate(amount)
      sep:remove_ownership()
      assert(chara:take_item(sep))
      elona_Item.convert_artifact(sep)
   end

   Equipment.equip_all_optimally(target)
   target:refresh()
   target:refresh_weight()

   return "inventory_continue"
   -- <<<<<<<< shade2/command.hsp:3955 			} ..
end

data:add(inv_take)
