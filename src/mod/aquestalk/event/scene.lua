local Event = require("api.Event")
local I18N = require("api.I18N")
local AquesTalk = require("mod.aquestalk.api.AquesTalk")

local function aquestalk_speak_scene(_, _, result)
   if I18N.language_id() ~= "base.japanese" then
      return result
   end

   local node = result.node
   local enabled = config.aquestalk.enabled_scene

   if node == nil then
      return result
   end

   if node[1] == "chat" and (enabled == "dialog" or enabled == "dialog_and_text") then
      local text = node[3]
      AquesTalk.speak(text, nil, nil, nil, "aquestalk.scene")
   end

   if node[1] == "txt" and enabled == "dialog_and_text" then
      local text = node[2]
      AquesTalk.speak(text, nil, nil, nil, "aquestalk.scene")
   end

   return result
end
Event.register("elona_sys.on_scene_proceed", "AquesTalk speak scene", aquestalk_speak_scene)
