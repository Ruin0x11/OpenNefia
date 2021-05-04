local ICharaMakeSection = class.interface("ICharaMakeSection",
                 {
                    on_charamake_finish = "function",
                    get_charamake_result = "function"
                 })

function ICharaMakeSection:on_charamake_finish(result)
end

function ICharaMakeSection:get_charamake_result(charamake_data, retval)
   return charamake_data
end

return ICharaMakeSection
