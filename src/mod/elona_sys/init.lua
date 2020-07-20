local CodeGenerator = require("api.CodeGenerator")

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
add_elona_id("base.map_template")
add_elona_id("base.portrait")


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
   fields = {
      {
         name = "params",
         default = { "source" },
         template = true,
         type = "table",
doc = [[
   The parameters this magic accepts.

   Currently used purely for documentation purposes. Might be redundant.
]]
      },
      {
         name = "dice",
         default = CodeGenerator.gen_literal [[
function(self, params)
  local level = params.source:skill_level("my_mod.some_magic")
  return {
    x = params.power * 10,
    y = level * 10,
    bonus = 50,
  }
end
]],
         type = "function(elona_sys.magic, table)",
         doc = [[
The dice indicating the relative strength of this magic. Has this format:
]]
      },
      {
         name = "cast",
         default = CodeGenerator.gen_literal [[
function(self, params)
   local source = params.source
   local target = params.target
   local map = params.source:current_map()

   return true
end]],
         template = true,
         type = "function(elona_sys.magic, table)",
doc = [[
   Runs arbitrary AI actions. Is passed the character and extra parameters, differing depending on the action.

   Returns true if the character acted, false if not.
]]
      },
   },
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

data:add_type {
   name = "scene",
   schema = schema.Record {
   }
}


require("mod.elona_sys.data.event")

require("mod.elona_sys.map_tileset.init")
require("mod.elona_sys.dialog.init")
require("mod.elona_sys.deferred_event.init")
require("mod.elona_sys.bindable_event.init")

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
   north = function(_, me)
      return Command.move(me, "North")
   end,
   south = function(_, me)
      return Command.move(me, "South")
   end,
   west = function(_, me)
      return Command.move(me, "West")
   end,
   east = function(_, me)
      return Command.move(me, "East")
   end,
   northwest = function(_, me)
      return Command.move(me, "Northwest")
   end,
   northeast = function(_, me)
      return Command.move(me, "Northeast")
   end,
   southwest = function(_, me)
      return Command.move(me, "Southwest")
   end,
   southeast = function(_, me)
      return Command.move(me, "Southeast")
   end,
   get = function(_, me)
      return Command.get(me)
   end,
   wear = function(_, me)
      return Command.wear(me)
   end,
   drop = function(_, me)
      return Command.drop(me)
   end,
   close = function(_, me)
      return Command.close(me)
   end,
   open = function(_, me)
      return Command.open(me)
   end,
   search = function(_, me)
      return Command.search(me)
   end,
   enter = function(_, me)
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
   end,
   cast = function(_, me)
      return Command.cast(me)
   end,
   skill = function(_, me)
      return Command.skill(me)
   end,
   target = function(_, me)
      return Command.target(me)
   end,
   look = function(_, me)
      return Command.look(me)
   end,
   quick_menu = function(_, me)
      return Command.quick_menu(me)
   end
}
