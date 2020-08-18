local IUiLayer = require("api.gui.IUiLayer")

local ICharaMakeSection = class.interface("ICharaMakeSection",
                 {
                    caption = "string",
                    -- TODO remove
                    -- intro_sound = "string",
                    on_charamake_finish = "function",
                    on_charamake_query_menu = "function",
                    get_charamake_result = "function"
                 },
                 { IUiLayer })

function ICharaMakeSection:on_charamake_finish(result)
end

function ICharaMakeSection:on_charamake_query_menu()
end

function ICharaMakeSection:get_charamake_result(charamake_data, retval)
   return charamake_data
end

return ICharaMakeSection
