local Draw = require("api.Draw")
local Chara = require("api.Chara")
local Pos = require("api.Pos")
local Gui = require("api.Gui")
local Map = require("api.Map")
local Ui = require("api.Ui")
local I18N = require("api.I18N")
local MapTileset = require("mod.elona_sys.map_tileset.api.MapTileset")

local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local UiTheme = require("api.gui.UiTheme")

local TreasureMapWindow = class.class("TreasureMapWindow", IUiLayer)

TreasureMapWindow:delegate("input", IInput)

function TreasureMapWindow:init(map, treasure_x, treasure_y)
   self.map = map
   self.treasure_x = treasure_x
   self.treasure_y = treasure_y

   self.finished = false
   self.circle = nil
   self.circle_sx = nil
   self.circle_sy = nil

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
end

function TreasureMapWindow:make_keymap()
   return {
      enter = function() self.finished = true end,
      cancel = function() self.finished = true end,
      escape = function() self.finished = true end,
   }
end

local function make_batch(map, treasure_x, treasure_y)
   local batch = Draw.make_chip_batch("tile")
   local tile_width, tile_height = Draw.get_coords():get_size()

   local default_id = MapTileset.get_default_tile(map)

   for j = 0, 5-1 do
      for i = 0, 7-1 do
         local x = i + treasure_x - 3
         local y = j + treasure_y - 2
         local sx, sy = Gui.tile_to_screen(i, j)
         local tile = map:tile(x, y)
         if tile then
            batch:add(tile._id, sx, sy, tile_width, tile_height)
         else
            batch:add(default_id, sx, sy, tile_width, tile_height)
         end
      end
   end

   return batch
end

function TreasureMapWindow:relayout()
   self.width = 400
   self.height = 300
   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.t = UiTheme.load(self)
   self.batch = make_batch(self.map, self.treasure_x, self.treasure_y)
   self.circle = I18N.get("magic.map.mark")
   self.circle_sx, self.circle_sy = Gui.tile_to_screen(4, 4)
end

function TreasureMapWindow:on_query()
   Gui.play_sound("base.book1")
end

function TreasureMapWindow:draw()
   self.t.base.paper:draw_region(1, self.x, self.y, nil, nil, {255, 255, 255})
   self.batch:draw(self.x + 26, self.y + 46)

   Draw.set_font(40, "italic")
   Draw.set_color(255, 20, 20)

   Draw.text(self.circle, self.x + self.circle_sx - 26, self.y + self.circle_sy - 46)

   self.t.base.paper:draw_region(2, self.x, self.y, nil, nil, {255, 255, 255})
end

function TreasureMapWindow:update(dt)
   if self.finished then
      Gui.play_sound("base.card1")
      return true
   end
end

return TreasureMapWindow
