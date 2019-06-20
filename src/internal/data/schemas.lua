local schema = require("thirdparty.schema")
local data = require("internal.data")

local IChara = require("api.chara.IChara")

data:add_type({
      name = "chara",
      schema = schema.Record {
         name = schema.String,
         image = schema.Number,
         max_hp = schema.Number,
         on_death = schema.Optional(schema.Function),
      },
              },
   IChara)

data:add_type {
   name = "item",
   schema = schema.Record {
      name = schema.String,
      image = schema.Number,
      weight = schema.Number,
      value = schema.Number,
      quality = schema.Number,
   },
}

data:add_type {
   name = "map_tile",
   schema = schema.Record {
      image = schema.Number,
      is_solid = schema.Boolean,
   },
}

data:add_type {
   name = "event",
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
   name = "ui_theme",
   schema = schema.Record {
      target = schema.String,
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
   name = "element",
   schema = schema.Record {
      can_resist = schema.Boolean,
      can_be_immune_to = schema.Boolean,
      on_damage_hp = schema.Optional(schema.Function),
      on_kill = schema.Optional(schema.Function),
      kill_animation = schema.Optional(schema.String),
      sound = schema.Optional(schema.String),
   }
}

data:add_type {
   name = "status_effect",
   schema = schema.Record {
      related_element = schema.Optional(schema.String),
      before_apply = schema.Optional(schema.Function),
      power_reduction_factor = schema.Optional(schema.Number),
      additive_power = schema.Optional(schema.Function),
      on_turn_begin = schema.Optional(schema.Function),
      on_turn_end = schema.Optional(schema.Function),
      ui_indicator = schema.Table, -- { string, color } or { [int] = { string, color }, ... }
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

require("internal.data.ai")
