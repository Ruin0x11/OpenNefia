local IKeyInput = require("api.gui.IKeyInput")
local IMouseInput = require("api.gui.IMouseInput")

local InputHandler = class("InputHandler", {IKeyInput, IMouseInput})

InputHandler:delegate("keys", IKeyInput)
InputHandler:delegate("mouse", IMouseInput)

function InputHandler:init()
   self.keys = KeyHandler:new()
   self.mouse = MouseHandler:new()
end

return InputHandler
