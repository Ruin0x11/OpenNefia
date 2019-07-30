-- We need to load all data fallbacks here so there are no issues with
-- missing data, since internal code can add its own data inline.
require("internal.data.base")

local Log = require("api.Log")
local SaveFs = require("api.SaveFs")
local internal = require("internal")

local chara_make = require("game.chara_make")
local mod = require("internal.mod")
local startup = require("game.startup")
local field_logic = require("game.field_logic")
local save_store = require("internal.save_store")

-- TODO: this module isn't hotloadable since game.loop gets run in a
-- coroutine. Would be better to just put game.loop() into a
-- standalone function.
local game = {}
game.in_game = false

local function main_title()
   game.in_game = false

   local title = require("api.gui.menu.MainTitleMenu"):new()

   local action
   local going = true
   while going do
      -- Clear the global save.
      SaveFs.clear()
      save_store.clear()

      local choice = title:query()

      if choice == 1 then
         field_logic.quickstart()
         going = false
         action = "start"
      elseif choice == 2 then
         local chara, canceled = chara_make.query()
         if not canceled then
            going = false

            if chara then
               field_logic.setup_new_game(chara)
               action = "start"
            end
         end
      elseif choice == 7 then
         going = false
         action = "quit"
      end
   end

   return action
end

-- TODO: make into scenario/config option
local quickstart = false

local function run_field()
   return field_logic.query()
end

function game.loop()
   local mods = mod.scan_mod_dir()
   startup.run(mods)

   local cb
   if quickstart then
      field_logic.quickstart()
      cb = run_field
   else
      cb = main_title
   end

   local going = true
   while going do
      local success, action = xpcall(cb, debug.traceback)
      if not success then
         local err = action
         if action == "title" then
            error(err)
            going = false
         else
            Log.error("Error in loop:\n\t%s", err)
            action = "title"
         end
      end

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
      local ok, ret = xpcall(internal.draw.draw_layers, debug.traceback)

      if not ok then
         going = coroutine.yield(ret)
      else
         going = coroutine.yield()
      end
   end
end

return game
