local Draw = require("api.Draw")
local IUiList = require("api.gui.IUiList")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local ListModel = require("api.gui.ListModel")
local UiTheme = require("api.gui.UiTheme")

local UiBuffList = class.class("UiBuffList", IUiList)

UiBuffList:delegate("model", {
                       "items",
                       "changed",
                       "selected",
                       "selected_item",
                       "select",
                       "select_next",
                       "select_previous",
                       "choose",
                       "can_select",
                       "set_data",
                       "get_item_text",
                       "chosen",
                       "on_choose",
                       "can_choose",
                       "on_select",
                       "iter"
})

UiBuffList:delegate("input", IInput)

function UiBuffList:init()
   self.model = ListModel:new(table.of("buff", 13))
   self.rows = 3
   self.columns = 3
   self.item_width = 32
   self.item_height = 32

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
end

function UiBuffList:make_keymap()
   return {
      north = function() self:select_previous() end,
      south = function() self:select_next() end,
      escape = function() self.canceled = true end,
      cancel = function() self.canceled = true end,
   }
end

function UiBuffList:get_item_color(item)
   return {0, 0, 0}
end

function UiBuffList:relayout(x, y)
   self.x = x
   self.y = y
   self.t = UiTheme.load(self)
end

function UiBuffList:draw_item(item, i, x, y)
   local has_buff = i % 2 == 0
   if has_buff then
      self.t.buff_icon:draw_region(3, x, y, nil, nil, {255, 255, 255, 255})
      if self.selected == i then
         Draw.filled_rect(x, y, 32, 32, {200, 200, 225, 63})
      end
   else
      self.t.buff_icon_none:draw(x, y, nil, nil, {255, 255, 255, 120})
   end
end

function UiBuffList:draw()
   for i=1,15 do
      local x = self.x + math.floor((i-1) / 3) * (self.item_width + 8)
      local y = self.y + (i-1) % 3 * self.item_height
      self:draw_item(self.items[i], i, x, y)
   end
end

function UiBuffList:update()
end

function UiBuffList:get_hint()
   return "hint:"
end

return UiBuffList
