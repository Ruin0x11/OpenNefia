local Chara = require("api.Chara")
local Item = require("api.Item")
local Itemgen = require("mod.tools.api.Itemgen")
local Rand = require("api.Rand")
local Enum = require("api.Enum")
local World = require("api.World")
local Inventory = require("api.Inventory")
local Calc = require("mod.elona.api.Calc")

local ShopInventory = {}

function ShopInventory.default_item_number(args)
   return math.min(80, 20 + args.shopkeeper.shop_rank / 2)
end

function ShopInventory.test_rule_predicate(rule, index, shopkeeper)
   if rule.index then
      return index == rule.index
   end
   if rule.one_in then
      return Rand.one_in(rule.one_in)
   end
   if rule.all_but_one_in then
      return not Rand.one_in(rule.all_but_one_in)
   end
   if rule.predicate then
      return rule.predicate({index = index, shopkeeper = shopkeeper}) == true
   end

   return true
end

function ShopInventory.apply_rule_properties(rule, ret, index, shopkeeper)
   for k, v in pairs(rule) do
      -- Apply "choices" and "on_generate" after the other properties
      -- have been copied.
      -- NOTE: The predicate fields get copied too, but are ignored by
      -- Item.create().
      if k ~= "choices" and k ~= "on_generate" then
         ret[k] = v
      end
   end

   if rule.choices then
      local chosen_rule = Rand.choice(rule.choices)
      ret = ShopInventory.apply_rule_properties(chosen_rule, ret)
   end

   if rule.on_generate then
      local generated_rule = rule.on_generate({index = index, shopkeeper = shopkeeper})

      -- NOTE: This could potentially recurse somewhat deeply if the
      -- generated rule also contains an on_generate field.
      ret = ShopInventory.apply_rule_properties(generated_rule, ret)
   end

   return ret
end

