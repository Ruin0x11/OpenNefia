local IList = require("api.gui.IList")
local IUiElement = require("api.gui.IUiElement")
local IInput = require("api.gui.IInput")

return class.interface("IUiList",
                 {},
                 {IList, IUiElement, IInput})
