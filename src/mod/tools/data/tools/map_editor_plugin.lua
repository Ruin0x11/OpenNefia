local MapEditor122Plugin = require("mod.tools.api.MapEditor122Plugin")
local MapEditorNefiaPlugin = require("mod.tools.api.MapEditorNefiaPlugin")
local MapEditorWfcPlugin = require("mod.tools.api.MapEditorWfcPlugin")

data:add_type {
   name = "map_editor_plugin"
}

data:add {
   _type = "tools.map_editor_plugin",
   _id = "elona_122",

   impl = MapEditor122Plugin
}

data:add {
   _type = "tools.map_editor_plugin",
   _id = "nefia",

   impl = MapEditorNefiaPlugin
}

data:add {
   _type = "tools.map_editor_plugin",
   _id = "wfc",

   impl = MapEditorWfcPlugin
}
