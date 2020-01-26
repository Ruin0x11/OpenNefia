--- @module Gui

local Env = require("api.Env")
local I18N = require("api.I18N")
local Log = require("api.Log")
local draw = require("internal.draw")
local Draw = require("api.Draw")
local field = require("game.field")
local ansicolors = require("thirdparty.ansicolors")

local Gui = {}

local scroll = false
local capitalize = true

--- Refreshes and scrolls the screen and recalculates FOV.
function Gui.update_screen()
   field:update_screen(scroll)
   scroll = false
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
function Gui.update_hud()
   field:update_hud()
end

--- Returns the screen coordinates of the tilemap renderer.
function Gui.field_draw_pos()
   return field.renderer:draw_pos()
end

--- Starts a draw callback to be run asynchronously.
function Gui.start_draw_callback(cb)
   field:add_async_draw_callback(cb)

   -- TODO: make configurable
   Gui.wait_for_draw_callbacks()
end

--- Waits for all draw callbacks to finish before continuing.
function Gui.wait_for_draw_callbacks()
   field:wait_for_draw_callbacks()
end

--- Waits for the specified number of milliseconds.
function Gui.wait(ms)
   local anim = function() Draw.yield(ms) end
   Gui.start_draw_callback(anim)
   Gui.wait_for_draw_callbacks()
end

--- Fades out the screen.
function Gui.fade_out()
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
         for _=1, 50 do
            Draw.filled_rect(0, 0, Draw.get_width(), Draw.get_height(), {0, 0, 0, 5})
         end

         love.graphics.setBlendMode("subtract")
         Draw.filled_rect(0, 0, Draw.get_width(), Draw.get_height(), {255, 255, 255, 10 + frame * 5})
         love.graphics.setBlendMode("alpha")
      end
   end

   Gui.start_draw_callback(anim)
   Gui.wait_for_draw_callbacks()
end

--- Converts from map tile space to screen space.
---
--- @tparam int tx Tile X coordinate
--- @tparam int ty Tile Y coordinate
function Gui.tile_to_screen(tx, ty)
   return draw.get_coords():tile_to_screen(tx+1, ty+1)
end

--- Returns the screen Y coordinate of the message window. Use for
--- checking occlusion of a point with the message window.
function Gui.message_window_y()
return Draw.get_width() - 72
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

--- Pauses rendering for the specified number of milliseconds.
---
--- @tparam int wait_ms
function Gui.wait(wait_ms)
   Gui.update_screen()
   Draw.wait(wait_ms)
end

local Color = {
   White =         { { 255, 255, 255 }, "white"          },
   Green =         { { 175, 255, 175 }, "green"          },
   Red =           { { 255, 155, 155 }, "red"            },
   Blue =          { { 175, 175, 255 }, "blue"           },
   Orange =        { { 255, 215, 175 }, "yellow"         },
   Yellow =        { { 255, 255, 175 }, "yellow"         },
   Grey =          { { 155, 154, 153 }, "white dim"      },
   Purple =        { { 185, 155, 215 }, "magenta"        },
   Cyan =          { { 155, 205, 205 }, "cyan"           },
   LightRed =      { { 255, 195, 185 }, "red bright"     },
   Gold =          { { 235, 215, 155 }, "yellow bright"  },
   LightBrown =    { { 225, 215, 185 }, "yellow dim"     },
   DarkGreen =     { { 105, 235, 105 }, "green dim"      },
   LightGrey =     { { 205, 205, 205 }, "white dim"      },
   PaleRed =       { { 255, 225, 225 }, "red dim"        },
   LightBlue =     { { 225, 225, 255 }, "blue bright"    },
   LightPurple =   { { 225, 195, 255 }, "magenta bright" },
   LightGreen =    { { 215, 255, 215 }, "green bright"   },
   YellowGreen =   { { 210, 250, 160 }, "yellow bright"  },
}

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
   local t = I18N.get_optional(text, ...) or text
   if t then text = t end

   if color == nil and string.find(text, I18N.quote_character()) then
      color = {210, 250, 160}
   end

   local dat
   if type(color) == "string" then
      dat = Color[color]
      if dat then
         color = dat[1]
      else
         color = {255, 255, 255}
      end
   end

   if capitalize then
      text = I18N.capitalize(text)
   end
   capitalize = true

   if Env.is_headless() then
      if Log.has_level("info") then
         color = dat and dat[2] or "white"
         local mes = ("<mes> %%{%s}%s%%{reset}"):format(color, text)
         print(ansicolors(mes))
      end
   else
      field:get_message_window():message(text, color)
   end
end

--- Prints a message in the HUD message if the provided position is
--- visible. This is checked using Map.is_in_fov.
---
--- @tparam i18n_id|string text
--- @tparam int x
--- @tparam int y
--- @param ...
--- @see Map.is_in_fov
function Gui.mes_visible(text, x, y, ...)
   Gui.mes_c_visible(text, x, y, nil, ...)
end

--- Prints a message in the HUD message if the provided position is
--- visible. This is checked using Map.is_in_fov.
---
--- @tparam i18n_id|string text
--- @tparam int x
--- @tparam int y
--- @tparam string|color color
--- @param ...
--- @see Map.is_in_fov
function Gui.mes_c_visible(text, x, y, color, ...)
   local Map = require("api.Map")
   if Map.is_in_fov(x, y) then
      Gui.mes_c(text, color, ...)
   end
end

--- Clears the HUD message window.
function Gui.mes_clear()
   field:get_message_window():clear()
end

--- Starts a new line in the HUD message window.
-- TODO: just use \n inline
function Gui.mes_newline()
   field:get_message_window():newline()
end

function Gui.mes_continue_sentence()
   capitalize = false
end

function Gui.mes_halt()
end

function Gui.mes_alert()
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
   local sound_manager = require("internal.global.sound_manager")
   local coords = draw.get_coords()

   if x ~= nil and y ~= nil then
      local sx, sy = coords:tile_to_screen(x, y)
      sound_manager:play(sound_id, sx, sy, channel)
   else
      sound_manager:play(sound_id, nil, nil, channel)
   end
end

--- Plays a sound looped in the background.
---
--- @tparam id:base.sound sound_id
--- @see Gui.stop_background_sound
function Gui.play_background_sound(sound_id)
   local sound_manager = require("internal.global.sound_manager")

   sound_manager:play_looping(sound_id)
end

--- Stops playing a sound that was started with
--- Gui.play_background_sound.
---
--- @tparam id:base.sound sound_id
--- @see Gui.play_background_sound
function Gui.stop_background_sound(sound_id)
   local sound_manager = require("internal.global.sound_manager")

   sound_manager:stop_looping(sound_id)
end

--- Plays music.
---
--- @tparam id:base.music music_id
function Gui.play_music(music_id)
   local sound_manager = require("internal.global.sound_manager")

   sound_manager:play_music(music_id)
end

--- Stops the currently playing music.
function Gui.stop_music()
   local sound_manager = require("internal.global.sound_manager")

   sound_manager:stop_music()
end

function Gui.bind_keys(keys)
   field:bind_keys(keys)
end

return Gui
