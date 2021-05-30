local Draw = require("api.Draw")
local Gui = require("api.Gui")
local MapEdit = require("mod.elona.api.MapEdit")

local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")

local MapEditTileList = class.class("MapEditTileList", IUiLayer)

MapEditTileList:delegate("input", IInput)

local function is_selectable_tile(tile_id)
   local tile_data = data["base.map_tile"]:ensure(tile_id)
   if tile_data.wall_kind == 1 then
      return false
   end
   return true
end

function MapEditTileList:init(tiles)
  self.finished = false
  self.canceled = false

  tiles = tiles or MapEdit.calc_selectable_tiles()
  self.tiles = fun.iter(tiles)
     :filter(is_selectable_tile)
     :map(function(tile_id)
           local tile_data = data["base.map_tile"]:ensure(tile_id)
           return {
              _id = tile_id,
              is_solid = tile_data.is_solid
           }
         end)
     :to_list()

  self.input = InputHandler:new()
  self.input:bind_keys(self:make_keymap())
  self.input:bind_mouse(self:make_mousemap())
  self.input:halt_input()
end

function MapEditTileList:default_z_order()
   return 2000000
end

function MapEditTileList:make_keymap()
  return {
    escape = function() self.canceled = true end,
    cancel = function() self.canceled = true end,
  }
end

function MapEditTileList:make_mousemap()
  return {
    button_1 = function(x, y, pressed)
       if pressed then
          local index = math.floor((self.x + x) / self.tile_width)
                      + math.floor((self.y + y) / self.tile_height) * self.count_x + 1

          if self.tiles[index] then
             Gui.play_sound("base.ok1")
             self.selected_tile = self.tiles[index]._id
             self.finished = true
          else
             Gui.play_sound("base.fail1")
          end
       end
    end,
    button_2 = function(x, y, pressed)
       if pressed then
          self.canceled = true
       end
    end
  }
end

function MapEditTileList:index_to_pos(i)
   local x = (self.x + (i-1) % self.count_x) * self.tile_width
   local y = self.y + math.floor((i-1) / self.count_x) * self.tile_height
   return x, y
end

function MapEditTileList:make_tile_batch()
   local batch = Draw.make_chip_batch("tile")

  for i, entry in ipairs(self.tiles) do
     local x, y = self:index_to_pos(i)
     batch:add(entry._id, x, y, self.tile_width, self.tile_height)
  end

  return batch
end

function MapEditTileList:relayout(x, y, width, height)
  self.x = 0
  self.y = 0
  self.width = Draw.get_width()
  self.height = Draw.get_height()
  self.tile_width, self.tile_height = Draw.get_coords():get_size()
  self.tile_width = math.floor(self.tile_width / 2)
  self.tile_height = math.floor(self.tile_height / 2)
  self.count_x = math.floor(self.width / self.tile_width)
  self.tile_batch = self:make_tile_batch()
end

function MapEditTileList:draw()
  Draw.set_color(255, 255, 255)
  self.tile_batch:draw()

  for i, entry in ipairs(self.tiles) do
     local x, y = self:index_to_pos(i)
     if entry.is_solid then
        Draw.set_color(240, 230, 220)
     else
        Draw.set_color(200, 200, 200)
     end
     Draw.line_rect(x, y, self.tile_width, self.tile_height)
  end
end

function MapEditTileList:update(dt)
  if self.finished then
    return self.selected_tile
  elseif self.canceled then
    return nil, "canceled"
  end
end

return MapEditTileList
