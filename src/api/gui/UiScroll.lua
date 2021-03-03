local Draw = require("api.Draw")
local I18N = require("api.I18N")

local Scroll = require("api.gui.Scroll")
local IUiElement = require("api.gui.IUiElement")
local IPaged = require("api.gui.IPaged")
local UiTheme = require("api.gui.UiTheme")

local UiScroll = class.class("UiScroll", IUiElement)

function UiScroll:init(shadow, key_help, x_offset, y_offset)
   self.x_offset = x_offset or 0
   self.y_offset = y_offset or 0
   self.key_help = key_help or ""
   self.key_help = I18N.get_optional(self.key_help) or self.key_help
   self.page = 0
   self.page_max = 0
   self.show_page = false

   shadow = shadow or true
   if shadow then
      self.shadow = Scroll:new(true)
   end

   self.image = Scroll:new()
end

function UiScroll:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load()

   if self.shadow then
      self.shadow:relayout(x + 4, y + 4, width, height - height % 8)
   end
   self.image:relayout(x, y, width, height)
end

function UiScroll:draw()
   if self.shadow then
      Draw.set_color(255, 255, 255, 80)
      Draw.set_blend_mode("subtract")
      self.shadow:draw()
      Draw.set_blend_mode("alpha")
   end
   Draw.set_color(255, 255, 255)
   self.image:draw()
   if self.topic_window then
      self.topic_window:draw()
   end

   local x = self.x
   local y = self.y
   local width = self.width
   local height = self.height
   local x_offset = self.x_offset
   local y_offset = self.y_offset

   if self.key_help ~= "" then
      self.t.base.tip_icons:draw_region(1, x + 40, y + height - 67 - (height % 8))

      Draw.set_color(194, 173, 161)
      Draw.line(x + 60, y + height - 68 - (height % 8), x + width - 40, y + height - 68 - (height % 8))
      Draw.set_color(224, 213, 191)
      Draw.line(x + 60, y + height - 69 - (height % 8), x + width - 40, y + height - 69 - (height % 8))

      Draw.set_font(12) -- 12 + sizefix
      Draw.set_color(0, 0, 0)
      Draw.text(self.key_help, x + 68, y + height - 63 - (height % 8))
   end

   if self.show_page then
      Draw.set_font(12, "bold") -- 12 + sizefix - en * 2
      local page_str = "Page." .. tostring(self.page + 1) .. "/" .. tostring(self.page_max + 1)
      Draw.text(page_str, x + width - Draw.text_width(page_str) - 40 - y_offset, y + height - 65 - height % 8)
   end
end

function UiScroll:set_pages(pages)
   if pages == nil then
      self.show_page = false
      return
   end

   class.assert_is_an(IPaged, pages)
   self.page = pages.page
   self.page_max = pages.page_max
   self.show_page = true
end

function UiScroll:update()
   if self.shadow then
      self.shadow:update()
   end
   self.image:update()
end

return UiScroll
