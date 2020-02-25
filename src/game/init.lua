-- We need to load all data fallbacks here so there are no issues with
-- missing data, since internal code can add its own data inline.
require("internal.data.base")

local Draw = require("api.Draw")
local Event = require("api.Event")
local SaveFs = require("api.SaveFs")

local chara_make = require("game.chara_make")
local mod = require("internal.mod")
local startup = require("game.startup")
local field_logic = require("game.field_logic")
local save_store = require("internal.save_store")
local draw = require("internal.draw")

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
local quickstart = true

local function run_field()
   return field_logic.query()
end

-- This loop should never throw an error, to support resuming using
-- the debug server.
function game.loop()
   -- Run one frame of drawing first, to clear the screen.
   coroutine.yield()

   local mods = mod.scan_mod_dir()

   -- This function will yield to support the progress bar.
   startup.run(mods)

   Event.trigger("base.on_startup")

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
         coroutine.yield(err)
      else
         if action == "start" then
            cb = run_field
         elseif action == "title" then
            cb = main_title
         elseif action == "quit" then
            going = false
         end
      end
   end

   startup.shutdown()
end

local function draw_progress_bar(status_text, ratio)
   Draw.clear(0, 0, 0)
   local text = "Now Loading..."
   local x = Draw.get_width() / 2
   local y = Draw.get_height() / 2
   local progress_width = 400
   local progress_height = 20

   Draw.set_font(18)
   Draw.text(text,
             x - Draw.text_width(text) / 2,
             y - Draw.text_height() / 2 - 20 - 4 - progress_height,
             {255, 255, 255})

   if status_text then
      Draw.set_font(14)
      Draw.text(status_text,
                x - Draw.text_width(status_text) / 2,
                y - Draw.text_height() / 2 - 4 - progress_height,
                {255, 255, 255})
      Draw.line_rect(x - progress_width / 2, y, progress_width, progress_height)
      Draw.filled_rect(x - progress_width / 2, y, progress_width * math.min(ratio, 1), progress_height)
   end
end

function game.draw()
   -- This gets called when game.loop() yields on the first frame.
   draw_progress_bar()

   -- Progress bar.
   local status = ""
   local last_status = ""
   local progress = 0
   local steps = 0
   while true do
      status, progress, steps = startup.get_progress()
      draw_progress_bar(status or last_status, progress / steps)
      if status == nil then break end
      last_status = status
      coroutine.yield()
   end

   local going = true

   while going do
      local ok, ret = xpcall(draw.draw_layers, debug.traceback)

      if not ok then
         going = coroutine.yield(ret)
      else
         going = coroutine.yield()
      end
   end
end

return game
