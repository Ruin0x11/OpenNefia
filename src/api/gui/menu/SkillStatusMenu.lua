local Draw = require("api.Draw")
local Ui = require("api.Ui")

local IUiLayer = require("api.gui.IUiLayer")
local UiTheme = require("api.gui.UiTheme")
local UiList = require("api.gui.UiList")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")

local SkillStatusMenu = class.class("SkillStatusMenu", IUiLayer)

SkillStatusMenu:delegate("pages", {"page", "page_max"})
SkillStatusMenu:delegate("input", IInput)

local UiListExt = function(skills_menu)
   local E = {}

   function E:draw_select_key(item, i, key_name, x, y)
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

      UiList.draw_select_key(self, item, i, key_name, x, y)
   end

   function E:draw_item_text(text, item, i, x, y, x_offset)
      if item.kind == "header" then
         Draw.set_font(12, "bold") -- 12 + sizefix - en * 2
         UiList.draw_item_text(self, text, item, i, x + 30, y, x_offset)
      else
         Draw.set_font(14) -- 14 - en * 2

         local is_basic = false
         local icon
         if is_basic then
            icon = "STR"
         else
            icon = "STR"
         end

         skills_menu.t.base.skill_icons:draw_region(icon, x - 20, y + 9, nil, nil, {255, 255, 255}, true)

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

         UiList.draw_item_text(self, text, item, i, x + new_x, y + 2 - 1, x_offset)

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

function SkillStatusMenu:init(show_bonus)
   self.width = 700
   self.height = 400

   self.show_bonus = show_bonus or true

   self.item_count = 0

   local skills = table.of(function(i)
         return
            { name = "skill" .. i, kind = "skill" }
                           end,
      100)
   self.pages = UiList:new_paged(skills, 16)

   table.merge(self.pages, UiListExt(self))

   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
end

function SkillStatusMenu:relayout()
   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.y = self.y - 10
   self.t = UiTheme.load(self)

   self.pages:relayout(self.x + 58, self.y + 64)
end

function SkillStatusMenu:draw()
   self.t.base.ie_sheet:draw(self.x, self.y)
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

function SkillStatusMenu:update()
   self.pages:update()
end

return SkillStatusMenu
