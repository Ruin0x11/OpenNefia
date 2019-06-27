require("boot")

local env = require("internal.env")

require("internal.data.schemas")
local data = require("internal.data")
local Chara = require("api.Chara")

Chara.at = nil

Chara = env.hotload("api.Chara", true)
Chara = env.hotload("api.Chara", true)

print(inspect(data["base.chara"]["base.me"].name))
_p(Chara.iter_allies():to_list())
