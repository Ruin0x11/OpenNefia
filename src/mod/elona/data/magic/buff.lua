local Effect = require("mod.elona.api.Effect")
local Rand = require("api.Rand")
local Gui = require("api.Gui")

data:add {
   _id = "holy_shield",
   _type = "elona_sys.buff",

   type = "blessing",

   params = function(self, params)
      return {
         duration = 10 + params.power / 10,
         power = params.power
      }
   end
}

data:add {
   _id = "daze",
   _type = "elona_sys.buff",

   type = "hex",

   params = function(self, params)
      return {
         duration = 5 + params.power / 40,
         power = 0
      }
   end,

   on_refresh = function(self, params)
   end
}

data:add {
   _id = "regeneration",
   _type = "elona_sys.buff",

   type = "blessing",

   params = function(self, params)
      return {
         duration = 12 + params.power / 20,
         power = 0
      }
   end,

   on_refresh = function(self, params)
   end
}

data:add {
   _id = "res_ele",
   _type = "elona_sys.buff",

   type = "blessing",

   params = function(self, params)
      return {
         duration = 4 + params.power / 20,
         power = 0
      }
   end,

   on_refresh = function(self, params)
   end
}

data:add {
   _id = "speed_up",
   _type = "elona_sys.buff",

   type = "blessing",
   target_rider = true,

   params = function(self, params)
      return {
         duration = 8 + params.power / 30,
         power = 50 + math.sqrt(params.power / 5)
      }
   end,

   on_add = function(self, params)
      local target = params.target
      if Effect.is_cursed(params.curse_state) then
         target.age = target.age - Rand.rnd(3) + 1
         Gui.mes_c_visible("magic.speed", target, "Purple")
      end
   end,

   on_refresh = function(self, params)
   end
}

data:add {
   _id = "speed_down",
   _type = "elona_sys.buff",

   type = "hex",

   params = function(self, params)
      return {
         duration = 8 + params.power / 30,
         power = math.min(20 + params.power / 20, 50)
      }
   end,

   on_add = function(self, params)
      local target = params.target
      if params.curse_state == "blessed" then
         target.age = math.min(target.age + Rand.rnd(3) + 1, save.base.date.year - 12)
         Gui.mes_c_visible("magic.slow", target, "Green")
      end
   end,

   on_refresh = function(self, params)
   end
}

data:add {
   _id = "hero",
   _type = "elona_sys.buff",

   type = "blessing",

   params = function(self, params)
      return {
         duration = 10 + params.power / 4,
         power = 5 + params.power / 30
      }
   end,

   on_refresh = function(self, params)
   end
}

data:add {
   _id = "weak_armor",
   _type = "elona_sys.buff",

   type = "hex",

   params = function(self, params)
      return {
         duration = 6 + params.power / 10,
         power = { 30 + params.power / 10, 5 + params.power / 15 }
      }
   end,

   on_refresh = function(self, params)
   end
}

data:add {
   _id = "weak_ele",
   _type = "elona_sys.buff",

   type = "hex",

   params = function(self, params)
      return {
         duration = 4 + params.power / 15,
         power = 0,
      }
   end,

   on_refresh = function(self, params)
   end
}

data:add {
   _id = "holy_veil",
   _type = "elona_sys.buff",

   type = "blessing",

   params = function(self, params)
      return {
         duration = 15 + params.power / 5,
         power = 50 + params.power / 3 * 2,
      }
   end,

   on_refresh = function(self, params)
   end
}

data:add {
   _id = "nightmare",
   _type = "elona_sys.buff",

   type = "hex",

   params = function(self, params)
      return {
         duration = 4 + params.power / 15,
         power = 0,
      }
   end,

   on_refresh = function(self, params)
   end
}

data:add {
   _id = "knowledge",
   _type = "elona_sys.buff",

   type = "blessing",

   params = function(self, params)
      return {
         duration = 10 + params.power / 4,
         power = { 6 + params.power / 40, 3 + params.power / 100},
      }
   end,

   on_refresh = function(self, params)
   end
}

