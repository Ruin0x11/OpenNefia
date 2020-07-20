local data = require("internal.data")
local Event = require("api.Event")
local Gui = require("api.Gui")
local Rand = require("api.Rand")

local ICharaBuffs = class.interface("ICharaBuffs")

function ICharaBuffs:init()
   self.buffs = {}
end

function ICharaBuffs:remove_all_buffs()
   self.buffs = {}
end

return ICharaBuffs
