local IUiLayer = require("api.gui.IUiLayer")
local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")

local ICharaMakeMenu = class.interface("ICharaMakeMenu",
                 {
                    -- TODO remove
                    -- intro_sound = "string",
                    caption = "string",
                    on_charamake_query_menu = "function",
                 },
                 { IUiLayer, ICharaMakeSection })

function ICharaMakeMenu:on_charamake_query_menu()
end

return ICharaMakeMenu
