local AiUtil = require("mod.elona.api.AiUtil")
local Action = require("api.Action")
local UidTracker = require("api.UidTracker")
local Pos = require("api.Pos")
local I18N = require("api.I18N")
local Magic = require("mod.elona.api.Magic")
local utils = require("mod.visual_ai.internal.utils")
local ElonaAction = require("mod.elona.api.ElonaAction")
local Const = require("api.Const")
local Itemgen = require("mod.tools.api.Itemgen")
local Rand = require("api.Rand")
local Filters = require("mod.elona.api.Filters")
local Item = require("api.Item")

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
         if chara == target then
            return false
         end

         local map = chara:current_map()
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
   _id = "action_move_within_distance",

   type = "action",

   is_terminal = true,
   vars = {
      threshold = { type = "integer", min_value = 0, default = 3 }
   },
   ordering = order:get_next_and_increment(),

   format_name = function(proto, vars)
      return I18N.get("visual_ai.block." .. proto._id .. ".name", vars.threshold)
   end,

   action = function(self, chara, target, ty)
      if ty == "map_object" then
         if chara == target then
            return false
         end

         local map = chara:current_map()
         local min_dist = self.vars.threshold
         if not map:can_access(target.x, target.y) then
            min_dist = math.max(min_dist, 2)
         end
         if Pos.dist(chara.x, chara.y, target.x, target.y) < min_dist then
            return true
         end

         return AiUtil.move_towards_target(chara, target, false)
      elseif ty == "position" then
         return AiUtil.go_to_position(chara, target.x, target.y, self.vars.threshold)
      end
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "action_move_until_skill_in_range",

   type = "action",

   is_terminal = true,
   vars = {
      skill_id = utils.vars.known_skill
   },
   ordering = order:get_next_and_increment(),

   format_name = function(proto, vars)
      local name
      if vars.skill_id == "none" then
         name = "<none>"
      else
         name = "ability." .. vars.skill_id .. ".name"
      end
      return I18N.get("visual_ai.block." .. proto._id .. ".name", name)
   end,

   action = function(self, chara, target, ty)
      if self.vars.skill_id == "none" then
         return false
      end

      local skill_proto = data["base.skill"]:ensure(self.vars.skill_id)
      local range = assert(skill_proto.range, "range not defined for spell?")

      if ty == "map_object" then
         if chara == target then
            return false
         end

         local map = chara:current_map()
         if not map:can_access(target.x, target.y) then
            range = math.max(range, 2)
         end
         if Pos.dist(chara.x, chara.y, target.x, target.y) < range then
            return true
         end

         return AiUtil.move_towards_target(chara, target, false)
      elseif ty == "position" then
         return AiUtil.go_to_position(chara, target.x, target.y, range)
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
         if chara == target then
            return false
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
   _id = "action_retreat_until_distance",

   type = "action",

   is_terminal = true,
   vars = {
      threshold = { type = "integer", min_value = 0, default = 3 }
   },
   ordering = order:get_next_and_increment(),

   format_name = function(proto, vars)
      return I18N.get("visual_ai.block." .. proto._id .. ".name", vars.threshold)
   end,

   action = function(self, chara, target, ty)
      if ty == "map_object" then
         if chara == target then
            return false
         end

         if Pos.dist(chara.x, chara.y, target.x, target.y) >= self.vars.threshold then
            return true
         end

         return AiUtil.move_towards_target(chara, target, true)
      elseif ty == "position" then
         if Pos.dist(chara.x, chara.y, target.x, target.y) >= self.vars.threshold then
            return true
         end

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
   _id = "action_melee_attack",

   type = "action",
   color = {180, 50, 50},
   icon = "visual_ai.icon_fight_fist",
   vars = {},

   is_terminal = true,
   ordering = order:get_next_and_increment(),

   applies_to = "map_object",

   action = function(self, chara, target, ty)
      local dist = Pos.dist(target.x, target.y, chara.x, chara.y)
      if dist > 1 then
         return false
      end

      ElonaAction.melee_attack(chara, target)
      return true
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "action_ranged_attack",

   type = "action",
   color = {180, 50, 50},
   icon = "visual_ai.icon_fight_fist",
   vars = {},

   is_terminal = true,
   ordering = order:get_next_and_increment(),

   applies_to = "map_object",

   action = function(self, chara, target, ty)
      local ranged, ammo = ElonaAction.get_ranged_weapon_and_ammo(chara)
      if not ranged then
         return false
      end

      local dist = Pos.dist(target.x, target.y, chara.x, chara.y)
      if dist >= Const.AI_RANGED_ATTACK_THRESHOLD then
         return false
      end

      ElonaAction.ranged_attack(chara, target, ranged, ammo)
      return true
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "action_cast_spell",

   type = "action",
   color = {180, 50, 50},
   icon = "visual_ai.icon_fight_fist",
   vars = {
      skill_id = utils.vars.known_skill
   },

   is_terminal = true,
   ordering = order:get_next_and_increment(),

   applies_to = "map_object",

   format_name = function(proto, vars)
      local name
      if vars.skill_id == "none" then
         name = "<none>"
      else
         name = "ability." .. vars.skill_id .. ".name"
      end
      return I18N.get("visual_ai.block." .. proto._id .. ".name", name)
   end,

   action = function(self, chara, target, ty)
      if self.vars.skill_id == "none" then
         return
      end

      chara:set_target(target)
      return Magic.cast_spell(self.vars.skill_id, chara, true)
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
   _id = "action_throw_potion",

   type = "action",
   vars = {},

   is_terminal = true,
   color = {50, 180, 100},
   icon = "visual_ai.icon_diamond",
   ordering = order:get_next_and_increment(),

   applies_to = "any",

   action = function(self, chara, target, ty)
      local dist = Pos.dist(target.x, target.y, chara.x, chara.y)
      if dist < Const.AI_THROWING_ATTACK_THRESHOLD and chara:has_los(target.x, target.y) then
         local potion = Itemgen.create(nil, nil, { amount = 1, categories = "elona.drink", id = Rand.choice(Filters.isetthrowpotionmajor) }, chara)
         if potion then
            ElonaAction.throw(chara, potion, target.x, target.y)
         end
         return true
      end
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "action_throw_monster_ball",

   type = "action",
   vars = {},

   is_terminal = true,
   color = {100, 50, 180},
   icon = "visual_ai.icon_target",
   ordering = order:get_next_and_increment(),

   applies_to = "any",

   action = function(self, chara, target, ty)
      local dist = Pos.dist(target.x, target.y, chara.x, chara.y)
      if dist < Const.AI_THROWING_ATTACK_THRESHOLD and chara:has_los(target.x, target.y) then
         local item = Item.create("elona.monster_ball", nil, nil, {}, chara)
         if item then
            item.params.monster_ball_max_level = 10
            ElonaAction.throw(chara, item, target.x, target.y)
         end
         return true
      end
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "action_store_target",

   type = "action",
   vars = {},

   is_terminal = false,
   color = {100, 40, 100},
   icon = "visual_ai.icon_download",
   ordering = order:get_next_and_increment(),

   applies_to = "map_object",

   action = function(self, chara, target)
      local ext = chara:get_mod_data("visual_ai")
      ext.stored_target = target

      return true
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "action_wander",

   type = "action",
   vars = {},

   is_terminal = true,
   color = {180, 140, 100},
   icon = "visual_ai.icon_flag",
   ordering = order:get_next_and_increment(),

   applies_to = "any",

   action = function(self, chara, target, ty)
      local map = chara:current_map()
      local nx, ny = Pos.random_direction(chara.x, chara.y)
      if map:can_access(nx, ny) then
         Action.move(chara, nx, ny)
      end
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
