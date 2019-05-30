local MainTitleMenu = require("api.gui.menu.MainTitleMenu")
local Draw = require("api.Draw")
local Input = require("api.Input")
local internal = require("internal")

local game = {}
local chara_make = require("game.chara_make")

local function main_title()
   local title = require("api.gui.menu.FeatsMenu"):new()
   internal.input.set_keyrepeat(true)
   Draw.set_root(title)

   local going = true
   while going do
      local choice = Input.query(title)

      if choice == 1 then
         going = chara_make.query()
      else
         error("no choice handler " .. tostring(choice))
      end
   end

   return true
end

function game.loop()
   local action = main_title()
end

function game.draw()
   local going = true

   while going do
      internal.draw.draw_root()

      going = coroutine.yield()
   end
end

return game
