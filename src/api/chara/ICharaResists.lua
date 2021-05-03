local ICharaResists = class.interface("ICharaResists")
local data = require("internal.data")
local Const = require("api.Const")

function ICharaResists:init()
   self.resistances = {}

   if self.proto.resistances then
      for element_id, level in pairs(self.proto.resistances) do
         assert(type(level) == "number")
         local potential = 100
         self:set_base_resist(element_id, level, potential, 0)
      end
   end
end

function ICharaResists:on_refresh()
end

--- Obtains the character's original resist level, before applying buffs.
function ICharaResists:base_resist_level(element_id)
   data["base.element"]:ensure(element_id)
   return self.resistances[element_id] and self.resistances[element_id].level or 0
end

--- Obtains the character's original resist grade, before applying buffs.
function ICharaResists:base_resist_grade(element_id)
   return math.floor(self:base_resist_level(element_id) / Const.RESIST_GRADE)
end

--- Obtains the character's resist level after applying buffs.
function ICharaResists:resist_level(element_id)
   data["base.element"]:ensure(element_id)
   local temp = self.temp["resistances"]
   if not temp then
      return self:base_resist_level(element_id)
   end
   local resist_entry = temp[element_id]
   if not resist_entry then
      return self:base_resist_level(element_id)
   end
   return resist_entry.level or 0
end

--- Obtains the character's resist grade after applying buffs.
function ICharaResists:resist_grade(element_id)
   return math.floor(self:resist_level(element_id) / Const.RESIST_GRADE)
end

--- Returns true if the character has a resistance. If true, you can call
--- ICharaResists:resist_level() and get back a non-zero level.
function ICharaResists:has_resist(element_id)
   return self:resist_level(element_id) > 0
end

function ICharaResists:has_base_resist(element_id)
   return self:base_resist_level(element_id) > 0
end

function ICharaResists:resist_potential(element_id)
   data["base.element"]:ensure(element_id)
   return self.resistances[element_id] and self.resistances[element_id].potential or 0
end

function ICharaResists:resist_experience(element_id)
   data["base.element"]:ensure(element_id)
   return self.resistances[element_id] and self.resistances[element_id].experience or 0
end

function ICharaResists:mod_resist_level(element_id, amount, op, force)
   data["base.element"]:ensure(element_id)
   if not self:has_resist(element_id) and not force then
      return
   end
   local result = self:mod("resistances", { [element_id] = { level = math.floor(amount) } }, op)
   local level = self.temp.resistances[element_id].level
   level = math.clamp(level, 0, Const.MAX_SKILL_LEVEL)
   self.temp.resistances[element_id].level = level
   return result
end

function ICharaResists:mod_base_resist_level(element_id, amount, op)
   data["base.element"]:ensure(element_id)
   if not self:has_resist(element_id) then
      self:set_base_resist(element_id, 1, 100, 0)
   end
   local result = self:mod_base("resistances", { [element_id] = { level = math.floor(amount) } }, op)
   local level = self.resistances[element_id].level
   level = math.clamp(level, 0, Const.MAX_SKILL_LEVEL)
   self.resistances[element_id].level = level
   return result
end

function ICharaResists:mod_resist_potential(element_id, amount, op)
   data["base.element"]:ensure(element_id)
   if not self:has_resist(element_id) then
      self:set_base_resist(element_id, 1, 100, 0)
   end
   local result = self:mod_base("resistances", { [element_id] = { potential = math.floor(amount) } }, op)
   local potential = self.resistances[element_id].potential
   potential = math.clamp(potential, 0, Const.MAX_SKILL_POTENTIAL)
   self.resistances[element_id].potential = potential
   return result
end

function ICharaResists:mod_resist_experience(element_id, amount, op)
   data["base.element"]:ensure(element_id)
   if not self:has_resist(element_id) then
      self:set_base_resist(element_id, 1, 100, 0)
   end
   local result = self:mod_base("resistances", { [element_id] = { experience = math.floor(amount) } }, op)
   local experience = self.resistances[element_id].experience
   experience = math.clamp(experience, 0, Const.MAX_SKILL_EXPERIENCE)
   self.resistances[element_id].experience = experience
   return result
end

function ICharaResists:set_base_resist(element_id, level, potential, experience)
   data["base.element"]:ensure(element_id)
   local s = self.resistances[element_id] or {}
   s.level = math.clamp(math.floor(level or s.level or 0), 0, Const.MAX_SKILL_LEVEL)
   s.potential = math.clamp(math.floor(potential or s.potential or 100), 0, Const.MAX_SKILL_POTENTIAL)
   s.experience = math.clamp(math.floor(experience or s.experience or 0), 0, Const.MAX_SKILL_EXPERIENCE)
   self.resistances[element_id] = s
end

return ICharaResists
