--- @module Gui

local Env = require("api.Env")
local I18N = require("api.I18N")
local Log = require("api.Log")
local draw = require("internal.draw")
local Draw = require("api.Draw")
local IMapObject = require("api.IMapObject")
local field = require("game.field")
local ansicolors = require("thirdparty.ansicolors")
local config = require("internal.config")
local Enum = require("api.Enum")
local Stopwatch = require("api.Stopwatch")

local Gui = {}

local scroll = false
local capitalize = true
local newline = true

--- Refreshes and scrolls the screen and recalculates FOV.
function Gui.update_screen(dt)
   local sw
   if Log.has_level("debug") then
      sw = Stopwatch:new()
   end

   field:update_screen(scroll, dt)
   scroll = false

   if sw then
      sw:p("screen update")
   end
end

--- Sets the center position that rendering will start from. Call this
--- function in the draw() method of a class implementing IUiLayer to
--- change where the camera will be positioned.
---
--- @tparam int x
--- @tparam int y
function Gui.set_camera_pos(x, y)
   field:set_camera_pos(x, y)
   scroll = false
end

--- Updates the HUD. Call this if you change anything that might need
--- to be reflected in the HUD, such as player equipment.
function Gui.refresh_hud()
   field:refresh_hud()
end

--- Returns the screen coordinates of the tilemap renderer.
function Gui.field_draw_pos()
   return field.renderer:draw_pos()
end

--- Starts a draw callback to be run asynchronously.
--- @tparam function cb
--- @tparam[opt] boolean async
--- @tparam[opt] string tag
function Gui.start_draw_callback(cb, async, tag)
   if Env.is_headless() then
      return
   end

   field:add_async_draw_callback(cb, tag)

   if not async then
      Gui.wait_for_draw_callbacks()
   end
end

--- Starts a draw callback to be run asynchronously, which will never block the
--- main thread if waited on. Use for things like weather animations that will
--- be continuously ran.
---
--- @tparam function cb
--- @tparam string tag
function Gui.start_background_draw_callback(cb, tag)
   assert(type(tag) == "string")

   if Env.is_headless() then
      return
   end

   field:add_async_draw_callback(cb, tag, "background")
end

--- Stops a tagged draw callback.
function Gui.stop_draw_callback(tag)
   field:remove_async_draw_callback(tag)
end

--- Waits for all draw callbacks to finish before continuing.
function Gui.wait_for_draw_callbacks()
   if Env.is_headless() then
      return
   end

   field:wait_for_draw_callbacks()
end

--- Waits for the specified number of milliseconds.
function Gui.wait(ms, no_update)
   local frames = ms / 16.66 -- TODO assumes 60 FPS
   local anim = function()
      local frame = 0
      while true do
         if not no_update then
            Gui.update_screen(16.66 / 1000)
         end
         if frame >= frames then
            return
         end
         local _, _, frame_delta = Draw.yield(16.66)
         frame = frame + frame_delta
      end
   end
   Gui.start_draw_callback(anim)
   Gui.wait_for_draw_callbacks()
end

function Gui.fade()
   local anim = function()
      local frame = 1
      while frame < 50 do
         local _, _, frames_passed = Draw.yield(20)
         frame = frame + frames_passed
         for _=1, frame do
            Draw.filled_rect(0, 0, Draw.get_width(), Draw.get_height(), {0, 0, 0, 5})
         end
      end

      frame = 1
      while frame < 30 do
         local _, _, frames_passed = Draw.yield(20)
         frame = frame + frames_passed
         for _=1, 20 do
            Draw.filled_rect(0, 0, Draw.get_width(), Draw.get_height(), {0, 0, 0, 5})
         end

         Draw.set_blend_mode("subtract")
         Draw.filled_rect(0, 0, Draw.get_width(), Draw.get_height(), {255, 255, 255, 10 + frame * 5})
         Draw.set_blend_mode("alpha")
      end
   end

   draw.add_global_draw_callback(anim)
   draw.wait_global_draw_callbacks()
end

