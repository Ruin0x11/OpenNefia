local Effect = require("mod.elona.api.Effect")
local Rand = require("api.Rand")
local Gui = require("api.Gui")
local Event = require("api.Event")
local Chara = require("api.Chara")
local Magic = require("mod.elona.api.Magic")
local I18N = require("api.I18N")
local Enum = require("api.Enum")

local RANGE_BOLT = 6 + 1

local function make_buff(opts)
   data:add {
      _id = "buff_" .. opts._id,
      _type = "base.skill",
      elona_id = opts.elona_id,

      type = opts.type,
      related_skill = opts.related_skill,
      cost = opts.cost,
      range = opts.range,
      difficulty = opts.difficulty,
      target_type = opts.target_type,

      calc_desc = function(chara, power, dice)
         local buff_data = data["elona_sys.buff"]:ensure("elona." .. opts._id)
         local params = { power = 0, duration = 0 }
         if buff_data.params then
            params = buff_data:params({ power = power, chara = chara })
         end

         if type(params.power) == "table" then
            for i = 1, #params.power do
               params.power[i] = math.floor(params.power[i])
            end
         else
            params.power = { math.floor(params.power) }
         end

         return tostring(math.floor(params.duration))
            .. I18N.get("ui.spell.turn_counter")
            .. I18N.space()
            .. I18N.get("buff." .. "elona" .. "." .. opts._id .. ".description", table.unpack(params.power))
      end,

      effect_id = "elona.buff_" .. opts._id,
   }
   data:add {
      _id = "buff_" .. opts._id,
      _type = "elona_sys.magic",
      elona_id = opts.elona_id,

      params = {
         "target"
      },

      alignment = (opts.type == "hex" and "negative") or "positive",

      cast = function(self, params)
         return Magic.apply_buff("elona." .. opts._id, params)
      end
   }
end

make_buff {
   _id = "holy_shield",
   elona_id = 442,

   type = "spell",
   related_skill = "elona.stat_will",
   cost = 8,
   range = 0,
   difficulty = 150,
   target_type = "self_or_nearby",
}
data:add {
   _id = "holy_shield",
   _type = "elona_sys.buff",

   type = "blessing",
   image = 1,

   params = function(self, params)
      return {
         duration = 10 + params.power / 10,
         power = params.power
      }
   end,

   on_refresh = function(self, chara)
      chara:mod("pv", self.power, "add")
      chara:set_effect_turns("elona.fear", 0)
   end
}

make_buff {
   _id = "mist_of_silence",
   elona_id = 443,

   type = "spell",
   related_skill = "elona.stat_perception",
   cost = 24,
   range = RANGE_BOLT,
   difficulty = 620,
   target_type = "enemy",
}
data:add {
   _id = "mist_of_silence",
   _type = "elona_sys.buff",

   type = "hex",
   image = 2,

   params = function(self, params)
      return {
         duration = 5 + params.power / 40,
         power = 0
      }
   end,

   on_refresh = function(self, chara)
      -- No-op, handled in events
   end
}

make_buff {
   _id = "regeneration",
   elona_id = 444,

   type = "spell",
   related_skill = "elona.stat_will",
   cost = 16,
   range = 0,
   difficulty = 400,
   target_type = "self",
}
data:add {
   _id = "regeneration",
   _type = "elona_sys.buff",

   type = "blessing",
   image = 3,

   params = function(self, params)
      return {
         duration = 12 + params.power / 20,
         power = 0
      }
   end,

   on_refresh = function(self, chara)
      chara:mod_skill_level("elona.healing", 40, "add")
   end
}

make_buff {
   _id = "elemental_shield",
   elona_id = 445,

   type = "spell",
   related_skill = "elona.stat_will",
   cost = 14,
   range = 0,
   difficulty = 350,
   target_type = "self",
}
data:add {
   _id = "elemental_shield",
   _type = "elona_sys.buff",

   type = "blessing",
   image = 4,

   params = function(self, params)
      return {
         duration = 4 + params.power / 20,
         power = 0
      }
   end,

   on_refresh = function(self, chara)
      chara:mod_resist_level("elona.fire", 100, "add")
      chara:mod_resist_level("elona.cold", 100, "add")
      chara:mod_resist_level("elona.lightning", 100, "add")
   end
}

