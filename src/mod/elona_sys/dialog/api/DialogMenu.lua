local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Ui = require("api.Ui")

local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local UiList = require("api.gui.UiList")
local UiTheme = require("api.gui.UiTheme")

local DialogMenu = class.class("DialogMenu", IUiLayer)

DialogMenu:delegate("input", IInput)

function DialogMenu:init(text, choices, speaker_name, portrait, chara_image, default_choice)
   self.width = 600
   self.height = 380

   self.text = text
   self.wrapped = {}
   self.choices = choices
   self.speaker_name = speaker_name or ""
   self.portrait = portrait
   self.chara_image = chara_image
   self.default_choice = default_choice
   self.can_cancel = default_choice ~= nil

   if self.choices == nil or #self.choices == 0 then
      self.choices = { "__MORE__" }
   end

   self.pages = UiList:new_paged(self.choices, 8)
   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
   self.input:bind_keys {
      shift = function() self:cancel() end,
      escape = function() self:cancel() end,
   }
end

function DialogMenu:cancel()
   if self.default_choice then
      self.canceled = true
   end
end

function DialogMenu:relayout()
   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.t = UiTheme.load(self)

   self.pages:relayout(self.x + 136, self.y + self.height - 56 - self.pages:len() * 19 + 4, self.width, self.height)

   local _, wrapped = Draw.wrap_text(self.text, self.width - 200)
   self.wrapped = wrapped
end

function DialogMenu:draw()
   self.t.ie_chat:draw(self.x + 4, self.y - 16, nil, nil, {255, 255, 255, 80})
   self.t.ie_chat:draw(self.x, self.y - 20, nil, nil, {255, 255, 255})

   if self.portrait then
      self.portrait:draw(self.x + 42, self.y + 42, 80, 112)
   elseif self.chara_image then
      self.chara_image:draw(self.x + 82,
                            self.y + 125, -- TODO offset_y
                            self.chara_image:get_width() * 2,
                            self.chara_image:get_height() * 2,
                            nil,
                            true)
   end

   -- NOTE: ignored by Ui.draw_topic
   Draw.set_font(10) -- 10 - en * 2

   Ui.draw_topic("impress", self.x + 28, self.y + 170)
   Ui.draw_topic("attract", self.x + 28, self.y + 215)

   Draw.set_font(12, "bold") -- 12 + sizefix - en * 2
   Draw.text(self.speaker_name, self.x + 120, self.y + 16, {20, 10, 5})

   Draw.set_font(13) -- 13 - en * 2
   -- TODO: impress/interest
   Draw.text("-", self.x + 60, self.y + 198, {0, 0, 0})
   Draw.text("-", self.x + 60, self.y + 245, {0, 0, 0})

   Draw.set_font(14) -- 14 - en * 2
   for i, line in ipairs(self.wrapped) do
      Draw.text(line, self.x + 150, self.y + 43 + (i - 1) * 19, {20, 10, 5})
   end

   self.pages:draw()
end

function DialogMenu:update()
   if self.pages.chosen then
      Gui.play_sound("base.more1")
      return self.pages.selected, self.pages:selected_item()
   end

   if self.default_choice and self.canceled then
      Gui.play_sound("base.more1")
      return self.default_choice
   end

   self.pages:update()
end

return DialogMenu
