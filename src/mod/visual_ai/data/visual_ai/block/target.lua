local UidTracker = require("api.UidTracker")

local order = UidTracker:new(20000)

data:add {
   _type = "visual_ai.block",
   _id = "target_player",

   type = "target",
   vars = {},

   ordering = order:get_next_and_increment(),

   -- format_name = function(self)
   --    return I18N.get("visual_ai.block." .. self._id .. ".name")
   -- end,

   target_source = "character",

   target_filter = function(self, chara, candidate)
      return candidate:is_player()
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "target_inventory",

   type = "target",
   icon = "visual_ai.icon_diamond",
   color = {100, 100, 180},
   vars = {},

   ordering = order:get_next_and_increment(),

   -- format_name = function(self)
   --    return I18N.get("visual_ai.block." .. self._id .. ".name")
   -- end,

   target_source = "items_on_self",

   target_filter = function(self, chara, candidate)
      return chara:has_item_in_inventory(candidate)
   end
}
