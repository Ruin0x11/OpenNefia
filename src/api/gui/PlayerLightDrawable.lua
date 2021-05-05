local IDrawable = require("api.gui.IDrawable")
local Draw = require("api.Draw")
local Rand = require("api.Rand")
local UiTheme = require("api.gui.UiTheme")
local config = require("internal.config")
local save = require("internal.global.save")

local PlayerLightDrawable = class.class("PlayerLightDrawable", IDrawable)

function PlayerLightDrawable:init()
   self.frames = 0
   self.color = {255, 255, 255, 50}
   local coords = Draw.get_coords()
   local tw, th = coords:get_size()
   self.offset_x = math.floor(tw / 2)
   self.offset_y = math.floor(th / 2)
   self.t = nil
end

function PlayerLightDrawable:is_drawable_in_ui()
   return false
end

function PlayerLightDrawable:serialize()
   self.t = nil
end

function PlayerLightDrawable:deserialize()
end

function PlayerLightDrawable:update(dt)
   self.frames = self.frames + dt / (config.base.screen_refresh * (16.66 / 1000))
   if self.frames > 1 then
      self.frames = math.fmod(self.frames, 1)
      local hour = save.base.date.hour
      local flicker
      if hour > 17 or hour < 6 then
         flicker = Rand.rnd(10)
      else
         flicker = -15
      end

      -- avoid allocation
      self.color[4] = flicker + 50
   end
end

function PlayerLightDrawable:draw(x, y, w, h, centered, rot)
   if self.t == nil then
      self.t = UiTheme.load(self)
   end
   Draw.set_blend_mode("add")
   Draw.set_color(self.color)
   self.t.base.player_light:draw(x + self.offset_x, y + self.offset_y, nil, nil, nil, true)
   Draw.set_blend_mode("alpha")
   Draw.set_color(255, 255, 255)
end

return PlayerLightDrawable
