local MainTitleMenu = require("api.gui.menu.MainTitleMenu")
local Draw = require("api.Draw")
local internal = require("internal")

local game = {}

function game.loop()
   local going = true
   local title = MainTitleMenu:new()
   internal.input.set_keyrepeat(true)
   Draw.set_root(title)

   while going do
      if title.list.chosen then
         print(title.list.selected)
      end

      internal.draw.update_root()
      internal.draw.draw_root()

      coroutine.yield()
   end
end

return game
