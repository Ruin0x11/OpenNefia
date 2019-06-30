local InputHandler = require("api.gui.InputHandler")
local IUiLayer = require("api.gui.IUiLayer")
local DateTime = require("api.DateTime")
local IInput = require("api.gui.IInput")
local Log = require("api.Log")

local env = require("internal.env")
local fs = require("internal.fs")
local field_renderer = require("internal.field_renderer")

local field_layer = class.class("field_layer", IUiLayer)

field_layer:delegate("keys", IInput)

function field_layer:init()
   self.is_active = false

   self.hud = require("api.gui.hud.MainHud"):new()

   self.map = nil
   self.renderer = nil
   self.player = nil
   self.allies = {}
   self.repl = nil

   self.map_changed = false
   self.no_scroll = true

   self:init_global_data()

   self.keys = InputHandler:new()
   self.keys:focus()

   self.layers = {
      "internal.layer.tile_layer",
      "internal.layer.feat_layer",
      "internal.layer.item_layer",
      "internal.layer.chara_layer",
      "internal.layer.shadow_layer",
   }
end

local function require_all_apis(dir)
   dir = dir or "api"

   local api_env = {}

   for _, api in fs.iter_directory_items(dir .. "/") do
      local path = fs.join(dir, api)
      if fs.is_file(path) then
         local name = fs.filename_part(path)
         if api_env[name] then
            Log.warn("Duplicate API required in environment: %s", name)
         end
         api_env[name] = env.require(path)
      elseif fs.is_directory(path) then
         table.merge(api_env, require_all_apis(path))
      end
   end

   return api_env
end

function field_layer:setup_repl()
   -- avoid circular requires that depend on internal.field, since
   -- this auto-requires the full public API.
   local Repl = require("api.gui.menu.Repl")

   local repl_env = env.generate_sandbox("repl")
   local apis = require_all_apis()
   repl_env = table.merge(repl_env, apis)

   -- WARNING: for development only.
   if _DEBUG then
      repl_env = table.merge(repl_env, _G)
   end

   local history = {}
   local file = io.open("repl_history.txt", "r")
   if file ~= nil then
      for line in file:lines() do
         history[#history + 1] = line
      end
   end

   self.repl = Repl:new(repl_env, history)
end

function field_layer:init_global_data()
   -- TEMP: temporary storage for save-global variables. needs to be
   -- moved a public store API.
   self.data = {}
   self.data.date = DateTime:new(517, 8, 12, 16, 10, 0)
   self.data.play_turns = 0
   self.data.play_days = 0
end

function field_layer:set_map(map)
   self.map = map
   self.renderer = field_renderer:new(map.width, map.height, self.layers)
   self.map_changed = true
   self.no_scroll = true
end

function field_layer:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.hud:relayout(x, y, width, height)
end

function field_layer:turn_cost()
   return self.map.turn_cost
end

function field_layer:get_object(_type, uid)
   return self.map and self.map:get_object_of_type(_type, uid)
end

function field_layer:update_screen(scroll)
   if not self.is_active or not self.renderer then return end

   if scroll == nil then
      scroll = false
   end

   scroll = scroll and (not self.no_scroll)

   assert(self.map ~= nil)

   local player = self.player
   if player then
      self.renderer:update_draw_pos(player.x, player.y, scroll)
      self.map:calc_screen_sight(player.x, player.y, player.fov or 15)
   end

   local dt = 0

   local going = true
   while going do
      self.keys:update_repeats(dt)
      going = self.renderer:update(dt)
      dt = coroutine.yield() or 0
   end

   self:update_hud()

   self.no_scroll = false
end

function field_layer:update_hud()
   -- HACK due to global data
   self.hud.clock:set_data(self.data.date)

   self.hud:refresh(self.player)
   self.hud:update()
end

function field_layer:update(dt, ran_action, result)
   self.renderer:update(dt)
end

function field_layer:add_async_draw_callback(cb)
   self.renderer:add_async_draw_callback(cb)
end

function field_layer:draw()
   if self.renderer then
      self.renderer:draw()
   end

   self.hud:draw()
end

function field_layer:query_repl()
   if self.repl == nil then
      self:setup_repl()
   end
   self.repl:query()
   self.repl:save_history()
end

-- HACK: Needs to be replaced with resource system.
function field_layer:register_draw_layer(require_path)
   self.layers[#self.layers+1] = require_path
end

return field_layer:new()
