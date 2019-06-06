local Chara = require("api.Chara")

local Gui = {}

function Gui.redraw_screen()
   local field = require("game.field")
   if field.is_active then
      local field_renderer = require("internal.field_renderer")
      local player = Chara.player()
      if player then
         field_renderer.get():update_draw_pos(player.x, player.y)
      else
         field_renderer.get():update()
      end
   end
end

return Gui
