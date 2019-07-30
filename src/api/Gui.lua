local Env = require("api.Env")
local I18N = require("api.I18N")
local Log = require("api.Log")
local draw = require("internal.draw")
local field = require("game.field")

local Gui = {}

local scroll = false

function Gui.update_screen()
   field:update_screen(scroll)
   scroll = false
end

function Gui.update_hud()
   field:update_hud()
end

function Gui.field_draw_pos()
   return field.renderer:draw_pos()
end

function Gui.tile_to_screen(tx, ty)
   local x, y = draw.get_coords():tile_to_screen(tx + 1, ty + 1)
   local tile_width, tile_height = draw.get_coords():get_size()
   x = x + tile_width / 2
   y = y + tile_height / 2
   return x, y
end

function Gui.scroll_screen()
   field:update_screen(true)
end

function Gui.set_scroll()
   scroll = true
end

function Gui.key_held_frames()
   return field:key_held_frames()
end

function Gui.player_is_running()
   return field:player_is_running()
end

function Gui.report_error(err, msg)
   msg = msg or "Error"
   Gui.mes(string.format("%s: %s", msg, string.split(err)[1]), "Red")
   Log.error("%s:\n\t%s", msg, err)
end

function Gui.wait(wait)
   Gui.update_screen()
   draw.wait(wait)
end

local function get_message_window()
   return field.hud:find_widget("api.gui.hud.UiMessageWindow")
end

local Color = {
   White =         { 255, 255, 255 },
   Green =         { 175, 255, 175 },
   Red =           { 255, 155, 155 },
   Blue =          { 175, 175, 255 },
   Orange =        { 255, 215, 175 },
   Yellow =        { 255, 255, 175 },
   Grey =          { 155, 154, 153 },
   Purple =        { 185, 155, 215 },
   Cyan =          { 155, 205, 205 },
   LightRed =      { 255, 195, 185 },
   Gold =          { 235, 215, 155 },
   LightBrown =    { 225, 215, 185 },
   DarkGreen =     { 105, 235, 105 },
   LightGrey =     { 205, 205, 205 },
   PaleRed =       { 255, 225, 225 },
   LightBlue =     { 225, 225, 255 },
   LightPurple =   { 225, 195, 255 },
   LightGreen =    { 215, 255, 215 },
   YellowGreen =   { 210, 250, 160 },
}

-- TODO: inline colors
function Gui.mes(text, color)
   if color == nil and string.find(text, I18N.quote_character()) then
      color = {210, 250, 160}
   end
   if type(color) == "string" then
      color = Color[color] or {255, 255, 255}
   end
   get_message_window():message(text, color)

   if Env.is_headless() then
      print("<mes> " .. text)
   end
end

function Gui.mes_visible(text, x, y, color)
   local Map = require("api.Map")
   if Map.is_in_fov(x, y) then
      Gui.mes(text, color)
   end
end

function Gui.mes_clear()
   get_message_window():clear()
end

-- TODO: just use \n inline
function Gui.mes_newline()
   get_message_window():newline()
end

function Gui.mes_new_turn()
   get_message_window():new_turn()
end

function Gui.mes_continue_sentence()
end

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

function Gui.play_background_sound(sound_id)
   local sound_manager = require("internal.global.sound_manager")

   sound_manager:play_looping(sound_id)
end

function Gui.stop_background_sound(sound_id)
   local sound_manager = require("internal.global.sound_manager")

   sound_manager:stop_looping(sound_id)
end

function Gui.bind_keys(keys)
   field:bind_keys(keys)
end

return Gui
