local Gui = require("api.Gui")

require("mod.chat_bubbles.data.init")
require("mod.chat_bubbles.event.init")

Gui.register_draw_layer("damage_popups", "mod.chat_bubbles.api.gui.ChatBubbleLayer")
