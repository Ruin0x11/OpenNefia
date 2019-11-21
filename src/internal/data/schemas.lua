local schema = require("thirdparty.schema")
local data = require("internal.data")

data:add_type {
   name = "event",
   schema = schema.Record {
      observer = schema.Optional(schema.String)
   },
}

local IChara = require("api.chara.IChara")
local IItem = require("api.item.IItem")
local IFeat = require("api.feat.IFeat")
local ITrap = require("api.feat.ITrap")
local IActivity = require("api.activity.IActivity")

data:add_type(
   {
      name = "resource",
      schema = schema.Record {
         type = schema.String,
         value = schema.Any
      }
   }
)

data:add_type(
   {
      name = "chara",
      schema = schema.Record {
         name = schema.String,
         image = schema.Number,
         max_hp = schema.Number,
         on_death = schema.Optional(schema.Function),
         on_instantiate = schema.Optional(schema.Function),
      },
   },
   { interface = IChara }
)

data:add_type(
   {
      name = "item",
      schema = schema.Record {
         name = schema.String,
         image = schema.Number,
         weight = schema.Number,
         value = schema.Number,
         quality = schema.Number,
         on_instantiate = schema.Optional(schema.Function),
      },
   },
   { interface = IItem }
)

data:add_type {
   name = "item_type",
   schema = schema.Record {
      no_generate = schema.Optional(schema.Boolean)
   }
}

data:add_type(
   {
      name = "feat",
      schema = schema.Record {
         name = schema.String,
         image = schema.Number,
         params = schema.Table,
         on_instantiate = schema.Optional(schema.Function),
      },
   },
   { interface = IFeat }
)

data:add_type(
   {
      name = "trap",
      schema = schema.Record {
         name = schema.String,
         image = schema.Number,
         params = schema.Table,
         on_instantiate = schema.Optional(schema.Function),
      },
   },
   { interface = ITrap }
)

data:add_type(
   {
      name = "class",
      schema = schema.Record {
         on_generate = schema.Optional(schema.Function),
      },
   }
)

data:add_type(
   {
      name = "race",
      schema = schema.Record {
      },
   }
)

data:add_type(
   {
      name = "element",
      schema = schema.Record {
      },
   }
)

data:add_type{
   name = "effect",
   schema = {
      indicator = schema.Function,
   }
}

data:add_type(
   {
      name = "activity",
      schema = {
      },
   },
   { interface = IActivity }
)

data:add_type(
   {
      name = "map",
      schema = schema.Record {
         name = schema.String
      },
   }
)

data:add_type {
   name = "body_part",
   schema = schema.Record {
      name = schema.String,
      icon = schema.Number -- TODO: needs to be themable
   }
}

data:add_type {
   name = "map_tile",
   schema = schema.Record {
      image = schema.Number,
      is_solid = schema.Boolean,
   },
}

data:add_type {
   name = "enchantment",
   schema = schema.Record {
      item_method = schema.String,
      item = schema.Table,
      wielder_method = schema.String,
      wielder = schema.Table,
      orientation = schema.String,
   },
}

data:add_type {
   name = "stat",
   schema = schema.Record {
   },
}

data:add_type {
   name = "skill",
   schema = schema.Record {
      is_main_skill = schema.Boolean
   },
}

data:add_type {
   name = "magic",
   schema = schema.Record {
   },
}

data:add_type {
   name = "trait",
   schema = schema.Record {
   },
}

data:add_type {
   name = "sound",
   schema = schema.Record {
      file = schema.String
   },
}

data:add_type {
   name = "ui_indicator",
   schema = schema.Record {
      indicator = schema.Function
   },
}

data:add_type(
   {
      name = "resolver",
      schema = schema.Record {
         invariants = schema.Table,
         params = schema.Table,
         resolve = schema.Function,
      },
   }
)

data:add_type {
   name = "scenario",
   schema = schema.Record {
      name = schema.String,
      starting_map = schema.Table,
      on_game_begin = schema.Function,
   },
}

data:add_type {
   name = "theme",
   schema = schema.Record {
      target = schema.Optional(schema.String),
      assets = schema.Table,
   },
}

data:add_type {
   name = "chip",
   schema = schema.Record {
   },
}

data:add_type {
   name = "asset",
   schema = schema.Record {
      target = schema.String,
   }
}

data:add_type {
   name = "map_generator",
   schema = schema.Record {
      generate = schema.Function,
   }
}

data:add_type {
   name = "faction",
   schema = schema.Record {
      reactions = schema.Table,
   },
}

data:add_type {
   name = "ai_action",
   schema = schema.Record {
      act = schema.Function
   }
}

data:add_type {
   name = "talk",
   schema = schema.Record {
      messages = schema.Table
   }
}

data:add_type {
   name = "talk_event",
   schema = schema.Record {
      params = schema.Table
   }
}

data:add_type {
   name = "portrait",
   schema = schema.Record {
      image = schema.String
   }
}

data:add_type {
   name = "config_option_boolean",
   schema = schema.Record {
      default = schema.Boolean,
      on_generate = schema.Optional(schema.Function),
   }
}

data:add_type {
   name = "config_option_choice",
   schema = schema.Record {
      choices = schema.Table,
      default = schema.String,
      on_generate = schema.Optional(schema.Function),
   }
}

data:add_type {
   name = "config_option_number",
   schema = schema.Record {
      max = schema.Number,
      min = schema.Number,
      default = schema.Number,
      on_generate = schema.Optional(schema.Function),
   }
}

data:add_type {
   name = "config_option_string",
   schema = schema.Record {
      max_length = schema.Number,
      min_length = schema.Number,
      default = schema.String,
      on_generate = schema.Optional(schema.Function),
   }
}

data:add_type {
   name = "config_option_file",
   schema = schema.Record {
      default = schema.Optional(schema.String),
      on_generate = schema.Optional(schema.Function),
      on_validate_file = schema.Optional(schema.Function),
   }
}

data:add_type {
   name = "config_menu",
   schema = schema.Record {
      options = schema.Table,
      on_generate = schema.Optional(schema.Function),
   }
}

data:add_type {
   name = "config_custom_menu",
   schema = schema.Record {
      require_path = schema.String,
      options = schema.Table
   }
}
