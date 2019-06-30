local IKeyInput = require("api.gui.IKeyInput")
local IMouseInput = require("api.gui.IMouseInput")

return class.interface("IInput", {}, {IKeyInput, IMouseInput})
