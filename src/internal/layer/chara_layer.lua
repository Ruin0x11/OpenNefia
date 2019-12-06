local Map = require("api.Map")
local IDrawLayer = require("api.gui.IDrawLayer")
local Draw = require("api.Draw")
local sparse_batch = require("internal.draw.sparse_batch")
local UiTheme = require("api.gui.UiTheme")
local atlas = require("internal.draw.atlas")

local chara_layer = class.class("chara_layer", IDrawLayer)

function chara_layer:init(width, height)
   local coords = Draw.get_coords()
   local chara_atlas = require("internal.global.atlases").get().chara
   local shadow_atlas = atlas:new(1, 1, 48, 48)
   local t = UiTheme.load(self)

   local tiles = {{
         _id = "shadow",
         image = t.character_shadow
   }}
   shadow_atlas:load(fun.iter(tiles), coords)

   self.chara_batch = sparse_batch:new(width, height, chara_atlas, coords)
   self.shadow_batch = sparse_batch:new(width, height, shadow_atlas, coords)
   self.batch_inds = {}
   self.shadow_batch_inds = {}
   self.scroll = nil
   self.scroll_frames = 0
   self.scroll_max_frames = 0
   self.scroll_consecutive = 0
   self.coords = coords
   self.t = t
end

function chara_layer:relayout()
   self.t = UiTheme.load(self)
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

local rot = 0
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
   --
   -- BUG: assumes memory is unique by UID, which is false since more
   -- than one memory can exist for a single UID at a time.
   local scroll = {} -- self:calc_scroll(map)

   self.chara_batch:clear()
   self.shadow_batch:clear()
   self.batch_inds = {}
   self.shadow_batch_inds = {}

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
   local i = 1
   for ind, stack in map:iter_memory("base.chara") do
      local x = (ind-1) % map:width()
      local y = math.floor((ind-1) / map:width())

      for _, c in ipairs(stack) do
         local show = c.show and map:is_in_fov(x, y)

         if show then
            local image = c.image
            local batch_ind = self.batch_inds[i]
            if batch_ind == nil or batch_ind.ind == 0 then
               local shadow_ind = self.shadow_batch:add_tile {
                  tile = "shadow#1",
                  x = x,
                  y = y
               }
               self.shadow_batch_inds[i] = { ind = ind, x = x, y = y }
               local ind = self.chara_batch:add_tile {
                  tile = image,
                  x = x,
                  y = y,
                  color = c.color
               }
               self.batch_inds[i] = { ind = ind, x = x, y = y }
               i = i + 1
            end
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

function chara_layer:draw_hp_bars(draw_x, draw_y, offx, offy)
   local sx, sy = Draw.get_coords():get_start_offset(draw_x, draw_y)

   for _, ind in pairs(self.batch_inds) do
      if true then
         local ratio = 0.9
         self.t.hp_bar_ally:draw_percentage_bar(sx - draw_x + offx + ind.x * 48 + 9,
                                     sy - draw_y + offy + ind.y * 48 + 32,
                                     ratio * 30, 3, ratio * 30)
      end
   end
end

function chara_layer:draw(draw_x, draw_y, offx, offy)
   love.graphics.setBlendMode("subtract")
   Draw.set_color(255, 255, 255, 110)
   self.shadow_batch:draw(draw_x + offx, draw_y + offy, 8, 20)
   love.graphics.setBlendMode("alpha")
   Draw.set_color(255, 255, 255)
   self.chara_batch:draw(draw_x + offx, draw_y + offy + 16)

   self:draw_hp_bars(draw_x, draw_y, offx, offy)
end

return chara_layer
