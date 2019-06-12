local Map = require("api.Map")
local IDrawLayer = require("api.gui.IDrawLayer")
local Draw = require("api.Draw")
local sparse_batch = require("internal.draw.sparse_batch")

local chara_layer = class("chara_layer", IDrawLayer)

function chara_layer:init(width, height)
   local coords = Draw.get_coords()
   local tile_atlas, chara_atlas, item_atlas = require("internal.global.atlases").get()

   self.chara_batch = sparse_batch:new(width, height, chara_atlas, coords)
   self.batch_inds = {}
end

function chara_layer:relayout()
end

function chara_layer:reset()
   self.batch_inds = {}
end

function chara_layer:update(dt, screen_updated)
   if not screen_updated then return end

   self.chara_batch.updated = true

   local map = Map.current()
   assert(map ~= nil)

   for _, c in map:iter_charas() do
      local show = c.state == "Alive" and map:is_in_fov(c.x, c.y)
      local hide = not show
         and self.batch_inds[c.uid] ~= nil
         and self.batch_inds[c.uid] ~= 0

      if show then
         local batch_ind = self.batch_inds[c.uid]
         if batch_ind == nil or batch_ind == 0 then
            self.batch_inds[c.uid] = self.chara_batch:add_tile {
               tile = c.image,
               x = c.x,
               y = c.y
            }
         else
            local tile, px, py = self.chara_batch:get_tile(batch_ind)

            if px ~= c.x or py ~= c.y or tile ~= c.image then
               self.chara_batch:remove_tile(batch_ind)
               self.batch_inds[c.uid] = self.chara_batch:add_tile {
                  tile = c.image,
                  x = c.x,
                  y = c.y
               }
            end
         end
      elseif hide then
         self.chara_batch:remove_tile(self.batch_inds[c.uid])
         self.batch_inds[c.uid] = 0
      end
   end
end

function chara_layer:draw(draw_x, draw_y)
   self.chara_batch:draw(draw_x, draw_y)
end

return chara_layer
