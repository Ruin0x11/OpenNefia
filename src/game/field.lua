local internal = require("internal")
local startup = require("game.startup")

local Draw = require("api.Draw")
local InputHandler = require("api.gui.InputHandler")
local KeyHandler = require("api.gui.KeyHandler")

local field = {}
field.active = false
field.draw_x = 0
field.draw_y = 0

local batches = {}

local hud

function field.query()
   local dt = 0
   local going = true
   field.active = true
   hud = require("api.gui.hud.MainHud"):new()
   internal.draw.set_hud(hud)

   batches = startup.load_batches()
   local keys = InputHandler:new(KeyHandler:new())
   keys:focus()
   keys:bind_keys {
      up = function()
         field.draw_y = field.draw_y - 500 * dt
         batches["map"].updated = true
         batches["chara"].updated = true
      end,
      down = function()
         field.draw_y = field.draw_y + 500 * dt
         batches["map"].updated = true
         batches["chara"].updated = true
      end,
      left = function()
         field.draw_x = field.draw_x - 500 * dt
         batches["map"].updated = true
         batches["chara"].updated = true
      end,
      right = function()
         field.draw_x = field.draw_x + 500 * dt
         batches["map"].updated = true
         batches["chara"].updated = true
      end,
      ["return"] = function()
         print(require("api.gui.TextPrompt"):new(16):query())
      end,
   }

   internal.draw.set_root_input_handler(keys)

   while going do
      keys:run_actions()

      dt = coroutine.yield()
   end

   field.active = false
end

function field.draw()
   local draw_x = field.draw_x
   local draw_y = field.draw_y

   batches["map"]:draw(draw_x, draw_y)
   -- blood, fragments
   -- efmap
   -- nefia icons
   -- mefs
   -- items
   batches["chara"]:draw(draw_x, draw_y)
   -- light
   -- cloud
   -- shadow

   internal.draw.draw_hud()
end

return field
