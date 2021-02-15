local AiUtil = require("mod.elona.api.AiUtil")
local Action = require("api.Action")

data:add {
   _type = "visual_ai.block",
   _id = "action_change_ammo",

   type = "action",
   vars = {},

   is_terminal = false,
   color = {50, 180, 100},

   -- format_name = function(self)
   --    return I18N.get("visual_ai.block." .. self._id .. ".name")
   -- end,

   action = function(self, chara, target)
      return true
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "action_equip",

   type = "action",
   vars = {},

   is_terminal = true,
   color = {50, 180, 100},

   -- format_name = function(self)
   --    return I18N.get("visual_ai.block." .. self._id .. ".name")
   -- end,

   action = function(self, chara, target)
      if target._type ~= "base.item" then
         return false
      end

      if chara:has_item_equipped(target) then
         return true
      end

      if not chara:has_item_in_inventory(target)  then
         return false
      end

      return Action.equip(chara, target)
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "action_move_close_as_possible",

   type = "action",
   vars = {},

   is_terminal = true,

   -- format_name = function(self)
   --    return I18N.get("visual_ai.block." .. self._id .. ".name")
   -- end,

   action = function(self, chara, target)
      if chara:current_map() ~= target:current_map() then
         return false
      end

      return AiUtil.move_towards_target(chara, target, false)
   end
}
