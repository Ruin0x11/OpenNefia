local Feat = require("api.Feat")
local Chara = require("api.Chara")
local Itemgen = require("mod.tools.api.Itemgen")
local Charagen = require("mod.tools.api.Charagen")
local Pos = require("api.Pos")
local Map = require("api.Map")
local InstancedMap = require("api.InstancedMap")
local Rand = require("api.Rand")
local Filters = require("mod.elona.api.Filters")
local Calc = require("mod.elona.api.Calc")

data:add_type {
   name = "dungeon_template",
   schema = schema.Record {
      generator = schema.Function
   }
}

data:add_multi(
   "base.map_tile",
   {
      {
         _id = "mapgen_floor",
         image = "mod/elona/graphic/map_tile/0_0.png",
         is_solid = false
      },
      {
         _id = "mapgen_tunnel",
         image = "mod/elona/graphic/map_tile/0_1.png",
         is_solid = false
      },
      {
         _id = "mapgen_wall",
         image = "mod/elona/graphic/map_tile/0_2.png",
         is_solid = true
      },
      {
         _id = "mapgen_room",
         image = "mod/elona/graphic/map_tile/0_3.png",
         is_solid = false
      },
      {
         _id = "mapgen_floor_2",
         image = "mod/elona/graphic/map_tile/0_3.png",
         is_solid = false
      },
})

local function connect_stairs(map, outer_map, area_uid, dungeon_level)
   local pred

   pred = function(feat) return feat._id == "elona.stairs_down" end
   local down = map:iter_feats():filter(pred):nth(1)

   if down then
      down.generator_params = { generator = "elona.dungeon_template", params = {dungeon_level = dungeon_level + 1} }
      down.area_params = area_uid
   end

   pred = function(feat) return feat._id == "elona.stairs_up" end
   local up = map:iter_feats():filter(pred):nth(1)
   assert(up)
   up._outer_map_id = outer_map.uid

   return up.x, up.y
end

local function convert_tiles(map)
   local lookup = {
      ["elona.mapgen_floor"] = "elona.hardwood_floor_1",
      ["elona.mapgen_tunnel"] = "elona.red_floor",
      ["elona.mapgen_wall"] = "elona.wall_decor_top",
      ["elona.mapgen_room"] = "elona.cyber_1",
      ["elona.mapgen_floor_2"] = "elona.hardwood_floor_1",
   }

   for _, x, y in Pos.iter_rect(0, 0, map:width() - 1, map:height() - 1) do
      local old = Map.tile(x, y, map)._id
      local new = lookup[old]
      assert(new, old)
      Map.set_tile(x, y, new, map)
   end
end

local function generate_dungeon_raw(id, width, height, gen_params)
   local template = data["elona.dungeon_template"]:ensure(id)

   local map = InstancedMap:new(width, height)
   map:clear("elona.mapgen_wall")
   map.dungeon_level = gen_params.dungeon_level
   map.deepest_dungeon_level = gen_params.deepest_dungeon_level
   assert(map.dungeon_level)
   assert(map.deepest_dungeon_level)
   map.max_crowd_density = math.floor(width * height / 100)

   local err
   local rooms = {}

   map, err = template.generate(map, rooms, gen_params)
   if not map then
      return nil, err
   end

   map.rooms = rooms

   return map
end

local function set_filter()
   return {
      level = Calc.calc_object_level(10),
      quality = Calc.calc_object_quality(1),
   }
end

