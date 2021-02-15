local UidTracker = require("api.UidTracker")
local Enum = require("api.Enum")
local Pos = require("api.Pos")
local I18N = require("api.I18N")
local Chara = require("api.Chara")

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
      return candidate:is_ally()
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
   _id = "target_stored",

   type = "target",
   color = {100, 40, 100},
   icon = "visual_ai.icon_singleplayer",

   ordering = order:get_next_and_increment(),

   target_source = "any",

   target_filter = function(self, chara, candidate, ty)
      return candidate == chara:get_mod_data("visual_ai").stored_target
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
      return candidate == target
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
