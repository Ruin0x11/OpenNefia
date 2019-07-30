local InputHandler = require("api.gui.InputHandler")
local IUiLayer = require("api.gui.IUiLayer")
local Event = require("api.Event")
local DateTime = require("api.DateTime")
local IInput = require("api.gui.IInput")
local KeyHandler = require("api.gui.KeyHandler")
local Log = require("api.Log")

local area_mapping = require("internal.area_mapping")
local env = require("internal.env")
local field_renderer = require("internal.field_renderer")
local uid_tracker = require("internal.uid_tracker")
local fs = require("util.fs")
local save = require("internal.global.save")

local field_layer = class.class("field_layer", IUiLayer)

field_layer:delegate("keys", IInput)

function field_layer:init()
   self.is_active = false

   self.hud = require("api.gui.hud.MainHud"):new()

   self.map = nil
   self.renderer = nil
   self.repl = nil

   self.map_changed = false
   self.no_scroll = true

   local keys = KeyHandler:new(true)
   self.keys = InputHandler:new(keys)
   self.keys:focus()

   self.layers = {
      "internal.layer.tile_layer",
      "internal.layer.feat_layer",
      "internal.layer.item_layer",
      "internal.layer.chara_layer",
      "internal.layer.shadow_layer",
   }
end

function field_layer:setup_repl()
   -- avoid circular requires that depend on internal.field, since
   -- this auto-requires the full public API.
   local ReplLayer = require("api.gui.menu.ReplLayer")

   local repl_env = env.generate_sandbox("repl")
   local apis = env.require_all_apis("api", true)
   repl_env = table.merge(repl_env, apis)

   -- WARNING: for development only.
   if _DEBUG then
      repl_env = table.merge(repl_env, _G)
      repl_env = table.merge(repl_env, env.require_all_apis("internal"))
      repl_env = table.merge(repl_env, env.require_all_apis("game"))
      repl_env["save"] = save
   end

   -- HACK: remove
   local history = {}
   local file = io.open("repl_history.txt", "r")
   if file ~= nil then
      for line in file:lines() do
         history[#history + 1] = line
      end
   end

   if fs.exists("repl_startup.lua") then
      local chunk = loadfile("repl_startup.lua")
      setfenv(chunk, repl_env)
      chunk()
      print("OK")
   end

   self.repl = ReplLayer:new(repl_env, history)
end

function field_layer:init_global_data()
   local s = save.base
   s.date = DateTime:new(517, 8, 12, 16, 10, 0)
   s.play_turns = 0
   s.play_days = 0
   s.area_mapping = area_mapping:new()
   s.player = nil
   s.allies = {}
   s.uids = uid_tracker:new()
   s.map_uids = uid_tracker:new()

   Event.trigger("base.on_init_save")
end

function field_layer:set_map(map)
   assert(type(map) == "table")
   assert(map.uid, "Map must have UID")

   if save.base.area_mapping:maybe_generate_area_for_map(map.uid) then
      Log.warn("Generating new area for map %d", map.uid)
   end

   self.map = map
   self.map._tiles_dirty = true
   self.renderer = field_renderer:new(map:width(), map:height(), self.layers)
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

   local player = self.map:get_object(self.player)
   local scroll_frames
   if player then
      if scroll then
         scroll_frames = player:calc("scroll") or 3
      end

      self.renderer:update_draw_pos(player.x, player.y, scroll_frames)
      self.map:calc_screen_sight(player.x, player.y, player:calc("fov") or 15)
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

function field_layer:key_held_frames()
   return self.keys:key_held_frames()
end

function field_layer:player_is_running()
   -- HACK
   return self.keys.keys.pressed["shift"]
end

function field_layer:update_hud()
   -- HACK due to global data
   self.hud.clock:set_data(save.base.date)

   local player = self.map:get_object(self.player)
   self.hud:refresh(player)
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
   if env.is_hotloading() then
      Log.warn("Skipping draw layer register of '%s'", require_path)
      return
   end
   self.layers[#self.layers+1] = require_path
end

return field_layer
