local Save = require("api.Save")
local DateTime = require("api.DateTime")
local Const = require("api.Const")
local Area = require("api.Area")
local Chara = require("api.Chara")
local Map = require("api.Map")
local Scene = require("mod.elona_sys.scene.api.Scene")
local Dialog = require("mod.elona_sys.dialog.api.Dialog")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local MapEntrance = require("mod.elona_sys.api.MapEntrance")
local Weather = require("mod.elona.api.Weather")
local Adventurer = require("mod.elona.api.Adventurer")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")

local function load_towns(north_tyris)
   for _, area in Area.iter_in_parent(north_tyris) do
      -- See if there are any maps in this area that need early
      -- initialization.
      if area.metadata.town_floors then
         -- For every floor that is marked to be initialized on save
         -- creation, generate it and initialize things like quest
         -- data. This is so quests that interlink between maps
         -- (delivery, escort) have proper connections to one another
         -- ahead of time.
         for _, floor in ipairs(area.metadata.town_floors) do
            local ok, map = assert(area:load_or_generate_floor(floor))

            -- Initialize quests, etc. in this map. (initialize_map() in events/map_init.lua)
            map:emit("base.on_map_initialize", {load_type = "initialize"})

            Map.save(map)
         end
      end
   end
end

local function start(self, player)
   Sidequest.set_main_quest("elona.main_quest", 0)
   Scene.play("elona.story_0")

   -- >>>>>>>> shade2/main.hsp:457 		gYear		=initYear,initMonth,initDay,1,10	 ..
   save.base.date = DateTime:new(Const.INITIAL_YEAR, Const.INITIAL_MONTH, Const.INITIAL_DAY, 1, 10)
   Weather.change_to("elona.rain", 6)
   -- <<<<<<<< shade2/main.hsp:467 		gWeather	=weatherRain,6 ..

   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")
   local ok, north_tyris = assert(north_tyris_area:load_or_generate_floor(north_tyris_area:starting_floor()))

   -- Load the player's home.
   local your_home_area = Area.create_unique("elona.your_home", north_tyris_area)
   local ok, your_home = assert(your_home_area:load_or_generate_floor(your_home_area:starting_floor()))
   Map.save(your_home)
   Map.set_map(your_home)
   save.base.home_map_uid = your_home.uid

   -- Load all towns.
   load_towns(north_tyris)

   -- Save the world map since we created new entrance feats in it. It also
   -- needs to be saved in order to be used as the previous map, set below.
   Map.save(north_tyris)

   -- Generate adventurers.
   Adventurer.initialize()

   -- NOTE: We have to update the outer map parameters here, or we won't know
   -- what map to travel to when exiting from the edge. This normally gets set
   -- when traveling into a map using stairs, but here we have to do it manually
   -- since we're placing the player into a map by hand.
   --
   -- This is also what vanilla does when starting a new game, so I guess it's
   -- okay.
   -- >>>>>>>> shade2/main.hsp:458 		gWorldX		=22 ..
   your_home:set_previous_map_and_location(north_tyris, 22, 21)
   -- <<<<<<<< shade2/main.hsp:461 		gWorld		=areaNorthTyris ..

   local pos = MapEntrance.center(your_home, player)
   assert(your_home:take_object(player, pos.x, pos.y))

   save.base.about_to_regenerate_world_map = true

   DeferredEvent.add(function()
         local lomias = Chara.find("elona.lomias", "others")
         Dialog.start(lomias, "elona.lomias_game_begin")

         return "player_turn_query"
   end)
end

data:add {
   _type = "base.scenario",
   _id = "elona",

   name = "Normal",

   on_game_start = start
}
