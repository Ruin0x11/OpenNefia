local InputHandler = require("api.gui.InputHandler")
local IUiLayer = require("api.gui.IUiLayer")
local Event = require("api.Event")
local IInput = require("api.gui.IInput")
local KeyHandler = require("api.gui.KeyHandler")
local Env = require("api.Env")
local DrawLayerSpec = require("api.draw.DrawLayerSpec")
local MapRenderer = require("api.gui.MapRenderer")
local Stopwatch = require("api.Stopwatch")

local config = require("internal.config")
local draw = require("internal.draw")
local draw_callbacks = require("internal.draw_callbacks")

local field_layer = class.class("field_layer", IUiLayer)

field_layer:delegate("keys", IInput)

function field_layer:init()
   self.is_active = false

   self.hud = require("api.gui.hud.MainHud"):new()

   self.map = nil
   self.renderer = nil
   self.repl = nil

   self.camera_x = nil
   self.camera_y = nil
   self.camera_dx = 0
   self.camera_dy = 0

   self.scrolling_mode = "none"
   self.scroll_last_px = 0
   self.scroll_last_py = 0
   self.scrolling_objs = {}
   self.no_scroll_this_update = false

   self.view_centered = false

   self.loaded = false
   self.map_changed = false
   self.waiting_for_draw_callbacks = false
   self.sound_manager = require("internal.global.global_sound_manager")
   self.draw_callbacks = draw_callbacks:new()

   local keys = KeyHandler:new(true)
   self.keys = InputHandler:new(keys)
   self.keys:focus()
   -- TODO: Maybe we should rethink allowing "alt" as a part of movement
   -- keybinds
   self.keys:ignore_modifiers { "alt" }

   self.draw_layer_spec = DrawLayerSpec:new()

   self:register_draw_layer("tile_layer", "internal.layer.tile_layer")
   self:register_draw_layer("debris_layer", "internal.layer.debris_layer")
   self:register_draw_layer("effect_map_layer", "internal.layer.effect_map_layer")
   self:register_draw_layer("chip_layer", "internal.layer.chip_layer")
   self:register_draw_layer("tile_overhang_layer", "internal.layer.tile_overhang_layer")
   self:register_draw_layer("emotion_icon_layer", "internal.layer.emotion_icon_layer")
   self:register_draw_layer("shadow_layer", "internal.layer.shadow_layer")
end

function field_layer:default_z_order()
   return 10000
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

   self.repl = ReplLayer:new(repl_env, { history = history, history_file = "data/repl_history" })
   self.repl:relayout()
end

function field_layer:init_global_data()
   self.player = nil
   self.map = nil

   Event.trigger("base.on_init_save")
end

function field_layer:get_renderer_y_offset()
   local y_offset = -(72 + 16)
   if self.view_centered then
      y_offset = 0
   end
   return y_offset
end

function field_layer:set_map(map)
   assert(type(map) == "table")
   assert(map.uid, "Map must have UID")

   self.map = map
   self.map:redraw_all_tiles()
   if self.renderer == nil then
      self.renderer = MapRenderer:new(map, self.draw_layer_spec)
   else
      self.renderer:set_map(map)
   end
   if self.x then
      self:relayout(self.x, self.y, self.width, self.height)
   end

   self.scrolling_mode = "none"
   if self.player then
      self.scroll_last_px = self.player.x
      self.scroll_last_py = self.player.y
   end

   self.map_changed = true
end

function field_layer:relayout(x, y, width, height)
   self.x = x or self.x
   self.y = y or self.y
   self.width = width or self.width
   self.height = height or self.height
   if self.renderer then
      self.renderer:relayout(self.x, self.y, self.width, self.height)
      self.renderer:relayout_inner(self.x, self.y, self.width, self.height + self:get_renderer_y_offset())
   end
end

function field_layer:on_theme_switched()
   -- Make sure that we redraw all tiles regardless of the FOV of the player. If
   -- we don't do this those tiles will get cleared from the theme switch, but
   -- not redrawn, so they will become black squares.
   if self.map then
      self.map:redraw_all_tiles()
   end

   if self.renderer then
      self.renderer:on_theme_switched()
   end
end

function field_layer:turn_cost()
   return self.map.turn_cost
end

function field_layer:get_object(_type, uid)
   return self.map and self.map:get_object_of_type(_type, uid)
end

function field_layer:set_view_centered(centered)
   self.view_centered = centered
   self:relayout()
end

function field_layer:update_draw_pos()
   local player = self.player
   local center_x = self.camera_x or nil
   local center_y = self.camera_y or nil

   if center_x == nil and player then
      local coords = draw.get_coords()
      center_x, center_y = coords:tile_to_screen(player.x, player.y)
   end

   if center_x then
      local sx = center_x + self.camera_dx
      local sy = center_y + self.camera_dy
      self.renderer:update_draw_pos(sx, sy)
      self.sound_manager:set_listener_pos(sx, sy)
   end
