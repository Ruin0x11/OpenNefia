local IUiList = require("api.gui.IUiList")
local IPaged = require("api.gui.IPaged")

return interface("IUiPagedList", {}, {IPaged, IUiList})
