local IWidgetMessageWindow = class.interface("IWidgetMessageWindow", {
                                                message = "function",
                                                newline = "function",
                                                redraw = "function",
                                                new_turn = "function",
                                                clear = "function",
                                                duplicate = "function",
})

return IWidgetMessageWindow
