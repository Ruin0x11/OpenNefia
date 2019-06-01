local input = require("internal.input")

local Input = {}
local IUiLayer = require("api.gui.IUiLayer")
local Prompt = require("api.gui.Prompt")

Input.set_key_handler = input.set_key_handler
Input.set_mouse_handler = input.set_mouse_handler

function Input.yes_no()
   local res = Prompt:new({{ text = "ああ", key = "y" }, { text = "いや...", key = "n" }}):query()
   return res.index == 1
end

return Input
