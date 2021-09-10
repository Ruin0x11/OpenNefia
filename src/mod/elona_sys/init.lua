local InventoryContext = require("api.gui.menu.InventoryContext")
local InventoryWrapper = require("api.gui.menu.InventoryWrapper")
local InstancedMap = require("api.InstancedMap")

local ty_quest = types.table -- TODO

data:add_type {
   name = "quest",
   fields = {
      {
         name = "elona_id",
         indexed = true,
         type = types.optional(types.uint)
      },
      {
         name = "client_chara_type",
         type = types.uint,
      },
      {
         name = "reward",
         type = types.data_id("elona_sys.quest_reward")
      },
      {
         name = "reward_fix",
         type = types.uint,
      },
      {
         name = "min_fame",
         type = types.uint
      },
      {
         name = "chance",
         type = types.some(types.uint, types.callback({"client", types.table, "town", types.class(InstancedMap)}, types.number)),
      },
      {
         name = "params",
         type = types.map(types.string, types.type)
      },
      {
         name = "difficulty",
         type = types.some(types.number, types.callback({}, types.number))
      },
      {
         name = "expiration_hours",
         type = types.callback({}, types.number)
      },
      {
         name = "deadline_days",
         type = types.optional(types.callback({}, types.number))
      },
      {
         name = "calc_reward_gold",
         type = types.optional(types.callback({"quest", ty_quest, "gold", types.uint}, types.uint))
      },
      {
         name = "calc_reward_platinum",
         type = types.optional(types.callback({"quest", ty_quest, "platinum", types.uint}, types.uint))
      },
      {
         name = "calc_reward_item_count",
         type = types.optional(types.callback({"quest", ty_quest, "item_count", types.uint}, types.uint))
      },
      {
         name = "reward_count",
         type = types.optional(types.callback({"quest", ty_quest}, types.uint))
      },
      {
         name = "generate",
         type = types.callback({"quest", ty_quest, "client", types.map_object("base.chara")}, types.boolean)
      },
      {
         name = "on_accept",
         type = types.optional(types.callback({"quest", ty_quest}, {types.boolean, types.optional(types.locale_id)}))
      },
      {
         name = "on_failure",
         type = types.optional(types.callback("quest", ty_quest))
      },
      {
         name = "on_complete",
         type = types.callback({}, types.locale_id)
      },
      {
         name = "on_time_expired",
         type = types.optional(types.callback("quest", ty_quest))
      },
      {
         name = "locale_data",
         type = types.optional(types.callback({"quest", ty_quest}, types.table))
      },
      {
         name = "target_chara_uids",
         type = types.optional(types.callback({"quest", ty_quest}, types.list(types.uint)))
      },
      {
         name = "prevents_return",
         type = types.boolean,
         default = false
      },
      {
         name = "prevents_pickpocket",
         type = types.boolean,
         default = false
      }
   }
}

data:add_type {
   name = "quest_reward",
   fields = {
      {
         name = "elona_id",
         indexed = true,
         type = types.optional(types.uint)
      },
      {
         name = "generate",
         type = types.callback({"quest_reward", types.table, "quest", ty_quest})
      },
      {
         name = "localize",
         type = types.optional(types.callback({"self", types.table}, types.string))
      },
      {
         name = "params",
         type = types.map(types.string, types.type),
         default = {}
      }
   }
}

data:add_type {
   name = "sidequest",
   fields = {
      {
         name = "elona_id",
         indexed = true,
         type = types.optional(types.uint)
      },
      {
         name = "is_main_quest",
         type = types.boolean,
         default = false
      },
      {
         name = "progress",
         type = types.map(types.int, types.some(types.locale_id, types.callback({"flag", types.int}, types.string)))
      }
   }
}

-- TODO unify with definition in `base` mod
local ty_dice = types.fields_strict {
   x = types.number,
   y = types.number,
   bonus = types.number
}

local ty_magic_params = types.fields_strict {
   source = types.optional(types.map_object("any")),
   target = types.optional(types.map_object("base.chara")),
   item = types.optional(types.map_object("base.item")),
   x = types.optional(types.uint),
   y = types.optional(types.uint)
}

data:add_type {
   name = "magic",
   fields = {
      {
         name = "elona_id",
         indexed = true,
         type = types.optional(types.uint)
      },
      {
         name = "params",
         type = types.list(types.literal("source", "target", "item", "x", "y")),
         default = { "source" },
         template = true,
doc = [[
   The parameters this magic accepts.

   Currently used purely for documentation purposes. Might be redundant.
]]
      },
      {
         name = "dice",
         type = types.optional(types.callback({"self", types.data_entry("elona_sys.magic"), "params", types.table}, ty_dice)),
         doc = [[
The dice indicating the relative strength of this magic. Has this format:

```lua
function(self, params)
  local level = params.source:skill_level("my_mod.some_magic")
  return {
    x = params.power * 10,
    y = level * 10,
    bonus = 50,
  }
end
```
]]
      },
      {
         name = "cast",
         type = types.callback({"self", types.data_entry("elona_sys.magic"), "params", ty_magic_params}, {types.boolean, types.optional(types.fields { obvious = types.boolean })}),
         template = true,
         doc = [[
Function run when the magic is cast.
]]
      },
      {
         name = "related_skill",
         type = types.data_id("base.skill")
      },
      {
         name = "alignment",
         type = types.optional(types.literal("positive", "negative"))
      },
      {
         name = "cost",
         type = types.number
      },
      {
         name = "range",
         type = types.uint,
         default = 0,
      },
      {
         name = "type",
         type = types.literal("skill", "action", "effect")
      }
   },
}

