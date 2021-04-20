local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Ui = require("api.Ui")

local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local UiTheme = require("api.gui.UiTheme")

local DirectionPrompt = class.class("DirectionPrompt", IUiLayer)

DirectionPrompt:delegate("input", IInput)

function DirectionPrompt:init(x, y, screen_pos)
   self.center_x = x
   self.center_y = y
   self.screen_pos = screen_pos or false
   self.frame = 0
   self.diagonal_only = false
   self.result = nil
   self.canceled = false

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
   self.input:ignore_modifiers { "alt" }
end

function DirectionPrompt:make_keymap()
   return {
      enter = function()
         self.result = "Center"
      end,
      north = function()
         if not self.diagonal_only then
            self.result = "North"
         end
      end,
      south = function()
         if not self.diagonal_only then
            self.result = "South"
         end
      end,
      west = function()
         if not self.diagonal_only then
            self.result = "West"
         end
      end,
      east = function()
         if not self.diagonal_only then
            self.result = "East"
         end
      end,
      northwest = function()
         self.result = "Northwest"
      end,
      northeast = function()
         self.result = "Northeast"
      end,
      southwest = function()
         self.result = "Southwest"
      end,
      southeast = function()
         self.result = "Southeast"
      end,
      escape = function()
         self.canceled = true
      end,
      cancel = function()
         self.canceled = true
      end
   }
end

function DirectionPrompt:relayout(x, y)
   if self.screen_pos then
      x = x or self.center_x
      y = y or self.center_y
   end

   if self.screen_pos then
      self.x, self.y = x, y
   else
      self.x, self.y = Gui.tile_to_screen(self.center_x, self.center_y)
   end
   self.tile_width, self.tile_height = Draw.get_coords():get_size()
   self.t = UiTheme.load(self)
end

function DirectionPrompt:on_query()
   Gui.play_sound("base.pop2")
end

function DirectionPrompt:draw()
   local frame = math.floor(self.frame*50)
   local alpha = math.floor(200 - frame / 2 % 20 * (frame / 2 % 20))
   local draw_x, draw_y = Gui.field_draw_pos()
   local tw, th = Draw.get_coords():get_size()
   local x = self.x + draw_x + math.floor(tw / 2)
   local y = self.y + draw_y + math.floor(th / 2)

   -- TODO move draw args into params

   Draw.set_color(255,255,255,alpha)

   if not self.diagonal_only then
      self.t.base.direction_arrow:draw(x, y - self.tile_height, nil, nil, nil, true, 0)
      self.t.base.direction_arrow:draw(x, y + self.tile_height, nil, nil, nil, true, 180)
      self.t.base.direction_arrow:draw(x + self.tile_width, y, nil, nil, nil, true, 90)
      self.t.base.direction_arrow:draw(x - self.tile_width, y, nil, nil, nil, true, 270)
   end

   self.t.base.direction_arrow:draw(x - self.tile_width, y - self.tile_height, nil, nil, nil, true, 315)
   self.t.base.direction_arrow:draw(x + self.tile_width, y + self.tile_height, nil, nil, nil, true, 135)
   self.t.base.direction_arrow:draw(x + self.tile_width, y - self.tile_height, nil, nil, nil, true, 45)
   self.t.base.direction_arrow:draw(x - self.tile_width, y + self.tile_height, nil, nil, nil, true, 225)
end

function DirectionPrompt:update(dt)
   self.frame = self.frame + dt

   self.diagonal_only = self.input:is_modifier_held("alt")

   if self.canceled then
      return nil, "canceled"
   end

   if self.result then
      return self.result
   end
end

return DirectionPrompt
