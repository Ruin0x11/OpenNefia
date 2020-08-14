local IUiLayer = require("api.gui.IUiLayer")

local ICharaMakeSection = class.interface("ICharaMakeSection",
                 {
                    caption = "string",
                    intro_sound = "string",
                    on_charamake_finish = "function",
                    on_charamake_query_menu = "function"
                 },
                 { IUiLayer })

function ICharaMakeSection.on_charamake_finish(result)
end

function ICharaMakeSection.on_charamake_query_menu()
end

return ICharaMakeSection
