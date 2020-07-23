local atlas = require("internal.draw.atlas")
local data = require("internal.data")
local draw = require("internal.draw")
local Log = require("api.Log")
local Stopwatch = require("api.Stopwatch")
local field = require("game.field")
local main_state = require("internal.global.main_state")
local UiTheme = require("api.gui.UiTheme")
local bmp_convert = require("internal.bmp_convert")

local theme = {}

function theme.get_tile_size()
   return draw.get_coords():get_size()
end

function theme.load_tilemap_tile()
   local map_tiles = data["base.map_tile"]:iter():to_list()

   local tw, th = theme.get_tile_size()

   local tile_atlas = atlas:new(tw, th)
   tile_atlas:load(map_tiles, draw.get_coords())
   return tile_atlas
end

function theme.load_tilemap_tile_overhang()
   local map_overhang_tiles = data["base.map_tile"]:iter()
       :filter(function(t) return t.wall_kind ~= nil end)
       :to_list()

   local tw, th = theme.get_tile_size()

   local draw_tile = function(tile, quad, x, y)
      local qx, qy, _, _ = quad:getViewport()
      quad:setViewport(qx, qy, tw, math.floor(th / 4))
      love.graphics.draw(tile, quad, x, y)
   end
   local load_tile = function(atlas, proto)
      atlas:load_one(proto, draw_tile)
   end

   local tile_overhang_atlas = atlas:new(tw, th)
   tile_overhang_atlas:load(map_overhang_tiles, nil, load_tile)
   return tile_overhang_atlas
end

function theme.load_tilemap_item_shadow()
   local chip_tiles = data["base.chip"]:iter():to_list()

   local tw, th = theme.get_tile_size()

   local draw_tile = function(tile, quad, x, y)
      love.graphics.setColor(0, 0, 0)
      love.graphics.draw(tile, quad, x, y)
      love.graphics.setColor(1, 1, 1)
   end
   local load_tile = function(atlas, proto)
      atlas:load_one(proto, draw_tile)
   end

   local item_shadow_atlas = atlas:new(tw, th)
   item_shadow_atlas:load(chip_tiles, nil, load_tile)
   return item_shadow_atlas
end

function theme.load_tilemap_chip()
   local chip_tiles = data["base.chip"]:iter():to_list()

   local tw, th =  theme.get_tile_size()
   local chip_atlas = atlas:new(tw, th)
   chip_atlas:load(chip_tiles)
   return chip_atlas
end

function theme.load_tilemap_portrait()
   local portrait_tiles = data["base.portrait"]:iter():to_list()

   local portrait_atlas = atlas:new(48, 72)
   portrait_atlas:load(portrait_tiles)
   return portrait_atlas
end

function theme.reload_all(log_cb)
   log_cb = log_cb or Log.info

   Log.info("Reloading theme.")

   bmp_convert.clear_cache()

   local sw = Stopwatch:new()

   log_cb("Loading tilemaps (tile)...")
   local tile_atlas = theme.load_tilemap_tile()
   Log.info("%s", sw:measure_and_format("Load tilemap: tile"))

   log_cb("Loading tilemaps (overhang)...")
   local tile_overhang_atlas = theme.load_tilemap_tile_overhang()
   Log.info("%s", sw:measure_and_format("Load tilemap: overhang"))

   log_cb("Loading tilemaps (item shadow)...")
   local item_shadow_atlas = theme.load_tilemap_item_shadow()
   Log.info("%s", sw:measure_and_format("Load tilemap: item shadow"))

   log_cb("Loading tilemaps (chip)...")
   local chip_atlas = theme.load_tilemap_chip()
   Log.info("%s", sw:measure_and_format("Load tilemap: chip"))

   log_cb("Loading tilemaps (portrait)...")
   local portrait_atlas = theme.load_tilemap_portrait()
   Log.info("%s", sw:measure_and_format("Load tilemap: portrait"))

   local atlases = require("internal.global.atlases")
   atlases.set(tile_atlas,
               tile_overhang_atlas,
               item_shadow_atlas,
               chip_atlas,
               portrait_atlas)

   -- Check if we're changing the theme in-game, and if so, do some special
   -- cleanup.
   if main_state.is_main_title_reached then
      -- Clear the cache of loaded theme assets.
      local id = UiTheme.theme_id()
      assert(id)
      UiTheme.clear()
      UiTheme.add_theme(id)

      -- Call :relayout() on every active layer. This should fully propagate the
      -- theme change, because the way things are designed is that each UI
      -- component is responsible for updating the theme in its :relayout()
      -- function, using "self.t = UiTheme.load()" or similar. Maybe this isn't
      -- a good way of standardizing things for modders, seeing as this is not
      -- handled automatically, but for now it works, so I won't complain...
      draw.resize(nil, nil)

      -- Update each draw layer with the new atlases.
      field:on_theme_switched()
   end
end

return theme
