data:add_type {
   name = "block",
   fields = {
      {
         name = "icon",
         type = "id:base.asset",
         template = true
      },
      {
         name = "type",
         type = "string",
         default = "action",
         template = true
      },
      {
         name = "vars",
         type = "table",
         default = {},
         template = true
      },
      {
         name = "color",
         type = "string|table|nil",
         default = nil,
         template = true
      },
      {
         name = "target_source",
         type = "string",
      },
      {
         name = "ordering",
         type = "number",
         default = 10000,
         template = true
      },
      {
         name = "is_terminal",
         type = "boolean?"
      },
      {
         name = "format_name",
         type = "function"
      }
   }
}

require("mod.visual_ai.data.visual_ai.block.condition")
require("mod.visual_ai.data.visual_ai.block.target")
require("mod.visual_ai.data.visual_ai.block.action")
