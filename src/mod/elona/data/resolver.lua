local Rand = require("api.Rand")
local Resolver = require("api.Resolver")
local Skill = require("mod.elona_sys.api.Skill")
local Event = require("api.Event")

data:add {
   _type = "base.resolver",
   _id = "skill",

   ordering = 300000,
   method = "add",
   invariants = { skill = "number", level = "number", },
   params     = { chara = "IChara", },
   resolve    = function(self, params)
      local chara = params.chara
      local skill = Skill.calc_initial_skill_level(self.skill, self.level, chara:base_skill_level(self.skill), chara:calc("level"), chara)
      skill.experience = 0
      return skill
   end,
}


local init_skill_list = function(self, params)
   local skills = {}

   for skill_id, level in pairs(self.skills) do
      skills["base.skill:" .. skill_id] = Resolver.run("elona.skill", { skill = skill_id, level = level }, { chara = params.chara })
   end

   return skills
end

data:add {
   _type = "base.resolver",
   _id = "skills",

   ordering = 300000,
   invariants = { skills = "table" },
   params     = { chara = "IChara" },
   resolve    = init_skill_list,
}

data:add {
   _type = "base.resolver",
   _id = "gender",

   ordering = 300000,
   method = "merge",
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
   method = "merge",
   invariants = { male = "any", female = "any" },
   params = { chara = "IChara" },

   resolve = function(self, params)
      return self[params.chara.gender or "female"]
   end
}

data:add {
   _type = "base.resolver",
   _id = "item_charges",

   ordering = 300000,
   method = "merge",
   invariants = { charges = "number" },

   resolve = function(self)
      return self.charges - Rand.rnd(self.charges) + Rand.rnd(self.charges)
   end
}

data:add {
   _type = "base.resolver",
   _id = "music_disc_id",

   ordering = 300000,
   method = "merge",

   resolve = function()
      return 12
   end
}

data:add {
   _type = "base.resolver",
   _id = "fruit_tree",

   ordering = 300000,
   method = "merge",

   resolve = function()
      return 5
   end
}

data:add {
   _type = "base.resolver",
   _id = "random_portrait",

   ordering = 300000,
   method = "merge",

   resolve = function(self, params)
      local ind = 1 + Rand.rnd(32)
      local chara = params.object
      local prefix
      if chara:calc("gender") == "male" then
         prefix = "man"
      else
         prefix = "woman"
      end
      local id = ("elona.%s%d"):format(prefix, ind)
      return data["base.portrait"]:ensure(id)._id
   end
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
      if race.skills then
         copy_to_chara.skills = Resolver.make("elona.skills", {skills = race.skills})
      end
      return Resolver.resolve(copy_to_chara, params)
end}

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

      copy_to_chara.skills = Resolver.make("elona.skills", {skills = class.skills})

      return Resolver.resolve(copy_to_chara, params)
   end
}

data:add {
   _type = "base.resolver",
   _id = "random_name",

   ordering = 200000,
   method = "merge",
   invariants = { },
   params = { },

   resolve = function()
      return {
         name = Event.trigger("base.generate_chara_name", {}, ""),
         has_own_name = true
      }
   end
}
