local Draw = require("api.Draw")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local Ui = require("api.Ui")
local Skill = require("mod.elona_sys.api.Skill")
local Const = require("api.Const")

local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local UiList = require("api.gui.UiList")
local UiTheme = require("api.gui.UiTheme")

local DialogMenu = class.class("DialogMenu", IUiLayer)

DialogMenu:delegate("input", IInput)

function DialogMenu:init(text, choices, speaker_name, portrait, chara_image, image_color, default_choice, is_in_game, impression, interest)
   self.width = 600
   self.height = 380

   self.text = text
   self.wrapped = {}
   self.choices = choices
   self.speaker_name = speaker_name or ""
   self.portrait = portrait
   self.chara_image = chara_image
   self.image_color = image_color
   self.default_choice = default_choice
   self.can_cancel = default_choice ~= nil
   self.is_in_game = is_in_game
   self.impression = impression
   self.interest = interest

   self.chip_batch = nil
   self.portrait_batch = nil

   if self.choices == nil or #self.choices == 0 then
      self.choices = { I18N.get("ui.more") }
   end

   self.pages = UiList:new_paged(self.choices, 8)
   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
   self.input:bind_keys(self:make_keymap())
end

function DialogMenu:make_keymap()
   return {
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
   self.x, self.y = Ui.params_centered(self.width, self.height, self.is_in_game)
   self.t = UiTheme.load(self)

   self.pages:relayout(self.x + 136, self.y + self.height - 56 - self.pages:len() * 19 + 4, self.width, self.height)

   self.chip_batch = Draw.make_chip_batch("chip")
   self.portrait_batch = Draw.make_chip_batch("portrait")

   Draw.set_font(14)
   local _, wrapped = Draw.wrap_text(self.text, self.width - 200)
   self.wrapped = wrapped
end

function DialogMenu:draw()
   self.t.base.ie_chat:draw(self.x + 4, self.y - 16, nil, nil, {255, 255, 255, 80})
   self.t.base.ie_chat:draw(self.x, self.y - 20, nil, nil, {255, 255, 255})

   if self.portrait then
      self.portrait_batch:clear()
      self.portrait_batch:add(self.portrait, self.x + 42, self.y + 42, 80, 112)
      self.portrait_batch:draw()
   elseif self.chara_image then
      self.chip_batch:clear()
      --TODO
      local width = 48
      local height = 48
      self.chip_batch:add(self.chara_image,
                           self.x + 82 + width,
                           self.y + 125 + height, -- TODO offset_y
                           width * 2,
                           height * 2,
                           self.image_color,
                           true)
      self.chip_batch:draw()
   end

   -- >>>>>>>> shade2/chat.hsp:3201  ..
   Ui.draw_topic("talk.window.impress", self.x + 28, self.y + 170)
   Ui.draw_topic("talk.window.attract", self.x + 28, self.y + 215)

   Draw.set_font(12, "bold") -- 12 + sizefix
   Draw.set_color(20, 10, 5)
   Draw.text(self.speaker_name, self.x + 120, self.y + 16)

   Draw.set_font(13)
   if self.impression and self.interest then
      local impression_level = I18N.get("ui.impression._" .. Skill.impression_level(self.impression))
      local impression_value
      if self.impression < Const.IMPRESSION_FELLOW then
         impression_value = tostring(self.impression)
      else
         impression_value = "???"
      end
      Draw.text(("(%s)%s"):format(impression_value, impression_level), self.x + 32, self.y + 198)
      if self.interest >= 0 then
         local icon_count = math.min(math.floor(self.interest / 5 + 1), 20)
         Draw.set_color(255, 255, 255)
         for i = 1, icon_count do
            self.t.base.impression_icon:draw(self.x + 26 + (i - 1) * 4, self.y + 245)
         end
      end
   else
      Draw.set_color(0, 0, 0)
      Draw.text("-", self.x + 60, self.y + 198)
      Draw.text("-", self.x + 60, self.y + 245)
   end

   Draw.set_font(14)
   Draw.set_color(20, 10, 5)
   for i, line in ipairs(self.wrapped) do
      Draw.text(line, self.x + 150, self.y + 43 + (i - 1) * 19)
   end

   self.pages:draw()
   -- <<<<<<<< shade2/chat.hsp:3239 	loop ..
end

function DialogMenu:update()
   if self.pages.chosen then
      Gui.play_sound("base.more1")
      return self.pages.selected, self.pages:selected_item()
   end

   if self.default_choice and self.canceled then
      Gui.play_sound("base.more1")
      return self.default_choice, "canceled"
   end

   self.pages:update()
end

function DialogMenu:release()
   if self.chip_batch then
      self.chip_batch:release()
   end
   if self.portrait_batch then
      self.portrait_batch:release()
   end
end

return DialogMenu
