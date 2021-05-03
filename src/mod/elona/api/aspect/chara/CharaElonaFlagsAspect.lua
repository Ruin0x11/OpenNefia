local ICharaElonaFlags = require("mod.elona.api.aspect.chara.ICharaElonaFlags")

local CharaElonaFlagsAspect = class.class("CharaElonaFlagsAspect", ICharaElonaFlags)

function CharaElonaFlagsAspect:init(chara, params)
   self.absorbed_charges = params.absorbed_charges or 0

   self.has_shield_bash = params.has_shield_bash or false
   self.is_married = params.is_married or false
   self.is_being_escorted_sidequest = params.is_being_escorted_sidequest or false
   self.has_given_token_of_friendship = params.has_given_token_of_friendship or false
end

return CharaElonaFlagsAspect
