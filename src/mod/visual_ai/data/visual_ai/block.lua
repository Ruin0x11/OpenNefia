local ty_pos = types.fields { x = types.uint, y = types.uint }
local ty_visual_ai_var = types.table -- TODO

data:add_type {
   name = "block",
   fields = {
      {
         name = "icon",
         type = types.data_id("base.asset"),
         template = true
      },
      {
         name = "type",
         type = types.literal("target", "action", "condition", "special"),
         template = true
      },
      {
         name = "vars",
         type = types.map(types.identifier, ty_visual_ai_var),
         default = {},
         template = true
      },
      {
         name = "color",
         type = types.optional(types.color),
         default = nil,
         template = true
      },
      {
         name = "target_source",
         type = types.optional(types.literal("character", "items_on_self", "items_on_ground"))
      },
      {
         name = "target_filter",
         type = types.optional(types.callback({"self", types.table,
                                               "chara", types.map_object("base.chara"),
                                               "candidate", types.map_object("base.chara")},
                                  types.boolean))
      },
      {
         name = "target_order",
         type = types.optional(types.callback({"self", types.table,
                                               "chara", types.map_object("base.chara"),
                                               "candidate_a", types.map_object("base.chara"),
                                               "candidate_b", types.map_object("base.chara")},
                                  types.boolean))
      },
      {
         name = "is_terminal",
         type = types.optional(types.boolean),
      },
      {
         name = "format_name",
         type = types.optional(types.callback({"proto", types.data_entry("visual_ai.block"), "vars", types.table}, types.string))
      },
      {
         name = "applies_to",
         type = types.optional(types.literal("any", "map_object", "position")),
         template = true
      },
      {
         name = "action",
         type = types.optional(types.callback({"self", types.table,
                                               "chara", types.map_object("base.chara"),
                                               "target", types.some(types.map_object("any"), ty_pos),
                                               "ty", types.literal("map_object", "position")},
                                  types.string)),
         template = true
      },
      {
         name = "action",
         type = types.optional(types.callback({"self", types.table,
                                               "chara", types.map_object("base.chara"),
                                               "target", types.some(types.map_object("any"), ty_pos),
                                               "ty", types.literal("map_object", "position")},
                                  types.boolean)),
         template = true
      }
   }
}

require("mod.visual_ai.data.visual_ai.block.condition")
require("mod.visual_ai.data.visual_ai.block.target")
require("mod.visual_ai.data.visual_ai.block.action")
require("mod.visual_ai.data.visual_ai.block.special")
