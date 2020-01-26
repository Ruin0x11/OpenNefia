local Chara = require("api.Chara")
local Map = require("api.Map")
local Item = require("api.Item")
local MapArea = require("api.MapArea")
local Dialog = require("mod.elona_sys.dialog.api.Dialog")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")

local function load_map(world_map, id)
   local find_home = function(i)
      return i.generator_params.generator == "elona_sys.map_template"
         and i.generator_params.params.id == id
   end
   local home_entrance = MapArea.iter_map_entrances("not_generated", world_map):filter(find_home):nth(1)
   assert(home_entrance)

   local success, map = MapArea.load_map_of_entrance(home_entrance, false)
   if not success then
      error(map)
   end
   return map
end

local function load_towns(world_map)
   local is_town = function(entrance)
      local gen_params = entrance.generator_params

      if gen_params.generator ~= "elona_sys.map_template" then
         return false
      end

      local template = data["elona_sys.map_template"]:ensure(gen_params.params.id)
      local types = table.set(template.copy.types or {})

      return types["town"]
   end

   local entrances = MapArea.iter_map_entrances("not_generated", world_map)
      :filter(is_town)

   for _, entrance in entrances:unwrap() do
      local success, map = MapArea.load_map_of_entrance(entrance, false)
      if not success then
         error(map)
      end
      Map.save(map)
   end
end

local function initialize_player(player)
   player.quality = 2
   Item.create("elona.cargo_travelers_food", nil, nil, {amount=8}, player)
   Item.create("elona.ration", nil, nil, {amount=8}, player)
   Item.create("elona.bottle_of_crim_ale", nil, nil, {amount=2}, player)
   if player:skill_level("elona.literacy") == 0 then
      Item.create("elona.potion_of_cure_minor_wound", nil, nil, {amount=3}, player)
   end

   local klass = data["base.class"][player.class]
   if klass.on_init_player then
      klass.on_init_player(player)
   end

   local skill_bonus = 5 + player:trait_level("elona.extra_bonus_points")
   player.skill_bonus = player.skill_bonus + skill_bonus
   player.total_skill_bonus = player.total_skill_bonus + skill_bonus

   for _, item in player:iter_items() do
      if Item.is_alive(item) then
         item.identify_state = "completely"
      end
   end

   player:refresh()
end

local function create_first_map()
   -- Generate the world map.
   local _, world_map = assert(Map.generate("elona_sys.map_template", { id = "elona.north_tyris" }))

   -- TODO set this up automatically, as "root map" or similar
   local area = save.base.area_mapping:create_area()
   save.base.area_mapping:add_map_to_area(area.uid, world_map.uid)
   area.outer_map_uid = world_map.uid

   return world_map
end

local function start(self, player)
   local world_map = create_first_map()

   -- Load the player's home.
   local home = load_map(world_map, "elona.your_home")
   Map.save(home)
   Map.set_map(home)
   save.base.home_map_uid = home.uid

   -- Load all towns.
   load_towns(world_map)

   -- Save the world map since the entrances on it were modified.
   Map.save(world_map)

   local x, y = data["base.map_entrance"]["base.center"].pos(player, home)
   assert(Map.current():take_object(player, x, y))
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
