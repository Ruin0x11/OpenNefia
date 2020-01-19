local Draw = require("api.Draw")
local Ui = require("api.Ui")
local Gui = require("api.Gui")

local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local TopicWindow = require("api.gui.TopicWindow")
local UiTheme = require("api.gui.UiTheme")
local InputHandler = require("api.gui.InputHandler")

local NumberPrompt = class.class("NumberPrompt", IUiLayer)

NumberPrompt:delegate("input", IInput)

function NumberPrompt:init(max, initial, autocenter)
   max = math.max(max or 100, 1)
   if initial then
      self.initial = math.clamp(initial, 1, max)
   else
      initial = max
   end

   self.max = max
   self.number = initial
   self.width = 8 * 16 + 60
   self.height = 36
   self.autocenter = autocenter
   if autocenter == nil then self.autocenter = true end

   local str = tostring(self.number)
   if #str >= 3 then
      self.width = self.width + Draw.text_width(str, 16)
   end

   self.win = TopicWindow:new(0, 2)
   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
end

function NumberPrompt:make_keymap()
   return {
      north = function()
         self:set_number(self.max)
         Gui.play_sound("base.cursor1")
      end,
      south = function()
         self:set_number(1)
         Gui.play_sound("base.cursor1")
      end,
      west = function()
         self:modify_number(-1)
         Gui.play_sound("base.cursor1")
      end,
      east = function()
         self:modify_number(1)
         Gui.play_sound("base.cursor1")
      end,
      -- TODO: intercardinal actions
      cancel = function() self.canceled = true end,
      escape = function() self.canceled = true end,
      enter = function() self.finished = true end,
   }
end

function NumberPrompt:on_query()
   Gui.play_sound("base.pop2")
end

function NumberPrompt:modify_number(delta)
   self:set_number(self.number + delta)
end

function NumberPrompt:set_number(num)
   self.number = math.clamp(num, 1, self.max)
end

function NumberPrompt:relayout(x, y, width, height)
   if self.autocenter then
      x, y = Ui.params_centered(self.width, self.height)
   end
   self.x = x
   self.y = y
   self.t = UiTheme.load(self)

   self.win:relayout(self.x + 20, self.y, self.width - 40, self.height)
end

function NumberPrompt:draw()
   Draw.filled_rect(self.x + 24, self.y + 4, self.width - 42, self.height - 1, {0, 0, 0, 127})

   self.win:draw()

   Draw.set_color(255, 255, 255)
   self.t.label_input:draw(self.x + math.floor(self.width / 2) - 56, self.y - 32)
   self.t.arrow_left:draw(self.x + 28, self.y + 4)
   self.t.arrow_right:draw(self.x + self.width - 51, self.y + 4)

   local text = string.format("%d(%d)", self.number, self.max)
   Draw.text(text, self.x + self.width - 70 - Draw.text_width(text) + 8,
             self.y + 11, -- y + vfix + 11
             {255, 255, 255})
end

function NumberPrompt:update()
   if self.finished then
      self.finished = false
      return self.number
   end

   if self.canceled then
      return nil, "canceled"
   end

   self.win:update()
end

return NumberPrompt
