local sparse_batch = require("internal.draw.sparse_batch")
local tile_batch = require("internal.draw.tile_batch")

local field_renderer = class("field_renderer")

function field_renderer:init(width, height)
   local coords = require("internal.draw.coords.tiled_coords"):new()
   local tile_atlas, chara_atlas = require("internal.global.atlases").get()

   self.tile_batch = tile_batch:new(width, height, tile_atlas, coords)
   self.chara_batch = sparse_batch:new(width, height, chara_atlas, coords)

   self.width = width
   self.height = height
   self.coords = coords
   self.draw_x = 0
   self.draw_y = 0
end

function field_renderer:add_object(_type, tile, x, y)
   print("add",_type,tile,x,y)
   if _type == "base.chara" then
      return self.chara_batch:add_tile {
         tile = tile,
         x = x,
         y = y,
      }
   end
end

function field_renderer:set_tile(tile, x, y)
   self.tile_batch:update_tile(x, y, tile)
end

function field_renderer:move_object(_type, batch_ind, x, y)
   print("mov",_type,batch_ind,x,y)
   assert(batch_ind ~= nil and batch_ind ~= 0)

   if _type == "base.chara" then
      local tile, px, py = self.chara_batch:get_tile(batch_ind)
      assert(tile ~= nil and tile ~= 0)

      if px ~= x or py ~= y then
         self.chara_batch:remove_tile(batch_ind)
         return self.chara_batch:add_tile {
            tile = tile,
            x = x,
            y = y
         }
      end
   end

   return nil
end

function field_renderer:update_draw_pos(player_x, player_y)
   local draw_x, draw_y = self.coords:get_draw_pos(player_x, player_y, self.width, self.height)

   if draw_x ~= self.draw_x or draw_y ~= self.draw_y then
      self.tile_batch.updated = true
      self.chara_batch.updated = true
   end

   self.draw_x, self.draw_y = draw_x, draw_y

   self:update()
end

function field_renderer:set_draw_pos(draw_x, draw_y)
   self.draw_x = draw_x
   self.draw_y = draw_y
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
   -- shadow
end

local map = require("internal.map")

function field_renderer:update()
   -- HACK don't do this.
   for i, t in ipairs(map.get().tiles) do
      local x = (i-1) % map.get().width
      local y = math.floor((i-1) / map.get().height)
      self:set_tile(t.image, x, y)
   end

   for _, c in map.get():iter_charas() do
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
   end
end


local singleton

local api = {}

function api.create(width, height)
   width = width or map.get().width
   height = height or map.get().height
   singleton = field_renderer:new(width, height)
end

function api.set(s)
   singleton = s
end

function api.get()
   return singleton
end

return api
