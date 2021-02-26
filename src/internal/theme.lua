local atlas = require("internal.draw.atlas")
local data = require("internal.data")
local draw = require("internal.draw")
local Log = require("api.Log")
local Stopwatch = require("api.Stopwatch")
local field = require("game.field")
local main_state = require("internal.global.main_state")
local UiTheme = require("api.gui.UiTheme")
local bmp_convert = require("internal.bmp_convert")
local config = require("internal.config")
local Gui = require("api.Gui")
local Event = require("api.Event")

local theme = {}

function theme.get_tile_size()
   return draw.get_coords():get_size()
end

local types = {}

types["base.chip"] = function(old, new)
   local fields = {
      image = new.image,
      width = new.width,
      height = new.height,
      tall = new.tall,
      key_color = new.key_color
   }
   if fields.tall == nil then
      fields.tall = old.tall
   end
   return table.merge(old, fields)
end

types["base.sound"] = function(old, new)
   local fields = {
      file = new.file
   }
   return table.merge(old, fields)
end

types["base.map_tile"] = function(old, new)
   local fields = {
      image = new.image
   }
   return table.merge(old, fields)
end

types["base.portrait"] = function(old, new)
   local fields = {
      image = new.image
   }
   return table.merge(old, fields)
end

types["base.pcc_part"] = function(old, new)
   local fields = {
      image = new.image,
      key_color = new.key_color
   }
   return table.merge(old, fields)
end

types["base.asset"] = function(old, new)
   local fields = {
      -- TODO: maybe use only "image" and detect type based on x/y/width/height
      -- parameter presence, like all other asset types
      image = new.image,
      source = new.source,

      x = new.x,
      y = new.y,
      width = new.width,
      height = new.height,
      count_x = new.count_x,
      count_y = new.count_y,
      key_color = new.key_color,

      -- XXX: probably a bad idea to mod this, given the pervasive amount of
      -- fixed offsets used when rendering. The better option would to be code
      -- entirely new GUIs instead.
      --
      -- regions = new.regions
   }
   return table.merge(old, fields)
end