function Gui.fade_out(length)
   length = length or 60
   local anim = function()
      local frame = 1
      while frame < length do
         local _, _, frames_passed = Draw.yield(20)
         Draw.set_blend_mode("subtract")
         for _ = 1, frames_passed do
            Draw.filled_rect(0, 0, Draw.get_width(), Draw.get_height(), {255, 255, 255, 10 + frame * 5})
            frame = frame + 1
         end
         Draw.set_blend_mode("alpha")
      end
   end

   draw.add_global_draw_callback(anim)
   draw.wait_global_draw_callbacks()
end

--- Converts from map tile space to screen space.
---
--- @tparam int tx Tile X coordinate
--- @tparam int ty Tile Y coordinate
function Gui.tile_to_screen(tx, ty)
   return draw.get_coords():tile_to_screen(tx+1, ty+1)
end

--- Converts from screen space to map tile space.
---
--- @tparam int sx Screen X coordinate
--- @tparam int sy Screen Y coordinate
function Gui.screen_to_tile(sx, sy)
   return draw.get_coords():screen_to_tile(sx, sy)
end

--- Converts from map tile space to visible screen space.
---
--- @tparam int tx Tile X coordinate
--- @tparam int ty Tile Y coordinate
function Gui.tile_to_visible_screen(tx, ty)
  local x, y = Gui.tile_to_screen(tx, ty)
  local draw_x, draw_y = Gui.field_draw_pos()
  local sx, sy = Draw.get_coords():get_start_offset(draw_x, draw_y)
  return x - draw_x + sx, y - draw_y + sy
end

--- Converts from visible screen space to map tile space.
---
--- @tparam int tx Tile X coordinate
--- @tparam int ty Tile Y coordinate
function Gui.visible_screen_to_tile(sx, sy)
   if not field.is_active or not field.renderer then
      return nil, nil
   end

  local draw_x, draw_y = Gui.field_draw_pos()
  local start_x, start_y = Draw.get_coords():get_start_offset(draw_x, draw_y)
   return draw.get_coords():screen_to_tile(sx + draw_x + start_x, sy + draw_y + start_y)
end

--- Returns the bounds of the visible tile positions on-screen.
---
--- @tparam uint x
--- @tparam uint y
--- @tparam uint width
--- @tparam uint height
--- @treturn uint tx upper-left x
--- @treturn uint ty upper-left y
--- @treturn uint tdx lower-right x
--- @treturn uint tdy lower-right y
function Gui.visible_tile_bounds(x, y, width, height)
   if not (x and y) and field.renderer then
      x = field.renderer.draw_x
      y = field.renderer.draw_y
   end
   width = width or Draw.get_width()
   height = height or Draw.get_height()

   return Draw.get_coords():find_bounds(x, y, width, height)
end

--- Returns the screen Y coordinate of the message window. Use for
--- checking occlusion of a point with the message window.
function Gui.message_window_y()
   return Draw.get_height() - 72
end

function Gui.scroll_screen()
   --field:update_screen(true)
end

function Gui.set_scroll()
   -- scroll = true
end

function Gui.key_held_frames()
   return field:key_held_frames()
end

--- Returns true if the player is running by holding Shift.
function Gui.player_is_running()
   return field:player_is_running()
end

--- @tparam string err
--- @tparam string msg
function Gui.report_error(err, msg)
   msg = msg or "Error"
   Gui.mes_newline()
   Gui.mes_c(string.format("%s: %s", msg, string.split(err)[1]), "Red")
   Log.error("%s:\n\t%s", msg, err)
end

-- >>>>>>>> shade2/init.hsp:4568 	dim c_col,3,30 ..
local TERMINAL_COLORS = {
   White       = "white",
   Green       = "green",
   Red         = "red",
   Blue        = "blue",
   Yellow      = "yellow",
   Brown       = "yellow",
   Black       = "white dim",
   Purple      = "magenta",
   SkyBlue     = "cyan",
   Pink        = "red bright",
   Orange      = "yellow bright",
   Fresh       = "yellow dim",
   DarkGreen   = "green dim",
   Gray        = "white dim",
   LightRed    = "red dim",
   LightBlue   = "blue bright",
   LightPurple = "magenta bright",
   LightGreen  = "green bright",
   Talk        = "yellow bright",
}
-- <<<<<<<< shade2/init.hsp:4588 		c_col(0,coTalk)		=45,5,95 ..

