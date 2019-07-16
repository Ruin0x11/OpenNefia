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

local function load_cm_bg(id)
   return draw.load_image(string.format("graphic/g%d.bmp", id))
end

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
         UiList.draw_item_text(self, x + 40, y + 1, item.text, 0, {0, 0, 0})
      end
   end

   return E
end

function MainTitleMenu:init()
   self.time = 0
   self.window_bg = load_cm_bg(4)
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
      { text = "Restore an Adventurer" },
      { text = "Generate an Adventurer" },
      { text = "Incarnate an Adventurer" },
      { text = "About" },
      { text = "Options" },
      { text = "Mods" },
      { text = "Exit" }
   }
   fun.iter(data):each(function(o) o.subtext = o.text end)

   self.list = UiList:new(data, 35)
   table.merge(self.list, UiListExt())

   self.input = InputHandler:new()
   self.input.keys:forward_to(self.list)
end

function MainTitleMenu:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load()
   self.win:relayout(self.x + 80, (self.height - 308) / 2, 320, 355)
   self.list:relayout(self.win.x + 40, self.win.y + 48)
end

function MainTitleMenu:draw()
   self.t.title:draw(0, 0, Draw.get_width(), Draw.get_height(), {255, 255, 255})

   Draw.set_font(13)

   local version = "1.22"
   Draw.text("Elona version " .. version .. "  Developed by Noa", 20, 20)

   if I18N.language() == "jp" then
      Draw.text("Contributor MSL / View the credits for more", 20, 38)
   else
      Draw.text("Contributor f1r3fly, Sunstrike, Schmidt, Elvenspirit / View the credits for more", 20, 38)
   end

   Draw.text("Elona_next version " .. self.version .. "  Developed by Ruin0x11", 20, 56)

   self.win:draw()
   self.list:draw()

   local w = self.win.width / 5 * 4
   local h = self.win.height - 80
   Draw.image(self.window_bg,
              self.win.x + 160 - (w / 2),
              self.win.y + self.win.height / 2 - (h / 2),
              w,
              h,
              {255, 255, 255, 50})
end

function MainTitleMenu:update(dt)
   self.time = self.time + dt

   if self.list.chosen then
      if self.list.selected ~= 2 then
         Gui.play_sound("base.ok1")
      end
      return self.list.selected
   end

   self.win:update()
   self.list:update()

end

return MainTitleMenu