local function populate_rooms(dungeon, template, gen_params)
   local has_monster_house = false

   for _, room in ipairs(dungeon.rooms) do
      local x = room.x + 1
      local y = room.y + 1
      local w = room.width - 2
      local h = room.height - 2
      local size = w * h

      for i=1, Rand.rnd(math.floor(size / 8) + 2) do
         if Rand.one_in(2) then
            Itemgen.create(Rand.rnd(w) + x,
                           Rand.rnd(h) + y,
                           {
                              level=dungeon.dungeon_level,
                              quality=1,
                              categories={Filters.dungeon()}
                           },
                           dungeon)
         end

         local filter = set_filter()

         local chara = Charagen.create(Rand.rnd(w) + x, Rand.rnd(h) + y, filter, dungeon)
         if chara then
            if dungeon.dungeon_level > 3 then
               if (chara.proto.creaturepack or 0) > 0 then
                  if Rand.one_in(gen_params.creature_packs * 5 + 5) then
                     gen_params.creature_packs = gen_params.creature_packs + 1
                     for _=1, 10 + Rand.rnd(20) do
                        local filter2 = { level = chara.level, quality = Calc.calc_object_quality(1) }
                        Charagen.create(Rand.rnd(w) + x, Rand.rnd(h) + y, filter2, dungeon)
                     end
                     break
                  end
               end
            end
         end
      end

      if not (room.has_stairs_up or room.has_stairs_down) then
         if not has_monster_house or template.has_monster_houses then
            if Rand.one_in(8) and size < 40 then
               has_monster_house = true
               room.has_monster_house = true

               for ry = y, y + h - 1 do
                  for rx = x, x + w - 1 do
                     local filter = set_filter()
                     Charagen.create(rx, ry, filter, dungeon)
                  end
               end

               if not template.has_monster_houses then
                  for _=1, Rand.rnd(3) + 1 do
                     Itemgen.create(Rand.rnd(w) + x, Rand.rnd(h) + y, {categories={"elona.container"}}, dungeon)
                  end
               end
            end
         end
      end
   end
end

local function place_trap(x, y, level, map)
   print "trap"
end

local function place_web(x, y, level, map)
   print "web"
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

local function generate_dungeon(self, params, opts)
   local dungeon

   local deepest_dungeon_level

   if opts.area.uid then
      local area = save.base.area_mapping:get_data_of_area(opts.area.uid)
      deepest_dungeon_level = area.data.deepest_dungeon_level
   else
      deepest_dungeon_level = params.deepest_dungeon_level
   end

   assert(params.dungeon_level)
   local dungeon_level = params.dungeon_level

   local gen_params = {
      min_size = 3,
      max_size = 4,
      room_count = 3,
      room_entrance_count = 1,
      hidden_path_chance = 5,
      creature_packs = 1,
      dungeon_level = dungeon_level,
      deepest_dungeon_level = deepest_dungeon_level
   }

   while true do
      local id = params.id
      assert(id)
      local width = params.width or 34 + Rand.rnd(15)
      local height = params.height or 22 + Rand.rnd(15)

      local err
      dungeon, err = generate_dungeon_raw(id, width, height, gen_params)

      if dungeon then
         break
      end
   end

   convert_tiles(dungeon)

   opts.area.deepest_dungeon_level = params.deepest_dungeon_level

   dungeon.dungeon_level = params.dungeon_level
   assert(dungeon.dungeon_level)

   local start_x, start_y = connect_stairs(dungeon, opts.outer_map, opts.area.uid, params.dungeon_level)

   dungeon.player_start_pos = {
      x = start_x,
      y = start_y
   }

   local template = data["elona.dungeon_template"]:ensure(params.id)

   populate_rooms(dungeon, template, gen_params)

   local crowd_density = dungeon:calc("max_crowd_density")
   local mob_density, item_density = crowd_density / 4, crowd_density / 4

   if template.calc_density then
      mob_density, item_density = template.calc_density(dungeon)
   end

   for _=1, mob_density do
      Charagen.create(Rand.rnd(dungeon:width()), Rand.rnd(dungeon:height()), set_filter(), dungeon)
   end

   for _=1, item_density do
      Itemgen.create(Rand.rnd(dungeon:width()), Rand.rnd(dungeon:height()),
                     {
                        level = dungeon.dungeon_level,
                        quality = 1,
                        categories = {Filters.dungeon()}
                     },
                     dungeon)
   end

   ---

   for _=0, Rand.rnd(dungeon:width() * dungeon:height() / 80) do
      place_trap(0, 0, dungeon.dungeon_level, dungeon)
   end

   if Rand.one_in(5) then
      local n = Rand.rnd(dungeon:width() * dungeon:height() / 40)
      if Rand.one_in(5) then
         n = Rand.rnd(dungeon:width() * dungeon:height() / 5)
      end
      for _=1, n do
         place_web(0, 0, dungeon.dungeon_level * 10 + 100, dungeon)
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
         Chara.create("elona.little_sister")
      end
   end

   -- TODO need some ID for each area that isn't necessarily unique
   if opts.area.outer_map_id == "elona.lesimas" then
   end

   return dungeon
end

data:add {
   _type = "base.map_generator",
   _id = "dungeon_template",

   params = {id = "string", width = "number", height = "number", dungeon_level = "number", deepest_dungeon_level = "number", area_id = "string"},
   generate = generate_dungeon,

   almost_equals = table.deepcompare
}
