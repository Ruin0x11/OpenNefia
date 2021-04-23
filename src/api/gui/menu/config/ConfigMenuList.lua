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
local I18N = require("api.I18N")

local config = require("internal.config")
local data = require("internal.data")

local ConfigMenuList = class.class("ConfigMenuList", {IUiList, IPaged})

ConfigMenuList:delegate("model", IList)
ConfigMenuList:delegate("model", IPaged)
ConfigMenuList:delegate("input", IInput)

local function gen_list(items)
   local map = function(i)

      if type(i) == "string" then
         local proto_id = i

         local proto = data["base.config_option"]:ensure(proto_id)
         assert(not proto.optional, ("Config option '%s' must not be optional"):format(proto_id))

         local mod_id, data_id = proto_id:match("([^.]+)%.([^.]+)")
         local value = config[mod_id][data_id]
         assert(value ~= nil, proto_id)

         local ty = proto.type
         if not string.find(ty, "%.") then
            ty = "base." .. ty
         end
         local widget_require = data["base.config_option_type"]:ensure(ty).widget
         local widget
         if type(widget_require) == "function" then
            widget = widget_require(proto)
         else
            local ctor = require(widget_require)
            widget = ctor:new(proto)
         end
         assert(class.is_an(IConfigItemWidget, widget))

         widget:set_value(value)

         return {
            proto = proto,
            widget = widget,
            text = I18N.get("config.option." .. proto_id .. ".name")
         }
      elseif type(i) == "table" then
         if i._type == "base.config_menu" then
            return {
               menu = i._id,
               text = I18N.get("config.menu." .. i._id .. ".name")
            }
         else
            error(inspect(i))
         end
      else
         error(inspect(i))
      end
   end

   return fun.iter(items):map(map):to_list()
end

function ConfigMenuList:make_keymap()
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

function ConfigMenuList:init(config_menu_items, item_height)
   local list = gen_list(config_menu_items)

   self.item_height = item_height or 19

   self.model = PagedListModel:new(list, 12)

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
end

function ConfigMenuList:change(item, delta)
   if item.menu then
      if delta < 0 then
         self:previous_page()
         Gui.play_sound("base.pop1")
      elseif delta > 0 then
         self:next_page()
         Gui.play_sound("base.pop1")
      end

      return
   end

   local widget = item.widget
   local left, right = widget:can_change()

   if delta < 0 then
      if left then
         Gui.play_sound("base.ok1")
         widget:on_change(delta)
         self:run_on_changed(item)
      end
   elseif delta > 0 then
      if right then
         Gui.play_sound("base.ok1")
         widget:on_change(delta)
         self:run_on_changed(item)
      end
   end
end

function ConfigMenuList:can_choose(item, i)
   if item.menu then
      return true
   end

   return item.widget:can_choose()
end

function ConfigMenuList:choose(i)
   local item = self.model:get_current_page(i)

   if not item or not self:can_choose(item) then
      return
   end

   Gui.play_sound("base.ok1")
   self.model:choose(i)

   if item.menu then
      self.chosen = true
      return
   end

   item.widget:on_choose()
   self:run_on_changed(item)
end

function ConfigMenuList:run_on_changed(item)
   local mod_id, data_id = item.proto._id:match("([^.]+)%.([^.]+)")
   config[mod_id][data_id] = item.widget:get_value()

   self:update_from_config()
end

function ConfigMenuList:refresh_localized_text()
   for _, item in self.model:iter() do
      if item.menu then
         item.text = I18N.get("config.menu." .. item.menu .. ".name")
      else
         item.text = I18N.get("config.option." .. item.proto._id .. ".name")
      end
   end
end

--- Called after something changes in the config, to account for things like
--- "on_changed" mutating more than one config option at once.
function ConfigMenuList:update_from_config()
   for _, item in self.model:iter() do
      if item.widget then
         local mod_id, data_id = item.proto._id:match("([^.]+)%.([^.]+)")
         local value = config[mod_id][data_id]
         assert(value ~= nil, item.proto._id)
         item.widget:set_value(value)
      end
   end
end

function ConfigMenuList:relayout(x, y, width, height)
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

function ConfigMenuList:get_item_color(item)
   if item.menu then
      return self.t.base.text_color
   end

   if item.widget.enabled then
      return self.t.base.text_color
   else
      return self.t.base.text_color_disabled
   end
end

function ConfigMenuList:draw_item(item, i, x, y)
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

function ConfigMenuList:draw()
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

function ConfigMenuList:update(dt)
   UiList.update(self)

   for _, item in self.model:iter() do
      if item.widget then
         item.widget:update(dt)
      end
   end
end

return ConfigMenuList
