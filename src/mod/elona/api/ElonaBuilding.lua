local Area = require("api.Area")
local I18N = require("api.I18N")
local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Item = require("api.Item")
local Enum = require("api.Enum")
local Calc = require("mod.elona.api.Calc")
local Itemgen = require("mod.tools.api.Itemgen")
local Skill = require("mod.elona_sys.api.Skill")
local Rank = require("mod.elona.api.Rank")
local Log = require("api.Log")
local Map = require("api.Map")

local ElonaBuilding = {}

-- >>>>>>>> shade2/map_user.hsp:473 *shop_turn ..
function ElonaBuilding.update_shops()
   for _, building in ipairs(save.elona.player_owned_buildings) do
      if building.area_archetype_id == "elona.shop" then
         ElonaBuilding.update_shop(building.area_uid)
      end
   end
end
-- <<<<<<<< shade2/map_user.hsp:481 	return ..

local function shop_message(id, color, ...)
   local mes = ("[%s]%s"):format(I18N.get("building.shop.info"), I18N.get_optional(id, ...) or id)
   Gui.mes_c(mes, color, ...)
end

function ElonaBuilding.calc_shop_customer_count(shop_level, shopkeeper)
   local customers = 0
   for _ = 1, 3 do
      customers = customers + Rand.rnd(shop_level / 3 + 5)
   end
   customers = math.floor(customers * (80 + shopkeeper:skill_level("elona.stat_charisma") * 3 / 2) / 100)
   customers = math.max(customers, 1)
   return customers
end

function ElonaBuilding.can_sell_item_in_shop(item)
   if not Item.is_alive(item) then
      return false
   end

   if item.prevent_sell_in_own_shop then
      return false
   end

   if item:calc("cargo_weight") > 0 or item:calc("quality") >= Enum.Quality.Unique or item:calc("value") < 50 then
      return false
   end

   if item:has_category("elona.furniture") then
      return false
   end

   return true
end

function ElonaBuilding.calc_shop_item_value(item, shopkeeper)
   local value = Calc.calc_item_value(item, "player_shop")
   value = value * math.floor(10 + math.sqrt(shopkeeper:skill_level("elona.negotiation") * 200) / 100)
   return value
end

function ElonaBuilding.calc_item_will_be_sold(item, value, shop_level)
   if Rand.rnd(value) > shop_level * 100 + 500 then
      return false
   end

   return Rand.one_in(8)
end

-- >>>>>>>> shade2/map_user.hsp:483 *shop_turn_main ..
function ElonaBuilding.update_shop(area)
   if type(area) == "number" then
      area = Area.get(area)
   end

   local shopkeeper_uid = area.metadata.shopkeeper_uid

   if not shopkeeper_uid then
      Log.debug("Shopkeeper not set in area metadata")
      shop_message("building.shop.log.no_shopkeeper")
      return
   end

   local ok, floor = area:get_floor(1)
   if not ok then
      Log.debug("Missing shop floor 1")
      shop_message("building.shop.log.no_shopkeeper")
      return
   end

   -- Be careful not to load the map from disk again if it's loaded already.
   local map, needs_save
   if floor.uid == Map.current().uid then
      map = Map.current()
   else
      needs_save = true
      ok, map = area:load_floor(1)
      if not ok then
         Log.debug("Missing shop floor 1")
         shop_message("building.shop.log.no_shopkeeper")
         return
      end
   end

   local shopkeeper = map:get_object(shopkeeper_uid)
   if not shopkeeper then
      Log.debug("Missing shopkeeper object")
      shop_message("building.shop.log.no_shopkeeper")
      return
   end

   local total_sold = 0
   local income = 0
   local items_created = 0
   local items_to_create = {}

   local shop_rank = Rank.get("elona.shop")
   local shop_level = math.floor(100 - shop_rank / 100)
   local customer_count = ElonaBuilding.calc_shop_customer_count(shop_level, shopkeeper)

   local sellable = Item.iter_all(map):filter(ElonaBuilding.can_sell_item_in_shop):to_list()

   for _ = 1, customer_count do
      if #sellable == 0 then
         break
      end

      local item = Rand.choice(sellable)

      local value = ElonaBuilding.calc_shop_item_value(item, shopkeeper)
      if ElonaBuilding.calc_item_will_be_sold(item, value, shop_level) then
         local sold_amount = Rand.rnd(item.amount) + 1
         item.amount = item.amount - sold_amount
         total_sold = total_sold + sold_amount

         value = value * total_sold

         if Rand.one_in(4) then
            local major_categories = item:major_categories()
            if #major_categories > 1 then
               items_to_create[#items_to_create+1] = {
                  filter = {
                     level = item:calc("level"),
                     quality = item:calc("quality"),
                     categories = major_categories,
                  },
                  value = value
               }
            end
         else
            income = income + value
         end

         item:remove_activity()
         item:refresh_cell_on_map()
      end
   end

   -- TODO containers
   if income > 0 then
      Item.create("elona.gold_piece", nil, nil, { amount = income }, map)
   end

   for _, item_to_create in ipairs(items_to_create) do
      local found = false
      for _ = 1, 4 do
         local item = Itemgen.create(nil, nil, item_to_create.filter, map)
         if item == nil then
            break
         end

         if item:calc("value") > item_to_create.value * 2 then
            found = true
            break
         else
            item:remove()
         end
      end

      if not found then
         Item.create("elona.gold_piece", nil, nil, { amount = item_to_create.value }, map)
         income = income + item_to_create.value
      else
         items_created = items_created + 1
      end
   end

   local hide = config["elona.hide_shop_results"]

   if total_sold == 0 then
      if hide == "none" then
         shop_message("building.shop.log.could_not_sell", nil, customer_count, shopkeeper)
      end
   else
      if hide == "none" or hide == "could_not_sell" then
         local put_in = I18N.get("building.shop.log.gold", income)
         if items_created > 0 then
            put_in = put_in .. I18N.get("building.shop.log.and_items", items_created)
         end
         local mes = I18N.get("building.shop.log.sold_items", customer_count, shopkeeper, total_sold, put_in)
         Gui.play_sound("base.ding2")
         shop_message(mes, "Yellow")
      end

      local exp_gain = math.clamp(math.sqrt(income) * 6, 25, 1000)
      Skill.gain_skill_exp(shopkeeper, "elona.negotiation", exp_gain)
   end

   if total_sold > (110 - shop_rank / 100) / 10 then
      Rank.modify("elona.shop", 30, 2)
   end

   if needs_save then
      Map.save(map)
   end
end
-- <<<<<<<< shade2/map_user.hsp:616 	return ..

return ElonaBuilding
