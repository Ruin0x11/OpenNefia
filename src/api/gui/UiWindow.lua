local Draw = require("api.Draw")

local Window = require("api.gui.Window")
local TopicWindow = require("api.gui.TopicWindow")
local IUiElement = require("api.gui.IUiElement")
local IPaged = require("api.gui.IPaged")

local UiWindow = class("UiWindow", IUiElement)

function UiWindow:init(title, shadow, key_help, x_offset, y_offset)
   local image = Draw.load_image("graphic/temp/tip_icons.bmp")
   local quad = love.graphics.newQuad(0, 0, 24, 16, image:getWidth(), image:getHeight())

   self.x_offset = x_offset or 0
   self.y_offset = y_offset or 0
   self.title = title or ""
   self.key_help = key_help or ""
   self.tip_icon = { image = image, quad = quad }
   self.page = 0
   self.page_max = 0
   self.show_page = false

   shadow = shadow or true
   if shadow then
      self.shadow = Window:new(true)
   end

   if string.nonempty(self.title) then
      self.topic_window = TopicWindow:new(1, 1)
   end

   self.image = Window:new()
end

function UiWindow:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height

   if self.shadow then
      self.shadow:relayout(x + 4, y + 4, width, height - height % 8)
   end
   self.image:relayout(x, y, width, height)
   if self.topic_window then
      self.topic_window:relayout(x + 34,
                                 y - 4,
                                 45 * width / 100 + math.clamp(Draw.text_width(self.title) - 120, 0, 200),
                                 32)
   end
end

function UiWindow:set_title(title)
   self.title = title
   if string.nonempty(self.title) then
      if self.topic_window == nil then
         self.topic_window = TopicWindow:new(1, 1)
      end
   else
      self.topic_window = nil
   end

   if self.x ~= nil then
      self:relayout(self.x, self.y, self.width, self.height)
   end
end

function UiWindow:draw()
   if self.shadow then
      Draw.set_color(31, 31, 31, 127)
      self.shadow:draw()
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
   local title = self.title

   Draw.image_region(self.tip_icon.image, self.tip_icon.quad, x + 30 + x_offset, y + height - 47 - height % 8)

   Draw.line(x + 50 + x_offset,
             y + height - 48 - self.height % 8,
             x + width - 40,
             y + height - 48 - height % 8,
             {194, 170, 146})

   Draw.line(x + 50 + x_offset,
             y + height - 49 - self.height % 8,
             x + width - 40,
             y + height - 49 - height % 8,
             {234, 220, 188})

   Draw.set_font(15) -- 15 + en - en * 2

   Draw.text_shadowed(title,
                      x + 45 * width / 200 + 34 - (Draw.text_width(title) / 2)
                         + math.clamp(Draw.text_width(title) - 120, 0, 200) / 20,
   y + 4, -- y + 4 + vfix
   {255, 255, 255},
   {20, 10, 0})

   Draw.set_color(0, 0, 0)
   Draw.set_font(12) -- 12 + sizefix - en * 2
   Draw.text(self.key_help, x + 58 + x_offset, y + height - 43 - height % 8)

   if self.show_page then
      Draw.set_font(12, "bold") -- 12 + sizefix - en * 2
      local page_str = "Page." .. tostring(self.page + 1) .. "/" .. tostring(self.page_max + 1)
      Draw.text(page_str, x + width - Draw.text_width(page_str) - 40 - y_offset, y + height - 65 - height % 8)
   end
end

function UiWindow:set_pages(pages)
   if pages == nil then
      self.show_page = false
      return
   end

   assert_is_an(IPaged, pages)
   self.page = pages.page
   self.page_max = pages.page_max
   self.show_page = true
end

function UiWindow:update()
   if self.shadow then
      self.shadow:update()
   end
   self.image:update()
   if self.topic_window then
      self.topic_window:update()
   end
end

return UiWindow
