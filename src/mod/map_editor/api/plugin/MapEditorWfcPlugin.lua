local Input = require("api.Input")
local Layout = require("mod.tools.api.Layout")
local WaveFunctionMap = require("mod.wfc.api.WaveFunctionMap")
local FuzzyFinderPrompt = require("mod.tools.api.FuzzyFinderPrompt")
local UiMouseMenu = require("mod.mouse_ui.api.gui.UiMouseMenu")
local UiMouseButton = require("mod.mouse_ui.api.gui.UiMouseButton")

local IMapEditorPlugin = require("mod.map_editor.api.IMapEditorPlugin")
local UiMouseMenuButton = require("mod.mouse_ui.api.gui.UiMouseMenuButton")

local MapEditorWfcPlugin = class.class("MapEditorWfcPlugin", IMapEditorPlugin)

function MapEditorWfcPlugin:init()
   self.target_width = 60
   self.target_height = 60
end

function MapEditorWfcPlugin:on_install(map_editor)
   local menu = UiMouseMenu:new {
      children = {
         UiMouseButton:new { text = "Generate...", callback = function() self:act_generate(map_editor) end },
         UiMouseButton:new { text = "Template...", callback = function() self:act_template(map_editor) end }
      }
   }
   local menu_button = UiMouseMenuButton:new { text = "WFC", id = "tools.wfc", menu = menu }
   map_editor.toolbar:find_menu("menu_plugin"):add_button(menu_button)
end

function MapEditorWfcPlugin:act_generate(map_editor)
   local map = map_editor:get_current_map().map
   if not map then
      return
   end

   local width, canceled = Input.query_number(1000, self.target_width)
   if canceled then
      return
   end
   self.target_width = width
   local height, canceled = Input.query_number(1000, self.target_height)
   if canceled then
      return
   end
   self.target_height = height

   local layout = Layout.from_map(map)
   local opts = {
      max_steps = 10000
   }

   local new_map = WaveFunctionMap.generate_overlapping(layout, width, height, opts)
   if new_map == nil then
      return nil
   end

   new_map.name = "WFC Map"

   local index = map_editor:add_map(new_map)
   map_editor:switch_to_map(index)
end

function MapEditorWfcPlugin:act_template(map_editor)
   local layouts = require("mod.wfc.scratch.layouts")
   local cands = table.keys(layouts)
   local template, canceled = FuzzyFinderPrompt:new(cands):query()
   if canceled then
      return
   end

   local new_map = Layout.to_map(layouts[template])

   new_map.name = "WFC Template - " .. template

   local index = map_editor:add_map(new_map)
   map_editor:switch_to_map(index)
end

return MapEditorWfcPlugin
