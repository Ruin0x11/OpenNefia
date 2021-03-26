local Draw = require("api.Draw")
local Gui = require("api.Gui")
local UiTheme = require("api.gui.UiTheme")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")

local MorePrompt = class.class("MorePrompt", IUiLayer)

MorePrompt:delegate("input", IInput)

function MorePrompt:init()
   self.size = 0
   self.delay = 0
   self.size2 = 0
   self.canceled = false
   self.can_cancel = false

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
   self.input:halt_input()
end

function MorePrompt:default_z_order()
   return 1000000
end

function MorePrompt:make_keymap()
   local function proceed()
      if self.can_cancel then
         Gui.play_sound("base.ok1")
         self.canceled = true
      end
   end

   return {
      cancel = proceed,
      escape = proceed,
      enter = proceed
   }
end

function MorePrompt:relayout(x, y)
   if x == 0 and y == 0 then
      self.x = Draw.get_width() - 120
      self.y = Draw.get_height() - 22
   else
      self.x = x or self.x
      self.y = y or self.y
   end
   self.width = 120
   self.height = 22
   self.t = UiTheme.load(self)
end

function MorePrompt:draw()
   Draw.set_color(255, 255, 255)
   if self.canceled then
      if self.size2 < 6 then
         self.t.base.more_prompt:draw(self.x, self.y + self.size2 * 2, self.width, self.height - self.size2 * 4)
      end
   elseif self.size > 0 then
      self.t.base.more_prompt:draw(self.x, self.y + 12 - self.size, self.width, self.size * 2 + 1)
   end
end

function MorePrompt:update(dt)
   local msecs = dt * 1000

   if self.canceled then
      if self.size2 >= 7 then
         return {}, "canceled"
      else
         self.size2 = self.size2 + (msecs / 10)
      end
   elseif not self.can_cancel then
      self.size = self.size + (msecs / 10)
      if self.size >= 12 then
         self.size = 12
         self.delay = self.delay + (msecs / 10)
         if self.delay > 20 then
            self.can_cancel = true
         end
      end
   end
end

return MorePrompt
