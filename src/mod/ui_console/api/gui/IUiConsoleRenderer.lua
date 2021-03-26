local IUiElement = require("api.gui.IUiElement")

return class.interface("IUiConsoleRenderer", {
                          render_chars = "function",
                          set_font_size = "function"
                                             },
                       {IUiElement})
