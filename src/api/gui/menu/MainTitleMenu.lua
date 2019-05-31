local Draw = require("api.Draw")
local I18N = require("api.I18N")
local UiWindow = require("api.gui.UiWindow")
local UiList = require("api.gui.UiList")
local IKeyInput = require("api.gui.IKeyInput")
local IMouseInput = require("api.gui.IMouseInput")
local InputHandler = require("api.gui.InputHandler")

local IUiLayer = require("api.gui.IUiLayer")

local MainTitleMenu = class("MainTitleMenu", IUiLayer)

MainTitleMenu:delegate("input", {IKeyInput, IMouseInput})

local function load_cm_bg(id)
   return Draw.load_image(string.format("graphic/g%d.bmp", id))
end

function MainTitleMenu:init()
   self.t = 0
   self.bg = Draw.load_image("graphic/title.bmp")
   self.shader = Draw.load_shader("graphic/shader/ripple2.frag.glsl")
   self.window_bg = load_cm_bg(4)

   local title_str, key_help
   if I18N.language() == "jp" then
      title_str = "冒険の道標"
   else
      title_str = "Starting Menu"
   end
   key_help = I18N.get("ui.hint.cursor")

   self.win = UiWindow:new(title_str, 80, (Draw.get_height() - 308) / 2, 320, 355, true, key_help)

   self.list = UiList:new(self.win.x + 40,
                          self.win.y + 50,
                          {
                             "Restore an Adventurer",
                             "Generate an Adventurer",
                             "Incarnate an Adventurer",
                             "About",
                             "Options",
                             "Mods",
                             "Exit"
   })

   self.input = InputHandler:new()
   self.input.keys:forward_to(self.list)
end

MainTitleMenu.query = require("api.Input").query

function MainTitleMenu:relayout()
   self.win:relayout()
   self.list:relayout()
end

function MainTitleMenu:draw()
   Draw.use_shader(self.shader)
   self.shader:send("time", self.t)
   Draw.image(self.bg, 0, 0, Draw.get_width(), Draw.get_height())
   Draw.use_shader()

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

function MainTitleMenu:update(dt)
   self.t = self.t + dt

   if self.list.chosen then
      return self.list.selected
   end

   self.win:update()
   self.list:update()

end

return MainTitleMenu