data:add_type {
   name = "buff",
   fields = {
      {
         name = "type",
         type = types.literal("blessing", "hex", "food"),
         default = "blessing",
         template = true,
doc = [[
The type of this buff.
]]
      },
      {
         name = "on_refresh",
         type = types.callback({"self", types.data_entry("base.buff"), "chara", types.map_object("base.chara")}, types.boolean),
         template = true,
doc = [[
Run the logic for this buff, if any. This can be omitted if the effect is
implemented in event handlers, like for Silence.
]]
      },
      {
         name = "on_add",
         type = types.optional(types.callback("self", types.data_entry("base.buff"), "params", types.table)),
      },
      {
         name = "on_remove",
         type = types.optional(types.callback("self", types.data_entry("base.buff"), "chara", types.map_object("base.chara"))),
      },
      {
         name = "on_expire",
         type = types.optional(types.callback("self", types.data_entry("base.buff"), "chara", types.map_object("base.chara"))),
      },
      {
         name = "params",
         type = types.callback({"self", types.data_entry("base.buff"), "params", types.table}, types.fields_strict { duration = types.number, power = types.number })
      },
      {
         -- TODO needs to be themable
         name = "image",
         type = types.uint
      },
      {
         name = "target_rider",
         type = types.boolean,
         default = false
      },
      {
         name = "no_remove_on_heal",
         type = types.boolean,
         default = false
      }
   },
}

data:add_type {
   name = "basic_anim",
   fields = {
      {
         name = "elona_id",
         indexed = true,
         type = types.optional(types.uint)
      },
      {
         name = "wait",
         type = types.number,
         default = 50,
         template = true,
         doc = [[
How much time to wait when running this animation, in milliseconds.
]]
      },
      {
         name = "frames",
         type = types.optional(types.int),
         default = nil,
         doc = [[
How many frames this animation holds. Omit to default to the asset's `count_x` property.
]]
      },
      {
         name = "rotation",
         type = types.optional(types.number),
         default = 0,
         doc = [[
How much time to wait between frames.
]]
      },
      {
         name = "asset",
         type = types.data_id("base.asset"),
         template = true,
         doc = [[
The asset that holds this animation's frames. It should have a `count_x` property.
]]
      },
      {
         name = "sound",
         type = types.optional(types.data_id("base.sound")),
         template = true,
         doc = [[
A sound to play for this animation, if any.
]]
      }
   }
}

local ty_ctxt_source = types.fields_strict {
   name = types.string,
   getter = types.callback({"ctxt", types.class(InventoryContext)}, types.iterator(types.map_object("base.item"))),
   order = types.uint,
   get_item_name = types.optional(types.callback({"self", types.table, "name", types.string, "item", types.map_object("base.item"), "menu", types.table}, types.string)),
   on_draw = types.optional(types.callback("self", types.table, "x", types.number, "y", types.number, "item", types.map_object("base.item"), "menu", types.table)),
   params = types.map(types.string, types.type)
}

local ty_ctxt_item = types.fields_strict {
   item = types.map_object("base.item"),
   source = ty_ctxt_source
}

local ty_key_hint = types.fields_strict { action = types.locale_id, keys = types.some(types.string, types.list(types.string)) }

