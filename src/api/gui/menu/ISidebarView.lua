local IUiElement = require("api.gui.IUiElement")
local ISettable = require("api.gui.ISettable")

return class.interface("ISidebarView", { get_sidebar_entries = "function" }, {IUiElement, ISettable})
