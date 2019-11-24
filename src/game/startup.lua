local mod = require("internal.mod")
local internal = require("internal")
local i18n = require("internal.i18n")
local data = require("internal.data")
local field = require("game.field")
local Stopwatch = require("api.Stopwatch")
local UiTheme = require("api.gui.UiTheme")
local Event = require("api.Event")
local Log = require("api.Log")

local startup = {}

function startup.run(mods)
   math.randomseed(internal.get_timestamp())

   require("internal.data.base")

   mod.load_mods(mods)
   data:run_all_edits()

   -- data is finalized at this point.

   startup.load_batches()

   i18n.switch_language("en")

   local default_theme = "elona_sys.default"
   UiTheme.add_theme(default_theme)

   field:setup_repl()

   Event.trigger("base.on_game_startup")
end

local tile_batch = require("internal.draw.tile_batch")
local sparse_batch = require("internal.draw.sparse_batch")
local atlas = require("internal.draw.atlas")
local batches = {}

local mkpred = function(group)
   return function(i) return i.group == group end
end

local function get_map_tiles()
   return data["base.map_tile"]:iter()
end

local function get_map_overhang_tiles()
   return data["base.map_tile"]:iter():filter(function(t) return t.wall_kind ~= nil end)
end

local function get_chara_tiles()
   return data["base.chip"]:iter():filter(mkpred("chara"))
end

local function get_item_tiles()
   return data["base.chip"]:iter():filter(mkpred("item"))
end

local function get_feat_tiles()
   return data["base.chip"]:iter():filter(mkpred("feat"))
end

local function get_portrait_tiles()
   return data["base.portrait"]:iter()
end

local tile_size = 48
local atlas_size = 96

function startup.load_batches()
   Log.info("Loading tile batches.")

   local coords = require("internal.draw.coords.tiled_coords"):new()
   internal.draw.set_coords(coords)

   local sw = Stopwatch:new()
   sw:measure()

   local tile_atlas = atlas:new(atlas_size, atlas_size, tile_size, tile_size)
   tile_atlas:load(get_map_tiles(), coords)

   sw:p("load_batches.tile")

   local tile_overhang_atlas = atlas:new(atlas_size, atlas_size, tile_size, math.floor(tile_size / 4), 0, 16)
   tile_overhang_atlas:load(get_map_overhang_tiles(), coords)

   sw:p("load_batches.tile_overhang")

   local chara_atlas = atlas:new(atlas_size, atlas_size, tile_size, tile_size)
   chara_atlas:load(get_chara_tiles())

   sw:p("load_batches.chara")

   local item_atlas = atlas:new(atlas_size, atlas_size, tile_size, tile_size)
   item_atlas:load(get_item_tiles())

   sw:p("load_batches.item")

   -- HACK
   local load_tile = function(atlas, proto)
      local draw = function(tile, x, y)
         love.graphics.setColor(0, 0, 0)
         love.graphics.draw(tile, x, y)
         love.graphics.setColor(1, 1, 1)
      end
      atlas:load_one(proto, draw)
   end
   local item_shadow_atlas = atlas:new(atlas_size, atlas_size, tile_size, tile_size)
   item_shadow_atlas:load(get_item_tiles(), nil, load_tile)

   sw:p("load_batches.item_shadow")

   local feat_atlas = atlas:new(atlas_size, atlas_size, tile_size, tile_size)
   feat_atlas:load(get_feat_tiles())

   sw:p("load_batches.feat")

   local portrait_atlas = atlas:new(100, 100, 48, 72)
   portrait_atlas:load(get_portrait_tiles())

   sw:p("load_batches.portrait")

   local atlases = require("internal.global.atlases")
   atlases.set(tile_atlas, tile_overhang_atlas, chara_atlas, item_atlas, item_shadow_atlas, feat_atlas, portrait_atlas)
end

return startup
