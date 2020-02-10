--- @classmod ICharaSkills

local ICharaSkills = class.interface("ICharaSkills")
local data = require("internal.data")

local MAX_LEVEL = 2000

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
generate_methods(ICharaSkills, "skill", "base.skill")
generate_methods(ICharaSkills, "magic", "elona_sys.magic")
generate_methods(ICharaSkills, "resist", "base.element")

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
