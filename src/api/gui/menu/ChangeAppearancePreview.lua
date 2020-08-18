local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")
local TopicWindow = require("api.gui.TopicWindow")
local Log = require("api.Log")

local ChangeAppearancePreview = class.class("ChangeAppearancePreview", IUiElement)

function ChangeAppearancePreview:init(chara)
   self.width = 88
   self.height = 120
   self.chara = chara or nil

   self.topic_window = TopicWindow:new(1, 1)
   self.show_portrait = false
   self.frame = 0
   self.pcc_frame = 0
end

function ChangeAppearancePreview:relayout(x, y)
   self.x = x
   self.y = y

   self.topic_window:relayout(self.x, self.y, self.width, self.height)

   self.chip_batch = Draw.make_chip_batch("chip")
   self.portrait_batch = Draw.make_chip_batch("portrait")
end

function ChangeAppearancePreview:draw()
   self.topic_window:draw()

   if self.chara then
      if self.show_portrait then
         if self.chara.portrait then
            self.portrait_batch:clear()
            self.portrait_batch:add(self.chara.portrait, self.x + 4, self.y + 4, 80, 112)
            self.portrait_batch:draw()
         end
      elseif self.chara.pcc then
         self.chara.pcc.frame = math.floor(self.pcc_frame / 4) % 4 + 1
         self.chara.pcc.dir = math.floor(self.pcc_frame / 16) % 4 + 1
         self.chara.pcc:draw(self.x + 36 - 24, self.y + 59 - 40, 2.0, 2.0)
      elseif self.chara.image then
         self.chip_batch:clear()
         local width, height = Draw.get_coords():get_size()
         self.chip_batch:add(self.chara.image, self.x + 46 - 24, self.y + 59 - 24, width, height)
         self.chip_batch:draw()
      end
   end
end

function ChangeAppearancePreview:update(dt)
   dt = dt * 50
   self.frame = self.frame + dt
   local frame = math.floor(self.frame)
   if frame % 100 < 45 then
      self.pcc_frame = frame % 16
   else
      self.pcc_frame = self.pcc_frame + dt
   end

   self.topic_window:update()
end

return ChangeAppearancePreview
