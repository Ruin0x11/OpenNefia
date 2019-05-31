local Draw = require("api.Draw")
local IUiList = require("api.gui.IUiList")
local UiList = require("api.gui.UiList")
local UiList = require("api.gui.UiList")
local PagedListModel = require("api.gui.PagedListModel")
local IKeyInput = require("api.gui.IKeyInput")
local KeyHandler = require("api.gui.KeyHandler")

local ChangeAppearanceList = class("ChangeAppearanceList", IUiList)

ChangeAppearanceList:delegate("model", {
                         "items",
                         "changed",
                         "selected",
                         "selected_item",
                         "select",
                         "select_next",
                         "select_previous",
                         "set_data",
                         "chosen"
})

ChangeAppearanceList:delegate("keys", IKeyInput)

local function make_arrows()
   local image = Draw.load_image("graphic/temp/arrows.bmp")
   local iw = image:getWidth()
   local ih = image:getHeight()

   local quad = {}
   quad["arrow_left"] = love.graphics.newQuad(0, 0, 24, 24, iw, ih)
   quad["arrow_right"] = love.graphics.newQuad(24, 0, 24, 24, iw, ih)

   return { image = image, quad = quad }
end

function ChangeAppearanceList:init(x, y, items)
   self.x = x
   self.y = y
   self.model = PagedListModel:new(items, 9)
   self.arrows = make_arrows()
   self.item_height = 21
   self.list_bullet = { image = Draw.load_image("graphic/temp/list_bullet.bmp") }
   self.keys = KeyHandler:new()
end

function ChangeAppearanceList:get_item_text(item)
   local part = "N/A"

   if item.kind == "name" then
      part = item.value
   elseif item.kind == "number" then
      part = tostring(item.value)
   end

   return item.category .. " " .. part
end

function ChangeAppearanceList:draw_item(i, item, x, y)
   local text = self:get_item_text(item)

   UiList.draw_item_text(self, text, i, item, x, y - 1)

   if item.kind then
      Draw.image_region(self.arrows.image, self.arrows.quad["arrow_left"], x - 30, y - 5, nil, nil, {255, 255, 255})
      Draw.image_region(self.arrows.image, self.arrows.quad["arrow_right"], x + 115, y - 5, nil, nil, {255, 255, 255})
   end
end

function ChangeAppearanceList:draw()
   Draw.set_font(14) -- 14 - en * 2
   for i, item in ipairs(self.items) do
      if self:can_select(i) then
         local x = self.x
         local y = (i - 1) * self.item_height + self.y
         self:draw_item(i, item, x, y)
      end
   end
end

function ChangeAppearanceList:update()
end

function ChangeAppearanceList:relayout()
end

function ChangeAppearanceList:can_select(i)
   return i ~= 10
end

function ChangeAppearanceList:bind()
end

function ChangeAppearanceList:choose(i)
end

return ChangeAppearanceList
