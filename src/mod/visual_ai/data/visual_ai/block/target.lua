data:add {
   _type = "visual_ai.block",
   _id = "target_inventory",

   type = "target",
   vars = {},

   -- format_name = function(self)
   --    return I18N.get("visual_ai.block." .. self._id .. ".name")
   -- end,

   target_source = "items_on_self",

   target_filter = function(self, chara, candidate)
      return chara:has_item_in_inventory(candidate)
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "target_player",

   type = "target",
   vars = {},

   -- format_name = function(self)
   --    return I18N.get("visual_ai.block." .. self._id .. ".name")
   -- end,

   target_source = "character",

   target_filter = function(self, chara, candidate)
      return candidate:is_player()
   end
}
