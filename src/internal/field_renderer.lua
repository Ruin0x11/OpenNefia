local sparse_batch = require("internal.draw.sparse_batch")
local tile_batch = require("internal.draw.tile_batch")
local shadow_batch = require("internal.draw.shadow_batch")
local draw = require("internal.draw")
local map = require("internal.map")
local chara = require("internal.chara")

local field_renderer = class("field_renderer")

function field_renderer:init(width, height, layers)
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
   self.layers = {}
   self.scroll_info = {}

   for _, require_path in ipairs(layers) do
      local layer, err = package.try_require(require_path)
      if layer == nil then
         error("Could not load draw layer " .. require_path .. ":\n\t" .. err)
      end
      local IDrawLayer = require("api.gui.IDrawLayer")

      local instance = layer:new(width, height)
      assert_is_an(IDrawLayer, instance)

      -- TODO
      instance:relayout()

      self.layers[#self.layers+1] = instance
   end
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

   for _, l in ipairs(self.layers) do
      l:draw(draw_x, draw_y)
   end

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

local function calc_map_shadow(map, hour)
   if not map.is_outdoors then
      return 0
   end

   local shadow = 0

   if hour >= 24 or (hour >= 0 and hour < 4) then
      shadow = 110
   elseif hour >= 4 and hour < 10 then
      shadow = math.max(10, 70 - (hour - 3) * 10)
   elseif hour >= 10 and hour < 12 then
      shadow = 10
   elseif hour >= 12 and hour < 17 then
      shadow = 1
   elseif hour >= 17 and hour < 21 then
      shadow = (hour - 17) * 20
   elseif hour >= 21 and hour < 24 then
      shadow = 80 + (hour - 21) * 10
   end

   -- TODO weather, noyel

   return shadow
end

function field_renderer:update_tile_layer(map, player)
   if map.tiles_dirty then
      for i, t in ipairs(map.tiles) do
         local x = (i-1) % map.width
         local y = math.floor((i-1) / map.width)
         local id = t._id

         if t.wall then
            local one_tile_down = map.tiles[(y+1)*map.width+x+1]
            if one_tile_down ~= nil and not one_tile_down.wall then
               id = t.wall
            end
         end
         self:set_tile(id, x, y)
      end
      map.tiles_dirty = false
   end

   -- TODO: maybe have this field accessable somewhere better?
   local field = require("game.field")
   local date = field.data.date

   self.tile_batch.shadow = calc_map_shadow(map, date.hour)
end

function field_renderer:update_shadow_layer(map, player)
   if player ~= nil then
      local shadow_map = map.shadow_map
      if #shadow_map > 0 then
         self.shadow_batch:set_tiles(shadow_map)
      end
   end
end

function field_renderer:update_chara_layer(map, player)
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

            if px ~= c.x or py ~= c.y or tile ~= c.image then
               self.chara_batch:remove_tile(batch_ind)
               --self.chara_batch_inds[c.uid] = self.chara_batch:add_tile {
               c.batch_ind = self.chara_batch:add_tile {
                  tile = c.image,
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

function field_renderer:update(map, player)
   self:update_tile_layer(map, player)
   self:update_shadow_layer(map, player)
   self:update_chara_layer(map, player)

   for _, l in ipairs(self.layers) do
      l:update(0, true)
   end
end

return field_renderer