data:add {
   _id = "punish",
   _type = "elona_sys.buff",

   type = "hex",

   params = function(self, params)
      return {
         duration = params.power,
         power = 20,
      }
   end,

   on_refresh = function(self, params)
   end
}

data:add {
   _id = "god_wind",
   _type = "elona_sys.buff",

   type = "blessing",
   target_rider = true,

   params = function(self, params)
      return {
         duration = 7,
         power = 155 + params.power / 5,
      }
   end,

   on_refresh = function(self, params)
   end
}

data:add {
   _id = "incognito",
   _type = "elona_sys.buff",

   type = "blessing",

   params = function(self, params)
      return {
         duration = 4 + params.power / 40,
         power = 0
      }
   end,

   on_add = function(self, params)
      local target = params.target

      if target:is_player() then
         Effect.start_incognito(target)
      end
   end,

   on_refresh = function(self, params)
   end
}

data:add {
   _id = "death",
   _type = "elona_sys.buff",

   type = "hex",

   params = function(self, params)
      return {
         duration = 20,
         power = 0
      }
   end,

   on_refresh = function(self, params)
   end
}

data:add {
   _id = "boost",
   _type = "elona_sys.buff",

   type = "blessing",

   params = function(self, params)
      return {
         duration = 5,
         power = 120
      }
   end,

   on_refresh = function(self, params)
   end
}

data:add {
   _id = "contingency",
   _type = "elona_sys.buff",

   type = "blessing",

   params = function(self, params)
      return {
         duration = 66,
         power = math.clamp(25 + params.power/17, 25, 80)
      }
   end,

   on_refresh = function(self, params)
   end
}

data:add {
   _id = "lucky",
   _type = "elona_sys.buff",

   type = "blessing",

   params = function(self, params)
      return {
         duration = 777,
         power = params.power
      }
   end,

   on_refresh = function(self, params)
   end
}

local function food_buff_power(skill_id)
   return function(self, params)
      return {
         duration = 10 + params.power / 10,
         power = params.power
      }
   end
end

local function apply_food_buff(skill_id)
   return function(self, params)
      local target = params.target
      target.temp.growth_buffs = target.temp.growth_buffs or {}
      target.temp.growth_buffs[skill_id] = params.buff.power
   end
end

data:add {
   _id = "food_str",
   _type = "elona_sys.buff",

   type = "food",

   power = food_buff_power,

   on_refresh = apply_food_buff("elona.stat_strength")
}

data:add {
   _id = "food_end",
   _type = "elona_sys.buff",

   type = "food",

   power = food_buff_power,

   on_refresh = apply_food_buff("elona.stat_strength")
}

data:add {
   _id = "food_dex",
   _type = "elona_sys.buff",

   type = "food",

   power = food_buff_power,

   on_refresh = apply_food_buff("elona.stat_strength")
}

data:add {
   _id = "food_per",
   _type = "elona_sys.buff",

   type = "food",

   power = food_buff_power,

   on_refresh = apply_food_buff("elona.stat_strength")
}

data:add {
   _id = "food_ler",
   _type = "elona_sys.buff",

   type = "food",

   power = food_buff_power,

   on_refresh = apply_food_buff("elona.stat_strength")
}

data:add {
   _id = "food_wil",
   _type = "elona_sys.buff",

   type = "food",

   power = food_buff_power,

   on_refresh = apply_food_buff("elona.stat_strength")
}

data:add {
   _id = "food_mag",
   _type = "elona_sys.buff",

   type = "food",

   power = food_buff_power,

   on_refresh = apply_food_buff("elona.stat_strength")
}

data:add {
   _id = "food_chr",
   _type = "elona_sys.buff",

   type = "food",

   power = food_buff_power,

   on_refresh = apply_food_buff("elona.stat_strength")
}

data:add {
   _id = "food_spd",
   _type = "elona_sys.buff",

   type = "food",

   power = food_buff_power,

   on_refresh = apply_food_buff("elona.stat_strength")
}
