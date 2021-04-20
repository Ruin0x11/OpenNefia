local Gui = require("api.Gui")

require("mod.chat_bubbles.data.init")
require("mod.chat_bubbles.event.init")

Gui.register_draw_layer("chat_bubbles", "mod.chat_bubbles.api.gui.ChatBubbleLayer")
