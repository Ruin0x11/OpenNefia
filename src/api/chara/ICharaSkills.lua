local ICharaSkills = class.interface("ICharaSkills")

function ICharaSkills:init()
   self.skills = self.skills or {}
   self.magic = self.magic or {}
   self.resists = self.resists or {}
end

local function generate_methods(iface, name, field)
   local subfields = { "level", "potential", "experience" }

   iface["has_" .. name] = function(self, skill)
      -- This checks base, not temporary
      return self[field][skill] and self[field][skill].level > 0
   end

   iface["set_base_" .. name] = function(self, skill, level, potential, experience)
      self[field][skill] = self[field][skill] or
         {
            level = 0,
            potential = 0,
            experience = 0,
         }

      local s = self[field][skill]
      s.level = math.floor(level or s.level)
      s.potential = math.floor(potential or s.potential)
      s.experience = math.floor(experience or s.experience)
   end

   for _, subfield in ipairs(subfields) do
      -- self:skill_level(skill)
      iface[name .. "_" .. subfield] = function(self, skill)
         local it = self:calc(field)[skill]
         if not it or not it[subfield] then
            it = self[field][skill]
         end
         if not it then return 0 end
         return it[subfield] or 0
      end
      -- self:base_skill_level(skill)
      iface["base_" .. name .. "_" .. subfield] = function(self, skill)
         local it = self[field][skill]
         if not it then return 0 end
         return it[subfield] or 0
      end
      -- self:mod_skill_level(skill, level, "add")
      iface["mod_" .. name .. "_" .. subfield] = function(self, skill, amount, op)
         if not self:has_skill(skill) then
            return
         end
         return self:mod(field, { [skill] = { [subfield] = math.floor(amount) } }, op)
      end
      -- self:mod_base_skill_level(skill, level, "add")
      iface["mod_base_" .. name .. "_" .. subfield] = function(self, skill, amount, op)
         if not self:has_skill(skill) then
            return
         end
         return self:mod_base(field, { [skill] = { [subfield] = math.floor(amount) } }, op)
      end
   end
end

-- TODO: keep eveything in one "skills" field, to prevent needing to
-- distinguish by type, and instead prefix each ID with the type name
generate_methods(ICharaSkills, "skill", "skills")
generate_methods(ICharaSkills, "magic", "magic")
generate_methods(ICharaSkills, "resist", "resists")

return ICharaSkills
