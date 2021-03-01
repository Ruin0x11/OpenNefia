local IDrawable = require("api.gui.IDrawable")
local Log = require("api.Log")

local draw_callbacks = class.class("draw_callbacks", IDrawable)

function draw_callbacks:init()
   self.draw_callbacks = {}
   self.waiting = false
   self.dt_this_frame = 0.0
end

function draw_callbacks:add(cb, tag, kind)
   if kind then
      assert(kind == "background", "invalid draw callback kind " .. tostring(kind))
   end

   local key = #self.draw_callbacks+1
   if tag ~= nil then
      if type(tag) ~= "string" then
         error(("Draw callback tag must be a string, got: '%s'"):format(tag))
      end
      key = tag
   end

   self.draw_callbacks[key] = {
      thread = coroutine.create(cb),
      dt = 0,
      is_background = kind == "background"
   }
end

function draw_callbacks:remove(tag)
   if self.draw_callbacks[tag] == nil then
      Log.debug("Tried to stop draw callback '%s' but it didn't exist.", tag)
      return
   end

   self.draw_callbacks[tag] = nil
end

local function resume_coroutine(co, draw_x, draw_y, frame_delta, dt_this_frame)
   local ok, dt = coroutine.resume(co.thread, draw_x, draw_y, frame_delta, dt_this_frame)
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

function draw_callbacks:draw(draw_x, draw_y)
   local dead = {}
   local Draw = require("api.Draw")
   local coords = Draw.get_coords()
   local sx = 0
   local sy = 0
   if coords then
     sx, sy = coords:get_start_offset(draw_x, draw_y)
   end

   draw_x = sx - draw_x
   draw_y = sy - draw_y

   Draw.set_color(255, 255, 255)

   -- TODO: order by priority
   for key, co in pairs(self.draw_callbacks) do
      if co.dt > 0 then
         -- This frame has not been advanced yet; redraw the animation
         -- on the current frame (delta 0)
         local going = resume_coroutine(co, draw_x, draw_y, 0, self.dt_this_frame)
         if not going then
            -- Coroutine error; stop drawing now
            dead[#dead+1] = key
         end
      else
         local frames = 0
         while co.dt <= 0 do
            -- TODO: assumes 60 FPS
            frames = frames + 1
            co.dt = co.dt + 16.66 / 1000
         end
         -- Advance the passed number of frames
         local going, dt = resume_coroutine(co, draw_x, draw_y, frames, self.dt_this_frame)
         if not going then
            -- Coroutine error; stop drawing now
            dead[#dead+1] = key
            break
         else
            dt = (dt or 16.66) / 1000
            co.dt = co.dt + dt
         end
      end
   end

   table.remove_keys(self.draw_callbacks, dead)
end

function draw_callbacks:update(dt)
   -- TODO: order by priority
   for _, co in pairs(self.draw_callbacks) do
      co.total = co.total or 0
      co.total = co.total + dt
      co.dt = co.dt - dt
   end
   self.dt_this_frame = dt

   if self:has_more() and self.waiting then
      return true
   end

   self.waiting = false
   return false
end

function draw_callbacks:has_more()
   for _, draw_cb in pairs(self.draw_callbacks) do
      if not draw_cb.is_background then
         return true
      end
   end
   return false
end

function draw_callbacks:wait()
   self.waiting = true

   local dt, _, skip
   local has_cbs
   dt = 0

   repeat
      has_cbs = self:update(dt)
      if not has_cbs then
         return
      end
      dt, _, skip = coroutine.yield()
   until not has_cbs or skip

   self.waiting = false
end

return draw_callbacks