make_buff {
   _id = "speed",
   elona_id = 446,

   type = "spell",
   related_skill = "elona.stat_will",
   cost = 28,
   range = 0,
   difficulty = 1050,
   target_type = "self",
}
data:add {
   _id = "speed",
   _type = "elona_sys.buff",

   type = "blessing",
   image = 5,
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

   on_refresh = function(self, chara)
      chara:mod_skill_level("elona.stat_speed", self.power, "add")
   end
}

make_buff {
   _id = "slow",
   elona_id = 447,

   type = "spell",
   related_skill = "elona.stat_magic",
   cost = 10,
   range = RANGE_BOLT,
   difficulty = 450,
   target_type = "enemy",
}
data:add {
   _id = "slow",
   _type = "elona_sys.buff",

   type = "hex",
   image = 6,

   params = function(self, params)
      return {
         duration = 8 + params.power / 30,
         power = math.min(20 + params.power / 20, 50)
      }
   end,

   on_add = function(self, params)
      local target = params.target
      if params.curse_state == Enum.CurseState.Blessed then
         target.age = math.min(target.age + Rand.rnd(3) + 1, save.base.date.year - 12)
         Gui.mes_c_visible("magic.slow", target, "Green")
      end
   end,

   on_refresh = function(self, chara)
      chara:mod_skill_level("elona.stat_speed", -self.power, "add")
   end
}

make_buff {
   _id = "hero",
   elona_id = 448,

   type = "spell",
   related_skill = "elona.stat_will",
   cost = 12,
   range = 0,
   difficulty = 80,
   target_type = "self_or_nearby",
}
data:add {
   _id = "hero",
   _type = "elona_sys.buff",

   type = "blessing",
   image = 7,

   params = function(self, params)
      return {
         duration = 10 + params.power / 4,
         power = 5 + params.power / 30
      }
   end,

   on_refresh = function(self, chara)
      chara:mod_skill_level("elona.stat_strength", self.power, "add")
      chara:mod_skill_level("elona.stat_dexterity", self.power, "add")
      chara:set_effect_turns("elona.fear", 0)
      chara:set_effect_turns("elona.confusion", 0)
   end
}

make_buff {
   _id = "mist_of_frailness",
   elona_id = 449,

   type = "spell",
   related_skill = "elona.stat_magic",
   cost = 8,
   range = RANGE_BOLT,
   difficulty = 300,
   target_type = "enemy",
}
data:add {
   _id = "mist_of_frailness",
   _type = "elona_sys.buff",

   type = "hex",
   image = 8,

   params = function(self, params)
      return {
         duration = 6 + params.power / 10,
         power = { 30 + params.power / 10, 5 + params.power / 15 }
      }
   end,

   on_refresh = function(self, chara)
      chara:mod("dv", math.floor(chara:calc("dv") / 2), "set")
      chara:mod("pv", math.floor(chara:calc("pv") / 2), "set")
   end
}

make_buff {
   _id = "element_scar",
   elona_id = 450,

   type = "spell",
   related_skill = "elona.stat_magic",
   cost = 15,
   range = RANGE_BOLT,
   difficulty = 600,
   target_type = "enemy",
}
data:add {
   _id = "element_scar",
   _type = "elona_sys.buff",

   type = "hex",
   image = 9,

   params = function(self, params)
      return {
         duration = 4 + params.power / 15,
         power = 0,
      }
   end,

   on_refresh = function(self, chara)
      chara:mod_resist_level("elona.fire", -100, "add")
      chara:mod_resist_level("elona.cold", -100, "add")
      chara:mod_resist_level("elona.lightning", -100, "add")
   end
}

make_buff {
   _id = "holy_veil",
   elona_id = 451,

   type = "spell",
   related_skill = "elona.stat_will",
   cost = 20,
   range = 0,
   difficulty = 900,
   target_type = "self_or_nearby",
}
data:add {
   _id = "holy_veil",
   _type = "elona_sys.buff",

   type = "blessing",
   image = 10,

   params = function(self, params)
      return {
         duration = 15 + params.power / 5,
         power = 50 + params.power / 3 * 2,
      }
   end,

   on_refresh = function(self, chara)
      -- No-op, handled in events
   end
}

