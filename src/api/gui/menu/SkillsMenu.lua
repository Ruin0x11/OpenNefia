local Draw = require("api.Draw")
local Ui = require("api.Ui")

local IUiLayer = require("api.gui.IUiLayer")
local UiWindow = require("api.gui.UiWindow")
local UiList = require("api.gui.UiList")
local KeyHandler = require("api.gui.KeyHandler")

local SkillsMenu = class("SkillsMenu", IUiLayer)

SkillsMenu:delegate("pages", {"page", "page_max"})
SkillsMenu:delegate("keys", {"focus"})

local UiListExt = function(skills_menu)
   local E = {}

   function E:draw_select_key(i, item, key_name, x, y)
      if item.kind == "header" then
         skills_menu.item_count = 1
         return
      end
      skills_menu.item_count = skills_menu.item_count + 1

      local new_x, new_dx
      if item.kind == "skill" then
         new_x = -6
         new_dx = 18
      else
         new_x = 12
         new_dx = 0
      end

      if skills_menu.item_count % 2 == 0 then
         Draw.filled_rect(x + new_x, y + 2, 595 + new_dx, 18, {12, 14, 16, 16})
      end

      if item.kind == "skill" then
         return
      end

      UiList.draw_select_key(self, i, item, key_name, x, y)
   end

   function E:draw_item_text(text, i, item, x, y, x_offset)
      if item.kind == "header" then
         Draw.set_font(12, "bold") -- 12 + sizefix - en * 2
         UiList.draw_item_text(self, text, i, item, x + 30, y, x_offset)
      else
         Draw.set_font(14) -- 14 - en * 2

         local is_basic = false
         local icon
         if is_basic then
            icon = "STR"
         else
            icon = "STR"
         end

         Draw.image_region(skills_menu.skill_icons, skills_menu.quad[icon], x - 20, y + 9, nil, nil, {255, 255, 255}, true)

         local new_x
         if is_basic then
            new_x = -4
         else
            new_x = 26
         end

         local skill_name = "The skill"
         local is_tracked = true
         if is_tracked then
            skill_name = "*" .. skill_name
         end

         UiList.draw_item_text(self, text, i, item, x + new_x, y + 2 - 1, x_offset)

         local skill_power = "1.4(99%)"
         Draw.text(skill_power, x + 222 - Draw.text_width(skill_power), y + 2)

         local skill_desc = "A description goes here."
         Draw.text(skill_desc, x + 272, y + 2)

         local show_train_cost = false
         local is_training = false
         local has_enchantment = true
         if show_train_cost then
            local train_cost = "10p"
            Draw.text(train_cost, x + 264 - Draw.text_length(train_cost), y + 2)
         elseif has_enchantment then
            local enchantment_level = "[****+]"
            Draw.text(enchantment_level, x + 224, y + 2)
         end
      end
   end

   return E
end

function SkillsMenu:init(show_bonus)
   self.x, self.y, self.width, self.height = Ui.params_centered(700, 400)
   self.y = self.y - 10

   self.show_bonus = show_bonus or true

   self.win = Draw.load_image("graphic/ie_sheet.bmp")

   self.item_count = 0

   local skills = table.of(function(i)
         return
            { name = "skill" .. i, kind = "skill" }
                           end,
      100)
   self.pages = UiList:new_paged(self.x + 58, self.y + 64, skills, 16)

   -------------------- dupe
   self.skill_icons = Draw.load_image("graphic/temp/skill_icons.bmp")
   local skills = {
      "STR",
   }

   local iw = self.skill_icons:getWidth()
   local ih = self.skill_icons:getHeight()

   self.quad = {}
   for i, s in ipairs(skills) do
      self.quad[s] = love.graphics.newQuad(i * 48, 0, 48, 48, iw, ih)
   end
   --------------------

   table.merge(self.pages, UiListExt(self))

   self.keys = KeyHandler:new()
   self.keys:forward_to(self.pages)
end

function SkillsMenu:relayout()
   self.pages:relayout()
end

function SkillsMenu:draw()
   Draw.image(self.win, self.x, self.y)
   if self.show_bonus then
      Draw.set_font(12, "bold") -- 12 + sizefix - en * 2
      local tips = "You can spend " .. 10 .. " bonus points."
      Draw.text(tips, self.x + self.width - Draw.text_width(tips) - 140, self.y + self.height - 24 - self.height % 8)
   end

   local page_str = string.format("Page.%d/%d", self.page, self.page_max)
   Draw.text(page_str, self.x + self.width - Draw.text_width(page_str) - 40, self.y + self.height - 24 - self.height % 8)

   Ui.draw_topic("skill.name", self.x + 28, self.y + 36)
   Ui.draw_topic("skill.level (skill.potential)", self.x + 182, self.y + 36)
   Ui.draw_topic("skill.detail", self.x + 320, self.y + 36)

   self.pages:draw()
end

function SkillsMenu:update()
   self.pages:update()
end

return SkillsMenu
