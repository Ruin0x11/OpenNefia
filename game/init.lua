local Draw = require("api.Draw")
local Input = require("api.Input")
local I18N = require("api.I18N")
local UiWindow = require("api.gui.UiWindow")
local UiList = require("api.gui.UiList")

local game = {}

local title = {}
local title_image, title_bg, title_list
local win = nil

local function load_cm_bg(id)
   return Draw.load_image(string.format("graphic/g%d.bmp", id))
end

function title.init()
   title_image = Draw.load_image("graphic/title.bmp")
   title_bg = load_cm_bg(4)

   local title_str, key_help
   if I18N.language() == "jp" then
      title_str = "冒険の道標"
   else
      title_str = "Starting Menu"
   end
   key_help = I18N.get("ui.hint.cursor")

   win = UiWindow:new(80, (Draw.get_height() - 308) / 2, 320, 355, true, title_str, key_help)
   title_list = UiList:new(win.x + 40,
                           win.y + 50,
                           {
                             "Restore an Adventurer",
                             "Generate an Adventurer",
                             "Incarnate an Adventurer",
                             "About",
                             "Options",
                             "Mods",
                             "Exit"
                           }
   )
end

function title.draw()
   Draw.image(title_image, 0, 0, Draw.get_width(), Draw.get_height())

   local version = "1.22"
   Draw.text("Elona version " .. version .. "  Developed by Noa", 20, 20)

   if I18N.language() == "jp" then
      Draw.text("Contributor MSL / View the credits for more", 20, 38)
   else
      Draw.text("Contributor f1r3fly, Sunstrike, Schmidt, Elvenspirit / View the credits for more", 20, 38)
   end

   win:update()
   win:draw()
   title_list:update()
   title_list:draw()

   local w = win.width / 5 * 4
   local h = win.height - 80
   Draw.image(title_bg,
              win.x + 160 - (w / 2),
              win.y + win.height / 2 - (h / 2),
              w,
              h,
              {255, 255, 255, 50})

   Draw.set_color(255, 255, 255)
end


local title_win = {}

function title_win.draw()
end


function game.loop()
   local going = true
   title.init()

   while going do
      title.draw()

      coroutine.yield()
   end
end

return game