make_buff {
   _id = "nightmare",
   elona_id = 452,

   type = "spell",
   related_skill = "elona.stat_perception",
   cost = 15,
   range = RANGE_BOLT,
   difficulty = 500,
   target_type = "enemy",
}
data:add {
   _id = "nightmare",
   _type = "elona_sys.buff",

   type = "hex",
   image = 11,

   params = function(self, params)
      return {
         duration = 4 + params.power / 15,
         power = 0,
      }
   end,

   on_refresh = function(self, chara)
      chara:mod_resist_level("elona.nerve", -100, "add")
      chara:mod_resist_level("elona.mind", -100, "add")
   end
}

make_buff {
   _id = "divine_wisdom",
   elona_id = 453,

   type = "spell",
   related_skill = "elona.stat_learning",
   cost = 22,
   range = 0,
   difficulty = 350,
   target_type = "self",
}
data:add {
   _id = "divine_wisdom",
   _type = "elona_sys.buff",

   type = "blessing",
   image = 12,

   params = function(self, params)
      return {
         duration = 10 + params.power / 4,
         power = { 6 + params.power / 40, 3 + params.power / 100},
      }
   end,

   on_refresh = function(self, chara)
      chara:mod_skill_level("elona.stat_learning", self.power[1], "add")
      chara:mod_skill_level("elona.stat_magic", self.power[1], "add")
      chara:mod_skill_level("elona.literacy", self.power[2], "add")
   end
}

make_buff {
   _id = "punishment",
   elona_id = 622,

   type = "action",
   related_skill = "elona.stat_will",
   cost = 15,
   range = RANGE_BOLT,
   difficulty = 500,
   target_type = "enemy",
}
data:add {
   _id = "punishment",
   _type = "elona_sys.buff",

   type = "hex",
   image = 13,
   no_remove_on_heal = true,

   params = function(self, params)
      return {
         duration = params.power,
         power = 20,
      }
   end,

   on_refresh = function(self, chara)
      chara:mod_skill_level("elona.stat_speed", -self.power, "add")
      local pv = chara:calc("pv")
      if pv > 1 then
         chara:mod("pv", -pv / 5, "add")
      end
   end
}

make_buff {
   _id = "lulwys_trick",
   elona_id = 625,

   type = "action",
   related_skill = "elona.stat_dexterity",
   cost = 20,
   range = 0,
   difficulty = 500,
   target_type = "self",
}
data:add {
   _id = "lulwys_trick",
   _type = "elona_sys.buff",

   type = "blessing",
   image = 14,
   target_rider = true,

   params = function(self, params)
      return {
         duration = 7,
         power = 155 + params.power / 5,
      }
   end,

   on_refresh = function(self, chara)
      chara:mod_skill_level("elona.stat_speed", self.power, "add")
   end
}

make_buff {
   _id = "incognito",
   elona_id = 458,

   type = "spell",
   related_skill = "elona.stat_perception",
   cost = 38,
   range = 0,
   difficulty = 250,
   target_type = "self",
}
data:add {
   _id = "incognito",
   _type = "elona_sys.buff",

   type = "blessing",
   image = 15,

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

   on_refresh = function(self, chara)
      chara:mod("is_incognito", true)
   end,

   on_remove = function(self, chara)
      if chara:is_player() then
         Effect.end_incognito(chara)
      end
   end
}

make_buff {
   _id = "death_word",
   elona_id = 646,

   type = "action",
   related_skill = "elona.stat_will",
   cost = 15,
   range = RANGE_BOLT,
   difficulty = 500,
   target_type = "enemy",
}
data:add {
   _id = "death_word",
   _type = "elona_sys.buff",

   type = "hex",
   image = 16,

   params = function(self, params)
      return {
         duration = 20,
         power = 0
      }
   end,

   on_refresh = function(self, chara)
      chara:calc("is_under_death_word", true)
   end,

   on_expire = function(self, chara)
      chara:damage_hp(9999, "elona.death_word")
   end,

   on_remove = function(self, chara)
      chara:reset("is_under_death_word", false)
   end
}

