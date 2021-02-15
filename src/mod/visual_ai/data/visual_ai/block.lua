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
      }
   }
}

require("mod.visual_ai.data.visual_ai.block.condition")
require("mod.visual_ai.data.visual_ai.block.target")
require("mod.visual_ai.data.visual_ai.block.action")
