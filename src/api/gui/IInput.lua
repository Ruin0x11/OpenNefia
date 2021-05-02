local IKeyInput = require("api.gui.IKeyInput")
local IMouseInput = require("api.gui.IMouseInput")

local IInput = class.interface("IInput", {}, {IKeyInput, IMouseInput})

function IInput:make_key_hints()
   return {}
end

return IInput
