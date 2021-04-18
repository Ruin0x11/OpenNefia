local IAspect = require("api.IAspect")

local ICharaEquipStyle = class.interface("ICharaEquipStyle",
                                  {
                                     is_wielding_shield = "boolean",
                                     is_wielding_two_handed = "boolean",
                                     is_dual_wielding = "boolean",
                                  },
                                  { IAspect })

ICharaEquipStyle.default_impl = "api.chara.aspect.CharaEquipStyleAspect"

function ICharaEquipStyle:refresh_melee_equip_style(chara)
end

return ICharaEquipStyle