--- Prints a localized message in the HUD message window. You can pass
--- in an I18N ID with arguments and it will be localized, or any
--- arbitrary string.
---
--- @tparam i18n_id|string text
--- @tparam ... ...
function Gui.mes(text, ...)
   Gui.mes_c(text, nil, ...)
end

--- Prints a localized message in the HUD message window with color.
--- You can pass in an I18N ID with arguments and it will be
--- localized, or any arbitrary string.
---
--- @tparam i18n_id|string text
--- @tparam string|color color
--- @param ...
function Gui.mes_c(text, color, ...)
   local t = I18N.get_optional(text, ...) or text or tostring(text)
   if t then text = t end

   if color == nil and string.find(text, I18N.quote_character()) then
      color = {210, 250, 160}
   end

   local color_tbl
   if type(color) == "string" then
      color_tbl = Enum.Color:try_get(color)
      if not color_tbl then
         Log.error("Unknown message color '%s'", color)
         color_tbl = {255, 255, 255}
      end
   end

   if capitalize then
      text = I18N.capitalize(text)
   end
   if not newline then
      text = I18N.space() .. text
   end
   capitalize = true
   newline = false

   if Env.is_headless() then
      if Log.has_level("info") then
         color = TERMINAL_COLORS[color] or "white"
         local mes = ("<mes> %%{%s}%s%%{reset}"):format(color, text)
         print(ansicolors(mes))
      end
   else
      if field.is_active then
         field:get_message_window():message(text, color_tbl)
      end
   end
end

--- Prints a message in the HUD message if the provided position is
--- visible.
---
--- This function can either be called like
---
---    Gui.mes_visible("mod.my_text", x, y, arg1, arg2, ...)
---
--- or like
---
---    Gui.mes_visible("mod.my_text", chara, arg1, arg2, ...)
---
--- where `chara` implements IMapObject. If this is so, then `chara` will be
--- passed automatically as the first argument to the localization system, and
--- arg1 will actually become the second argument. This is to save yourself from
--- having to type out
---
---    Gui.mes_visible("mod.my_text", chara.x, chara.y, chara, arg1, arg2, ...)
---
--- or
---
---    if chara:is_in_fov() then
---       Gui.mes("mod.my_text", chara, arg1, arg2, ...)
---    end
---
--- since the above is a rather common pattern in vanilla Elona's codebase.
---
--- @tparam i18n_id|string text
--- @tparam int|IMapObject x
--- @tparam int|nil y
--- @param ...
function Gui.mes_visible(text, x, y, ...)
   if class.is_an(IMapObject, x) then
      Gui.mes_c_visible(text, x, nil, nil, y, ...)
   else
      Gui.mes_c_visible(text, x, y,   nil, ...)
   end
end

--- Prints a message in the HUD message if the provided position is
--- visible. See `Gui.mes_visible()` for details about the arguments.
---
--- @tparam i18n_id|string text
--- @tparam int|IMapObject x
--- @tparam int|string|color y
--- @tparam string|color color
--- @param ...
--- @see Gui.mes_visible
function Gui.mes_c_visible(text, x, y, color, ...)
   if class.is_an(IMapObject, x) then
      local obj = x
      if obj:is_in_fov() then
         color = y
         -- TODO do not implictly pass obj
         Gui.mes_c(text, color, obj, ...)
      end
   else
      local Map = require("api.Map")
      if Map.is_in_fov(x, y) then
         Gui.mes_c(text, color, ...)
      end
   end
end

--- Clears the HUD message window.
function Gui.mes_clear()
   field:get_message_window():clear()
   capitalize = true
   newline = true