end

function field_layer:set_camera_pos(sx, sy)
   if sx and sy then
      self.camera_x = sx
      self.camera_y = sy
   else
      self.camera_x = nil
      self.camera_y = nil
   end
   self:update_draw_pos()
   self.renderer:update(0)
   self:refresh_hud()
end

function field_layer:set_camera_offset(sdx, sdy)
   self.camera_dx = sdx or 0
   self.camera_dy = sdy or 0
   self:update_draw_pos()
   self.renderer:update(0)
   self:refresh_hud()
end

local function msecs_to_frames(msecs, framerate)
   framerate = framerate or 60
   local msecs_per_frame = (1 / framerate) * 1000
   local frames = msecs / msecs_per_frame
   return frames
end

local function can_scroll_object(obj)
   local scroll = config.base.scroll

   if scroll == "all" then
      return true
   elseif scroll == "player" then
      return obj:is_player()
   end

   return false
end

function field_layer:update_scrolling()
   if self.player == nil
      or config.base.scroll == "none"
      or Env.is_headless()
      or (self:player_is_running() and not config.base.scroll_when_run)
      or self.no_scroll_this_update
   then
      self.scrolling_mode = "none"
      self.scroll_last_px = self.player.x
      self.scroll_last_py = self.player.y
      self.scrolling_objs = {}
      return
   end

   local objs_in_sight = {}
   for _, obj in self.map:iter() do
      if obj:is_in_fov() then
         objs_in_sight[obj.uid] = obj
      end
   end

   local coords = draw.get_coords()
   local tw, th = coords:get_size()
   local px, py = coords:tile_to_screen(self.player.x, self.player.y)

   local layer = self.renderer:get_draw_layer("base.chip_layer")

   local obj_scroll_offsets = {}

   for uid, pos in pairs(self.scrolling_objs) do
      local obj = objs_in_sight[uid]
      if obj then
         if can_scroll_object(obj) then
            -- The chip layer has not been updated at this point, so the old index ->
            -- UID mapping from the previous screen update is still there. It will be
            -- rebuilt when self.renderer:update() is called. So the chip index
            -- returned below might also be removed after the scrolling is finished.
            local index = layer.uid_to_index[uid]
            if index then
               local odx = (pos.prev_x - obj.x) * tw
               local ody = (pos.prev_y - obj.y) * th
               if odx ~= 0 or ody ~= 0 then
                  table.insert(obj_scroll_offsets, {
                                  index = index,
                                  dx = odx,
                                  dy = ody
                  })
               end
            end
         end
      end
   end

   if #obj_scroll_offsets > 0 then
      local dx = self.scroll_last_px - self.player.x
      local dy = self.scroll_last_py - self.player.y

      local tdx = tw * math.sign(dx)
      local tdy = th * math.sign(dy)

      local draw_x, draw_y = draw.get_coords():get_draw_pos(px + tdx,
                                                            py + tdy,
                                                            self.map:width(),
                                                            self.map:height(),
                                                            self.renderer.renderer.width,
                                                            self.renderer.renderer.height)

      if config.base.scroll_type == "classic" then
         -- >>>>>>>> elona122/shade2/screen.hsp:1224 *screen_scroll ...
         local frames = 5
         if self.scrolling_mode == "fast" then
            frames = 3
         elseif self.scrolling_mode == "slow" then
            frames = 6
         end
         if self:player_is_running() then
            frames = 1
         end

         for i = 0, frames-1 do
            local scroll_x = dx * i * tw / frames
            local scroll_y = dy * i * th / frames

            local sx, sy = draw.get_coords():get_draw_pos(px - scroll_x + tdx,
                                                          py - scroll_y + tdy,
                                                          self.map:width(),
                                                          self.map:height(),
                                                          self.renderer.renderer.width,
                                                          self.renderer.renderer.height)

            for _, offset in ipairs(obj_scroll_offsets) do
               local obj_scroll_x = i * offset.dx / frames
               local obj_scroll_y = i * offset.dy / frames
               layer:scroll_chip(offset.index, obj_scroll_x, obj_scroll_y)
            end

            self.renderer.x = -(draw_x - sx)
            self.renderer.y = -(draw_y - sy)

            local ms = 0
            repeat
               local dt, _, _ = coroutine.yield()
               self.renderer:update(dt)
               self.draw_callbacks:update(dt)
               self.keys:update_repeats(dt)
               ms = ms + dt
            until ms > 33.0 / 1000.0
         end
         -- <<<<<<<< elona122/shade2/screen.hsp:1267 	return ..
      else
         local frames = 3
         if self.scrolling_mode == "fast" then
            frames = 2
         elseif self.scrolling_mode == "slow" then
            frames = 3.5
         end
         if self:player_is_running() then
            frames = 1
         end

         -- TODO assumes 60 FPS
         local ms = msecs_to_frames(frames, 60)
         local i = 0

         repeat
            local scroll_x = i * (dx / ms) * tw
            local scroll_y = i * (dy / ms) * th
            local sx, sy = draw.get_coords():get_draw_pos(px - scroll_x + tdx,
                                                          py - scroll_y + tdy,
                                                          self.map:width(),
                                                          self.map:height(),
                                                          self.renderer.renderer.width,
                                                          self.renderer.renderer.height)

            for _, offset in ipairs(obj_scroll_offsets) do
               local obj_scroll_x = i * (offset.dx / ms)
               local obj_scroll_y = i * (offset.dy / ms)
               layer:scroll_chip(offset.index, obj_scroll_x, obj_scroll_y)
            end

            self.renderer.x = -(draw_x - sx)
            self.renderer.y = -(draw_y - sy)

            local dt, _, _ = coroutine.yield()
            self.renderer:update(dt)
            self.draw_callbacks:update(dt)
            self.keys:update_repeats(dt)
            i = i + dt
         until i >= ms
      end
   else
      self.scrolling_mode = "none"
   end

   self.renderer.x = self.x
   self.renderer.y = self.y
   self.scroll_last_px = self.player.x
   self.scroll_last_py = self.player.y
   self.scrolling_mode = "none"
   self.scrolling_objs = {}
