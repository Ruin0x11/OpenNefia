local Draw = require("api.Draw")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local Ui = require("api.Ui")
local Rand = require("api.Rand")
local IUiLayer = require("api.gui.IUiLayer")
local Window = require("api.gui.Window")

local Event = require("api.Event")
local UiList = require("api.gui.UiList")
local UiWindow = require("api.gui.UiWindow")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")
local UiTheme = require("api.gui.UiTheme")

local RandomEventPrompt = class.class("RandomEventPrompt", IUiLayer)

RandomEventPrompt:delegate("input", IInput)

local UiListExt = function(select_alias_menu)
   local E = {}

   function E:get_item_text(item)
      return item
   end
   function E:on_choose(item)
      if item.on_choose then
         self.chosen = false
         item.on_choose()
      end
   end
   function E:draw_item_text(text, item, i, x, y, x_offset)
      UiList.draw_item_text(self, text, item, i, x, y, x_offset)

      if item.locked then
         Draw.set_font(12, "bold") -- 12 - en * 2
         Draw.text("Locked!", x + 216, y + 2, {20, 20, 140})
      end
   end

   return E
end

function RandomEventPrompt:init(title, text, image, choices)
   self.win = Window:new()
   self.win_shadow = Window:new(true)

   local items = fun.iter(choices):map(function(c) return I18N.get_optional(c) or c end):to_list()
   self.list = UiList:new(items)
   table.merge(self.list, UiListExt(self))

   self.title = I18N.get("random_event.title", I18N.get_optional(title) or title)
   self.text = I18N.get_optional(text) or text
   self.image = image

   self.can_cancel = false

   self.input = InputHandler:new()
   self.input:forward_to(self.list)
   self.input:bind_keys(self:make_keymap())
end

function RandomEventPrompt:make_keymap()
   return {
      escape = function() if self.can_cancel then self.canceled = true end end,
      cancel = function() if self.can_cancel then self.canceled = true end end,
   }
end

function RandomEventPrompt:on_query()
   Gui.play_sound("base.pop4")
end

function RandomEventPrompt:relayout(x, y)
   self.t = UiTheme.load(self)

   Draw.set_font(14)

   local asset = self.t[self.image]
   self.width = asset:get_width() + 36
   local _, wrapped = Draw.wrap_text(self.text, self.width - 80)
   self.wrapped = wrapped
   self.height = asset:get_height() + #self.wrapped * 15 + 80 + self.list:len() * 20
   self.x, self.y = Ui.params_centered(self.width, self.height - 16)
   self.y = self.y + 16

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.win_shadow:relayout(self.x + 4, self.y + 4, self.width, self.height - self.height % 8)
   self.list:relayout(self.x + 38, self.y + 30 + #self.wrapped * 15 + asset:get_height() + 16)
end

function RandomEventPrompt:draw()
   Draw.set_color(255, 255, 255, 80)
   Draw.set_blend_mode("subtract")
   self.win_shadow:draw()
   Draw.set_blend_mode("alpha")

   Draw.set_color(255, 255, 255)
   self.win:draw()

   Draw.set_color(255, 255, 255)
   local asset = self.t[self.image]
   asset:draw(self.x + 12, self.y + 6 + 16)
   Draw.set_color(240, 230, 220)
   Draw.line_rect(self.x + 12, self.y + 6 + 16, asset:get_width(), asset:get_height())

   Draw.set_font(14)
   Draw.set_color(30, 20, 10)
   Draw.text_shadowed(self.title, self.x + 40, self.y + 16 + 16)

   Draw.set_color(30, 30, 30)
   local y = self.y + asset:get_height() + 20 + 16
   for _, line in ipairs(self.wrapped) do
      Draw.text(line, self.x + 24, y)
      y = y + Draw.text_height(line)
   end

   self.list:draw()
end

function RandomEventPrompt:update()
   if self.list.chosen then
      local index = self.list.selected
      return index, nil
   end

   if self.canceled then
      Rand.set_seed()
      return nil, "canceled"
   end

   self.win:update()
   self.list:update()
end

return RandomEventPrompt
