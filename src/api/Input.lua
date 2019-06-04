local input = require("internal.input")

local IUiLayer = require("api.gui.IUiLayer")
local Prompt = require("api.gui.Prompt")
local TextPrompt = require("api.gui.TextPrompt")

-- Functions for receiving input from the player.
-- @module Input
local Input = {}

Input.set_key_handler = input.set_key_handler
Input.set_mouse_handler = input.set_mouse_handler

function Input.yes_no()
   local res = Prompt:new({{ text = "ああ", key = "y" }, { text = "いや...", key = "n" }}):query()
   return res.index == 1
end

function Input.prompt_text(length, can_cancel, limit_length)
   return TextPrompt:new(length, can_cancel, limit_length):query()
end

return Input
