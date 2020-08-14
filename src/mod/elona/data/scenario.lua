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

-- TODO: move this into an event, to be shared by multiple scenarios.
local function initialize_player(player)
   -- >>>>>>>> shade2/chara.hsp:539 *cm_finishPC ..
   player.quality = Enum.Quality.Normal
   Item.create("elona.cargo_travelers_food", nil, nil, {amount=8}, player)
   Item.create("elona.ration", nil, nil, {amount=8}, player)
   Item.create("elona.bottle_of_crim_ale", nil, nil, {amount=2}, player)
   if player:skill_level("elona.literacy") == 0 then
      Item.create("elona.potion_of_cure_minor_wound", nil, nil, {amount=3}, player)
   end

   local klass = data["base.class"]:ensure(player.class)
   if klass.on_init_player then
      klass.on_init_player(player)
   end

   local skill_bonus = 5 + player:trait_level("elona.perm_skill_point")
   player.skill_bonus = player.skill_bonus + skill_bonus
   player.total_skill_bonus = player.total_skill_bonus + skill_bonus

   for _, item in player:iter_items() do
      if Item.is_alive(item) then
         item.identify_state = Enum.IdentifyState.Full
      end
   end

   player:refresh()
   -- <<<<<<<< shade2/chara.hsp:579 	return ..
end

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
   initialize_player(player)

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
