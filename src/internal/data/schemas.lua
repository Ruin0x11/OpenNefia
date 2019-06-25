local schema = require("thirdparty.schema")
local data = require("internal.data")

local IChara = require("api.chara.IChara")
local IItem = require("api.item.IItem")

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

data:add_type({
      name = "item",
      schema = schema.Record {
         name = schema.String,
         image = schema.Number,
         weight = schema.Number,
         value = schema.Number,
         quality = schema.Number,
      },
              },
   IItem)

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
   name = "event",
   schema = schema.Record {
      observer = schema.Optional(schema.String)
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
