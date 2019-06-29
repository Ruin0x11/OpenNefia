local resource = {}
local function clamp_if_known(chara, new, amount)
   return math.clamp(new, (amount > 0 and 1) or 0, resource["base.max_stat"])
end

local scale_stat = {
   _type = "base.effect",
   _id = "scale_stat",

   params = { stat = "number", add = "number", div = "number", neg = false },

   on_apply = function(self, chara)
      local prev = chara:get_stat(self.stat)
      chara:mod_stat(self.stat, clamp_if_known(prev + math.floor(self.add + chara:calc("level") * self.mul / self.div) * (self.neg and -1 or 1), prev))
   end
}

local four_eyes = {
   _type = "elona_sys.trait",
   _id = "four_eyes",

   orientation = "detrimental",
   description = function(self)
      local s1 = self:sub_effect_power("base.add_stat", { stat = 60 })
      local s2 = self:sub_effect_power("base.add_stat", { stat = 61 })
      return "You " .. " have 4 eyes. [PER+" .. s1 .. " CHR" .. s2 .. "]"
   end,

   effects = {
      {"elona_sys.scale_stat", stat = 17, add = 5, div = 3, neg = true},
      {"elona_sys.scale_stat", stat = 13, add = 5, div = 3},
   }
}

local shield_bash = {
   _type = "elona_sys.trait",
   _id = "shield_bash",

   can_acquire = function(chara)
      return chara.stat["168"] > 0
   end,

   effects = {
      {
         method = "add",
         delta = {
            known_abilities = { "base.shield_bash" }
         }
      }
   }
}

local high_resistances = {
   _type = "elona_sys.trait",
   _id = "high_resistances",

   orientation = "beneficial",

   effects = {
      stat = {
         [60] = 150,
         [52] = 100,
         [53] = 200,
         [57] = 50,
         [59] = 100,
         [54] = 200,
         [58] = 100,
         [51] = 100,
      }
   }
}
