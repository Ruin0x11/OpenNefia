local Draw = require("api.Draw")
local IUiList = require("api.gui.IUiList")
local UiList = require("api.gui.UiList")
local ListModel = require("api.gui.ListModel")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")

local ChangeAppearanceList = class("ChangeAppearanceList", IUiList)

ChangeAppearanceList:delegate("model", {
                         "items",
                         "get_item_text",
                         "changed",
                         "can_select",
                         "selected",
                         "selected_item",
                         "select",
                         "on_select",
                         "select_next",
                         "select_previous",
                         "set_data",
                         "can_choose",
                         "on_choose",
})

ChangeAppearanceList:delegate("input", IInput)

local function make_arrows()
   local image = Draw.load_image("graphic/temp/arrows.bmp")
   local iw = image:getWidth()
   local ih = image:getHeight()

   local quad = {}
   quad["arrow_left"] = love.graphics.newQuad(0, 0, 24, 24, iw, ih)
   quad["arrow_right"] = love.graphics.newQuad(24, 0, 24, 24, iw, ih)

   return { image = image, quad = quad }
end

function ChangeAppearanceList:init(items)
   self.model = ListModel:new({})
   self.arrows = make_arrows()
   self.item_height = 21
   self.list_bullet = { image = Draw.load_image("graphic/temp/list_bullet.bmp") }
   self.chosen = false

   self.input = InputHandler:new()
   self.input:bind_keys {
      up = function() self:select_previous() end,
      down = function() self:select_next() end,
      ["return"] = function() self:choose(self.model:selected_item()) end,
      left = function() self:decrement(self.model:selected_item()) end,
      right = function() self:increment(self.model:selected_item()) end,
   }

   self:set_page(0)
end

function ChangeAppearanceList:set_page(i)
   local data
   if i == 1 then
      data = {
         { text = "body_color", type = "option", value = "base.0" },
         { text = "cloth_color", type = "option", value = "base.0" },
         { text = "pants_color", type = "option", value = "base.0" },
         { text = "etc_1", type = "option", value = "base.0" },
         { text = "etc_2", type = "option", value = "base.0" },
         { text = "etc_3", type = "option", value = "base.0" },
         { text = "eyes", type = "option", value = "base.0" },
         { text = "set_basic", type = "action", action = function() self:set_page(0); self:select(#self.items) end },
      }
   else
      data = {
         { text = "done", type = "confirm", value = "base.0" },
         { text = "portrait", type = "portrait", value = "base.0" },
         { text = "hair", type = "option", value = "base.0" },
         { text = "sub_hair", type = "option", value = "base.0" },
         { text = "hair_color", type = "option", value = "base.0" },
         { text = "body", type = "option", value = "base.0" },
         { text = "cloth", type = "option", value = "base.0" },
         { text = "pants", type = "option", value = "base.0" },
         { text = "set_detail", type = "action", action = function() self:set_page(1); self:select(#self.items) end },
      }

      local is_player = true
      local has_mount = false
      if is_player and has_mount then
         table.insert(data, { text = "mount", type = "option" })
      elseif not is_player then
         table.insert(data, { text = "custom", type = "option" })
      end
   end
   self.model:set_data(data)
end

function ChangeAppearanceList:increment(item)
   if item.type == "action" then
      item.action()
   else
      item.value = "base.1"
   end
end

function ChangeAppearanceList:decrement(item)
   if item.type == "action" then
      item.action()
   else
      item.value = "base.0"
   end
end

function ChangeAppearanceList:choose(item)
   if item.type == "confirm" then
      self.chosen = true
   else
      self:increment(self.model:selected_item())
   end
end

function ChangeAppearanceList:relayout(x, y)
   self.x = x
   self.y = y
end

function ChangeAppearanceList:draw_item(item, i, x, y)
   local text
   if item.type == "confirm" or item.type == "action" then
      text = item.text
   else
      text = item.text .. " " .. item.value
   end

   UiList.draw_item_text(self, text, item, i, x, y - 1)

   if item.type ~= "confirm" then
      Draw.image_region(self.arrows.image, self.arrows.quad["arrow_left"], x - 30, y - 5, nil, nil, {255, 255, 255})
      Draw.image_region(self.arrows.image, self.arrows.quad["arrow_right"], x + 115, y - 5, nil, nil, {255, 255, 255})
   end
end

function ChangeAppearanceList:draw()
   Draw.set_font(14) -- 14 - en * 2
   for i, item in ipairs(self.items) do
      if self:can_select(self:selected_item(), self.selected) then
         local x = self.x
         local y = (i - 1) * self.item_height + self.y
         self:draw_item(item, i, x, y)
      end
   end
end

function ChangeAppearanceList:update()
   self.chosen = false
end

return ChangeAppearanceList
