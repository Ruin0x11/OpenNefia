Env = require("api.Env")
local Dialog = require("mod.elona_sys.dialog.api.Dialog")
local Chara = require("api.Chara")

local putit = assert(Chara.find("elona.putit"))

Env.clear_ui_results()
Env.push_ui_result(1)
Env.push_ui_result(2)
Env.push_ui_result(4)

Dialog.start(putit, "mine.main")
