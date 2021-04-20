local Event = require("api.Event")
local I18N = require("api.I18N")
local ChatBubble = require("mod.chat_bubbles.api.ChatBubble")

local function add_chat_bubble(chara, params)
   if I18N.is_quoted(params.text) then
      ChatBubble.add(chara.uid, params.text)
   end
end
Event.register("base.on_chara_say_text", "Add chat bubble", add_chat_bubble)
