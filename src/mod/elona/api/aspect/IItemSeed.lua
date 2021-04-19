local IAspect = require("api.IAspect")
local IItemUseable = require("mod.elona.api.aspect.IItemUseable")

local IItemSeed = class.interface("IItemSeed", { plant_id = "string" }, { IAspect, IItemUseable })

IItemSeed.default_impl = "mod.elona.api.aspect.ItemSeedAspect"

function IItemSeed:localize_action()
   return "base:aspect._.elona.IItemSeed.action_name"
end

function IItemSeed:on_use(item, params)
   -- >>>>>>>> elona122/shade2/action.hsp:1729 	if iTypeMinor(ci)=fltSeed	:goto *item_seed ..
   local Gardening = require("mod.elona.api.Gardening")
   if Gardening.plant_seed(item, params.chara) then
      return "turn_end"
   end
   -- <<<<<<<< elona122/shade2/action.hsp:1729 	if iTypeMinor(ci)=fltSeed	:goto *item_seed ..
end

return IItemSeed
