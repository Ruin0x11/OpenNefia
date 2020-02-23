local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Ui = require("api.Ui")

local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local UiTheme = require("api.gui.UiTheme")

local PicViewer = class.class("PicViewer", IUiLayer)

PicViewer:delegate("input", IInput)

function PicViewer:init(drawable)
   assert(type(drawable.draw) == "function")

   self.width = drawable:get_width() + 20
   self.height = drawable:get_height() + 20

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
   self.drawable = drawable
end

function PicViewer:make_keymap()
   return {
      cancel = function() self.canceled = true end,
      escape = function() self.canceled = true end,
      enter = function() self.canceled = true end,
   }
end

function PicViewer:on_query()
   Gui.play_sound("base.pop2")
end

function PicViewer:relayout()
   self.x, self.y, self.width, self.height = Ui.params_centered(self.width, self.height)
   self.y = self.y
end

function PicViewer:draw()
   Draw.filled_rect(self.x, self.y, self.width, self.height, {0, 0, 0})
   Draw.line_rect(self.x+9, self.y+9, self.width-18, self.height-18, {255, 255, 255})
   self.drawable:draw(self.x + 10, self.y + 10, nil, nil, {255, 255, 255})
end

function PicViewer:update(dt)
   if self.canceled then
      return nil, "canceled"
   end
end

function PicViewer.start(asset)
   local asset = UiTheme.load()[asset]
   if asset == nil then
      error("unknown asset " .. asset)
   end
   print"go"
   PicViewer:new(asset):query()
end

return PicViewer
