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
   b = function(me)
      return ElonaCommand.bash(me)
   end,
   e = function(me)
      return ElonaCommand.eat(me)
   end,
   f = function(me)
      return ElonaCommand.fire(me)
   end,
   i = function(me)
      return ElonaCommand.dig(me)
   end
}
