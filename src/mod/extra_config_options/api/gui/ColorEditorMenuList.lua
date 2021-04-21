local Draw = require("api.Draw")
local IInput = require("api.gui.IInput")
local IPaged = require("api.gui.IPaged")
local IUiList = require("api.gui.IUiList")
local InputHandler = require("api.gui.InputHandler")
local UiList = require("api.gui.UiList")
local UiTheme = require("api.gui.UiTheme")
local IList = require("api.gui.IList")
local Gui = require("api.Gui")
local ListModel = require("api.gui.ListModel")
local I18N = require("api.I18N")

local ColorEditorMenuList = class.class("ColorEditorMenuList", IUiList)

ColorEditorMenuList:delegate("model", IList)
ColorEditorMenuList:delegate("model", IPaged)
ColorEditorMenuList:delegate("input", IInput)

function ColorEditorMenuList:make_keymap()
   return {
      north = function()
         self:select_previous()
         Gui.play_sound("base.cursor1")
      end,
      south = function()
         self:select_next()
         Gui.play_sound("base.cursor1")
      end,
      west = function() self:change(self.model:selected_index(), -1) end,
      east = function() self:change(self.model:selected_index(), 1) end,
      enter = function() self.chosen = true end,
      escape = function() self.canceled = true end,
      cancel = function() self.canceled = true end,
   }
end

function ColorEditorMenuList:init(color)
   self.color = color or { 255, 255, 255, 255 }
   for i = 1, 4 do
      self.color[i] = self.color[i] or 255
   end
   self.item_height = 21

   self.model = ListModel:new(self.color)

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
end

function ColorEditorMenuList:change(index, delta)
   Gui.play_sound("base.cursor1")
   local v = self.model.items[index]
   self.model.items[index] = math.clamp(v + delta, 0, 255)
end

function ColorEditorMenuList:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height

   self.t = UiTheme.load(self)
end

function ColorEditorMenuList:draw_item(item, i, x, y)
   Draw.set_color(self.t.base.text_color)
   Draw.set_font(14)

   local title
   if i == 1 then
      title = "extra_config_options:ui.menu.color_editor.value.red"
   elseif i == 2 then
      title = "extra_config_options:ui.menu.color_editor.value.green"
   elseif i == 3 then
      title = "extra_config_options:ui.menu.color_editor.value.blue"
   else
      title = "extra_config_options:ui.menu.color_editor.value.alpha"
   end

   UiList.draw_item_text(self, I18N.get(title), item, i, x, y - 1)

   Draw.text(tostring(item), x + 134, y)

   Draw.set_color(255, 255, 255)
   self.t.base.arrow_left:draw(x + 104, y - 5)
   self.t.base.arrow_right:draw(x + 182, y - 5)
end

function ColorEditorMenuList:draw()
   Draw.set_font(14) -- 14 - en * 2
   for i = 1, 4 do
      local item = self.model:get(i)
      if self:can_select(self:selected_item(), self.selected) then
         local x = self.x
         local y = (i - 1) * self.item_height + self.y
         self:draw_item(item, i, x, y)
      end
   end
end

function ColorEditorMenuList:update(dt)
   if self.canceled then
      return self.color, "canceled"
   end
   if self.chosen then
      self.chosen = false
      return self.color
   end

   UiList.update(self)
end

return ColorEditorMenuList
