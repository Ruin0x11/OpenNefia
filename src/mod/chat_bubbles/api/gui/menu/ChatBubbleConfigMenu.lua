local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local UiTheme = require("api.gui.UiTheme")
local Ui = require("api.Ui")
local Draw = require("api.Draw")
local UiWindow = require("api.gui.UiWindow")
local ChatBubbleConfigMenuList = require("mod.chat_bubbles.api.gui.menu.ChatBubbleConfigMenuList")
local Gui = require("api.Gui")
local Input = require("api.Input")
local ICharaChatBubble = require("mod.chat_bubbles.api.aspect.ICharaChatBubble")
local I18N = require("api.I18N")

local ChatBubbleConfigMenu = class.class("ChatBubbleConfigMenu", IUiLayer)

ChatBubbleConfigMenu:delegate("input", IInput)

function ChatBubbleConfigMenu:init(chara, default)
   self.chara = chara
   self.default = default
   if self.chara == nil then
      self.default = true
   end

   self.list = ChatBubbleConfigMenuList:new(self.chara, self.default)

   local title
   if self.default then
      title = "chat_bubbles:ui.menu.config.title.default"
   else
      title = "chat_bubbles:ui.menu.config.title.individual"
   end

   local key_hints = self:make_key_hints()
   self.win = UiWindow:new(title, true, key_hints)

   self.input = InputHandler:new()
   self.input:forward_to(self.list)
   self.input:bind_keys(self:make_keymap())
end

function ChatBubbleConfigMenu:make_keymap()
   return {
      escape = function() self.canceled = true end,
      cancel = function() self.canceled = true end,
      mode2 = function() self:initialize_settings() end,
      message_log = function() if self.chara then self:switch_mode(not self.default) end end,
   }
end

function ChatBubbleConfigMenu:make_key_hints()
   local hints = {
      {
         action = "ui.key_hint.action.change",
         key_name = "ui.key_hint.key.left_right"
      },
      {
         action = "ui.key_hint.action.close",
         key_name = "ui.key_hint.key.cancel",
         keys = { "cancel", "escape" }
      },
      {
         action = "chat_bubbles:ui.menu.config.hint.action.reset",
         keys = "mode2"
      }
   }

   local switch_action
   if self.default then
      switch_action = "chat_bubbles:ui.menu.config.hint.action.individual_settings"
   else
      switch_action = "chat_bubbles:ui.menu.config.hint.action.default_settings"
   end

   hints[#hints+1] = {
      action = switch_action,
      keys = "message_log"
   }

   return hints
end

function ChatBubbleConfigMenu:on_query()
   Gui.play_sound("base.pop2")
end

function ChatBubbleConfigMenu:switch_mode(default)
   Gui.play_sound("base.ok1")

   self.default = default
   if self.chara == nil then
      self.default = true
   end

   local title
   if self.default then
      title = "chat_bubbles:ui.menu.config.title.default"
   else
      title = "chat_bubbles:ui.menu.config.title.individual"
   end

   self.win:set_title(title)
   self.win:set_key_hints(self:make_key_hints())
   self.list:switch_mode(default)
end

function ChatBubbleConfigMenu:initialize_settings()
   -- >>>>>>>> oomSEST/src/southtyris.hsp:96008 		snd 20 ...
   Gui.play_sound("base.ok1")

   if not Input.yes_no(true) then
      return
   end

   self.list:initialize_settings()
   -- <<<<<<<< oomSEST/src/southtyris.hsp:96034 		goto *label_2059 ..
end

function ChatBubbleConfigMenu:relayout()
   self.tile_width, self.tile_height = Draw.get_coords():get_size()
   self.width = 440 + self.tile_width * 3
   self.height = 400

   self.x, self.y = Ui.params_centered(self.width, self.height)

   self.t = UiTheme.load(self)

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.list:relayout(self.x + 56, self.y + 66)
end

function ChatBubbleConfigMenu:draw()
   -- >>>>>>>> elona122/shade2/help.hsp:936 	redraw 0 ...
   self.win:draw()

   Ui.draw_topic("config.common.menu", self.x + 34, self.y + 36)

   if not self.default then
      Draw.set_font(14)
      local text
      if self.chara:get_aspect(ICharaChatBubble) then
         Draw.set_color(55, 55, 255)
         text = I18N.get("config.common.yes_no.on_off.yes")
      else
         Draw.set_color(0, 0, 0)
         text = I18N.get("config.common.yes_no.on_off.no")
      end
      Draw.text(I18N.get("chat_bubbles:ui.menu.config.individual_setting", text), self.x + 410, self.y + self.height - 170)
   end

   self.list:draw()
   -- <<<<<<<< elona122/shade2/help.hsp:979 	cs_list s,wX+56+x ,wY+66+cnt*19-1,19,0 ..
end

function ChatBubbleConfigMenu:update(dt)
   local canceled = self.canceled

   self.canceled = false
   self.win:update(dt)
   self.list:update(dt)

   if canceled then
      return nil, "canceled"
   end
end

return ChatBubbleConfigMenu
