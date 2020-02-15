local UiTheme = require("api.gui.UiTheme")

local t = UiTheme.load()

t.base.hud_icons:draw(0, 0, 100, 100)

t = UiTheme.load().base

t.hud_icons:draw(0, 0, 100, 100)
