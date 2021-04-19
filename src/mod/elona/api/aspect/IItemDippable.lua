local IItemDippable = class.interface("IItemDippable",
                                   {
                                      can_dip_into = "function",
                                      on_dip_into = "function"
                                   })

return IItemDippable
