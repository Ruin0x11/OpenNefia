local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local UiTheme = require("api.gui.UiTheme")
local IUiElement = require("api.gui.IUiElement")
local Draw = require("api.Draw")
local Color = require("mod.extlibs.api.Color")
local utils = require("mod.visual_ai.internal.utils")

local VisualAIPlanGrid = class.class("VisualAIPlanGrid", {IUiElement, IInput})

VisualAIPlanGrid:delegate("input", IInput)

function VisualAIPlanGrid:init(plan)
   self.plan = plan

   self.tiles = {}
   self.lines = {}
   self.trail = {}
   self.cursor_x = 1
   self.cursor_y = 1
   self.trail_idx = 1

   self.offset_x = 0
   self.offset_y = 0
   self.canvas_width = 1
   self.canvas_height = 1
   self.tile_size_px = 48
   self.tile_padding = 8

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
end

function VisualAIPlanGrid:make_keymap()
   return {
      enter = function() self.chosen = true end,

      north = function() self:move_cursor( 0, -1) end,
      south = function() self:move_cursor( 0,  1) end,
      west  = function() self:move_cursor(-1,  0) end,
      east  = function() self:move_cursor( 1,  0) end,
   }
end

function VisualAIPlanGrid:move_cursor(dx, dy)
   self.cursor_x = math.wrap(self.cursor_x + dx, 1, self.tile_count_x + 1)
   self.cursor_y = math.wrap(self.cursor_y + dy, 1, self.tile_count_y + 1)
   self:_recalc_offsets()
   self:_recalc_active_trail()
   self.changed = true
end

function VisualAIPlanGrid:selected_tile()
   return self.tiles[(self.cursor_y-1)*self.canvas_width+self.cursor_x]
end

function VisualAIPlanGrid:_resize_canvas_from_plan()
   self.canvas_width = math.floor(self.width / self.tile_size_px)
   self.canvas_height = math.floor(self.height / self.tile_size_px)

   self.cursor_x = math.clamp(self.cursor_x, 1, self.canvas_width)
   self.cursor_y = math.clamp(self.cursor_y, 1, self.canvas_height)
end

function VisualAIPlanGrid:_recalc_offsets()
   self.offset_x = 0
   local selected_x = self.cursor_x * self.tile_size_px
   if selected_x + self.tile_size_px > self.width then
      self.offset_x = math.max(self.width - (selected_x + self.tile_size_px), math.floor(self.tile_count_x - (self.width / self.tile_size_px)) * -self.tile_size_px)
   end

   self.offset_y = 0
   local selected_y = self.cursor_y * self.tile_size_px
   if selected_y + self.tile_size_px > self.height then
      self.offset_y = math.max(self.height - (selected_y + self.tile_size_px), math.floor(self.tile_count_y - (self.height / self.tile_size_px)) * -self.tile_size_px)
   end
end

