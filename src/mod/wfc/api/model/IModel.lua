local IModel = class.interface("IModel", {
                          is_on_boundary = "function",
                          to_image_data = "function",
                          run = "function",
                          clear = "function",
                          is_fully_observed = "function"
})
