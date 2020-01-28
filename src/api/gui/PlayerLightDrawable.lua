local Draw = require("api.Draw")
local Rand = require("api.Rand")
local UiTheme = require("api.gui.UiTheme")

local PlayerLightDrawable = class.class("PlayerLightDrawable")

function PlayerLightDrawable:init()
   self.frames = 0
   self.flicker = 0
   self.t = UiTheme.load(self)
   local coords = Draw.get_coords()
   local tw, th = coords:get_size()
   self.offset_x = math.floor(tw / 2)
   self.offset_y = math.floor(th / 2)
end

function PlayerLightDrawable:serialize()
   self.t = nil
end

function PlayerLightDrawable:deserialize()
   self.t = UiTheme.load(self)
end

function PlayerLightDrawable:update(dt)
   self.frames = self.frames + dt * 6
   if self.frames > 1 then
      self.frames = math.fmod(self.frames, 1)
      self.flicker = Rand.rnd(10)
   end
end

function PlayerLightDrawable:draw(x, y)
   love.graphics.setBlendMode("add")
   self.t.player_light:draw(x + self.offset_x, y + self.offset_y, nil, nil, {255, 255, 255,self.flicker+50}, true)
   love.graphics.setBlendMode("alpha")
   Draw.set_color(255, 255, 255)
end

return PlayerLightDrawable