end

--- Starts a new line in the HUD message window.
-- TODO: just use \n inline
function Gui.mes_newline()
   field:get_message_window():do_newline()
   newline = true
end

function Gui.mes_continue_sentence()
   capitalize = false
end

function Gui.mes_duplicate()
   -- TODO
end

function Gui.mes_halt()
   -- TODO
end

function Gui.mes_alert()
   -- TODO
end

--- Plays a sound. You can optionally provide a position, so that if
--- positional audio is enabled in the settings then it will be panned
--- according to the relative position of the player.
---
--- @tparam id:base.sound sound_id
--- @tparam[opt] int x
--- @tparam[opt] int y
--- @tparam[opt] int channel
function Gui.play_sound(sound_id, x, y, channel)
   local sound_manager = require("internal.global.global_sound_manager")
   local coords = draw.get_coords()

   if config.base.positional_audio and x ~= nil and y ~= nil then
      local sx, sy = coords:tile_to_screen(x, y)
      sound_manager:play(sound_id, sx, sy, channel)
   else
      sound_manager:play(sound_id, nil, nil, channel)
   end
end

--- Plays a sound looped in the background.
---
--- @tparam string tag
--- @tparam id:base.sound sound_id
--- @see Gui.stop_background_sound
function Gui.play_background_sound(sound_id, tag)
   local sound_manager = require("internal.global.global_sound_manager")

   sound_manager:play_looping(tag, sound_id, "sound")
end

--- Stops playing a sound that was started with
--- Gui.play_background_sound.
---
--- Pass 'nil' to stop all background sounds.
---
--- @tparam string tag
--- @see Gui.play_background_sound
function Gui.stop_background_sound(tag)
   local sound_manager = require("internal.global.global_sound_manager")

   sound_manager:stop_looping(tag)
end

--- Plays music.
---
--- @tparam id:base.music music_id
function Gui.play_music(music_id, no_loop)
   local sound_manager = require("internal.global.global_sound_manager")

   if not config.base.music then
      sound_manager:stop_music()
      return
   end

   sound_manager:play_music(music_id)
end

--- Stops the currently playing music.
function Gui.stop_music()
   local sound_manager = require("internal.global.global_sound_manager")

   sound_manager:stop_music()
end

function Gui.bind_keys(keys)
   field:bind_keys(keys)
end

function Gui.field_is_active()
   return field.is_active
end

function Gui.add_hud_widget(widget, tag, opts)
   field.hud.widgets:add(widget, tag, opts)
end

function Gui.remove_hud_widget(tag)
   field.hud.widgets:remove(tag)
end

function Gui.hud_widget(tag)
   return field.hud.widgets:get(tag)
end

function Gui.add_global_widget(widget, tag, opts)
   draw.add_global_widget(widget, tag, opts)
end

function Gui.remove_global_widget(tag)
   draw.remove_global_widget(tag)
end

function Gui.global_widget(tag)
   return draw.global_widget(tag)
end

function Gui.run_keybind_action(action, ...)
   return field:run_keybind_action(action, true, ...)
end

function Gui.update_minimap(map)
   Gui.hud_widget("hud_minimap"):widget():refresh_visible(map)
end

function Gui.render_tilemap_to_image()
   local map = field.map
   if not (field.is_active and map) then
      return
   end

   local tw, th = Draw.get_coords():get_size()

   local cw = map:width() * tw
   local ch = map:height() * th

   local canvas = love.graphics.newCanvas(cw, ch)

   local function draw_to_canvas()
      -- HACK
      local draw_x_back = field.renderer.draw_x
      local draw_y_back = field.renderer.draw_y

      field.renderer:set_draw_pos(0, 0)
      field.renderer:draw(0, 0, cw, ch) -- TODO draw layers to specified width
      field.renderer:set_draw_pos(draw_x_back, draw_y_back)
   end

   Draw.with_canvas(canvas, draw_to_canvas)

   local image_data = canvas:newImageData()
   canvas:release()

   return image_data
end

return Gui
