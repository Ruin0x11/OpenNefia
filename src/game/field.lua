local internal = require("internal")
local startup = require("game.startup")

local Command = require("api.Command")
local Draw = require("api.Draw")
local Map = require("api.Map")
local InputHandler = require("api.gui.InputHandler")
local GameKeyHandler = require("api.gui.GameKeyHandler")

local field = {}
field.active = false
field.draw_x = 0
field.draw_y = 0

local batches = {}

local hud

local me = {
   batch_ind = 0,
   tile = 3,
   x = 0,
   y = 0
}

local Chara = require("api.Chara")

function field.query()
   local dt = 0
   local going = true
   field.active = true
   hud = require("api.gui.hud.MainHud"):new()
   internal.draw.set_hud(hud)

   batches = startup.load_batches()
   local keys = InputHandler:new()
   keys:focus()
   keys:bind_keys {
      a = function()
         print("do")
      end,
      up = function()
         Command.move(me, "North")
         batches["map"].updated = true
         batches["chara"].updated = true
      end,
      down = function()
         Command.move(me, "South")
         batches["map"].updated = true
         batches["chara"].updated = true
      end,
      left = function()
         Command.move(me, "East")
         batches["map"].updated = true
         batches["chara"].updated = true
      end,
      right = function()
         Command.move(me, "West")
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

      field.draw_x = math.clamp(me.x * 48 - Draw.get_width() / 2 + (48 / 2), 0, Map.width() * 48 - Draw.get_width())
      field.draw_y = math.clamp(me.y * 48 - Draw.get_height() / 2 + (48 / 2), 0, Map.width() * 48 - Draw.get_height() + (72 + 16))

      dt = coroutine.yield()
   end

   field.active = false
end

local px = -1
local py = -1

local function update_chara_batch(chara)
   if chara.x ~= px or chara.y ~= py then
      if chara.batch_ind > 0 then
         batches["chara"]:remove_tile(chara.batch_ind)
      end
      chara.batch_ind = batches["chara"]:add_tile {
         tile = chara.tile,
         x = chara.x,
         y = chara.y
                                                  }

      px = chara.x
      py = chara.y
   end
end

function field.draw()
   update_chara_batch(me)

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
