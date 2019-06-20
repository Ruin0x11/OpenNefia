local MainTitleMenu = require("api.gui.menu.MainTitleMenu")
local Draw = require("api.Draw")
local Input = require("api.Input")
local internal = require("internal")

local chara_make = require("game.chara_make")
local startup = require("game.startup")
local field_logic = require("game.field_logic")

local game = {}
game.in_game = false

local function main_title()
   game.in_game = false

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

local function run_field()
   return field_logic.query()
end

function game.loop()
   startup.run()

   local cb = run_field

   local going = true
   while going do
      local action = cb()

      if action == "start" then
         cb = run_field
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
      internal.draw.draw_layers()

      going = coroutine.yield()
   end
end

return game
