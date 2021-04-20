local Event = require("api.Event")
local I18N = require("api.I18N")
local ChatBubble = require("mod.chat_bubbles.api.ChatBubble")

local function extract_quoted_text(text)
   if text:match("「.*」") then
      return text:gsub("「(.*)」", "%1")
   end

   if text:match("\".*\"") then
      return text:gsub("\"(.*)\"", "%1")
   end

   return text
end

local function add_chat_bubble(chara, params)
   if I18N.is_quoted(params.text) then
      local bubble_color, text_color, font, font_size, font_style, x_offset, y_offset, show_when_disabled = ChatBubble.get_bubble_params(chara)
      local text = extract_quoted_text(params.text)

      -- >>>>>>>> oomSEST/src/southtyris.hsp:1137 			if (cfg_txtpop > 0 | ocdata(164, oom_talkchara) ...
      if not config.chat_bubbles.enabled and show_when_disabled == "never" then
         return
      end
      -- <<<<<<<< oomSEST/src/southtyris.hsp:1137 			if (cfg_txtpop > 0 | ocdata(164, oom_talkchara) ..

      -- >>>>>>>> oomSEST/src/net.hsp:1478 						if (cfg_txtpop == 1 | ocdata(164, txtpopup(1 ...
      if ChatBubble.get(chara.uid) and show_when_disabled ~= "unlimited" then
         return
      end
      -- <<<<<<<< oomSEST/src/net.hsp:1480 						} ..

      ChatBubble.add(chara.uid, text, bubble_color, text_color, font, font_size, font_style, x_offset, y_offset)
   end
end
Event.register("base.on_chara_say_text", "Add chat bubble", add_chat_bubble)
