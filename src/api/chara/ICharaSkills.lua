--- @classmod ICharaSkills

local ICharaSkills = class.interface("ICharaSkills")
local data = require("internal.data")

function ICharaSkills:init()
   self.skills = self.skills or {}
   self.magic = self.magic or {}
   self.resists = self.resists or {}

   self.stat_adjusts = self.stat_adjusts or {}
end

function ICharaSkills:stat_adjustment(skill)
   return self.stat_adjusts[skill] or 0
end

function ICharaSkills:set_stat_adjustment(skill, adj)
   if adj == 0 then
      adj = nil
   end
   local skill_data = data["base.skill"]:ensure(skill)
   assert(skill_data.skill_type == "stat")
   self.stat_adjusts[skill] = math.floor(adj)
end

function ICharaSkills:add_stat_adjustment(skill, delta)
   self:set_stat_adjustment(skill, self:stat_adjustment(skill) + delta)
end

function ICharaSkills:on_refresh()
   for skill_id, adj in pairs(self.stat_adjusts) do
      if adj ~= 0 then
         if self.quality >= 4 then -- miracle
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

local function generate_methods(iface, name, field, ty)
   local subfields = { "level", "potential", "experience" }

   iface["has_" .. name] = function(self, skill)
      data[ty]:ensure(skill)
      -- This checks base, not temporary
      return self[field][skill] and self[field][skill].level > 0
   end

   iface["gain_" .. name] = function(self, skill, level)
      data[ty]:ensure(skill)
      self[field][skill] = self[field][skill] or
         {
            level = 0,
            potential = 0,
            experience = 0,
         }

      if self[field][skill].level == 0 then
         self[field][skill].level = level or 1
      end
   end

   iface["set_base_" .. name] = function(self, skill, level, potential, experience)
      data[ty]:ensure(skill)
      if not self["has_" .. name](self, skill) then
         self["gain_" .. name](self, skill)
      end

      local s = self[field][skill]
      s.level = math.floor(level or s.level)
      s.potential = math.floor(potential or s.potential)
      s.experience = math.floor(experience or s.experience)
   end

   for _, subfield in ipairs(subfields) do
      -- self:skill_level(skill)
      iface[name .. "_" .. subfield] = function(self, skill)
         data[ty]:ensure(skill)
         local it = self:calc(field)[skill]
         if not it or not it[subfield] then
            it = self[field][skill]
         end
         if not it then return 0 end
         return it[subfield] or 0
      end
      -- self:base_skill_level(skill)
      iface["base_" .. name .. "_" .. subfield] = function(self, skill)
         data[ty]:ensure(skill)
         local it = self[field][skill]
         if not it then return 0 end
         return it[subfield] or 0
      end
      -- self:mod_skill_level(skill, level, "add")
      iface["mod_" .. name .. "_" .. subfield] = function(self, skill, amount, op)
         data[ty]:ensure(skill)
         if not self["has_" .. name](self, skill) then
            return
         end
         return self:mod(field, { [skill] = { [subfield] = math.floor(amount) } }, op)
      end
      -- self:mod_base_skill_level(skill, level, "add")
      iface["mod_base_" .. name .. "_" .. subfield] = function(self, skill, amount, op)
         data[ty]:ensure(skill)
         if not self["has_" .. name](self, skill) then
            self["gain_" .. name](self, skill)
         end
         return self:mod_base(field, { [skill] = { [subfield] = math.floor(amount) } }, op)
      end
   end
end

-- TODO: keep eveything in one "skills" field, to prevent needing to
-- distinguish by type, and instead prefix each ID with the type name
generate_methods(ICharaSkills, "skill", "skills", "base.skill")
generate_methods(ICharaSkills, "magic", "magic", "base.skill")
generate_methods(ICharaSkills, "resist", "resists", "base.element")

--- @function ICharaSkills:skill_level(skill_id)
--- @tparam id:base.skill skill_id
--- @treturn[opt] number

--- @function ICharaSkills:base_skill_level(skill_id)
--- @tparam id:base.skill skill_id
--- @treturn[opt] number

--- @function ICharaSkills:mod_skill_level(skill_id, amount, op)
--- @tparam id:base.skill skill_id
--- @tparam number amount
--- @tparam[opt] string op
--- @treturn[opt] number

--- @function ICharaSkills:mod_base_skill_level(skill_id, amount, op)
--- @tparam id:base.skill skill_id
--- @tparam number amount
--- @tparam[opt] string op
--- @treturn[opt] number

return ICharaSkills
