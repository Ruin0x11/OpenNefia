local Draw = require("api.Draw")
local Chara = require("api.Chara")
local Pos = require("api.Pos")
local Gui = require("api.Gui")
local Map = require("api.Map")
local Ui = require("api.Ui")

local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local UiTheme = require("api.gui.UiTheme")

local PositionPrompt = class.class("PositionPrompt", IUiLayer)

PositionPrompt:delegate("input", IInput)

function PositionPrompt:init(target_x, target_y, origin_x, origin_y, targets)
   self.origin_x = origin_x or Chara.player().x
   self.origin_y = origin_y or Chara.player().y
   self.target_x = math.clamp(target_x or self.origin_x, 0, Map.current():width()-1)
   self.target_y = math.clamp(target_y or self.origin_y, 0, Map.current():height()-1)

   self.targets = targets or {}
   self.result = nil
   self.canceled = false

   self.input = InputHandler:new()
   self.input:bind_keys {
      ["return"] = function()
         self.result = { x = self.target_x, y = self.target_y }
      end,
      up = function()
         self.target_y = math.max(self.target_y - 1, 0)
      end,
      down = function()
         self.target_y = math.min(self.target_y + 1, Map.current():height()-1)
      end,
      left = function()
         self.target_x = math.max(self.target_x - 1, 0)
      end,
      right = function()
         self.target_x = math.min(self.target_x + 1, Map.current():width()-1)
      end,
      escape = function()
         self.canceled = true
      end,
      shift = function()
         self.canceled = true
      end,
      ["kp+"] = function()
         self:next_target()
      end,
      ["kp-"] = function()
         self:previous_target()
      end
   }

   Gui.set_camera_pos(self.target_x, self.target_y)
end

function PositionPrompt:current_target_index()
   for i, target in ipairs(self.targets) do
      if target.x == self.target_x and target.y == self.target_y then
         return i
      end
   end

   return nil
end

function PositionPrompt:next_target()
   local cur = self:current_target_index()

   cur = cur + 1
   if cur > #self.targets then
      cur = 1
   end

   self.target_x = self.targets[cur].x
   self.target_y = self.targets[cur].y
end

function PositionPrompt:previous_target()
   local cur = self:current_target_index()

   cur = cur - 1
   if cur < 1 then
      cur = #self.targets
   end

   self.target_x = self.targets[cur].x
   self.target_y = self.targets[cur].y
end

function PositionPrompt:draw_target_text(x, y)
end

function PositionPrompt:relayout()
   -- self.x, self.y = Gui.tile_to_screen(self.target_x, self.target_y)
   self.tile_width, self.tile_height = Draw.get_coords():get_size()
   self.t = UiTheme.load(self)
end

function PositionPrompt:on_query()
   Gui.play_sound("base.pop2")
end

local function should_draw_line(origin_x, origin_y, target_x, target_y)
   local chara = Chara.at(target_x, target_y)
   if not chara then
      return false
   end

   if not chara:is_in_fov() then
      return false
   end

   if not chara:has_los(origin_x, origin_y) then
      return false
   end

   if not chara:calc("can_target") then
      return false
   end

   return true
end

function PositionPrompt:draw()
   Gui.set_camera_pos(self.target_x, self.target_y)
   local x, y = Draw.get_coords():tile_to_screen(self.target_x+1, self.target_y+1)
   local draw_x, draw_y, scx, scy = Gui.field_draw_pos()
   love.graphics.setBlendMode("add")
   Draw.filled_rect(x - draw_x, y - draw_y, self.tile_width, self.tile_height, {127, 127, 255, 50})

   if should_draw_line(self.origin_x, self.origin_y, self.target_x, self.target_y) then
      for _, tx, ty in  Pos.iter_line(self.origin_x, self.origin_y, self.target_x, self.target_y) do
         local x, y = Draw.get_coords():tile_to_screen(tx+1, ty+1)
         Draw.filled_rect(x - draw_x, y - draw_y, self.tile_width, self.tile_height, {255, 255, 255, 25})
      end
   end
end

function PositionPrompt:update(dt)
   if self.canceled then
      Gui.set_camera_pos(self.origin_x, self.origin_y)
      Gui.update_screen()
      return nil, "canceled"
   end

   if self.result then
      Gui.set_camera_pos(self.origin_x, self.origin_y)
      Gui.update_screen()
      return self.result
   end
end

return PositionPrompt
