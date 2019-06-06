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
field.is_active = false

local batches = {}

local tile_size = 48

local m

function field.query()
   local dt = 0
   local going = true

   field.is_active = true

   local hud = require("api.gui.hud.MainHud"):new()
   internal.draw.set_hud(hud)

   startup.load_batches(require("internal.draw").get_coords())

   map.create(40, 40)

   field_renderer.create()

   do
      local me = Chara.create("base.player", 25, 25)
      Chara.set_player(me)
   end

   local keys = InputHandler:new()
   keys:focus()
   keys:bind_keys {
      a = function()
         print("do")
      end,
      up = function()
         local p = Chara.player()
         Command.move(p, "North")
      end,
      down = function()
         local p = Chara.player()
         Command.move(p, "South")
      end,
      left = function()
         local p = Chara.player()
         Command.move(p, "East")
      end,
      right = function()
         local p = Chara.player()
         Command.move(p, "West")
      end,
      ["`"] = function()
         require("api.gui.menu.Repl"):new({}):query()
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

   local p = Chara.player()
   field_renderer.get():update_draw_pos(p.x, p.y)

   while going do
      local ran = keys:run_actions(dt)

      if ran then
         p = Chara.player()
         field_renderer.get():update_draw_pos(p.x, p.y)
      end

      dt = coroutine.yield()
   end

   field.is_active = false

   return "title"
end

function field.draw()
   field_renderer.get():draw()

   internal.draw.draw_hud()
end

return field
