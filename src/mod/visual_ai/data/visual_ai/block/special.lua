local UidTracker = require("api.UidTracker")

local order = UidTracker:new(40000)

data:add {
   _type = "visual_ai.block",
   _id = "special_clear_target",

   type = "special",
   is_terminal = false,
   color = {180, 50, 50},
   icon = "visual_ai.icon_cross",
   ordering = order:get_next_and_increment(),
}
