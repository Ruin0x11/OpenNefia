local Chara = require("api.Chara")
local ExHelpPrompt = require("mod.elona.api.gui.ExHelpPrompt")
local Gui = require("api.Gui")
local I18N = require("api.I18N")

local ExHelp = {}

function ExHelp.show(id, force)
   -- >>>>>>>> shade2/init.hsp:4272 	#define global help(%%1,%%2=0) if cfg_extraHelp@:if ...
   data["elona.ex_help"]:ensure(id)

   if not config.base.extra_help then
      return
   end

   if save.elona.ex_help_shown[id] and not force then
      return
   end

   local text = I18N.get_optional(("elona.ex_help._.%s"):format(id))
   if not text then
      Log.error("missing help text for %s", id)
      return
   end

   local player = Chara.player()
   if not Chara.is_alive(player) or (player:has_activity() and not player:has_activity("elona.traveling")) then
      return
   end

   Gui.update_screen()
   ExHelpPrompt:new(text):query()
   save.elona.ex_help_shown[id] = true
   -- <<<<<<<< shade2/init.hsp:4272 	#define global help(%%1,%%2=0) if cfg_extraHelp@:if ..
end

return ExHelp
