local Map = require("api.Map")
local input = require("internal.input")

local IUiLayer = require("api.gui.IUiLayer")
local InventoryMenu = require("api.gui.menu.InventoryMenu")
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

function Input.query_text(length, can_cancel, limit_length)
   return TextPrompt:new(length, can_cancel, limit_length):query()
end

function Input.query_inventory(chara, can_cancel)
   local ctxt = {
      chara = chara,
      target = nil,
      container = nil,
      map = Map.current(),
      stack = {},
      sources = { "chara", "ground" }
   }
   return InventoryMenu:new(ctxt, can_cancel):query()
end

return Input
