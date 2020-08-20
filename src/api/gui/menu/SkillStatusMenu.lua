local Draw = require("api.Draw")
local Ui = require("api.Ui")
local config = require("internal.config")
local Skill = require("mod.elona_sys.api.Skill")
local I18N = require("api.I18N")
local data = require("internal.data")
local Enchantment = require("mod.elona.api.Enchantment")
local Calc = require("mod.elona.api.Calc")
local save = require("internal.global.save")
local Gui = require("api.Gui")
local IPaged = require("api.gui.IPaged")

local IUiLayer = require("api.gui.IUiLayer")
local UiTheme = require("api.gui.UiTheme")
local UiList = require("api.gui.UiList")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")

local SkillStatusMenu = class.class("SkillStatusMenu", { IUiLayer, IPaged })

SkillStatusMenu:delegate("pages", IPaged)
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

      if item.kind == "header" then
         return
      end

      UiList.draw_select_key(self, item, i, key_name, x, y)
   end

   function E:get_item_text(entry)
      return entry.name
   end

   function E:draw_item_text(text, item, i, x, y, x_offset)
      if item.kind == "header" then
         Draw.set_font(12, "bold") -- 12 + sizefix - en * 2
         UiList.draw_item_text(self, text, item, i, x + 30, y, x_offset)
      else
         Draw.set_font(14) -- 14 - en * 2

         local icon = item.icon

         skills_menu.t.base.skill_icons:draw_region(icon, x - 46, y + 9, nil, nil, {255, 255, 255}, true)

         UiList.draw_item_text(self, text, item, i, x, y + 2 - 1, x_offset)

         Draw.text(item.power, x + 192 - Draw.text_width(item.power), y + 2)

         if item.desc then
            Draw.text(item.desc, x + 252, y + 2)
         end

         if item.detail then
            if item.right_align then
               Draw.text(item.detail, x + 264 - Draw.text_width(item.detail), y + 2)
            else
               Draw.text(item.detail, x + 194, y + 2)
            end
         end
      end
   end

   return E
end

