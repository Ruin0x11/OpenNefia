local Draw = require("api.Draw")
local Ui = require("api.Ui")

local IUiLayer = require("api.gui.IUiLayer")
local UiPagedList = require("api.gui.UiPagedList")
local UiActionList = require("api.gui.UiActionList")
local UiWindow = require("api.gui.UiWindow")

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

function FeatsMenu:init(chara_make)
   self.x, self.y, self.width, self.height = Ui.params_centered(730, 430)

   if chara_make then
      self.y = self.y + 15
   end

   self.win = UiWindow:new("ui.feat.title", self.x, self.y, self.width, self.height, true, "key help", 55, 40)

   self.inventory_icon = make_inventory_icon()
   self.deco = make_deco()

   self.data = {
      { kind = "feat", value = 10 },
      { kind = "blank", value = 1 },
      { kind = "feat", value = 10000 },
      { kind = "trait", value = 10000 },
   }

   local alist = UiActionList:new(self.x + 64, self.y + 66, self.data, 23)
   self.pages = UiPagedList:new(alist, 15)

   -------------------- WARNING this will bug.
   local super = UiActionList.draw_select_key
   self.pages.draw_select_key = function(l, i, item, key_name, x, y)
      if item.kind ~= "feat" then
         return
      end
      if i % 2 then -- i % 2 == 0
         Draw.filled_rect(x - 7, y, 640, 18, {12, 14, 16, 16})
      end
      if item.value >= 10000 then
         return
      end

      super(l, key_name, x, y)
   end

   super = UiActionList.draw_item_text
   self.pages.draw_item_text = function(l, selected, text, i, item, x, y, x_offset)
      if item.value < 10 then
         super(l, selected, text, i, item, x, y, x_offset)
         return
      end

      local color = {10, 10, 10}
      local trait_icon = "first"
      if item.kind == "trait" then
         local trait = "base.some_trait"
         color = trait_color(trait)
         trait_icon = "second"
      end

      local draw_name = item.kind == "feat"

      local new_x_offset, name_x_offset
      if draw_name then
         new_x_offset = 84 - 64
         name_x_offset = 30 - 64
      else
         new_x_offset = 70 - 64
         name_x_offset = 45 - 64
      end
      Draw.image_region(self.trait_icons, self.quad[trait_icon], x + name_x_offset, y - 5)

      super(l, selected, text, i, item, x + new_x_offset, y, x_offset)

      if draw_name then
         Draw.text("(Trait name.)", x + 206, y + 2, color)
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
