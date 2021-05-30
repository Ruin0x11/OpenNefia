local MapEditor122Plugin = require("mod.map_editor.api.plugin.MapEditor122Plugin")
local MapEditorNefiaPlugin = require("mod.map_editor.api.plugin.MapEditorNefiaPlugin")
local MapEditorWfcPlugin = require("mod.map_editor.api.plugin.MapEditorWfcPlugin")

data:add_type {
   name = "plugin"
}

data:add {
   _type = "map_editor.plugin",
   _id = "elona_122",

   impl = MapEditor122Plugin
}

data:add {
   _type = "map_editor.plugin",
   _id = "nefia",

   impl = MapEditorNefiaPlugin
}

data:add {
   _type = "map_editor.plugin",
   _id = "wfc",

   impl = MapEditorWfcPlugin
}
