local Chara = require("api.Chara")
local Pcc = require("api.gui.Pcc")

Chara.player().pcc = Pcc:new {
   {
      id = "elona.etc_10",
      z_order = 100
   },
   {
      id = "elona.body_1",
      z_order = 0
   },
   {
      id = "elona.eye_1",
      z_order = 10
   }
}
