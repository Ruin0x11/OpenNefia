local Map = require("api.Map")
local IDrawLayer = require("api.gui.IDrawLayer")
local Draw = require("api.Draw")
local sparse_batch = require("internal.draw.sparse_batch")

local feat_layer = class("feat_layer", IDrawLayer)

function feat_layer:init(width, height)
   local coords = Draw.get_coords()
   local tile_atlas, chara_atlas, item_atlas = require("internal.global.atlases").get()

   self.feat_batch = sparse_batch:new(width, height, item_atlas, coords)
   self.batch_inds = {}
   self.batch_inds_memory = {}
end

function feat_layer:relayout()
end

function feat_layer:reset()
   self.batch_inds = {}
end

function feat_layer:update(dt, screen_updated, scroll_frames)
   if not screen_updated then return end

   self.feat_batch.updated = true

   local map = Map.current()
   assert(map ~= nil)

   local found = {}

   for _, f in map:iter_type("base.feat") do
      found[f.uid] = true
      local show = not f:calc("is_invisible") and map:is_in_fov(f.x, f.y)
      local hide = not show
         and self.batch_inds[f.uid] ~= nil
         and self.batch_inds[f.uid] ~= 0

      if show then
         local batch_ind = self.batch_inds[f.uid]
         if batch_ind == nil or batch_ind == 0 then
            self.batch_inds[f.uid] = self.feat_batch:add_tile {
               tile = f.image,
               x = f.x,
               y = f.y
            }
         else
            local tile, px, py = self.feat_batch:get_tile(batch_ind)

            if px ~= f.x or py ~= f.y or tile ~= f.image then
               self.feat_batch:remove_tile(batch_ind)
               self.batch_inds[f.uid] = self.feat_batch:add_tile {
                  tile = f.image,
                  x = f.x,
                  y = f.y
               }
            end
         end
      elseif hide then
         self.feat_batch:remove_tile(self.batch_inds[f.uid])
         self.batch_inds[f.uid] = 0
      end
   end

   for uid, _ in pairs(self.batch_inds) do
      if not found[uid] then
         self.feat_batch:remove_tile(self.batch_inds[uid])
         self.batch_inds[uid] = nil
      end
   end
end

function feat_layer:draw(draw_x, draw_y)
   self.feat_batch:draw(draw_x, draw_y)
end

return feat_layer
