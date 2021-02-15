local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local UiTheme = require("api.gui.UiTheme")
local Ui = require("api.Ui")
local Draw = require("api.Draw")
local UiWindow = require("api.gui.UiWindow")
local VisualAIConfigureBlockList = require("mod.visual_ai.api.gui.VisualAIConfigureBlockList")

local VisualAIConfigureBlockMenu = class.class("VisualAIConfigureBlockMenu", IUiLayer)

VisualAIConfigureBlockMenu:delegate("input", IInput)

function VisualAIConfigureBlockMenu:init(vars)
   self.vars = vars

   self.win = UiWindow:new("Configure Block", true)
   self.list = VisualAIConfigureBlockList:new(self.vars)

   self.input = InputHandler:new()
   self.input:forward_to(self.list)
   self.input:bind_keys(self:make_keymap())
end

function VisualAIConfigureBlockMenu:make_keymap()
   return {
      enter = function() self.chosen = true end,
      escape = function() self.canceled = true end,
      cancel = function() self.canceled = true end
   }
end

function VisualAIConfigureBlockMenu:on_query()
   self.canceled = false
   self.chosen = false
end

function VisualAIConfigureBlockMenu:relayout()
   self.width = 440
   self.height = 300
   if self.list:len() > 8 then
      self.height = self.height + 10 + 30 * (self.list:len() - 9)
   end

   print(self.list:len(), self.height)
   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.y = self.y - 12

   self.t = UiTheme.load(self)

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.list:relayout(self.x + 56, self.y + 66)
end

function VisualAIConfigureBlockMenu:draw()
   -- >>>>>>>> elona122/shade2/help.hsp:936 	redraw 0 ...
   self.win:draw()

   Ui.draw_topic("Options", self.x + 34, self.y + 36)

   local bg_width = self.width / 5 * 3
   local bg_height = self.height - 80
   Draw.set_color(255, 255, 255, 50)
   self.t.base.g2:draw(
      self.x + self.width / 3,
      self.y + self.height / 2,
      bg_width,
      bg_height,
      nil,
      true)

   self.list:draw()
   -- <<<<<<<< elona122/shade2/help.hsp:979 	cs_list s,wX+56+x ,wY+66+cnt*19-1,19,0 ..
end

function VisualAIConfigureBlockMenu:update(dt)
   if self.chosen then
      return self.list:get_vars(), nil
   end

   self.win:update()
   self.list:update()

   if self.canceled then
      return nil, "canceled"
   end
end

return VisualAIConfigureBlockMenu
