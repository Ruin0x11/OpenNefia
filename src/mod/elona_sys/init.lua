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
add_elona_id("base.music")
add_elona_id("base.body_part")


data:add_type {
   name = "quest",
   schema = schema.Record {
   },
}

data:add_type {
   name = "quest_reward",
   schema = schema.Record {
   },
}

data:add_type {
   name = "sidequest",
   schema = schema.Record {
   },
}

data:add_type {
   name = "magic",
   schema = schema.Record {
      cast = schema.Function
   }
}

data:add_type {
   name = "basic_anim",
   schema = schema.Record {
   }
}

data:add_type {
   name = "inventory_proto",
   schema = schema.Record {
   }
}

data:add_type {
   name = "inventory_group",
   schema = schema.Record {
      protos = schema.Table
   }
}


require("mod.elona_sys.data.event")

require("mod.elona_sys.theme.init")
require("mod.elona_sys.map_loader.init")
require("mod.elona_sys.map_template.init")
require("mod.elona_sys.map_tileset.init")
require("mod.elona_sys.dialog.init")
require("mod.elona_sys.deferred_event.init")

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
   north = function(me)
      return Command.move(me, "North")
   end,
   south = function(me)
      return Command.move(me, "South")
   end,
   west = function(me)
      return Command.move(me, "West")
   end,
   east = function(me)
      return Command.move(me, "East")
   end,
   northwest = function(me)
      return Command.move(me, "Northwest")
   end,
   northeast = function(me)
      return Command.move(me, "Northeast")
   end,
   southwest = function(me)
      return Command.move(me, "Southwest")
   end,
   southeast = function(me)
      return Command.move(me, "Southeast")
   end,
   get = function(me)
      return Command.get(me)
   end,
   wear = function(me)
      return Command.wear(me)
   end,
   drop = function(me)
      return Command.drop(me)
   end,
   quick_inv = function(me)
      return Command.inventory(me)
   end,
   close = function(me)
      return Command.close(me)
   end,
   open = function(me)
      return Command.open(me)
   end,
   search = function(me)
      return Command.search(me)
   end,
   enter = function(me)
      return Command.enter_action(me)
   end,
   wait = function()
      return "turn_end"
   end,
   repl = function()
      Repl.query()
      return "player_turn_query"
   end,
   quit = function()
      return Command.quit_game()
   end,
   help = function()
      return Command.help()
   end,
   quicksave = function()
      return Command.save_game()
   end,
   quickload = function()
      return Command.load_game()
   end,
   chara_info = function()
      return Command.chara_info()
   end
}
