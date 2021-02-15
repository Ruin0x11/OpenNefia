local I18N = require("api.I18N")
local utils = require("mod.visual_ai.internal.utils")

data:add {
   _type = "visual_ai.block",
   _id = "condition_hp_threshold",

   type = "condition",
   vars = {
      comparator = { type = "comparator" },
      threshold = { type = "integer", min_value = 0, max_value = 100 }
   },

   format_name = function(self)
      return I18N.get("visual_ai.block." .. self._id .. ".name", self.vars.comparator, self.vars.threshold)
   end,

   condition = function(self, chara, targets)
      local ratio = (chara.hp / chara:calc("max_hp")) * 100
      return utils.compare(ratio, self.vars.comparator, self.vars.threshold)
   end
}
