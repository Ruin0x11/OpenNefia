local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")
local UiTheme = require("api.gui.UiTheme")

local MapEditorTileWidget = class.class("MapEditorTileWidget", IUiElement)

function MapEditorTileWidget:init(tile_id)
   self.tile_batch = Draw.make_chip_batch("tile")
   self:set_tile(tile_id)
end

function MapEditorTileWidget:_update_tile_batch()
   if self.tile_id and self.x then
      local width, height = Draw.get_coords():get_size()
      self.tile_batch:clear()
      self.tile_batch:add(self.tile_id, self.x, self.y, width, height)
   end
end

function MapEditorTileWidget:set_tile(tile_id)
   data["base.map_tile"]:ensure(tile_id)
   self.tile_id = tile_id

   self:_update_tile_batch()
end

function MapEditorTileWidget:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load(self)

   self:_update_tile_batch()
end

function MapEditorTileWidget:draw()
   self.tile_batch:draw()
end

function MapEditorTileWidget:update(dt)
end

return MapEditorTileWidget
