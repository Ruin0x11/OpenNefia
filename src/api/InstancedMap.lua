local data = require("internal.data")
local pool = require("internal.pool")
local bresenham = require("thirdparty.bresenham")

local Pos = require("api.Pos")
local Draw = require("api.Draw")
local IObject = require("api.IObject")

local InstancedMap = class("InstancedMap")

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

function InstancedMap:init(width, height, uids)
   uids = uids or require("internal.global.uids")

   if width <= 0 or height <= 0 then
      error("Maps must be at least 1 tile wide and long.")
   end

   self.width = width
   self.height = height

   self.pools = {}
   self.last_sight_id = 0
   self.in_sight = table.of(self.last_sight_id, width * height)

   -- Map of shadows to be drawn. This is coordinate-local to the
   -- visible screen area only, with (1, 1) being the tile at the
   -- upper left corner of the game window.
   self.shadow_map = {}

   -- Locations that are treated as solid. Can be changed by mods to
   -- make objects that act solid, like map features.
   self.solid = table.of(false, width * height)

   -- Locations that are treated as opaque. Can be changed by mods to
   -- make objects that act opaque.
   self.opaque = table.of(false, width * height)

   self.tiles = table.of({}, width * height)
   self.tiles_dirty = true
   self.uids = uids

   self:init_map_data()

   self:clear("base.floor")
end

function InstancedMap:init_map_data()
   self.turn_cost = 1000
   self.is_outdoors = true
end

function InstancedMap:clear(tile)
   for x=0,self.width-1 do
      for y=0,self.height-1 do
         self:set_tile(x, y, tile)
      end
   end
end

function InstancedMap:set_tile(x, y, tile)
   if type(tile) == "string" then
      tile = data["base.map_tile"][tile]
   end

   assert(tile ~= nil)

   if not self:is_in_bounds(x, y) then
      return
   end

   self.tiles[y*self.width+x+1] = tile

   self.tiles_dirty = true
end

function InstancedMap:tile(x, y)
   return self.tiles[y*self.width+x+1]
end

function InstancedMap:get_pool(type_id)
   self.pools[type_id] = self.pools[type_id] or pool:new(type_id, self.uids, self.width, self.height)
   return self.pools[type_id]
end

function InstancedMap:create_object(proto, x, y)
   local _type = proto._type
   if not _type then error("no type") end

   local pool = self:get_pool(_type)
   return pool:create_object(proto, x, y)
end

function InstancedMap:get_batch(type_id)
   self.batches[type_id] = self.batches[type_id] or sparse_batch:new(type_id)
   return self.batches[type_id]
end

function InstancedMap:add_object(obj, x, y)
   assert_is_an(IObject, obj)
   local pool = self:get_pool(obj._type)
   pool:add_object(obj, x, y)

   return obj
end

function InstancedMap:move_object(obj, x, y)
   assert_is_an(IObject, obj)
   assert(self:exists(obj))

   local pool = self:get_pool(obj._type)
   pool:move_object(obj, x, y)
end

function InstancedMap:remove_object(obj)
   assert_is_an(IObject, obj)
   local pool = self:get_pool(obj._type)
   pool:remove(obj.uid)
end

function InstancedMap:objects_at(type_id, x, y)
   local pool = self:get_pool(type_id)
   if not pool then return {} end
   return pool:objects_at(x, y)
end

function InstancedMap:get_object(_type, uid)
   local pool = self:get_pool(_type)
   return pool:get(uid)
end

function InstancedMap:transfer_to(map, _type, uid, x, y)
   local from = self:get_pool(_type)
   local to = map:get_pool(_type)
   return from:transfer_to_with_pos(to, uid, x, y)
end

function InstancedMap:exists(obj)
   return is_an(IObject, obj) and self:get_pool(obj._type):exists(obj.uid)
end

