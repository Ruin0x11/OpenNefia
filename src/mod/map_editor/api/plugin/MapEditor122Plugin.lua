local FuzzyFinderPrompt = require("mod.tools.api.FuzzyFinderPrompt")
local Fs = require("api.Fs")
local Elona122Map = require("mod.elona_sys.map_loader.Elona122Map")
local UiMouseMenu = require("mod.mouse_ui.api.gui.UiMouseMenu")
local UiMouseButton = require("mod.mouse_ui.api.gui.UiMouseButton")

local IMapEditorPlugin = require("mod.map_editor.api.IMapEditorPlugin")
local UiMouseMenuButton = require("mod.mouse_ui.api.gui.UiMouseMenuButton")

local MapEditor122Plugin = class.class("MapEditor122Plugin", IMapEditorPlugin)

function MapEditor122Plugin:init()
end

function MapEditor122Plugin:on_install(map_editor)
   local menu = UiMouseMenu:new {
      children = {
         UiMouseButton:new { text = "Load...", callback = function() self:act_load(map_editor) end },
      }
   }
   local menu_button = UiMouseMenuButton:new { text = "1.22", id = "tools.122", menu = menu }
   map_editor.toolbar:find_menu("menu_plugin"):add_button(menu_button)
end

function MapEditor122Plugin:act_load(map_editor)
   local cands = Fs.iter_directory_items("mod/elona/map")
      :filter(function(i) return i:match("%.map$") end)
      :map(function(i) return i:gsub("%.map$", "") end)
      :to_list()
   local name, canceled = FuzzyFinderPrompt:new(cands):query()
   if canceled then
      return
   end

   local new_map = Elona122Map.generate(name)
   if new_map == nil then
      return nil
   end

   new_map.name = name

   local index = map_editor:add_map(new_map)
   map_editor:switch_to_map(index)
end

return MapEditor122Plugin
