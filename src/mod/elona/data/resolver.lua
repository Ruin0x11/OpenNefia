local Rand = require("api.Rand")
local Resolver = require("api.Resolver")
local Skill = require("mod.elona_sys.api.Skill")

data:add {
   _type = "base.resolver",
   _id = "skill",

   ordering = 300000,
   method = "add",
   invariants = { skill = "number", level = "number", },
   params     = { chara = "IChara", },
   resolve    = function(self, params)
      local chara = params.chara
      return Skill.calc_initial_skill_level(self.skill, self.level, chara:has_skill(self.skill), chara:calc("level"), chara)
   end,
}


local init_skill_list = function(self, params)
   self.resolver = "elona.skill"

   local skills = {}

   for skill_id, level in pairs(self.skills) do
      skills[skill_id] = Resolver.run(self.resolver, { skill = skill_id, level = level }, { chara = params.chara })
   end

   return skills
end

data:add {
   _type = "base.resolver",
   _id = "skills",

   ordering = 300000,
   method = "add",
   invariants = { skills = "table", resolver = "string", },
   params     = { chara = "IChara", },
   resolve    = init_skill_list,
}

data:add {
   _type = "base.resolver",
   _id = "gender",

   ordering = 300000,
   method = "set",
   invariants = { male_ratio = "number" },
   params = { chara = "IChara" },

   resolve = function(self)
      return (Rand.percent_chance(self.male_ratio) and "male") or "female"
   end
}

data:add {
   _type = "base.resolver",
   _id = "by_gender",

   ordering = 310000,
   method = "set",
   invariants = { male = "any", female = "any" },
   params = { chara = "IChara" },

   resolve = function(self, params)
      return self[params.chara.gender or "female"]
   end
}

data:add {
   _type = "base.resolver",
   _id = "item_count",

   ordering = 300000,
   method = "set",
   invariants = { count = "number" },

   resolve = function(self)
      return self.count - Rand.rnd(self.count) + Rand.rnd(self.count)
   end
}

data:add {
   _type = "base.resolver",
   _id = "music_disc_id",

   ordering = 300000,
   method = "set",

   resolve = function()
      return 12
   end
}

local base_resolvers = {
   skills = "elona.skills",
}

data:add {
   _type = "base.resolver",
   _id = "race",

   ordering = 100000,
   method = "merge",
   invariants = { race = "string" },
   params = { chara = "table" },

   resolve = function(self, params)
      local race = data["base.race"][self.race or params.chara.race or ""]
      if not race then
         return {}
      end
      local copy_to_chara = table.deepcopy(race.copy_to_chara)
      if race.base then
         for k, v in pairs(race.base) do
            local resolver = base_resolvers[k]
            if resolver then
               copy_to_chara[k] = Resolver.run(base_resolvers[k], race.base, params)
            end
         end
      end
      return Resolver.resolve(copy_to_chara, params)
   end
}

data:add {
   _type = "base.resolver",
   _id = "class",

   ordering = 200000,
   method = "merge",
   invariants = { class = "string" },
   params = { chara = "table" },

   resolve = function(self, params)
      local class = data["base.class"][self.class or params.chara.class or ""]
      if not class then
         return {}
      end
      local copy_to_chara = table.deepcopy(class.copy_to_chara)
      return Resolver.resolve(copy_to_chara, params)
   end
}
