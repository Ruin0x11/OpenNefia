local IUiWidget = require("api.gui.IUiWidget")
local UiTheme = require("api.gui.UiTheme")
local DirectionPrompt = require("api.gui.DirectionPrompt")
local Enum = require("api.Enum")
local Gui = require("api.Gui")
local field = require("game.field")

local UiDiagonalArrows = class.class("UiDiagonalArrows", IUiWidget)

function UiDiagonalArrows:init()
   self.directional_prompt = DirectionPrompt:new(0, 0, true)
   self.player_x = nil
   self.player_y = nil
   self.y_offset = 0

   self.directional_prompt:set_direction_enabled(Enum.Direction.North, false)
   self.directional_prompt:set_direction_enabled(Enum.Direction.South, false)
   self.directional_prompt:set_direction_enabled(Enum.Direction.East, false)
   self.directional_prompt:set_direction_enabled(Enum.Direction.West, false)
end

function UiDiagonalArrows:default_widget_z_order()
   return 75000
end

function UiDiagonalArrows:default_widget_refresh(player)
   local sx, sy = Gui.tile_to_visible_screen(player.x, player.y)
   self.player_x = sx or nil
   self.player_y = sy or nil
   self.y_offset = player:calc("y_offset") or 0
end

function UiDiagonalArrows:relayout(x, y)
   self.x = x
   self.y = y
   self.t = UiTheme.load(self)
end

function UiDiagonalArrows:draw()
   if self.player_x and self.player_y and Gui.is_modifier_held("alt") and field:is_querying() then
      self.directional_prompt:relayout(self.player_x, self.player_y + self.y_offset - 16)
      self.directional_prompt:draw()
   else
      self.directional_prompt:set_frame(0)
   end
end

function UiDiagonalArrows:update(dt)
   self.directional_prompt:update(dt)
end

return UiDiagonalArrows
