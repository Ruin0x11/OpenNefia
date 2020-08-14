local Rand = require("api.Rand")
local Text = require("mod.elona.api.Text")
local I18N = require("api.I18N")

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
      return self[params.object.gender or "female"]
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
   _id = "random_name",

   ordering = 200000,
   method = "merge",
   invariants = { },
   params = { },

   resolve = function(self, params)
      local chara = params.object
      return {
         name = I18N.get("chara.job.own_name", chara.name, Text.random_name()),
         has_own_name = true
      }
   end
}
