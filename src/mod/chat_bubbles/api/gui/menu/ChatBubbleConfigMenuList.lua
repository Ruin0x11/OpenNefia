local Draw = require("api.Draw")
local IInput = require("api.gui.IInput")
local IPaged = require("api.gui.IPaged")
local IUiList = require("api.gui.IUiList")
local InputHandler = require("api.gui.InputHandler")
local PagedListModel = require("api.gui.PagedListModel")
local UiList = require("api.gui.UiList")
local UiTheme = require("api.gui.UiTheme")
local IList = require("api.gui.IList")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local IConfigItemWidget = require("api.gui.menu.config.item.IConfigItemWidget")
local ChatBubbleConfigMenuPreview = require("mod.chat_bubbles.api.gui.menu.ChatBubbleConfigMenuPreview")
local ChatBubble = require("mod.chat_bubbles.api.ChatBubble")
local ICharaChatBubble = require("mod.chat_bubbles.api.aspect.ICharaChatBubble")

local ChatBubbleConfigMenuList = class.class("ChatBubbleConfigMenuList", {IUiList, IPaged})

ChatBubbleConfigMenuList:delegate("model", IList)
ChatBubbleConfigMenuList:delegate("model", IPaged)
ChatBubbleConfigMenuList:delegate("input", IInput)

local function make_config_widget(id, ty, text, def, default, value)
   if type(def) == "string" then
      def = data["base.config_option"]:ensure(def)
      ty = def.type
   end
   if not string.find(ty, "%.") then
      ty = "base." .. ty
   end
   local widget_require = data["base.config_option_type"]:ensure(ty).widget
   local widget
   if type(widget_require) == "function" then
      widget = widget_require(def)
   else
      local ctor = require(widget_require)
      widget = ctor:new(def)
   end
   assert(class.is_an(IConfigItemWidget, widget))

   if def._id then
      local mod_id, data_id = def._id:match("([^.]+)%.([^.]+)")
      widget:set_value(config[mod_id][data_id])
      default = def.default
   elseif value or default then
      widget:set_value(value or default)
   end

   return {
      id = id,
      proto = def,
      widget = widget,
      text = text,
      default = default
   }
end