data:add_type {
   name = "inventory_proto",
   fields = {
      {
         name = "elona_id",
         type = types.optional(types.uint)
      },
      {
         name = "elona_sub_id",
         type = types.optional(types.uint)
      },
      {
         name = "sources",
         type = types.list(types.literal("chara", "equipment", "target", "target_optional", "container", "shop", "target_equipment", "ground"))
      },
      {
         name = "shortcuts",
         type = types.boolean,
         default = false
      },
      {
         name = "icon",
         type = types.optional(types.uint),
      },
      {
         name = "query_amount",
         type = types.boolean,
         default = false
      },
      {
         name = "show_money",
         type = types.boolean,
         default = false,
      },
      {
         name = "show_target_equip",
         type = types.boolean,
         default = false
      },
      {
         name = "window_title",
         type = types.locale_id
      },
      {
         name = "query_text",
         type = types.some(types.locale_id, types.callback({"ctxt", types.class(InventoryContext), "item", types.map_object("base.item")}, types.string))
      },
      {
         name = "window_detail_header",
         type = types.locale_id
      },
      {
         name = "default_amount",
         type = types.optional(types.uint)
      },
      {
         name = "allow_special_owned",
         type = types.boolean,
         default = false
      },
      {
         name = "params",
         type = types.map(types.string, types.type)
      },
      {
         name = "keybinds",
         type = types.optional(types.callback({"ctxt", types.class(InventoryContext)}, types.map(types.string, types.callback("wrapper", types.class(InventoryWrapper)))))
      },
      {
         name = "key_hints",
         type = types.optional(
            types.some(
               types.list(ty_key_hint),
               types.callback({"ctxt", types.class(InventoryContext)}, types.list(ty_key_hint)))
         )
      },
      {
         name = "get_item_name",
         type = types.optional(types.callback({"name", types.string, "item", types.map_object("base.item")}, types.string))
      },
      {
         name = "get_item_detail_text",
         type = types.optional(types.callback({"name", types.string, "item", types.map_object("base.item")}, types.string))
      },
      {
         name = "sort",
         type = types.optional(types.callback({"ctxt", types.class(InventoryContext), "a", ty_ctxt_item, "b", ty_ctxt_item}, types.boolean))
      },
      {
         name = "filter",
         type = types.optional(types.callback({"ctxt", types.class(InventoryContext), "item", types.map_object("base.item")}, types.boolean))
      },
      {
         name = "after_filter",
         type = types.optional(types.callback({"ctxt", types.class(InventoryContext), "filtered", types.list(ty_ctxt_item)}, types.optional(types.string)))
      },
      {
         name = "on_query",
         type = types.optional(types.callback("ctxt", types.class(InventoryContext)))
      },
      {
         name = "can_select",
         type = types.optional(types.callback({"ctxt", types.class(InventoryContext), "item", types.map_object("base.item")}, types.boolean))
      },
      {
         name = "on_select",
         type = types.optional(types.callback({"ctxt", types.class(InventoryContext), "item", types.map_object("base.item")}, types.string))
      },
      {
         name = "on_shortcut",
         type = types.optional(types.callback({"ctxt", types.class(InventoryContext), "item", types.map_object("base.item")}, {types.optional(types.string), types.optional(types.string)}))
      },
      {
         name = "on_menu_exit",
         type = types.optional(types.callback({"ctxt", types.class(InventoryContext)}, types.string))
      },
      {
         name = "hide_weight_text",
         type = types.boolean,
         default = false,
         template = true,
         doc = [[
If true, hide weight text at the bottom of the inventory menu. Defaults to false.
]]
      },
   }
}

data:add_type {
   name = "inventory_group",
   fields = {
      {
         name = "protos",
         type = types.list(types.data_id("base.inventory_proto"))
      }
   }
}

local ty_scene_entry = types.some(
   types.fields_strict {
      [1] = types.literal("wait", "fade", "fadein")
   },
   types.fields_strict {
      [1] = types.literal("pic"),
      [2] = types.data_id("base.asset"),
   },
   types.fields_strict {
      [1] = types.literal("mc"),
      [2] = types.data_id("base.music"),
   },
   types.fields_strict {
      [1] = types.literal("se"),
      [2] = types.data_id("base.sound"),
   },
   types.fields_strict {
      [1] = types.literal("txt"),
      [2] = types.string
   },
   types.fields_strict {
      [1] = types.literal("chat"),
      [2] = types.uint,
      [3] = types.string
   },
   types.fields_strict {
      [1] = types.literal("actor"),
      [2] = types.uint,
      name = types.string,
      portrait = types.data_id("base.portrait")
   }
)

data:add_type {
   name = "scene",
   fields = {
      {
         name = "content",
         type = types.map(types.string, types.list(ty_scene_entry))
      }
   }
}


require("mod.elona_sys.data.event")

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
   north = function(_, me, is_repeat)
      return Command.move(me, "North", is_repeat)
   end,
   south = function(_, me, is_repeat)
      return Command.move(me, "South", is_repeat)
   end,
   west = function(_, me, is_repeat)
      return Command.move(me, "West", is_repeat)
   end,
   east = function(_, me, is_repeat)
      return Command.move(me, "East", is_repeat)
   end,
   northwest = function(_, me, is_repeat)
      return Command.move(me, "Northwest", is_repeat)
   end,
   northeast = function(_, me, is_repeat)
      return Command.move(me, "Northeast", is_repeat)
   end,
   southwest = function(_, me, is_repeat)
      return Command.move(me, "Southwest", is_repeat)
   end,
   southeast = function(_, me, is_repeat)
      return Command.move(me, "Southeast", is_repeat)
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
   search = function(_, me)
      return Command.search(me)
   end,
   wait = function(_, me, is_repeat)
      if is_repeat then
         Gui.set_scrolling("disabled")
      end
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
   chara_info = function(_, me)
      return Command.chara_info(me)
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
   interact = function(_, me)
      return Command.interact(me)
   end,
   quick_menu = function(_, me)
      return Command.quick_menu(me)
   end,
   journal = function(_, me)
      return Command.journal(me)
   end,
   dip = function(_, me)
      return Command.dip(me)
   end
}
