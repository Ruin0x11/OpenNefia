local Chara = require("api.Chara")
local Map = require("api.Map")
local Gui = require("api.Gui")
local Feat = require("api.Feat")
local Input = require("api.Input")
local InstancedArea = require("api.InstancedArea")
local Area = require("api.Area")
local Item = require("api.Item")
local Log = require("api.Log")
local Prompt = require("api.gui.Prompt")

local Building = {}

function Building.iter(map)
   return Area.iter(map):filter(function(_, a) return a.metadata.is_player_owned end)
end

function Building.find_worker(map, chara_uid)
   local obj = map:get_object_of_type("base.chara", chara_uid)
   if Chara.is_alive(obj) then
      return obj
   end

   obj = save.base.staying_charas:get_object(chara_uid)
   if obj then
      return obj
   end

   return nil
end

function Building.update_map(area, floor_no, cb)
   if type(area) == "number" then
      area = Area.get(area)
   end

   -- TODO multiple shop maps per area (#178)
   local ok, floor = area:get_floor(floor_no)
   if not ok then
      Log.warn("Missing building floor %d", floor_no)
      return false
   end

   -- Be careful not to load the map from disk again if it's loaded already.
   local map, needs_save
   if floor.uid == Map.current().uid then
      map = Map.current()
   else
      needs_save = true
      ok, map = area:load_floor(floor_no)
      if not ok then
         Log.warn("Missing building floor %d", floor_no)
         return false
      end
   end

   cb(map, area)

   if needs_save then
      Map.save(map)
   end

   return true
end

function Building.query_build(deed)
   local player = Chara.player()
   local x = player.x
   local y = player.y
   local map = player:current_map()
   if not Map.is_world_map(map) then
      Gui.mes("building.can_only_use_in_world_map")
      return false
   end

   if Feat.at(x, y, map):length() > 0 then
      Gui.mes("building.cannot_build_it_here")
      return false
   end

   if Building.iter(map):length() > 300 then
      Gui.mes("building.cannot_build_anymore")
      return false
   end

   Gui.mes("building.really_build_it_here")
   if not Input.yes_no() then
      return false
   end

   return true
end

function Building.build(building_id, x, y, map)
   local proto = data["elona.building"]:ensure(building_id)

   return Building.build_area(proto.area_archetype_id, x, y, map, proto.tax_cost)
end

function Building.build_area(area_archetype_id, x, y, map, tax_cost)
   local area = InstancedArea:new(area_archetype_id)
   local floor = 1

   area.metadata.is_player_owned = true
   Area.register(area, { parent = Area.for_map(map) })
   Area.create_entrance(area, floor, x, y, {}, map)

   -- TODO make this into table instead of list, to force uniqueness per
   -- area/map?
   local metadata = {
      area_archetype_id = area._archetype,
      area_uid = area.uid,
      name = area.name,
      tax_cost = tax_cost or 0,
      floor = floor,
   }

   table.insert(save.elona.player_owned_buildings, metadata)

   return area, metadata
end

function Building.iter_in_area(area)
   return fun.iter(save.elona.player_owned_buildings):filter(function(m) return m.area_uid == area.uid end)
end

function Building.for_map(map)
   local area = Area.for_map(map)
   if area == nil then
      return nil
   end
   local floor = Map.floor_number(map)
   if floor == nil then
      return nil
   end
   return Building.iter_in_area(area):filter(function(i) return i.floor == floor end):nth(1)
end

function Building.map_is_building(map, area_archetype_id)
   data["base.area_archetype"]:ensure(area_archetype_id)
   local building = Building.for_map(map)
   return building and building.area_archetype_id == area_archetype_id
end

function Building.find_home_area_and_entrances(world_map)
   local home_map_uid = save.base.home_map_uid
   local home_area

   local world_area = Area.for_map(world_map)
   for _, _, area in Area.iter_children(world_area) do
      for floor, map_metadata in pairs(area.maps) do
         if map_metadata.uid == home_map_uid then
            home_area = area
            break
         end
      end
      if home_area then
         break
      end
   end

   if home_area == nil then
      return nil
   end

   local is_home_entrance = function(feat)
      return feat.params and feat.params.area_uid == home_area.uid
   end

   local home_entrances = Area.iter_entrances_in_parent(world_map):filter(is_home_entrance):to_list()

   return home_area, home_entrances
end

local function migrate_homes(old_home_area, new_home_area)
   -- We need to make sure all the characters and items in all the floors of
   -- the old home get placed into the new home properly.
   for old_floor, map_metadata in pairs(old_home_area.maps) do
      local old_floor_map_uid = map_metadata.uid
      local ok, new_floor_map = assert(new_home_area:load_or_generate_floor(old_floor))
      local ok, old_floor_map = assert(Map.load(old_floor_map_uid))

      local cx = math.floor(new_floor_map:width() / 2)
      local cy = math.floor(new_floor_map:height() / 2)
      local place_x, place_y = assert(Map.find_free_position(cx, cy, { allow_stacking = true, only_map = true, force = true }, new_floor_map))

      for _, item in Item.iter(old_floor_map) do
         assert(new_floor_map:take_object(item, place_x, place_y))
      end

      for _, chara in Chara.iter_all(old_floor_map) do
         local success = Map.try_place_chara(chara, cx, cy, new_floor_map)
         if not success then
            Log.warn("Couldn't find a spot for character '%s' in new home map", tostring(chara))
         end
      end

      -- We will not move anything else, like mefs or feats, for the time being.
      Map.save(old_floor_map)
      Map.save(new_floor_map)
   end
end

function Building.build_home(home_id, x, y, world_map)
   local home_proto = data["elona.home"]:ensure(home_id)

   local world_area = Area.for_map(world_map)
   local new_home_area = InstancedArea:new("elona.your_home")
   new_home_area.metadata.is_player_owned = true

   -- This will change what kind of map gets created by
   -- new_home_area:load_or_generate_floor() in migrate_homes().
   --
   -- TODO maybe area archetypes should have a params table...
   save.elona.home_rank = home_id

   -- TODO this has to handle entrances to the home in more than one world map
   -- at some point, if we're really going to be robust. (see: #174)
   local old_home_area, old_home_entrances = Building.find_home_area_and_entrances(world_map)
   if old_home_area ~= nil then
      migrate_homes(old_home_area, new_home_area)
      for _, old_home_entrance in ipairs(old_home_entrances) do
         old_home_entrance:remove_ownership()
      end
      Area.delete(old_home_area)
   end

   -- TODO world map nefia refresh

   local entrance = assert(Area.create_entrance(new_home_area, 1, x, y, {}, world_map))
   entrance.image = home_proto.image

   local ok, new_home_map = assert(new_home_area:load_or_generate_floor(new_home_area:starting_floor()))
   save.base.home_map_uid = new_home_map.uid

   Area.set_unique("elona.your_home", new_home_area, world_area)
   return new_home_map, new_home_area
end

function Building.query_house_board()
   -- >>>>>>>> shade2/action.hsp:1808 	case effShop ...
   local map = Map.current()

   if not map or not map:has_type("player_owned") then
      Gui.mes("action.use.house_board.cannot_use_it_here")
      return
   end
   -- <<<<<<<< shade2/action.hsp:1811 	swbreak ..


   -- >>>>>>>> shade2/map_user.hsp:192 *com_home ...
   if not map:has_type("player_owned") and not config.base.development_mode then
      Gui.mes("building.house_board.only_use_in_home")
      return
   end

   local function is_furniture(item)
      return item:has_category("elona.furniture")
   end

   local items = Item.iter(map)
   local item_count = items:length()
   local furniture_count = items:filter(is_furniture):length()
   local max_item_count = map:calc("item_on_floor_limit") or 0

   Gui.mes("building.house_board.item_count", map.name, item_count, furniture_count, max_item_count)

   map:emit("elona.on_house_board_queried")

   while true do
      Gui.mes("building.house_board.what_do")

      local actions = {}
      map:emit("elona.on_build_house_board_actions", {}, actions)

      if #actions == 0 then
         Log.error("No interact actions returned from `elona_sys.on_build_interact_actions`.")
         Gui.mes("common.it_is_impossible")
         break
      end

      --[[
         actions = {
         { text = "action.interact.choices.talk", key = "a", callback = function(map) ... end }
         }
      --]]

      local to_prompt_item = function(t)
         assert(type(t.text) == "string", "Action must have 'text' defined")
         assert(type(t.callback) == "function", "Action must have 'callback' defined")
         return { text = t.text or "", key = t.key or nil }
      end

      local prompt_items = fun.iter(actions):map(to_prompt_item):to_list()
      local result, canceled = Prompt:new(prompt_items):query()

      if canceled then
         break
      end

      local choice = assert(actions[result.index])

      choice.callback(map)
   end

   return "player_turn_query"
   -- <<<<<<<< shade2/map_user.hsp:245  ..
end

return Building
