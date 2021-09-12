local I18N = require("api.I18N")
local utils = require("mod.visual_ai.internal.utils")
local Pos = require("api.Pos")
local ElonaAction = require("mod.elona.api.ElonaAction")
local Const = require("api.Const")
local Rand = require("api.Rand")

data:add {
   _type = "visual_ai.block",
   _id = "condition_target_in_sight",

   type = "condition",
   vars = {},

   condition = function(self, chara, target, ty)
      return chara:has_los(target.x, target.y)
         and Pos.dist(chara.x, chara.y, target.x, target.y) <= chara:calc("fov") / 2
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "condition_hp_mp_sp_threshold",

   type = "condition",
   vars = {
      kind = { type = "enum", choices = { "hp", "mp", "stamina" }},
      comparator = utils.vars.comparator,
      threshold = { type = "integer", min_value = 0, max_value = 100, default = 100, increment_amount = 10 }
   },

   format_name = function(proto, vars)
      return I18N.get("visual_ai.block." .. proto._id .. ".name", "visual_ai.var.hp_mp_sp." .. vars.kind, vars.comparator, vars.threshold)
   end,

   condition = function(self, chara, target)
      local max_var = utils.hp_mp_sp_var(self.vars.kind)
      local ratio = (chara[self.vars.kind] / chara:calc(max_var)) * 100
      return utils.compare(ratio, self.vars.comparator, self.vars.threshold)
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "condition_can_do_melee_attack",

   type = "condition",
   vars = {},

   condition = function(self, chara, target)
      return Pos.dist(target.x, target.y, chara.x, chara.y) <= 1
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "condition_can_do_ranged_attack",

   type = "condition",
   vars = {},

   condition = function(self, chara, target)
      local ranged, ammo = ElonaAction.get_ranged_weapon_and_ammo(chara)
      if not ranged then
         return false
      end

      return Pos.dist(target.x, target.y, chara.x, chara.y) < Const.AI_RANGED_ATTACK_THRESHOLD
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "condition_target_tile_dist",

   type = "condition",
   vars = {
      comparator = utils.vars.comparator,
      threshold = { type = "integer", min_value = 0, default = 3 }
   },

   format_name = function(proto, vars)
      return I18N.get("visual_ai.block." .. proto._id .. ".name", vars.comparator, vars.threshold)
   end,

   condition = function(self, chara, target)
      return utils.compare(Pos.dist(chara.x, chara.y, target.x, target.y), self.vars.comparator, self.vars.threshold)
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "condition_skill_in_range",

   type = "condition",
   vars = {
      skill_id = utils.vars.known_skill
   },

   format_name = function(proto, vars)
      local name
      if vars.skill_id == "none" then
         name = "<none>"
      else
         name = I18N.localize("base.skill", vars.skill_id, "name")
      end
      return I18N.get("visual_ai.block." .. proto._id .. ".name", name)
   end,

   condition = function(self, chara, target)
      if self.vars.skill_id == "none" then
         return false
      end
      local skill_proto = data["base.skill"]:ensure(self.vars.skill_id)

      if skill_proto.type ~= "spell" then
         return false
      end

      local range = assert(skill_proto.range, "range not defined for spell?")

      return Pos.dist(chara.x, chara.y, target.x, target.y) <= range
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "condition_random_chance",

   type = "condition",
   vars = {
      chance = { type = "integer", min_value = 0, max_value = 100, default = 50, increment_amount = 10 }
   },

   format_name = function(proto, vars)
      return I18N.get("visual_ai.block." .. proto._id .. ".name", vars.chance)
   end,

   condition = function(self, chara, target, ty)
      return Rand.percent_chance(self.vars.chance)
   end
}
