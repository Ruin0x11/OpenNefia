local AiUtil = require("mod.elona.api.AiUtil")
local Action = require("api.Action")
local UidTracker = require("api.UidTracker")
local Pos = require("api.Pos")

local order = UidTracker:new(30000)

data:add {
   _type = "visual_ai.block",
   _id = "action_move_close_as_possible",

   type = "action",
   vars = {},

   is_terminal = true,
   ordering = order:get_next_and_increment(),

   action = function(self, chara, target, ty)
      if ty == "map_object" then
         local map = chara:current_map()
         if map ~= target:current_map() then
            return false
         end

         if chara == target then
            return false
         end

         local min_dist = 0
         if not map:can_access(target.x, target.y) then
            min_dist = 1
         end
         if Pos.dist(chara.x, chara.y, target.x, target.y) <= min_dist then
            return true
         end

         return AiUtil.move_towards_target(chara, target, false)
      elseif ty == "position" then
         if Pos.dist(chara.x, chara.y, target.x, target.y) <= 0 then
            return true
         end

         return AiUtil.go_to_position(chara, target.x, target.y, 0)
      end
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "action_retreat_from_target",

   type = "action",
   vars = {},

   is_terminal = true,
   ordering = order:get_next_and_increment(),

   applies_to = "any",

   action = function(self, chara, target, ty)
      if ty == "map_object" then
         if chara:current_map() ~= target:current_map() then
            return false
         end

         if chara == target then
            return false
         end

         if Pos.dist(chara.x, chara.y, target.x, target.y) <= 1 then
            return true
         end

         return AiUtil.move_towards_target(chara, target, true)
      elseif ty == "position" then
         local dx, dy = Pos.direction_in(chara.x, chara.y, target.x, target.y)
         local nx, ny = chara.x - dx, chara.y - dy

         local map = chara:current_map()

         if map:can_access(nx, ny) then
            Action.move(chara, nx, ny)
            return true
         end

         return false
      end
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "action_pick_up",

   type = "action",
   vars = {},

   is_terminal = true,
   color = {50, 180, 100},
   ordering = order:get_next_and_increment(),

   applies_to = "map_object",

   action = function(self, chara, target)
      print("get1")
      if chara.x ~= target.x or chara.y ~= target.y then
         return false
      end
      if chara:has_item(target)  then
         return false
      end
      print("get")

      return Action.get(chara, target)
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "action_equip",

   type = "action",
   vars = {},

   is_terminal = true,
   color = {50, 180, 100},
   ordering = order:get_next_and_increment(),

   applies_to = "map_object",

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
   _id = "action_change_ammo",

   type = "action",
   vars = {},

   is_terminal = false,
   color = {50, 180, 100},
   icon = "visual_ai.icon_joystick_right",
   ordering = order:get_next_and_increment(),

   applies_to = "map_object",

   action = function(self, chara, target)
      return true
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "action_do_nothing",

   type = "action",
   vars = {},

   is_terminal = true,
   color = {180, 140, 100},
   icon = "visual_ai.icon_stop",
   ordering = order:get_next_and_increment(),

   applies_to = "any",

   action = function(self, chara, target, ty)
      return true
   end
}
