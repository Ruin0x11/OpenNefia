local ICharaSkills = class.interface("ICharaSkills")

function ICharaSkills:init()
   self.skills = self.skills or {}
   self.magic = self.magic or {}
   self.resists = self.resists or {}
end

local function generate_methods(iface, name, field)
   local subfields = { "level", "potential" }

   for _, subfield in ipairs(subfields) do
      -- self:skill_level(skill)
      iface[name .. "_" .. subfield] = function(self, skill)
         local it = self:calc(field)[skill]
         if not it then return 0 end
         return it[subfield]
      end
      -- self:base_skill_level(skill)
      iface["base_" .. name .. "_" .. subfield] = function(self, skill)
         local it = self[field][skill]
         if not it then return 0 end
         return it[subfield]
      end
      -- self:mod_skill_level(skill, level, "add")
      iface["mod_" .. name .. "_" .. subfield] = function(self, skill, amount, op)
         return self:mod(field, { [skill] = { [subfield] = amount } }, op)
      end
      -- self:base_skill_level()
      iface["mod_base_" .. name .. "_" .. subfield] = function(self, skill, amount, op)
         return self:mod_base(field, { [skill] = { [subfield] = amount } }, op)
      end
   end
end

generate_methods(ICharaSkills, "skill", "skills")
generate_methods(ICharaSkills, "magic", "magic")
generate_methods(ICharaSkills, "resist", "resists")

return ICharaSkills
