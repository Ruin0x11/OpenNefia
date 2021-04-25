local Event = require("api.Event")
local I18N = require("api.I18N")
local AquesTalk = require("mod.aquestalk.api.AquesTalk")

local function extract_quoted_text(text)
   if text:match("「.*」") then
      return text:gsub("「(.*)」", "%1")
   end

   if text:match("\".*\"") then
      return text:gsub("\"(.*)\"", "%1")
   end

   return text
end

local function aquestalk_speak_chara_talk(chara, params)
   if config.aquestalk.enabled_chara_talk and I18N.language_id() == "base.japanese" and I18N.is_quoted(params.text) then
      local text = extract_quoted_text(params.text)
      local channel = chara:get_talk_channel()

      local bas, spd, vol, pit, acc, lmd, fsc = AquesTalk.calc_chara_params(chara)

      AquesTalk.speak(text, chara.x, chara.y, nil, channel, bas, spd, vol, pit, acc, lmd, fsc)
   end
end
Event.register("base.on_chara_say_text", "AquesTalk speak chara talk", aquestalk_speak_chara_talk)
