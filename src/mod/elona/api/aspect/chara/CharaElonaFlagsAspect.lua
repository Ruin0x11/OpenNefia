local ICharaElonaFlags = require("mod.elona.api.aspect.chara.ICharaElonaFlags")

local CharaElonaFlagsAspect = class.class("CharaElonaFlagsAspect", ICharaElonaFlags)

function CharaElonaFlagsAspect:init(chara, params)
   self.is_married = params.is_married or false
   self.is_being_escorted_sidequest = params.is_being_escorted_sidequest or false
end

return CharaElonaFlagsAspect
