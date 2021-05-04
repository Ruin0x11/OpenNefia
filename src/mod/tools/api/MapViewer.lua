local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Ui = require("api.Ui")
local InstancedMap = require("api.InstancedMap")

local MapRenderer = require("api.gui.MapRenderer")
local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local UiTheme = require("api.gui.UiTheme")

local MapViewer = class.class("MapViewer", IUiLayer)

MapViewer:delegate("input", IInput)

function MapViewer:init(map)
   class.assert_is_an(InstancedMap, map)

   self.map = map
   map:iter_tiles():each(function(x, y) map:memorize_tile(x, y) end)
   map:redraw_all_tiles()

   self.renderer = MapRenderer:new(map)

   self.offset_x = 0
   self.offset_y = 0
   self.delta = 50
   self.draw_border = true

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
end

function MapViewer:default_z_order()
   return 100000000
end

function MapViewer:make_keymap()
   return {
      north = function() self:pan(0, -self.delta) end,
      south = function() self:pan(0, self.delta) end,
      east = function() self:pan(self.delta, 0) end,
      west = function() self:pan(-self.delta, 0) end,
      mode = function() self.draw_border = not self.draw_border end,
      cancel = function() self.canceled = true end,
      escape = function() self.canceled = true end,
      enter = function() self.canceled = true end,
   }
end

function MapViewer:on_query()
   Gui.play_sound("base.pop2")
end

function MapViewer:update_draw_pos()
   self.renderer:set_draw_pos(self.x + self.offset_x, self.y + self.offset_y)
end

function MapViewer:pan(dx, dy)
   self.offset_x = self.offset_x + dx
   self.offset_y = self.offset_y + dy
   self:update_draw_pos()
end

function MapViewer:relayout()
   local tw, th = Draw.get_coords():get_size()
   self.width = self.map:width() * tw
   self.height = self.map:height() * th
   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.y = self.y

   self.renderer:relayout(self.x, self.y, self.width, self.height)
   self:update_draw_pos()
end

function MapViewer:draw()
   local x = self.x + self.offset_x
   local y = self.y + self.offset_y

   local width = math.floor(self.width)
   local height = math.floor(self.height)
   local pad = 10
   local border_width = width + pad
   local border_height = height + pad

   self.renderer:relayout_inner(x, y, width, height)
   self.renderer.x = x
   self.renderer.y = y

   -- if self.draw_border then
   --    Draw.filled_rect(x-pad/2, y-pad/2, border_width, border_height, {0, 0, 0})
   --    Draw.line_rect(x-pad/2, y-pad/2, border_width, border_height, {255, 255, 255})
   -- end

   Draw.set_color(255, 255, 255)
   self.renderer:draw()
end

function MapViewer:update(dt)
   self.renderer:update(dt)

   local canceled = self.canceled
   self.canceled = nil

   if canceled then
      return nil, "canceled"
   end
end

function MapViewer.start(map)
   MapViewer:new(map):query()
end

return MapViewer
