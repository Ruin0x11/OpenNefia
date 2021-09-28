local I18N = require("api.I18N")
local Draw = require("api.Draw")
local Ui = require("api.Ui")

local TopicWindow = require("api.gui.TopicWindow")
local IUiElement = require("api.gui.IUiElement")
local ISettable = require("api.gui.ISettable")
local UiTheme = require("api.gui.UiTheme")

local IconBar = class.class("IconBar", {IUiElement, ISettable})

function IconBar:init(icon_set, key_hints)
   self.icon_set = icon_set
   self.icon_order = {}
   self.index = 1
   self.bar = TopicWindow:new(5, 5)
   self.key_hints = Ui.format_key_hints(key_hints)
end

function IconBar:set_data(icon_order)
   for _, pair in ipairs(icon_order) do
      pair.text = I18N.get_optional(pair.text) or pair.text
   end

   self.icon_order = icon_order
   self.redraw = true
end

function IconBar:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load(self)
   self.canvas = Draw.create_canvas(self.width + 100, self.height + 100)
   self.redraw = true

   self.bar:relayout(50, 50, width, height)
end

function IconBar:select(index)
   self.index = index
   self.redraw = true
end

function IconBar:do_redraw()
   local x = 50
   local y = 50
   self.bar:draw()
   self.t.base.radar_deco:draw(x - 28, y - 8, nil, nil, {255, 255, 255})

   Draw.set_font(12) -- 12 + sizefix - en * 2

   for i, item in ipairs(self.icon_order) do
      local icon = item.icon
      local text = item.text

      local x = x + (i-1) * 44
      self.t.base[self.icon_set]:draw_region(icon, x + 20, y - 24)

      local color = {165, 165, 165}
      if self.index == i then
         color = {255, 255, 255}

         Draw.set_blend_mode("add")
         self.t.base[self.icon_set]:draw_region(i, x + 20, y - 24, nil, nil, {255, 255, 255, 70})
         Draw.set_blend_mode("alpha")
      end


      Draw.text_shadowed(text, x + 46 - math.floor(Draw.text_width(text) / 2), y + 7, color)

      local invkey = "(" .. tostring(i) .. ")"
      if invkey then
         Draw.text_shadowed(invkey, x + 46, y + 18, {235, 235, 235})
      end
   end

   Draw.text_shadowed(self.key_hints, x + self.width - Draw.text_width(self.key_hints) - 6, y + 32)
end

function IconBar:draw()
   Draw.set_color(255, 255, 255)

   if self.redraw then
      Draw.with_canvas(self.canvas, function() self:do_redraw() end)
      self.redraw = false
   end

   Draw.image(self.canvas, self.x - 50, self.y - 50)
end

function IconBar:update()
end

function IconBar:release()
   if self.canvas then
      self.canvas:release()
   end
end

return IconBar
