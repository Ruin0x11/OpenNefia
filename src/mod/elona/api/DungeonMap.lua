local Area = require("api.Area")
local Dungeon = require("mod.elona.api.Dungeon")
local Enum = require("api.Enum")
local Feat = require("api.Feat")
local Chara = require("api.Chara")
local Itemgen = require("mod.elona.api.Itemgen")
local Charagen = require("mod.elona.api.Charagen")
local Map = require("api.Map")
local Rand = require("api.Rand")
local Filters = require("mod.elona.api.Filters")
local Calc = require("mod.elona.api.Calc")
local Log = require("api.Log")
local MapTileset = require("mod.elona_sys.map_tileset.api.MapTileset")
local InstancedMap = require("api.InstancedMap")

local DungeonMap = {}

local function populate_rooms(map, creature_packs, has_monster_houses, chara_filter)
   -- >>>>>>>> shade2/map_rand.hsp:175 	rdMonsterHouse	=false ..
   local has_monster_house = false

   local rooms = map.rooms or {}

   for _, room in ipairs(rooms) do
      local x = room.x + 1
      local y = room.y + 1
      local w = room.width - 2
      local h = room.height - 2
      local size = w * h

      for _=1, Rand.rnd(math.floor(size / 8) + 2) do
         if Rand.one_in(2) then
            Itemgen.create(Rand.rnd(w) + x,
                           Rand.rnd(h) + y,
                           {
                              level=Calc.calc_object_level(map.level, map),
                              quality=Calc.calc_object_quality(Enum.Quality.Normal),
                              categories={Filters.dungeon()}
                           },
                           map)
         end

         local filter = chara_filter(map)

         local chara = Charagen.create(Rand.rnd(w) + x, Rand.rnd(h) + y, filter, map)
         if chara then
            if map.level > 3 then
               if (chara.proto.creaturepack or 0) > 0 then
                  if Rand.one_in(creature_packs * 5 + 5) then
                     creature_packs = creature_packs + 1
                     for _ = 1, 10 + Rand.rnd(20) do
                        local filter2 = {
                           level = chara.level,
                           quality = Calc.calc_object_quality(Enum.Quality.Normal),
                           category = chara.proto.creaturepack
                        }
                        Charagen.create(Rand.rnd(w) + x, Rand.rnd(h) + y, filter2, map)
                     end
                     break
                  end
               end
            end
         end
      end

      if not (room.has_stairs_up or room.has_stairs_down) then
         if not has_monster_house or has_monster_houses then
            if Rand.one_in(8) and size < 40 then
               has_monster_house = true
               room.has_monster_house = true

               for ry = y, y + h - 1 do
                  for rx = x, x + w - 1 do
                     local filter = chara_filter(map)
                     Charagen.create(rx, ry, filter, map)
                  end
               end

               if not has_monster_houses then
                  for _=1, Rand.rnd(3) + 1 do
                     Itemgen.create(Rand.rnd(w) + x, Rand.rnd(h) + y, {categories={"elona.container"}}, map)
                  end
               end
            end
         end
      end
   end
   -- <<<<<<<< shade2/map_rand.hsp:222 	loop ..
end

local function place_trap(x, y, level, map)
   -- >>>>>>>> shade2/map_func.hsp:896 #deffunc map_trap  int x ,int y ,int lv ,int type ..
   -- print "trap"
   -- <<<<<<<< shade2/map_func.hsp:919 	return false ..
end

local function place_web(x, y, level, map)
   -- print "web"
end

local function place_pot(x, y, map)
   local dx, dy
   for _=1, 3 do
      if x == nil then
         dx = Rand.rnd(map:width() - 5) + 2
         dy = Rand.rnd(map:height() - 5) + 2
      else
         dx = x
         dy = y
      end
      if Map.is_floor(dx, dy, map) and Feat.at(dx, dy, map):length() == 0 then
         Feat.create("elona.pot", dx, dy, {}, map)
         return true
      end
   end

   return false
end

--- Randomly generates a single dungeon floor, given a generator function.
---
--- The generator is a function that takes an area, floor number and table of
--- dungeon generation parameters and either returns an InstancedMap or nil,
--- depending on if the map was successfully generated.
---
--- This function handles picking out a valid dungeon map by repeatedly calling
--- the generator with a set of random parameters.
function DungeonMap.generate_raw(generator, area, floor, width, height, attempts, on_generate_params, chara_filter)
   attempts = attempts or 2000

   local dungeon, err
   local gen_params = {}

   for attempt = 1, attempts do
      Rand.set_seed()

      local w = width or (34 + Rand.rnd(15))
      local h = height or (22 + Rand.rnd(15))

      gen_params = {
         width = w,
         height = h,
         room_count = w * w / 70,
         min_size = 3,
         max_size = 4,
         extra_room_count = 10,
         room_entrance_count = 1,
         tunnel_length = w * h,
         hidden_path_chance = 5,
         creature_packs = 1,
         level = floor,
         max_crowd_density = w * h / 100,
         chara_filter = chara_filter,
         generation_attempt = attempt
      }

      if on_generate_params then
         gen_params = on_generate_params(gen_params)
         assert(type(gen_params) == "table")
      end

      dungeon, err = generator(floor, gen_params)

      if dungeon then
         assert(class.is_an(InstancedMap, dungeon))
         break
      end
   end

   return dungeon, gen_params
