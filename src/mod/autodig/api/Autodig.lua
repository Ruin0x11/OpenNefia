local Gui = require("api.Gui")

local Autodig = {}

function Autodig.is_enabled()
   return not not save.autodig.enabled
end

function Autodig.set_enabled(enabled)
   save.autodig.enabled = not not enabled
end

function Autodig.toggle()
   save.autodig.enabled = not save.autodig.enabled

   if save.autodig.enabled then
      Gui.mes("autodig.command.enable")
   else
      Gui.mes("autodig.command.disable")
   end

   Gui.refresh_hud()
end

return Autodig
