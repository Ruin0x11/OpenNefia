local Const = require("api.Const")
--- @classmod ICharaSkills
local Enum = require("api.Enum")

local ICharaSkills = class.interface("ICharaSkills")
local data = require("internal.data")

function ICharaSkills:init()
   self.skills = {}

   if self.proto.skills then
      for _, skill_id in ipairs(self.proto.skills) do
         local level = 1
         local potential = 100
         self:set_base_skill(skill_id, level, potential, 0)
      end
   end

   self.stat_adjusts = self.stat_adjusts or {}
end

function ICharaSkills:stat_adjustment(skill)
   return self.stat_adjusts[skill] or 0
end

function ICharaSkills:set_stat_adjustment(skill, adj)
   if adj == 0 then
      adj = nil
   end
   if type(adj) == "number" then
      adj = math.floor(adj)
   end
   local skill_data = data["base.skill"]:ensure(skill)
   assert(skill_data.type == "stat", skill)
   self.stat_adjusts[skill] = adj
   self:refresh()
end

function ICharaSkills:add_stat_adjustment(skill, delta)
   self:set_stat_adjustment(skill, self:stat_adjustment(skill) + delta)
end

-- emulates attbFix
function ICharaSkills:on_refresh()
   for skill_id, adj in pairs(self.stat_adjusts) do
      if adj ~= 0 then
         if self.quality >= Enum.Quality.Good then
            local amt = math.floor(self:base_skill_level(skill_id) / 5)
            if adj < amt then
               adj = amt
            end
         end

         self:mod_skill_level(skill_id, adj, "add")

         if self:skill_level(skill_id) < 1 then
            self:mod_skill_level(skill_id, 1)
         end
      end
   end
end

function ICharaSkills:spell_stock(skill_id)
   local skill_entry = data["base.skill"]:ensure(skill_id)
   if skill_entry.type ~= "spell" then return 0 end
   return self.spell_stocks[skill_id] or 0
end

function ICharaSkills:set_spell_stock(skill_id, amount)
   local skill_entry = data["base.skill"]:ensure(skill_id)
   if skill_entry.type ~= "spell" then return end
   self.spell_stocks[skill_id] = amount
end

--- Obtains the character's original skill level, before applying buffs.
function ICharaSkills:base_skill_level(skill_id)
   data["base.skill"]:ensure(skill_id)
   return self.skills[skill_id] and self.skills[skill_id].level or 0
end

--- Obtains the character's skill level after applying buffs.
function ICharaSkills:skill_level(skill_id)
   data["base.skill"]:ensure(skill_id)
   local temp = self.temp["skills"]
   if not temp then
      return self:base_skill_level(skill_id)
   end
   local skill_entry = temp[skill_id]
   if not skill_entry then
      return self:base_skill_level(skill_id)
   end
   return skill_entry.level or 0
end

--- Returns true if the character knows a skill. If true, you can call
--- ICharaSkills:skill_level() and get back a non-zero level.
function ICharaSkills:has_skill(skill_id)
   return self:skill_level(skill_id) > 0
end

function ICharaSkills:has_base_skill(skill_id)
   return self:base_skill_level(skill_id) > 0
end

function ICharaSkills:skill_potential(skill_id)
   data["base.skill"]:ensure(skill_id)
   return self.skills[skill_id] and self.skills[skill_id].potential or 0
end

function ICharaSkills:skill_experience(skill_id)
   data["base.skill"]:ensure(skill_id)
   return self.skills[skill_id] and self.skills[skill_id].experience or 0
end

function ICharaSkills:mod_skill_level(skill_id, amount, op)
   data["base.skill"]:ensure(skill_id)
   if not self:has_skill(skill_id) then
      return
   end
   self.temp.skills = self.temp.skills or {}
   local result = self:mod("skills", { [skill_id] = { level = math.floor(amount) } }, op)
   local level = self.temp.skills[skill_id].level
   level = math.clamp(level, 0, Const.MAX_SKILL_LEVEL)
   self.temp.skills[skill_id].level = level
   return result
end

function ICharaSkills:mod_base_skill_level(skill_id, amount, op)
   data["base.skill"]:ensure(skill_id)
   if not self:has_skill(skill_id) then
      self:set_base_skill(skill_id, 1, 100, 0)
   end
   self.temp.skills = self.temp.skills or {}
   local result = self:mod_base("skills", { [skill_id] = { level = math.floor(amount) } }, op)
   local level = self.skills[skill_id].level
   level = math.clamp(level, 0, Const.MAX_SKILL_LEVEL)
   self.skills[skill_id].level = level
   return result
end

function ICharaSkills:mod_skill_potential(skill_id, amount, op)
   data["base.skill"]:ensure(skill_id)
   if not self:has_skill(skill_id) then
      self:set_base_skill(skill_id, 1, 100, 0)
   end
   self.temp.skills = self.temp.skills or {}
   local result = self:mod_base("skills", { [skill_id] = { potential = math.floor(amount) } }, op)
   local potential = self.skills[skill_id].potential
   potential = math.clamp(potential, 0, Const.MAX_SKILL_POTENTIAL)
   self.skills[skill_id].potential = potential
   return result
end

function ICharaSkills:mod_skill_experience(skill_id, amount, op)
   data["base.skill"]:ensure(skill_id)
   if not self:has_skill(skill_id) then
      self:set_base_skill(skill_id, 1, 100, 0)
   end
   self.temp.skills = self.temp.skills or {}
   local result = self:mod_base("skills", { [skill_id] = { experience = math.floor(amount) } }, op)
   local experience = self.skills[skill_id].experience
   experience = math.clamp(experience, 0, Const.MAX_SKILL_EXPERIENCE)
   self.skills[skill_id].experience = experience
   return result
end

function ICharaSkills:set_base_skill(skill_id, level, potential, experience)
   data["base.skill"]:ensure(skill_id)
   local s = self.skills[skill_id] or {}
   s.level = math.clamp(math.floor(level or s.level or 0), 0, Const.MAX_SKILL_LEVEL)
   s.potential = math.clamp(math.floor(potential or s.potential or 100), 0, Const.MAX_SKILL_POTENTIAL)
   s.experience = math.clamp(math.floor(experience or s.experience or 0), 0, Const.MAX_SKILL_EXPERIENCE)
   self.skills[skill_id] = s
end

return ICharaSkills
