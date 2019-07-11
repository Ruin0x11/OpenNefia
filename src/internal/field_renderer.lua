local shadow_batch = require("internal.draw.shadow_batch")
local sparse_batch = require("internal.draw.sparse_batch")
local tile_batch = require("internal.draw.tile_batch")
local sound_manager = require("internal.global.sound_manager")
local Draw = require("api.Draw")

local field_renderer = class.class("field_renderer")

function field_renderer:init(width, height, layers)
   local coords = Draw.get_coords()

   self.width = width
   self.height = height
   self.coords = coords
   self.draw_x = 0
   self.draw_y = 0

   self.screen_updated = true

   self.draw_coroutines = {}
   self.layers = {}

   self.scroll = nil
   self.scroll_frames = 0
   self.scroll_max_frames = 0
   self.scroll_x = 0
   self.scroll_y = 0

   for _, require_path in ipairs(layers) do
      -- WARNING: This needs to be sanitized by moving all the layers
      -- to the public API, to prevent usage of the global require.
      local layer, err = package.try_require(require_path)
      if layer == nil then
         error("Could not load draw layer " .. require_path .. ":\n\t" .. err)
      end
      local IDrawLayer = require("api.gui.IDrawLayer")

      local instance = layer:new(width, height)
      class.assert_is_an(IDrawLayer, instance)

      -- TODO
      instance:relayout()

      self.layers[#self.layers+1] = instance
   end
end

function field_renderer:set_scroll(dx, dy, scroll_frames)
   self.scroll = { dx = dx, dy = dy }
   self.scroll_max_frames = scroll_frames
   self.scroll_frames = self.scroll_max_frames
end

function field_renderer:update_draw_pos(player_x, player_y, scroll_frames)
   local draw_x, draw_y = self.coords:get_draw_pos(player_x,
                                                   player_y,
                                                   self.width,
                                                   self.height,
                                                   Draw.get_width(),
                                                   Draw.get_height())

   if scroll_frames then
      self:set_scroll(self.draw_x - draw_x, self.draw_y - draw_y, scroll_frames)
   else
      self.scroll = nil
      self.scroll_frames = 0
   end

   self:set_draw_pos(draw_x, draw_y)

   sound_manager:set_listener_pos(self.coords:tile_to_screen(player_x, player_y))
end

function field_renderer:set_draw_pos(draw_x, draw_y)
   self.draw_x = draw_x
   self.draw_y = draw_y
   self.screen_updated = true
end

function field_renderer:add_async_draw_callback(cb)
   self.draw_coroutines[#self.draw_coroutines+1] = coroutine.create(cb)
end

function field_renderer:draw()
   local draw_x = self.draw_x
   local draw_y = self.draw_y

   for _, l in ipairs(self.layers) do
      l:draw(draw_x, draw_y, self.scroll_x, self.scroll_y)
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

function field_renderer:update(dt)
   -- BUG: this really doesn't look like the original Elona's
   -- scrolling. The issue is here it is based on dt. In vanilla
   -- scrolling would always scroll by a fixed amount of pixels
   -- between 40ms pauses, regardless of framerate. This meant the
   -- framerate the game ran at affected the speed of scrolling, but
   -- the effect ends up being different. There should be a
   -- compatability option for vanilla.
   if self.scroll then
      self.scroll_frames = self.scroll_frames - Draw.msecs_to_frames(dt*1000)
      if self.scroll_frames <= 0 then
         self.scroll = nil
         self.scroll_x = 0
         self.scroll_y = 0
      else
         local p = 1 - (self.scroll_frames/self.scroll_max_frames)
         self.scroll_x = (self.scroll.dx - (p * self.scroll.dx))
         self.scroll_y = (self.scroll.dy - (p * self.scroll.dy))
      end
   end

   local going = false
   for _, l in ipairs(self.layers) do
      local result = l:update(dt, self.screen_updated, self.scroll_frames)
      if result then -- not nil or false
         going = true
      end
   end

   if not going then
      self.screen_updated = false
   end

   return going
end

return field_renderer
