local field = require("game.field")
local I18N = require("api.I18N")

local Gui = {}

function Gui.update_screen()
   field:update_screen()
end

local function get_message_window()
   return field.hud:find_widget("api.gui.hud.UiMessageWindow")
end

function Gui.mes(text, color)
   if string.find(text, I18N.quote_character()) and color == nil then
      color = {210, 250, 160}
   end
   get_message_window():message(text, color)
end

function Gui.mes_newline()
   get_message_window():newline()
end

function Gui.mes_new_turn()
   get_message_window():new_turn()
end

return Gui
