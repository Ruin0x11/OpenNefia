local IAspect = require("api.IAspect")
local IItemUseable = require("mod.elona.api.aspect.IItemUseable")
local Gui = require("api.Gui")
local Magic = require("mod.elona_sys.api.Magic")

local IItemGaroksHammer = class.interface("IItemGaroksHammer", {
                                          seed = "number"
                                                         },
                                       {
                                          IAspect,
                                          IItemUseable,
                                       })

IItemGaroksHammer.default_impl = "mod.elona.api.aspect.ItemGaroksHammerAspect"

function IItemGaroksHammer:localize_action()
   return "base:aspect._.elona.IItemGaroksHammer.action_name"
end

function IItemGaroksHammer:on_use(item, params)
   -- >>>>>>>> shade2/action.hsp:1973 	case effGarokHammer ...
   Gui.mes("action.use.hammer.use", item:build_name(1))
   Gui.play_sound("base.build1", params.chara.x, params.chara.y)
   Magic.cast("elona.effect_garoks_hammer", { target = params.chara, item = item, power = 100 })
   -- <<<<<<<< shade2/action.hsp:1976 	swbreak ..
end

return IItemGaroksHammer
