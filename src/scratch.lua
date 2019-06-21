local Gui = require("api.Gui")
local Chara = require("api.Chara")

for i=0,10 do
   local x = i * 1
   Gui.mes(tostring(x) .. " ")
   Gui.play_sound("base.ball1", Chara.player().x - 5 + x, Chara.player().y+3)
   Gui.wait(3000)
end
