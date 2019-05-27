local Draw = require("api.Draw")
local Input = require("api.Input")
local I18N = require("api.I18N")
local UiWindow = require("api.gui.UiWindow")

local game = {}

local title = {}
local title_image
local win = nil

function title.init()
   title_image = Draw.load_image("graphic/title.bmp")

   win = UiWindow:new(80, 308, 320, 320, true)
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

   for i=1,100 do
      win:update()
      win:draw()
   end
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
