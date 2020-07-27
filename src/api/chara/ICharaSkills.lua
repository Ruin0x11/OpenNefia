--- @classmod ICharaSkills
local Enum = require("api.Enum")

local ICharaSkills = class.interface("ICharaSkills")
local data = require("internal.data")

local MAX_LEVEL = 2000
local MAX_POTENTIAL = 400
local MAX_EXPERIENCE = 1000

function ICharaSkills:init()
   self.skills = self.skills or {}

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

local function generate_methods(iface, name, ty)
   local subfields = { "level", "potential", "experience" }

   local get_id = function(id)
      return ("%s:%s"):format(ty, id)
   end

   iface["has_" .. name] = function(self, skill)
      data[ty]:ensure(skill)
      skill = get_id(skill)
      -- This checks base, not temporary
      return self.skills[skill] and self.skills[skill].level > 0
   end

   iface["gain_" .. name] = function(self, skill, level)
      data[ty]:ensure(skill)
      skill = get_id(skill)
      self.skills[skill] = self.skills[skill] or
         {
            level = 0,
            potential = 0,
            experience = 0,
         }

      if self.skills[skill].level == 0 then
         level = level or 1
         level = math.clamp(level, 1, MAX_LEVEL)
         self.skills[skill].level = level
      end
   end

   iface["set_base_" .. name] = function(self, skill, level, potential, experience)
      data[ty]:ensure(skill)
      if not self["has_" .. name](self, skill) then
         self["gain_" .. name](self, skill)
      end

      skill = get_id(skill)
      local s = self.skills[skill]
      s.level = math.clamp(math.floor(level or s.level), 0, MAX_LEVEL)
      s.potential = math.floor(potential or s.potential)
      s.experience = math.floor(experience or s.experience)
   end

   for _, subfield in ipairs(subfields) do
      -- self:skill_level(skill)
      iface[name .. "_" .. subfield] = function(self, skill)
         data[ty]:ensure(skill)
         skill = get_id(skill)
         local it = self:calc("skills")[skill]
         if not it or not it[subfield] then
            it = self.skills[skill]
         end
         if not it then return 0 end
         return it[subfield] or 0
      end
      -- self:base_skill_level(skill)
      iface["base_" .. name .. "_" .. subfield] = function(self, skill)
         data[ty]:ensure(skill)
         skill = get_id(skill)
         local it = self.skills[skill]
         if not it then return 0 end
         return it[subfield] or 0
      end
      -- self:mod_skill_level(skill, level, "add")
      iface["mod_" .. name .. "_" .. subfield] = function(self, skill, amount, op)
         data[ty]:ensure(skill)
         if not self["has_" .. name](self, skill) then
            return
         end
         skill = get_id(skill)
         local result = self:mod("skills", { [skill] = { [subfield] = math.floor(amount) } }, op)
         local level = self.temp.skills[skill][subfield]
         level = math.clamp(level, 0, MAX_LEVEL)
         self.temp.skills[skill][subfield] = level
         return result
      end
      -- self:mod_base_skill_level(skill, level, "add")
      iface["mod_base_" .. name .. "_" .. subfield] = function(self, skill, amount, op)
         data[ty]:ensure(skill)
         if not self["has_" .. name](self, skill) then
            self["gain_" .. name](self, skill)
         end
         skill = get_id(skill)
         local result = self:mod_base("skills", { [skill] = { [subfield] = math.floor(amount) } }, op)
         local level = self.skills[skill][subfield]
         level = math.clamp(level, 0, MAX_LEVEL)
         self.skills[skill][subfield] = level
         return result
      end
   end
end

-- TODO: keep eveything in one "skills" field, to prevent needing to
-- distinguish by type, and instead prefix each ID with the type name
generate_methods(ICharaSkills, "resist", "base.element")

--- Obtains the character's original skill level, before applying buffs.
function ICharaSkills:base_skill_level(skill_id)
   data["base.skill"]:ensure(skill_id)
   skill_id = ("base.skill:%s"):format(skill_id)
   return self.skills[skill_id] and self.skills[skill_id].level or 0
end

--- Obtains the character's skill level after applying buffs.
function ICharaSkills:skill_level(skill_id)
   data["base.skill"]:ensure(skill_id)
   local temp = self.temp["skills"]
   if not temp then
      return self:base_skill_level(skill_id)
   end
   local skill_entry = temp["base.skill:" .. skill_id]
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

function ICharaSkills:skill_potential(skill_id)
   data["base.skill"]:ensure(skill_id)
   skill_id = ("base.skill:%s"):format(skill_id)
   return self.skills[skill_id] and self.skills[skill_id].potential or 0
end

function ICharaSkills:skill_experience(skill_id)
   data["base.skill"]:ensure(skill_id)
   skill_id = ("base.skill:%s"):format(skill_id)
   return self.skills[skill_id] and self.skills[skill_id].experience or 0
end

function ICharaSkills:mod_skill_level(skill_id, amount, op)
   data["base.skill"]:ensure(skill_id)
   if not self:has_skill(skill_id) then
      return
   end
   skill_id = ("base.skill:%s"):format(skill_id)
   local result = self:mod("skills", { [skill_id] = { level = math.floor(amount) } }, op)
   local level = self.temp.skills[skill_id].level
   level = math.clamp(level, 0, MAX_LEVEL)
   self.temp.skills[skill_id].level = level
   return result
end

function ICharaSkills:mod_base_skill_level(skill_id, amount, op)
   data["base.skill"]:ensure(skill_id)
   if not self:has_skill(skill_id) then
      self:set_base_skill(skill_id, 1, 100, 0)
   end
   skill_id = ("base.skill:%s"):format(skill_id)
   local result = self:mod_base("skills", { [skill_id] = { level = math.floor(amount) } }, op)
   local level = self.skills[skill_id].level
   level = math.clamp(level, 0, MAX_LEVEL)
   self.skills[skill_id].level = level
   return result
end

function ICharaSkills:mod_skill_potential(skill_id, amount, op)
   data["base.skill"]:ensure(skill_id)
   if not self:has_skill(skill_id) then
      self:set_base_skill(skill_id, 1, 100, 0)
   end
   skill_id = ("base.skill:%s"):format(skill_id)
   local result = self:mod_base("skills", { [skill_id] = { potential = math.floor(amount) } }, op)
   local potential = self.skills[skill_id].potential
   potential = math.clamp(potential, 0, MAX_POTENTIAL)
   self.skills[skill_id].potential = potential
   return result
end

function ICharaSkills:mod_skill_experience(skill_id, amount, op)
   data["base.skill"]:ensure(skill_id)
   if not self:has_skill(skill_id) then
      self:set_base_skill(skill_id, 1, 100, 0)
   end
   skill_id = ("base.skill:%s"):format(skill_id)
   local result = self:mod_base("skills", { [skill_id] = { experience = math.floor(amount) } }, op)
   local experience = self.skills[skill_id].experience
   experience = math.clamp(experience, 0, MAX_EXPERIENCE)
   self.skills[skill_id].experience = experience
   return result
end

function ICharaSkills:set_base_skill(skill_id, level, potential, experience)
   data["base.skill"]:ensure(skill_id)
   skill_id = ("base.skill:%s"):format(skill_id)
   local s = self.skills[skill_id] or {}
   s.level = math.clamp(math.floor(level or s.level or 0), 0, MAX_LEVEL)
   s.potential = math.clamp(math.floor(potential or s.potential or 100), 0, MAX_POTENTIAL)
   s.experience = math.clamp(math.floor(experience or s.experience or 0), 0, MAX_EXPERIENCE)
   self.skills[skill_id] = s
end

return ICharaSkills