end

function field_layer:update_screen(dt, and_draw)
   if not self.is_active or not self.renderer then return end

   assert(self.map ~= nil)

   local player = self.player

   if player then
      self.map:calc_screen_sight(player.x, player.y, player:calc("fov") or 15)
   end

   self:update_scrolling()
   self:update_draw_pos()

   local dt = dt or 0

   if not Env.is_headless() then
      local going = true
      while going do
         self.keys:update_repeats(dt)
         going = self.renderer:update(dt)
         if and_draw then
            dt = coroutine.yield() or 0
         end
      end

      self:refresh_hud()
   end
end

function field_layer:key_held_frames()
   return self.keys:key_held_frames()
end

function field_layer:player_is_running()
   -- HACK
   return self.keys.keys.pressed["shift"]
end

function field_layer:refresh_hud(relayout)
   local player = self.player
   self.hud:refresh(player)
   if relayout then
      self.hud:relayout()
   end
end

function field_layer:update(dt, ran_action, result)
   self.renderer:update(dt)

   -- HACK the hud also gets tracked by the draw layer system, but since the hud
   -- will never technically get updated by the draw layer system since it's
   -- never focused for input, we update it manually in the field layer. This
   -- will have to change if the hud wants to grab input for some potential new
   -- modding feature.
   self.hud:update(dt)

   self.draw_callbacks:update(dt)
   self.sound_manager:update(dt)
end

function field_layer:add_async_draw_callback(cb, tag, kind, z_order)
   self.draw_callbacks:add(cb, tag, kind, z_order)
end

function field_layer:remove_async_draw_callback(tag)
   self.draw_callbacks:remove(tag)
end

function field_layer:remove_all_async_draw_callbacks()
   self.draw_callbacks:remove_all()
end

function field_layer:wait_for_draw_callbacks()
   self.draw_callbacks:wait()
end

function field_layer:has_draw_callbacks(include_bg_cbs)
   return self.draw_callbacks:has_more(include_bg_cbs)
end

function field_layer:update_draw_callbacks(dt)
   return self.draw_callbacks:update(dt)
end

function field_layer:draw()
   if not self.is_active or not self.renderer then
      return
   end

   self.renderer:draw()

   local draw_x, draw_y = self.renderer:get_draw_pos()
   self.draw_callbacks:draw(draw_x, draw_y)
end

function field_layer:query_repl()
   if self.repl == nil then
      self:setup_repl()
   end

   if draw.is_layer_active(self.repl) then
      return
   end

   -- The repl could get hotloaded, so keep it in an upvalue.
   local repl = self.repl
   repl:query()

   if repl then
      repl:save_history()
   end
end

function field_layer:register_draw_layer(tag, require_path, z_order, enabled)
   return self.draw_layer_spec:register_draw_layer(tag, require_path, z_order, enabled)
end

function field_layer:get_draw_layer(tag)
   if self.renderer == nil then
      return nil
   end

   return self.renderer:get_draw_layer(tag)
end

function field_layer:set_draw_layer_enabled(tag, enabled)
   self.draw_layer_spec:set_draw_layer_enabled(tag, enabled)

   if self.renderer then
      return self.renderer:set_draw_layer_enabled(tag, enabled)
   end
end

return field_layer
