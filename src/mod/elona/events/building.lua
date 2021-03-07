local Rand = require("api.Rand")
local Gui = require("api.Gui")
local Event = require("api.Event")
local ElonaBuilding = require("mod.elona.api.ElonaBuilding")
local Map = require("api.Map")
local Area = require("api.Area")
local Gardening = require("mod.elona.api.Gardening")
local Feat = require("api.Feat")
local Building = require("mod.elona.api.Building")
local Chara = require("api.Chara")
local Servant = require("mod.elona.api.Servant")

local function day_passes()
   local guests = save.elona.waiting_guests
   if guests < 3 and Rand.one_in(8 + guests * 5) then
      save.elona.waiting_guests = guests + 1
   end
end

Event.register("base.on_day_passed", "Day passing message/update guests", day_passes, 100000)

-- >>>>>>>> shade2/main.hsp:641 		gosub *shop_turn ..
Event.register("base.on_day_passed", "Update shop every day", function() ElonaBuilding.update_shops() end, 110000)
-- <<<<<<<< shade2/main.hsp:641 		gosub *shop_turn ..

-- >>>>>>>> shade2/main.hsp:571 	if areaId(gArea)=areaMuseum 	: gosub *museum_upda ..
local function update_museum()
   local map = Map.current()
   if Building.map_is_building(map, "elona.museum") then
      ElonaBuilding.update_museum(map)
   end
end

Event.register("base.on_hour_passed", "Update museum every hour", update_museum, 80000)
Event.register("base.on_get_item", "Update museum on item take", update_museum, 150000)
Event.register("base.on_drop_item", "Update museum on item drop", update_museum, 150000)
-- <<<<<<<< shade2/main.hsp:571 	if areaId(gArea)=areaMuseum 	: gosub *museum_upda ..

-- >>>>>>>> elona122/shade2/action.hsp:1729 	if iTypeMinor(ci)=fltSeed	:goto *item_seed ..
local function use_seed(item, params, result)
   if item:has_category("elona.crop_seed") then
      if Gardening.plant_seed(item, params.chara) then
         return "turn_end"
      end
   end
   return result
end
Event.register("elona_sys.on_item_use", "Use seeds", use_seed)
-- <<<<<<<< elona122/shade2/action.hsp:1729 	if iTypeMinor(ci)=fltSeed	:goto *item_seed ..

local function get_plant(chara, params, result)
   local is_plant = function(feat) return feat._id == "elona.plant" end
   local plant = Feat.at(chara.x, chara.y):filter(is_plant):nth(1)

   if plant then
      if Gardening.get_plant(plant, chara) then
         return true
      end
   end

   return result
end
Event.register("elona_sys.on_get", "Get plant", get_plant)

local function house_board_shop_info(map)
   -- >>>>>>>> shade2/map_user.hsp:206 	if areaId(gArea)=areaShop{ ...
   if not Building.map_is_building(map, "elona.shop") then
      return
   end

   local area = assert(Area.for_map(map))
   local shopkeeper_uid = area.metadata.shopkeeper_uid

   if shopkeeper_uid then
      local shopkeeper = map:get_object(shopkeeper_uid)
      if shopkeeper then
         Gui.mes("building.shop.current_shopkeeper", shopkeeper)
      else
         area.metadata.shopkeeper_uid = nil
      end
   end

   if area.metadata.shopkeeper_uid == nil then
      Gui.mes("building.shop.no_assigned_shopkeeper")
   end
   -- <<<<<<<< shade2/map_user.hsp:208 		} ..
end
Event.register("elona.on_house_board_queried", "Show shop info", house_board_shop_info)

local function house_board_ranch_info(map)
   -- >>>>>>>> shade2/map_user.hsp:206 	if areaId(gArea)=areaShop{ ...
   if not Building.map_is_building(map, "elona.ranch") then
      return
   end

   local area = assert(Area.for_map(map))
   local breeder_uid = area.metadata.ranch_breeder_uid

   if breeder_uid then
      local breeder = map:get_object(breeder_uid)
      if breeder then
         Gui.mes("building.ranch.current_breeder", breeder)
      else
         area.metadata.breeder_uid = nil
      end
   end

   if area.metadata.breeder_uid == nil then
      Gui.mes("building.ranch.no_assigned_breeder")
   end
end
Event.register("elona.on_house_board_queried", "Show ranch info", house_board_ranch_info)

local function house_board_your_home_info(map)
   -- >>>>>>>> shade2/map_user.hsp:206 	if areaId(gArea)=areaShop{ ...
   if not map._archetype == "elona.your_home" then
      return
   end

   local servants = Chara.iter_all(map):filter(Servant.is_servant):length()
   local max = Servant.calc_max_servant_limit(map)

   Gui.mes("building.home.staying.count", servants, max)
end
Event.register("elona.on_house_board_queried", "Show Your Home info", house_board_your_home_info)
