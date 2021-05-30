local Ui = require("api.Ui")
local FuzzyFinderPrompt = require("mod.tools.api.FuzzyFinderPrompt")
local Fs = require("api.Fs")
local Elona122Map = require("mod.elona_sys.map_loader.Elona122Map")

local IMapEditorPlugin = require("mod.tools.api.IMapEditorPlugin")
local UiMouseMenuButton = require("api.gui.UiMouseMenuButton")

local MapEditor122Plugin = class.class("MapEditor122Plugin", IMapEditorPlugin)

function MapEditor122Plugin:init()
end

function MapEditor122Plugin:on_install(map_editor)
   local menu = Ui.make_mouse_menu {
      { text = "Load...", cb = function() self:act_load(map_editor) end },
   }
   local menu_button = UiMouseMenuButton:new("1.22", "tools.122", menu)
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
