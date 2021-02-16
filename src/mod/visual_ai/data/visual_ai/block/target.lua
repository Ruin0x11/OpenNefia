local UidTracker = require("api.UidTracker")
local Enum = require("api.Enum")
local Pos = require("api.Pos")
local I18N = require("api.I18N")
local Chara = require("api.Chara")
local utils = require("mod.visual_ai.internal.utils")

local order = UidTracker:new(20000)

data:add {
   _type = "visual_ai.block",
   _id = "target_player",

   type = "target",
   color = {80, 100, 180},
   icon = "visual_ai.icon_singleplayer",

   ordering = order:get_next_and_increment(),

   target_source = "character",

   target_filter = function(self, chara, candidate)
      return candidate:is_player()
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "target_self",

   type = "target",
   color = {80, 100, 180},
   icon = "visual_ai.icon_singleplayer",

   ordering = order:get_next_and_increment(),

   target_source = "character",

   target_filter = function(self, chara, candidate)
      return candidate == chara
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "target_allies",

   type = "target",
   color = {80, 100, 180},
   icon = "visual_ai.icon_multiplayer",

   ordering = order:get_next_and_increment(),

   target_source = "character",

   target_filter = function(self, chara, candidate)
      return chara:relation_towards(candidate) == Enum.Relation.Ally
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "target_enemies",

   type = "target",
   color = {180, 100, 80},
   icon = "visual_ai.icon_multiplayer",

   ordering = order:get_next_and_increment(),

   target_source = "character",

   target_filter = function(self, chara, candidate)
      return chara:relation_towards(candidate) == Enum.Relation.Enemy
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "target_characters",

   type = "target",
   color = {180, 180, 80},
   icon = "visual_ai.icon_multiplayer",

   ordering = order:get_next_and_increment(),

   target_source = "character",

   target_filter = function(self, chara, candidate)
      return Chara.is_alive(chara)
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "target_ground_items",

   type = "target",
   color = {50, 180, 100},
   icon = "visual_ai.icon_diamond",

   ordering = order:get_next_and_increment(),

   target_source = "items_on_ground",

   target_filter = function(self, chara, candidate)
      return true
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "target_inventory",

   type = "target",
   icon = "visual_ai.icon_diamond",
   color = {50, 180, 100},
   vars = {},

   ordering = order:get_next_and_increment(),

   target_source = "items_on_self",

   target_filter = function(self, chara, candidate)
      return chara:has_item_in_inventory(candidate)
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "target_hp_mp_sp_threshold",

   type = "target",
   color = {140, 100, 140},
   icon = "visual_ai.icon_dpad",
   vars = {
      kind = { type = "enum", choices = { "hp", "mp", "stamina" }},
      comparator = utils.vars.comparator,
      threshold = { type = "integer", min_value = 0, max_value = 100, default = 100, increment_amount = 10 }
   },
   ordering = order:get_next_and_increment(),

   applies_to = "map_object",

   format_name = function(proto, vars)
      return I18N.get("visual_ai.block." .. proto._id .. ".name", "visual_ai.var.hp_mp_sp." .. vars.kind, vars.comparator, vars.threshold)
   end,

   target_filter = function(self, chara, candidate)
      if candidate._type ~= "base.chara" or not Chara.is_alive(candidate) then
         return false
      end

      local max_var = utils.hp_mp_sp_var(self.vars.kind)
      local ratio = (candidate[self.vars.kind] / candidate:calc(max_var)) * 100
      print(candidate[self.vars.kind], candidate:calc(max_var), ratio)
      return utils.compare(ratio, self.vars.comparator, self.vars.threshold)
   end,
}

data:add {
   _type = "visual_ai.block",
   _id = "target_order_nearest",

   type = "target",
   color = {140, 100, 140},
   icon = "visual_ai.icon_return",

   ordering = order:get_next_and_increment(),

   target_order = function(self, chara, candidate_a, candidate_b)
      return Pos.dist(chara.x, chara.y, candidate_a.x, candidate_a.y)
         < Pos.dist(chara.x, chara.y, candidate_b.x, candidate_b.y)
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "target_order_furthest",

   type = "target",
   color = {140, 100, 140},
   icon = "visual_ai.icon_return",

   ordering = order:get_next_and_increment(),

   target_order = function(self, chara, candidate_a, candidate_b)
      return Pos.dist(chara.x, chara.y, candidate_a.x, candidate_a.y)
         > Pos.dist(chara.x, chara.y, candidate_b.x, candidate_b.y)
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "target_order_hp_mp_sp",

   type = "target",
   color = {140, 100, 140},
   icon = "visual_ai.icon_dpad",
   vars = {
      kind = { type = "enum", choices = { "hp", "mp", "stamina" }},
      comparator = utils.vars.comparator_partial,
   },
   ordering = order:get_next_and_increment(),

   applies_to = "map_object",

   format_name = function(proto, vars)
      local root = "visual_ai.block." .. proto._id
      return I18N.get(root .. ".name", root .. ".comparator." .. vars.comparator, "visual_ai.var.hp_mp_sp." .. vars.kind)
   end,

   target_order = function(self, chara, candidate_a, candidate_b)
      local max_var = utils.hp_mp_sp_var(self.vars.kind)
      print(inspect(self))
      local ratio_a = (candidate_a[self.vars.kind] / candidate_a:calc(max_var)) * 100
      local ratio_b = (candidate_b[self.vars.kind] / candidate_b:calc(max_var)) * 100
      return utils.compare(ratio_a, self.vars.comparator, ratio_b)
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "target_stored",

   type = "target",
   color = {100, 40, 100},
   icon = "visual_ai.icon_singleplayer",

   ordering = order:get_next_and_increment(),

   target_source = "any",

   target_filter = function(self, chara, candidate, ty)
      local target = chara:get_mod_data("visual_ai").stored_target
      return Chara.is_alive(target) and candidate == target
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "target_player_targeting_character",

   type = "target",
   color = {100, 40, 100},
   icon = "visual_ai.icon_singleplayer",

   ordering = order:get_next_and_increment(),

   target_source = "character",

   target_filter = function(self, chara, candidate)
      local player = Chara.player()
      local target = player:get_target() or player
      return Chara.is_alive(target) and candidate == target
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "target_set_position",

   type = "target",
   color = {160, 160, 130},
   icon = "visual_ai.icon_home",
   vars = {
      x = { type = "integer", min_value = 0 },
      y = { type = "integer", min_value = 0 },
   },

   ordering = order:get_next_and_increment(),

   format_name = function(proto, vars)
      return I18N.get("visual_ai.block." .. proto._id .. ".name", vars.x, vars.y)
   end,

   target_source = "position",

   target_filter = function(self, chara, candidate)
      return candidate.x == self.vars.x and candidate.y == self.vars.y
   end
}

data:add {
   _type = "visual_ai.block",
   _id = "target_player_targeting_position",

   type = "target",
   color = {160, 160, 130},
   icon = "visual_ai.icon_target",

   ordering = order:get_next_and_increment(),

   target_source = "position",

   target_filter = function(self, chara, candidate)
      local player = Chara.player()
      local loc = player.target_location
      if loc == nil then
         local target = player:get_target()
         if target then
            loc = { x = target.x, y = target.y }
         else
            loc = { x = player.x, y = player.y }
         end
      end
      return candidate.x == loc.x and candidate.y == loc.y
   end
}
