local Map = require("api.Map")
local Item = require("api.Item")
local IDrawLayer = require("api.gui.IDrawLayer")
local Draw = require("api.Draw")
local sparse_batch = require("internal.draw.sparse_batch")

local item_layer = class.class("item_layer", IDrawLayer)

function item_layer:init(width, height)
   local coords = Draw.get_coords()
   local tile_atlas, chara_atlas, item_atlas = require("internal.global.atlases").get()

   self.item_batch = sparse_batch:new(width, height, item_atlas, coords)
   self.batch_inds = {}
   self.batch_inds_memory = {}
end

function item_layer:relayout()
end

function item_layer:reset()
   self.batch_inds = {}
end

function item_layer:update(dt, screen_updated, scroll_frames)
   if not screen_updated then return end

   self.item_batch.updated = true

   local map = Map.current()
   assert(map ~= nil)

   local found = {}

   for _, i in map:iter_items() do
      found[i.uid] = true
      local show = Item.is_alive(i) and map:is_in_fov(i.x, i.y)
      local hide = not show
         and self.batch_inds[i.uid] ~= nil
         and self.batch_inds[i.uid] ~= 0

      if show then
         local batch_ind = self.batch_inds[i.uid]
         local image = i:calc("image")
         if batch_ind == nil or batch_ind == 0 then
            self.batch_inds[i.uid] = self.item_batch:add_tile {
               tile = image,
               x = i.x,
               y = i.y
            }
         else
            local tile, px, py = self.item_batch:get_tile(batch_ind)

            if px ~= i.x or py ~= i.y or tile ~= image then
               self.item_batch:remove_tile(batch_ind)
               self.batch_inds[i.uid] = self.item_batch:add_tile {
                  tile = image,
                  x = i.x,
                  y = i.y
               }
            end
         end
      elseif hide then
         self.item_batch:remove_tile(self.batch_inds[i.uid])
         self.batch_inds[i.uid] = 0
      end
   end

   for uid, _ in pairs(self.batch_inds) do
      if not found[uid] then
         self.item_batch:remove_tile(self.batch_inds[uid])
         self.batch_inds[uid] = nil
      end
   end
end

function item_layer:draw(draw_x, draw_y)
   self.item_batch:draw(draw_x, draw_y)
end

return item_layer
