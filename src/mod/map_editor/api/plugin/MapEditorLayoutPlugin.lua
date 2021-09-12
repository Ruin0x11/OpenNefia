local Codegen = require("api.Codegen")
local Layout = require("mod.tools.api.Layout")
local Env = require("api.Env")
local CodeGenerator = require("api.CodeGenerator")

local UiMouseMenu = require("mod.mouse_ui.api.gui.UiMouseMenu")
local UiMouseButton = require("mod.mouse_ui.api.gui.UiMouseButton")
local TextEditorPrompt = require("mod.ui_console.api.gui.TextEditorPrompt")
local IMapEditorPlugin = require("mod.map_editor.api.IMapEditorPlugin")
local UiMouseMenuButton = require("mod.mouse_ui.api.gui.UiMouseMenuButton")

local MapEditorLayoutPlugin = class.class("MapEditorLayoutPlugin", IMapEditorPlugin)

function MapEditorLayoutPlugin:init()
end

function MapEditorLayoutPlugin:on_install(map_editor)
   local menu = UiMouseMenu:new {
      children = {
         UiMouseButton:new { text = "Import...", callback = function() self:act_import(map_editor) end },
         UiMouseButton:new { text = "Export", callback = function() self:act_export(map_editor) end },
      }
   }
   local menu_button = UiMouseMenuButton:new { text = "Layout", id = "tools.layout", menu = menu }
   map_editor.toolbar:find_menu("menu_plugin"):add_button(menu_button)
end

function MapEditorLayoutPlugin:act_import(map_editor)
   local code, canceled = TextEditorPrompt:new():query()
   if canceled then
      return
   end

   local chunk, err = Codegen.loadstring(code)
   if err then
      error(err)
   end

   local new_map = Layout.to_map(chunk())

   local index = map_editor:add_map(new_map)
   map_editor:switch_to_map(index)
end

function MapEditorLayoutPlugin:act_export(map_editor)
   if not map_editor.current_map then
      return
   end

   local layout = Layout.from_map(map_editor.current_map.map)
   layout.tiles = CodeGenerator.gen_block_string("\n" .. layout.tiles)
   Env.set_clipboard_text(CodeGenerator.inspect(layout, { always_tabify = true }))
end

return MapEditorLayoutPlugin
