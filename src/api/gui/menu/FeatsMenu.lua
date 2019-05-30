local Draw = require("api.Draw")
local Ui = require("api.Ui")

local IUiLayer = require("api.gui.IUiLayer")
local UiPagedList = require("api.gui.UiPagedList")
local UiWindow = require("api.gui.UiWindow")
local UiList = require("api.gui.UiList")

local FeatsMenu = class("FeatsMenu", IUiLayer)

FeatsMenu:delegate("win", {"x", "y", "width", "height", "relayout"})
FeatsMenu:delegate("pages", {"focus", "bind"})

local function trait_color(trait)
   if true then
      return {0, 0, 200}
   elseif false then
      return {200, 0, 0}
   end

   return {10, 10, 10}
end

local function make_deco()
   local image = Draw.load_image("graphic/deco_feat.bmp")
   local iw = image:getWidth()
   local ih = image:getHeight()

   local quad = {}
   quad["a"] = love.graphics.newQuad(0, 0, 48, 192, iw, ih)
   quad["b"] = love.graphics.newQuad(48, 0, 48, 144, iw, ih)
   quad["c"] = love.graphics.newQuad(0, 192, 96, 72, iw, ih)
   quad["d"] = love.graphics.newQuad(48, 192, 96, 48, iw, ih)

   return { image = image, quad = quad }
end

local function make_inventory_icon()
   local image = Draw.load_image("graphic/deco_feat.bmp")
   local iw = image:getWidth()
   local ih = image:getHeight()

   local quad = love.graphics.newQuad(48 * 11, 0, 48, 48, iw, ih)
   return { image = image, quad = quad }
end

local function make_trait_icons()
   local image = Draw.load_image("graphic/temp/trait_icons.bmp")
   local iw = image:getWidth()
   local ih = image:getHeight()

   local quad = {}
   for i=1,6 do
      quad[i] = love.graphics.newQuad(24 * (i-1), 0, 24, 24, iw, ih)
   end
   return { image = image, quad = quad }
end

function FeatsMenu:init(chara_make)
   self.x, self.y, self.width, self.height = Ui.params_centered(730, 430)

   if chara_make then
      self.y = self.y + 15
   end

   self.win = UiWindow:new("ui.feat.title", self.x, self.y, self.width, self.height, true, "key help", 55, 40)

   self.inventory_icon = make_inventory_icon()
   self.deco = make_deco()
   self.trait_icons = make_trait_icons()

   self.data = table.flatten(
      table.of(
         {
            { text = "Header.", kind = "text", value = 1 },
            { text = "Feat", kind = "feat", value = 10 },
            { text = "", kind = "feat", value = 1 },
            { text = "Feat", kind = "feat", value = 10000 },
            { text = "Trait", kind = "feat", value = 10000 },
         },
         20))

   local alist = UiList:new(self.x + 58, self.y + 66, self.data, 19)
   self.pages = UiPagedList:new(alist, 15)

   --------------------
   alist.get_item_text = function(l, item)
      return item.text
   end
   alist.draw_select_key = function(l, i, item, key_name, x, y)
      if item.kind ~= "feat" then
         return
      end
      if i % 2 == 0 then
         Draw.filled_rect(x - 1, y, 640, 18, {12, 14, 16, 16})
      end
      if item.value >= 10000 then
         return
      end

      UiList.draw_select_key(l, i, item, key_name, x, y)
   end

   alist.draw_item_text = function(l, text, i, item, x, y, x_offset)
      if item.value < 10 then
         UiList.draw_item_text(l, text, i, item, x, y, x_offset)
         return
      end

      local color = {10, 10, 10}
      local trait_icon = 1
      if item.kind == "trait" then
         local trait = "base.some_trait"
         color = trait_color(trait)
         trait_icon = 5
      end

      local draw_name = item.kind == "feat"

      local new_x_offset, name_x_offset
      if draw_name then
         new_x_offset = 84 - 64
         name_x_offset = 30 - 64 - 20
      else
         new_x_offset = 70 - 64
         name_x_offset = 45 - 64 - 20
      end

      local quad = self.trait_icons.quad[trait_icon]
      if quad then
         Draw.image_region(self.trait_icons.image, quad, x + name_x_offset, y - 4, nil, nil, {255, 255, 255})
      end

      UiList.draw_item_text(l, text, i, item, x + new_x_offset, y, x_offset)

      if draw_name then
         Draw.text("(Trait name.)", x + 186, y + 2, color, {0, 0, 0})
      end
   end
   --------------------
end

function FeatsMenu:draw()
   self.win:draw()

   Ui.draw_topic("trait.window.name", self.x + 46, self.y + 36)
   -- UNUSED trait.window.level
   Ui.draw_topic("trait.window.detail", self.x + 255, self.y + 36)
   Draw.image_region(self.inventory_icon.image, self.inventory_icon.quad, self.x + 46, self.y - 16)
   Draw.image_region(self.deco.image, self.deco.quad["a"], self.x + self.width - 56, self.y + self.height - 198)
   Draw.image_region(self.deco.image, self.deco.quad["b"], self.x, self.y)
   Draw.image_region(self.deco.image, self.deco.quad["c"], self.x + self.width - 108, self.y)
   Draw.image_region(self.deco.image, self.deco.quad["d"], self.x, self.y + self.height - 70)

   self.pages:draw()

   local is_player = true
   local text
   if is_player then
      text = "ui.feat.you_can_aquire" .. " " .. tostring(5)
   else
      text = "ui.feat.your_trait" .. " " .. "name"
   end

   Ui.draw_note(text, self.x, self.y, self.width, self.height, 50)
end

function FeatsMenu:update()
   self.win:update()
   self.pages:update()
end

return FeatsMenu
