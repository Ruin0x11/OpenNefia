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
         name = "target_filter",
         type = "function",
      },
      {
         name = "target_order",
         type = "function",
      },
      {
         name = "ordering",
         type = "number",
         default = 10000,
         template = true
      },
      {
         name = "is_terminal",
         type = "boolean",
         default = true
      },
      {
         name = "format_name",
         type = "function"
      },
      {
         name = "applies_to",
         type = "string",
         default = "any",
         template = true
      }
   }
}

require("mod.visual_ai.data.visual_ai.block.condition")
require("mod.visual_ai.data.visual_ai.block.target")
require("mod.visual_ai.data.visual_ai.block.action")
require("mod.visual_ai.data.visual_ai.block.special")
