local IAspect = require("api.IAspect")
local IItemUseable = require("mod.elona.api.aspect.IItemUseable")
local IItemLocalizableExtra = require("mod.elona.api.aspect.IItemLocalizableExtra")
local Magic = require("mod.elona_sys.api.Magic")
local I18N = require("api.I18N")

local IItemFishingPole = class.interface("IItemFishingPole", {
                                            bait_type = { type = "string", optional = true },
                                          bait_amount = "number"
                                                         },
                                       {
                                          IAspect,
                                          IItemUseable,
                                          IItemLocalizableExtra
                                       })

IItemFishingPole.default_impl = "mod.elona.api.aspect.ItemFishingPoleAspect"

function IItemFishingPole:localize_action()
   return "base:aspect._.elona.IItemFishingPole.action_name"
end

function IItemFishingPole:on_use(item, params)
   Magic.cast("elona.fishing", { source = params.chara, item = item })
end

function IItemFishingPole:localize_extra(s, item)
   local bait_amount = self:calc(item, "bait_amount")
   local bait_type = self:calc(item, "bait_type")
   if bait_amount > 0 and bait_type then
      local bait_name = I18N.localize("elona.bait", bait_type, "name")
      return I18N.get("base:aspect._.elona.IItemFishingPole.remaining", s, bait_name, bait_amount)
   end
end

return IItemFishingPole
