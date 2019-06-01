local IKeyInput = require("api.gui.IKeyInput")
local IMouseInput = require("api.gui.IMouseInput")

return interface("IInput", {}, {IKeyInput, IMouseInput})
