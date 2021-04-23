local IInventoryMenuDetailView =  class.interface("IInventoryMenuDetailView",
                                                  {
                                                     on_page_changed = "function",
                                                     relayout = "function",
                                                     draw_header = "function",
                                                     draw_row = "function",
                                                     update = "function"
                                                  })

return IInventoryMenuDetailView
