local Input = require("api.Input")
local FuzzyFinderPrompt = require("mod.tools.api.FuzzyFinderPrompt")
local InstancedArea = require("api.InstancedArea")
local MouseUi = require("mod.mouse_ui.api.MouseUi")

local IMapEditorPlugin = require("mod.map_editor.api.IMapEditorPlugin")
local UiMouseMenuButton = require("mod.mouse_ui.api.gui.UiMouseMenuButton")

local MapEditorNefiaPlugin = class.class("MapEditorNefiaPlugin", IMapEditorPlugin)

function MapEditorNefiaPlugin:init()
   self.target_floor = 20
end

function MapEditorNefiaPlugin:on_install(map_editor)
   local menu = MouseUi.make_mouse_menu {
      { text = "Generate...", cb = function() self:act_generate(map_editor) end },
   }
   local menu_button = UiMouseMenuButton:new("Nefia", "tools.nefia", menu)
   map_editor.toolbar:find_menu("menu_plugin"):add_button(menu_button)
end

function MapEditorNefiaPlugin:act_generate(map_editor)
   local cands = data["elona.nefia"]:iter():extract("_id"):to_list()
   local nefia_id, canceled = FuzzyFinderPrompt:new(cands):query()
   if canceled then
      return
   end

   local floor, canceled = Input.query_number(1000, self.target_floor)
   if canceled then
      return
   end

   local area = InstancedArea:new()
   local new_map
   for i = 1, 10 do
      new_map = data["elona.nefia"]:ensure(nefia_id).on_generate_floor(area, floor)
      if new_map then
         break
      end
   end
   if not new_map then
      return
   end

   local index = map_editor:add_map(new_map)
   map_editor:switch_to_map(index)
end

return MapEditorNefiaPlugin
