local internal = require("internal")
local mod = require("internal.mod")
local i18n = require("internal.i18n")
local data = require("internal.data")
local doc = require("internal.doc")
local field = require("game.field")
local Stopwatch = require("api.Stopwatch")
local UiTheme = require("api.gui.UiTheme")
local Event = require("api.Event")
local Log = require("api.Log")
local Doc = require("api.Doc")
local Repl = require("api.Repl")

local startup = {}

local progress_step = 0
local status = ""
function startup.get_progress()
   return status, progress_step, 11
end

local function progress(_status)
   status = _status
   progress_step = progress_step + 1
   coroutine.yield()
end

function startup.run_all(mods)
   local coro = coroutine.create(function() startup.run(mods) end)
   while startup.get_progress() ~= "progress_finished" do
      coroutine.resume(coro)
   end
end

function startup.run(mods)
   progress("Loading mods...")

   -- Wrap these functions to allow hotloading via table access.
   rawset(_G, "help", function(...) return Doc.help(...) end)
   rawset(_G, "pause", function(...) return Repl.pause(...) end)

   if jit and jit.status() == false then
      Log.warn("JIT compiler is _off_ due to sethook/debug settings.")
   end

   math.randomseed(internal.get_timestamp())

   require("internal.data.base")

   mod.load_mods(mods)
   data:run_all_edits()

   progress("Loading documentation...")

   doc.load()

   -- data is finalized at this point.

   progress("Loading tilemaps...")

   startup.load_batches()

   progress("Loading translations...")

   i18n.switch_language("jp")

   progress("Loading theme...")

   local default_theme = "elona_sys.default"
   UiTheme.add_theme(default_theme)

   field:setup_repl()

   Event.trigger("base.on_game_startup")

   progress("Finished.")
   progress("progress_finished")
end

function startup.shutdown()
   doc.save()
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

   progress("Loading tilemaps (tile)...")
   local tile_atlas = atlas:new(atlas_size, atlas_size, tile_size, tile_size)
   tile_atlas:load(get_map_tiles(), coords)

   sw:p("load_batches.tile")

   progress("Loading tilemaps (overhang)...")
   local tile_overhang_atlas = atlas:new(atlas_size, atlas_size, tile_size, math.floor(tile_size / 4), 0, 16)
   tile_overhang_atlas:load(get_map_overhang_tiles(), coords)

   sw:p("load_batches.tile_overhang")

   progress("Loading tilemaps (character)...")
   local chara_atlas = atlas:new(atlas_size, atlas_size, tile_size, tile_size)
   chara_atlas:load(get_chara_tiles())

   sw:p("load_batches.chara")

   progress("Loading tilemaps (item)...")
   local item_atlas = atlas:new(atlas_size, atlas_size, tile_size, tile_size)
   item_atlas:load(get_item_tiles())

   sw:p("load_batches.item")

   -- HACK
   progress("Loading tilemaps (item shadow)...")
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

   progress("Loading tilemaps (feat)...")
   local feat_atlas = atlas:new(atlas_size, atlas_size, tile_size, tile_size)
   feat_atlas:load(get_feat_tiles())

   sw:p("load_batches.feat")

   progress("Loading tilemaps (portrait)...")
   local portrait_atlas = atlas:new(100, 100, 48, 72)
   portrait_atlas:load(get_portrait_tiles())

   sw:p("load_batches.portrait")

   local atlases = require("internal.global.atlases")
   atlases.set(tile_atlas, tile_overhang_atlas, chara_atlas, item_atlas, item_shadow_atlas, feat_atlas, portrait_atlas)
end

return startup
