local internal = require("internal")
local startup = require("game.startup")

local Chara = require("api.Chara")
local Command = require("api.Command")
local Draw = require("api.Draw")
local Map = require("api.Map")
local Input = require("api.Input")
local InputHandler = require("api.gui.InputHandler")
local GameKeyHandler = require("api.gui.GameKeyHandler")

local map = require("internal.map")
local field_renderer = require("internal.field_renderer")

local field = {}
field.active = false
field.draw_x = 0
field.draw_y = 0

local batches = {}

local me

local tile_size = 48

local m

function field.query()
   local dt = 0
   local going = true

   field.active = true

   local hud = require("api.gui.hud.MainHud"):new()
   internal.draw.set_hud(hud)

   startup.load_batches(require("internal.draw.coords.tiled_coords"):new())

   map.create()

   field_renderer.create()

   me = Chara.create("base.player", 25, 25)

   local keys = InputHandler:new()
   keys:focus()
   keys:bind_keys {
      a = function()
         print("do")
      end,
      up = function()
         Command.move(me, "North")
      end,
      down = function()
         Command.move(me, "South")
      end,
      left = function()
         Command.move(me, "East")
      end,
      right = function()
         Command.move(me, "West")
      end,
      escape = function()
         if Input.yes_no() then
            going = false
         end
      end,
      ["return"] = function()
         print(require("api.gui.TextPrompt"):new(16):query())
      end,
   }

   internal.draw.set_root_input_handler(keys)

   field_renderer.get():update_draw_pos(me.x, me.y)

   while going do
      local ran = keys:run_actions()

      if ran then
         field_renderer.get():update_draw_pos(me.x, me.y)
      end

      dt = coroutine.yield()
   end

   field.active = false

   return "title"
end

function field.draw()
   field_renderer.get():draw()

   internal.draw.draw_hud()
end

return field
