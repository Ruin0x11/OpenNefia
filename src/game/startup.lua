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
local UiFpsCounter = require("api.gui.hud.UiFpsCounter")


local startup = {}

local progress_step = 0
local status = ""
function startup.get_progress()
   return status, progress_step, 12
end

local function progress(_status)
   status = _status
   coroutine.yield()
   progress_step = progress_step + 1
end

local function copy_files(src, dest)
   local fs = require("util.fs")

   if not fs.exists(src) then
      error(("Directory %s does not exist; does 'src/deps/elona' exist?"):format(src))
   end

   for _, name in fs.iter_directory_items(src) do
      local src_file = fs.join(src, name)
      local dest_file = fs.join(fs.get_working_directory(), dest, name)

      -- HACK: Because of LÖVE's restriction that you can only write
      -- files to the save directory with love.filesystem, we have to
      -- drop down into using `io` to copy the dependencies from
      -- 1.22's folder without needing an external build step.
      if not fs.is_file(dest_file) then
         local f = assert(io.open(src_file, "rb"))
         local data = f:read("*all")
         f:close()

         f = assert(io.open(dest_file, "wb"))
         f:write(data)
         f:close()
      end
   end
end

local function check_dependencies()
   copy_files("deps/elona/graphic", "graphic")
   copy_files("deps/elona/sound", "mod/elona/sound")
end

local function load_keybinds()
   local Input = require("api.Input")
   Input.reload_keybinds()
end

-- skip documenting api tables to save startup time from dozens of
-- requires.
-- TODO should be config option
local alias_api_tables = false

function startup.run_all(mods)
   -- we're running headless, turn off expensive documentation loading
   alias_api_tables = false

   local coro = coroutine.create(function() startup.run(mods) end)
   while startup.get_progress() ~= nil do
      local ok, err = coroutine.resume(coro)
      if not ok then
         error(debug.traceback(coro, err))
      end
   end
end

function startup.run(mods)
   progress("Checking dependencies...")

   check_dependencies()

   progress("Loading early modules...")

   -- Wrap these functions to allow hotloading via table access.
   rawset(_G, "help", function(...) return Doc.help(...) end)
   rawset(_G, "pause", function(...) return Repl.pause(...) end)

   draw.add_global_widget(UiFpsCounter:new(), "fps_counter")

   progress("Loading documentation...")

   doc.load(alias_api_tables)

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
   progress()
end

function startup.shutdown()
   doc.save()
end

local atlas = require("internal.draw.atlas")

local mkpred = function(group)
   return function(i) return i.group == group end
end

local function get_map_tiles()
   return data["base.map_tile"]:iter():to_list()
end

local function get_map_overhang_tiles()
   return data["base.map_tile"]:iter():filter(function(t) return t.wall_kind ~= nil end):to_list()
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
   local tw, th = coords:get_size()
   local load_tile = function(atlas, proto)
      local draw = function(tile, quad, x, y)
         local qx, qy, _, _ = quad:getViewport()
         quad:setViewport(qx, qy, tw, math.floor(th / 4))
         love.graphics.draw(tile, quad, x, y)
      end
      atlas:load_one(proto, draw)
   end
   local tile_overhang_atlas = atlas:new(tile_size, tile_size)
   tile_overhang_atlas:load(get_map_overhang_tiles(), nil, load_tile)

   sw:p("load_batches.tile_overhang")

   -- HACK
   progress("Loading tilemaps (item shadow)...")
   local load_tile = function(atlas, proto)
      local draw = function(tile, quad, x, y)
         love.graphics.setColor(0, 0, 0)
         love.graphics.draw(tile, quad, x, y)
         love.graphics.setColor(1, 1, 1)
      end
      atlas:load_one(proto, draw)
   end
   local item_shadow_atlas = atlas:new(tile_size, tile_size)
   item_shadow_atlas:load(get_chip_tiles(), nil, load_tile)

   sw:p("load_batches.item_shadow")

   progress("Loading tilemaps (chip)...")
   local chip_atlas = atlas:new(tile_size, tile_size)
   chip_atlas:load(get_chip_tiles())

   sw:p("load_batches.feat")

   progress("Loading tilemaps (portrait)...")
   local portrait_atlas = atlas:new(48, 72)
   portrait_atlas:load(get_portrait_tiles())

   sw:p("load_batches.portrait")

   local atlases = require("internal.global.atlases")
   atlases.set(tile_atlas,
               tile_overhang_atlas,
               item_shadow_atlas,
               chip_atlas,
               portrait_atlas)
end

return startup