end

local function find_feat(map, _id)
   local pred = function(feat) return feat._id == _id end
   return map:iter_feats():filter(pred):nth(1)
end

-- TODO: Allow reversing direction.
local function connect_stairs(map, area, floor)
   local down = find_feat(map, "elona.stairs_down")
   if down then
      down.params.area_uid = area.uid
      down.params.area_floor = floor + 1
   end

   local up = find_feat(map, "elona.stairs_up")
   if up then
      local area_uid
      local area_floor
      if floor == 1 then
         local parent_area = assert(Area.parent(area))
         area_uid = parent_area.uid
         area_floor = parent_area:starting_floor() -- TODO find entrance of map in parent area?
      else
         area_uid = area.uid
         area_floor = floor - 1
      end

      up.params.area_uid = area_uid
      up.params.area_floor = area_floor
   else
      Log.warn("No up stairs in dungeon.")
   end
end

--- Generates a single floor of a dungeon, separate from other floors.
---
--- It needs to be added to an area later, as part of a set of dungeon
--- floors.
function DungeonMap.generate(area, floor, generator, opts)
   opts = opts or {}
   local width = opts.width
   local height = opts.height
   local attempts = opts.attempts
   local has_monster_houses = opts.has_monster_houses
   local chara_filter = opts.chara_filter
   local map_archetype_id = opts.map_archetype_id or nil

   local map, gen_params = DungeonMap.generate_raw(generator, area, floor, width, height, attempts, opts.on_generate_params, chara_filter)

   if map == nil then
      return nil
   end

   if map_archetype_id then
      map:set_archetype(map_archetype_id, { set_properties = true })
   end

   map.level = opts.level or map.level
   chara_filter = chara_filter or Dungeon.random_chara_filter(map)

   local tileset = opts.tileset or map.tileset or "elona.dungeon"
   map.tileset = tileset
   MapTileset.apply(tileset, map)

   Log.debug("Populating dungeon rooms.")
   populate_rooms(map, gen_params.creature_packs, has_monster_houses, chara_filter)

   -- HACK: Block the starting positions so nothing gets generated
   -- there. This was done in Elona by just placing the player on the
   -- stairs in the map during the generation routine, but here the
   -- map is generated independent of which map the player is in.

   local blocks = {}
   for _, feat in Feat.iter(map) do
      if feat._id == "elona.stair_up" or feat._id == "elona.stair_down" then
         blocks[#blocks+1] = assert(Feat.create("elona.mapgen_block", feat.x, feat.y, {}, map))
         assert(not Map.can_access(feat.x, feat.y, map))
      end
   end

   local crowd_density = map:calc("max_crowd_density")
   local mob_density, item_density = crowd_density / 4, crowd_density / 4

   if opts.calc_density then
      local result = opts.calc_density(map)
      mob_density = result.mob or mob_density
      item_density = result.item or item_density
   end

   DungeonMap.add_mobs_and_traps(map, crowd_density, mob_density, item_density, chara_filter)

   if opts.properties then
      for k, v in pairs(opts.properties) do
         map[k] = v
      end
   end

   if opts.after_generate then
      opts.after_generate(map)
   end

   for _, block in ipairs(blocks) do
      block:remove_ownership()
   end

   Log.debug("Connecting stairs.")
   connect_stairs(map, area, floor)

   Log.debug("Generation finished: %d", map.uid)

   return map
end

function DungeonMap.add_mobs_and_traps(dungeon, crowd_density, mob_density, item_density, chara_filter)
   Log.debug("Map density: %s", crowd_density)

   Log.debug("Creating %d mobs.", mob_density)
   for _=1, mob_density do
      Charagen.create(nil, nil, chara_filter(dungeon), dungeon)
   end

   Log.debug("Creating %d items.", item_density)
   for _=1, item_density do
      Itemgen.create(nil, nil,
                     {
                        level = dungeon.level,
                        quality = 1,
                        categories = {Filters.dungeon()}
                     },
                     dungeon)
   end

   Log.debug("Placing traps.")
   for _=0, Rand.rnd(dungeon:width() * dungeon:height() / 80) do
      place_trap(0, 0, dungeon.level, dungeon)
   end

   if Rand.one_in(5) then
      local n = Rand.rnd(dungeon:width() * dungeon:height() / 40)
      if Rand.one_in(5) then
         n = Rand.rnd(dungeon:width() * dungeon:height() / 5)
      end
      for _=1, n do
         place_web(0, 0, dungeon.level * 10 + 100, dungeon)
      end
   end

   if Rand.one_in(4) then
      local n = math.clamp(Rand.rnd(dungeon:width() * dungeon:height() / 500 + 1) + 1, 3, 15)
      for _=1, n do
         place_pot(nil, nil, dungeon)
      end
   end

   if not dungeon.is_temporary then
      local kill_count = 0
      if Rand.one_in(15 + kill_count * 2) then
         Chara.create("elona.little_sister", nil, nil, {}, dungeon)
      end
   end
end

return DungeonMap
