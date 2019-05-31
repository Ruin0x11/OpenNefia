local IKeyInput = require("api.gui.IKeyInput")
local IMouseInput = require("api.gui.IMouseInput")
local KeyHandler = require("api.gui.KeyHandler")
local MouseHandler = require("api.gui.MouseHandler")

local InputHandler = class("InputHandler", {IKeyInput, IMouseInput})

InputHandler:delegate("keys", {"receive_key", "run_action"})
InputHandler:delegate("mouse", {"receive_mouse_movement", "receive_mouse_button"})

function InputHandler:init()
   self.keys = KeyHandler:new()
   self.mouse = MouseHandler:new()
end

function InputHandler:focus()
   self.keys:focus()
   self.mouse:focus()
end

function InputHandler:forward_to(handler, keys)
   self.keys:forward_to(handler, keys)
end

function InputHandler:run_actions()
   self.keys:run_actions()
   self.mouse:run_actions()
end

return InputHandler