function ShopInventory.apply_rules(index, shopkeeper, inv)
   -- >>>>>>>> shade2/chat.hsp:3314 	flt calcObjLv(cRoleShopLv(tc)),calcFixLv(fixNorma ...
   local ret = {
      level = Calc.calc_object_level(shopkeeper:calc("shop_rank"), shopkeeper:current_map()),
      quality = Calc.calc_object_quality(Enum.Quality.Normal)
   }
   -- <<<<<<<< shade2/chat.hsp:3314 	flt calcObjLv(cRoleShopLv(tc)),calcFixLv(fixNorma ..

   if not inv.rules then
      return ret
   end

   for _, rule in ipairs(inv.rules) do
      if ShopInventory.test_rule_predicate(rule, index, shopkeeper) then
         ret = ShopInventory.apply_rule_properties(rule, ret, index, shopkeeper)

         if ret.id == "Skip" then
            -- Don't generate an item this cycle.
            return nil
         end
      end
   end

   return ret
end

-- If all of the properties of an item match that of an exclusion, the item is
-- removed.
ShopInventory.item_exclusions = {
   { _category = "elona.drink", _id = "core.bottle_of_water" },
   { _category = "elona.crop_seed" }
}

local function is_excluded(item)
   local categories = table.set(item.categories)
   for _, exclusion in ipairs(ShopInventory.item_exclusions) do
      local found = true

      for k, v in pairs(exclusion) do
         if k == "_category" then
            if not categories[v] then
               found = false
            end
         elseif item[k] ~= v then
            found = false
         end
      end

      if found then
         return true
      end
   end

   return false
end

function ShopInventory.should_remove(item, inv)
   local tags = table.set(item.proto.tags or {})

   if tags["neg"] then
      return true
   end

   if tags["noshop"] and not inv.ignores_noshop then
      return true
   end

   if item:is_cursed() then
      return true
   end

   if is_excluded(item) then
      return true
   end

   return false
end

-- Higher factor means fewer items.
local function number_from_rarity(factor)
   return function(args) return ((args.item.proto.rarity or 1000000) / 1000) / factor end
end

-- Map of item category/id -> function returning sold item amount.
-- Gets passed the item's definition and the item instance.
ShopInventory.item_number_factors = {
   ["elona.food"] = function() return 1 end,
   ["elona.cargo"] = number_from_rarity(200),
   ["elona.tree"] = number_from_rarity(100),
   ["elona.drink"] = number_from_rarity(100),
   ["elona.scroll"] = number_from_rarity(100),
   ["elona.furniture"] = number_from_rarity(200),
   ["elona.junk"] = number_from_rarity(80),
   ["elona.misc_item"] = number_from_rarity(500),

   ["core.small_gamble_chest"] = function() return Rand.rnd(8) end
}

function ShopInventory.calc_max_item_number(item)
   local categories = item.proto.categories
   local number = 1

   for _, category in ipairs(categories) do
      local f = ShopInventory.item_number_factors[category]
      if f then
         number = f({item = item})
      end
   end

   local f = ShopInventory.item_number_factors[item.id]
   if f then
      number = f({item = item})
   end

   if number < 1 then
      number = 1
   end

   return number
end

-- Parameters for adjusting the amount of available cargo based on the
-- cargo's fluctuating value. Cargo of higher value will be more
-- difficult to find in shops. More than one modifier can be applied
-- if multiple value thresholds are reached.
ShopInventory.cargo_amount_rates = {
   { threshold = 70,  type = "lt", amount = function(n) return n * 200 / 100 end                    },
   { threshold = 50,  type = "lt", amount = function(n) return n * 200 / 100 end                    },
   { threshold = 80,  type = "gt", amount = function(n) return n / 2 + 1     end, remove_chance = 2 },
   { threshold = 100, type = "gt", amount = function(n) return n / 2 + 1     end, remove_chance = 3 },
}

function ShopInventory.cargo_amount_modifier(amount)
   return amount * (100 + Chara.player():skill_level("elona.negotiation") * 10) / 100 + 1
end

local function trade_rate(item)
   -- TODO
   return 0
end

-- Calculate adjusted amount of cargo items to be sold based on the
-- cargo's value.
function ShopInventory.calc_cargo_amount(item)
   local rate = trade_rate(item)
   local amount = item.number

   for _, v in ipairs(ShopInventory.cargo_amount_rates) do
      local apply

      if v.type == "lt" then
         apply = rate <= v.threshold
      else
         apply = rate >= v.threshold
      end

      if apply then
         amount = v.amount(amount)
         if v.discard_chance and Rand.one_in(v.discard_chance) then
            return nil
         end
      end
   end

   return ShopInventory.cargo_amount_modifier(amount)
end

-- @tparam id:elona.shop_inventory inv_id
-- @tparam IChara shopkeeper
function ShopInventory.generate(inv_id, shopkeeper)
   local inv = data["elona.shop_inventory"]:ensure(inv_id)
   local result = Inventory:new(nil, "base.item", nil) -- will set _parent later

   -- Determine how many items to create. Shops can also adjust the
   -- amount with a formula.
   local items_to_create = ShopInventory.default_item_number({shopkeeper = shopkeeper})
   if inv.item_number then
      items_to_create = inv.item_number({shopkeeper = shopkeeper, item_number = items_to_create})
   end

   local go = function(index)
      -- Go through each generation rule the shop defines and get back
      -- a table of options for Item.create().
      local args = ShopInventory.apply_rules(index, shopkeeper, inv)

      if not args then
         return
      end

      args.no_stack = true
      args.is_shop = true
      local item
      if args.id then
         local id = args.id
         args.id = nil
         item = Item.create(id, nil, nil, args, result)
      else
         item = Itemgen.create(nil, nil, args, result)
      end
      if not item then
         -- Shop inventory is full, don't generate anything else.
         return true
      end

      -- If the shop defines special handling of item state on
      -- generation, use it and skip the remaining adjustments to the
      -- item that happen afterward.
      if inv.on_generate_item then
         inv.on_generate_item({item = item, index = index, shopkeeper = shopkeeper})
         return
      end

      -- Exclude items like cursed items, seeds or water.
      if ShopInventory.should_remove(item, inv) then
         item:remove_ownership()
         return
      end

      -- Calculate the number of items sold (always above 0).
      item.number = Rand.rnd(ShopInventory.calc_max_item_number(item)) + 1

      -- Cargo traders have special behavior for calculating the sold
      -- item number.
      if inv._id == "elona.trader" then
         local number = ShopInventory.calc_cargo_amount(item)
         if number == nil then
            item:remove_ownership()
            return
         else
            item.number = number
         end
      end

      -- Blessed items are never generated in multiple (per cycle).
      if item.curse_state == Enum.CurseState.Blessed then
         item.number = 1
      end

      -- Shops can adjust the price of items through a formula.
      if inv.item_base_value then
         item.value = inv.item_base_value({item = item, shopkeeper = shopkeeper})
      end

      item:stack() -- Item.stack(-1, item, false) -- invalidates "item".
   end

   for index = 0, items_to_create - 1 do
      if go(index) then
         break
      end
   end

   return result
end

function ShopInventory.refresh_shop(shopkeeper)
   -- TODO multiple shop roles
   local role = shopkeeper:find_role("elona.shopkeeper")
   local inv_id = role.inventory_id
   local inv_data = data["elona.shop_inventory"]:ensure(inv_id)
   shopkeeper.shop_inventory = ShopInventory.generate(inv_id, shopkeeper)
   shopkeeper.shop_inventory:set_owner(shopkeeper)

   -- >>>>>>>> elona122/shade2/chat.hsp:3564  ..
   local restock_interval = inv_data.restock_interval or 24
   shopkeeper.shop_restock_date = World.date_hours() + restock_interval
   -- <<<<<<<< elona122/shade2/chat.hsp:3565 	cRoleRestock(tc)=dateID+restockTime*(1+(cRole(tc) ..

   shopkeeper:emit("elona.on_shop_restocked", {inventory_id=inv_id})
end

return ShopInventory
