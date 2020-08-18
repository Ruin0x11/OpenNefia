local Save = require("api.Save")
local DateTime = require("api.DateTime")
local Const = require("api.Const")
local Area = require("api.Area")
local Chara = require("api.Chara")
local Map = require("api.Map")
local Item = require("api.Item")
local Scene = require("mod.elona_sys.scene.api.Scene")
local Dialog = require("mod.elona_sys.dialog.api.Dialog")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local Enum = require("api.Enum")
local MapEntrance = require("mod.elona_sys.api.MapEntrance")

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
   Scene.play("elona.story0")

   -- >>>>>>>> shade2/main.hsp:457 		gYear		=initYear,initMonth,initDay,1,10	 ..
   save.base.date = DateTime:new(Const.INITIAL_YEAR, Const.INITIAL_MONTH, Const.INITIAL_DAY, 1, 10)
   -- TODO weather
   -- <<<<<<<< shade2/main.hsp:461 		gWorld		=areaNorthTyris ..

   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")
   local ok, north_tyris = assert(north_tyris_area:load_or_generate_floor(north_tyris_area:starting_floor()))

   -- Load the player's home.
   local your_home_area = Area.create_unique("elona.your_home", north_tyris_area)
   local ok, your_home = assert(your_home_area:load_or_generate_floor(your_home_area:starting_floor()))
   Map.save(your_home)
   Map.set_map(your_home)
   save.base.home_map_uid = your_home.uid

   -- >>>>>>>> shade2/economy.hsp:20 	snd seSave:gosub *game_save ..
   Save.save_game()
   -- <<<<<<<< shade2/economy.hsp:20 	snd seSave:gosub *game_save ..

   -- Load all towns.
   load_towns(north_tyris)

   -- Save the world map since we created new entrance feats in it.
   Map.save(north_tyris)

   local pos = MapEntrance.center(your_home, player)
   assert(your_home:take_object(player, pos.x, pos.y))

   save.base.should_reset_world_map = true

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
