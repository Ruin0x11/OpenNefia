local Draw = require("api.Draw")
local global = require("mod.chat_bubbles.internal.global")

local ChatBubble = {}

function ChatBubble.add(uid, text, font, bubble_color, text_color)
   local chat_bubbles = global.chat_bubbles

   bubble_color = bubble_color or {255, 255, 255, 255}
   text_color = text_color or {0, 0, 0, 255}
   font = font or 20 -- 11

   Draw.set_font(font)
   local width = Draw.text_width(text) + 10
   local height = Draw.text_height() + 10

   chat_bubbles[uid] = {
      uid = uid,
      text = text,
      width = width,
      height = height,
      bubble_color = bubble_color,
      text_color = text_color,
      font = font,
      frame = 0
   }
end

function ChatBubble.clear()
   table.replace_with(global.chat_bubbles, {})
end

function ChatBubble.on_hotload(old, new)
   ChatBubble.clear()
   table.replace_with(old, new)
end

return ChatBubble
