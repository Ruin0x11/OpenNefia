local Draw = require("api.Draw")
local Input = require("api.Input")
local I18N = require("api.I18N")

local game = {}

local title = {}
local title_image

function title.init()
   title_image = Draw.load_image("graphic/title.bmp")
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
