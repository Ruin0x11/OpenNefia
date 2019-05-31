local IList = require("api.gui.IList")
local IUiElement = require("api.gui.IUiElement")
local IFocusable = require("api.gui.IFocusable")

return interface("IUiList",
                 {},
                 {IList, IUiElement, IFocusable})
