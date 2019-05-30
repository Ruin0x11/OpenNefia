local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")
local TopicWindow = require("api.gui.TopicWindow")

local ChangeAppearancePreview = class("ChangeAppearancePreview", IUiElement)
ChangeAppearancePreview:delegate("topic_window", {"x", "y", "width", "height", "relayout"})

function ChangeAppearancePreview:init(x, y)
   self.topic_window = TopicWindow:new(x, y, 88, 120, 1, 1)
   self.show_portrait = false
   self.frame = 0
   self.direction = 0
   self.chip = Draw.load_image("graphic/temp/chara_female.bmp")
   self.portrait = Draw.load_image("graphic/temp/portrait_female.bmp")
end

function ChangeAppearancePreview:update()
   self.frame = frame + 1
   if self.frame % 100 < 45 then
      self.direction = i % 16
   else
      self.direction = self.direction + 1
   end

   self.topic_window:update()
end

function ChangeAppearancePreview:draw()
   if self.show_portrait then
      Draw.image(self.portrait, self.x + 4, self.y + 4)
   else
      local has_own_sprite = false
      if has_own_sprite then
      else
         Draw.image(self.chip, self.x + 46, self.y + 42)
      end
   end
end

return ChangeAppearancePreview