function SkillStatusMenu.build_list(chara, mode)
   -- >>>>>>>> shade2/command.hsp:2370 	if dbg_showAllSkill:if (csCtrl!2)&(csCtrl!3)&(csC ..
   local list = {}

   local right_align = mode == "trainer_train" or mode == "trainer_learn"

   list[#list+1] = { name = I18N.get("ui.chara_sheet.category.skill"), kind = "header", ordering = 100000 }

   -- >>>>>>>> shade2/command.hsp:2654 				p(1)=limit(sdata(list(0,p),cc)/resistGrade,0,6 ..
   local skill_power = function(skill_id)
      local base_level = chara:base_skill_level(skill_id)
      local level = chara:skill_level(skill_id)
      local exp = chara:skill_experience(skill_id)
      local s = ("%01.03f"):format(base_level + exp / 1000)

      if config["base.debug_show_all_skills"] then
         if level ~= base_level then
            local diff = level - base_level
            if diff >= 0 then
               s = s .. "+" .. tostring(diff)
            else
               s = s .. tostring(diff)
            end
         end
      end

      s = s .. ("(%s%%)"):format(chara:skill_potential(skill_id))

      return s
   end

   local resist_power = function(skill_id)
      return ""
   end
   -- <<<<<<<< shade2/command.hsp:2664 				s+="("+sGrowth(i,cc)+"%)" ..

   -- >>>>>>>> shade2/command.hsp:2669 			if (csCtrl=2)or(csCtrl=3){ ..
   local skill_detail = function(skill_id)
      local s = ""

      if mode == "trainer_train" then
         s = ("%sp "):format(Calc.calc_train_cost())
      elseif mode == "trainer_learn" then
         s = ("%sp "):format(Calc.calc_learn_cost())
      else
         local base_level = chara:base_skill_level(skill_id)
         local level = chara:skill_level(skill_id)

         if level ~= base_level then
            local grade = (level - base_level) / 5
            s = Enchantment.power_text(grade)
         end
      end

      return s
   end

   local resist_detail = function(skill_id)
   end
   -- <<<<<<<< shade2/command.hsp:2679 				} ..

   if mode == "trainer_learn" then
      error("TODO")
   else
      for _, skill_entry in Skill.iter_normal_skills() do
         list[#list+1] = {
            _id = skill_entry._id,
            name = I18N.get("ability." .. skill_entry._id .. ".name"),
            desc = I18N.get("ability." .. skill_entry._id .. ".description"),
            power = skill_power(skill_entry._id),
            detail = skill_detail(skill_entry._id),
            kind = "skill",
            icon = Ui.skill_icon(skill_entry.related_skill),
            right_align = right_align,
            ordering = (skill_entry.elona_id or 0) + 110000
         }
      end
   end

   list[#list+1] = { name = I18N.get("ui.chara_sheet.category.weapon_proficiency"), kind = "header", ordering = 200000 }

   for _, skill_entry in Skill.iter_weapon_proficiencies() do
      local add = true

      if mode == "trainer_learn" then
         if chara:has_skill(skill_entry._id) or skill_entry.related_skill == nil then
            add = false
         end
      end

      if add then
         list[#list+1] = {
            _id = skill_entry._id,
            name = I18N.get("ability." .. skill_entry._id .. ".name"),
            desc = I18N.get("ability." .. skill_entry._id .. ".description"),
            kind = "skill",
            power = skill_power(skill_entry._id),
            detail = skill_detail(skill_entry._id),
            icon = Ui.skill_icon(skill_entry.related_skill),
            right_align = right_align,
            ordering = (skill_entry.elona_id or 0) + 210000
         }
      end
   end

   if mode == "chara_status" or mode == "informer" then
      list[#list+1] = { name = I18N.get("ui.chara_sheet.category.resistance"), kind = "header", ordering = 300000 }
      for _, element_entry in Skill.iter_resistances() do
         if chara:has_resist(element_entry._id) then
            list[#list+1] = {
               _id = element_entry._id,
               name = I18N.get("ui.chara_sheet.skill.resist", I18N.capitalize(I18N.get("element." .. element_entry._id .. ".name"))),
               desc = I18N.get("element." .. element_entry._id .. ".description"),
               kind = "resistance",
               power = resist_power(element_entry._id),
               detail = resist_detail(element_entry._id),
               icon = 11,
               right_align = right_align,
               ordering = (element_entry.elona_id or 0) + 310000
            }
         end
      end
   end

   local tracked = save.base.tracked_skill_ids or {}
   for _, entry in ipairs(list) do
      if tracked[entry._id] then
         entry.name = "*" .. entry.name
      end
   end

   local sort = function(a, b)
      if a.ordering == b.ordering then
         return a.name < b.name
      end

      return a.ordering < b.ordering
   end

   table.sort(list, sort)

   return list
   -- <<<<<<<< shade2/command.hsp:2415 	gosub *sort_list ..
end

function SkillStatusMenu:init(chara, mode, opts)
   opts = opts or {}
   self.chara = chara
   self.width = 700
   self.height = 400
   self.mode = mode or "chara_status"

   self.show_bonus = opts.show_bonus or true

   self.item_count = 0

   local skills = SkillStatusMenu.build_list(chara, self.mode)
   self.pages = UiList:new_paged(skills, 16)

   table.merge(self.pages, UiListExt(self))

   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
   self.input:bind_keys(self:make_keymap())
end

function SkillStatusMenu:make_keymap()
   return {
      escape = function() self.canceled = true end,
      cancel = function() self.canceled = true end,
      mode2 = function()
         local entry = self.pages:selected_item()
         -- TODO track resistances
         if entry.kind == "skill" then
            if save.base.tracked_skill_ids[entry._id] then
               save.base.tracked_skill_ids[entry._id] = nil
               entry.name = I18N.get("ability." .. entry._id .. ".name")
            else
               save.base.tracked_skill_ids[entry._id] = true
               entry.name = "*" .. I18N.get("ability." .. entry._id .. ".name")
            end
            Gui.play_sound("base.ok1")
         end
      end,
   }
end

function SkillStatusMenu:relayout(x, y)
   self.x = x
   self.y = y
   self.t = UiTheme.load(self)

   self.pages:relayout(self.x + 58, self.y + 64)
end

function SkillStatusMenu:draw()
   self.t.base.ie_sheet:draw(self.x, self.y)
   Draw.set_color(0, 0, 0)
   Draw.set_font(12, "bold") -- 12 + sizefix - en * 2
   if self.show_bonus then
      local tips = "You can spend " .. 10 .. " bonus points."
      Draw.text(tips, self.x + self.width - Draw.text_width(tips) - 140, self.y + self.height - 24 - self.height % 8)
   end

   Ui.draw_topic("ui.chara_sheet.skill.name", self.x + 28, self.y + 36)
   Ui.draw_topic("ui.chara_sheet.skill.level", self.x + 182, self.y + 36)
   Ui.draw_topic("ui.chara_sheet.skill.detail", self.x + 320, self.y + 36)

   self.pages:draw()
end

function SkillStatusMenu:update()
   local result = self.pages:update()

   if result == "chosen" then
      local entry = self.pages:selected_item()
      if entry.kind ~= "header" then
         return entry
      end
   end

   if self.canceled then
      return nil, "canceled"
   end
end

function SkillStatusMenu:on_hotload_layer()
   table.merge(self.pages, UiListExt(self))
end

return SkillStatusMenu
