local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local UiTheme = require("api.gui.UiTheme")
local IUiElement = require("api.gui.IUiElement")
local Draw = require("api.Draw")

local VisualAIPlanGrid = class.class("VisualAIPlanGrid", {IUiElement, IInput})

VisualAIPlanGrid:delegate("input", IInput)

function VisualAIPlanGrid:init(plan)
   self.plan = plan

   self.tiles = {}
   self.lines = {}
   self.cursor_x = 1
   self.cursor_y = 1

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

local function wrap(x, min, max)
   return (((x - min) % (max - min)) + (max - min)) % (max - min) + min
end

function VisualAIPlanGrid:move_cursor(dx, dy)
   self.cursor_x = wrap(self.cursor_x + dx, 1, self.canvas_width + 1)
   self.cursor_y = wrap(self.cursor_y + dy, 1, self.canvas_height + 1)
end

function VisualAIPlanGrid:selected_tile()
   return self.tiles[self.cursor_y*self.canvas_width+self.cursor_x+1]
end

function VisualAIPlanGrid:_resize_canvas_from_plan()
   self.canvas_width = math.floor(self.width / self.tile_size_px)
   self.canvas_height = math.floor(self.height / self.tile_size_px)

   self.cursor_x = math.clamp(self.cursor_x, 1, self.canvas_width)
   self.cursor_y = math.clamp(self.cursor_y, 1, self.canvas_height)
end

local DEFAULT_ICONS = {
   condition = "visual_ai.icon_down_right",
   target = "visual_ai.icon_figurine",
   action = "visual_ai.icon_flag",
}

function VisualAIPlanGrid:_recalc_layout()
   local tw, th = self.plan:tile_size()
   self.tiles = {}
   self.lines = {}
   self.tile_width = math.max(tw, self.canvas_width)
   self.tile_height = math.max(th, self.canvas_height)

   self:_resize_canvas_from_plan()

   for _, state, x, y, block in self.plan:iter_tiles() do
      local idx = y*self.canvas_width+x+1
      if state == "empty" then
         self.tiles[idx] = {
            x = x,
            y = y,
            type = "empty",
            color = self.t.visual_ai["color_tile_empty"]
         }
      elseif state == "block" then
         local color
         if type(block.proto.color) == "string" then
            color = self.t[block.proto.color]
            assert(color)
         elseif block.proto_color then
            color = block.proto.color
         else
            color = self.t.visual_ai[("color_block_" .. block.proto.type)]
         end

         local icon
         if block.proto.icon then
            icon = self.t[block.proto.icon]
         else
            local default = DEFAULT_ICONS[block.proto.type]
            if default then
               icon = self.t[default]
            end
         end

         self.tiles[idx] = {
            x = x,
            y = y,
            type = "block",
            block = block,
            icon = icon,
            color = color
         }
      elseif state == "line" then
         self.lines[#self.lines+1] = {
            sx = x,
            sy = y,
            type = block[1],
            ex = block[2],
            ey = block[3],
         }
      end
   end
end

function VisualAIPlanGrid:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load(self)

   self:_resize_canvas_from_plan()
   self:_recalc_layout()
end

function VisualAIPlanGrid:draw()
   local size = self.tile_size_px - self.tile_padding * 2


   Draw.set_color(0, 0, 0, 20)
   for y = 1, self.canvas_height do
      for x = 1, self.canvas_width do
         local x = self.x + (x-1) * self.tile_size_px
         local y = self.y + (y-1) * self.tile_size_px
         Draw.filled_rect(x + self.tile_padding, y + self.tile_padding, size, size)
      end
   end

   Draw.set_line_width(4)
   for _, line in ipairs(self.lines) do
      if line.type == "right" then
         Draw.set_color(100, 100, 200)
      elseif line.type == "down" then
         Draw.set_color(200, 100, 100)
      end
      local sx = self.x + (line.sx) * self.tile_size_px + self.tile_size_px / 2
      local sy = self.y + (line.sy) * self.tile_size_px + self.tile_size_px / 2
      local ex = self.x + (line.ex) * self.tile_size_px + self.tile_size_px / 2
      local ey = self.y + (line.ey) * self.tile_size_px + self.tile_size_px / 2
      Draw.line(sx, sy, ex, ey)
   end
   Draw.set_line_width()

   for _, tile in pairs(self.tiles) do
      local x = self.x + tile.x * self.tile_size_px
      local y = self.y + tile.y * self.tile_size_px
      if tile.type == "empty" then
         Draw.set_color(tile.color)
         Draw.filled_rect(x + self.tile_padding, y + self.tile_padding, size, size)
         Draw.set_color(200, 40, 40)
         Draw.line_rect(x + self.tile_padding, y + self.tile_padding, size, size)
      elseif tile.type == "block" then
         Draw.set_color(tile.color)
         Draw.filled_rect(x + self.tile_padding, y + self.tile_padding, size, size)
         Draw.set_color(180, 180, 180)
         Draw.line_rect(x + self.tile_padding, y + self.tile_padding, size, size)
         if tile.icon then
            Draw.set_color(255, 255, 255)
            tile.icon:draw(x + self.tile_padding - 4, y + self.tile_padding - 4, size + 4, size + 4)
            -- tile.icon:draw(x + self.tile_padding, y + self.tile_padding, size, size)
         end
      end
   end

   local x = self.x + (self.cursor_x-1) * self.tile_size_px
   local y = self.y + (self.cursor_y-1) * self.tile_size_px
   Draw.set_color(255, 255, 255, 80)
   Draw.filled_rect(x, y, self.tile_size_px, self.tile_size_px)
end

function VisualAIPlanGrid:update(dt)
   if self.chosen then
      self.chosen = false
      return self:selected_tile()
   end
end

return VisualAIPlanGrid
