local chara_make = require("game.chara_make")

local CharaMake = {}

CharaMake.get_section_result = chara_make.get_section_result

setmetatable(CharaMake,
             {
                __index = {
                   sections = chara_make.sections
                },
                __newindex = function(t, k, v)
                   if k == "sections" then
                      chara_make[k] = v
                   end
                end
             }
)

return CharaMake
