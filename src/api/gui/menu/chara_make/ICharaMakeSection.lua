local IUiLayer = require("api.gui.IUiLayer")

local ICharaMakeSection = class.interface("ICharaMakeSection",
                 {
                    caption = "string",
                    intro_sound = "string",
                    on_make_chara = "function",
                    on_resume_query = "function"
                 },
                 { IUiLayer })

function ICharaMakeSection.charamake_result(chara)
   return nil
end

function ICharaMakeSection.on_make_chara(chara)
end

function ICharaMakeSection.on_resume_query()
end

return ICharaMakeSection
