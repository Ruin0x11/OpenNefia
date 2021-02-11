local IUiElement = require("api.gui.IUiElement")

local IConfigItemWidget = class.interface("IConfigItemWidget", {
                                           enabled = "boolean",
                                           get_value = "function",
                                           set_value = "function",
                                           can_change = "function",
                                           can_choose = "function",
                                           on_choose = "function",
                                           on_change = "function",
                                                           },
                                        { IUiElement })

function IConfigItemWidget:init(item, value)
   self.enabled = true
end

return IConfigItemWidget
