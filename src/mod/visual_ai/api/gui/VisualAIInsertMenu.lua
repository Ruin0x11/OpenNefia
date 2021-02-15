local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local UiTheme = require("api.gui.UiTheme")
local VisualAIBlockList = require("mod.visual_ai.api.gui.VisualAIBlockList")
local Ui = require("api.Ui")
local UiWindow = require("api.gui.UiWindow")
local TopicWindow = require("api.gui.TopicWindow")
local Draw = require("api.Draw")
local I18N = require("api.I18N")

local VisualAIInsertMenu = class.class("VisualAIInsertMenu", IUiLayer)

VisualAIInsertMenu:delegate("input", IInput)

function VisualAIInsertMenu:init(category_idx, item_id)
   self.win = UiWindow:new("Insert Block", true)
   self.list = VisualAIBlockList:new()
   self.category_win = TopicWindow:new(1, 1)
   self.category_text = ""

   self.input = InputHandler:new()
   self.input:forward_to(self.list)
   self.input:bind_keys(self:make_keymap())

   self.list:set_category(category_idx or 1)
   if item_id then
      self.list:select_block(item_id)
   end
end

function VisualAIInsertMenu:make_keymap()
   return {
      escape = function() self.canceled = true end,
      cancel = function() self.canceled = true end
   }
end

function VisualAIInsertMenu:on_query()
   self.canceled = false
end

function VisualAIInsertMenu:relayout(x, y, width, height)
   self.width = 400
   self.height = 520
   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.y = self.y + 20
   self.t = UiTheme.load(self)

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.list:relayout(self.x + 10, self.y + 10 + 50, self.width - 20, self.height - 20 - 40)
   self.category_win:relayout(self.x + 10 + 50, self.y + 32, self.width - 20 - 100, 40)
end

function VisualAIInsertMenu:draw()
   self.win:draw()
   self.list:draw()
   self.category_win:draw()

   Draw.set_font(15)
   Draw.set_color(0, 0, 0)
   Draw.text_shadowed(self.category_text,
                      self.category_win.x + self.category_win.width / 2 - Draw.text_width(self.category_text) / 2,
                      self.category_win.y + self.category_win.height / 2 - Draw.text_height() / 2)
end

function VisualAIInsertMenu:update(dt)
   if self.list.changed then
      self.category_text = I18N.get("visual_ai.gui.menu.category", "visual_ai.gui.category." .. self.list.category)
   end

   self.win:update(dt)
   local chosen = self.list:update(dt)
   self.category_win:update(dt)

   if chosen then
      return chosen, nil
   end
   if self.canceled then
      return nil, "canceled"
   end
end

return VisualAIInsertMenu
