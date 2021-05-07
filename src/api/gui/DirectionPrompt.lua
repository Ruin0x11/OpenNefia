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
   self.disabled = table.set {}

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
   self.input:ignore_modifiers { "alt" }
end

function DirectionPrompt:make_keymap()
   return {
      enter = function()
         if not self.disabled["Center"] then
            self.result = "Center"
         end
      end,
      north = function()
         if not self.diagonal_only and not self.disabled["North"] then
            self.result = "North"
         end
      end,
      south = function()
         if not self.diagonal_only and not self.disabled["South"] then
            self.result = "South"
         end
      end,
      west = function()
         if not self.diagonal_only and not self.disabled["West"] then
            self.result = "West"
         end
      end,
      east = function()
         if not self.diagonal_only and not self.disabled["East"] then
            self.result = "East"
         end
      end,
      northwest = function()
         if not self.disabled["Northwest"] then
            self.result = "Northwest"
         end
      end,
      northeast = function()
         if not self.disabled["Northeast"] then
            self.result = "Northeast"
         end
      end,
      southwest = function()
         if not self.disabled["Southwest"] then
            self.result = "Southwest"
         end
      end,
      southeast = function()
         if not self.disabled["Southeast"] then
            self.result = "Southeast"
         end
      end,
      escape = function()
         self.canceled = true
      end,
      cancel = function()
         self.canceled = true
      end
   }
end

function DirectionPrompt:set_direction_enabled(dir, enabled)
   self.disabled[dir] = not enabled
end

function DirectionPrompt:relayout(x, y)
   if self.screen_pos then
      x = x or self.center_x
      y = y or self.center_y
   end

   if self.screen_pos then
      self.x, self.y = x, y
   else
      self.x, self.y = Gui.tile_to_visible_screen(self.center_x, self.center_y)
      self.x = self.x or 0
      self.y = self.y or 0
   end

   local tw, th = Draw.get_coords():get_size()
   self.x = self.x + math.floor(tw / 2)
   self.y = self.y + math.floor(th / 2)

   self.tile_width, self.tile_height = Draw.get_coords():get_size()
   self.t = UiTheme.load(self)
end

function DirectionPrompt:on_query()
   Gui.play_sound("base.pop2")
end

function DirectionPrompt:draw()
   local frame = math.floor(self.frame*50)
   local alpha = math.floor(200 - frame / 2 % 20 * (frame / 2 % 20))

   local x = self.x
   local y = self.y

   Draw.set_color(255,255,255,alpha)

   local function draw_arrow(dir, sx, sy, rot)
      if not self.disabled[dir] then
         self.t.base.direction_arrow:draw(sx, sy, nil, nil, nil, true, rot)
      end
   end

   if not self.diagonal_only then
      draw_arrow("North", x, y - self.tile_height, 0)
      draw_arrow("South", x, y + self.tile_height, 180)
      draw_arrow("East", x + self.tile_width, y, 90)
      draw_arrow("West", x - self.tile_width, y, 270)
   end

   draw_arrow("Northwest", x - self.tile_width, y - self.tile_height, 315)
   draw_arrow("Southeast", x + self.tile_width, y + self.tile_height, 135)
   draw_arrow("Southwest", x + self.tile_width, y - self.tile_height, 45)
   draw_arrow("Northeast", x - self.tile_width, y + self.tile_height, 225)
end

function DirectionPrompt:set_frame(frame)
   self.frame = frame or 0
end

function DirectionPrompt:update(dt)
   self.frame = self.frame + dt

   self.diagonal_only = self.input:is_modifier_held("alt")

   local canceled = self.canceled
   local result = self.result

   self.canceled = nil
   self.result = nil

   if canceled then
      return nil, "canceled"
   end

   if result then
      return result
   end
end

return DirectionPrompt
