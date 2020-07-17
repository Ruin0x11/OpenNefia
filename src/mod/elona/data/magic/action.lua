local Event = require("api.Event")
local Effect = require("mod.elona.api.Effect")
local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Anim = require("mod.elona_sys.api.Anim")
local I18N = require("api.I18N")
local Map = require("api.Map")
local Chara = require("api.Chara")
local Enum = require("api.Enum")

data:add {
   _id = "action_pregnant",
   _type = "base.skill",
   elona_id = 626,

   type = "action",
   effect_id = "elona.pregnant",
   related_skill = "elona.stat_perception",
   cost = 15,
   range = 1,
   difficulty = 0,
   target_type = "enemy"
}
data:add {
   _id = "pregnant",
   _type = "elona_sys.magic",
   elona_id = 626,

   type = "action",
   params = {
      "source",
      "target",
   },

   cast = function(self, params)
      if params.target:is_in_fov() then
         Gui.mes_visible("magic.pregnant", params.target, params.source)
      end

      Effect.impregnate(params.target)

      return true
   end
}

local function proc_pregnancy(chara)
   if not chara:calc("is_pregnant") then
      return
   end

   if Rand.one_in(15) then
      if chara:is_in_fov() then
         Gui.mes("misc.pregnant.pats_stomach", chara)
         Gui.mes(I18N.quote_speech("misc.pregnant.something_is_wrong"))
      end
   end

   local map = chara:current_map()
   if not Map.is_world_map(map) and Rand.one_in(30) then
      Gui.mes_visible("misc.pregnant.something_breaks_out", chara)
      chara:apply_effect("elona.bleeding", 15)
      local level = chara:calc("level") / 2 + 1
      local alien = Chara.create("elona.alien", chara.x, chara.y, { level = level }, map)
      if alien then
         if utf8.wide_len(chara.name) > 10 or string.match(chara.name, I18N.get("chara.job.alien.child")) then
            alien.name = I18N.get("chara.job.alien.alien_kid")
         else
            alien.name = I18N.get("chara.job.alien.child_of", chara.name)
         end
      end
   end
end

local function event_pregnancy(source, params, result)
   if result and result.blocked then
      return result
   end

   if source.turns_alive % 25 == 0 then
      proc_pregnancy(source)
   end

   return result
end
Event.register("base.on_chara_pass_turn", "Proc pregnancy", event_pregnancy)

-- fov

-- attack

data:add {
   _id = "action_eye_of_insanity",
   _type = "base.skill",
   elona_id = 636,

   type = "action",
   effect_id = "elona.eye_of_insanity",
   related_skill = "elona.stat_charisma",
   cost = 10,
   range = 2,
   difficulty = 0,
   target_type = "enemy"
}
data:add {
   _id = "eye_of_insanity",
   _type = "elona_sys.magic",
   elona_id = 636,

   params = {
      "source",
      "target",
   },

   dice = function(self, params)
      local level = params.source:skill_level("elona.action_eye_of_insanity")
      return {
         x = 1 + level / 20,
         y = 10 + 1,
         bonus = 0
      }
   end,

   cast = function(self, params)
      local source = params.source
      local target = params.target

      Gui.mes_c("magic.insanity", "Purple", source, target)

      local dice = self:dice(params)
      local damage = Rand.roll_dice(dice.x, dice.y, dice.bonus)

      Effect.damage_insanity(target, damage)

      return true
   end
}

data:add {
   _id = "action_harvest_mana",
   _type = "base.skill",
   elona_id = 621,

   type = "action",
   effect_id = "elona.harvest_mana",
   related_skill = "elona.stat_magic",
   cost = 10,
   range = 0,
   difficulty = 700,
   target_type = "self_or_nearby"
}
data:add {
   _id = "harvest_mana",
   _type = "elona_sys.magic",
   elona_id = 621,

   params = {
      "source",
      "target",
   },

   cast = function(self, params)
      local source = params.source
      local target = params.target

      target:heal_mp(params.power / 2 + Rand.rnd(params.power / 2 + 1))

      if target:is_in_fov() then
         Gui.mes("magic.harvest_mana", target)
         local cb = Anim.heal(target.x, target.y, "base.heal_effect", "base.heal1")
         Gui.start_draw_callback(cb)
      end
   end
}

