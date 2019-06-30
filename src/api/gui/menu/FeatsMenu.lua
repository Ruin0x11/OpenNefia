local Draw = require("api.Draw")
local Ui = require("api.Ui")

local IUiLayer = require("api.gui.IUiLayer")
local UiList = require("api.gui.UiList")
local UiWindow = require("api.gui.UiWindow")
local UiList = require("api.gui.UiList")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")

local FeatsMenu = class.class("FeatsMenu", IUiLayer)

FeatsMenu:delegate("pages", "chosen")
FeatsMenu:delegate("input", IInput)

local function trait_color(trait)
   if true then
      return {0, 0, 200}
   elseif false then
      return {200, 0, 0}
   end

   return {10, 10, 10}
end

local function trait_icon(trait)
   return 5
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

local UiListExt = function(feats_menu)
   local E = {}

   function E:get_item_text(item)
      return item.text
   end
   function E:can_choose(item)
      return item.type == "can_acquire"
   end
   function E:draw_select_key(item, i, key_name, x, y)
      if item.type == "header" then
         return
      end
      if i % 2 == 0 then
         Draw.filled_rect(x - 1, y, 640, 18, {12, 14, 16, 16})
      end
      if item.type ~= "can_acquire" then
         return
      end

      UiList.draw_select_key(self, item, i, key_name, x, y)
   end

   function E:draw_item_text(text, item, i, x, y, x_offset)
      if item.type == "header" then
         UiList.draw_item_text(self, text, item, i, x, y, x_offset)
         return
      end

      local color = trait_color(item.trait)
      local trait_icon = trait_icon(item.trait)

      local draw_name = item.type == "can_acquire"

      local new_x_offset, name_x_offset
      if draw_name then
         new_x_offset = 84 - 64
         name_x_offset = 30 - 64 - 20
      else
         new_x_offset = 70 - 64
         name_x_offset = 45 - 64 - 20
      end

      local quad = feats_menu.trait_icons.quad[trait_icon]
      if quad then
         Draw.image_region(feats_menu.trait_icons.image, quad, x + name_x_offset, y - 4, nil, nil, {255, 255, 255})
      end

      UiList.draw_item_text(self, text, item, i, x + new_x_offset, y, x_offset)

      if draw_name then
         Draw.text("(Trait name.)", x + 186, y + 2, color)
      end
   end
   --------------------

   return E
end

function FeatsMenu:init()
   self.chara_make = false

   self.win = UiWindow:new("ui.feat.title", true, "key help", 55, 40)

   self.inventory_icon = make_inventory_icon()
   self.deco = make_deco()
   self.trait_icons = make_trait_icons()

   self.data = table.flatten({
      {{ text = "Available feats", type = "header" }},
      table.of({ text = "Trait name", trait = "base.sometrait", type = "can_acquire" }, 20),
      {{ text = "Feats and traits", type = "header"}},
      {{ text = "Your body is complicated.", trait = "base.complicated", type = "description" }},
      table.of({ text = "Your trait is this.", trait = "base.othertrait", type = "description" }, 20),
   })

   self.pages = UiList:new_paged(self.data, 15)
   table.merge(self.pages, UiListExt(self))

   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
   self.input:bind_keys {
      shift = function() self.canceled = true end
   }
end

function FeatsMenu:relayout(x, y)
   self.width = 730
   self.height = 430
   self.x, self.y = Ui.params_centered(self.width, self.height)

   if self.chara_make then
      self.y = self.y + 15
   end

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.pages:relayout(self.x + 58, self.y + 66)
   self.win:set_pages(self.pages)
end

function FeatsMenu:get_result()
   return {}
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
      text = "ui.feat.you_can_acquire" .. " " .. tostring(5)
   else
      text = "ui.feat.your_trait" .. " " .. "name"
   end

   Ui.draw_note(text, self.x, self.y, self.width, self.height, 50)
end

function FeatsMenu:update()
   if self.canceled then
      return nil, "canceled"
   end

   if self.pages.changed then
      self.win:set_pages(self.pages)
   elseif self.pages.chosen then
   end

   self.win:update()
   self.pages:update()
end

return FeatsMenu
