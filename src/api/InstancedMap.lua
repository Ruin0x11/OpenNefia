local data = require("internal.data")
local multi_pool = require("internal.multi_pool")
local save = require("internal.global.save")

local Pos = require("api.Pos")
local IEventEmitter = require("api.IEventEmitter")
local IModdable = require("api.IModdable")
local Draw = require("api.Draw")
local ILocation = require("api.ILocation")
local ITypedLocation = require("api.ITypedLocation")

local InstancedMap = class.class("InstancedMap", { ITypedLocation, IModdable, IEventEmitter })

local fov_cache = {}

local function gen_fov_radius(fov_max)
   if fov_cache[fov_max] then
      return fov_cache[fov_max]
   end

   local radius = math.floor((fov_max + 2) / 2)
   local max_dist = math.floor(fov_max / 2)

   local fovmap = {}

   for y=0,fov_max+1 do
      fovmap[y] = {}
      for x=0,fov_max+1 do
         fovmap[y][x] = Pos.dist(x, y, radius, radius) < max_dist
      end
   end

   local fovlist = table.of(function() return {0, 0} end, fov_max + 2)

   for y=0,fov_max+1 do
      local found = false
      for x=0,fov_max+1 do
         if fovmap[y][x] == true then
            if not found then
               fovlist[y][1] = x
               found = true
            end
         elseif found then
            fovlist[y][2] = x
            break
         end
      end
   end

   fov_cache[fov_max] = fovlist

   return fov_cache[fov_max]
end

function InstancedMap:init(width, height, uids, tile)
   IModdable.init(self)
   IEventEmitter.init(self)

   self.uid = save.base.map_uids:get_next_and_increment()

   uids = uids or save.base.uids
   tile = tile or "base.floor"

   if width <= 0 or height <= 0 then
      error("Maps must be at least 1 tile wide and long.")
   end

   self._width = width
   self._height = height

   self._multi_pool = multi_pool:new(width, height, uids)
   self._last_sight_id = 1
   self._in_sight = table.of(0, width * height)

   -- Map of shadows to be drawn. This is coordinate-local to the
   -- visible screen area only, with (1, 1) being the tile at the
   -- upper left corner of the game window.
   self._shadow_map = {}

   -- Locations that are treated as solid. Can be changed by mods to
   -- make objects that act solid, like map features.
   self._solid = table.of(false, width * height)

   -- Locations that are treated as opaque. Can be changed by mods to
   -- make objects that act opaque.
   self._opaque = table.of(false, width * height)

   -- Memory data produced by map objects. These are expected to be
   -- interpreted by each rendering layer.
   self._memory = {}

   -- Ambient light information. See IItem.light.
   self._light = {}

   self._tiles = table.of({}, width * height)
   self._tiles_dirty = {}
   self._uids = uids

   self.default_tile = "base.floor"

   self:init_map_data()

   self:clear(tile)
end

function InstancedMap:on_refresh()
   IModdable.on_refresh(self)
end

local fallbacks = {
   turn_cost = 10000,
   is_indoor = false,
   dungeon_level = 1,
   deepest_dungeon_level = 1,
   player_start_pos = nil,
   types = {},
   appearance = "",
   tileset = "elona.dirt",
   tile_type = 2,
   default_ai_calm = 1,
   crowd_density = 0,
   max_crowd_density = 40,
   is_user_map = false,
   has_anchored_npcs = false,
   reveals_fog = false,
   name = "",
   item_limit = nil,

   is_generated_every_time = false,
   is_not_regenerated = false,
   is_temporary = false,
   can_exit_from_edge = true,
   cannot_mine_items = nil,

   next_regenerate_date = 0,
   visit_times = 0
}

function InstancedMap:init_map_data()
   self:mod_base_with(fallbacks, "merge")
   self:emit("base.on_build_map")
end

function InstancedMap:has_type(ty)
   if type(ty) == "table" then
      for _, t in ipairs(ty) do
         assert(type(t) == "string")
         if self:has_type(t) then
            return true
         end
      end
   else
      for _, v in ipairs(self.types) do
         if v == ty then
            return true
         end
      end
   end

   return false
