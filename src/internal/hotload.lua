local Log = require("api.Log")
local env = require("internal.env")
local Event = require("api.Event")
local theme = require("internal.theme")

local hotload = {}

local hotloaded_data = {}
local hotloaded_types = table.set {}

local function clear_hotloaded_data()
   hotloaded_data = {}
   hotloaded_types = table.set {}
end
local function add_hotloaded_data(_, args)
   hotloaded_data[#hotloaded_data+1] = args.entry
   hotloaded_types[args.entry._type] = true
end

-- Pass a list of everything hotloaded when hotloading finishes.
Event.register("base.on_hotload_begin", "Clear hotloaded data list", clear_hotloaded_data)
Event.register("base.on_hotload_prototype", "Add to hotloaded data list", add_hotloaded_data)


--- Reloads a path or a class required from a path that has been
--- required already by updating its table in-place. If either the
--- result of `require` or the existing item in package.loaded are not
--- tables, the existing item is overwritten instead.
-- @tparam string|table path
-- @tparam bool also_deps If true, also hotload any nested
-- dependencies loaded with `require` that any hotloaded chunk tries
-- to load.
-- @treturn table
function hotload.hotload(path_or_class, also_deps)
   if type(path_or_class) == "table" then
      local path = env.get_require_path(path_or_class)
      if path == nil then
         error("Unknown require path for " .. tostring(path_or_class))
      end

      path_or_class = path
   end

   local ok, result, err
   ok, result = pcall(Event.trigger, "base.on_hotload_begin", {path_or_class=path_or_class,also_deps=also_deps})
   if not ok then
      Log.error("Error on on_hotload_begin: %s", result)
      err = result
   end

   ok, result = xpcall(env.hotload_path, debug.traceback, path_or_class, also_deps)
   if not ok then
      Log.error("Error on hotload_path: %s", result)
      err = result
   end

   ok, result = xpcall(Event.trigger, debug.traceback,
                       "base.on_hotload_end", {
                         hotloaded_data=hotloaded_data,
                         hotloaded_types=hotloaded_types,
                         path_or_class=path_or_class,
                         also_deps=also_deps,
                         ok=ok,
                         result=result
   })

   if not ok then
      Log.error("Error on hotload_end: %s", result)
      err = result
   end

   if err then
      error(err)
   end

   return result
end

Event.register("base.on_hotload_end", "Hotload field renderer",
               function()
                  local field = require("game.field")
                  if field.is_active then
                     field.renderer.screen_updated = true
                     field.renderer:update(0)
                  end
               end)

-- Event.register("base.on_hotload_prototype", "Hotload UI theme",
--                function(_, args)
--                   if args.entry._type == "base.theme" then
--                      local UiTheme = require("api.gui.UiTheme")
--                      UiTheme.clear()
--                      local default_theme = "base.default"
--                      UiTheme.add_theme(default_theme)
--                   end
--                end)

local THEME_TYPES = table.set {
   "base.theme",
   "base.chip",
   "base.asset",
   "base.portrait",
   "base.map_tile",
   "base.sound",
   "base.pcc_part"
}

Event.register("base.on_hotload_end", "Reload theme if assets were hotloaded",
               function(_, params)
                  local need_reload = fun.iter(table.keys(params.hotloaded_types))
                      :any(function(_type) return THEME_TYPES[_type] end)
                  if need_reload then
                     theme.reload_all()
                  end
               end)

return hotload
