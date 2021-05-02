local IAspect = require("api.IAspect")

local flags = {
   has_shield_bash = "boolean",               -- cPowerBash
   is_married = "boolean",                    -- cMarry
   is_being_escorted_sidequest = "boolean",   -- cGuardTemp
   has_given_token_of_friendship = "boolean", -- cTokenFriend
}

local ICharaElonaFlags = class.interface("ICharaElonaFlags",
                       flags,
                       { IAspect })

ICharaElonaFlags.default_impl = "mod.elona.api.aspect.chara.CharaElonaFlagsAspect"

return ICharaElonaFlags
