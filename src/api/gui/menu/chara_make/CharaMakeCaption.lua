local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")
local ISettable = require("api.gui.ISettable")
local UiTheme = require("api.gui.UiTheme")
local I18N = require("api.I18N")

local CharaMakeCaption = class.class("CharaMakeCaption", {IUiElement, ISettable})

function CharaMakeCaption:init(caption)
   self.width = 760
   self.height = 24

   self.caption = I18N.get(caption) or caption
end

function CharaMakeCaption:set_data(caption)
   self.caption = caption or self.caption
   self.caption = I18N.get_optional(caption) or caption
   self:relayout()
end

function CharaMakeCaption:relayout(x, y)
   self.x = x or self.x
   self.y = y or self.y
   self.t = UiTheme.load(self)

   local width = math.min(Draw.text_width(self.caption) + 45, 760)

   self.width = width

   self.i_caption = self.t.base.caption:make_instance(self.width)
end

function CharaMakeCaption:update()
end

function CharaMakeCaption:draw()
   Draw.set_font(16) -- 16 - en * 2

   local count = math.ceil(self.width / 128)
   local step
   for i=0,count do
      local q
      if i == count then
         step = self.width % 128
         q = 3
      else
         step = 128
         q = 0
      end

      self.i_caption:draw_region(1 + q, i * 128 + self.x, self.y, nil, nil, {255, 255, 255})
      self.i_caption:draw_region(2 + q, i * 128 + self.x, self.y + 2, nil, nil, {255, 255, 255})
      self.i_caption:draw_region(3 + q, i * 128 + self.x, self.y + 22, nil, nil, {255, 255, 255})
   end

   Draw.text(self.caption, self.x + 18, self.y + 4, {245, 245, 245}) -- y + vfix + 4
end

return CharaMakeCaption
