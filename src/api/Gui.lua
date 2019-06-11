local draw = require("internal.draw")
local field = require("game.field")
local I18N = require("api.I18N")

local Gui = {}

function Gui.update_screen()
   field:update_screen()
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

function Gui.mes(text, color)
   if color == nil and string.find(text, I18N.quote_character()) then
      color = {210, 250, 160}
   end
   if type(color) == "string" then
      color = Color[color] or {255, 255, 255}
   end
   get_message_window():message(text, color)
end

function Gui.mes_clear()
   get_message_window():clear()
end

function Gui.mes_newline()
   get_message_window():newline()
end

function Gui.mes_new_turn()
   get_message_window():new_turn()
end

function Gui.mes_continue_sentence()
   get_message_window():new_turn()
end

return Gui
