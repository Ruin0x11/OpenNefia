local Draw = require("api.Draw")

local ResistanceLayout = class("ResistanceLayout")

function ResistanceLayout:draw_row(item, text, subtext, x, y)
   Draw.filled_rect(x, y, 400, 16, {200, 0, 0})
   text = utf8.wide_sub(text, 0, 22)
   return text, subtext
end

return ResistanceLayout
