local I18N = require("api.I18N")
local AquesTalk = require("mod.aquestalk.api.AquesTalk")
local Event = require("api.Event")

local function aquestalk_speak_dialog(_, params, result)
   if config.aquestalk.enabled_dialog and I18N.language_id() == "base.japanese" then
      local bas, spd, vol, pit, acc, lmd, fsc = AquesTalk.calc_chara_params(params.talk.speaker)

      AquesTalk.speak(params.text, nil, nil, nil, "aquestalk.dialog", bas, spd, vol, pit, acc, lmd, fsc)
   end
end
Event.register("elona_sys.on_show_dialog", "AquesTalk speak dialog", aquestalk_speak_dialog)
