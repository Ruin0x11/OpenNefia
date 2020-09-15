local field = require("game.field")
local field_logic = require("game.field_logic")
local Gui = require("api.Gui")
local Log = require("api.Log")

local util = {}

function util.load_game()
   Log.info("Attempting to load game headlessly.")

   field.is_active = false
   field_logic.quickstart()
   field_logic.setup()
   field.is_active = true
   Gui.update_screen() -- refresh shadows/FOV
end

return util
