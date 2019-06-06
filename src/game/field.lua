local internal = require("internal")
local startup = require("game.startup")

local Draw = require("api.Draw")
local InputHandler = require("api.gui.InputHandler")
local GameKeyHandler = require("api.gui.GameKeyHandler")
local IUiLayer = require("api.gui.IUiLayer")

local map = require("internal.map")
local field_renderer = require("internal.field_renderer")

local field_layer = class("field_layer", IUiLayer)

function field_layer:init()
   self.is_active = false

   startup.load_batches(require("internal.draw").get_coords())

   self.hud = require("api.gui.hud.MainHud"):new()

   self.map = nil
   self.renderer = nil
   self.player = nil

   self.keys = InputHandler:new()
   keys:focus()
end

function field_layer:set_map(map)
   self.map = map
   self.renderer = field_renderer:new(map.width, map.height)
end

function field_layer:draw()
   if self.renderer then
      self.renderer:draw()
   end

   self.hud:draw()
end

function field_layer:exists(obj)
   return self.map and self.map:exists(obj)
end

function field_layer:redraw_screen()
   if not self.is_active or not self.renderer then return end

   local player = self.player
   if player then
      self.renderer:update_draw_pos(player.x, player.y)
   end
   self.renderer:update(self.map)
end

function field_layer:update(dt, ran_action)
   if ran_action then
      self:redraw_screen()
   end
end

-- HACK should be a better way to get default interface implementation
do
   local super = field_layer.query
   function field_layer:query()
      self.is_active = true

      self:redraw_screen()

      super(self)

      self.is_active = false
   end
end

return field_layer:new()
