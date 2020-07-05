local Enum = require("api.Enum")
local Gui = require("api.Gui")
local data = require("internal.data")

local MapEdit = {}

function MapEdit.start()
   local MapEditLayer = require("api.gui.MapEditLayer")

   Gui.mes_newline()
   Gui.mes("building.home.design.help")
   MapEditLayer:new():query()
end

function MapEdit.is_tile_selectable(tile)
  local tile_data = data["base.map_tile"]:ensure(tile)

  if tile_data.disable_in_map_edit then
     return false
  end

  if tile_data.elona_atlas == 0 or tile_data.elona_atlas == 2 then
     -- TODO support world map editing
     return false
  end

  if tile_data.wall_kind == 1 then
     return false
  end

  if tile_data.kind == Enum.TileRole.Crop or tile_data.kind == Enum.TileRole.Dryground then
     return false
  end

  return true
end

function MapEdit.calc_selectable_tiles()
   local list = data["base.map_tile"]:iter()
      :filter(function(t) return MapEdit.is_tile_selectable(t._id) end)
      :to_list()

   table.sort(list, function(a, b) return (a.elona_id or -1) < (b.elona_id or -1) end)

   return fun.iter(list):extract("_id"):to_list()
end

return MapEdit
