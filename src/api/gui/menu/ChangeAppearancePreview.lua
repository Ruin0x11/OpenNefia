local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")
local TopicWindow = require("api.gui.TopicWindow")

local ChangeAppearancePreview = class("ChangeAppearancePreview", IUiElement)

function ChangeAppearancePreview:init()
   self.width = 88
   self.height = 120

   self.topic_window = TopicWindow:new(1, 1)
   self.show_portrait = false
   self.frame = 0
   self.direction = 0
   self.chip = Draw.load_image("graphic/temp/chara_female.bmp")
   self.portrait = Draw.load_image("graphic/temp/portrait_female.bmp", false)
end

function ChangeAppearancePreview:relayout(x, y)
   self.x = x
   self.y = y

   self.topic_window:relayout(self.x, self.y, self.width, self.height)
end

function ChangeAppearancePreview:update()
   self.frame = self.frame + 1
   if self.frame % 100 < 45 then
      self.direction = self.frame % 16
   else
      self.direction = self.direction + 1
   end

   self.topic_window:update()
end

function ChangeAppearancePreview:draw()
   self.topic_window:draw()
   if self.show_portrait then
      Draw.image(self.portrait, self.x + 4, self.y + 4, 80, 112)
   else
      local has_own_sprite = false
      if has_own_sprite then
      else
         Draw.image(self.chip, self.x + 46, self.y + 59, nil, nil, nil, true)
      end
   end
end

return ChangeAppearancePreview
