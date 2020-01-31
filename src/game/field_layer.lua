local InputHandler = require("api.gui.InputHandler")
local IUiLayer = require("api.gui.IUiLayer")
local Event = require("api.Event")
local IInput = require("api.gui.IInput")
local KeyHandler = require("api.gui.KeyHandler")
local Log = require("api.Log")
local Env = require("api.Env")

local env = require("internal.env")
local field_renderer = require("internal.field_renderer")
local save = require("internal.global.save")

local field_layer = class.class("field_layer", IUiLayer)

field_layer:delegate("keys", IInput)

function field_layer:init()
   self.is_active = false

   self.hud = require("api.gui.hud.MainHud"):new()

   self.map = nil
   self.renderer = nil
   self.repl = nil

   self.loaded = false
   self.map_changed = false
   self.no_scroll = true
   self.waiting_for_draw_callbacks = false
   self.sound_manager = require("internal.global.sound_manager")

   local keys = KeyHandler:new(true)
   self.keys = InputHandler:new(keys)
   self.keys:focus()

   self.layers = {
      "internal.layer.tile_layer",
      "internal.layer.chip_layer",
      "internal.layer.tile_overhang_layer",
      "internal.layer.shadow_layer",
   }
end

function field_layer:make_keymap()
   return {}
end

function field_layer:setup_repl()
   -- avoid circular requires that depend on internal.field, since
   -- `Repl.generate_env()` auto-requires the full public API.
   local Repl = require("api.Repl")
   local ReplLayer = require("api.gui.menu.ReplLayer")

   local repl_env, history = Repl.generate_env()

   self.repl = ReplLayer:new(repl_env, { history = history })
end

function field_layer:init_global_data()
   self.player = nil

   Event.trigger("base.on_init_save")
end

function field_layer:set_map(map)
   assert(type(map) == "table")
   assert(map.uid, "Map must have UID")

   self.map = map
   self.map:redraw_all_tiles()
   if self.renderer == nil then
      self.renderer = field_renderer:new(map:width(), map:height(), self.layers)
   else
      self.renderer:set_map(map, self.layers)
   end
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

function field_layer:set_camera_pos(x, y)
   self.camera_x = x
   self.camera_y = y
   self.renderer:update_draw_pos(x, y, 0)
   self.renderer:update(0)
   self:update_hud()
end

function field_layer:update_screen(scroll, dt)
   if not self.is_active or not self.renderer then return end
   local sw = require("api.Stopwatch"):new()

   if scroll == nil or self.no_scroll then
      scroll = false
   end

   assert(self.map ~= nil)

   local player = self.player
   local scroll_frames = 0
   if scroll then
      scroll_frames = 3
   end

   local center_x = self.camera_x or nil
   local center_y = self.camera_y or nil
   self.camera_x = nil
   self.camera_y = nil

   if center_x == nil and player then
      center_x = player.x
      center_y = player.y
      if scroll then
         scroll_frames = player:calc("scroll") or scroll_frames
      end
   end


   if center_x then
      self.renderer:update_draw_pos(center_x, center_y, scroll_frames)
   end

   if player then
      self.map:calc_screen_sight(player.x, player.y, player:calc("fov") or 15)
   end

   local dt = dt or 0

   if not Env.is_headless() then
      local going = true
      while going do
         self.keys:update_repeats(dt)
         going = self.renderer:update(dt)
         dt = coroutine.yield() or 0
      end

      self:update_hud()
   end

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

   local player = self.player
   self.hud:refresh(player)
   self.hud:update()
end


function field_layer:get_message_window()
   return self.hud:find_widget("api.gui.hud.UiMessageWindow")
end

function field_layer:update(dt, ran_action, result)
   self.renderer:update(dt)
   self.sound_manager:update(dt)
end

function field_layer:add_async_draw_callback(cb, tag)
   self.renderer:add_async_draw_callback(cb, tag)
end

function field_layer:remove_async_draw_callback(tag)
   self.renderer:remove_async_draw_callback(tag)
end

function field_layer:wait_for_draw_callbacks()
   self.waiting_for_draw_callbacks = true
end

function field_layer:update_draw_callbacks(dt)
   local has_cbs = self.renderer:update_draw_callbacks(dt)
   if has_cbs and self.waiting_for_draw_callbacks then
      return true
   end

   self.waiting_for_draw_callbacks = false
   return false
end

function field_layer:draw()
   if self.renderer then
      self.renderer:draw()
   end
end

function field_layer:query_repl()
   if self.repl == nil then
      self:setup_repl()
   end

   -- The repl could get hotloaded, so keep it in an upvalue.
   local repl = self.repl
   repl:query(100000000) -- draw on top of everything

   if repl then
      repl:save_history()
   end
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
