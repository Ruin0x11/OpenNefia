local ICharaChatBubble = require("mod.chat_bubbles.api.aspect.ICharaChatBubble")

local CharaChatBubbleAspect = class.class("CharaChatBubbleAspect", ICharaChatBubble)

function CharaChatBubbleAspect:init(chara, params)
   self.x_offset = params.x_offset or 0
   self.y_offset = params.y_offset or 0
   self.show_when_disabled = params.show_when_disabled or "disabled"

   self.bubble_color = params.bubble_color or nil
   self.text_color = params.text_color or nil
   self.font_name = params.font_name or nil
   self.font_size = params.font_size or nil
   self.font_style = params.font_style or nil
end

return CharaChatBubbleAspect