function VisualAIPlanGrid:_recalc_active_trail()
   local selected = self:selected_tile()
   if selected == nil then
      return
   end

   self.trail = {}
   self.trail_idx = 1

   local plans = table.set {selected.plan}

   local backwards = selected.plan.parent
   while backwards do
      plans[backwards] = true
      backwards = backwards.parent
   end

   local forwards = selected.plan.subplan_true
   while forwards do
      plans[forwards] = true
      forwards = forwards.subplan_true
   end

   for _, tile in pairs(self.tiles) do
      if plans[tile.plan] then
         tile.selected = true
         self.trail[#self.trail+1] = tile
         if tile == selected then
            self.trail_idx = #self.trail
         end
      else
         tile.selected = false
      end
   end

   for _, line in pairs(self.lines) do
      if plans[line.plan] then
         line.selected = true
      else
         line.selected = false
      end
   end
end

function VisualAIPlanGrid:get_trail_and_index()
   return self.trail, self.trail_idx
end

function VisualAIPlanGrid:_recalc_layout()
   local tw, th = self.plan:tile_size()
   self.tiles = {}
   self.lines = {}
   self.tile_count_x = math.max(tw, self.canvas_width)
   self.tile_count_y = math.max(th, self.canvas_height)

   self:_resize_canvas_from_plan()

   for _, state, x, y, block, plan in self.plan:iter_tiles() do
      local idx = y*self.canvas_width+x+1
      if state == "empty" then
         self.tiles[idx] = {
            x = x,
            y = y,
            type = "empty",
            color = self.t.visual_ai["color_tile_empty"],
            plan = plan,
            selected = false
         }
      elseif state == "block" then
         local color = utils.get_block_color(block.proto, self.t)
         local icon = utils.get_block_icon(block.proto, self.t)
         local text = utils.get_block_text(block.proto, block.vars)

         self.tiles[idx] = {
            x = x,
            y = y,
            type = "block",
            block = block,
            icon = icon,
            color = color,
            text = text,
            plan = plan,
            selected = false
         }
      elseif state == "line" then
         self.lines[#self.lines+1] = {
            sx = x,
            sy = y,
            type = block[1],
            ex = block[2],
            ey = block[3],
            plan = plan,
            selected = false
         }
      end
   end

   self:_recalc_offsets()
   self:_recalc_active_trail()
end

function VisualAIPlanGrid:refresh()
   self:_resize_canvas_from_plan()
   self:_recalc_layout()
   self:_recalc_offsets()
   self.changed = true
end

function VisualAIPlanGrid:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load(self)

   self:refresh()
end

function VisualAIPlanGrid.draw_tile(icon, color, selected, x, y, tile_size_px, tile_padding)
   local size = tile_size_px - tile_padding * 2

   Draw.set_color(255, 255, 255)
   Draw.filled_rect(x + tile_padding - 2, y + tile_padding - 2, size + 4, size + 4)
   Draw.set_color(0, 0, 0)
   Draw.filled_rect(x + tile_padding - 1, y + tile_padding - 1, size + 2, size + 2)
   Draw.set_color(color)
   Draw.filled_rect(x + tile_padding, y + tile_padding, size, size)
   if icon then
      if selected then
         Draw.set_color(255, 255, 255)
      else
         Draw.set_color(128, 128, 128)
      end
      icon:draw(x + tile_padding - 4 + 1, y + tile_padding - 4 + 1, size + 4, size + 4)
   end
end

function VisualAIPlanGrid:draw()
   local size = self.tile_size_px - self.tile_padding * 2
   local ox = self.x + self.offset_x
   local oy = self.y + self.offset_y

   Draw.set_scissor(self.x, self.y, self.width, self.height)

   Draw.set_color(0, 0, 0, 20)
   for y = 1, self.tile_count_y do
      for x = 1, self.tile_count_x do
         local x = ox + (x-1) * self.tile_size_px
         local y = oy + (y-1) * self.tile_size_px
         Draw.filled_rect(x + self.tile_padding, y + self.tile_padding, size, size)
      end
   end

   Draw.set_line_width(4)
   for _, line in ipairs(self.lines) do
      if line.type == "right" then
         if line.selected then
            Draw.set_color(100, 100, 200)
         else
            Draw.set_color(50, 50, 100)
         end
      elseif line.type == "down" then
         if line.selected then
            Draw.set_color(200, 100, 100)
         else
            Draw.set_color(100, 50, 50)
         end
      end
      local sx = ox + (line.sx) * self.tile_size_px + self.tile_size_px / 2
      local sy = oy + (line.sy) * self.tile_size_px + self.tile_size_px / 2
      local ex = ox + (line.ex) * self.tile_size_px + self.tile_size_px / 2
      local ey = oy + (line.ey) * self.tile_size_px + self.tile_size_px / 2
      Draw.line(sx, sy, ex, ey)
   end
   Draw.set_line_width()

   for _, tile in pairs(self.tiles) do
      local x = ox + tile.x * self.tile_size_px
      local y = oy + tile.y * self.tile_size_px
      if tile.type == "empty" then
         Draw.set_color(tile.color)
         Draw.filled_rect(x + self.tile_padding, y + self.tile_padding, size, size)
         Draw.set_color(200, 40, 40)
         Draw.line_rect(x + self.tile_padding, y + self.tile_padding, size, size)
      else
         tile.dark_color = tile.dark_color or {Color:new_rgb(tile.color):lighten_by(0.5):to_rgb()}
         VisualAIPlanGrid.draw_tile(tile.icon, tile.selected and tile.color or tile.dark_color, tile.selected, x, y, self.tile_size_px, self.tile_padding)
      end
   end

   local x = ox + (self.cursor_x-1) * self.tile_size_px
   local y = oy + (self.cursor_y-1) * self.tile_size_px
   Draw.set_color(230, 230, 255, 128)
   Draw.filled_rect(x, y, self.tile_size_px, self.tile_size_px)
   Draw.set_line_width(2)
   Draw.set_color(64, 64, 64, 128)
   Draw.line_rect(x, y, self.tile_size_px, self.tile_size_px)
   Draw.set_line_width()

   Draw.set_scissor()
end

function VisualAIPlanGrid:update(dt)
   if self.changed then
      self.changed = false
   end
   if self.chosen then
      self.chosen = false
      return self:selected_tile()
   end
end

return VisualAIPlanGrid
