local Draw = require("api.Draw")
local I18N = require("api.I18N")
local Input = require("api.Input")
local IUiList = require("api.gui.IUiList")

local UiList = class("UiList", IUiList)

local keys = "abcdefghijklmnopqr"

function UiList:init(x, y, items)
      self.x = x
      self.y = y
      self.items = items
      self.selected = 1,
      self.chosen = false,
      self.select_key = { image = Draw.load_image("graphic/temp/select_key.bmp") },
      self.list_bullet = { image = Draw.load_image("graphic/temp/list_bullet.bmp") },

      self.keys = {}
      self.keys["return"] = function(p)
         if p then
            self.chosen = true
         end
      end
      self.keys.up = function(p)
         if p then
            self:select_previous()
         end
      end,
      self.keys.down = function(p)
         if p then
            self:select_next()
         end
      end

   for i=1,#keys do
      local key = keys:sub(i, i)
      self.keys[key] = function(p)
         if p then
            self.selected = i
            self.chosen = true
         end
      end
   end
end

function UiList:focus()
   Input.set_key_handler(self.keys)
end

function UiList:relayout()
end

function UiList:select_next()
   self.selected = self.selected + 1
   if self.selected > #self.items then
      self.selected = 1
   end
end

function UiList:select_previous()
   self.selected = self.selected - 1
   if self.selected < 1 then
      self.selected = #self.items
      if self.selected < 1 then
         self.selected = 1
      end
   end
end

function UiList:selected_item()
   return self.items[self.selected]
end

function UiList:draw()
   local function cs_list(selected, text, x, y, x_offset)
      x_offset = x_offset or 0
      if selected then
         local width = math.clamp(Draw.text_width(text) + 32 + x_offset, 10, 400)
         love.graphics.setBlendMode("alpha")
         Draw.filled_rect(x, y, width, 19, {127, 191, 255, 63})
         Draw.image(self.list_bullet.image, x + width - 20, y + 4, nil, nil, {255, 255, 255})
      end
      Draw.text(text, x + 4 + x_offset, y + 3, {0, 0, 0})
   end

   for i, item in ipairs(self.items) do
      local x = self.x
      local y = (i - 1) * 35 + self.y
      Draw.image(self.select_key.image, x, y, nil, nil, {255, 255, 255})
      local key = keys:sub(i, i)
      Draw.text_shadowed(key,
                         x + (self.select_key.image:getWidth() - Draw.text_width(key)) / 2 - 2,
                         y + (self.select_key.image:getHeight() - Draw.text_height()) / 2,
                         {250, 240, 230},
                         {50, 60, 80})
      if I18N.language == "en" then
         Draw.set_font(14 - 2)
         cs_list(i == self.selected, item, x + 40, y + 1)
      else
         Draw.set_font(11)
         Draw.text(item, x + 40, y - 4, {0, 0, 0})
         Draw.set_font(14)
         cs_list(i == self.selected, item, x + 40, y + 8)
      end
   end
end

function UiList:update()
   self.chosen = false
end

return UiList