data:add {
   _id = "action_absorb_magic",
   _type = "base.skill",
   elona_id = 624,

   type = "action",
   effect_id = "elona.absorb_magic",
   related_skill = "elona.stat_magic",
   cost = 25,
   range = 0,
   difficulty = 0,
   target_type = "self"
}
data:add {
   _id = "absorb_magic",
   _type = "elona_sys.magic",
   elona_id = 624,

   params = {
      "source",
      "target",
   },

   dice = function(self, params)
      local level = params.source:skill_level("elona.action_absorb_magic")
      local piety = params.source:calc("piety")
      return {
         x = 1 + level / 20,
         y = piety / 140 + 1 + 1,
         bonus = 0
      }
   end,

   cast = function(self, params)
      local source = params.source
      local target = params.target

      local dice = self:dice(params)

      target:heal_mp(Rand.roll_dice(dice.x, dice.y, dice.bonus))

      if target:is_in_fov() then
         Gui.mes("magic.absorb_magic", target)
         local cb = Anim.heal(target.x, target.y, "base.heal_effect", "base.heal1")
         Gui.start_draw_callback(cb)
      end
   end
}

data:add {
   _id = "action_drain_blood",
   _type = "base.skill",
   elona_id = 601,

   type = "action",
   effect_id = "elona.drain_blood",
   related_skill = "elona.stat_dexterity",
   cost = 7,
   range = 1,
   difficulty = 0,
   target_type = "enemy"
}
data:add {
   _id = "drain_blood",
   _type = "elona_sys.magic",
   elona_id = 601,

   params = {
      "source",
      "target",
   },

   dice = function(self, params)
      local level = params.source:skill_level("elona.action_drain_blood")
      return {
         x = 1 + level / 15,
         y = 6 + 1,
         bonus = level / 4,
         element = "elona.nether",
         element_power = 200
      }
   end,

   cast = function(self, params)
      local source = params.source
      local target = params.target

      local tense = "enemy"

      local cast_style = source:calc("cast_style")
      if cast_style then
         if source:is_player() then
            Gui.mes_visible("action.cast.self", source, "ability." .. self._id .. ".name")
         else
            Gui.mes_visible("action.cast.other", source, "ui.cast_style." .. cast_style)
         end
      else
         if target:is_allied() then
            Gui.mes_visible("magic.sucks_blood.ally", source, target)
         else
            tense = "ally"
            Gui.mes_visible("magic.sucks_blood.other", source, target)
         end
      end

      local dice = self:dice(params)

      local damage = Rand.roll_dice(dice.x, dice.y, dice.bonus)
      target:damage_hp(damage, source,
                       {
                          element = dice.element,
                          element_power = dice.element_power,
                          message_tense = tense,
                          no_attack_text = true
      })

      return true
   end
}

local function make_touch(opts)
   local full_id = "elona.action_" .. opts._id
   data:add {
      _id = "action_" .. opts._id,
      _type = "base.skill",
      elona_id = opts.elona_id,

      type = "action",
      effect_id = "elona." .. opts._id,
      related_skill = opts.related_skill,
      cost = 10,
      range = 0,
      difficulty = 0,
      target_type = "direction"
   }
   data:add {
      _id = opts._id,
      _type = "elona_sys.magic",
      elona_id = opts.elona_id,

      params = {
         "source",
         "target",
      },

      dice = function(self, params)
         local level = params.source:skill_level(full_id)
         return opts.dice(params.power, level)
      end,

      cast = function(self, params)
         local source = params.source
         local target = params.target

         local tense = "enemy"

         local dice = self:dice(params)
         local element = dice.element

         local cast_style = source:calc("cast_style")
         if cast_style then
            if source:is_player() then
               Gui.mes_visible("action.cast.self", source, "ability." .. self._id .. ".name")
            else
               Gui.mes_visible("action.cast.other", source, "ui.cast_style." .. cast_style)
            end
         else
            local element_adj = I18N.get("element.damage." .. element .. ".name")
            local melee_style = source:calc("melee_style") or "default"
            local melee_text
            if target:is_allied() then
               melee_text = I18N.get("damage.melee." .. melee_style .. ".ally")
               Gui.mes_visible("magic.touch.ally", source, target, element_adj, melee_text)
            else
               tense = "ally"
               melee_text = I18N.get("damage.melee." .. melee_style .. ".other")
               Gui.mes_visible("magic.touch.other", source, target, element_adj, melee_text)
            end
         end

         -- Some of the actions have special names for the melee damage type
         -- ("silky", "rotten") but don't actually exist as elemental damage
         -- types. If so then don't use an elemental type for them.
         if not data["base.element"][element] then
            element = nil
         end

         local damage = Rand.roll_dice(dice.x, dice.y, dice.bonus)
         target:damage_hp(damage, source,
                          {
                             element = element,
                             element_power = dice.element_power,
                             message_tense = tense,
                             no_attack_text = true
         })

         opts.on_damage(self, params, dice)

         return true
      end
   }
