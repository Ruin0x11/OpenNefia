local IPlotRenderer = class.interface("IPlotRenderer",
                                      {
                                        draw_path = "function",
                                        draw_text = "function",
                                        get_text_width_height_descent = "function",
                                      })

function IPlotRenderer:draw_marker(ctx, x, y, radius, color)
end

return IPlotRenderer