end

function InstancedMap:width()
   return self._width
end

function InstancedMap:height()
   return self._height
end

function InstancedMap:shadow_map()
   return self._shadow_map
end

function InstancedMap:clear(tile)
   for x=0,self._width-1 do
      for y=0,self._height-1 do
         self:set_tile(x, y, tile)
      end
   end
end

local function _iter_tiles(state, prev_index)
   if state.iter == nil then
      return nil
   end

   local next_index, dat = state.iter(state.state, prev_index)

   if next_index == nil then
      return nil
   end

   local x = (next_index-1) % state.width
   local y = math.floor((next_index-1) / state.width)

   return next_index, x, y, dat
end

function InstancedMap:iter_tiles()
   local inner_iter, inner_state, inner_index = pairs(self._tiles)
   local state = {
      iter = inner_iter,
      state = inner_state,
      width = self:width(),
   }
   return fun.wrap(_iter_tiles, state, inner_index)
end

function InstancedMap:iter_tile_memory()
   return fun.range(self._width * self._height):map(function(i) return (self._memory["base.map_tile"] or {})[i] end)
end

function InstancedMap:set_tile(x, y, id)
   local tile = data["base.map_tile"]:ensure(id)

   if not self:is_in_bounds(x, y) then
      return
   end

   self._tiles[y*self._width+x+1] = tile

   self:refresh_tile(x, y)

   self._tiles_dirty[#self._tiles_dirty] = {x, y}
end

function InstancedMap:tile(x, y)
   return self._tiles[y*self._width+x+1]
end

function InstancedMap:memory(x, y, kind)
   return self._memory[kind][y*self._width+x+1]
end

function InstancedMap:light(x, y)
   return self._light[y*self._width+x+1]
end

--- Returns true if there is an unblocked line of sight that is
--- completely within player-visible tiles between two points. This
--- includes tiles that are outside the game window.
---
--- @tparam int x1
--- @tparam int y1
--- @tparam int x2
--- @tparam int y2
--- @treturn bool
function InstancedMap:has_los(x1, y1, x2, y2)
   local cb = function(x, y)
      return self:can_see_through(x, y)
      -- in Elona, the final tile is visible even if it is solid.
         or (x == x2 and y == y2)
   end
   return Pos.iter_line(x1, y1, x2, y2):all(cb)
end

--- Calculates the positions that can be seen by the player and are
--- contained in the game window.
-- @tparam int player_x
-- @tparam int player_y
-- @tparam int fov_radius
function InstancedMap:calc_screen_sight(player_x, player_y, fov_size)
   local stw = math.min(Draw.get_tiled_width(), self._width)
   local sth = math.min(Draw.get_tiled_height(), self._height)

   self._shadow_map = {}
   for i=0,stw + 4 do
      self._shadow_map[i] = {}
      for j=0,sth + 4 do
         self._shadow_map[i][j] = 0
      end
   end

   local fov_radius = gen_fov_radius(fov_size)
   local radius = math.floor((fov_size + 2) / 2)
   local max_dist = math.floor(fov_size / 2)

   -- The shadowmap has extra space at the edges, to make shadows at
   -- the edge of the map display correctly, so offset the start and
   -- end positions by 1.
   local start_x = math.clamp(player_x - math.floor(stw / 2), 0, self._width - stw) - 1
   local start_y = math.clamp(player_y - math.floor(sth / 2) - 1, 0, self._height - sth) - 1
   local end_x = (start_x + stw) + 1 + 1
   local end_y = (start_y + sth) + 1 + 1

   local fov_y_start = player_y - math.floor(fov_size / 2)
   local fov_y_end = player_y + math.floor(fov_size / 2)

   local lx, ly
   lx = 1
   ly = 1

   self._last_sight_id = self._last_sight_id + 1

   --
   -- Bits indicate directions that border a shadow.
   -- A bit set indicates "there is a shadow in direction X".
   --
   --        NSEW
   --        ----
   -- 0x000001111
   --
   --    NSSN
   --    EWEW
   --    ----
   -- 0x011110000
   --
   -- Then there is an extra bit for indicating if this tile is shadowed
   -- or lighted.
   --
   --  (is shadow)
   --   |
   -- 0x100000000
   --
   local function set_shadow_border(x, y, v)
      self._shadow_map[x][y] = bit.bor(self._shadow_map[x][y], v)
   end

   local function mark_shadow(lx, ly)
      set_shadow_border(lx + 1, ly,     0x1 ) -- W
      set_shadow_border(lx - 1, ly,     0x8 ) -- E
      set_shadow_border(lx,     ly - 1, 0x2 ) -- S
      set_shadow_border(lx,     ly + 1, 0x4 ) -- N
      set_shadow_border(lx + 1, ly + 1, 0x10) -- NW
      set_shadow_border(lx - 1, ly - 1, 0x20) -- SE
      set_shadow_border(lx + 1, ly - 1, 0x40) -- SW
      set_shadow_border(lx - 1, ly + 1, 0x80) -- NE
   end

   for j=start_y,end_y do
      lx = 1

      local cx = player_x - radius
      local cy = radius - player_y

      if j < 0 or j >= self._height then
         for i=start_x,end_x do
            mark_shadow(lx, ly)
            lx = lx + 1
         end
      else
         for i=start_x,end_x do
            if i < 0 or i >= self._width then
               mark_shadow(lx, ly)
            else
               local shadow = true

               if fov_y_start <= j and j <= fov_y_end then
                  if i >= fov_radius[j+cy][1] + cx and i < fov_radius[j+cy][2] + cx then
                     if self:has_los(player_x, player_y, i, j) then
                        self:memorize_tile(i, j)
                        shadow = false
                     end
                  end
               end

               if shadow then
                  set_shadow_border(lx, ly, 0x100)
                  mark_shadow(lx, ly)
               end
            end

            lx = lx + 1
         end
      end
      ly = ly + 1
   end

   return self._shadow_map, start_x, start_y
end

function InstancedMap:memorize_tile(x, y)
   local ind = y * self._width + x + 1;

   self._in_sight[ind] = self._last_sight_id

   local memory = self._memory
   for m, _ in pairs(memory) do
      memory[m][ind] = nil
   end

   memory["base.map_tile"] = memory["base.map_tile"] or {}
   memory["base.map_tile"][ind] = { self:tile(x, y) }

   for _, obj in self._multi_pool:objects_at_pos(x, y) do
      local m = obj:produce_memory()
      memory[obj._type] = memory[obj._type] or {}
      memory[obj._type][ind] = memory[obj._type][ind] or {}
      table.insert(memory[obj._type][ind], m)
   end

   self._tiles_dirty[#self._tiles_dirty+1] = {x, y}
end

function InstancedMap:is_memorized(x, y)
   local ind = y * self._width + x + 1;
   return (self._in_sight[ind] or 0) > 0
end

function InstancedMap:reveal_tile(x, y, tile_id)
   local memory = self._memory
   local ind = y * self._width + x + 1;

   local tile
   if tile_id then
      tile = data["base.map_tile"]:ensure(tile_id)
   end

   memory["base.map_tile"] = memory["base.map_tile"] or {}
   memory["base.map_tile"][ind] = { tile or self:tile(x, y) }
end

function InstancedMap:iter_memory(_type)
   return fun.iter(pairs(self._memory[_type] or {}))
end

function InstancedMap:iter_charas()
   return self:iter_type("base.chara")
end

function InstancedMap:iter_items()
   return self:iter_type("base.item")
end

function InstancedMap:iter_feats()
   return self:iter_type("base.feat")
end

function InstancedMap:is_in_bounds(x, y)
   return x >= 0 and y >= 0 and x < self._width and y < self._height
end

function InstancedMap:set_outer_map(map_or_uid, x, y)
   local uid = map_or_uid
   if type(map_or_uid) == "table" then
      class.assert_is_an(InstancedMap, map_or_uid)
      uid = map_or_uid.uid
   end

   local area = save.base.area_mapping:area_for_outer_map(uid)
   if area == nil then
      area = save.base.area_mapping:create_area(uid, x, y)
   end

   area.x = x
   area.y = y
   area.outer_map_uid = uid

   save.base.area_mapping:add_map_to_area(area.uid, self.uid)
end

function InstancedMap:is_floor(x, y)
   return self:is_in_bounds(x, y) and not self:tile(x, y).is_solid
end

-- TODO: Need to handle depending on what is querying. People may want
-- things that can pass through walls, etc.
function InstancedMap:can_access(x, y)
   return self:is_in_bounds(x, y)
      and not self._solid[y*self._width+x+1]
end

function InstancedMap:can_see_through(x, y)
   return self:is_in_bounds(x, y)
      and not self._opaque[y*self._width+x+1]
end

--- Returns true if the player can see a position on screen.
---
--- NOTE: This function returns false for any positions that are not
--- contained in the game window. This is the same behavior as
--- vanilla. For game calculations depending on LoS outside of the
--- game window, use InstancedMap:has_los combined with a maximum
--- distance check instead.
---
--- @tparam int x
--- @tparam int y
--- @treturn bool
function InstancedMap:is_in_fov(x, y)
   return self._in_sight[y*self._width+x+1] == self._last_sight_id
end

function InstancedMap:recalc_access(x, y, exclude)
   if self:tile(x, y).is_solid then
      return false
   end

   for _, obj in self._multi_pool:objects_at_pos(x, y) do
      if not exclude or obj.uid ~= exclude.uid then
         if obj:calc("is_solid") then
            return false
         end
      end
   end

   return true
end

function InstancedMap:refresh_tile(x, y)
   local tile = self:tile(x, y)

   -- TODO: maybe map tiles should be map objects, or at least support
   -- IMapObject:calc() by extracting its interface.
   local solid = tile.is_solid
   local opaque = tile.is_opaque

   local ind = y * self._width + x + 1
   self._light[ind] = nil

   for _, obj in self._multi_pool:objects_at_pos(x, y) do
      if solid and opaque then
         break
      end

      solid = solid or obj:calc("is_solid")
      opaque = opaque or obj:calc("is_opaque")

      local tile_light = obj:calc("light")
      if tile_light then
         tile_light.offset_y = tile_light.offset_y or 0
         tile_light.brightness = tile_light.brightness or 0
         tile_light.power = tile_light.power or 0
         tile_light.flicker = tile_light.flicker or 0

         self._light[ind] = tile_light
      end
   end
   self._solid[ind] = solid
   self._opaque[ind] = opaque
end

function InstancedMap:redraw_all_tiles()
   for _, x, y in Pos.iter_rect(0, 0, self:width()-1, self:height()-1)  do
      self._tiles_dirty[#self._tiles_dirty+1] = {x, y}
   end
end

function InstancedMap:replace_with(other)
   assert(class.is_an(InstancedMap, other))

   local uid = self.uid
   table.replace_with(self, other)
   self.uid = uid
end

function InstancedMap:deserialize()
   ILocation.deserialize(self)
   self:redraw_all_tiles()
end


--
-- ILocation impl
--

InstancedMap:delegate("_multi_pool",
{
   "is_positional",
   "objects_at_pos",
   "iter_type_at_pos",
   "iter_type",
   "iter",
   "has_object",
   "get_object",
   "get_object_of_type",
   "has_object_of_type",
})

function InstancedMap:is_positional()
   return true
end

function InstancedMap:take_object(obj, x, y)
   if x < 0 or y < 0 or x >= self:width() or y >= self:height() then
      return nil
   end
   self._multi_pool:take_object(obj, x, y)
   obj.location = self
   self:refresh_tile(x, y)
   return obj
end

function InstancedMap:remove_object(obj)
   local prev_x, prev_y = obj.x, obj.y
   local success = self._multi_pool:remove_object(obj)

   if success then
      self:refresh_tile(prev_x, prev_y)
   end

   return success
end

function InstancedMap:move_object(obj, x, y)
   local prev_x, prev_y = obj.x, obj.y
   local success = self._multi_pool:move_object(obj, x, y)

   if success then
      self:refresh_tile(x, y)
   end

   return success
end

function InstancedMap:can_take_object(obj)
   return true
end

return InstancedMap
