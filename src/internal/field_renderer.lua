local sound_manager = require("internal.global.sound_manager")
local Draw = require("api.Draw")
local Log = require("api.Log")

local field_renderer = class.class("field_renderer")

function field_renderer:init(width, height, layers)
   local coords = Draw.get_coords()

   self.width = width
   self.height = height
   self.coords = coords
   self.draw_x = 0
   self.draw_y = 0

   self.screen_updated = true

   self.draw_callbacks = {}
   self.layers = {}

   self.scroll = nil
   self.scroll_frames = 0
   self.scroll_max_frames = 0
   self.scroll_x = 0
   self.scroll_y = 0

   for _, require_path in ipairs(layers) do
      -- WARNING: This needs to be sanitized by moving all the layers
      -- to the public API, to prevent usage of the global require.
      local ok, layer = pcall(require, require_path)
      if not ok then
         error("Could not load draw layer " .. require_path .. ":\n\t" .. layer)
      end
      local IDrawLayer = require("api.gui.IDrawLayer")

      local instance = layer:new(width, height, coords)
      class.assert_is_an(IDrawLayer, instance)

      -- TODO
      instance:relayout()

      self.layers[#self.layers+1] = instance
   end
end

function field_renderer:set_map(map, layers)
   local draw_callbacks = self.draw_callbacks

   self:init(map:width(), map:height(), layers)

   self.draw_callbacks = draw_callbacks
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

function field_renderer:draw_pos()
   return self.draw_x, self.draw_y, self.scroll_x, self.scroll_y
end

function field_renderer:add_async_draw_callback(cb, tag)
   local key = #self.draw_callbacks+1
   if tag ~= nil then
      if type(tag) ~= "string" then
         error(("Draw callback tag must be a string, got: '%s'"):format(tag))
      end
      key = tag
   end

   self.draw_callbacks[key] = {
      thread = coroutine.create(cb),
      dt = 0
   }
end

function field_renderer:remove_async_draw_callback(tag)
   if self.draw_callbacks[tag] == nil then
      Log.debug("Tried to stop draw callback '%s' but it didn't exist.", tag)
      return
   end

   self.draw_callbacks[tag] = nil
end

function field_renderer:update_draw_callbacks(dt)
   -- TODO: order by priority
   for _, co in pairs(self.draw_callbacks) do
      co.dt = co.dt - dt
   end

   return #self.draw_callbacks > 0
end

local function resume_coroutine(co, draw_x, draw_y, frame_delta)
   local ok, dt = coroutine.resume(co.thread, draw_x, draw_y, frame_delta)
   local is_dead = coroutine.status(co.thread) == "dead"
   if is_dead or not ok then
      local err = dt
      if err then
         local Gui = require("api.Gui")
         Gui.report_error(debug.traceback(co.thread, err), "Error in draw callback")
      end
      return false, 0
   end
   return true, dt
end

function field_renderer:draw()
   local draw_x = self.draw_x
   local draw_y = self.draw_y
   local sx, sy = Draw.get_coords():get_start_offset(draw_x, draw_y)

   for _, l in ipairs(self.layers) do
      local ok, result = xpcall(function() l:draw(draw_x, draw_y, self.scroll_x, self.scroll_y) end, debug.traceback)
      if not ok then
         print(result)
      end
   end

   Draw.set_color(255, 255, 255)

   draw_x = sx - draw_x
   draw_y = sy - draw_y
   local dead = {}

   -- TODO: order by priority
   for key, co in pairs(self.draw_callbacks) do
      if co.dt > 0 then
         -- This frame has not been advanced yet; redraw the animation
         -- on the current frame (delta 0)
         local going = resume_coroutine(co, draw_x, draw_y, 0)
         if not going then
            -- Coroutine error; stop drawing now
            dead[#dead+1] = key
         end
      else
         while co.dt <= 0 do
            -- Advance one frame (delta 1)
            local going, dt = resume_coroutine(co, draw_x, draw_y, 1)
            if not going then
               -- Coroutine error; stop drawing now
               dead[#dead+1] = key
               break
            else
               -- TODO: assumes 60 FPS
               dt = math.max(dt or 16.66, 16.66) / 1000
               co.dt = co.dt + dt
            end
         end
      end
   end

   table.remove_keys(self.draw_callbacks, dead)
end

function field_renderer:update(dt)
   self:update_draw_callbacks(dt)

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
