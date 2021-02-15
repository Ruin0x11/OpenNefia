local UidTracker = require("api.UidTracker")
local Enum = require("api.Enum")
local Pos = require("api.Pos")

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
   color = {180, 100, 80},
   icon = "visual_ai.icon_multiplayer",

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
   color = {180, 100, 80},
   icon = "visual_ai.icon_multiplayer",

   ordering = order:get_next_and_increment(),

   target_order = function(self, chara, candidate_a, candidate_b)
      return Pos.dist(chara.x, chara.y, candidate_a.x, candidate_a.y)
         > Pos.dist(chara.x, chara.y, candidate_b.x, candidate_b.y)
   end
}
