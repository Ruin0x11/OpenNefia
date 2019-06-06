local Chara = require("api.Chara")
local field = require("game.field")

local Gui = {}

function Gui.redraw_screen()
   field:redraw_screen()
end

return Gui
