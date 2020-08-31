local IPlotRenderable = class.interface("IPlotRenderable", {
                                           draw_with_renderer = "function",
                                           refresh = "function"
})

return IPlotRenderable
