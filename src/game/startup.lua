local internal = require("internal")
local mod = require("internal.mod")
local i18n = require("internal.i18n")
local data = require("internal.data")
local doc = require("internal.doc")
local draw = require("internal.draw")
local field = require("game.field")
local Stopwatch = require("api.Stopwatch")
local UiTheme = require("api.gui.UiTheme")
local Event = require("api.Event")
local Log = require("api.Log")
local Doc = require("api.Doc")
local Rand = require("api.Rand")
local Repl = require("api.Repl")

local startup = {}

local progress_step = 0
local status = ""
function startup.get_progress()
   return status, progress_step, 12
end

local function progress(_status)
   status = _status
   progress_step = progress_step + 1
   coroutine.yield()
end

local function load_keybinds()
   local input = require("internal.input")

   local keybinds = {}
   for _, kb in data["base.keybind"]:iter() do
      local id = kb._id

      -- allow omitting "base." if the keybind is provided by the base
      -- mod.
      if string.match(id, "^base%.") then
         id = string.split(id, ".")[2]
      end

      keybinds[#keybinds+1] = {
         action = id,
         primary = kb.default,
         alternate = kb.default_alternate,
      }
   end

   input.set_keybinds(keybinds)
end

-- skip documenting api tables to save startup time from dozens of
-- requires.
-- TODO should be config option
local alias_api_tables = false

function startup.run_all(mods)
   -- we're running headless, turn off expensive documentation loading
   alias_api_tables = false

   local coro = coroutine.create(function() startup.run(mods) end)
   while startup.get_progress() ~= "progress_finished" do
      local ok, err = coroutine.resume(coro)
      if not ok then
         error(debug.traceback(coro, err))
      end
   end
end

function startup.run(mods)
   progress("Loading documentation...")

   doc.load(alias_api_tables)

   -- Wrap these functions to allow hotloading via table access.
   rawset(_G, "help", function(...) return Doc.help(...) end)
   rawset(_G, "pause", function(...) return Repl.pause(...) end)

   if rawget(_G, "jit") and jit.status() == false then
      Log.warn("JIT compiler is _off_ due to sethook/debug settings.")
   end

   -- For determinism during mod loading.
   Rand.set_seed(0)

   require("internal.data.base")

   progress("Loading mods...")

   mod.load_mods(mods)
   data:run_all_edits()

   -- data is finalized at this point.

   -- if alias_api_tables then
   --    doc.alias_api_tables()
   -- end

   progress("Loading tilemaps...")

   startup.load_batches()

   progress("Loading translations...")

   i18n.switch_language("jp")

   progress("Loading theme...")

   local default_theme = "elona_sys.default"
   UiTheme.add_theme(default_theme)

   field:setup_repl()

   Event.trigger("base.on_game_startup")

   load_keybinds()

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
   return data["base.map_tile"]:iter():to_list()
end

local function get_map_overhang_tiles()
   return data["base.map_tile"]:iter():filter(function(t) return t.wall_kind ~= nil end):to_list()
end

local function get_chara_tiles()
   return data["base.chip"]:iter():filter(mkpred("chara")):to_list()
end

local function get_item_tiles()
   return data["base.chip"]:iter():filter(mkpred("item")):to_list()
end

local function get_feat_tiles()
   return data["base.chip"]:iter():filter(mkpred("feat")):to_list()
end

local function get_chip_tiles()
   return data["base.chip"]:iter():to_list()
end

local function get_portrait_tiles()
   return data["base.portrait"]:iter():to_list()
end

local tile_size = 48

function startup.load_batches()
   Log.info("Loading tile batches.")

   local coords = require("internal.draw.coords.tiled_coords"):new()
   draw.set_coords(coords)

   local sw = Stopwatch:new()
   sw:measure()

   progress("Loading tilemaps (tile)...")
   local tile_atlas = atlas:new(tile_size, tile_size)
   tile_atlas:load(get_map_tiles(), coords)

   sw:p("load_batches.tile")

   progress("Loading tilemaps (overhang)...")
   local tile_overhang_atlas = atlas:new(tile_size, tile_size)
   tile_overhang_atlas:load(get_map_overhang_tiles(), coords)

   sw:p("load_batches.tile_overhang")

   progress("Loading tilemaps (character)...")
   local chara_atlas = atlas:new(tile_size, tile_size)
   chara_atlas:load(get_chara_tiles())

   sw:p("load_batches.chara")

   progress("Loading tilemaps (item)...")
   local item_atlas = atlas:new(tile_size, tile_size)
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
   local item_shadow_atlas = atlas:new(tile_size, tile_size)
   item_shadow_atlas:load(get_item_tiles(), nil, load_tile)

   sw:p("load_batches.item_shadow")

   progress("Loading tilemaps (feat)...")
   local feat_atlas = atlas:new(tile_size, tile_size)
   feat_atlas:load(get_feat_tiles())

   sw:p("load_batches.feat")

   progress("Loading tilemaps (chip)...")
   local chip_atlas = atlas:new(tile_size, tile_size)
   chip_atlas:load(get_chip_tiles())

   sw:p("load_batches.feat")

   progress("Loading tilemaps (portrait)...")
   local portrait_atlas = atlas:new(48, 72)
   portrait_atlas:load(get_portrait_tiles())

   sw:p("load_batches.portrait")

   local atlases = require("internal.global.atlases")
   atlases.set(tile_atlas, tile_overhang_atlas, chara_atlas, item_atlas, item_shadow_atlas, feat_atlas, chip_atlas, portrait_atlas)
end

return startup
