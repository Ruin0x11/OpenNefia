local Rand = require("api.Rand")
local Gui = require("api.Gui")
local Event = require("api.Event")
local ElonaBuilding = require("mod.elona.api.ElonaBuilding")
local Map = require("api.Map")
local Area = require("api.Area")
local Gardening = require("mod.elona.api.Gardening")
local Feat = require("api.Feat")

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
   local area = Area.for_map(map)
   if area._archetype == "elona.museum" then
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
