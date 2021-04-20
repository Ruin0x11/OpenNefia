local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local UiTheme = require("api.gui.UiTheme")
local UiWindow = require("api.gui.UiWindow")
local Draw = require("api.Draw")
local ColorEditorMenuList = require("mod.extra_config_options.api.gui.ColorEditorMenuList")
local Ui = require("api.Ui")
local Gui = require("api.Gui")

local ColorEditorMenu = class.class("ColorEditorMenu", IUiLayer)

ColorEditorMenu:delegate("input", IInput)

function ColorEditorMenu:init(color)
   self.win = UiWindow:new("extra_config_options:ui.menu.color_editor.title", true)
   self.list = ColorEditorMenuList:new(color)

   self.input = InputHandler:new()
   self.input:forward_to(self.list)
   self.input:bind_keys(self:make_keymap())
end

function ColorEditorMenu:make_keymap()
   return {}
end

function ColorEditorMenu:on_query()
   Gui.play_sound("base.pop2")
end

function ColorEditorMenu:relayout()
   self.width = 360
   self.height = 190
   self.x, self.y = Ui.params_centered(self.width, self.height)

   self.t = UiTheme.load(self)

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.list:relayout(self.x + 26, self.y + 46, self.width, self.height)
end

function ColorEditorMenu:draw()
   self.win:draw()
   self.list:draw()

   Draw.set_color(self.t.base.text_color)
   Draw.line_rect(self.x + 243, self.y + 45, 82, 82)
   Draw.set_color(self.list.color)
   Draw.filled_rect(self.x + 244, self.y + 46, 80, 80)
end

function ColorEditorMenu:update(dt)
   self.win:update(dt)

   local color, canceled = self.list:update(dt)
   if color then
      return color
   end
end

return ColorEditorMenu
