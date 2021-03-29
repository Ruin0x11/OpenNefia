local Calc = require("mod.elona.api.Calc")
local Gui = require("api.Gui")
local MapgenUtils = require("mod.elona.api.MapgenUtils")
local Event = require("api.Event")
local Effect = require("mod.elona.api.Effect")
local Home = require("mod.elona.api.Home")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local DeferredEvents = require("mod.elona.api.DeferredEvents")
local ElonaWorld = require("mod.elona.api.ElonaWorld")
local ExHelp = require("mod.elona.api.ExHelp")

local function spawn_random_sites(map, params)
   local amount = Calc.calc_random_site_generate_count(map)

   for _ = 1, amount do
      MapgenUtils.spawn_random_site(map, params.is_first_renewal, nil, nil)
   end
end
Event.register("base.on_map_renew_major", "Spawn random sites", spawn_random_sites, { priority = 250000 })

-- >>>>>>>> shade2/map.hsp:2122 	if mCanSave=true{ ...
local function spoil_items_on_enter(map)
   if not map.is_temporary then
      Effect.spoil_items(map)
   end
end
Event.register("base.on_map_entered", "Spoil items on enter", spoil_items_on_enter, 150000)
-- <<<<<<<< shade2/map.hsp:2124 		} ..


local function welcome_home(map)
   -- >>>>>>>> shade2/system.hsp:23 	if gArea=areaHome{ ...
   if Home.is_home(map) then
      DeferredEvent.add(function() DeferredEvents.welcome_home(map) end)
   end
   -- <<<<<<<< shade2/system.hsp:28 		} ..
end
Event.register("base.on_map_entered", "Make servants welcome the player", welcome_home, 100000)

local function generate_initial_nefias(map)
   -- >>>>>>>> shade2/map.hsp:917 	if gArea=areaNorthTyris{ ...
   if not map:has_type("world_map") then
      return
   end

   ElonaWorld.generate_random_nefias(map)
-- <<<<<<<< shade2/map.hsp:921 	} ..
end
Event.register("base.on_map_renew_major", "Generate initial world map nefias", generate_initial_nefias, 100000)

local function update_world_map(map)
   -- >>>>>>>> shade2/map.hsp:2067 	if areaType(gArea)=mTypeWorld{ ...
   local is_world_map = map:has_type("world_map")
   Gui.set_draw_layer_enabled("elona.cloud", is_world_map)
   if is_world_map then
      ElonaWorld.proc_world_regenerate(map)
   end
   -- <<<<<<<< shade2/map.hsp:2070 		} ..
end
Event.register("base.on_map_entered", "Update world map", update_world_map, 90000)

local function show_first_ex_help(map, params)
   -- >>>>>>>> shade2/map.hsp:124 	if mType=mTypeHome 	: help 1 ...
   if params.previous_map and Home.is_home(params.previous_map) then
      ExHelp.show("elona.first")
   end
   -- <<<<<<<< shade2/map.hsp:124 	if mType=mTypeHome 	: help 1 ..
end
Event.register("base.on_map_entered", "Show first EX help", show_first_ex_help, 10000)

local function show_map_ex_help(map, params)
   -- >>>>>>>> shade2/map.hsp:2137 	if mType=mTypeWorld	: help 2 ...
   if map:has_type("world_map") then
      ExHelp.show("elona.world_map")
   end

   if map:has_type("town") then
      ExHelp.show("elona.town")
   end

   if map._archetype == "elona.shelter" then
      ExHelp.show("elona.shelter")
   end
   -- <<<<<<<< shade2/map.hsp:2139 	if gArea=areaShelter	: help 14 ..
end
Event.register("base.after_map_changed", "Show map EX help", show_map_ex_help, 10000)

local function show_role_ex_help(chara)
   -- >>>>>>>> shade2/chat.hsp:44 	if cRole(tc)=cRoleShopInn :help 7,1 ...
   if chara:find_role("elona.innkeeper") then
      ExHelp.show("elona.innkeeper")
   end

   if chara:find_role("elona.trainer") then
      ExHelp.show("elona.trainer")
   end
   -- <<<<<<<< shade2/chat.hsp:45 	if cRole(tc)=cRoleTrainer :help 8,1 ..
end
Event.register("elona_sys.on_chara_dialog_start", "Show role EX help", show_role_ex_help, 10000)