local function gen_list(default, chara)
   local list
   if default then
      list = {
         {
            id = "text_color",
            text = I18N.get("chat_bubbles:ui.menu.config.options.text_color.title"),
            def = "chat_bubbles.default_text_color"
         },
         {
            id = "bg_color",
            text = I18N.get("chat_bubbles:ui.menu.config.options.bg_color.title"),
            def = "chat_bubbles.default_bubble_color"
         },
         {
            id = "font",
            text = I18N.get("chat_bubbles:ui.menu.config.options.font.title"),
            def = "chat_bubbles.default_font"
         },
         {
            id = "font_size",
            text = I18N.get("chat_bubbles:ui.menu.config.options.font_size.title"),
            def = "chat_bubbles.default_font_size"
         },
         {
            id = "font_style",
            text = I18N.get("chat_bubbles:ui.menu.config.options.font_style.title"),
            def = "chat_bubbles.default_font_style"
         },
      }

      return fun.iter(list):map(function(t) return make_config_widget(t.id, t.type, t.text, t.def, t.default) end):to_list()
   else
      list = {
         {
            -- >>>>>>>> oomSEST/src/southtyris.hsp:95825 			if (cs == 0) { ...
            id = "talk_type",
            text = I18N.get("chat_bubbles:ui.menu.config.options.talk_type.title"),
            type = "integer",
            default = 0,
            def = {
               min_value = 0,
               max_value = 6
            }
            -- <<<<<<<< oomSEST/src/southtyris.hsp:95836 			} ..
         },
         {
            -- >>>>>>>> oomSEST/src/southtyris.hsp:95843 			if (cs == 1) { ...
            id = "show_when_disabled",
            text = I18N.get("chat_bubbles:ui.menu.config.options.show_when_disabled.title"),
            type = "enum",
            default = "never",
            def = {
               choices = { "never", "once", "unlimited" },
               formatter = function(_id, value, index)
                  return I18N.get("chat_bubbles:ui.menu.config.options.show_when_disabled.choices." .. value)
               end
            },
            -- <<<<<<<< oomSEST/src/southtyris.hsp:95853 			} ..
         },
         {
            -- >>>>>>>> oomSEST/src/southtyris.hsp:95854 			if (cs == 2) { ...
            id = "x_offset",
            text = I18N.get("chat_bubbles:ui.menu.config.options.x_offset.title"),
            type = "integer",
            default = 0,
            def = {
               min_value = -24,
               max_value = 24
            }
            -- <<<<<<<< oomSEST/src/southtyris.hsp:95864 			} ..
         },
         {
            -- >>>>>>>> oomSEST/src/southtyris.hsp:95854 			if (cs == 2) { ...
            id = "y_offset",
            text = I18N.get("chat_bubbles:ui.menu.config.options.y_offset.title"),
            type = "integer",
            default = 0,
            def = {
               min_value = -48,
               max_value = 48
            }
            -- <<<<<<<< oomSEST/src/southtyris.hsp:95864 			} ..
         },
         {
            id = "text_color",
            text = I18N.get("chat_bubbles:ui.menu.config.options.text_color.title"),
            type = "extra_config_options.color",
            default = {0, 0, 0},
            def = {}
         },
         {
            id = "bg_color",
            text = I18N.get("chat_bubbles:ui.menu.config.options.bg_color.title"),
            type = "extra_config_options.color",
            default = {255, 255, 255},
            def = {}
         },
         {
            id = "font",
            text = I18N.get("chat_bubbles:ui.menu.config.options.font.title"),
            type = "enum",
            default = "(font)",
            def = {
               choices = { "(font)" }
            }
         },
         {
            id = "font_size",
            text = I18N.get("chat_bubbles:ui.menu.config.options.font_size.title"),
            type = "integer",
            default = 11,
            def = {
               min_value = 8,
               max_value = 30
            }
         },
         {
            id = "font_style",
            text = I18N.get("chat_bubbles:ui.menu.config.options.font_style.title"),
            type = "enum",
            default = "normal",
            def = {
               choices = { "normal", "bold", "italic", "underline", "strikethrough" },
               formatter = function(_id, value, index)
                  return tostring(index) .. ":" .. I18N.get("chat_bubbles:ui.menu.config.options.font_style.choices." .. value)
               end
            },
         },
      }

      assert(chara)
      local bubble_color, text_color, font, font_size, font_style, x_offset, y_offset, show_when_disabled = ChatBubble.get_bubble_params(chara)
      local settings = {
         talk_type = chara.talk_type or 0,
         show_when_disabled = show_when_disabled,
         x_offset = x_offset,
         y_offset = y_offset,
         bg_color = bubble_color,
         text_color = text_color,
         font = font,
         font_size = font_size,
         font_style = font_style,
      }

      return fun.iter(list):map(function(t)
            local value = settings[t.id]
            return make_config_widget(t.id, t.type, t.text, t.def, t.default, value)
                               end):to_list()
   end
end

function ChatBubbleConfigMenuList:init(chara, default)
   self.chara = chara
   self.default = default
   if chara == nil then
      self.default = true
   end
   local list = gen_list(self.default, self.chara)

   self.model = PagedListModel:new(list, 18)
   self.preview = ChatBubbleConfigMenuPreview:new(self.chara:calc("image"))

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())

   self:update_preview()
end

function ChatBubbleConfigMenuList:initialize_settings()
   for _, item in self.model:iter() do
      if item.widget and item.default then
         item.widget:set_value(item.default)
      end
   end

   self.chara:set_aspect(ICharaChatBubble, nil)
   self:update_preview()
