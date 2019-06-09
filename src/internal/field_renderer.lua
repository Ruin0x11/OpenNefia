local sparse_batch = require("internal.draw.sparse_batch")
local tile_batch = require("internal.draw.tile_batch")
local shadow_batch = require("internal.draw.shadow_batch")
local draw = require("internal.draw")
local map = require("internal.map")
local chara = require("internal.chara")

local field_renderer = class("field_renderer")

function field_renderer:init(width, height)
   local coords = draw.get_coords()
   local tile_atlas, chara_atlas = require("internal.global.atlases").get()

   self.tile_batch = tile_batch:new(width, height, tile_atlas, coords)
   self.chara_batch = sparse_batch:new(width, height, chara_atlas, coords)
   self.shadow_batch = shadow_batch:new(width, height, coords)

   self.width = width
   self.height = height
   self.coords = coords
   self.draw_x = 0
   self.draw_y = 0

   self.draw_coroutines = {}
end

function field_renderer:update_draw_pos(player_x, player_y)
   local draw_x, draw_y = self.coords:get_draw_pos(player_x,
                                                   player_y,
                                                   self.width,
                                                   self.height,
                                                   draw.get_width(),
                                                   draw.get_height())

   if draw_x ~= self.draw_x or draw_y ~= self.draw_y then
      self.tile_batch.updated = true
      self.chara_batch.updated = true
   end

   self:set_draw_pos(draw_x, draw_y)
end

function field_renderer:set_tile(tile, x, y)
   self.tile_batch:update_tile(x, y, tile)
end

function field_renderer:set_draw_pos(draw_x, draw_y)
   self.draw_x = draw_x
   self.draw_y = draw_y
end

function field_renderer:add_async_draw_callback(cb)
   self.draw_coroutines[#self.draw_coroutines+1] = coroutine.create(cb)
end

function field_renderer:draw()
   local draw_x = self.draw_x
   local draw_y = self.draw_y

   self.tile_batch:draw(draw_x, draw_y)
   -- blood, fragments
   -- efmap
   -- nefia icons
   -- mefs
   -- items
   self.chara_batch:draw(draw_x, draw_y)
   -- light
   -- cloud
   self.shadow_batch:draw(draw_x, draw_y)

   local dead = {}
   for i, co in ipairs(self.draw_coroutines) do
      local msg, err = coroutine.resume(co, draw_x, draw_y)
      if err then
         dead[#dead+1] = i
      end
   end

   for _, i in ipairs(dead) do
      table.remove(self.draw_coroutines, i)
   end
end

function field_renderer:update(map, player)
   if map.tiles_dirty then
      for i, t in ipairs(map.tiles) do
         local x = (i-1) % map.width
         local y = math.floor((i-1) / map.height)
         self:set_tile(t.image, x, y)
      end
      map.tiles_dirty = false
   end

   if player ~= nil then
      local shadow_map = map:calc_screen_sight(player.x, player.y, 35)
      if #shadow_map > 0 then
         self.shadow_batch:set_tiles(shadow_map)
      end
   end

   for _, c in map:iter_charas() do
      local show = c.state == "Alive" and map:is_in_fov(c.x, c.y)
      local hide = not show and c.batch_ind ~= 0

      if show then
         -- HACK replace as batch_ind shouldn't be stored on character
         -- local batch_ind = self.chara_batch_inds[c.uid]
         local batch_ind = c.batch_ind
         if c.batch_ind == nil or c.batch_ind == 0 then
            c.batch_ind = self.chara_batch:add_tile {
               tile = c.image,
               x = c.x,
               y = c.y
            }
         else
            local tile, px, py = self.chara_batch:get_tile(batch_ind)

            if px ~= c.x or py ~= c.y then
               self.chara_batch:remove_tile(batch_ind)
               --self.chara_batch_inds[c.uid] = self.chara_batch:add_tile {
               c.batch_ind = self.chara_batch:add_tile {
                  tile = tile,
                  x = c.x,
                  y = c.y
               }
            end
         end
      elseif hide then
         self.chara_batch:remove_tile(c.batch_ind)
         c.batch_ind = 0
      end
   end
end

return field_renderer
