local Map = require("api.Map")
local IDrawLayer = require("api.gui.IDrawLayer")
local Draw = require("api.Draw")
local sparse_batch = require("internal.draw.sparse_batch")

local feat_layer = class.class("feat_layer", IDrawLayer)

function feat_layer:init(width, height)
   local coords = Draw.get_coords()
   local feat_atlas = require("internal.global.atlases").get().feat

   self.feat_batch = sparse_batch:new(width, height, feat_atlas, coords)
   self.batch_inds = {}
end

function feat_layer:relayout()
end

function feat_layer:reset()
   self.batch_inds = {}
end

function feat_layer:update(dt, screen_updated, scroll_frames)
   if not screen_updated then return end

   self.feat_batch.updated = true

   if scroll_frames > 0 then
      return true
   end

   local map = Map.current()
   assert(map ~= nil)

   local found = {}

   for i, stack in map:iter_memory("base.feat") do
      local x = (i-1) % map:width()
      local y = math.floor((i-1) / map:width())
      for _, f in ipairs(stack) do
         found[f.uid] = true
         local show = f.show
         local hide = not show
            and self.batch_inds[f.uid] ~= nil
            and self.batch_inds[f.uid] ~= 0

         if show then
            local image = f.image
            local batch_ind = self.batch_inds[f.uid]
            if batch_ind == nil or batch_ind == 0 then
               self.batch_inds[f.uid] = self.feat_batch:add_tile {
                  tile = image,
                  x = x,
                  y = y
               }
            else
               local tile, px, py = self.feat_batch:get_tile(batch_ind)

               if px ~= x or py ~= y or tile ~= image then
                  self.feat_batch:remove_tile(batch_ind)
                  self.batch_inds[f.uid] = self.feat_batch:add_tile {
                     tile = image,
                     x = x,
                     y = y
                  }
               end
            end
         elseif hide then
            self.feat_batch:remove_tile(self.batch_inds[f.uid])
            self.batch_inds[f.uid] = 0
         end
      end
   end

   for uid, _ in pairs(self.batch_inds) do
      if not found[uid] then
         self.feat_batch:remove_tile(self.batch_inds[uid])
         self.batch_inds[uid] = nil
      end
   end
end

function feat_layer:draw(draw_x, draw_y, offx, offy)
   self.feat_batch:draw(draw_x + offx, draw_y + offy)
end

return feat_layer
