data:extend_type(
   "base.element",
   {
      preserves_sleep = schema.Boolean,
      sound = schema.Optional(schema.String),
   }
)

data:extend_type(
   "base.chara",
   {
      splits = schema.Boolean,
      splits2 = schema.Boolean,
      is_quick_tempered = schema.Boolean,
      has_lay_hand = schema.Boolean,
      is_lay_hand_available = schema.Boolean,
      cut_counterattack = schema.Number
   }
)

require("mod.elona.init.god")

require("mod.elona.dungeon_template")

require("mod.elona.data")

require("mod.elona.events")

local Gui = require("api.Gui")
local ElonaCommand = require("mod.elona.api.ElonaCommand")

Gui.bind_keys {
   bash = function(me)
      return ElonaCommand.bash(me)
   end,
   eat = function(me)
      return ElonaCommand.eat(me)
   end,
   fire = function(me)
      return ElonaCommand.fire(me)
   end,
   dig = function(me)
      return ElonaCommand.dig(me)
   end,
   read = function(me)
      return ElonaCommand.read(me)
   end,
   drink = function(me)
      return ElonaCommand.drink(me)
   end,
   zap = function(me)
      return ElonaCommand.zap(me)
   end,
}
