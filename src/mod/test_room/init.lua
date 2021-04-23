--- Code for the quickstart scenario.
local Enum = require("api.Enum")
local Item = require("api.Item")
local Map = require("api.Map")
local Text = require("mod.elona.api.Text")
local Area = require("api.Area")
local ItemMaterial = require("mod.elona.api.ItemMaterial")
local Building = require("mod.elona.api.Building")
local Nefia = require("mod.elona.api.Nefia")
local Rand = require("api.Rand")
local Tools = require("mod.tools.api.Tools")
local Adventurer = require("mod.elona.api.Adventurer")

require("mod.test_room.data")

data:add_multi(
   "base.config_option",
   {
      { _id = "load_towns", type = "boolean", default = false },
   }
)

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

local function on_game_start(self, player)
   local bow = Item.create("elona.long_bow", nil, nil, { ownerless = true })
   local arrow = Item.create("elona.arrow", nil, nil, { ownerless = true })
   bow.curse_state = Enum.CurseState.Normal
   arrow.curse_state = Enum.CurseState.Normal
   player:equip_item(bow, true)
   player:equip_item(arrow, true)

   local armors = { "elona.chain_mail", "elona.composite_helm", "elona.composite_boots", "elona.composite_girdle" }
   for _, _id in ipairs(armors) do
      local armor = Item.create(_id, nil, nil, { ownerless = true })
      armor.curse_state = Enum.CurseState.Normal
      ItemMaterial.change_item_material(armor, "elona.diamond")
      player:equip_item(armor, true)
   end

   Item.create("elona.putitoro", nil, nil, {}, player)
   Item.create("elona.rod_of_identify", nil, nil, {amount=10}, player)
   Item.create("elona.stomafillia", nil, nil, {amount=1000}, player)

   player:heal_to_max()

   player.title = Text.random_title()

   local root_area = Area.create_unique("test_room.test_room", "root")
   local _, map = assert(root_area:load_or_generate_floor(1))

   local north_tyris = Area.create_unique("elona.north_tyris", "root")
   assert(Area.create_entrance(north_tyris, 1, 25, 23, {}, map))
   local ok, north_tyris_map = assert(north_tyris:load_or_generate_floor(north_tyris:starting_floor()))
   if config.test_room.load_towns then
      load_towns(north_tyris_map)
   end

   for _, i, building in data["elona.building"]:iter():enumerate() do
      Building.build(building._id, 50 + i, 22, north_tyris_map)
   end
   for _, i, nefia in data["elona.nefia"]:iter():enumerate() do
      local nefia_area = Nefia.create(nefia._id,  north_tyris, Rand.rnd(10) + 1, 5)
      Nefia.create_entrance(nefia_area, 50 + i, 20, north_tyris_map)
   end
   Map.save(north_tyris_map)

   local your_home = Area.create_unique("elona.your_home", north_tyris)
   assert(Area.create_entrance(your_home, 1, 23, 23, {}, map))

   Map.set_map(map)
   map:take_object(player, 25, 25)

   Adventurer.initialize()

   Tools.powerup(player)
end

data:add {
   _type = "base.scenario",
   _id = "test_room",

   on_game_start = on_game_start
}
