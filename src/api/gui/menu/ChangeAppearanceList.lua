local Draw = require("api.Draw")
local IUiList = require("api.gui.IUiList")
local UiList = require("api.gui.UiList")

local ChangeAppearanceList = class("ChangeAppearanceList", IUiList)

ChangeAppearanceList:delegate("inner", {
                         "x",
                         "y",
                         "items",
                         "changed",
                         "selected",
                         "selected_item",
                         "select",
                         "select_next",
                         "select_previous",
                         "relayout",
                         "update",
                         "draw",
                         "focus",
                         "set_data"
})

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
   self.inner = UiList:new(x, y, items, 21)
   self.arrows = make_arrows()
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

   inner:draw_item_text(text, i, item, x, y - 1)

   if item.kind then
      Draw.image_region(self.arrows.image, self.arrows.quad["arrow_left"], x - 30, y - 5)
      Draw.image_region(self.arrows.image, self.arrows.quad["arrow_right"], x + 115, y - 5)
   end
end

function ChangeAppearanceList:can_select(i)
   return true
end

function ChangeAppearanceList:bind()
end

function ChangeAppearanceList:choose(i)
end

return ChangeAppearanceList