function InstancedMap:has_los(x1, y1, x2, y2)
   local cb = function(x, y)
      return self:can_see_through(x, y)
      -- in Elona, the final tile is visible even if it is solid.
         or (x == x2 and y == y2)
   end
   return bresenham.los(x1, y1, x2, y2, cb)
end

local function pp(ar)
   print("==============")
   for i=0, #ar do
      for j=0,#ar do
         local o = ar[j][i] or 0
         local i = "."
         if bit.band(o, 0x100) > 0 then
            i = "#"
         end
         io.write(i)
      end
      io.write("\n")
   end
end

--- Calculates the positions that can be seen by the player and are
--- contained in the game window.
-- @tparam int player_x
-- @tparam int player_y
-- @tparam int fov_radius
function InstancedMap:calc_screen_sight(player_x, player_y, fov_size)
   local stw = math.min(Draw.get_tiled_width(), self.width)
   local sth = math.min(Draw.get_tiled_height(), self.height)

   self.shadow_map = {}
   for i=0,stw + 4 - 1 do
      self.shadow_map[i] = {}
      for j=0,sth + 4 - 1 do
         self.shadow_map[i][j] = 0
      end
   end

   local fov_radius = gen_fov_radius(fov_size)
   local radius = math.floor((fov_size + 2) / 2)
   local max_dist = math.floor(fov_size / 2)

   local start_x = math.clamp(player_x - math.floor(stw / 2), 0, self.width - stw)
   local start_y = math.clamp(player_y - math.floor(sth / 2) - 1, 0, self.height - sth)
   local end_x = (start_x + stw)
   local end_y = (start_y + sth)

   local fov_y_start = player_y - math.floor(fov_size / 2)
   local fov_y_end = player_y + math.floor(fov_size / 2)

   local lx, ly
   lx = 1
   ly = 1

   self.last_sight_id = self.last_sight_id + 1

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
      self.shadow_map[x][y] = bit.bor(self.shadow_map[x][y], v)
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

      if j < 0 or j >= self.height then
         for i=start_x,end_x do
            mark_shadow(lx, ly)
            lx = lx + 1
         end
      else
         for i=start_x,end_x do
            if i < 0 or i >= self.width then
               mark_shadow(lx, ly)
            else
               local shadow = true

               if fov_y_start <= j and j <= fov_y_end then
                  if i >= fov_radius[j+cy][1] + cx and i < fov_radius[j+cy][2] + cx then
                     if self:has_los(player_x, player_y, i, j) then
                        self.in_sight[j*self.width+i+1] = self.last_sight_id
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
   -- pp(self.shadow_map)

   return self.shadow_map, start_x, start_y
end

function InstancedMap:iter_charas()
   return self:iter_objects("base.chara")
end

function InstancedMap:iter_objects(type_id)
   return self:get_pool(type_id):iter()
end

function InstancedMap:is_in_bounds(x, y)
   return x >= 0 and y >= 0 and x < self.width and y < self.height
end

-- TODO: Need to handle depending on what is querying. People may want
-- things that can pass through walls, etc.
function InstancedMap:can_access(x, y)
   -- TODO: Perhaps make one source of truth.
   local tile = self:tile(x, y)
   return self:is_in_bounds(x, y)
      and not tile.is_solid
      and not self.solid[y*self.width+x+1]
end

function InstancedMap:can_see_through(x, y)
   -- TODO: Perhaps make one source of truth.
   local tile = self:tile(x, y)
   return self:is_in_bounds(x, y)
      and not tile.is_opaque
      and not self.opaque[y*self.width+x+1]
end

function InstancedMap:calculate_opaqueness(x, y)
end

function InstancedMap:calculate_accessibility(x, y)
end

-- NOTE: This function returns false for any positions that are not
-- contained in the game window. This is the same behavior as vanilla.
-- For game calculations depending on LoS outside of the game window,
-- use InstancedMap:has_los combined with a maximum distance check instead.
function InstancedMap:is_in_fov(x, y)
   return self.in_sight[y*self.width+x+1] == self.last_sight_id
end

return InstancedMap
