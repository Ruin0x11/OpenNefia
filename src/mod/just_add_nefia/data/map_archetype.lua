local MapEntrance = require("mod.elona_sys.api.MapEntrance")
local Dungeon = require("mod.elona.api.Dungeon")
local Pos = require("api.Pos")
local MapTileset = require("mod.elona_sys.map_tileset.api.MapTileset")
local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Anim = require("mod.elona_sys.api.Anim")
local Effect = require("mod.elona.api.Effect")
local Chara = require("api.Chara")
local Draw = require("api.Draw")
local Mef = require("api.Mef")

local firey_life = {
   _type = "base.map_archetype",
   _id = "firey_life",

   starting_pos = MapEntrance.stairs_up,

   chara_filter = Dungeon.default_chara_filter,

   properties = {
      turn_cost = 10000,
      is_temporary = false,
      has_anchored_npcs = false,
      is_indoor = true,
      types = { "dungeon" },
   }
}

function firey_life.on_map_entered_events(map)
   local ext = map:get_mod_data("just_add_nefia")
   ext.firey_life_turns = 0

   local tileset_tunnel = MapTileset.get("elona.mapgen_tunnel", map)
   local tileset_wall = MapTileset.get("elona.mapgen_wall", map)
   for _, x, y in map:iter_tiles() do
      if Rand.one_in(2) then
         if map:is_floor(x, y) then
            map:set_tile(x, y, "elona.tower_of_fire_tile_1")
         else
            map:set_tile(x, y, "elona.wall_tower_of_fire_top")
         end
      else
         if map:is_floor(x, y) then
            map:set_tile(x, y, tileset_tunnel)
         else
            map:set_tile(x, y, tileset_wall)
         end
      end
   end
end

local function fire_anim(positions, map)
   local tw, th = Draw.get_coords():get_size()
   local make_flame = function(pos)
      if not map:is_in_fov(pos.x, pos.y) then
         return nil
      end
      local sx, sy = Gui.tile_to_screen(pos.x, pos.y)
      return {
         x = sx - tw / 2,
         y = sy - th * 3,
         frame = 0 - Rand.rnd(3)
      }
   end
   local flames = fun.iter(positions):map(make_flame):filter(fun.op.truth):to_list()
   local cb = Anim.ragnarok(flames, true)
   Gui.start_draw_callback(cb)
end

local function cause_fire(map)
   local filter = function(x, y)
      return map:tile(x, y)._id == "elona.tower_of_fire_tile_1"
   end
   local to_pos = function(x, y)
      return { x = x, y = y }
   end
   Gui.update_screen()
   local positions = map:iter_tiles():filter(filter):map(to_pos):to_list()
   fire_anim(positions, map)
   for _, pos in ipairs(positions) do
      local x, y = pos.x, pos.y
      Effect.damage_map_fire(x, y, nil, map)
      if Rand.one_in(20) then
         Mef.create("elona.fire", x, y, { duration = Rand.rnd(15+20), power = 500 * map:calc("level"), origin = nil }, map)
      end
      local chara = Chara.at(x, y, map)
      if chara then
         local damage = map:calc("level") * 50
         chara:damage_hp(damage, "just_add_nefia.firey_life", { element = "elona.fire", element_power = 1000 })
      end
   end
end

function firey_life.on_map_pass_turn(map)
   local curr = {}
   local next = {}

   local sx, sy, ex, ey = 1, 1, map:width() - 2, map:height() - 2

   for _, x, y in Pos.iter_rect(sx, sy, ex, ey) do
      local tile = map:tile(x, y)
      local is_fire = tile._id == "elona.tower_of_fire_tile_1"
         or tile._id == "elona.wall_tower_of_fire_top"

      curr[y] = curr[y] or {}
      curr[y][x] = (is_fire and 1) or 0
      next[y] = next[y] or {}
   end

   local ym1 = ey - 1
   local y = ey
   local yp1 = sy
   for _ = sy, ey do
      local xm1 = ex - 1
      local x = ex
      local xp1 = sy
      for _ = sx, ex do
         local sum = curr[ym1][xm1] + curr[ym1][x] + curr[ym1][xp1] +
            curr[y][xm1] + curr[y][xp1] +
            curr[yp1][xm1] + curr[yp1][x] + curr[yp1][xp1]

         if sum == 2 then
            next[y][x] = curr[y][x]
         elseif sum == 3 then
            next[y][x] = 1
         else
            next[y][x] = 0
         end
         xm1, x, xp1 = x, xp1, xp1+1
      end
      ym1, y, yp1 = y, yp1, yp1+1
   end

   local tileset_tunnel = MapTileset.get("elona.mapgen_tunnel", map)
   local tileset_wall = MapTileset.get("elona.mapgen_wall", map)
   for _, x, y in Pos.iter_rect(sx, sy, ex, ey) do
      local tile = map:tile(x, y)
      local is_fire = tile._id == "elona.tower_of_fire_tile_1"
         or tile._id == "elona.wall_tower_of_fire_top"

      if next[y][x] == 1 and not is_fire then
         if map:is_floor(x, y) then
            map:set_tile(x, y, "elona.tower_of_fire_tile_1")
         else
            map:set_tile(x, y, "elona.wall_tower_of_fire_top")
         end
      elseif next[y][x] == 0 and is_fire then
         if map:is_floor(x, y) then
            map:set_tile(x, y, tileset_tunnel)
         else
            map:set_tile(x, y, tileset_wall)
         end
      end
   end

   local FIRE_STEP = 10
   local ext = map:get_mod_data("just_add_nefia")
   ext.firey_life_turns = ext.firey_life_turns + 1
   if ext.firey_life_turns % FIRE_STEP == FIRE_STEP-1 then
      Gui.play_sound("base.chest1")
      Gui.mes_c("damage.explode_click", "Red")
   elseif ext.firey_life_turns % FIRE_STEP == 0 then
      cause_fire(map)
   end
end

data:add(firey_life)
