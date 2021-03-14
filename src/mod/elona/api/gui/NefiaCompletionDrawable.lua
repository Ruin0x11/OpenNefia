local IDrawable = require("api.gui.IDrawable")
local Draw = require("api.Draw")
local UiTheme = require("api.gui.UiTheme")

local NefiaCompletionDrawable = class.class("NefiaCompletionDrawable", IDrawable)

function NefiaCompletionDrawable:init(state)
   local coords = Draw.get_coords()
   local tw, th = coords:get_size()
   self.t = UiTheme.load(self)
   self.offset_x = math.floor(tw / 4)
   self.offset_y = math.floor(-th / 4)
   self:set_state(state)
end

function NefiaCompletionDrawable:set_state(state)
   if state == "conquered" then
      self.region = 1
   elseif state == "in_progress" then
      self.region = 2
   else
      self.region = 0
   end
end

function NefiaCompletionDrawable:update(dt)
end

function NefiaCompletionDrawable:draw(x, y)
   -- >>>>>>>> shade2/module.hsp:650 				if areaDeepest(p)=areaMaxLevel(p):pos dx+16,dy ...
   if self.region > 0 then
      Draw.set_color(255, 255, 255)
      self.t.base.nefia_mark:draw_region(self.region, x + self.offset_x, y + self.offset_y)
   end
   -- <<<<<<<< shade2/module.hsp:650 				if areaDeepest(p)=areaMaxLevel(p):pos dx+16,dy ..
end

return NefiaCompletionDrawable
