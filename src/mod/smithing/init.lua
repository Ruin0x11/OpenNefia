local SimpleIndicators = require("mod.simple_indicators.api.SimpleIndicators")

require("mod.smithing.data.init")

data:add_multi(
   "base.config_option",
   {
      {
         _id = "display_hammer_level",
         type = "enum",
         choices = { "no", "level", "level_and_sps", "sps" },
         default = "no",

         on_changed = function(value)
            local level = value == "level" or value == "level_and_sps"
            local sps = value == "sps" or value == "level_and_sps"
            SimpleIndicators.set_enabled("smithing.hammer_level", level)
            SimpleIndicators.set_enabled("smithing.sps", sps)
         end
      },
   }
)