--- Builds a modified table of all supported assets with the overrides set in
--- the config option `base.themes`.
function theme.build_overrides()
   -- Build a table of all unmodified assets like this:
   --
   -- {
   --    ["base.chip"] = {
   --      ["elona.chara_putit"] = { _id = "elona.chara_putit", image = "..." },
   --      ["elona.chara_yeek"] = { _id = "elona.chara_yeek", image = "..." },
   --      ...
   --    },
   --    ["base.map_tile"] = { ... },
   --    ...
   -- }
   --
   -- Deepcopy each original entry to avoid mutating it. We want to be able to
   -- go back to a clean state if the user disables themes in the config menu,
   -- without the need to restart.
   local make_entry_map = function(ty)
      return ty, data[ty]:iter():map(function(t) return t._id, table.deepcopy(t) end):to_map()
   end
   local supported_types = table.keys(types)
   local t = fun.iter(supported_types):map(make_entry_map):to_map()

   -- Get the list of overrides for each theme.
   local active_theme_ids = table.shallow_copy(config.base.themes or {})
   local active_themes = fun.iter(active_theme_ids):map(function(_id) return data["base.theme"]:ensure(_id) end)

   -- later themes override earlier ones
   for _, active_theme in active_themes:unwrap() do
      for _, new_entry in ipairs(active_theme.overrides) do
         local _type = new_entry._type
         local _id = new_entry._id

         assert(types[_type], ("Unsupported theme type '%s'"):format(_type))

         -- Get the original entry in the working copy and modify it.
         --
         -- TODO if this theme offers more than one override for the same _id,
         -- allow the user to configure which one gets chosen.
         local old_entry = t[_type][_id]
         if old_entry then
            t[_type][_id] = types[_type](old_entry, new_entry)
         else
            Log.error("Theme '%s' overrides '%s.%s', but it was missing. Are you missing a mod?", active_theme._id, _type, _id)
         end
      end
   end

   -- The shape of the final data looks like this:
   --
   -- {
   --    ["base.chip"] = {
   --      { _id = "elona.chara_putit", image = "..." },
   --      { _id = "elona.chara_yeek", image = "..." },
   --      ...
   --    },
   --    ["base.map_tile"] = { ... },
   --    ...
   -- }
   local final = {}

   for _type, entries in pairs(t) do
      local list = {}
      for _, entry in pairs(entries) do
         list[#list+1] = entry
      end
      final[_type] = list
   end

   return final, active_theme_ids
end

function theme.load_tilemap_tile(map_tiles)
   map_tiles = map_tiles or data["base.map_tile"]:iter():to_list()

   local tw, th = theme.get_tile_size()

   local tile_atlas = atlas:new(tw, th)
   tile_atlas:load(map_tiles, draw.get_coords())
   return tile_atlas
end

function theme.load_tilemap_tile_overhang(map_tiles)
   local iter
   if map_tiles then
      iter = fun.iter(map_tiles)
   else
      iter = data["base.map_tile"]:iter()
   end
   local map_overhang_tiles = iter
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

function theme.load_tilemap_item_shadow(chip_tiles)
   chip_tiles = chip_tiles or data["base.chip"]:iter():to_list()

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

function theme.load_tilemap_chip(chip_tiles)
   chip_tiles = chip_tiles or data["base.chip"]:iter():to_list()

   local tw, th =  theme.get_tile_size()
   local chip_atlas = atlas:new(tw, th)
   chip_atlas:load(chip_tiles)
   return chip_atlas
end

function theme.load_tilemap_portrait(portrait_tiles)
   portrait_tiles = portrait_tiles or data["base.portrait"]:iter():to_list()

   local portrait_atlas = atlas:new(48, 72)
   portrait_atlas:load(portrait_tiles)
   return portrait_atlas
end

local active_themes = table.set {}

function theme.is_active(theme_id)
   return not not active_themes[theme_id]
end

function theme.reload_all(log_cb)
   log_cb = log_cb or Log.info

   Log.debug("Reloading theme.")

   bmp_convert.clear_cache()

   local overrides, _active_themes = theme.build_overrides()
   local map_tiles = overrides["base.map_tile"]
   local chip_tiles = overrides["base.chip"]
   local portrait_tiles = overrides["base.portrait"]

   local sw = Stopwatch:new()

   log_cb("Loading tilemaps (tile)...")
   local tile_atlas = theme.load_tilemap_tile(map_tiles)
   Log.debug("%s", sw:measure_and_format("Load tilemap: tile"))

   log_cb("Loading tilemaps (overhang)...")
   local tile_overhang_atlas = theme.load_tilemap_tile_overhang(map_tiles)
   Log.debug("%s", sw:measure_and_format("Load tilemap: overhang"))

   log_cb("Loading tilemaps (item shadow)...")
   local item_shadow_atlas = theme.load_tilemap_item_shadow(chip_tiles)
   Log.debug("%s", sw:measure_and_format("Load tilemap: item shadow"))

   log_cb("Loading tilemaps (chip)...")
   local chip_atlas = theme.load_tilemap_chip(chip_tiles)
   Log.debug("%s", sw:measure_and_format("Load tilemap: chip"))

   log_cb("Loading tilemaps (portrait)...")
   local portrait_atlas = theme.load_tilemap_portrait(portrait_tiles)
   Log.debug("%s", sw:measure_and_format("Load tilemap: portrait"))

   local atlases = require("internal.global.atlases")
   atlases.set(tile_atlas,
               tile_overhang_atlas,
               item_shadow_atlas,
               chip_atlas,
               portrait_atlas)

   log_cb("Loading theme...")

   local asset_map = fun.iter(overrides["base.asset"])
      :map(function(a) return a._id, a end)
      :to_map()

   UiTheme.clear()
   UiTheme.set_assets(asset_map)

   active_themes = table.set(_active_themes)

   -- Check if we're changing the theme in-game, and if so, do some special
   -- cleanup.
   if main_state.is_main_title_reached then
      -- Call :relayout() on every active layer. This should fully propagate the
      -- theme change, because the way things are designed is that each UI
      -- component is responsible for updating the theme in its :relayout()
      -- method, using "self.t = UiTheme.load()" or similar. Maybe this isn't a
      -- good way of standardizing things for modders, seeing as this is not
      -- handled automatically, but for now it works, so I won't complain...
      draw.resize(nil, nil)

      -- Update each draw layer with the new tile/chip atlases.
      field:on_theme_switched()

      Gui.update_screen()

      Event.trigger("base.on_theme_switched")
   end
end

return theme
