local IList = require("api.gui.IList")
local IUiElement = require("api.gui.IUiElement")
local IFocusable = require("api.gui.IFocusable")

return class.interface("IUiList",
                 {},
                 {IList, IUiElement, IFocusable})
