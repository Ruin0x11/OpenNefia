local Map = require("api.Map")
local input = require("internal.input")

local IUiLayer = require("api.gui.IUiLayer")
local Prompt = require("api.gui.Prompt")
local TextPrompt = require("api.gui.TextPrompt")
local NumberPrompt = require("api.gui.NumberPrompt")

-- Functions for receiving input from the player.
-- @module Input
local Input = {}

Input.set_key_handler = input.set_key_handler
Input.set_mouse_handler = input.set_mouse_handler

function Input.yes_no()
   local res = Prompt:new({{ text = "ああ", key = "y" }, { text = "いや...", key = "n" }}):query()
   return res.index == 1
end

function Input.query_text(length, can_cancel, limit_length)
   return TextPrompt:new(length, can_cancel, limit_length):query()
end

function Input.query_number(max, initial)
   return NumberPrompt:new(max, initial):query()
end

function Input.query_inventory(chara, operation)
   local InventoryWrapper = require("api.gui.menu.InventoryWrapper")

   operation = operation or "inv_general"

   local params = {
      chara = chara,
      target = nil,
      container = nil,
      map = Map.current(),
   }

   local result, canceled = InventoryWrapper:new(operation, params):query()

   return (result or "player_turn_query"), canceled
end

return Input
