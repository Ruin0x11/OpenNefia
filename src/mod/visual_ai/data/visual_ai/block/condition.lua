local I18N = require("api.I18N")
local utils = require("mod.visual_ai.internal.utils")
local UidTracker = require("api.UidTracker")
local Pos = require("api.Pos")

local order = UidTracker:new(10000)

data:add {
   _type = "visual_ai.block",
   _id = "condition_target_in_sight",

   type = "condition",
   vars = {},
   ordering = order:get_next_and_increment(),

   condition = function(self, chara, target, ty)
      return chara:has_los(target.x, target.y)
         and Pos.dist(chara.x, chara.y, target.x, target.y) <= chara:calc("fov") / 2
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "condition_hp_threshold",

   type = "condition",
   vars = {
      comparator = utils.vars.comparator,
      threshold = { type = "integer", min_value = 0, max_value = 100, default = 100, increment_amount = 10 }
   },
   ordering = order:get_next_and_increment(),

   format_name = function(proto, vars)
      return I18N.get("visual_ai.block." .. proto._id .. ".name", vars.comparator, vars.threshold)
   end,

   condition = function(self, chara, target)
      local ratio = (chara.hp / chara:calc("max_hp")) * 100
      return utils.compare(ratio, self.vars.comparator, self.vars.threshold)
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
   ordering = order:get_next_and_increment(),

   format_name = function(proto, vars)
      return I18N.get("visual_ai.block." .. proto._id .. ".name", vars.comparator, vars.threshold)
   end,

   condition = function(self, chara, target)
      return utils.compare(Pos.dist(chara.x, chara.y, target.x, target.y), self.vars.comparator, self.vars.threshold)
   end
}
