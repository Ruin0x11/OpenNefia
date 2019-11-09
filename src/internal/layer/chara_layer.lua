local Map = require("api.Map")
local IDrawLayer = require("api.gui.IDrawLayer")
local Draw = require("api.Draw")
local sparse_batch = require("internal.draw.sparse_batch")

local chara_layer = class.class("chara_layer", IDrawLayer)

function chara_layer:init(width, height)
   local coords = Draw.get_coords()
   local chara_atlas = require("internal.global.atlases").get().chara

   self.chara_batch = sparse_batch:new(width, height, chara_atlas, coords)
   self.batch_inds = {}
   self.scroll = nil
   self.scroll_frames = 0
   self.scroll_max_frames = 0
   self.scroll_consecutive = 0
   self.coords = coords
end

function chara_layer:relayout()
end

function chara_layer:reset()
   self.batch_inds = {}
end

function chara_layer:calc_scroll(map)
   local scroll = {}

   for uid, dat in pairs(self.batch_inds) do
      local c = map:get_object_of_type("base.chara", uid)
      if c.x ~= dat.x or c.y ~= dat.y then
         local dx = c.x - dat.x
         local dy = c.y - dat.y

         if math.abs(dx) <= 1 and math.abs(dy) <= 1 and c:is_player() then
            scroll[#scroll+1] = { ind = self.batch_inds[uid].ind, dx = -dx, dy = -dy}
         end

         dat.x = c.x
         dat.y = c.y
      end
   end

   return scroll
end

function chara_layer:scroll_one(dt)
   local tw, th = self.coords:get_size()
   self.scroll_frames = self.scroll_frames - Draw.msecs_to_frames(dt*1000)
   for _, scroll in ipairs(self.scroll) do
      local p = 1 - ((self.scroll_frames)/self.scroll_max_frames)
      local sx, sy = (scroll.dx - (p * scroll.dx)) * tw, (scroll.dy - (p * scroll.dy)) * th
      self.chara_batch:set_tile_offsets(scroll.ind, sx, sy)
   end

   return self.scroll_frames <= 0
end

function chara_layer:update(dt, screen_updated, scroll_frames)
   if not screen_updated then
      self.scroll_consecutive = 0
      return false
   end

   if scroll_frames <= 0 then
      self.chara_batch.updated = true
   end

   local map = Map.current()
   assert(map ~= nil)

   if self.scroll then
      local finished = self:scroll_one(dt)

      if finished then
         for _, scroll in ipairs(self.scroll) do
            self.chara_batch:set_tile_offsets(scroll.ind, 0, 0)
         end
         self.scroll = nil
         return false
      end

      -- keep scrolling
      return true
   end

   -- Calculate scroll now before the position of all character
   -- sprites are updated.
   local scroll = self:calc_scroll(map)

   -- TODO: This has to be deferred to the final scroll frame, because
   -- the shadow map has already been updated by this point. This can
   -- cause the rendering order to differ from vanilla:
   --
   --   - In vanilla, the screen is first scrolled before the FOV map
   --     is updated. This will cause items to only appear after the
   --     scroll is finished.
   --   - In Elona_next, the FOV map is calculated by the time the
   --   - screen is scrolled, but the FOV map from the previous turn
   --   - will still be displayed.
   for ind, stack in map:iter_memory("base.chara") do
      local x = (ind-1) % map:width()
      local y = math.floor((ind-1) / map:width())

      for _, c in ipairs(stack) do
         local show = c.show and map:is_in_fov(x, y)
         local hide = not show
            and self.batch_inds[c.uid] ~= nil
            and self.batch_inds[c.uid].ind ~= 0

         if show then
            local image = c.image
            local batch_ind = self.batch_inds[c.uid]
            if batch_ind == nil or batch_ind.ind == 0 then
               local ind = self.chara_batch:add_tile {
                  tile = image,
                  x = x,
                  y = y
               }
               self.batch_inds[c.uid] = { ind = ind, x = x, y = y }
            else
               local tile, px, py = self.chara_batch:get_tile(batch_ind)

               if px ~= x or py ~= y or tile ~= image then
                  self.chara_batch:remove_tile(batch_ind.ind)
                  local ind = self.chara_batch:add_tile {
                     tile = image,
                     x = x,
                     y = y
                  }
                  self.batch_inds[c.uid] = { ind = ind, x = x, y = y }
               end
            end
         elseif hide then
            self.chara_batch:remove_tile(self.batch_inds[c.uid].ind)
            self.batch_inds[c.uid] = nil
         end
      end
   end

   if scroll_frames > 0 and #scroll > 0 then
      self.scroll_consecutive = self.scroll_consecutive + 1
      self.scroll = scroll

      local max = 12
      max = 6
      max = 3

      self.scroll_max_frames = scroll_frames
      self.scroll_frames = scroll_frames
      self:scroll_one(dt)
      return true
   else
      self.scroll_consecutive = 0
   end

   return false
end

function chara_layer:draw(draw_x, draw_y, offx, offy)
   self.chara_batch:draw(draw_x + offx, draw_y + offy)
end

return chara_layer
