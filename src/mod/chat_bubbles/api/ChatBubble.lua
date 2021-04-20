local Draw = require("api.Draw")
local global = require("mod.chat_bubbles.internal.global")
local ICharaChatBubble = require("mod.chat_bubbles.api.aspect.ICharaChatBubble")

local ChatBubble = {}

function ChatBubble.add(uid, text, bubble_color, text_color, font, font_size, font_style, x_offset, y_offset)
   local chat_bubbles = global.chat_bubbles

   bubble_color = bubble_color or {255, 255, 255, 255}
   text_color = text_color or {0, 0, 0, 255}
   font_size = font_size or 11
   x_offset = x_offset or 0
   y_offset = y_offset or 0

   Draw.set_font(font_size)
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
      font_size = font_size,
      font_style = font_style,
      x_offset = x_offset,
      y_offset = y_offset,
      frame = 0
   }
end

function ChatBubble.get(uid)
   return global.chat_bubbles[uid]
end

function ChatBubble.get_bubble_params(chara)
   local bubble_color, text_color, font, font_size, font_style
   local x_offset = 0
   local y_offset = 0
   local show_when_disabled

   local aspect = chara:get_aspect(ICharaChatBubble)
   if aspect then
      text_color = aspect:calc(chara, "text_color")
      bubble_color = aspect:calc(chara, "bg_color")
      font = aspect:calc(chara, "font")
      font_size = aspect:calc(chara, "font_size")
      font_style = aspect:calc(chara, "font_style")

      x_offset = aspect:calc(chara, "x_offset")
      y_offset = aspect:calc(chara, "y_offset")
      show_when_disabled = aspect:calc(chara, "show_when_disabled")
   end

   text_color = text_color or config.chat_bubbles.default_text_color
   bubble_color = bubble_color or config.chat_bubbles.default_bubble_color
   font = font or config.chat_bubbles.default_font
   font_size = font_size or config.chat_bubbles.default_font_size
   font_style = font_style or config.chat_bubbles.default_font_style
   show_when_disabled = show_when_disabled or config.chat_bubbles.enabled

   return bubble_color, text_color, font, font_size, font_style, x_offset, y_offset, show_when_disabled
end

function ChatBubble.clear()
   table.replace_with(global.chat_bubbles, {})
end

function ChatBubble.on_hotload(old, new)
   ChatBubble.clear()
   table.replace_with(old, new)
end

return ChatBubble
