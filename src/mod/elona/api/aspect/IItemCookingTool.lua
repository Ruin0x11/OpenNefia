local IAspect = require("api.IAspect")
local IItemUseable = require("mod.elona.api.aspect.IItemUseable")
local Magic = require("mod.elona_sys.api.Magic")

local IItemCookingTool = class.interface("IItemCookingTool", { cooking_quality = "number" }, { IAspect, IItemUseable })

IItemCookingTool.default_impl = "mod.elona.api.aspect.ItemCookingToolAspect"

function IItemCookingTool:localize_action()
   return "base:aspect._.elona.IItemCookingTool.action_name"
end

function IItemCookingTool:on_use(item, params)
   -- >>>>>>>> elona122/shade2/action.hsp:1729 	if iTypeMinor(ci)=fltCookingTool	:goto *item_seed ..
   Magic.cast("elona.cooking", { source = params.chara, item = item })
   -- <<<<<<<< elona122/shade2/action.hsp:1729 	if iTypeMinor(ci)=fltCookingTool	:goto *item_seed ..
end

return IItemCookingTool
