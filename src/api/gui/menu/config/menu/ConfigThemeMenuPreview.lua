local Draw = require("api.Draw")
local InstancedMap = require("api.InstancedMap")
local data = require("internal.data")
local theme = require("internal.theme")
local tile_layer = require("internal.layer.tile_layer")
local chip_layer = require("internal.layer.chip_layer")
local DrawLayerSpec = require("api.draw.DrawLayerSpec")

local MapRenderer = require("api.gui.MapRenderer")
local IUiElement = require("api.gui.IUiElement")

local ConfigThemeMenuPreview = class.class("ConfigThemeMenuPreview", IUiElement)

function ConfigThemeMenuPreview:init(map, themes)
   class.assert_is_an(InstancedMap, map)

   self.map = nil
   self.map_renderer = nil

   self.themes = themes or {}

   self.tile_ids = {}
   self.chip_ids = {}

   self.tile_atlas = nil
   self.tile_overhang_atlas = nil
   self.chip_atlas = nil
   self.item_shadow_atlas = nil

   self:set_map(map)
end

local function extract_tile_and_chip_ids(map)
   local tile_ids = table.set {}
   local chip_ids = table.set {}

   for _, _, _, tile in map:iter_tiles() do
      tile_ids[tile._id] = true
      local tile_entry = data["base.map_tile"]:ensure(tile._id)
      if tile_entry.wall then
         tile_ids[tile_entry.wall] = true
      end
   end

   for _, obj in map:iter() do
      if obj.image then
         chip_ids[obj.image] = true
      end
   end

   tile_ids = table.keys(tile_ids)
   chip_ids = table.keys(chip_ids)

   return tile_ids, chip_ids
end

function ConfigThemeMenuPreview:set_map(map)
   assert(class.is_an(InstancedMap, map))

   self.map = map
   self.map:iter_tiles():each(function(x, y) self.map:memorize_tile(x, y) end)
   self.map:redraw_all_tiles()

   self:_update_renderer()
end

function ConfigThemeMenuPreview:set_themes(themes)
   assert(type(themes) == "table")

   self.themes = themes

   self:_update_renderer()
end

-- Perform a miniature version of theme.build_overrides() just for the
-- tiles/chips visible in the map that was provided.
local function build_overrides(themes, tile_ids, chip_ids)
   -- Get a copy of the base tile/chip data so it won't get overwritten.
   local tiles = fun.iter(tile_ids):map(function(_id) return _id, table.deepcopy(data["base.map_tile"]:ensure(_id)) end):to_map()
   local chips = fun.iter(chip_ids):map(function(_id) return _id, table.deepcopy(data["base.chip"]:ensure(_id)) end):to_map()

   -- Get the callbacks that apply the theme overrides.
   local transform_tile = data["base.theme_transform"]:ensure("base.map_tile")
   local transform_chip = data["base.theme_transform"]:ensure("base.chip")

   -- Earlier themes override later ones.
   themes = table.shallow_copy(themes)
   table.reverse(themes)

   local theme_entries = fun.iter(themes)
      :map(function(_id) return data["base.theme"]:ensure(_id) end)

   -- Apply each override to the tiles/chips in the preview map.
   for _, active_theme in theme_entries:unwrap() do
      local overrides = active_theme.overrides["base.map_tile"]
      if overrides then
         for _, tile_id in ipairs(tile_ids) do
            local override = overrides[tile_id]
            if override then
               local old = tiles[tile_id]
               tiles[tile_id] = transform_tile.transform(old, override)
            end
         end
      end

      overrides = active_theme.overrides["base.chip"]
      if overrides then
         for _, chip_id in ipairs(chip_ids) do
            local override = overrides[chip_id]
            if override then
               local old = chips[chip_id]
               chips[chip_id] = transform_chip.transform(old, override)
            end
         end
      end
   end

   return table.values(tiles), table.values(chips)
end

function ConfigThemeMenuPreview:_update_renderer()
   self.tile_ids, self.chip_ids = extract_tile_and_chip_ids(self.map)

   local tiles, chips = build_overrides(self.themes, self.tile_ids, self.chip_ids)

   self.tile_atlas = theme.load_tilemap_tile(tiles)
   self.tile_overhang_atlas = theme.load_tilemap_tile_overhang(tiles)

   self.chip_atlas = theme.load_tilemap_chip(chips)
   self.item_shadow_atlas = theme.load_tilemap_item_shadow(chips)

   local mw = self.map:width()
   local mh = self.map:height()

   local new_tile_layer = tile_layer:new(mw, mh)
   new_tile_layer:set_atlas(self.tile_atlas)

   local new_tile_overhang_layer = tile_layer:new(mw, mh)
   new_tile_overhang_layer:set_atlas(self.tile_overhang_atlas)

   local new_chip_layer = chip_layer:new(mw, mh)
   new_chip_layer:set_atlases(self.chip_atlas, self.item_shadow_atlas)

   local spec = DrawLayerSpec:new()
   spec:register_draw_layer("tile_layer", new_tile_layer)
   spec:register_draw_layer("chip_layer", new_chip_layer)
   -- spec:register_draw_layer("tile_overhang_layer", new_tile_overhang_layer)

   if self.map_renderer then
      self.map_renderer:set_draw_layer_spec(spec)
      self.map_renderer:set_map(self.map)
   else
      self.map_renderer = MapRenderer:new(self.map, spec)
   end
end

function ConfigThemeMenuPreview:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height

   self.map_renderer:relayout(self.x, self.y, self.width, self.height)
end

function ConfigThemeMenuPreview:draw()
   Draw.set_color(255, 255, 255)
   self.map_renderer:draw()
end

function ConfigThemeMenuPreview:update(dt)
   self.map_renderer:update(dt)
end

return ConfigThemeMenuPreview
