local Draw = require("api.Draw")
local I18N = require("api.I18N")
local UiWindow = require("api.gui.UiWindow")
local UiList = require("api.gui.UiList")

local MainTitleMenu = {}
local MainTitleMenu_mt = { __index = MainTitleMenu }

local function load_cm_bg(id)
   return Draw.load_image(string.format("graphic/g%d.bmp", id))
end

function MainTitleMenu:new()
   local m = {
      bg = Draw.load_image("graphic/title.bmp"),
      window_bg = load_cm_bg(4),
   }

   local title_str, key_help
   if I18N.language() == "jp" then
      title_str = "冒険の道標"
   else
      title_str = "Starting Menu"
   end
   key_help = I18N.get("ui.hint.cursor")

   m.win = UiWindow:new(80, (Draw.get_height() - 308) / 2, 320, 355, true, title_str, key_help)
   m.list = UiList:new(m.win.x + 40,
                       m.win.y + 50,
                       {
                          "Restore an Adventurer",
                          "Generate an Adventurer",
                          "Incarnate an Adventurer",
                          "About",
                          "Options",
                          "Mods",
                          "Exit"
                       })

   setmetatable(m, MainTitleMenu_mt)
   return m
end

function MainTitleMenu:relayout()
end

function MainTitleMenu:focus()
   self.list:focus()
end

function MainTitleMenu:draw()
   Draw.image(self.bg, 0, 0, Draw.get_width(), Draw.get_height())

   local version = "1.22"
   Draw.text("Elona version " .. version .. "  Developed by Noa", 20, 20)

   if I18N.language() == "jp" then
      Draw.text("Contributor MSL / View the credits for more", 20, 38)
   else
      Draw.text("Contributor f1r3fly, Sunstrike, Schmidt, Elvenspirit / View the credits for more", 20, 38)
   end

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

function MainTitleMenu:update()
   self.win:update()
   self.list:update()
end

return MainTitleMenu
