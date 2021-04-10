local Draw = require("api.Draw")
local I18N = require("api.I18N")
local ISettable = require("api.gui.ISettable")
local IUiElement = require("api.gui.IUiElement")
local Ui = require("api.Ui")
local UiTheme = require("api.gui.UiTheme")
local Skill = require("mod.elona_sys.api.Skill")

local data = require("internal.data")

local UiRaceInfo = class.class("UiRaceInfo", {IUiElement, ISettable})

function UiRaceInfo:init(race)
   self:set_data(race)
end

-- @tparam {proto=base.race,name=string,desc=string} race
function UiRaceInfo:set_data(race)
   self.race = race or self.race

   Draw.set_font(14) -- 14 - en * 2
   local _, wrapped = Draw.wrap_text(self.race.desc,
                                     Draw.text_width(" ") * 60) -- 60 + en * 2
   self.wrapped = wrapped
end

function UiRaceInfo:relayout(x, y)
   self.x = x
   self.y = y
   self.t = UiTheme.load(self)
end

function UiRaceInfo:update()
end

local function skill_info(level)
   local proficiency = 0
   local color = {120, 120, 120}

   if level > 13 then
      proficiency = 1
      color = {0, 0, 200}
   elseif level > 11 then
      proficiency = 2
      color = {0, 0, 200}
   elseif level > 9 then
      color = {0, 0, 150}
      proficiency = 3
   elseif level > 7 then
      proficiency = 4
      color = {0, 0, 150}
   elseif level > 5 then
      proficiency = 5
      color = {0, 0, 0}
   elseif level > 3 then
      proficiency = 6
      color = {150, 0, 0}
   elseif level > 0 then
      proficiency = 7
      color = {200, 0, 0}
   end

   return color, I18N.get("chara_make.select_race.race_info.attribute_bonus._" .. proficiency)
end

local ATTRIBUTES = {
   "elona.stat_strength",
   "elona.stat_constitution",
   "elona.stat_dexterity",
   "elona.stat_perception",
   "elona.stat_learning",
   "elona.stat_will",
   "elona.stat_magic",
   "elona.stat_charisma",
}

local function right_pad(str, amount)
   local len = utf8.wide_len(str)
   local count = math.max(amount - len, 0)
   return str .. string.rep(" ", count)
end

function UiRaceInfo:draw()
   -- >>>>>>>> shade2/chara.hsp:1109 	color 0,0,0:fontSize 14 ..
   Draw.set_font(14) -- 14 - en * 2

   for i, line in ipairs(self.wrapped) do
      Draw.text(line, self.x + 230 - 20, self.y + 62 + (i - 1) * Draw.text_height(), {0, 0, 0})
   end

   Ui.draw_topic("chara_make.select_race.race_info.attribute_bonus.text", self.x + 200, self.y + 166)

   local ty = 166 + 34

   Draw.set_font(14) -- 14 - en * 2

   for i=0,2 do
      for j=0,2 do
         if i == 2 and j == 2 then
            break
         end

         local skill_id = ATTRIBUTES[i * 3 + j + 1]
         local skill_name = utf8.wide_sub(I18N.localize("base.skill", skill_id, "name"), 0, 2)
         local skill_level = self.race.proto.skills[skill_id] or 0
         local text_color, proficiency = skill_info(skill_level)
         local skill_text = ("%s: %s"):format(skill_name, proficiency)

         self.t.base.skill_icons:draw_region(
            Ui.skill_icon(skill_id),
            j * 150 + self.x + 200 + 13,
            self.y + ty + 7,
            nil,
            nil,
            {255, 255, 255},
            true)
         Draw.text(skill_text,
                   j * 150 + self.x + 200 + 32,
                   self.y + ty,
                   text_color)
      end
      ty = ty + Draw.text_height() + 2
   end

   Ui.draw_topic("chara_make.select_race.race_info.trained_skill.text",
                 self.x + 200,
                 self.y + 260)

   Draw.set_font(14)

   local pad_size = 16
   if I18N.is_fullwidth() then
      pad_size = 12
   end

   local skill_count = 0
   local skill_text = I18N.get("chara_make.select_race.race_info.trained_skill.proficient_in")
   skill_text = right_pad(skill_text, pad_size)

   for _, proto in Skill.iter_weapon_proficiencies() do
      local skill_name = I18N.localize("base.skill", proto._id, "name")
      local skill_level = self.race.proto.skills[proto._id] or 0
      if skill_level > 0 then
         if skill_count == 0 then
            skill_text = skill_text .. skill_name
         else
            skill_text = skill_text .. "," .. skill_name
         end
         skill_count = skill_count + 1
      end
   end

   local rows = 0

   if skill_count > 0 then
      self.t.base.skill_icons:draw_region(
         1,
         self.x + 200 + 13,
         self.y + 260 + 34 + 6,
         nil,
         nil,
         {255, 255, 255},
         true)
      Draw.text(skill_text, self.x + 200 + 32, self.y + 260 + 34, {0, 0, 0})
      rows = 1
   end

   for _, proto in Skill.iter_normal_skills() do
      local skill_level = self.race.proto.skills[proto._id] or 0
      if skill_level > 0 then
         local skill_name = I18N.localize("base.skill", proto._id, "name")
         skill_name = right_pad(skill_name, pad_size)

         self.t.base.skill_icons:draw_region(
            Ui.skill_icon(proto.related_skill),
            self.x + 200 + 13,
            self.y + 260 + 34 + rows*14 + 6,
            nil,
            nil,
            {255, 255, 255},
            true)

         local skill_desc = I18N.localize("base.skill", proto._id, "description")

         if utf8.wide_len(skill_desc) > 43 then
            skill_desc = utf8.wide_sub(skill_desc, 0, 40) .. "..."
         end

         Draw.text(skill_name .. skill_desc,
                   self.x + 200 + 32,
                   self.y + 260 + rows*14 + 34,
                   {0, 0, 0})

         rows = rows + 1
      end
   end
   -- <<<<<<<< shade2/chara.hsp:1179 	loop ..
end

return UiRaceInfo
