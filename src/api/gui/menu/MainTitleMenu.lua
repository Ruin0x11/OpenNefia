local Draw = require("api.Draw")
local Env = require("api.Env")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local UiList = require("api.gui.UiList")
local UiWindow = require("api.gui.UiWindow")
local UiTheme = require("api.gui.UiTheme")

local IUiLayer = require("api.gui.IUiLayer")

local MainTitleMenu = class.class("MainTitleMenu", IUiLayer)

local draw = require("internal.draw")

MainTitleMenu:delegate("input", IInput)

local UiListExt = function()
   local E = {}

   function E:draw_item(item, i, x, y, key_name)
      UiList.draw_select_key(self, item, i, key_name, x, y)

      Draw.set_color(0, 0, 0)

      if I18N.is_fullwidth() then
         Draw.set_font(11)
         Draw.text(item.subtext, x + 40, y - 4)
         Draw.set_font(13)
         UiList.draw_item_text(self, item.text, item, i, x + 40, y + 8, 0, {0, 0, 0})
      else
         Draw.set_font(14)
         UiList.draw_item_text(self, item.text, item, i, x + 40, y + 1, 0, {0, 0, 0})
      end
   end

   return E
end

function MainTitleMenu:init()
   self.time = 0
   self.version = Env.version()

   local title_str, key_help
   if I18N.language() == "jp" then
      title_str = "冒険の道標"
   else
      title_str = "Starting Menu"
   end
   key_help = I18N.get("ui.hint.cursor")

   self.win = UiWindow:new(title_str, true, key_help)

   local data = {
      { action = "restore",   text = "main_menu.title_menu.restore", subtext = "Restore an Adventurer" },
      { action = "generate",  text = "main_menu.title_menu.generate", subtext = "Generate an Adventurer" },
      { action = "incarnate", text = "main_menu.title_menu.incarnate", subtext = "Incarnate an Adventurer" },
      { action = "about",     text = "main_menu.title_menu.about", subtext = "About" },
      { action = "options",   text = "main_menu.title_menu.options", subtext = "Options" },
      { action = "mods",      text = "main_menu.title_menu.mods", subtext = "Mods" },
      { action = "exit",      text = "main_menu.title_menu.exit", subtext = "Exit" }
   }
   for _, entry in ipairs(data) do
       if I18N.language() == "en" then
         entry.text = entry.subtext
         entry.subtext = ""
       else
         entry.text = I18N.get(entry.text)
       end
   end

   self.list = UiList:new(data, 35)
   table.merge(self.list, UiListExt())

   self.input = InputHandler:new()
   self.input.keys:forward_to(self.list)
   self.input:bind_keys(self:make_keymap())

   self.action = nil
end

function MainTitleMenu:make_keymap()
   return {
      raw_f3 = function() self.action = "quickstart" end
  }
end

function MainTitleMenu:on_query()
   Gui.play_music("elona.opening")
end

function MainTitleMenu:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load(self)
   self.win:relayout(self.x + 80, (self.height - 308) / 2, 320, 355)
   self.list:relayout(self.win.x + 40, self.win.y + 48)
end

function MainTitleMenu:draw()
   Draw.set_color(255, 255, 255)
   self.t.base.title:draw(0, 0, Draw.get_width(), Draw.get_height())

   Draw.set_font(13)

   local version = "1.22"
   Draw.text("Elona version " .. version .. "  Developed by Noa", 20, 20)

   if I18N.language() == "jp" then
      Draw.text("Contributor MSL / View the credits for more", 20, 38)
   else
      Draw.text("Contributor f1r3fly, Sunstrike, Schmidt, Elvenspirit / View the credits for more", 20, 38)
   end

   Draw.text("OpenNefia version " .. self.version .. "  Developed by Ruin0x11", 20, 56)

   Draw.text("F3: Quickstart", 20, Draw.get_height() - 20 - Draw.text_height())

   self.win:draw()
   self.list:draw()

   local w = self.win.width / 5 * 4
   local h = self.win.height - 80
   self.t.base.g4:draw(
              self.win.x + 160 - (w / 2),
              self.win.y + self.win.height / 2 - (h / 2),
              w,
              h,
              {255, 255, 255, 50})
end

function MainTitleMenu:update(dt)
   self.time = self.time + dt

   local action
   if self.list.chosen then
      action = self.list:selected_item().action
   elseif self.action then
      action = self.action
   end
   if action then
      if action ~= "generate" then
         Gui.play_sound("base.ok1")
      end
      return action
   end

   self.win:update()
   self.list:update()
end

return MainTitleMenu
