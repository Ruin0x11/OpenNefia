local IUiLayer = require("api.gui.IUiLayer")

local ICharaMakeSection = class.interface("ICharaMakeSection",
                 {
                    caption = "string",
                    intro_sound = "string",
                    on_make_chara = "function",
                 },
                 { IUiLayer })

function ICharaMakeSection.charamake_result(chara)
   return nil
end

function ICharaMakeSection.on_charamake_finish(chara)
end

return ICharaMakeSection
