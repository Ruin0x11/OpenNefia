local IAspect = require("api.IAspect")

local flags = {
   is_married = "boolean",                 -- cMarry
   is_being_escorted_sidequest = "boolean" -- cGuardTemp
}

local ICharaElonaFlags = class.interface("ICharaElonaFlags",
                       flags,
                       { IAspect })

ICharaElonaFlags.default_impl = "mod.elona.api.aspect.chara.CharaElonaFlagsAspect"

return ICharaElonaFlags
