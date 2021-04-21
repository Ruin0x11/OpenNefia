local IAspect = require("api.IAspect")

local ICharaChatBubble = class.interface("ICharaChatBubble",
                                         {
                                            x_offset = "number",
                                            y_offset = "number",
                                            show_when_disabled = "string",

                                            color = { type = "table", optional = true },
                                            bg_color = { type = "table", optional = true },
                                            font_name = { type = "string", optional = true },
                                            font_size = { type = "number", optional = true },
                                            font_style = { type = "number", optional = true },
                                         },
                                         { IAspect })

ICharaChatBubble.default_impl = "mod.chat_bubbles.api.aspect.CharaChatBubbleAspect"

return ICharaChatBubble