end

make_touch {
   _id = "touch_of_weakness",
   elona_id = 613,

   related_skill = "elona.stat_magic",

   dice = function(p, l)
      return {
         x = 1 + l / 10,
         y = 3 + 1,
         bonus = 0,
         element = "elona.rotten"
      }
   end,

   on_damage = function(self, params, dice)
      local target = params.target
      local attribute = Rand.choice(config["base._basic_attributes"])
      local sustains_enchantment = "" -- TODO enchantment: sustains attribute
      local proceed = true
      if (target:calc("quality") >= Enum.Quality.Miracle and Rand.one_in(4))
         or target:has_enchantment(sustains_enchantment)
      then
         proceed = false
      end

      if proceed then
         local adj = target:stat_adjustment(attribute)
         local diff = target:base_skill_level(attribute) - adj
         if diff > 0 then
            diff = diff * params.power / 2000 + 1
            target:set_stat_adjustment(attribute, adj - diff)
         end
         Gui.mes_c_visible("magic.weaken", target, "Purple")
         target:refresh()
      end
   end
}

make_touch {
   _id = "touch_of_hunger",
   elona_id = 614,

   related_skill = "elona.stat_magic",

   dice = function(p, l)
      return {
         x = 1 + l / 10,
         y = 3 + 1,
         bonus = 0,
         element = "elona.starving"
      }
   end,

   on_damage = function(self, params, dice)
      local target = params.target
      target.nutrition = target.nutrition - 8 * 100
      Gui.mes_c_visible("magic.hunger", target, "Purple")
      Effect.get_hungry(target)
   end
}

make_touch {
   _id = "touch_of_poison",
   elona_id = 615,

   related_skill = "elona.stat_dexterity",

   dice = function(p, l)
      return {
         x = 1 + l / 10,
         y = 4 + 1,
         bonus = 0,
         element = "elona.poison",
         element_power = l * 4 + 20
      }
   end
}

make_touch {
   _id = "touch_of_nerve",
   elona_id = 616,

   related_skill = "elona.stat_dexterity",

   dice = function(p, l)
      return {
         x = 1 + l / 10,
         y = 3 + 1,
         bonus = 0,
         element = "elona.nerve",
         element_power = l * 4 + 20
      }
   end
}

make_touch {
   _id = "touch_of_fear",
   elona_id = 617,

   related_skill = "elona.stat_will",

   dice = function(p, l)
      return {
         x = 1 + l / 10,
         y = 3 + 1,
         bonus = 0,
         element = "elona.fearful",
         element_power = 100 + l * 2
      }
   end,

   on_damage = function(self, params, dice)
      params.target:apply_effect("elona.fear", dice.element_power)
   end
}

make_touch {
   _id = "touch_of_sleep",
   elona_id = 618,

   related_skill = "elona.stat_will",

   dice = function(p, l)
      return {
         x = 1 + l / 10,
         y = 3 + 1,
         bonus = 0,
         element = "elona.silky",
         element_power = 100 + l * 3
      }
   end,

   on_damage = function(self, params, dice)
      params.target:apply_effect("elona.sleep", dice.element_power)
   end
}
