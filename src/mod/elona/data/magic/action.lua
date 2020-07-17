local Effect = require("mod.elona.api.Effect")
local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Anim = require("mod.elona_sys.api.Anim")

data:add {
   _id = "pregnancy",
   _type = "elona_sys.magic",
   elona_id = 626,

   type = "action",
   params = {
      "source",
      "target",
   },

   related_skill = "elona.stat_perception",
   cost = 15,
   range = 2001,

   cast = function(self, params)
      if params.target:is_in_fov() then
         Gui.mes("magic.pregnant", params.source, params.target)
      end

      Effect.impregnate(params.target)

      return true
   end
}

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