end

function ChatBubbleConfigMenuList:switch_mode(default)
   self.default = default
   if self.chara == nil then
      self.default = true
   end
   local list = gen_list(self.default, self.chara)

   self.model:set_data(list)
   self:update_preview()
   self:relayout(self.x, self.y, self.width, self.height)
end

function ChatBubbleConfigMenuList:make_keymap()
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

function ChatBubbleConfigMenuList:get_data()
   local result = {}
   for i, item in self.model:iter() do
      if item.widget then
         result[item.id] = item.widget:get_value()
      end
   end
   return result
end

function ChatBubbleConfigMenuList:update_preview()
   local t = self:get_data()
   self.preview:set_data(t.text_color, t.bg_color, t.font, t.font_size, t.font_style, t.x_offset, t.y_offset)
end

function ChatBubbleConfigMenuList:change(item, delta)
   local widget = item.widget
   local left, right = widget:can_change()

   if delta < 0 then
      if left then
         Gui.play_sound("base.ok1")
         widget:on_change(delta)
      end
   elseif delta > 0 then
      if right then
         Gui.play_sound("base.ok1")
         widget:on_change(delta)
      end
   end

   self:run_on_changed(item)
end

function ChatBubbleConfigMenuList:run_on_changed(item)
   local has_config_option = item.proto._id ~= nil
   if has_config_option then
      local mod_id, data_id = item.proto._id:match("([^.]+)%.([^.]+)")
      config[mod_id][data_id] = item.widget:get_value()
   else
      local data = self:get_data()

      self.chara.talk_type = data.talk_type

      if item.id ~= "talk_type" then
         local aspect = self.chara:get_aspect_or_default(ICharaChatBubble, true)
         aspect.show_when_disabled = data.show_when_disabled
         aspect.x_offset = data.x_offset
         aspect.y_offset = data.y_offset
         aspect.text_color = data.text_color
         aspect.bg_color = data.bg_color
         aspect.font = data.font
         aspect.font_size = data.font_size
         aspect.font_style = data.font_style
      end
   end

   self:update_preview()
end

function ChatBubbleConfigMenuList:can_choose(item, i)
   if item.menu then
      return true
   end

   return item.widget:can_choose()
end

function ChatBubbleConfigMenuList:choose(i)
   local item = self.model:get(i)

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

function ChatBubbleConfigMenuList:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height

   self.t = UiTheme.load(self)

   for i, item in self.model:iter() do
      if item.widget then
         local ix = self.x + 204
         local iy = (i - 1) * 19 + self.y + 1
         item.widget:relayout(ix, iy)
      end
   end

   local tw, th = Draw.get_coords():get_size()

   self.preview:relayout(self.x + 400 - 56, self.y - 1, tw * 3 + 10, th * 3 + 10)
end

function ChatBubbleConfigMenuList:draw_item(item, i, x, y)
   Draw.set_color(0, 0, 0)
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
      self.t.base.arrow_left:draw(x + 230 - 56, y - 5)
      if right then
         Draw.set_color(255, 255, 255)
      else
         Draw.set_color(255, 255, 255, 100)
      end
      self.t.base.arrow_right:draw(x + 370 - 56, y - 5)
   end
end

function ChatBubbleConfigMenuList:draw()
   for i, item in self.model:iter() do
      local x = self.x
      local y = (i - 1) * 19 + self.y
      local key_name = UiList.KEYS:sub(i, i)

      if self:can_choose(item) then
         UiList.draw_select_key(self, item, i, key_name, x - 24, y)
      end

      self:draw_item(item, i, x, y)
   end

   self.preview:draw()
end

function ChatBubbleConfigMenuList:update(dt)
   UiList.update(self)

   for _, item in self.model:iter() do
      if item.widget then
         item.widget:update(dt)
      end
   end
end

return ChatBubbleConfigMenuList
