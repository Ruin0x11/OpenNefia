local MainTitleMenu = require("api.gui.menu.MainTitleMenu")
local Draw = require("api.Draw")
local Input = require("api.Input")
local internal = require("internal")

local chara_make = require("game.chara_make")
local startup = require("game.startup")
local field = require("game.field")

local game = {}
game.in_game = false

local function main_title()
   game.in_game = false
   internal.mod.load_mods()

   local title = require("api.gui.menu.MainTitleMenu"):new()

   local action
   local going = true
   while going do
      local choice = title:query()

      if choice == 1 then
         going = false
         action = "start"
      elseif choice == 2 then
         local _, canceled = chara_make.query()
         if not canceled then
            going = false
         end
      elseif choice == 7 then
         going = false
         action = "quit"
      end
   end

   return action
end

function game.loop()
   startup.run()

   local cb = main_title

   local going = true
   while going do
      local action = cb()

      if action == "start" then
         cb = field.query
      elseif action == "title" then
         cb = main_title
      elseif action == "quit" then
         going = false
      end
   end
end

function game.draw()
   local going = true

   while going do
      if field.active then
         field.draw()
      end

      internal.draw.draw_layers()

      going = coroutine.yield()
   end
end

return game
