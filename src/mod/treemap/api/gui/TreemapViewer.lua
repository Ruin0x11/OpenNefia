local Gui = require("api.Gui")
local Ui = require("api.Ui")
local Draw = require("api.Draw")

local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local Treemap = require("mod.treemap.api.gui.Treemap")

local TreemapViewer = class.class("TreemapViewer", IUiLayer)

TreemapViewer:delegate("input", IInput)

function TreemapViewer:init(t, depth)
   assert(type(t) == "table")
   if next(t) == nil then
      error("Table has no elements.")
   end

   self.depth = depth or 3
   self.treemap = Treemap:new(t, self.depth)
   self.trail = {}
   self.selected = 1

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
end

function TreemapViewer:default_z_order()
   return 100000000
end

function TreemapViewer:make_keymap()
   return {
      cancel = function() self:go_back() end,
      escape = function() self:go_back() end,
      enter = function() self:choose() end,
      north = function() self:select_prev() end,
      south = function() self:select_next() end,
   }
end

function TreemapViewer:select_next()
   self.selected = math.min(self.selected + 1, #self.treemap.sizes)
end

function TreemapViewer:select_prev()
   self.selected = math.max(self.selected - 1, 1)
end

function TreemapViewer:choose()
   local size = self.treemap.sizes[self.selected]
   if size and size.cell.child and next(size.value)  then
      self.trail[#self.trail+1] = { self.treemap, self.selected }
      self.treemap = size.cell.child
      self.selected = 1
      self:relayout()
      self:halt_input()
   end
end

function TreemapViewer:go_back()
   if #self.trail == 0 then
      self.canceled = true
      return
   end

   self.treemap = self.trail[#self.trail][1]
   self.selected = self.trail[#self.trail][2]
   self.trail[#self.trail] = nil
   self:relayout()
   self:halt_input()
end

function TreemapViewer:on_query()
   Gui.play_sound("base.pop2")
end

function TreemapViewer:relayout(x, y, width, height)
   local pad = 150
   if width and self.width == nil then
      self.x, self.y, self.width, self.height = Ui.params_centered(width - pad, height - pad)
   end

   self.treemap:relayout(0, 0, self.width, self.height)

   self.canvas = Draw.create_canvas(self.width, self.height)
   self.redraw = true
end

function TreemapViewer:draw()
   if self.redraw then
      Draw.set_color(255, 255, 255)
      Draw.with_canvas(self.canvas, function() self.treemap:draw() end)
      self.redraw = false
   end
   Draw.image(self.canvas, self.x, self.y)

   local size = self.treemap.sizes[self.selected]
   if size and size.cell.x then
      Draw.set_color(255, 255, 255, 80)
      Draw.filled_rect(self.x + size.cell.x, self.y + size.cell.y, size.cell.width, size.cell.height)
   end
end

function TreemapViewer:update(dt)
   self.treemap:update(dt)

   if self.canceled then
      return nil, "canceled"
   end
end

function TreemapViewer.inspect(t, depth)
   TreemapViewer:new(t, depth):query()
end

return TreemapViewer
