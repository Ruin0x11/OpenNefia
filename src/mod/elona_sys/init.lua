local function add_elona_id(_type)
   data:extend_type(
      _type,
      {
         elona_id = schema.Number,
      }
   )
   data:add_index(_type, "elona_id")
end

data:extend_type(
   "base.chara",
   {
      impress = schema.Number,
      attract = schema.Number,
      on_gold_amount = schema.Function,
   }
)

data:extend_type(
   "base.item",
   {
      elona_id = schema.Number,
   }
)

data:extend_type(
   "base.skill",
   {
      elona_id = schema.Number,
   }
)

data:extend_type(
   "base.trait",
   {
      elona_id = schema.Number,
   }
)

data:extend_type(
   "base.scenario",
   {
      restrictions = schema.Table,
   }
)

data:extend_type(
   "base.feat",
   {
      elona_id = schema.Optional(schema.Number),
   }
)

add_elona_id("base.chara")
add_elona_id("base.item")
add_elona_id("base.skill")
add_elona_id("base.element")
add_elona_id("base.feat")
add_elona_id("base.element")
add_elona_id("base.sound")

require("mod.elona_sys.data.event")

require("mod.elona_sys.theme.init")
require("mod.elona_sys.map_loader.init")
require("mod.elona_sys.map_template.init")
require("mod.elona_sys.dialog.init")

require("mod.elona_sys.events")

--
--
-- keybinds
--
--

local Command = require("mod.elona_sys.api.Command")
local Gui = require("api.Gui")
local Repl = require("api.Repl")
Gui.bind_keys {
   up = function(me)
      return Command.move(me, "North")
   end,
   down = function(me)
      return Command.move(me, "South")
   end,
   left = function(me)
      return Command.move(me, "West")
   end,
   right = function(me)
      return Command.move(me, "East")
   end,
   g = function(me)
      return Command.get(me)
   end,
   w = function(me)
      return Command.wear(me)
   end,
   d = function(me)
      return Command.drop(me)
   end,
   x = function(me)
      return Command.inventory(me)
   end,
   c = function(me)
      return Command.close(me)
   end,
   o = function(me)
      return Command.open(me)
   end,
   ["return"] = function(me)
      return Command.enter_action(me)
   end,
   ["."] = function(me)
      return "turn_end"
   end,
   ["`"] = function(me)
      Repl.query()
      return "player_turn_query"
   end,
   escape = function(me)
      return Command.quit_game()
   end,
   n = function()
      Gui.mes(require("api.gui.TextPrompt"):new(16):query())
      return "player_turn_query"
   end,
   f2 = function()
      return Command.save_game()
   end,
   f3 = function()
      return Command.load_game()
   end
}
