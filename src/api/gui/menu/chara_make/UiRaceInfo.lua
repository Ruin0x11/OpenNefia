local Draw = require("api.Draw")
local Ui = require("api.Ui")
local IUiElement = require("api.gui.IUiElement")
local ISettable = require("api.gui.ISettable")

local UiRaceInfo = class("UiRaceInfo", {IUiElement, ISettable})

function UiRaceInfo:init(race)
   self.race = race

   self.skill_icons = Draw.load_image("graphic/temp/skill_icons.bmp")
   local skills = {
      "base.strength",
   }

   local iw = self.skill_icons:getWidth()
   local ih = self.skill_icons:getHeight()

   self.quad = {}
   for i, s in ipairs(skills) do
      self.quad[s] = love.graphics.newQuad(i * 48, 0, 48, 48, iw, ih)
   end

   self:set_data()
end

function UiRaceInfo:set_data(race)
   self.race = race or self.race
end

function UiRaceInfo:relayout(x, y)
   self.x = x
   self.y = y
end

function UiRaceInfo:update()
end

local function skill_color(level)
   if level > 13 then
      return {0, 0, 200}
   elseif level > 11 then
      return {0, 0, 200}
   elseif level > 9 then
      return {0, 0, 150}
   elseif level > 7 then
      return {0, 0, 150}
   elseif level > 5 then
      return {0, 0, 0}
   elseif level > 3 then
      return {150, 0, 0}
   elseif level > 0 then
      return {200, 0, 0}
   else
      return {120, 120, 120}
   end
end

function UiRaceInfo:draw()
   Draw.set_font(14) -- 14 - en * 2

   local text = "(race description.) " .. self.race
   Draw.text(text, self.x + 230, self.y + 62, {0, 0, 0})

   Ui.draw_topic("chara_make.select_race.race_info.bonus.text", self.x + 200, self.y + 166)

   local ty = 166 + 34

   -- TODO remove
   Draw.set_font(14) -- 14 - en * 2

   for i=0,2 do
      for j=0,2 do
         if i == 2 and j == 2 then
            break
         end

         local skill_name = "base.strength"
         local skill_level = 15
         local skill_text = "Strength" .. ": " .. "Superb"

         local text_color = skill_color(skill_level)

         Draw.image_region(
            self.skill_icons,
            self.quad[skill_name],
            j * 150 + self.x + 200 + 13,
            self.y + ty + 7,
            nil,
            nil,
            {255, 255, 255},
            true
         )
         Draw.text(skill_text,
                   j * 150 + self.x + 200 + 32,
                   self.y + ty,
                   text_color)
      end
      ty = ty + Draw.text_height() + 2
   end

   Ui.draw_topic("chara_make.select_race.race_info.skill.text",
                 self.x + 200,
                 self.y + 260)

   Draw.set_font(14)

   local skill_count = 0
   local skill_text

   -- TODO
   for i=0,3 do
      local skill_name = "skill"
      if not skill_text then
         skill_text = skill_name
      else
         skill_text = skill_text .. "," .. skill_name
      end
   end

   local rows = 0

   if skill_text then
      Draw.image_region(
         self.skill_icons,
         self.quad["base.strength"],
         self.x + 200 + 13,
         self.y + 260 + 34 + 6,
         nil,
         nil,
         {255, 255, 255},
         true)
      Draw.text(skill_text, self.x + 200 + 32, self.y + 260 + 34, {0, 0, 0})
      rows = 1
   end

   -- TODO
   for i=0,8 do
      local skill_name = "Cooking"
      local related_skill = "base.strength"

      Draw.image_region(
         self.skill_icons,
         self.quad[related_skill],
         self.x + 200 + 13,
         self.y + 260 + 34 + rows*14 + 6,
         nil,
         nil,
         {255, 255, 255},
         true)

      local skill_desc = "(description.)"

      if false then
         if #skill_desc > 45 then
            skill_desc = string.sub(skill_desc, 1, 43) .. "..."
         end
      end

      Draw.text(skill_name .. skill_desc,
                self.x + 200 + 32,
                self.y + 260 + rows*14 + 34,
                {0, 0, 0})

      rows = rows + 1
   end
end

return UiRaceInfo
