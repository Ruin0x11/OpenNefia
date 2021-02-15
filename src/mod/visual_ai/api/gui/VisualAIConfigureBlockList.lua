local Draw = require("api.Draw")
local IInput = require("api.gui.IInput")
local IPaged = require("api.gui.IPaged")
local IUiList = require("api.gui.IUiList")
local InputHandler = require("api.gui.InputHandler")
local PagedListModel = require("api.gui.PagedListModel")
local UiList = require("api.gui.UiList")
local UiTheme = require("api.gui.UiTheme")
local IList = require("api.gui.IList")
local IConfigItemWidget = require("api.gui.menu.config.item.IConfigItemWidget")
local Gui = require("api.Gui")

local VisualAIConfigureBlockList = class.class("VisualAIConfigureBlockList", {IUiList, IPaged})

VisualAIConfigureBlockList:delegate("model", IList)
VisualAIConfigureBlockList:delegate("model", IPaged)
VisualAIConfigureBlockList:delegate("input", IInput)

local function gen_list(items)
   local map = function(t)
      local ty = t.def.type
      if not string.find(ty, "%.") then
         ty = "base." .. ty
      end
      local widget_require = data["base.config_option_type"]:ensure(ty).widget
      local widget
      if type(widget_require) == "function" then
         widget = widget_require(t.def)
      else
         local ctor = require(widget_require)
         widget = ctor:new(t.def)
      end
      assert(class.is_an(IConfigItemWidget, widget))

      widget:set_value(t.value)

      return {
         proto = t.def,
         widget = widget,
         text = t.name
      }
   end

   return fun.iter(items):map(map):to_list()
end

function VisualAIConfigureBlockList:get_vars()
   local map = function(item)
      return item.text, item.widget:get_value()
   end
   return self.model:iter():map(map):to_map()
end

function VisualAIConfigureBlockList:make_keymap()
   local keys = {
      north = function()
         self:select_previous()
         Gui.play_sound("base.cursor1")
      end,
      south = function()
         self:select_next()
         Gui.play_sound("base.cursor1")
      end,
      enter = function() self:choose(self.model:selected_index()) end,
      west = function() self:change(self.model:selected_item(), -1) end,
      east = function() self:change(self.model:selected_item(), 1) end,
   }

   for i=1,#UiList.KEYS do
      local key = "raw_" .. UiList.KEYS:sub(i, i)
      keys[key] = function()
         self:choose(i)
      end
   end

   return keys
end

function VisualAIConfigureBlockList:init(var_items, item_height)
   local list = gen_list(var_items)

   self.item_height = item_height or 19

   self.model = PagedListModel:new(list, 12)

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
end

function VisualAIConfigureBlockList:change(item, delta)
   local widget = item.widget
   local left, right = widget:can_change()

   if delta < 0 then
      if left then
         Gui.play_sound("base.cursor1")
         widget:on_change(delta)
      end
   elseif delta > 0 then
      if right then
         Gui.play_sound("base.cursor1")
         widget:on_change(delta)
      end
   end
end

function VisualAIConfigureBlockList:can_choose(item, i)
   return item.widget:can_choose()
end

function VisualAIConfigureBlockList:choose(i)
   local item = self.model:get(i)

   if not item or not self:can_choose(item) then
      return
   end

   Gui.play_sound("base.ok1")
   self.model:choose(i)

   item.widget:on_choose()
end

function VisualAIConfigureBlockList:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height

   self.t = UiTheme.load(self)

   for i, item in self.model:iter() do
      if item.widget then
         local ix = self.x + 194
         local iy = (i - 1) * self.item_height + self.y + 1
         item.widget:relayout(ix, iy)
      end
   end
end

function VisualAIConfigureBlockList:get_item_color(item)
   if item.widget.enabled then
      return self.t.base.text_color
   else
      return self.t.base.text_color_disabled
   end
end

function VisualAIConfigureBlockList:draw_item(item, i, x, y)
   local color =  self:get_item_color(item)
   Draw.set_color(color)
   Draw.set_font(14)

   UiList.draw_item_text(self, item.text, item, i, x, y + 1)

   if item.widget then
      item.widget:draw()

      local left, right = item.widget:can_change()

      if left then
         Draw.set_color(255, 255, 255)
      else
         Draw.set_color(255, 255, 255, 100)
      end
      self.t.base.arrow_left:draw(x + 164, y - 5)
      if right then
         Draw.set_color(255, 255, 255)
      else
         Draw.set_color(255, 255, 255, 100)
      end
      self.t.base.arrow_right:draw(x + 302, y - 5)
   end
end

function VisualAIConfigureBlockList:draw()
   for i, item in self.model:iter() do
      local x = self.x
      local y = (i - 1) * self.item_height + self.y
      local key_name = UiList.KEYS:sub(i, i)

      if self:can_choose(item) then
         UiList.draw_select_key(self, item, i, key_name, x - 24, y)
      end

      self:draw_item(item, i, x, y)
   end
end

function VisualAIConfigureBlockList:update(dt)
   UiList.update(self)

   for _, item in self.model:iter() do
      if item.widget then
         item.widget:update(dt)
      end
   end
end

return VisualAIConfigureBlockList