local function remove_death_word_on_all_charas(chara)
   if chara:calc("is_death_master") then
      Gui.mes("damage.death_word_breaks")
      for _, other in Chara.iter() do
         other:remove_buff("elona.death_word")
      end
   end
end

Event.register("base.on_chara_killed", "Remove Death Word on all characters if death master killed",
               remove_death_word_on_all_charas)


make_buff {
   _id = "boost",
   elona_id = 647,

   type = "action",
   related_skill = "elona.stat_will",
   cost = 50,
   range = RANGE_BOLT,
   difficulty = 500,
   target_type = "self",
}
data:add {
   _id = "boost",
   _type = "elona_sys.buff",

   type = "blessing",
   image = 17,

   params = function(self, params)
      return {
         duration = 5,
         power = 120
      }
   end,

   on_refresh = function(self, chara)
      chara:mod_skill_level("elona.stat_speed", self.power, "add")
      chara:mod_skill_level("elona.stat_strength", chara:skill_level("elona.stat_strength") * 150 / 100 + 10, "set")
      chara:mod_skill_level("elona.stat_dexterity", chara:skill_level("elona.stat_dexterity") * 150 / 100 + 10, "set")
      chara:mod_skill_level("elona.healing", 50, "add")
      chara:mod("pv", math.floor(chara:calc("pv") * 150 / 100 + 25), "set")
      chara:mod("dv", math.floor(chara:calc("dv") * 150 / 100 + 25), "set")
      chara:mod_skill_level("elona.stat_strength", chara:skill_level("elona.stat_strength") * 150 / 100 + 50, "set")
   end
}

make_buff {
   _id = "contingency",
   elona_id = 462,

   type = "spell",
   related_skill = "elona.stat_will",
   cost = 25,
   range = 0,
   difficulty = 1250,
   target_type = "self_or_nearby",
}
data:add {
   _id = "contingency",
   _type = "elona_sys.buff",

   type = "blessing",
   image = 18,

   params = function(self, params)
      return {
         duration = 66,
         power = math.clamp(25 + params.power/17, 25, 80)
      }
   end,

   on_refresh = function(self, chara)
      -- No-op, handled in events
   end
}

data:add {
   _id = "lucky",
   _type = "elona_sys.buff",

   type = "blessing",
   image = 19,

   params = function(self, params)
      return {
         duration = 777,
         power = params.power
      }
   end,

   on_refresh = function(self, chara)
      chara:mod_skill_level("elona.stat_luck", self.power, "add")
   end
}

local function make_food_buff(opts)
   data:add {
      _id = opts._id,
      _type = "elona_sys.buff",

      type = "food",
      image = opts.image,

      params = function(self, params)
         return {
            duration = 10 + params.power / 10,
            power = params.power
         }
      end,

      on_refresh = function(self, chara)
         chara.temp.growth_buffs = chara.temp.growth_buffs or {}
         chara.temp.growth_buffs[opts.skill_id] = self.power
      end
   }
end

make_food_buff {
   _id = "food_str",

   image = 20,
   skill_id = "elona.stat_strength"
}

make_food_buff {
   _id = "food_end",

   image = 21,
   skill_id = "elona.stat_constitution"
}

make_food_buff {
   _id = "food_dex",

   image = 22,
   skill_id = "elona.stat_dexterity"
}

make_food_buff {
   _id = "food_per",

   image = 23,
   skill_id = "elona.stat_perception"
}
make_food_buff {
   _id = "food_ler",

   image = 24,
   skill_id = "elona.stat_learning"
}

make_food_buff {
   _id = "food_wil",

   image = 25,
   skill_id = "elona.stat_will"
}

make_food_buff {
   _id = "food_mag",

   image = 26,
   skill_id = "elona.stat_magic"
}

make_food_buff {
   _id = "food_chr",

   image = 27,
   skill_id = "elona.stat_charisma"
}

make_food_buff {
   _id = "food_spd",

   image = 28,
   skill_id = "elona.stat_speed"
}
