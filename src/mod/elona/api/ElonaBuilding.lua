local Area = require("api.Area")
local I18N = require("api.I18N")
local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Item = require("api.Item")
local Enum = require("api.Enum")
local Calc = require("mod.elona.api.Calc")
local Itemgen = require("mod.elona.api.Itemgen")
local Skill = require("mod.elona_sys.api.Skill")
local Rank = require("mod.elona.api.Rank")
local Log = require("api.Log")
local Map = require("api.Map")
local Draw = require("api.Draw")
local Chara = require("api.Chara")
local Charagen = require("mod.elona.api.Charagen")
local Building = require("mod.elona.api.Building")
local Inventory = require("api.Inventory")
local IItemCargo = require("mod.elona.api.aspect.IItemCargo")

local ElonaBuilding = {}

function ElonaBuilding.calc_shop_extend_cost(map)
   -- >>>>>>>> shade2/module.hsp:381 	return mMaxInv*100+1000 ...
   return map.item_on_floor_limit * 100 + 1000
   -- <<<<<<<< shade2/module.hsp:381 	return mMaxInv*100+1000 ..
end

-- >>>>>>>> shade2/map_user.hsp:473 *shop_turn ..
function ElonaBuilding.update_shops()
   -- TODO multiple shop maps per area (#178)
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

function ElonaBuilding.is_item_sellable_in_shop(item)
   if not Item.is_alive(item) then
      return false
   end

   if item.prevent_sell_in_own_shop then
      return false
   end

   if item:get_aspect(IItemCargo) or item:calc("quality") >= Enum.Quality.Unique or item:calc("value") < 50 then
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
   local success = Building.update_map(area, 1, ElonaBuilding.update_shop_map)
   if not success then
      shop_message("building.shop.log.no_shopkeeper")
   end
end

function ElonaBuilding.update_shop_map(map)
   -- TODO move somewhere else
   local shopkeeper_uid = map.shopkeeper_uid

   if not shopkeeper_uid then
      Log.debug("Shopkeeper not set in map properties")
      shop_message("building.shop.log.no_shopkeeper")
      return
   end

   local shopkeeper = Building.find_worker(map, shopkeeper_uid)
   if not shopkeeper then
      map.shopkeeper_uid = nil
      Log.warn("Could not find worker %d in shop map or stayers.", shopkeeper_uid)
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

   local sellable = Item.iter_all(map):filter(ElonaBuilding.is_item_sellable_in_shop):to_list()

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
            if #major_categories > 0 then
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

   local shop_strongbox = Inventory.get_or_create("elona.shop_strongbox")

   -- TODO containers
   if income > 0 then
      Item.create("elona.gold_piece", nil, nil, { amount = income }, shop_strongbox)
   end

   for _, item_to_create in ipairs(items_to_create) do
      local found = false
      for _ = 1, 4 do
         local item = Itemgen.create(nil, nil, item_to_create.filter, shop_strongbox)
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
         Item.create("elona.gold_piece", nil, nil, { amount = item_to_create.value }, shop_strongbox)
         income = income + item_to_create.value
      else
         items_created = items_created + 1
      end
   end

   local hide = config.elona.hide_shop_results

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
end
-- <<<<<<<< shade2/map_user.hsp:616 	return ..

-- >>>>>>>> shade2/map_user.hsp:639 *museum_value ..
function ElonaBuilding.calc_museum_item_value(item, seen)
   local chara_entry = data["base.chara"]:ensure(item.params.chara_id)

   local value
   if chara_entry.quality == Enum.Quality.Unique then
      value = 70 + chara_entry.level
   else
      value = chara_entry.level / 10 + 2
      -- TODO
      local chip = "elona.chara_race_slime"
      local chip_width, chip_height = Draw.get_chip_size("chip", chip)
      local is_tall = chip_width and (chip_height > chip_width)
      if is_tall then
         value = value / 2 * 3 + 40
      end
      if chara_entry.rarity < 80 * 1000 then
         value = value + 80 - (chara_entry.rarity / 1000)
      end
   end

   if seen[chara_entry._id] then
      value = math.min(value / 3, 15)
   end

   if item._id == "elona.card" then
      value = value / 2
   end

   return math.floor(value)
end
-- <<<<<<<< shade2/map_user.hsp:653 	return ..

function ElonaBuilding.calc_museum_rank(map)
   local filter = function(item)
      return (item._id == "elona.card" or item._id == "elona.figurine")
         and data["base.chara"][item.params.chara_id] ~= nil
   end
   local new_rank = 0
   local seen = table.set {}

   for _, item in Item.iter(map):filter(filter) do
      local value = ElonaBuilding.calc_museum_item_value(item, seen)
      new_rank = new_rank + value
      seen[item.params.chara_id] = true
   end
   new_rank = math.max(10000 - math.sqrt(new_rank) * 100, 100)
   return math.floor(new_rank)
end

function ElonaBuilding.update_museum(map)
   local original_rank = Rank.get("elona.museum")
   local new_rank = ElonaBuilding.calc_museum_rank(map)
   Rank.set("elona.museum", new_rank, true)

   if original_rank ~= new_rank then
      local color
      if original_rank > new_rank then
         color = "Green"
      else
         color = "Purple"
      end
      Gui.mes_c("building.museum.rank_change", color, math.floor(original_rank / 100), math.floor(new_rank / 100), Rank.title("elona.museum"))
   end

   map.max_crowd_density = (100 - new_rank / 100) / 2 + 1
end

-- >>>>>>>> elona122/shade2/map_user.hsp:753 #defcfunc cBreeder int c ..
function ElonaBuilding.calc_breeder_power(breeder)
   local breed_power = breeder:calc("breed_power") or 100
   return math.floor(breed_power * 100 / (100 + breeder:calc("level") * 5))
end
-- <<<<<<<< elona122/shade2/map_user.hsp:757 	return p ..

-- >>>>>>>> elona122/shade2/map_user.hsp:762 *ranch_update ..
function ElonaBuilding.ranch_generate_item(map, chara, x, y)
   local filter = {
      level = Calc.calc_object_level(chara:calc("level"), map),
      quality = Enum.Quality.Normal
   }

   local item
   local total_generated = 0

   local option = Rand.choice({"egg", "milk", "shit", "bone"})
   if option == "egg" then
      local success = Rand.one_in(60)
      if chara.race == "elona.chicken" and Rand.one_in(20) then -- TODO
         success = true
      end
      if success then
         total_generated = total_generated + 1
         item = Item.create("elona.egg", x, y, filter, map)
         if item then
            item.params.chara_id = chara._id
            item.weight = chara:calc("weight") * 10 + 250
            item.value = math.floor(math.clamp(item.weight * item.weight / 10000, 200, 40000))
         end
      end
   elseif option == "milk" then
      local success = Rand.one_in(60)
      if chara.race == "elona.sheep" and Rand.one_in(20) then -- TODO
         success = true
      end
      if success then
         total_generated = total_generated + 1
         item = Item.create("elona.bottle_of_milk", x, y, filter, map)
         if item then
            item.params.chara_id = chara._id
         end
      end
   elseif option == "shit" then
      local success = Rand.one_in(80)
      if success then
         item = Item.create("elona.shit", x, y, filter, map)
         if item then
            item.params.chara_id = chara._id
            item.weight = chara:calc("weight") * 40 + 300
            item.value = math.floor(math.clamp(item.weight * item.weight / 5000, 1, 20000))
         end
      end
   elseif option == "bone" then
      local success = Rand.one_in(80)
      if success then
         local id = "elona.remains_bone"
         if Rand.one_in(2) then
            id = "elona.garbage"
         end
         item = Item.create(id, x, y, filter, map)
      end
   end

   return item, total_generated
end

function ElonaBuilding.update_ranch(map, days_passed)
   map = map or Map.current()
   days_passed = days_passed or 1

   -- TODO move somewhere else
   local breeder_uid = map.breeder_uid

   local breeder
   if breeder_uid then
      breeder = Building.find_worker(map, breeder_uid)
      if breeder == nil then
         map.breeder_uid = nil
         Log.warn("Could not find worker %d in ranch map or stayers.", breeder_uid)
      end
   end

   local is_livestock = function(c) return c.is_livestock end
   local total_livestock = Chara.iter(map):filter(is_livestock):length()

   for _ = 1, days_passed do
      if breeder then
         local should_breed = true
         local breed_power = ElonaBuilding.calc_breeder_power(breeder)
         if Rand.rnd(5000) > breed_power * 100 / (100 + total_livestock * 20) - total_livestock * 2 then
            if total_livestock > 0 or not Rand.one_in(30) then
               should_breed = false
            end
         end

         if should_breed then
            local filter = {
               level = Calc.calc_object_level(breeder:calc("level"), map),
               quality = Enum.Quality.Bad
            }
            if Rand.one_in(2) then
               filter.id = breeder._id
            end
            if not Rand.one_in(10) then
               filter.race_filter = breeder.race
            end
            -- BUG does not filter out randomly selected ID
            if breeder._id == "elona.little_sister" then
               filter.id = "elona.younger_sister"
            end
            local chara = Charagen.create(4 + Rand.rnd(11), 4 + Rand.rnd(8), filter, map)
            if chara then
               chara.is_livestock = true
               total_livestock = total_livestock + 1
            end
         end

         local total_generated = 0

         for _, chara in Chara.iter(map):filter(is_livestock) do
            -- TODO custom map
            local x = Rand.rnd(11) + 4
            local y = Rand.rnd(8) + 4
            if Item.at(x, y):length() == 0 then
               local should_generate = true

               if Rand.rnd(total_generated + 1) > 2 then
                  should_generate = false
               end
               if total_livestock > 10 and Rand.one_in(4) then
                  should_generate = false
               end
               if total_livestock > 20 and Rand.one_in(4) then
                  should_generate = false
               end
               if total_livestock > 30 and Rand.one_in(4) then
                  should_generate = false
               end
               if total_livestock > 40 and Rand.one_in(4) then
                  should_generate = false
               end

               if should_generate then
                  local item, generated = ElonaBuilding.ranch_generate_item(map, chara, x, y)
                  total_generated = total_generated + generated
               end
            end
         end
      end
   end
end
-- <<<<<<<< elona122/shade2/map_user.hsp:832 	return ..

function ElonaBuilding.ranch_reset_aggro(map)
   map = map or Map.current()

   -- >>>>>>>> shade2/map.hsp:2128 	if areaId(gArea)=areaRanch{ ...
   for _, chara in Chara.iter(map) do
      if chara.is_livestock then
         chara:reset_aggro()
         chara:reset_all_relations()
         chara.relation = Enum.Relation.Dislike
      end
   end
   -- <<<<<<<< shade2/map.hsp:2132 		} ..
end

return ElonaBuilding
