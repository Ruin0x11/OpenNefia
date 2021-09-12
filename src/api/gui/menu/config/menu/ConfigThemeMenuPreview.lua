--[[
local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")
local theme = require("internal.theme")
local data = require("internal.data")
local InstancedMap = require("api.InstancedMap")
local tile_layer = require("internal.layer.tile_layer")
local chip_layer = require("internal.layer.chip_layer")
local DrawLayerSpec = require("api.draw.DrawLayerSpec")
local MapRenderer = require("api.gui.MapRenderer")

local ConfigThemeMenuPreview = class.class("ConfigThemeMenuPreview", IUiElement)

function ConfigThemeMenuPreview:init(map)
   self.map = nil
   self.map_renderer = nil

   self.tile_ids = {}
   self.chip_ids = {}
   self.item_chip_ids = {} -- for item shadow atlas

   self.tile_atlas = nil
   self.chip_atlas = nil
   self.item_shadow_atlas = nil

   self:set_map(map)
end

local function extract_tile_and_chip_ids(map)
   local tile_ids = table.set {}
   local chip_ids = table.set {}
   local item_chip_ids = table.set { "elona.item_stack" }

   for _, _, _, tile in map:iter_tiles() do
      tile_ids[tile._id] = true
   end

   for _, obj in map:iter() do
      if obj.image then
         chip_ids[obj.image] = true
         if obj._type == "base.item" then
            item_chip_ids[obj.image] = true
         end
      end
   end

   tile_ids = table.keys(tile_ids)
   chip_ids = table.keys(chip_ids)
   item_chip_ids = table.keys(item_chip_ids)

   return tile_ids, chip_ids, item_chip_ids
end

function ConfigThemeMenuPreview:set_map(map)
   assert(class.is_an(InstancedMap, map))

   self.map = map
   self.map:iter_tiles():each(function(x, y) self.map:memorize_tile(x, y) end)
   self.map:redraw_all_tiles()

   -- self.tile_ids, self.chip_ids, self.item_chip_ids = extract_tile_and_chip_ids(map)

   -- local map_tile_entries = fun.iter(self.tile_ids)
   --    :map(function(_id) return data["base.map_tile"]:ensure(_id) end)
   --    :to_list()

   -- self.tile_atlas = theme.load_tilemap_tile(map_tile_entries)
   -- -- TODO handle tile overhang
   -- --self.tile_overhang_atlas = theme.load_tilemap_tile_overhang(map_tile_entries)

   -- local chip_entries = fun.iter(self.chip_ids)
   --    :map(function(_id) return data["base.chip"]:ensure(_id) end)
   --    :to_list()

   -- self.chip_atlas = theme.load_tilemap_chip(chip_entries)

   -- local mw = map:width()
   -- local mh = map:height()

   -- local new_tile_layer = tile_layer:new(mw, mh)
   -- new_tile_layer:set_atlas(self.tile_atlas)

   -- local new_chip_layer = chip_layer:new(mw, mh)
   -- new_chip_layer:set_atlases(self.chip_atlas, self.item_shadow_atlas)

   -- local spec = DrawLayerSpec:new()
   -- -- spec:register_draw_layer("tile_layer", new_tile_layer)
   -- -- spec:register_draw_layer("chip_layer", new_chip_layer)

   -- spec:register_draw_layer("tile_layer", "internal.layer.tile_layer")
   -- spec:register_draw_layer("debris_layer", "internal.layer.debris_layer")
   -- spec:register_draw_layer("chip_layer", "internal.layer.chip_layer")
   -- spec:register_draw_layer("tile_overhang_layer", "internal.layer.tile_overhang_layer")
   -- spec:register_draw_layer("emotion_icon_layer", "internal.layer.emotion_icon_layer")

   self.map_renderer = MapRenderer:new(self.map)
end

function ConfigThemeMenuPreview:update_draw_pos()
   self.map_renderer:set_draw_pos(0, 0)
   local tx, ty = Draw.get_coords():screen_to_tile(-0 + math.floor(self.width / 2), -0 + math.floor(self.height / 2))
   self.map:calc_screen_sight(tx, ty, "all")
end

function ConfigThemeMenuPreview:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height

   self.map_renderer:relayout(self.x, self.y, self.width, self.height)
   self:update_draw_pos()
end

function ConfigThemeMenuPreview:draw()
   Draw.set_color(200, 200, 200)
   Draw.filled_rect(self.x, self.y, self.width, self.height)

   Draw.set_color(255, 255, 255)
   self:update_draw_pos()
   self.map_renderer:relayout_inner(self.x, self.y, self.width, self.height)
   self.map_renderer:draw()
end

function ConfigThemeMenuPreview:update(dt)
   self.map_renderer:update(dt)
end

return ConfigThemeMenuPreview

--]]


local Draw = require("api.Draw")
local InstancedMap = require("api.InstancedMap")

local MapRenderer = require("api.gui.MapRenderer")
local IUiElement = require("api.gui.IUiElement")

local ConfigThemeMenuPreview = class.class("ConfigThemeMenuPreview", IUiElement)

function ConfigThemeMenuPreview:init(map)
   class.assert_is_an(InstancedMap, map)

   self.map = map
   map:iter_tiles():each(function(x, y) map:memorize_tile(x, y) end)
   map:redraw_all_tiles()

   self.renderer = MapRenderer:new(map)
end

function ConfigThemeMenuPreview:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height

   self.renderer:relayout(self.x, self.y, self.width, self.height)
end

function ConfigThemeMenuPreview:draw()
   Draw.set_color(255, 255, 255)
   self.renderer:draw()
end

function ConfigThemeMenuPreview:update(dt)
   self.renderer:update(dt)
end

return ConfigThemeMenuPreview
